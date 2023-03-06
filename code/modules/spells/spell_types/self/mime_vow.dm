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

	var/popup = FALSE // is the confirmation window open?

/datum/action/cooldown/spell/vow_of_silence/Grant(mob/living/grant_to)
	. = ..()
	ADD_TRAIT(grant_to, TRAIT_MIMING, "[type]")
	grant_to.clear_mood_event("vow")

/datum/action/cooldown/spell/vow_of_silence/Remove(mob/remove_from)
	. = ..()
	REMOVE_TRAIT(remove_from, TRAIT_MIMING, "[type]")

/datum/action/cooldown/spell/vow_of_silence/cast(mob/living/carbon/human/cast_on)
	. = ..()
	if(popup)
		return FALSE
	popup = TRUE
	var/response = tgui_alert(cast_on, "Are you sure you want to break your vow of silence? This will disable your mimery abilities!", "Break Vow of Silence Confirmation", list("Yes", "No"))
	popup = FALSE
	if(response != "Yes")
		return FALSE
	var/datum/action/cooldown/spell/vow_of_silence/vow = locate() in cast_on.actions
	vow.Remove(cast_on)
	to_chat(cast_on, span_notice("You break your vow of silence."))
	cast_on.add_mood_event("vow", /datum/mood_event/broken_vow)
	cast_on.log_message("broke their vow of silence.", LOG_GAME)
	cast_on.update_mob_action_buttons()
