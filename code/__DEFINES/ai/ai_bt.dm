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

// --- Inline tree descriptor macros ---
// DM variadic syntax: param... / ##param
/// Inline selector (priority fallback): tries each child left-to-right, returns first non-FAILURE.
#define BT_SELECTOR(children...) list(BT_DESC_TYPE = /datum/bt_node/composite/selector, BT_DESC_CHILDREN = list(##children))
/// Inline sequence: runs each child left-to-right, fails on first FAILURE.
#define BT_SEQUENCE(children...) list(BT_DESC_TYPE = /datum/bt_node/composite/sequence, BT_DESC_CHILDREN = list(##children))
/// Inline parallel. fail_policy: BT_PARALLEL_FAILURE_CHILD_ONE or BT_PARALLEL_FAILURE_ANY.
/// success_policy: BT_PARALLEL_SUCCESS_CHILD_ONE or BT_PARALLEL_SUCCESS_ALL.
/// repeat_secondary: if TRUE, children 2+ reset and retick on completion instead of counting toward tallies.
/// finish_on_primary: if TRUE, cancels children 2+ when child 1 finishes.
#define BT_PARALLEL(fail_policy, success_policy, repeat_secondary, finish_on_primary, children...) list(BT_DESC_TYPE = /datum/bt_node/composite/parallel, "failure_policy" = (fail_policy), "success_policy" = (success_policy), "repeat_secondary" = (repeat_secondary), "finish_on_primary" = (finish_on_primary), BT_DESC_CHILDREN = list(##children))
/// Behavior leaf node. Positional args become default_behavior_args passed to queue_behavior().
#define BT_LEAF(behavior_type, args...) list(BT_DESC_TYPE = (behavior_type), "default_behavior_args" = list(##args))
/// Subtree reference — a modular section of behavior nodes housed in a /datum/bt_node/subtree subtype.
/// Expands to a plain typepath; the descriptor builder resolves it to the singleton at runtime.
#define BT_SUBTREE(subtype) (subtype)
/// Any decorator node. child is the single guarded child descriptor or typepath. Trailing key=value pairs are var assignments on the node.
#define BT_DECORATOR(type, child, config...) list(BT_DESC_TYPE = (type), BT_DESC_CHILDREN = list(child), ##config)
