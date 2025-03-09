/datum/quirk_constant_data/ship_captain
	associated_typepath = /datum/quirk/ship_captain
	customization_options = list(
		/datum/preference/choiced/ship_captain_hull,
		/datum/preference/text/ship_captain_name,
		/datum/preference/text/ship_captain_crewkey,
	)

// HULL TYPE
/datum/preference/choiced/ship_captain_hull
	category = PREFERENCE_CATEGORY_MANUALLY_RENDERED
	savefile_key = "ship_captain_hull"
	savefile_identifier = PREFERENCE_CHARACTER
	can_randomize = FALSE

/datum/preference/choiced/ship_captain_hull/init_possible_values()
	return list("Random") + assoc_to_keys(GLOB.purchasable_ship_hulls)

/datum/preference/choiced/ship_captain_hull/create_default_value()
	return "Random"

/datum/preference/choiced/ship_captain_hull/is_accessible(datum/preferences/preferences)
	if (!..())
		return FALSE

	return "Spacefarer" in preferences.all_quirks

/datum/preference/choiced/ship_captain_hull/apply_to_human(mob/living/carbon/human/target, value)
	return

// TRANSPONDER/SHIP NAME
/datum/preference/text/ship_captain_name
	category = PREFERENCE_CATEGORY_MANUALLY_RENDERED
	savefile_key = "ship_captain_name"
	savefile_identifier = PREFERENCE_CHARACTER
	can_randomize = FALSE

/datum/preference/text/ship_captain_name/create_default_value()
	return "Default"

/datum/preference/text/ship_captain_name/is_accessible(datum/preferences/preferences)
	if (!..())
		return FALSE

	return "Spacefarer" in preferences.all_quirks

/datum/preference/text/ship_captain_name/apply_to_human(mob/living/carbon/human/target, value)
	return


// CREWING KEY
/datum/preference/text/ship_captain_crewkey
	category = PREFERENCE_CATEGORY_MANUALLY_RENDERED
	savefile_key = "ship_captain_crewkey"
	savefile_identifier = PREFERENCE_CHARACTER
	can_randomize = FALSE

/datum/preference/text/ship_captain_crewkey/create_default_value()
	return "Solo"

/datum/preference/text/ship_captain_crewkey/is_accessible(datum/preferences/preferences)
	if (!..())
		return FALSE

	return "Spacefarer" in preferences.all_quirks

/datum/preference/text/ship_captain_crewkey/apply_to_human(mob/living/carbon/human/target, value)
	return
