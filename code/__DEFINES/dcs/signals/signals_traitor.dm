/// Called whenever the uplink handler receives any sort of update. Used by uplinks to update their UI. No arguments passed
#define COMSIG_UPLINK_HANDLER_ON_UPDATE "uplink_handler_on_update"

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
