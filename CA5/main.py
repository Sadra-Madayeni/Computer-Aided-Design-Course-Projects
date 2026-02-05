import ast
import sys
import json
import os
import math
import datetime
from pathlib import Path
from src.dfg_creator import GraphBuilder, IdentifierNode, OperatorNode, OP_TYPES
from src.graph_visualizer import expression_to_graph, visualize_graph, visualize_scheduled_graph
from src.scheduler import MinLatencyScheduler, MinResourceScheduler, ScheduledNodeInfo

MinResourceAlgorithm = "MinResourceLatencyConstrained"
MinlatencyAlgorithm = "MinLatencyResourceContrained"

def load_input(filename: str) -> dict:
    with open(filename, "r") as file:
        return json.load(file)

def build_dfg(expression: str, folder_path : str):
    ast_root = expression_to_graph(expression)

    dot = visualize_graph(ast_root)
    dot.attr(label="", labelloc='t', fontsize='17')  
    dot.render(folder_path + "/pics/DFG", format='png', view=False, cleanup=True)

    builder = GraphBuilder()
    return builder.build(ast_root)


def schedule_dfg(dfg_root, algorithm : str, config : dict, folder_path : str) -> list:
    if (algorithm == MinResourceAlgorithm):
        scheduler = MinResourceScheduler(dfg_root=dfg_root, numof_resources=config["Resources"], max_time=config["MaxTime"])
    else:
        scheduler = MinLatencyScheduler(dfg_root=dfg_root, numof_resources=config["Resources"])    
    scheduler.schedule()
    schedule_info = scheduler.get_scheduling_info()

    dot = visualize_scheduled_graph(root_id=dfg_root.id, schedule_info=schedule_info)
    dot.attr(label="", labelloc='t', fontsize='17')  
    dot.render(folder_path + "/pics/ScheduledDFG", format='png', view=False, cleanup=True)

    return schedule_info

