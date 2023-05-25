/// What to show on the AI monitor
/datum/preference/choiced/ai_monitor_display
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "preferred_ai_monitor_display"
	should_generate_icons = TRUE

/datum/preference/choiced/ai_monitor_display/init_possible_values()
	var/list/values = list()

	values["Random"] = icon('icons/mob/silicon/ai.dmi', "ai-empty")

	for (var/screen in GLOB.ai_monitor_display_screens - "Portrait" - "Random")
		values[screen] = icon('icons/mob/silicon/ai.dmi', resolve_ai_icon_sync(screen))

	return values

/datum/preference/choiced/ai_monitor_display/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE

	return istype(preferences.get_highest_priority_job(), /datum/job/ai)

/datum/preference/choiced/ai_monitor_display/apply_to_human(mob/living/carbon/human/target, value)
	return
