import re, os, argparse
from typing import Dict, Tuple, List, Optional

# ---------- decl scan ----------
_DECL_RE = re.compile(r"""
^\s*(wire|reg|input|output)\b(?:\s+signed)?\s*
(?:\[\s*(\d+)\s*:\s*(\d+)\s*\])?\s*
(?P<names>
  (?:\\?[A-Za-z_]\w*(?:[\$][\w:.\-]+)?)(?:\s*\[\s*\d+\s*:\s*\d+\s*\])?
  (?:\s*,\s*(?:\\?[A-Za-z_]\w*(?:[\$][\w:.\-]+)?(?:\s*\[\s*\d+\s*:\s*\d+\s*\])?))*
)
\s*;
""", re.VERBOSE | re.MULTILINE)

def scan_decl_widths(verilog: str) -> Dict[str, Tuple[int,int]]:
    widths: Dict[str, Tuple[int,int]] = {}
    for m in _DECL_RE.finditer(verilog):
        msb_s, lsb_s = m.group(2), m.group(3)
        if msb_s is None or lsb_s is None:
            continue
        msb, lsb = int(msb_s), int(lsb_s)
        for nm in m.group("names").split(","):
            nm = nm.strip()
            base = re.match(r"\\?[A-Za-z_]\w*(?:[\$][\w:.\-]+)?", nm)
            if base:
                widths.setdefault(base.group(0), (msb, lsb))
    return widths

# ---------- $lut parse ----------
_LUT_RE = re.compile(r"""
\\?\$lut\s*\#\s*\(\s*
    \.LUT\(\s*([^)]+?)\s*\)\s*,\s*
    \.WIDTH\(\s*([^)]+?)\s*\)
\s*\)\s*
([^\s(]+)\s*\(\s*
    \.A\(\s*([^)]+?)\s*\)\s*,\s*
    \.Y\(\s*([^)]+?)\s*\)
\s*\)\s*;
""", re.MULTILINE | re.DOTALL | re.VERBOSE)

def parse_lut_instances(verilog_content: str):
    insts = []
    for m in _LUT_RE.finditer(verilog_content):
        lut_value, width, inst_name, inputs, output = m.groups()
        insts.append({
            "value": lut_value.strip(),
            "width": width.strip(),
            "name": inst_name.strip(),
            "inputs": inputs.strip(),
            "output": output.strip(),
            "full_match": m.group(0),
        })
    return insts

# ---------- helpers ----------
def _literal_to_int(lit: str) -> Optional[int]:
    s = lit.replace('_', '').strip().lower()
    m = re.fullmatch(r"\d+\s*'s?h([0-9a-f]+)", s)
    if m: return int(m.group(1), 16)
    m = re.fullmatch(r"\d+\s*'s?b([01x]+)", s)
    if m: return int(m.group(1).replace('x','0'), 2)
    m = re.fullmatch(r"\d+\s*'s?d(\d+)", s)
    if m: return int(m.group(1), 10)
    try:
        return int(s, 0)
    except Exception:
        return None

# ---------- escaped identifier fix ----------
_ESC_TERM_RE = re.compile(r'(\\[^\s\)\,]+)(?=[\)\,])')

def ensure_escaped_id_terminated(verilog_text: str) -> str:
    r"""Insert a whitespace after any escaped identifier (starting with '\')
    when it is immediately followed by ')' or ','. This is required by IEEE
    Verilog where escaped identifiers must be terminated by whitespace.
    Examples:
      .Y(\$abc$123)  -> .Y(\$abc$123 )
      .A(\foo,       -> .A(\foo ,

    This is safe to run repeatedly.
    """
    return _ESC_TERM_RE.sub(r'\1 ', verilog_text)

def _width_is_n(width_str: str, n: int) -> bool:
    return _literal_to_int(width_str) == n

_VEC2_RE = re.compile(r"^\s*(\\?[A-Za-z_]\w*(?:[\$][\w:.\-]+)?)\s*\[\s*(\d+)\s*:\s*(\d+)\s*\]\s*$")
_BIT_RE  = re.compile(r"^\s*(\\?[A-Za-z_]\w*(?:[\$][\w:.\-]+)?)\s*\[\s*(\d+)\s*\]\s*$")

