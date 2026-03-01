/// Gender preference
/datum/preference/choiced/gender
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "gender"
	priority = PREFERENCE_PRIORITY_GENDER

/datum/preference/choiced/gender/init_possible_values()
	return list(MALE, FEMALE, PLURAL, NEUTER)

/datum/preference/choiced/gender/apply_to_human(mob/living/carbon/human/target, value)
	if(!target.dna.species.sexes)
		value = PLURAL //disregard gender preferences on this species
	target.gender = value

/datum/preference/choiced/gender/create_default_value()
	// The only reason I'm limiting this to male or female
	// is that hairstyle randomization handles enbies poorly
	return pick(MALE, FEMALE)

/datum/preference/choiced/gender/post_write(value, datum/preferences/preferences)
	..()
	if (gender_has_physique(value))
		return

	var/current_physique = preferences.read_preference(/datum/preference/choiced/body_type)
	if(current_physique != MALE && current_physique != FEMALE)
		preferences.update_preference(GLOB.preference_entries[/datum/preference/choiced/body_type], FEMALE)
