/datum/preference/choiced/height_scaling
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_key = "height_scaling"
	savefile_identifier = PREFERENCE_CHARACTER

	/// Assoc list of stringified HUMAN_HEIGHT_### defines to string. Passed into CHOICED_PREFERENCE_DISPLAY_NAMES.
	var/static/list/height_scaling_strings = list(
		"[HUMAN_HEIGHT_SHORTEST]" = "Shortest",
		"[HUMAN_HEIGHT_SHORT]" = "Short",
		"[HUMAN_HEIGHT_MEDIUM]" = "Medium",
		"[HUMAN_HEIGHT_TALL]" = "Tall",
		"[HUMAN_HEIGHT_TALLER]" = "Taller",
		"[HUMAN_HEIGHT_TALLEST]" = "Tallest"
	)

	/// List of strings, representing quirk ids that prevent this from applying and being accessed.
	var/static/list/incompatable_quirk_ids = list(
		"Spacer",
		"Settler"
	)

/datum/preference/choiced/height_scaling/init_possible_values()
	return list(HUMAN_HEIGHT_SHORTEST, HUMAN_HEIGHT_SHORT, HUMAN_HEIGHT_MEDIUM, HUMAN_HEIGHT_TALL, HUMAN_HEIGHT_TALLER, HUMAN_HEIGHT_TALLEST)

/datum/preference/choiced/height_scaling/create_default_value()
	return HUMAN_HEIGHT_MEDIUM

/datum/preference/choiced/height_scaling/is_accessible(datum/preferences/preferences)
	. = ..()

	if(!.)
		return

	// if (ispath(preferences?.pref_species, /datum/species/dwarf)) // all 3 of these manually set your height
	// 	return FALSE

	for (var/quirk_id as anything in preferences?.all_quirks)
		if (quirk_id in incompatable_quirk_ids)
			return FALSE

	return TRUE

/datum/preference/choiced/height_scaling/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	if (HAS_TRAIT(target, TRAIT_DWARF)) // nuh uh. your height is set mf
		return FALSE

	for (var/quirk_id as anything in preferences?.all_quirks)
		if (quirk_id in incompatable_quirk_ids)
			return FALSE

	// if (isteshari(target))
	// 	value = (max(value, HUMAN_HEIGHT_MEDIUM)) // to respect junis tesh rework i am preventing them from getting shorter

	target.set_mob_height(value)

/datum/preference/choiced/height_scaling/compile_constant_data()
	var/list/data = ..()

	// An assoc list of values to display names so we don't show players numbers in their settings!
	data[CHOICED_PREFERENCE_DISPLAY_NAMES] = height_scaling_strings

	return data
