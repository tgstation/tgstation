/**
 * # Cult halo element
 *
 * Applies and removes the cult halo
 */
/datum/element/cult_halo
	element_flags = ELEMENT_DETACH

/datum/element/cult_halo/Attach(datum/target, initial_delay = 20 SECONDS)
	. = ..()
	if (!isliving(target))
		return ELEMENT_INCOMPATIBLE

	// Register signals for mob transformation to prevent premature halo removal
	RegisterSignal(target, list(COMSIG_CHANGELING_TRANSFORM, COMSIG_MONKEY_HUMANIZE, COMSIG_HUMAN_MONKEYIZE), .proc/set_halo)
	addtimer(CALLBACK(src, .proc/set_halo, target), initial_delay)

/**
 * Halo setter proc
 *
 * Adds the cult halo overlays, and adds the halo trait to the mob.
 */
/datum/element/cult_halo/proc/set_halo(mob/living/target)
	SIGNAL_HANDLER

	ADD_TRAIT(target, TRAIT_CULT_HALO, CULT_TRAIT)
	var/mutable_appearance/new_halo_overlay = mutable_appearance('icons/effects/32x64.dmi', "halo[rand(1, 6)]", -HALO_LAYER)
	if (ishuman(target))
		var/mob/living/carbon/human/human_parent = target
		new /obj/effect/temp_visual/cult/sparks(get_turf(human_parent), human_parent.dir)
		human_parent.overlays_standing[HALO_LAYER] = new_halo_overlay
		human_parent.apply_overlay(HALO_LAYER)
	else
		target.add_overlay(new_halo_overlay)

/**
 * Detach proc
 *
 * Removes the halo overlays, and trait from the mob
 */
/datum/element/cult_halo/Detach(mob/living/target, ...)
	REMOVE_TRAIT(target, TRAIT_CULT_HALO, CULT_TRAIT)
	if (ishuman(target))
		var/mob/living/carbon/human/human_parent = target
		human_parent.remove_overlay(HALO_LAYER)
		human_parent.update_body()
	else
		target.cut_overlay(HALO_LAYER)
	UnregisterSignal(target, list(COMSIG_CHANGELING_TRANSFORM, COMSIG_HUMAN_MONKEYIZE, COMSIG_MONKEY_HUMANIZE))
	. = ..()
