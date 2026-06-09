/// Maximum number of execution indices the bt_viewer draining log can hold between polls.
#define BT_EXECUTION_LOG_MAX 250

// BT node return values
/// Node completed its goal and succeeded
#define BT_SUCCESS 1
/// Node failed for one reason or the other
#define BT_FAILURE 2
/// Node has an action running;
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

/// Subplan propagates BT_SUCCESS when all children succeed (default)
#define BT_SUBPLAN_SUCCEED_ON_SUCCESS 0
/// Subplan resets and loops (returns BT_RUNNING) when all children succeed
#define BT_SUBPLAN_LOOP_ON_SUCCESS 1
/// Subplan propagates BT_FAILURE when a child fails (default)
#define BT_SUBPLAN_FAIL_ON_FAILURE 0
/// Subplan resets and loops (returns BT_RUNNING) when a child fails
#define BT_SUBPLAN_LOOP_ON_FAILURE 1

/// No observer abort registered
#define BT_ABORT_NONE 0
/// Abort this branch when the watched condition becomes FALSE
#define BT_ABORT_SELF (1<<0)
/// Abort lower-priority running behaviors when the watched condition becomes TRUE
#define BT_ABORT_LOWER_PRIORITY (1<<1)
/// Both BT_ABORT_SELF and BT_ABORT_LOWER_PRIORITY
#define BT_ABORT_BOTH (BT_ABORT_SELF | BT_ABORT_LOWER_PRIORITY)

// BT viewer node type identifiers (stored on bt_node.node_type)
/// Selector composite node
#define BT_NODE_SELECTOR 0
/// Sequence composite node
#define BT_NODE_SEQUENCE 1
/// Parallel composite node
#define BT_NODE_PARALLEL 2
/// Decorator (gate/condition) node
#define BT_NODE_DECORATOR 3
/// Leaf behavior node
#define BT_NODE_LEAF 4
/// Subtree container node
#define BT_NODE_SUBTREE 5
/// Subplan composite node
#define BT_NODE_SUBPLAN 6

// --- Inline descriptor keys (used internally by SSai_controllers descriptor builder) ---
/// Key storing the node typepath in a descriptor list
#define BT_DESC_TYPE "type"
/// Key storing the children list in a descriptor list
#define BT_DESC_CHILDREN "children"
/// Key storing the default behavior args list in a leaf descriptor
#define BT_DESC_BEHAVIOR_ARGS "default_behavior_args"
/// Key storing the override slot ID in a subtree descriptor
#define BT_DESC_OVERRIDE_ID "override_id"
/// Key storing bindable parameter declarations in a compiled subtree descriptor
#define BT_DESC_BINDINGS "__bindings"

/// Resolves the compiled JSON path for a behavior tree by name.
#define BT_COMPILED_PATH(tree_name) ("build/behavior_trees/[tree_name].compiled.json")

// Runtime subtree IDs. Can be used to override trees at runtime

/// pet_command ID to override based on given pet command
#define SUBPLAN_ID_PET_COMMAND "pet_command"
