//Events

// Vent Clog Event signals
/// Called when a vent is clogged (spawned_mob, maximum_spawns)
#define COMSIG_VENT_CLOG "clog_vent"
/// Sent to clogged vents to indicate they should produce a mob
#define COMSIG_PRODUCE_MOB "produce_mob"
/// Sent to automatically clear the vent if the scrubber clog event ends on its own
#define COMSIG_VENT_UNCLOG "unclog_vent"
