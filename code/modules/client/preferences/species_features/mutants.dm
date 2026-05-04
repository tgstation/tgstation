/datum/preference/color/mutant_color
	savefile_key = "feature_mcolor"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_inherent_trait = TRAIT_MUTANT_COLORS

/datum/preference/color/mutant_color/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE

	var/species_type = preferences.read_preference(/datum/preference/choiced/species)
	var/datum/species/species = GLOB.species_prototypes[species_type]
	return !(TRAIT_FIXED_MUTANT_COLORS in species.inherent_traits)

/datum/preference/color/mutant_color/create_default_value()
	return sanitize_hexcolor("[pick("7F", "FF")][pick("7F", "FF")][pick("7F", "FF")]")

/datum/preference/color/mutant_color/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features[FEATURE_MUTANT_COLOR] = value

/datum/preference/color/mutant_color/is_valid(value)
	if (!..(value))
		return FALSE

	if (is_color_dark(value, 15))
		return FALSE

	return TRUE
