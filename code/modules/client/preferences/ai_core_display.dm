/// What to show on the AI screen
/datum/preference/choiced/ai_core_display
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "preferred_ai_core_display"

/datum/preference/choiced/ai_core_display/init_possible_values()
	return GLOB.ai_core_display_screens - "Portrait"

/datum/preference/choiced/ai_core_display/apply_to_human(mob/living/carbon/human/target, value)
	return
