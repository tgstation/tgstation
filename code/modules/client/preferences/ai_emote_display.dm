/// What to show on the AI monitor
/datum/preference/choiced/ai_emote_display
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "preferred_ai_emote_display"
	should_generate_icons = TRUE

/datum/preference/choiced/ai_emote_display/init_possible_values()
	var/list/values = list()

	values["Random"] = icon('icons/mob/silicon/ai.dmi', "questionmark")

	for(var/emote in GLOB.ai_status_display_emotes)
		var/emote_icon = GLOB.ai_status_display_emotes[emote]
		values[emote] = icon('icons/obj/machines/status_display.dmi', emote_icon)

	return values

/datum/preference/choiced/ai_emote_display/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE

	return istype(preferences.get_highest_priority_job(), /datum/job/ai)

/datum/preference/choiced/ai_emote_display/apply_to_human(mob/living/carbon/human/target, value)
	return
