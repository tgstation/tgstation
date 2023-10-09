/**
 * ## death explosion element!
 *
 * Bespoke element that generates an explosion when a mob is killed.
 */
/datum/element/death_explosion
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 3
	///The range at which devastating impact happens
	var/devastation
	///The range at which heavy impact happens
	var/heavy_impact
	///The range at which light impact happens
	var/light_impact

/datum/element/death_explosion/Attach(datum/target, devastation = -1, heavy_impact = -1, light_impact = -1)
	. = ..()
	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE
	src.devastation = devastation
	src.heavy_impact = heavy_impact
	src.light_impact = light_impact
	RegisterSignal(target, COMSIG_LIVING_DEATH, PROC_REF(on_death))

/datum/element/death_explosion/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, COMSIG_LIVING_DEATH)

/// Triggered when target dies, make an explosion.
/datum/element/death_explosion/proc/on_death(mob/living/target, gibbed)
	SIGNAL_HANDLER
	explosion(
		get_turf(target),
		devastation_range = devastation,
		heavy_impact_range = heavy_impact,
		light_impact_range = light_impact,
		explosion_cause = target)
