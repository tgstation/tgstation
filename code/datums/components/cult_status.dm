/datum/component/cult_status
	// keeps track of a cultist's visible status
	// use this to update its current state:
	// eyes
	// halos
	// add overlays, manage the traits.
	// add support for multiple mobs
	// make sure not to remove this on transformation (see changelings, human -> monkey -> human)

	// this may need to be true to handle cross transformation? check this out
	can_transfer = FALSE

	///Which stage of visibilty is the cultist at?
	var/stage = STAGE_CULT_UNSEEN

/datum/component/cult_status/Initialize()
	RegisterSignal(parent, COMSIG_CULT_VIS, .proc/raise_level)
	RegisterSignal(parent, COMSIG_CULT_DECONVERT, .proc/UnregisterFromParent)

/datum/component/cult_status/UnregisterFromParent()
	. = ..()
	if (HAS_TRAIT(parent, TRAIT_UNNATURAL_RED_GLOWY_EYES))
		REMOVE_TRAIT(parent, TRAIT_UNNATURAL_RED_GLOWY_EYES, CULT_TRAIT)
		var/mob/living/carbon/human/human_parent = parent
		human_parent.eye_color = initial(human_parent.eye_color)
		human_parent.dna.update_ui_block(DNA_EYE_COLOR_BLOCK)
	if (stage == STAGE_CULT_HALOS)
		var/mob/living/carbon/human/human_parent = parent
		human_parent.remove_overlay(HALO_LAYER)
		human_parent.update_body()
	UnregisterSignal(parent, COMSIG_CULT_VIS)
	UnregisterSignal(parent, COMSIG_CULT_DECONVERT)


/datum/component/cult_status/proc/raise_level(var/new_stage, var/override_timer = FALSE)
	stage = new_stage
	switch(stage)
		if (STAGE_CULT_RED_EYES)
			SEND_SOUND(parent, 'sound/hallucinations/i_see_you2.ogg')
			to_chat(parent, span_cultlarge(span_warning("The veil weakens as your cult grows, your eyes begin to glow...")))
			if (override_timer)
				set_eyes()
			else
				addtimer(CALLBACK(src, .proc/set_eyes, parent), 20 SECONDS)
		if (STAGE_CULT_HALOS)
			SEND_SOUND(parent, 'sound/hallucinations/im_here1.ogg')
			to_chat(parent, span_cultlarge(span_warning("Your cult is ascendent and the red harvest approaches - you cannot hide your true nature for much longer!!")))
			if (override_timer)
				set_halo()
			else
				addtimer(CALLBACK(src, .proc/set_halo, parent), 20 SECONDS)

/datum/component/cult_status/proc/set_eyes()
	if (ishuman(parent))
		var/mob/living/carbon/human/human_parent = parent
		human_parent.eye_color = BLOODCULT_EYE
		human_parent.dna.update_ui_block(DNA_EYE_COLOR_BLOCK)
		ADD_TRAIT(human_parent, TRAIT_UNNATURAL_RED_GLOWY_EYES, CULT_TRAIT)
		human_parent.update_body()
	else
		// add something that indicates a simplemob may be a cultist
		message_admins("Chungus")

/datum/component/cult_status/proc/set_halo()
	if (ishuman(parent))
		var/mob/living/carbon/human/human_parent = parent
		new /obj/effect/temp_visual/cult/sparks(get_turf(human_parent), human_parent.dir)
		var/icon_state = pick ("halo1", "halo2", "halo3", "halo4", "halo5", "halo6")
		var/mutable_appearance/new_halo_overlay = mutable_appearance('icons/effects/32x64.dmi', icon_state, -HALO_LAYER)
		human_parent.overlays_standing[HALO_LAYER] = new_halo_overlay
		human_parent.apply_overlay(HALO_LAYER)
	else
		// add something...
		message_admins("Chungus")
