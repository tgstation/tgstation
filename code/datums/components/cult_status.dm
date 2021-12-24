/**
 * # Cult Status component
 *
 * Component used to track and display the visual cult effects.
 *
 * Used to apply and remove the traits, and overlays associated with the growing size of a cult.
 */
/datum/component/cult_status
	///Which stage of visibilty is the cultist at?
	var/stage = STAGE_CULT_UNSEEN
	///Have the eyes started glowing?
	var/glowing_eyes = FALSE
	///Has the halo been added?
	var/has_halo = FALSE

/**
 * Check if the cultist needs to have their
 */
/datum/component/cult_status/Initialize()
	RegisterSignal(parent, COMSIG_CULT_VIS, .proc/raise_level)
	RegisterSignal(parent, COMSIG_ANTAGONIST_REMOVED, .proc/UnregisterFromParent)
	RegisterSignal(parent, COMSIG_MOB_TRANSFORMING, .proc/handle_transform)

	var/datum/team/cult/parent_team
	for (var/datum/antagonist/cult/cult_datum in parent.mind.antag_datums)
		parent_team = cult_datum.get_team
	if (parent_team.cult_risen)
		set_eyes()
		stage = STAGE_CULT_RED_EYES
	else if (parent_team.cult_ascendent)
		set_eyes()
		set_halo()
		stage = STAGE_CULT_HALOS

/**
 * Removes all the effects applied when removing the component.
 */
/datum/component/cult_status/Destroy()
	. = ..()
	if (glowing_eyes)
		REMOVE_TRAIT(parent, TRAIT_UNNATURAL_RED_GLOWY_EYES, CULT_TRAIT)
		if (ishuman(parent))
			var/mob/living/carbon/human/human_parent = parent
			human_parent.eye_color = initial(human_parent.eye_color)
			human_parent.dna.update_ui_block(DNA_EYE_COLOR_BLOCK)
	if (has_halo)
		if (ishuman(parent))
			var/mob/living/carbon/human/human_parent = parent
			human_parent.remove_overlay(HALO_LAYER)
			human_parent.update_body()
		else
			var/mob/living/mob = parent
			mob.cut_overlay(HALO_LAYER)

/datum/component/cult_status/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, COMSIG_CULT_VIS)
	UnregisterSignal(parent, COMSIG_CULT_DECONVERT)
	UnregisterSignal(parent, COMSIG_MOB_TRANSFORMING)
	qdel(src)

/**
 * Raise the current visibility level of the cultist.
 *
 * Checks the current stage, raises it if a specific level is not applied.
 * Supplies the flavour text, and the sounds, then calls the procs associated with each stage.
 * Arguments:
 * * _stage - (Optional) Specify the cult visibility stage to raise to.
 */
/datum/component/cult_status/proc/raise_level(_stage = -1)
	if (_stage == -1)
		stage += 1
	else
		stage = _stage

	switch(stage)
		if (STAGE_CULT_RED_EYES)
			SEND_SOUND(parent, 'sound/hallucinations/i_see_you2.ogg')
			to_chat(parent, span_cultlarge(span_warning("The veil weakens as your cult grows, your eyes begin to glow...")))
			addtimer(CALLBACK(src, .proc/set_eyes, parent), 20 SECONDS)
		if (STAGE_CULT_HALOS)
			SEND_SOUND(parent, 'sound/hallucinations/im_here1.ogg')
			to_chat(parent, span_cultlarge(span_warning("Your cult is ascendent and the red harvest approaches - you cannot hide your true nature for much longer!!")))
			addtimer(CALLBACK(src, .proc/set_halo, parent), 20 SECONDS)

/**
 * Set the eyes of the cultist to begin glowing.
 *
 * Humans will have their eye colour changed, while any other mob will just have "glowing eyes".
 */
/datum/component/cult_status/proc/set_eyes()
	if (ishuman(parent))
		var/mob/living/carbon/human/human_parent = parent
		human_parent.eye_color = BLOODCULT_EYE
		human_parent.dna.update_ui_block(DNA_EYE_COLOR_BLOCK)
		ADD_TRAIT(human_parent, TRAIT_UNNATURAL_RED_GLOWY_EYES, CULT_TRAIT)
		human_parent.update_body()
	else
		ADD_TRAIT(parent, TRAIT_UNNATURAL_RED_GLOWY_EYES, CULT_TRAIT)
	glowing_eyes = TRUE

/**
 * Apply a floating halo above the cultist.
 */
/datum/component/cult_status/proc/set_halo()
	var/icon_state = pick ("halo1", "halo2", "halo3", "halo4", "halo5", "halo6")
	var/mutable_appearance/new_halo_overlay = mutable_appearance('icons/effects/32x64.dmi', icon_state, -HALO_LAYER)
	if (ishuman(parent))
		var/mob/living/carbon/human/human_parent = parent
		new /obj/effect/temp_visual/cult/sparks(get_turf(human_parent), human_parent.dir)
		human_parent.overlays_standing[HALO_LAYER] = new_halo_overlay
		human_parent.apply_overlay(HALO_LAYER)
	else
		var/mob/living/mob = parent
		mob.add_overlay(new_halo_overlay)
	has_halo = TRUE

/**
 * Handle mob transformation.
 *
 * Prevents deleting the given traits by transforming into a different mob.
 */
/datum/component/cult_status/proc/handle_transform()
	if (glowing_eyes)
		set_eyes()
	if (has_halo)
		set_halo()
