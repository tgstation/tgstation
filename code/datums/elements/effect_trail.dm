/*
 * An element used for making a trail of effects appear behind a movable atom when it moves.
 */

/datum/element/effect_trail
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	/// The effect used for the trail generation.
	var/chosen_effect

/datum/element/effect_trail/Attach(datum/target, chosen_effect = /obj/effect/forcefield/cosmic_field)
	. = ..()
	if(!ismovable(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(generate_effect))
	src.chosen_effect = chosen_effect

/datum/element/effect_trail/Detach(datum/target)
	UnregisterSignal(target, COMSIG_MOVABLE_MOVED)
	return ..()

/// Generates an effect
/datum/element/effect_trail/proc/generate_effect(atom/movable/target_object)
	SIGNAL_HANDLER

	var/turf/open/open_turf = get_turf(target_object)
	if(!istype(open_turf))
		return
	new chosen_effect(open_turf)

/// If we are a cosmic heretic, this will return the appropriate effect trail based on our passive level. returns the default trail otherwise
/proc/cosmic_trail_based_on_passive(mob/living/source)
	if(isstargazer(source))
		return /datum/element/effect_trail/cosmic_field/antiprojectile

	var/datum/status_effect/heretic_passive/cosmic/cosmic_passive = source.has_status_effect(/datum/status_effect/heretic_passive/cosmic)
	if(!cosmic_passive)
		return /datum/element/effect_trail/cosmic_field
	if(cosmic_passive.passive_level == 3)
		return /datum/element/effect_trail/cosmic_field/antiprojectile
	if(cosmic_passive.passive_level == 2)
		return /datum/element/effect_trail/cosmic_field/antiexplosion
	return /datum/element/effect_trail

/datum/element/effect_trail/cosmic_field // Cosmic field subtype which applies any upgrades
	var/prevents_explosions = FALSE
	var/slows_projectiles = FALSE

/datum/element/effect_trail/cosmic_field/Attach(datum/target, chosen_effect)
	. = ..()
	if(!ispath(chosen_effect, /obj/effect/forcefield/cosmic_field))
		stack_trace("Tried to attach a cosmic_field effect trail with a non-cosmic field as the chosen effect")

/datum/element/effect_trail/cosmic_field/generate_effect(atom/movable/target_object)
	var/turf/open/open_turf = get_turf(target_object)
	if(!istype(open_turf))
		return
	var/obj/effect/forcefield/cosmic_field/new_field = new chosen_effect(open_turf)

	if(prevents_explosions)
		new_field.prevents_explosions()
	if(slows_projectiles)
		new_field.slows_projectiles()

/datum/element/effect_trail/cosmic_field/antiexplosion
	prevents_explosions = TRUE

/datum/element/effect_trail/cosmic_field/antiprojectile
	prevents_explosions = TRUE
	slows_projectiles = TRUE
