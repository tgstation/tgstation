/datum/preference/toggle/default_legs_color
	savefile_key = "default_legs_color"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES

/datum/preference/toggle/default_legs_color/create_default_value()
	return FALSE

/datum/preference/toggle/default_legs_color/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["legs_color_custom"] = value

/datum/preference/toggle/default_legs_color/is_accessible(datum/preferences/preferences)
	. = ..()
	var/species = preferences.read_preference(/datum/preference/choiced/species)
	if(species in GLOB.species_blacklist_no_mutant)
		return FALSE
	return TRUE

/datum/preference/color/legs_color
	priority = PREFERENCE_PRIORITY_BODYPARTS
	savefile_key = "legs_color"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES

/datum/preference/color/legs_color/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["legs_color"] = value

/datum/preference/color/legs_color/create_default_value()
	return random_hair_color() // fur is close enough to hair...

/datum/preference/color/legs_color/is_accessible(datum/preferences/preferences)
	. = ..()
	var/ticked = preferences.read_preference(/datum/preference/toggle/default_legs_color)
	if(ticked == TRUE)
		return TRUE
	return FALSE

/datum/preference/color/legs_color/is_valid(value)
	if (!..(value))
		return FALSE

	return TRUE
