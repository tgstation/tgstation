// Atom explosion signals. Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

///from [/datum/controller/subsystem/explosions/proc/explode]: (/list(/atom, devastation_range, heavy_impact_range, light_impact_range, flame_range, flash_range, adminlog, ignorecap, silent, smoke, explosion_cause))
#define COMSIG_ATOM_EXPLODE "atom_explode"
///from [/datum/controller/subsystem/explosions/proc/explode]: (/list(/atom, devastation_range, heavy_impact_range, light_impact_range, flame_range, flash_range, adminlog, ignorecap, silent, smoke, explosion_cause))
#define COMSIG_ATOM_INTERNAL_EXPLOSION "atom_internal_explosion"
///from [/datum/controller/subsystem/explosions/proc/explode]: (/list(/atom, devastation_range, heavy_impact_range, light_impact_range, flame_range, flash_range, adminlog, ignorecap, silent, smoke, explosion_cause))
#define COMSIG_AREA_INTERNAL_EXPLOSION "area_internal_explosion"
	/// When returned on a signal hooked to [COMSIG_ATOM_EXPLODE], [COMSIG_ATOM_INTERNAL_EXPLOSION], or [COMSIG_AREA_INTERNAL_EXPLOSION] it prevents the explosion from being propagated further.
	#define COMSIG_CANCEL_EXPLOSION (1<<0)

