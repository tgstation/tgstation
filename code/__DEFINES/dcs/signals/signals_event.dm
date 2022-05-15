//Events

// Vent Clog Event signals
/// Called when a vent is clogged (spawned_mob, maximum_spawns)
#define COMSIG_VENT_CLOG "clog_vent"
/// Sent to clogged vents to indicate they should produce a mob
#define COMSIG_PRODUCE_MOB "unclog_vent"
