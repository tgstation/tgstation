/// Called when the hack_comm_console objective is completed.
#define COMSIG_GLOB_TRAITOR_OBJECTIVE_COMPLETED "!traitor_objective_completed"

/// Called whenever the uplink handler receives any sort of update. Used by uplinks to update their UI. No arguments passed
#define COMSIG_UPLINK_HANDLER_ON_UPDATE "uplink_handler_on_update"

/// Called whenever the traitor objective is completed
#define COMSIG_TRAITOR_OBJECTIVE_COMPLETED "traitor_objective_completed"
/// Called whenever the traitor objective is failed
#define COMSIG_TRAITOR_OBJECTIVE_FAILED "traitor_objective_failed"

/// Called when a traitor bug is planted in an area
#define COMSIG_TRAITOR_BUG_PLANTED_GROUND "traitor_bug_planted_area"
/// Called when a traitor bug is planted
#define COMSIG_TRAITOR_BUG_PLANTED_OBJECT "traitor_bug_planted_object"
/// Called before a traitor bug is planted, where it can still be overrided
#define COMSIG_TRAITOR_BUG_PRE_PLANTED_OBJECT "traitor_bug_planted_pre_object"
	#define COMPONENT_FORCE_PLACEMENT (1<<0)
	#define COMPONENT_FORCE_FAIL_PLACEMENT (1<<1)
