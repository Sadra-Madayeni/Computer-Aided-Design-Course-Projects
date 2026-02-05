from abc import ABC, abstractmethod
from .dfg_creator import BaseNode, OperatorNode, OP_TYPES, IdentifierNode
from typing import List

class ScheduledNodeInfo:
    def __init__(self, node : OperatorNode, scheduled_time : int, resource_num : int):
        self.node = node
        self.scheduled_time = scheduled_time
        self.resource_num = resource_num


class ListScheduler(ABC):
    def __init__(self, dfg_root : BaseNode, numof_reources : dict):
        self.root = dfg_root
        if numof_reources is None:
            self.numof_resources = {op: 1 for op in OP_TYPES}
        else:
            self.numof_resources = numof_reources

        self.scheduled_nodes_info : List[ScheduledNodeInfo] = []
        self.all_nodes = []
        self._collect_nodes(self.root)
        self.scheduled_ids = set()
        
    '''
        For a node, records its execution cycle and index of the resource to be executed on.
    '''

    def _collect_nodes(self, node):

        if node is None:
            return
        
        if isinstance(node, OperatorNode) and node not in self.all_nodes:
            self.all_nodes.append(node)
        
        children = getattr(node, 'operands', [])
        for operand in children:
            if isinstance(operand, OperatorNode):
                self._collect_nodes(operand)

    def is_ready(self, node: OperatorNode) -> bool:
        for operand in node.operands:
            if isinstance(operand, OperatorNode):
                if operand.id not in self.scheduled_ids:
                    return False
        return True

    def record_scheduled_node(self, node : OperatorNode, scheduled_time : int, resource_num : int):
        recorded_info = ScheduledNodeInfo(node=node, scheduled_time=scheduled_time, resource_num=resource_num)
        self.scheduled_nodes_info.append(recorded_info)
        self.scheduled_ids.add(node.id)
        
        
    '''
        Returns the list of all ScheduledNodeInfos sorted by their node id.
    '''    

    def get_scheduling_info(self) -> List[ScheduledNodeInfo]:
        return sorted(self.scheduled_nodes_info, key = lambda node_info: node_info.node.id)

  
    '''
        Returns a list of nodes that are ready to execute at the time.
        Operands of these nodes are either an IdentifierNode or the result of an already executed OperatorNode.
    '''

    def reset_state(self):
        self.scheduled_nodes_info = []
        self.scheduled_ids = set()

    @abstractmethod
    def find_candidate_nodes(self) -> List[OperatorNode]:
        pass
    
    
    '''
        Based on the algorithm, it selects nodes from frontier to be executed on the currently available resources.
        Frontier is the output of find_candidate_nodes.
    '''

    @abstractmethod
    def select_from_frontier(self, frontier : dict) -> List[OperatorNode]:
        pass
    
    
    '''
        Performes the process of scheduling.
        It repeatedly selects some nodes from frontier to be executed at the time and records their scheduling information until there are no more nodes. 
    '''

    @abstractmethod
    def schedule(self) -> None:
        pass


class MinLatencyScheduler(ListScheduler):
    def __init__(self, dfg_root : BaseNode, numof_resources : dict):
        super().__init__(dfg_root=dfg_root, numof_reources=numof_resources)

    def find_candidate_nodes(self) -> List[OperatorNode]:
        candidates = []
        for node in self.all_nodes:
            if node.id not in self.scheduled_ids:
                if self.is_ready(node):
                    candidates.append(node)
        return sorted(candidates, key=lambda x: x.id)

    def select_from_frontier(self, frontier : List[OperatorNode]) -> List[OperatorNode]:
        selected = []
        current_resources = self.numof_resources.copy()
        
        for node in frontier:
            if current_resources.get(node.op_type, 0) > 0:
                selected.append(node)
                current_resources[node.op_type] -= 1
        
        return selected

    def schedule(self) -> None:
        current_step = 1
        while len(self.scheduled_ids) < len(self.all_nodes):
            candidates = self.find_candidate_nodes()
            if not candidates:
                break
            
            selected_nodes = self.select_from_frontier(candidates)
            
            type_usage_counter = {op: 0 for op in OP_TYPES}
            
            for node in selected_nodes:
                type_usage_counter[node.op_type] += 1
                self.record_scheduled_node(node, current_step, type_usage_counter[node.op_type])
            
            current_step += 1


class MinResourceScheduler(ListScheduler):
    def __init__(self, dfg_root : BaseNode, numof_resources : dict, max_time : int):
        super().__init__(dfg_root=dfg_root, numof_reources=None)
        self.max_time = max_time
        self.latest_time = self.find_latest_times()

    def find_latest_times(self) -> dict:
        times = {node.id: float('inf') for node in self.all_nodes}
        
        def set_alap(node, time):
            if not isinstance(node, OperatorNode):
                return
            
            if time < times.get(node.id, float('inf')):
                times[node.id] = time
                for operand in node.operands:
                    set_alap(operand, time - 1)

        set_alap(self.root, self.max_time)
        return times
    
    def find_candidate_nodes(self) -> List[OperatorNode]:
        candidates = []
        for node in self.all_nodes:
            if node.id not in self.scheduled_ids:
                if self.is_ready(node):
                    candidates.append(node)
        
        return sorted(candidates, key=lambda x: self.latest_time.get(x.id, float('inf')))

    def select_from_frontier(self, frontier : List[OperatorNode]) -> List[OperatorNode]:
        selected = []
        current_resources = self.numof_resources.copy()
        
        for node in frontier:
            if current_resources.get(node.op_type, 0) > 0:
                selected.append(node)
                current_resources[node.op_type] -= 1
        
        return selected

    def schedule(self) -> None:
        required_ops = set(node.op_type for node in self.all_nodes)
        test_resources = {op: 1 for op in OP_TYPES}
        
        while True:
            self.numof_resources = test_resources.copy()
            self.reset_state()
            
            current_step = 1
            max_scheduled_cycle = 0
            
            while len(self.scheduled_ids) < len(self.all_nodes):
                candidates = self.find_candidate_nodes()
                
                if not candidates: 
                    break 

                selected_nodes = self.select_from_frontier(candidates)            
                type_usage_counter = {op: 0 for op in OP_TYPES}
                
                if not selected_nodes:
                     pass
                else:
                    for node in selected_nodes:
                        type_usage_counter[node.op_type] += 1
                        self.record_scheduled_node(node, current_step, type_usage_counter[node.op_type])
                
                current_step += 1
    
                if current_step > self.max_time + 5:
                    break
            
            if self.scheduled_nodes_info:
                max_scheduled_cycle = max(info.scheduled_time for info in self.scheduled_nodes_info)
            else:
                max_scheduled_cycle = float('inf')

            if len(self.scheduled_ids) == len(self.all_nodes) and max_scheduled_cycle <= self.max_time:
                break
            else:
                changed = False
                for op in required_ops:
                    if test_resources[op] < 20:
                        test_resources[op] += 1
                        changed = True
                
                if not changed:
                    print("Error: could not schedule with resources.")
                    break