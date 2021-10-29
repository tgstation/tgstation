/*
/datum/preference/color_legacy/mutant_color_two
	savefile_key = "feature_mcolor2"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_species_trait = MUTCOLORS

/datum/preference/color_legacy/mutant_color_two/create_default_value()
	return sanitize_hexcolor("[pick("7F", "FF")][pick("7F", "FF")][pick("7F", "FF")]")

/datum/preference/color_legacy/mutant_color_two/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["mcolor2"] = value

/datum/preference/color_legacy/mutant_color_two/is_valid(value)
	if (!..(value))
		return FALSE

	if (is_color_dark(expand_three_digit_color(value)))
		return FALSE

	return TRUE

/datum/preference/color_legacy/mutant_color_three
	savefile_key = "feature_mcolor3"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_species_trait = MUTCOLORS

/datum/preference/color_legacy/mutant_color_three/create_default_value()
	return sanitize_hexcolor("[pick("7F", "FF")][pick("7F", "FF")][pick("7F", "FF")]")

/datum/preference/color_legacy/mutant_color_three/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["mcolor3"] = value

/datum/preference/color_legacy/mutant_color_three/is_valid(value)
	if (!..(value))
		return FALSE

	if (is_color_dark(expand_three_digit_color(value)))
		return FALSE

	return TRUE
*/
