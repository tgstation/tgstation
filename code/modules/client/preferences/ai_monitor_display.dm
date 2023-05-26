/// What to show on the AI monitor
/datum/preference/choiced/ai_monitor_display
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "preferred_ai_monitor_display"
	should_generate_icons = TRUE

/datum/preference/choiced/ai_monitor_display/init_possible_values()
	var/list/values = list()

	values["Random"] = icon('icons/effects/random_spawners.dmi', "questionmark")

	for(var/emote in GLOB.ai_status_display_emotes)
		var/emote_icon = GLOB.ai_status_display_emotes[emote]

		// strip the string so we just get the emotion part
		emote = lowertext(replacetext(emote, "AI_EMOTION_", ""))
		values[emote] = image('icons/obj/status_display.dmi', emote_icon)

	return values

/datum/preference/choiced/ai_monitor_display/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE

	return istype(preferences.get_highest_priority_job(), /datum/job/ai)

/datum/preference/choiced/ai_monitor_display/apply_to_human(mob/living/carbon/human/target, value)
	return
