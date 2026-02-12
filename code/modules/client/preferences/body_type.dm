#define USE_GENDER "Use gender"

/datum/preference/choiced/body_type
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	priority = PREFERENCE_PRIORITY_BODY_TYPE
	savefile_key = "body_type"
	savefile_identifier = PREFERENCE_CHARACTER
	can_randomize = FALSE

/datum/preference/choiced/body_type/init_possible_values()
	return list(USE_GENDER, MALE, FEMALE)

/datum/preference/choiced/body_type/is_valid(value, datum/preferences/preferences)
	. = ..()
	if(. && value == USE_GENDER)
		return gender_has_physique(preferences.read_preference(/datum/preference/choiced/gender))

/datum/preference/choiced/body_type/create_informed_default_value(datum/preferences/preferences)
	return gender_has_physique(preferences.read_preference(/datum/preference/choiced/gender)) ? USE_GENDER : FEMALE

/datum/preference/choiced/body_type/apply_to_human(mob/living/carbon/human/target, value)
	if (value == USE_GENDER)
		value = target.gender
		if (!gender_has_physique(value))
			value = FEMALE // non-binary physique does not work for several reasons, big refactor for whoever bites, female is the most common in this scenario

	target.physique = value

/datum/preference/choiced/body_type/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE

	var/datum/species/species = preferences.read_preference(/datum/preference/choiced/species)
	return initial(species.sexes)

/proc/gender_has_physique(gender)
	return gender == MALE || gender == FEMALE

#undef USE_GENDER