def expand_A_port_for_lut2(a_expr: str, widths: Dict[str, Tuple[int,int]]) -> Optional[List[str]]:
    s = a_expr.strip()
    if s.startswith("{") and s.endswith("}"):
        parts = [p.strip() for p in s[1:-1].split(",") if p.strip()]
        return parts if len(parts) == 2 else None
    m = _VEC2_RE.match(s)
    if m:
        base, msb_s, lsb_s = m.group(1), int(m.group(2)), int(m.group(3))
        if abs(msb_s - lsb_s) == 1:
            return [f"{base}[{msb_s}]", f"{base}[{lsb_s}]"]
        return None
    if s in widths:
        msb, lsb = widths[s]
        lo = min(msb, lsb)
        span = abs(msb - lsb) + 1
        if span >= 2:
            return [f"{s}[{lo+1}]", f"{s}[{lo}]"]  
    return None

def get_single_bit_signal(a_expr: str, widths: Dict[str, Tuple[int,int]]) -> Optional[str]:
    """Resolve .A(...) to a single bit signal for LUT1."""
    s = a_expr.strip()
    if s.startswith("{") and s.endswith("}"):
        parts = [p.strip() for p in s[1:-1].split(",") if p.strip()]
        if len(parts) == 1:
            return parts[0]
        return None
    m = _BIT_RE.match(s)
    if m:
        base, idx = m.group(1), int(m.group(2))
        return f"{base}[{idx}]"
    m2 = _VEC2_RE.match(s)
    if m2:
        base, msb_s, lsb_s = m2.group(1), int(m2.group(2)), int(m2.group(3))
        idx = min(msb_s, lsb_s)
        return f"{base}[{idx}]"
    if s in widths:
        msb, lsb = widths[s]
        idx = min(msb, lsb)      
        return f"{s}[{idx}]"
    
    if re.fullmatch(r"\\?[A-Za-z_]\w*(?:[\$][\w:.\-]+)?", s):
        return s
    return None

# ---------- LUT mapping ----------
def map_lut2_to_cell(lut, cell_type, widths) -> Optional[str]:
    ab = expand_A_port_for_lut2(lut['inputs'], widths)
    if not ab:
        return None
    a_signal, b_signal = ab
    cfg = _literal_to_int(lut['value'])
    if cfg is None:
        return None
    bit0 = (cfg >> 0) & 1
    bit1 = (cfg >> 1) & 1
    bit2 = (cfg >> 2) & 1
    bit3 = (cfg >> 3) & 1

    # LUT2 truth table (A,B):
    #  A B | bit index  -> a_signal b_signal
    #  0 0 | 0                 0       0      |  bit0
    #  0 1 | 1                 0       1      |  bit1
    #  1 0 | 2                 1       0      |  bit2
    #  1 1 | 3                 1       1      |  bit3


    # TODO: complete inside each {""} with the right Configuration SRAM bits (bit0-3) or Select lines (a_signal, b_signal)
    # for example .D00(1'b{""}), -> .D00(1'b{bit0}),     
    if cell_type == "c2":
        return (f"c2 {lut['name']} (\n"
            f"    .D00(1'b{bit0}), .D01(1'b{bit1}), .D10(1'b{bit2}), .D11(1'b{bit3}),\n"
            f"    .A1({a_signal}), .B1(1'b0), .A0({b_signal}), .B0(1'b1),\n" 
            f"    .out({lut['output']})\n"
            f");")    

    # TODO: complete inside each {} with the right Configuration SRAM bits (bit0-3) or Select lines (a_signal, b_signal)
    return (f"c1 {lut['name']} (\n"
                f"    .A0(1'b{bit0}), .A1(1'b{bit1}), .SA({b_signal}),\n"
                f"    .B0(1'b{bit2}), .B1(1'b{bit3}), .SB({b_signal}),\n"
                f"    .S0({a_signal}), .S1(1'b0), .f({lut['output']})\n"
                f");") 
    

