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

#define MAX_INTERACTION_POINTS_TIER_1 2
#define MAX_INTERACTION_POINTS_TIER_2 3
#define MAX_INTERACTION_POINTS_TIER_3 4
#define MAX_INTERACTION_POINTS_TIER_4 6

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

// The tasking schedules the manipulator uses to iterate through points
#define TASKING_ROUND_ROBIN "Round Robin" // 1 - 2 - 3 - 2 - 3
#define TASKING_STRICT_ROBIN "Strict Robin" // 1 - 2 - 3 - (waiting for 1) - 1 - 2
#define TASKING_PREFER_FIRST "Prefer First" // 1 - 2 - 1 - 2 - 3 - 2 - 1 - 3 (first availiable)

// Defines if this point is a pickup or a dropoff point
#define TRANSFER_TYPE_PICKUP "PICK UP"
#define TRANSFER_TYPE_DROPOFF "DROP OFF"

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
#define IS_STOPPING (current_task == CURRENT_TASK_STOPPING)
#define IS_BUSY (current_task != CURRENT_TASK_NONE)
