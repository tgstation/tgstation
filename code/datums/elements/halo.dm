/**
 * # Halo element
 *
 * Applies and removes halos!
 */
/datum/element/halo
	element_flags = ELEMENT_DETACH
	///icon of halo applied
	var/halo_icon = 'icons/effects/halo.dmi'
	///icon_state of halo applied
	var/halo_icon_state
	///what the source of the halo is
	var/trait_source

/datum/element/halo/Attach(datum/target, initial_delay = 20 SECONDS)
	. = ..()
	if (!isliving(target))
		return ELEMENT_INCOMPATIBLE

	// Register signals for mob transformation to prevent premature halo removal
	RegisterSignal(target, list(COMSIG_CHANGELING_TRANSFORM, COMSIG_MONKEY_HUMANIZE, COMSIG_HUMAN_MONKEYIZE), .proc/set_halo)
	if(initial_delay)
		addtimer(CALLBACK(src, .proc/set_halo, target), initial_delay)
	else
		set_halo(target)

/**
 * Halo setter proc
 *
 * Adds the cult halo overlays, and adds the halo trait to the mob.
 */
/datum/element/halo/proc/set_halo(mob/living/target)
	SIGNAL_HANDLER

	ADD_TRAIT(target, TRAIT_HAS_HALO, trait_source)
	var/mutable_appearance/new_halo_overlay = mutable_appearance(halo_icon, halo_icon_state, -HALO_LAYER)
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
/datum/element/halo/Detach(mob/living/target, ...)
	REMOVE_TRAIT(target, TRAIT_HAS_HALO, trait_source)
	if (ishuman(target))
		var/mob/living/carbon/human/human_parent = target
		human_parent.remove_overlay(HALO_LAYER)
		human_parent.update_body()
	else
		target.cut_overlay(HALO_LAYER)
	UnregisterSignal(target, list(COMSIG_CHANGELING_TRANSFORM, COMSIG_HUMAN_MONKEYIZE, COMSIG_MONKEY_HUMANIZE))
	return ..()

/datum/element/halo/cult
	trait_source = CULT_TRAIT

/datum/element/halo/cult/Attach(datum/target)
	. = ..()
	if(. == ELEMENT_INCOMPATIBLE)
		return
	halo_icon_state = "halo[rand(1, 6)]"

/datum/element/halo/holy
	halo_icon_state = "holy_halo"
	trait_source = INNATE_TRAIT
