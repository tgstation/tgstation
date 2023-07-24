/datum/preference/choiced/glasses
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_key = "glasses"
	savefile_identifier = PREFERENCE_CHARACTER
	should_generate_icons = TRUE

/datum/preference/choiced/glasses/init_possible_values()
	var/list/values = list()

	values["Random"] = icon('icons/effects/random_spawners.dmi', "questionmark")

	for(var/glass_design in GLOB.nearsighted_glasses - "Random")
		values[glass_design] = icon('icons/obj/clothing/glasses.dmi', "glasses_[lowertext(glass_design)]")

	return values

/datum/preference/choiced/glasses/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE

	return "Nearsighted" in preferences.all_quirks

/datum/preference/choiced/glasses/apply_to_human(mob/living/carbon/human/target, value)
	return
