export type BlackboardEntry = {
  key: string; // BB_* constant name
  value: string; // stringified value
};

export type BehaviorTreeViewerData = {
  mob_name: string | null;
  controller_type: string | null;
  active_execution_index: number;
  fired_indices: number[]; // all leaf execution indices that fired since last poll
  awaiting_pick: boolean;
  roots: number[]; // execution indices of root nodes
  nodes: BtNodeData[]; // flat list of all nodes in the tree
  blackboard: BlackboardEntry[];
};

// node_type: 0=selector 1=sequence 2=parallel 3=decorator 4=leaf 5=subtree 6=subplan
export const BT_NODE_SELECTOR = 0;
export const BT_NODE_SEQUENCE = 1;
export const BT_NODE_PARALLEL = 2;
export const BT_NODE_DECORATOR = 3;
export const BT_NODE_LEAF = 4;
export const BT_NODE_SUBTREE = 5;
export const BT_NODE_SUBPLAN = 6;

export type BtNodeData = {
  exec_index: number; // unique key for this node instance
  label: string; // display label
  node_type: number; // BT_NODE_* constant
  priority: number; // sibling priority (1-based)
  last_exec_index?: number; // last execution index in subtree — omitted when same as exec_index
  children?: number[]; // child exec_indices — omitted when no children
  observer_abort?: 0 | 1 | 2 | 3; // abort scope — only on observing decorators
  observed_keys?: string[]; // watched blackboard keys — only when non-empty
  invert?: boolean; // condition is inverted — only when true
};

export const BT_ABORT_NONE = 0;
export const BT_ABORT_SELF = 1;
export const BT_ABORT_LOWER_PRIORITY = 2;
export const BT_ABORT_BOTH = 3;
