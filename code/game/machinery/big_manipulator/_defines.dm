// How should the manipulator interact with the point
#define INTERACT_DROP "DROP"
#define INTERACT_USE "USE"
#define INTERACT_THROW "THROW"

#define MIN_SPEED_MULTIPLIER_TIER_1 0.5
#define MIN_SPEED_MULTIPLIER_TIER_2 0.4
#define MIN_SPEED_MULTIPLIER_TIER_3 0.3
#define MIN_SPEED_MULTIPLIER_TIER_4 0.1

#define MAX_SPEED_MULTIPLIER_TIER_1 2
#define MAX_SPEED_MULTIPLIER_TIER_2 3
#define MAX_SPEED_MULTIPLIER_TIER_3 5
#define MAX_SPEED_MULTIPLIER_TIER_4 6

#define MAX_TASKS_TIER_1 8
#define MAX_TASKS_TIER_2 16
#define MAX_TASKS_TIER_3 32
#define MAX_TASKS_TIER_4 48


#define BASE_POWER_USAGE 0.2
#define BASE_INTERACTION_TIME 0.3 SECONDS
#define BASE_TASK_DELAY 0.3 SECONDS

/// How long will the manipulator wait if there's nothing to do
#define CYCLE_SKIP_TIMEOUT 1 SECONDS

// How should overflow should be handled
#define POINT_OVERFLOW_ALLOWED "ALLOW"
#define POINT_OVERFLOW_FILTERS "TO FILTERS"
#define POINT_OVERFLOW_HELD "TO HELD"
#define POINT_OVERFLOW_FORBIDDEN "FORBID"

#define PICKUP_EAGER "Always Pick Up"
#define PICKUP_CAN_WAIT "Wait For Suiting"

#define TASK_TYPE_PICKUP "pickup"
#define TASK_TYPE_DROP "drop"
#define TASK_TYPE_THROW "throw"
#define TASK_TYPE_USE "use"
#define TASK_TYPE_INTERACT "interact"
#define TASK_TYPE_MOVE "move"
#define TASK_TYPE_WAIT "wait"
#define TASK_TYPE_STOP "stop"

#define TASKING_SEQUENTIAL "Sequential"
#define TASKING_STRICT "Strict order"
