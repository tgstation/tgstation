/datum/preference/choiced/smoker
	category = PREFERENCE_CATEGORY_MANUALLY_RENDERED
	savefile_key = "smoker"
	savefile_identifier = PREFERENCE_CHARACTER

/datum/preference/choiced/smoker/init_possible_values()
	return list("Random") + GLOB.drug_container_type

/datum/preference/choiced/smoker/is_accessible(datum/preferences/preferences)
	. = ..()
	if (!.)
		return FALSE

	return "Favorite Brand" in preferences.all_quirks

/datum/preference/choiced/smoker/apply_to_human(mob/living/carbon/human/target, value)
	return
