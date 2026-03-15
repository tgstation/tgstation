// How should the manipulator interact with the point
#define INTERACT_DROP "DROP"
#define INTERACT_USE "USE"
#define INTERACT_THROW "THROW"

// What should be picked up from the point
#define TAKE_ITEMS 1
#define TAKE_CLOSETS 2
#define TAKE_HUMANS 3

#define MIN_SPEED_MULTIPLIER_TIER_1 0.5
#define MIN_SPEED_MULTIPLIER_TIER_2 0.4
#define MIN_SPEED_MULTIPLIER_TIER_3 0.3
#define MIN_SPEED_MULTIPLIER_TIER_4 0.1

#define MAX_SPEED_MULTIPLIER_TIER_1 2
#define MAX_SPEED_MULTIPLIER_TIER_2 3
#define MAX_SPEED_MULTIPLIER_TIER_3 5
#define MAX_SPEED_MULTIPLIER_TIER_4 6

#define MAX_TASKS_TIER_1 6
#define MAX_TASKS_TIER_2 12
#define MAX_TASKS_TIER_3 24
#define MAX_TASKS_TIER_4 32

#define CURRENT_TASK_NONE "NO TASK" // manipulator is off
#define CURRENT_TASK_IDLE "IDLE" // manipulator is skipping a cycle because it has nothing to do
#define CURRENT_TASK_MOVING_PICKUP "MOVING TO PICKUP POINT"
#define CURRENT_TASK_MOVING_DROPOFF "MOVING TO DROPOFF POINT"
#define CURRENT_TASK_INTERACTING "INTERACTING"
#define CURRENT_TASK_STOPPING "STOPPING"

// How should the worker interact with the point
#define WORKER_SINGLE_USE "SINGLE TIME"
#define WORKER_EMPTY_USE "EMPTY HAND"
#define WORKER_NORMAL_USE "NORMAL"

#define BASE_POWER_USAGE 0.2
#define BASE_INTERACTION_TIME 0.3 SECONDS

/// How long will the manipulator wait if there's nothing to do
#define CYCLE_SKIP_TIMEOUT 1 SECONDS

// How should overflow should be handled
#define POINT_OVERFLOW_ALLOWED "ALLOW"
#define POINT_OVERFLOW_FILTERS "TO FILTERS"
#define POINT_OVERFLOW_HELD "TO HELD"
#define POINT_OVERFLOW_FORBIDDEN "FORBID"

// What should the manipulator do after there's nothing else to interact with on this point anymore
#define POST_INTERACTION_DROP_AT_POINT "AT DROPOFF"
#define POST_INTERACTION_DROP_AT_MACHINE "AT MACHINE"
#define POST_INTERACTION_DROP_NEXT_FITTING "AT ANY FITTING"
#define POST_INTERACTION_WAIT "CONTINUE"

// Some macros for interaction checks
#define IS_STOPPING (current_task_state == CURRENT_TASK_STOPPING)
#define IS_BUSY (current_task_state != CURRENT_TASK_NONE)

#define PICKUP_EAGER "Always Pick Up"
#define PICKUP_CAN_WAIT "Wait For Suiting"

#define TASK_TYPE_PICKUP "pickup"
#define TASK_TYPE_DROP "drop"
#define TASK_TYPE_THROW "throw"
#define TASK_TYPE_USE "use"
#define TASK_TYPE_INTERACT "interact"
#define TASK_TYPE_WAIT "wait"
#define TASK_TYPE_SIGNAL "signal"

#define TASKING_SEQUENTIAL "Sequential"
#define TASKING_STRICT "Strict order"
