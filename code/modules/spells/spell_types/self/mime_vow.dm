/datum/action/cooldown/spell/vow_of_silence
	name = "Speech"
	desc = "Make (or break) a vow of silence."
	background_icon_state = "bg_mime"
	icon_icon = 'icons/mob/actions/actions_mime.dmi'
	button_icon_state = "mime_speech"
	panel = "Mime"

	school = SCHOOL_MIME
	cooldown_time = 5 MINUTES

	spell_requirements = SPELL_REQUIRES_HUMAN|SPELL_REQUIRES_MIND
	spell_max_level = 1

/datum/action/cooldown/spell/vow_of_silence/cast(mob/living/carbon/human/cast_on)
	. = ..()
	cast_on.mind.miming = !cast_on.mind.miming
	if(cast_on.mind.miming)
		to_chat(cast_on, span_notice("You make a vow of silence."))
		SEND_SIGNAL(cast_on, COMSIG_CLEAR_MOOD_EVENT, "vow")
	else
		to_chat(cast_on, span_notice("You break your vow of silence."))
		SEND_SIGNAL(cast_on, COMSIG_ADD_MOOD_EVENT, "vow", /datum/mood_event/broken_vow)
	cast_on.update_action_buttons_icon()