def map_lut1_to_cell(lut, cell_type, widths) -> Optional[str]:
    """Map WIDTH=1 LUT to c1/c2 keeping output independent of 'B'."""
    a = get_single_bit_signal(lut['inputs'], widths)
    if not a:
        return None
    cfg = _literal_to_int(lut['value'])
    if cfg is None:
        return None
    
    bit0 = (cfg >> 0) & 1  # A=0
    bit1 = (cfg >> 1) & 1  # A=1

    # LUT1 truth table (A):
    #  A  | bit index  -> a    bit index
    #  0  | 0             0    |  bit0
    #  1  | 1             1    |  bit1

    # TODO: complete inside each {} with the right Configuration SRAM bits (bit0-1) or Select line (a)
    # you can use constant bits 0, 1 if needed

    if cell_type == "c2":
           return (f"c2 {lut['name']} (\n"
            f"    .D00(1'b{bit0}), .D01(1'b{bit1}), .D10(1'b0), .D11(1'b0),\n"
            f"    .A1(1'b0), .B1(1'b0), .A0({a}), .B0(1'b1),\n"  
            f"    .out({lut['output']})\n"
            f");")
    
    return (f"c1 {lut['name']} (\n"
            f"    .A0(1'b{bit0}), .A1(1'b{bit1}), .SA({a}),\n"
            f"    .B0(1'b0), .B1(1'b0), .SB(1'b0),\n"
            f"    .S0(1'b0), .S1(1'b0), .f({lut['output']})\n"
            f");") 
     

# ---------- FF mapping ----------
_PORT_RE = re.compile(r"\.(\w+)\(\s*([^)]+?)\s*\)")

def _ports_dict(port_block: str) -> Dict[str,str]:
    return {k: v.strip() for k, v in _PORT_RE.findall(port_block)}

_SDFFE_RE = re.compile(r"""\\?\$_SDFFE_PP0P_\s*([^\s(]+)\s*\(\s*(.*?)\s*\)\s*;""", re.DOTALL)
_DFF_RE   = re.compile(r"""\\?\$_DFF_P_\s*([^\s(]+)\s*\(\s*(.*?)\s*\)\s*;""", re.DOTALL)


def map_sdffe_to_s2(inst_name: str, ports: Dict[str,str]) -> str:
    """Map SDFFE (sync DFF with enable and reset) to s2 module"""
    C = ports.get('C')
    D = ports.get('D') 
    E = ports.get('E')
    Q = ports.get('Q')
    R = ports.get('R')
    
    if not all([C, D, Q, E, R]):
        print(f"Warning: Missing ports in SDFFE instance {inst_name}")
        return None
        
    # SDFFE truth table:
    # R E | Action
    # 0 0 | Hold (Q <= Q)  
    # 0 1 | Load (Q <= D)
    # 1 0 | Reset (Q <= 0)
    # 1 1 | Reset (Q <= 0)

    #         +----------------------+
    # D ----->|                      |
    # C ----->|                      |-----> Q
    # E ----->|   $_SDFFE_PP0P_      |
    # R ----->|   (CE + reset)       |
    #         +----------------------+

    # C – clock (posedge, because of the final P)
    # D – data input
    # E – clock enable (active high, P)
    # R – reset (active high, P), reset value = 0 (the 0 in PP0P)
    # Q – output

    # TODO: complete inside each {} with the right arguments (C, D, E, R, Q) or const 1'b0, 1'b1
    return (
        f"s2 {inst_name} (\n"
        f"    .D00({Q}), .D01(1'b0), .D10({D}), .D11(1'b0),\n"  
        f"    .A1({E}), .B1(1'b0), .A0(1'b0), .B0(1'b0),\n"      
        f"    .clr({R}), .clk({C}), .out({Q})\n"             
        f");"
    )  
       

def map_dff_to_s1(inst: str, ports: Dict[str,str]) -> str:
    C = ports.get('C'); D = ports.get('D'); Q = ports.get('Q')

    #         +----------------------+
    # D ----->|                      |-----> Q
    # C ----->|      $_DFF_P_        |
    #         +----------------------+

    # C – clock (posedge, P)
    # D – data input
    # Q – output

    # TODO: complete inside each {} with the right arguments (C, D, Q) or const bits 1'b0, 1'b1
    return (
        f"s1 {inst} (\n"
        f"    .D00({D}), .D01(1'b0), .D10(1'b0), .D11(1'b0),\n"
        f"    .A1(1'b0), .B1(1'b0), .A0(1'b0),\n"
        f"    .clr(1'b0), .clk({C}), .out({Q})\n"
        f");"
    )     

