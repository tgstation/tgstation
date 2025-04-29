#define SILICON_MALE "He/Him"
#define SILICON_FEMALE "She/Her"
#define SILICON_PLURAL "They/Them"
#define SILICON_NEUTER "It/Its"

/datum/preference/choiced/silicon_gender
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "silicon_gender"
	var/static/use_character_gender = "Use character gender"
	///Used to convert the read value of this preference into a gender
	var/static/list/pronouns_to_genders = list(
		"[SILICON_MALE]" = MALE,
		"[SILICON_FEMALE]" = FEMALE,
		"[SILICON_PLURAL]" = PLURAL,
		"[SILICON_NEUTER]" = NEUTER,
	)

/datum/preference/choiced/silicon_gender/init_possible_values()
	return list(
		use_character_gender,
		SILICON_MALE,
		SILICON_FEMALE,
		SILICON_PLURAL,
		SILICON_NEUTER,
	)

/datum/preference/choiced/silicon_gender/create_default_value()
	return SILICON_NEUTER

/datum/preference/choiced/silicon_gender/apply_to_human(mob/living/carbon/human/target, value)
	return

#undef SILICON_MALE
#undef SILICON_FEMALE
#undef SILICON_PLURAL
#undef SILICON_NEUTER
