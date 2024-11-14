/// Called when the hack_comm_console objective is completed.
#define COMSIG_GLOB_TRAITOR_OBJECTIVE_COMPLETED "!traitor_objective_completed"

/// Called whenever the uplink handler receives any sort of update. Used by uplinks to update their UI. No arguments passed
#define COMSIG_UPLINK_HANDLER_ON_UPDATE "uplink_handler_on_update"
/// Sent from the uplink handler when the traitor uses the syndicate uplink beacon to order a replacement uplink.
#define COMSIG_UPLINK_HANDLER_REPLACEMENT_ORDERED "uplink_handler_replacement_ordered"

/// Called before the traitor objective is generated
#define COMSIG_TRAITOR_OBJECTIVE_PRE_GENERATE "traitor_objective_pre_generate"
	#define COMPONENT_TRAITOR_OBJECTIVE_ABORT_GENERATION (1<<0)
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

/// Called when a machine a traitor has booby trapped triggers its payload
#define COMSIG_TRAITOR_MACHINE_TRAP_TRIGGERED "traitor_machine_trap_triggered"

/// Called when a device a traitor has planted effects someone's mood. Pass the mind of the viewer.
#define COMSIG_DEMORALISING_EVENT "traitor_demoralise_event"
/// Called when you finish drawing some graffiti so we can register more signals on it. Pass the graffiti effect.
#define COMSIG_TRAITOR_GRAFFITI_DRAWN "traitor_rune_drawn"
/// Called when someone slips on some seditious graffiti. Pass the mind of the viewer.
#define COMSIG_TRAITOR_GRAFFITI_SLIPPED "traitor_demoralise_event"
/// For when someone is injected with the EHMS virus from /datum/traitor_objective_category/infect
#define COMSIG_EHMS_INJECTOR_INJECTED "after_ehms_inject"

/// Called by an battle royale implanter when successfully implanting someone. Passes the implanted mob.
#define COMSIG_ROYALE_IMPLANTED "royale_implanted"