def map_flipflops(verilog: str, mapped_s1, mapped_s2) -> str:
    out = verilog
    for m in list(_SDFFE_RE.finditer(out)):
        inst = m.group(1); ports = _ports_dict(m.group(2))
        out = out.replace(m.group(0), map_sdffe_to_s2(inst, ports), 1)
        mapped_s2 += 1
    for m in list(_DFF_RE.finditer(out)):
        inst = m.group(1); ports = _ports_dict(m.group(2))
        out = out.replace(m.group(0), map_dff_to_s1(inst, ports), 1)
        mapped_s1 += 1
    return out, mapped_s1, mapped_s2

# ---------- create modules file ----------
def create_modules_file(cell_type: str, count_cell: bool) -> str:
    """Create the modules.v file with all required module definitions"""
    modules_content = ""
    
    if count_cell:
    
        modules_content += """
module FDCP(
input clk , CLR, D, 
output reg Q);

    always @(posedge clk or posedge CLR)
        if(CLR)
        Q <= 0;
        else
        Q <= D;
endmodule

"""
        
        
        modules_content += """
module s1(input D00 , D01 ,D10 , D11 , A1 , B1 , A0 , clr , clk , output out);
    initial begin 
    $system("s2-s1.exe ");
    end
    wire s0 , s1 ,d; 
    assign s1 = A1 | B1 ;
    assign s0 = A0 & clr ;
    assign d= ({s1,s0}== 2'd0)? D00: 
            ({s1,s0}==2'd1)? D01: 
            ({s1,s0}==2'd2)? D10: 
            ({s1,s0}==2'd3)? D11 :
                    2'bz;
    FDCP ff(clk , clr , d, out) ;

endmodule

"""
    
        modules_content += """
module s2(input D00 , D01 ,D10 , D11 , A1 , B1 , A0,B0 , clr , clk , output out);
initial begin 
    $system("s2-s1.exe ");
    end
    wire s0 , s1 ,d; 
    assign s1 = A1 | B1 ;
    assign s0 = A0 & B0;
    assign d= ({s1,s0}== 2'd0)? D00: 
            ({s1,s0}==2'd1)? D01: 
            ({s1,s0}==2'd2)? D10: 
            ({s1,s0}==2'd3)? D11 :
                    2'bz;
    FDCP ff (clk , clr , d, out) ;     
endmodule

"""
        
        
        if cell_type == "c1":
            modules_content += """
module c1(input A0 , A1 , SA , B0 , B1 ,SB , S0 , S1,output f);
    initial begin 
    $system("c1.exe ");
    end
    wire f1 , f2 , s2; 
    assign f1 = (SA)? A1:A0;
    assign f2 = (SB)? B1:B0;
    assign s2 = S0|S1;
    assign f=(s2)?f2:f1;
endmodule

"""
        else: 
            modules_content += """
module c2 (input D00 , D01 ,D10 , D11 , A1 , B1 , A0 , B0 , output reg out);
    initial begin 
    $system("c2.exe ");
    end
    wire s0 , s1; 
    assign s1 = A1 | B1 ;
    assign s0 = A0 & B0 ;
    always @(*) begin
    case ({s1, s0})
        2'b00: out = D00;
        2'b01: out = D01;
        2'b10: out = D10;
        2'b11: out = D11;
        default: out = 1'b0;
    endcase
end

endmodule

"""
    else:
        modules_content += """
module FDCP(
input clk , CLR, D, 
output reg Q);

    always @(posedge clk or posedge CLR)
        if(CLR)
        Q <= 0;
        else
        Q <= D;
endmodule

"""
       
        modules_content += """
module s1(input D00 , D01 ,D10 , D11 , A1 , B1 , A0 , clr , clk , output out);
    wire s0 , s1 ,d; 
    assign s1 = A1 | B1 ;
    assign s0 = A0 & clr ;
    assign d= ({s1,s0}== 2'd0)? D00: 
            ({s1,s0}==2'd1)? D01: 
            ({s1,s0}==2'd2)? D10: 
            ({s1,s0}==2'd3)? D11 :
                    2'bz;
    FDCP ff(clk , clr , d, out) ;

endmodule

"""
        
       
        modules_content += """
module s2(input D00 , D01 ,D10 , D11 , A1 , B1 , A0,B0 , clr , clk , output out);
    wire s0 , s1 ,d; 
    assign s1 = A1 | B1 ;
    assign s0 = A0 & B0;
    assign d= ({s1,s0}== 2'd0)? D00: 
            ({s1,s0}==2'd1)? D01: 
            ({s1,s0}==2'd2)? D10: 
            ({s1,s0}==2'd3)? D11 :
                    2'bz;
    FDCP ff (clk , clr , d, out) ;     
endmodule

"""
        
        if cell_type == "c1":
            modules_content += """
module c1(input A0 , A1 , SA , B0 , B1 ,SB , S0 , S1,output f);
    wire f1 , f2 , s2; 
    assign f1 = (SA)? A1:A0;
    assign f2 = (SB)? B1:B0;
    assign s2 = S0|S1;
    assign f=(s2)?f2:f1;
endmodule

"""
        else:  
            modules_content += """
module c2 (input D00 , D01 ,D10 , D11 , A1 , B1 , A0 , B0 , output reg out);
    wire s0 , s1; 
    assign s1 = A1 | B1 ;
    assign s0 = A0 & B0 ;
    always @(*) begin
    case ({s1, s0})
        2'b00: out = D00;
        2'b01: out = D01;
        2'b10: out = D10;
        2'b11: out = D11;
        default: out = 1'b0;
    endcase
end

endmodule

"""
    
    return modules_content

