/datum/preference/choiced/item_quirk/junkie/smoker
	category = PREFERENCE_CATEGORY_MANUALLY_RENDERED
	savefile_key = "smoker"
	savefile_identifier = PREFERENCE_CHARACTER

/datum/preference/choiced/item_quirk/junkie/smoker/init_possible_values()
	return list("Random") + GLOB.favorite_brand

/datum/preference/choiced/item_quirk/junkie/smoker/is_accessible(datum/preferences/preferences)
	. = ..()
	if (!.)
		return FALSE

	return "Smoker" in preferences.all_quirks

/datum/preference/choiced/item_quirk/junkie/smoker/apply_to_human(mob/living/carbon/human/target, value)
	return
