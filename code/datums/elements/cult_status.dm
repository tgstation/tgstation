//TODO: ALL THATS LEFT:
// send a list in check_size or wherever it calls the signal of all thecultists
//
// clean the code up
// finish and redo all the autodoc comments


/**
 * # Cult Status element
 *
 * Element used to manage and display the visual cult effects.
 *
 * Used to apply and remove the traits, and overlays associated with the growing size of a cult.
 */
/datum/element/cult_status

/**
 * Check if the cultist needs to have their
 */
/datum/element/cult_status/Attach(datum/parent)
	. = ..()
	if (!isliving(parent))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_MOB_TRANSFORMING, .proc/handle_transform)
	RegisterSignal(parent, COMSIG_CULT_STATUS_CHANGED, .proc/raise_level)

	var/status = CULT_STATUS_NORMAL
	var/mob/living/mob = parent
	for (var/datum/antagonist/cult/player_datum in mob.mind.antag_datums)
		if (player_datum.cult_team.cult_ascendent)
			status = CULT_STATUS_ASCENDED
		else if (player_datum.cult_team.cult_risen)
			status = CULT_STATUS_RISEN

	// Do a shortened version of raise_level() here, since we don't need all the flavour text
	switch(status)
		if (CULT_STATUS_RISEN)
			set_eyes(parent)
		if (CULT_STATUS_ASCENDED)
			set_eyes(parent)
			set_halo(parent)

/**
 * Removes all the effects applied when removing the component.
 */
/datum/element/cult_status/Detach(datum/parent, ...)
	. = ..()
	var/mob/living/parent_mob = parent
	if (HAS_TRAIT(parent_mob, TRAIT_UNNATURAL_RED_GLOWY_EYES))
		REMOVE_TRAIT(parent_mob, TRAIT_UNNATURAL_RED_GLOWY_EYES, CULT_TRAIT)
		if (ishuman(parent_mob))
			var/mob/living/carbon/human/human_parent = parent_mob
			human_parent.eye_color = initial(human_parent.eye_color)
			human_parent.dna.update_ui_block(DNA_EYE_COLOR_BLOCK)
	if (HAS_TRAIT(parent_mob, TRAIT_CULT_HALO))
		REMOVE_TRAIT(parent_mob, TRAIT_CULT_HALO, CULT_TRAIT)
		if (ishuman(parent_mob))
			var/mob/living/carbon/human/human_parent = parent_mob
			human_parent.remove_overlay(HALO_LAYER)
			human_parent.update_body()
		else
			parent_mob.cut_overlay(HALO_LAYER)
	UnregisterSignal(parent, COMSIG_MOB_TRANSFORMING)
	UnregisterSignal(parent, COMSIG_CULT_STATUS_CHANGED)

/**
 * Raise the current visibility level of the cultist.
 *
 * Checks the current stage, raises it if a specific level is not applied.
 * Supplies the flavour text, and the sounds, then calls the procs associated with each stage.
 * Arguments: (re turn true if raised)
 * * _stage - (Optional) Specify the cult visibility stage to raise to.
 */
/datum/element/cult_status/proc/raise_level(datum/target, status, list/to_raise)
	for (var/datum/mind/parent_mind in to_raise)
		var/mob/living/parent = parent_mind.current
		switch(status)
			if (CULT_STATUS_RISEN)
				SEND_SOUND(parent, 'sound/hallucinations/i_see_you2.ogg')
				to_chat(parent, span_cultlarge(span_warning("The veil weakens as your cult grows, your eyes begin to glow...")))
				addtimer(CALLBACK(src, .proc/set_eyes, parent), 20 SECONDS)
			if (CULT_STATUS_ASCENDED)
				SEND_SOUND(parent, 'sound/hallucinations/im_here1.ogg')
				to_chat(parent, span_cultlarge(span_warning("Your cult is ascendent and the red harvest approaches - you cannot hide your true nature for much longer!!")))
				addtimer(CALLBACK(src, .proc/set_halo, parent), 20 SECONDS)

/**
 * Set the eyes of the cultist to begin glowing.
 *
 * Humans will have their eye colour changed, while any other mob will just have "glowing eyes".
 */
/datum/element/cult_status/proc/set_eyes(datum/parent, override = FALSE)
	var/mob/living/parent_mob = parent
	if (HAS_TRAIT(parent_mob, TRAIT_UNNATURAL_RED_GLOWY_EYES) && !override)
		return
	ADD_TRAIT(parent_mob, TRAIT_UNNATURAL_RED_GLOWY_EYES, CULT_TRAIT)
	if (ishuman(parent_mob))
		var/mob/living/carbon/human/human_parent = parent_mob
		human_parent.eye_color = BLOODCULT_EYE
		human_parent.dna.update_ui_block(DNA_EYE_COLOR_BLOCK)
		human_parent.update_body()

/**
 * Apply a floating halo above the cultist.
 */
/datum/element/cult_status/proc/set_halo(datum/parent, override = FALSE)
	var/mob/living/parent_mob = parent
	if (HAS_TRAIT(parent_mob, TRAIT_CULT_HALO) && !override)
		return
	ADD_TRAIT(parent_mob, TRAIT_CULT_HALO, CULT_TRAIT)
	var/icon_state = pick ("halo1", "halo2", "halo3", "halo4", "halo5", "halo6")
	var/mutable_appearance/new_halo_overlay = mutable_appearance('icons/effects/32x64.dmi', icon_state, -HALO_LAYER)
	if (ishuman(parent))
		var/mob/living/carbon/human/human_parent = parent_mob
		new /obj/effect/temp_visual/cult/sparks(get_turf(human_parent), human_parent.dir)
		human_parent.overlays_standing[HALO_LAYER] = new_halo_overlay
		human_parent.apply_overlay(HALO_LAYER)
	else
		parent_mob.add_overlay(new_halo_overlay)

/**
 * Handle mob transformation.
 *
 * Prevents deleting the given traits by transforming into a different mob.
 */
/datum/element/cult_status/proc/handle_transform(datum/parent)
	if (HAS_TRAIT(parent, TRAIT_UNNATURAL_RED_GLOWY_EYES))
		set_eyes(parent, override = TRUE)
	if (HAS_TRAIT(parent, TRAIT_CULT_HALO))
		set_halo(parent, override = TRUE)
