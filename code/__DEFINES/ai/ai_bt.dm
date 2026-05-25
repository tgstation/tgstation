// BT node return values
/// Node completed its goal. Sequence continues; Selector/Parallel stop.
#define BT_SUCCESS 1
/// Node could not act. Selector tries next child; Sequence fails.
#define BT_FAILURE 2
/// Node has an action running. Both composites stop here.
#define BT_RUNNING 3

// Parallel node completion policies (mutually exclusive per axis)
/// Parallel succeeds when child 1 succeeds (default)
#define BT_PARALLEL_SUCCESS_CHILD_ONE 0
/// Parallel succeeds only when all children succeed
#define BT_PARALLEL_SUCCESS_ALL 1
/// Parallel fails when child 1 fails (default)
#define BT_PARALLEL_FAILURE_CHILD_ONE 0
/// Parallel fails when any child fails
#define BT_PARALLEL_FAILURE_ANY 1

// Decorator observer abort modes (UE5 Behavior Tree style)
/// No observer abort registered
#define BT_ABORT_NONE 0
/// Abort this branch when the watched condition becomes FALSE
#define BT_ABORT_SELF (1<<0)
/// Abort lower-priority running behaviors when the watched condition becomes TRUE
#define BT_ABORT_LOWER_PRIORITY (1<<1)
/// Both BT_ABORT_SELF and BT_ABORT_LOWER_PRIORITY
#define BT_ABORT_BOTH (BT_ABORT_SELF | BT_ABORT_LOWER_PRIORITY)

/// Lookup a singleton BT node by typepath from the global registry
#define GET_bt_node(node_type) GLOB.bt_nodes[node_type]

// Per-controller-type execution index caches.
// Keyed by controller type → alist(node → index).
// Built once per type in ensure_execution_index_cache() and used by the observer abort system.
GLOBAL_VAR_INIT(bt_execution_indices, list())
GLOBAL_VAR_INIT(bt_last_execution_indices, list())

// --- Inline descriptor keys (used internally by SSai_controllers descriptor builder) ---
/// Key storing the node typepath in a descriptor list
#define BT_DESC_TYPE "__t"
/// Key storing the children list in a descriptor list
#define BT_DESC_CHILDREN "__c"
