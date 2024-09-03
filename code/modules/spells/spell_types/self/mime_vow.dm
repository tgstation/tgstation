/datum/action/cooldown/spell/vow_of_silence
	name = "Break Vow"
	desc = "Break your vow of silence. Permanently."
	background_icon_state = "bg_mime"
	overlay_icon_state = "bg_mime_border"
	button_icon = 'icons/mob/actions/actions_mime.dmi'
	button_icon_state = "mime_speech"
	panel = "Mime"

	school = SCHOOL_MIME
	//MMI mimes should be able to break their vow
	spell_requirements = SPELL_CASTABLE_AS_BRAIN

	spell_max_level = 1

/datum/action/cooldown/spell/vow_of_silence/Grant(mob/grant_to)
	. = ..()
	ADD_TRAIT(grant_to, TRAIT_MIMING, "[type]")

/datum/action/cooldown/spell/vow_of_silence/Remove(mob/living/remove_from)
	. = ..()
	REMOVE_TRAIT(remove_from, TRAIT_MIMING, "[type]")

/datum/action/cooldown/spell/vow_of_silence/before_cast(atom/cast_on)
	if(tgui_alert(usr, "Are you sure? There's no going back.", "Break Vow", list("I'm Sure", "Abort")) != "I'm Sure")
		return SPELL_CANCEL_CAST
	return ..()

/datum/action/cooldown/spell/vow_of_silence/cast(mob/living/carbon/human/cast_on)
	. = ..()
	to_chat(cast_on, span_notice("You break your vow of silence."))
	cast_on.log_message("broke [cast_on.p_their()] vow of silence.", LOG_GAME)
	cast_on.add_mood_event("vow", /datum/mood_event/broken_vow)
	REMOVE_TRAIT(cast_on, TRAIT_MIMING, "[type]")
	var/datum/job/mime/mime_job = SSjob.GetJob(JOB_MIME)
	mime_job.total_positions += 1
	qdel(src)