class VerilogGenerator:
    def __init__(self, folder_path, schedule_info: list[ScheduledNodeInfo]):
        self.folder_path = folder_path
        self.schedule_info = schedule_info
        self.sorted_nodes = sorted(schedule_info, key=lambda x: x.node.id)
        
        self.max_time = 0
        if schedule_info:
            self.max_time = max(node.scheduled_time for node in schedule_info)
            
        self.inputs = self._extract_inputs()
        self.resources = self._extract_resources()
        self.mux_sources = self._create_mux_sources_map()
        
    def _extract_inputs(self):
        inputs = set()
        for item in self.schedule_info:
            for op in item.node.operands:
                if isinstance(op, IdentifierNode):
                    inputs.add(op.name)
        return sorted(list(inputs))

    def _extract_resources(self):
        res_counts = {op: 0 for op in OP_TYPES}
        for item in self.schedule_info:
            res_type = item.node.op_type
            if item.resource_num > res_counts.get(res_type, 0):
                res_counts[res_type] = item.resource_num
        return res_counts

    def _create_mux_sources_map(self):
        sources = []
        for inp in self.inputs:
            sources.append(f"{inp}")
        
        for item in self.sorted_nodes:
            reg_name = f"reg_{item.node.op_type.lower()}{item.node.id}"
            sources.append(reg_name)
            
        return {name: i for i, name in enumerate(sources)}

    def _get_timestamp(self):
        return datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    def generate(self):
        codes_dir = os.path.join(self.folder_path, "codes")
        os.makedirs(codes_dir, exist_ok=True)

        self._write_datapath(os.path.join(codes_dir, "datapath.v"))
        self._write_controller(os.path.join(codes_dir, "controller.v"))
        self._write_top_module(os.path.join(codes_dir, "top_module.v"))

    def _write_datapath(self, filepath):
        lines = []
        lines.append(f"// Generated at: {self._get_timestamp()}")
        lines.append("module datapath(")
        lines.append("  input clk, rst,")
        
        for inp in self.inputs:
            lines.append(f"  input [31:0] {inp},")
            
        mux_bits = math.ceil(math.log2(len(self.mux_sources))) if self.mux_sources else 1
        
        for res_type, count in self.resources.items():
            for i in range(1, count + 1):
                name = f"{res_type.lower()}{i}"
                lines.append(f"  input [{mux_bits-1}:0] {name}_sel1, {name}_sel2,")
                if res_type == "LOG":
                     lines.append(f"  input [1:0] {name}_op,")
                else:
                     lines.append(f"  input {name}_op,")
                     
        lines.append("  input result_en, done_next,")
        for item in self.sorted_nodes:
            lines.append(f"  input reg_{item.node.op_type.lower()}{item.node.id}_en,")
            
        lines.append("  output reg [31:0] result,")
        lines.append("  output reg done")
        lines.append(");")
        
        lines.append("\n  // Intermediate Registers")
        for item in self.sorted_nodes:
            lines.append(f"  reg [31:0] reg_{item.node.op_type.lower()}{item.node.id};")
            
        lines.append("\n  // Functional Units Wires")
        for res_type, count in self.resources.items():
            for i in range(1, count + 1):
                name = f"{res_type.lower()}{i}"
                lines.append(f"  reg [31:0] {name}_op1, {name}_op2;")
                lines.append(f"  reg [31:0] {name}_out;")

        lines.append("\n  // MUX Logic")
        for res_type, count in self.resources.items():
            for i in range(1, count + 1):
                name = f"{res_type.lower()}{i}"
                for op_num in [1, 2]:
                    lines.append(f"  always @(*) begin")
                    lines.append(f"    case ({name}_sel{op_num})")
                    for src_name, idx in self.mux_sources.items():
                        lines.append(f"      {mux_bits}'d{idx}: {name}_op{op_num} = {src_name};")
                    lines.append(f"      default: {name}_op{op_num} = 0;")
                    lines.append(f"    endcase")
                    lines.append(f"  end")

        lines.append("\n  // Functional Units Implementation")
        for res_type, count in self.resources.items():
            for i in range(1, count + 1):
                name = f"{res_type.lower()}{i}"
                lines.append(f"  always @(*) begin")
                if res_type == "ALU":
                    lines.append(f"    case ({name}_op)")
                    lines.append(f"      1'b0: {name}_out = {name}_op1 + {name}_op2; // ADD")
                    lines.append(f"      1'b1: {name}_out = {name}_op1 - {name}_op2; // SUB")
                    lines.append(f"      default: {name}_out = 0;")
                    lines.append(f"    endcase")
                elif res_type == "MUL":
                    lines.append(f"    case ({name}_op)")
                    lines.append(f"      1'b0: {name}_out = {name}_op1 * {name}_op2; // MULT")
                    lines.append(f"      1'b1: {name}_out = {name}_op1 / {name}_op2; // DIV")
                    lines.append(f"      default: {name}_out = 0;")
                    lines.append(f"    endcase")
                elif res_type == "LOG":
                    lines.append(f"    case ({name}_op)")
                    lines.append(f"      2'b00: {name}_out = {name}_op1 & {name}_op2; // AND")
                    lines.append(f"      2'b01: {name}_out = {name}_op1 | {name}_op2; // OR")
                    lines.append(f"      2'b10: {name}_out = {name}_op1 ^ {name}_op2; // XOR")
                    lines.append(f"      default: {name}_out = 0;")
                    lines.append(f"    endcase")
                lines.append(f"  end")

        lines.append("\n  // Registers Update Logic")
        lines.append("  always @(posedge clk or posedge rst) begin")
        lines.append("    if (rst) begin")
        lines.append("      done <= 0;")
        lines.append("      result <= 0;")
        for item in self.sorted_nodes:
             lines.append(f"      reg_{item.node.op_type.lower()}{item.node.id} <= 0;")
        lines.append("    end else begin")
        lines.append("      done <= done_next;")
        
        for item in self.sorted_nodes:
            reg_name = f"reg_{item.node.op_type.lower()}{item.node.id}"
            res_out_wire = f"{item.node.op_type.lower()}{item.resource_num}_out"
            lines.append(f"      if ({reg_name}_en) {reg_name} <= {res_out_wire};")
        
        if self.sorted_nodes:
            last_node = self.sorted_nodes[-1]
            last_reg = f"reg_{last_node.node.op_type.lower()}{last_node.node.id}"
            lines.append(f"      if (result_en) result <= {last_reg};")
        
        lines.append("    end")
        lines.append("  end")
        lines.append("endmodule")

        with open(filepath, "w") as f:
            f.write("\n".join(lines))

    def _write_controller(self, filepath):
        lines = []
        lines.append(f"// Generated at: {self._get_timestamp()}")
        lines.append("module controller(")
        lines.append("  input clk, rst, start,")
        lines.append("  output reg op_ready, done_next, result_en,")
        
        mux_bits = math.ceil(math.log2(len(self.mux_sources))) if self.mux_sources else 1

        for res_type, count in self.resources.items():
            for i in range(1, count + 1):
                name = f"{res_type.lower()}{i}"
                lines.append(f"  output reg [{mux_bits-1}:0] {name}_sel1, {name}_sel2,")
                if res_type == "LOG":
                    lines.append(f"  output reg [1:0] {name}_op,")
                else:
                    lines.append(f"  output reg {name}_op,")
                    
        for item in self.sorted_nodes:
            lines.append(f"  output reg reg_{item.node.op_type.lower()}{item.node.id}_en,")
        
        lines[-1] = lines[-1].strip(",")
        lines.append(");")
        
        lines.append("\n  reg [31:0] state, next_state;")
        lines.append("  localparam S_IDLE = 0, S_DONE = 999;")
        for t in range(1, self.max_time + 1):
            lines.append(f"  localparam S_CYCLE_{t} = {t};")
            
        lines.append("\n  always @(posedge clk or posedge rst) begin")
        lines.append("    if (rst) state <= S_IDLE;")
        lines.append("    else state <= next_state;")
        lines.append("  end")
        
        lines.append("\n  always @(*) begin")
        lines.append("    next_state = state;")
        lines.append("    op_ready = 0; done_next = 0; result_en = 0;")
        
        for res_type, count in self.resources.items():
            for i in range(1, count + 1):
                name = f"{res_type.lower()}{i}"
                lines.append(f"    {name}_sel1 = 0; {name}_sel2 = 0; {name}_op = 0;")
        for item in self.sorted_nodes:
            lines.append(f"    reg_{item.node.op_type.lower()}{item.node.id}_en = 0;")
            
        lines.append("\n    case (state)")
        lines.append("      S_IDLE: begin")
        lines.append("        op_ready = 1;")
        lines.append("        if (start) next_state = S_CYCLE_1;")
        lines.append("      end")
        
        for t in range(1, self.max_time + 1):
            lines.append(f"      S_CYCLE_{t}: begin")
            
            active_nodes = [n for n in self.sorted_nodes if n.scheduled_time == t]
            
            for info in active_nodes:
                res_name = f"{info.node.op_type.lower()}{info.resource_num}"
                reg_en = f"reg_{info.node.op_type.lower()}{info.node.id}_en"
                
                op1 = info.node.operands[0]
                if isinstance(op1, IdentifierNode):
                    src1_key = op1.name
                else:
                    src1_key = f"reg_{op1.op_type.lower()}{op1.id}"
                
                op2 = info.node.operands[1]
                if isinstance(op2, IdentifierNode):
                    src2_key = op2.name
                else:
                    src2_key = f"reg_{op2.op_type.lower()}{op2.id}"
                
                lines.append(f"        {res_name}_sel1 = {mux_bits}'d{self.mux_sources[src1_key]};")
                lines.append(f"        {res_name}_sel2 = {mux_bits}'d{self.mux_sources[src2_key]};")
                lines.append(f"        {reg_en} = 1;")
                
                op_code = "0"
                if isinstance(info.node.op, (ast.Sub, ast.Div, ast.BitOr)):
                    op_code = "1"
                elif isinstance(info.node.op, ast.BitXor):
                    op_code = "2"
                
                if info.node.op_type == "LOG":
                    lines.append(f"        {res_name}_op = 2'd{op_code};")
                else:
                    lines.append(f"        {res_name}_op = 1'b{op_code};")

            if t < self.max_time:
                lines.append(f"        next_state = S_CYCLE_{t+1};")
            else:
                lines.append(f"        result_en = 1;")
                lines.append(f"        next_state = S_DONE;")
            lines.append("      end")

        lines.append("      S_DONE: begin")
        lines.append("        done_next = 1;")
        lines.append("        next_state = S_IDLE;")
        lines.append("      end")
        lines.append("    endcase")
        lines.append("  end")
        lines.append("endmodule")
        
        with open(filepath, "w") as f:
            f.write("\n".join(lines))

    def _write_top_module(self, filepath):
        lines = []
        lines.append(f"// Generated at: {self._get_timestamp()}")
        lines.append("module top_module(")
        lines.append("  input clk, rst, start,")
        for inp in self.inputs:
            lines.append(f"  input [31:0] {inp},")
        lines.append("  output [31:0] result,")
        lines.append("  output done")
        lines.append(");")
        
        mux_bits = math.ceil(math.log2(len(self.mux_sources))) if self.mux_sources else 1
        
        lines.append("\n  wire op_ready, done_next, result_en;")
        
        for res_type, count in self.resources.items():
            for i in range(1, count + 1):
                name = f"{res_type.lower()}{i}"
                lines.append(f"  wire [{mux_bits-1}:0] {name}_sel1, {name}_sel2;")
                if res_type == "LOG":
                    lines.append(f"  wire [1:0] {name}_op;")
                else:
                    lines.append(f"  wire {name}_op;")
                    
        for item in self.sorted_nodes:
            lines.append(f"  wire reg_{item.node.op_type.lower()}{item.node.id}_en;")
            
        lines.append("\n  controller ctrl_inst (")
        lines.append("    .clk(clk), .rst(rst), .start(start),")
        lines.append("    .op_ready(op_ready), .done_next(done_next), .result_en(result_en),")
        for res_type, count in self.resources.items():
            for i in range(1, count + 1):
                name = f"{res_type.lower()}{i}"
                lines.append(f"    .{name}_sel1({name}_sel1), .{name}_sel2({name}_sel2), .{name}_op({name}_op),")
        
        for item in self.sorted_nodes:
            reg_name = f"reg_{item.node.op_type.lower()}{item.node.id}_en"
            lines.append(f"    .{reg_name}({reg_name}),")
            
        lines[-1] = lines[-1].strip(",")
        lines.append("  );")
        
        lines.append("\n  datapath dp_inst (")
        lines.append("    .clk(clk), .rst(rst),")
        for inp in self.inputs:
            lines.append(f"    .{inp}({inp}),")
        lines.append("    .done_next(done_next), .result_en(result_en), .result(result), .done(done),")
        
        for res_type, count in self.resources.items():
            for i in range(1, count + 1):
                name = f"{res_type.lower()}{i}"
                lines.append(f"    .{name}_sel1({name}_sel1), .{name}_sel2({name}_sel2), .{name}_op({name}_op),")
        
        for item in self.sorted_nodes:
            reg_name = f"reg_{item.node.op_type.lower()}{item.node.id}_en"
            lines.append(f"    .{reg_name}({reg_name}),")
            
        lines[-1] = lines[-1].strip(",")
        lines.append("  );")
        
        lines.append("endmodule")
        
        with open(filepath, "w") as f:
            f.write("\n".join(lines))

def generate_verilog(folder_path : str, schedule_info : list[ScheduledNodeInfo]):
    generator = VerilogGenerator(folder_path, schedule_info)
    generator.generate()
    print("codes generated.")

def save_result(folder_path : str, schedule_info : list[ScheduledNodeInfo]):
    json_output = {}
    with open(folder_path + "/output.json", "w") as file:
        for node_info in schedule_info:
            json_output[node_info.node.id] = {
                "clk": node_info.scheduled_time,
                "resource_type": node_info.node.op_type,
                "resource_num": node_info.resource_num
            }
        json.dump(json_output, file, indent=4)


def run_test(folder_path : str):
    input_file_path = folder_path + "/input.json"
    data = load_input(input_file_path)

    dfg_root = build_dfg(expression=data["Expression"], folder_path=folder_path)

    schedule_info = schedule_dfg(dfg_root, algorithm=data["Algorithm"], config=data["Config"], folder_path=folder_path)

    save_result(folder_path=folder_path, schedule_info=schedule_info)

    generate_verilog(folder_path=folder_path, schedule_info=schedule_info)

def main():
    if len(sys.argv) > 1:
        run_test(folder_path=sys.argv[1])
    else:
        print("Please provide the input folder path.")

if __name__ == "__main__":
    main()