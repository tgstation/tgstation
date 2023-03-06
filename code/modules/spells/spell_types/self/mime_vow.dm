/datum/action/cooldown/spell/vow_of_silence
	name = "Speech"
	desc = "Break a vow of silence."
	background_icon_state = "bg_mime"
	overlay_icon_state = "bg_mime_border"
	button_icon = 'icons/mob/actions/actions_mime.dmi'
	button_icon_state = "mime_speech"
	panel = "Mime"

	school = SCHOOL_MIME
	cooldown_time = 5 MINUTES
	spell_requirements = NONE

	spell_max_level = 1

/datum/action/cooldown/spell/vow_of_silence/Grant(mob/living/grant_to)
	. = ..()
	ADD_TRAIT(grant_to, TRAIT_MIMING, "[type]")
	grant_to.clear_mood_event("vow")

/datum/action/cooldown/spell/vow_of_silence/Remove(mob/remove_from)
	. = ..()
	REMOVE_TRAIT(remove_from, TRAIT_MIMING, "[type]")

/datum/action/cooldown/spell/vow_of_silence/cast(mob/living/carbon/human/cast_on)
	. = ..()
	var/datum/action/cooldown/spell/vow_of_silence/vow = locate() in cast_on.actions
	vow.Remove(cast_on)
	to_chat(cast_on, span_notice("You break your vow of silence."))
	cast_on.add_mood_event("vow", /datum/mood_event/broken_vow)
	cast_on.log_message("broke their vow of silence.", LOG_GAME)
	cast_on.update_mob_action_buttons()
