/proc/setup_junkie_addictions(list/possible_addictions)
	. = possible_addictions
	for(var/datum/reagent/addiction as anything in .)
		. -= addiction
		.[addiction::name] = addiction

/proc/setup_smoker_addictions(list/possible_addictions)
	. = possible_addictions
	for(var/obj/item/storage/addiction as anything in .)
		. -= addiction
		.[format_text(addiction::name)] = addiction // Format text to remove \improper used in cigarette packs

/datum/preference/choiced/junkie
	category = PREFERENCE_CATEGORY_MANUALLY_RENDERED
	savefile_key = "junkie"
	savefile_identifier = PREFERENCE_CHARACTER

/datum/preference/choiced/junkie/init_possible_values()
	return list("Random") + assoc_to_keys(GLOB.possible_junkie_addictions)

/datum/preference/choiced/junkie/create_default_value()
	return "Random"

/datum/preference/choiced/junkie/is_accessible(datum/preferences/preferences)
	if (!..())
		return FALSE
	return "Junkie" in preferences.all_quirks

/datum/preference/choiced/junkie/apply_to_human(mob/living/carbon/human/target, value)
	return

/datum/preference/choiced/smoker
	category = PREFERENCE_CATEGORY_MANUALLY_RENDERED
	savefile_key = "smoker"
	savefile_identifier = PREFERENCE_CHARACTER

/datum/preference/choiced/smoker/init_possible_values()
	return list("Random") + assoc_to_keys(GLOB.possible_smoker_addictions)

/datum/preference/choiced/smoker/create_default_value()
	return "Random"

/datum/preference/choiced/smoker/is_accessible(datum/preferences/preferences)
	if (!..())
		return FALSE
	return "Smoker" in preferences.all_quirks

/datum/preference/choiced/smoker/apply_to_human(mob/living/carbon/human/target, value)
	return

/datum/preference/choiced/alcoholic
	category = PREFERENCE_CATEGORY_MANUALLY_RENDERED
	savefile_key = "alcoholic"
	savefile_identifier = PREFERENCE_CHARACTER

/datum/preference/choiced/alcoholic/init_possible_values()
	return list("Random") + assoc_to_keys(GLOB.possible_alcoholic_addictions)

/datum/preference/choiced/alcoholic/create_default_value()
	return "Random"

/datum/preference/choiced/alcoholic/is_accessible(datum/preferences/preferences)
	if (!..())
		return FALSE
	return "Alcoholic" in preferences.all_quirks

/datum/preference/choiced/alcoholic/apply_to_human(mob/living/carbon/human/target, value)
	return
