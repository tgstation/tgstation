/**
 * # Cult Status element
 *
 * Element used to manage and display the visual cult effects.
 *
 * Used to apply and remove the traits, and overlays associated with the growing size of a cult.
 *
 */
/datum/element/cult_status

/**
 * Attach proc.
 *
 * If the parent is a mob, setup the cult visibility.
 *
 */
/datum/element/cult_status/Attach(datum/parent)
	. = ..()
	if (istype(parent, /datum/team/cult))
		RegisterSignal(parent, COMSIG_CULT_STATUS_CHANGED, .proc/raise_level)
		return .
	else if (isliving(parent))
		RegisterSignal(parent, COMSIG_MOB_TRANSFORMING, .proc/handle_transform)
	else
		return ELEMENT_INCOMPATIBLE

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
	if (isliving(parent))
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
	else
		UnregisterSignal(parent, COMSIG_CULT_STATUS_CHANGED)

/**
 * Raise the current visibility level of the cult team.
 *
 * Updates all cultist's to the new visibility stage, with the given status.
 * Supplies the flavour text, and the sounds, then calls the procs associated with each stage.
 * Arguments:
 * * status - Specify the cult visibility stage to raise to.
 */
/datum/element/cult_status/proc/raise_level(datum/parent, status)
	var/datum/team/cult/parent_team = parent
	for (var/datum/mind/parent_mind in parent_team.members)
		var/mob/living/parent_mob = parent_mind.current
		switch(status)
			if (CULT_STATUS_RISEN)
				SEND_SOUND(parent_mob, 'sound/hallucinations/i_see_you2.ogg')
				to_chat(parent_mob, span_cultlarge(span_warning("The veil weakens as your cult grows, your eyes begin to glow...")))
				addtimer(CALLBACK(src, .proc/set_eyes, parent_mob), 20 SECONDS)
			if (CULT_STATUS_ASCENDED)
				SEND_SOUND(parent_mob, 'sound/hallucinations/im_here1.ogg')
				to_chat(parent_mob, span_cultlarge(span_warning("Your cult is ascendent and the red harvest approaches - you cannot hide your true nature for much longer!!")))
				addtimer(CALLBACK(src, .proc/set_halo, parent_mob), 20 SECONDS)

/**
 * Set the eyes of the cultist to begin glowing.
 *
 * Humans will have their eye colour changed, while any other mob will just have "glowing eyes".
 * Arguments:
 * * override - Override the check to see if the mob already has the glowing eye trait.
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
 * Arguments:
 * * override - Override the check to see if the mob already has the halo trait.
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
 *
 */
/datum/element/cult_status/proc/handle_transform(datum/parent)
	if (HAS_TRAIT(parent, TRAIT_UNNATURAL_RED_GLOWY_EYES))
		set_eyes(parent, override = TRUE)
	if (HAS_TRAIT(parent, TRAIT_CULT_HALO))
		set_halo(parent, override = TRUE)
