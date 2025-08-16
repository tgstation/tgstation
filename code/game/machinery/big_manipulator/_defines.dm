#define INTERACT_DROP "drop"
#define INTERACT_USE "use"
#define INTERACT_THROW "throw"

#define TAKE_ITEMS 1
#define TAKE_CLOSETS 2
#define TAKE_HUMANS 3

#define DELAY_STEP 0.1
#define MAX_DELAY 30

#define MIN_ROTATION_MULTIPLIER_TIER_1 0.5
#define MIN_ROTATION_MULTIPLIER_TIER_2 0.4
#define MIN_ROTATION_MULTIPLIER_TIER_3 0.3
#define MIN_ROTATION_MULTIPLIER_TIER_4 0.2

#define MAX_INTERACTION_POINTS_TIER_1 2
#define MAX_INTERACTION_POINTS_TIER_2 4
#define MAX_INTERACTION_POINTS_TIER_3 5
#define MAX_INTERACTION_POINTS_TIER_4 6

#define STATUS_BUSY "busy"
#define STATUS_WAITING "waiting"
#define STATUS_IDLE "idle"

#define WORKER_SINGLE_USE "single"
#define WORKER_EMPTY_USE "empty"
#define WORKER_NORMAL_USE "normal"

#define FILTERS_REQUIRED TRUE
#define FILTERS_SKIPPED FALSE

#define TASKING_ROUND_ROBIN "Round Robin" // 1 - 2 - 3 - 2 - 3
#define TASKING_STRICT_ROBIN "Strict Robin" // 1 - 2 - 3 - (waiting for 1) - 1 - 2
#define TASKING_PREFER_FIRST "Prefer First" // 1 - 2 - 1 - 2 - 3 - 2 - 1 - 3 (first availiable)

#define TRANSFER_TYPE_PICKUP "pick up"
#define TRANSFER_TYPE_DROPOFF "drop off"

#define BASE_POWER_USAGE 0.2
#define BASE_INTERACTION_TIME 0.5 SECONDS

#define STARTING_MULTIPLIER 5
#define MAX_MULTIPLIER 10

#define CYCLE_SKIP_TIMEOUT 1 SECONDS
