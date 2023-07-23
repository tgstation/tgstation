/// What to show on the AI hologram
/datum/preference/choiced/ai_hologram_display
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "preferred_ai_hologram_display"
	should_generate_icons = TRUE

/datum/preference/choiced/ai_hologram_display/init_possible_values()
	var/list/values = list()

	values["Random"] = icon('icons/mob/silicon/ai.dmi', "questionmark")

	for(var/hologram in GLOB.ai_hologram_icons - "Random")
		values[hologram] = icon(GLOB.ai_hologram_icons[hologram], GLOB.ai_hologram_icon_state[hologram])

	return values

/datum/preference/choiced/ai_hologram_display/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE

	return istype(preferences.get_highest_priority_job(), /datum/job/ai)

/datum/preference/choiced/ai_hologram_display/apply_to_human(mob/living/carbon/human/target, value)
	return
