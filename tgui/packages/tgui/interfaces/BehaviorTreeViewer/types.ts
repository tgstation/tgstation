export type BehaviorTreeViewerData = {
  mob_name: string | null;
  controller_type: string | null;
  active_execution_index: number;
  awaiting_pick: boolean;
  roots: number[]; // execution indices of root nodes
  nodes: BtNodeData[]; // flat list of all nodes in the tree
};

// t: 0=selector 1=sequence 2=parallel 3=decorator 4=leaf 5=subtree 6=subplan
export const BT_NODE_SELECTOR = 0;
export const BT_NODE_SEQUENCE = 1;
export const BT_NODE_PARALLEL = 2;
export const BT_NODE_DECORATOR = 3;
export const BT_NODE_LEAF = 4;
export const BT_NODE_SUBTREE = 5;
export const BT_NODE_SUBPLAN = 6;

export type BtNodeData = {
  e: number; // execution index (unique key)
  l: string; // label
  t: number; // node type (BT_NODE_* constants)
  p: number; // priority index
  z?: number; // last execution index — omitted when same as e
  c?: number[]; // child execution indices — omitted when no children
  a?: 0 | 1 | 2 | 3; // observer_abort — only on observing decorators
  k?: string[]; // observed_keys — only when non-empty
  i?: boolean; // invert — only when true
};

export const BT_ABORT_NONE = 0;
export const BT_ABORT_SELF = 1;
export const BT_ABORT_LOWER_PRIORITY = 2;
export const BT_ABORT_BOTH = 3;
