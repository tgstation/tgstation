export type BehaviorTreeViewerData = {
  mob_name: string | null;
  controller_type: string | null;
  active_execution_index: number;
  awaiting_pick: boolean;
  roots: BtNodeData[];
};

export type BtNodeData = {
  label: string;
  full_type: string;
  node_type: 'selector' | 'sequence' | 'parallel' | 'decorator' | 'leaf' | 'subtree';
  priority_index: number;
  execution_index: number;
  last_execution_index: number;
  observer_abort: 0 | 1 | 2 | 3;
  observed_keys: string[];
  invert: boolean;
  children: BtNodeData[];
};

export const BT_ABORT_NONE = 0;
export const BT_ABORT_SELF = 1;
export const BT_ABORT_LOWER_PRIORITY = 2;
export const BT_ABORT_BOTH = 3;
