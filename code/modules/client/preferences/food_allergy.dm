/datum/preference/choiced/food_allergy
	category = PREFERENCE_CATEGORY_MANUALLY_RENDERED
	savefile_key = "food_allergy"
	savefile_identifier = PREFERENCE_CHARACTER
	can_randomize = FALSE

/datum/preference/choiced/food_allergy/init_possible_values()
	return list("Random") + assoc_to_keys(GLOB.possible_food_allergies)

/datum/preference/choiced/food_allergy/create_default_value()
	return "Random"

/datum/preference/choiced/food_allergy/is_accessible(datum/preferences/preferences)
	if (!..())
		return FALSE

	return "Food Allergy" in preferences.all_quirks

/datum/preference/choiced/food_allergy/apply_to_human(mob/living/carbon/human/target, value)
	return
