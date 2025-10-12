/datum/action/cooldown/spell/pointed/moon_smile
	name = "Smile of the moon"
	desc = "Lets you turn the gaze of the moon on someone \
			temporarily blinding, muting, deafening and knocking down a single target if their sanity is low enough."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "moon_smile"
	ranged_mousepointer = 'icons/effects/mouse_pointers/moon_target.dmi'

	sound = 'sound/effects/magic/blind.ogg'
	school = SCHOOL_FORBIDDEN
	cooldown_time = 20 SECONDS
	antimagic_flags = MAGIC_RESISTANCE|MAGIC_RESISTANCE_MIND
	invocation = "M'N S'M'LE!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE
	cast_range = 6

	active_msg = "You prepare to let them see the true face..."

/datum/action/cooldown/spell/pointed/moon_smile/can_cast_spell(feedback = TRUE)
	return ..() && isliving(owner)

/datum/action/cooldown/spell/pointed/moon_smile/is_valid_target(atom/cast_on)
	return ..() && ishuman(cast_on)

/datum/action/cooldown/spell/pointed/moon_smile/cast(mob/living/carbon/human/cast_on)
	. = ..()
	/// The duration of these effects are based on sanity, mainly for flavor but also to make it a weaker alpha strike
	var/maximum_duration = 15 SECONDS
	var/moon_smile_duration = ((SANITY_MAXIMUM - cast_on.mob_mood.sanity) / (SANITY_MAXIMUM - SANITY_INSANE)) * maximum_duration + 1 SECONDS
	if(cast_on.can_block_magic(antimagic_flags))
		to_chat(cast_on, span_notice("The moon turns, its smile no longer set on you."))
		to_chat(owner, span_warning("The moon does not smile upon them."))
		return FALSE

	playsound(cast_on, 'sound/effects/hallucinations/i_see_you1.ogg', 50, 1)
	to_chat(cast_on, span_warning("Your eyes cry out in pain, your ears bleed and your lips seal! THE MOON SMILES UPON YOU!"))
	cast_on.adjust_temp_blindness(moon_smile_duration)
	cast_on.set_eye_blur_if_lower(moon_smile_duration + 2 SECONDS)

	var/obj/item/organ/ears/ears = cast_on.get_organ_slot(ORGAN_SLOT_EARS)
	ears?.temporarily_deafen(moon_smile_duration)

	cast_on.adjust_silence(moon_smile_duration)
	cast_on.add_mood_event("moon_smile", /datum/mood_event/moon_smile)

	// Only knocksdown if the target has a low enough sanity
	if(cast_on.mob_mood.sanity < 40)
		cast_on.AdjustKnockdown(2 SECONDS)
	//Lowers sanity
	cast_on.mob_mood.adjust_sanity(-20)
	return TRUE