# ---------- main ----------
def main():
    ap = argparse.ArgumentParser(description='Map $lut WIDTH=1/2 to c1/c2 and FFs to s1/s2')
    ap.add_argument('input_file')
    ap.add_argument('--cell', choices=['c1','c2'], default='c2')
    ap.add_argument('--count-cells', action='store_true')
    args = ap.parse_args()

    if not os.path.exists(args.input_file):
        print(f"Error: File {args.input_file} not found"); return
    verilog = open(args.input_file, 'r').read()
    verilog = ensure_escaped_id_terminated(verilog)

    widths = scan_decl_widths(verilog)
    luts = parse_lut_instances(verilog)
    lut1s = [i for i in luts if _width_is_n(i['width'], 1)]
    lut2s = [i for i in luts if _width_is_n(i['width'], 2)]
    print(f"Found {len(lut1s)} LUT1 and {len(lut2s)} LUT2 instances (out of {len(luts)} $lut)")

    new = verilog
    mapped = 0
    mapped_s1 = 0
    mapped_s2 = 0
    
    for lut in lut2s:
        rep = map_lut2_to_cell(lut, args.cell, widths)
        if rep:
            new = new.replace(lut['full_match'], rep, 1)
            mapped += 1
            

    for lut in lut1s:
        rep = map_lut1_to_cell(lut, args.cell, widths)
        if rep:
            new = new.replace(lut['full_match'], rep, 1)
            mapped += 1
            

    
    before = new
    new, mapped_s1, mapped_s2 = map_flipflops(new, mapped_s1, mapped_s2)
    ff_mapped = (before.count("$_SDFFE_PP0P_") - new.count("$_SDFFE_PP0P_")) + \
                (before.count("$_DFF_P_") - new.count("$_DFF_P_"))
    

    print(f"Total number of {args.cell}: {mapped}")
    print(f"Total number of S1: {mapped_s1}")
    print(f"Total number of S2: {mapped_s2}")

 
    out_file = f"mapped_{os.path.basename(args.input_file)}"
    new = ensure_escaped_id_terminated(new)
    with open(out_file, "w") as f:
        f.write(new)
    print(f"Created mapped design: {out_file}")
    
    modules_file = "modules.v"
    modules_content = create_modules_file(args.cell, args.count_cells)
    with open(modules_file, "w") as f:
        f.write(modules_content)
    print(f"Created modules file: {modules_file}")

if __name__ == "__main__":
    main()