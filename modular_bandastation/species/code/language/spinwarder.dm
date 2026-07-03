/datum/language/spinwarder
	always_use_default_namelist = TRUE

/datum/language/spinwarder/default_name(gender)
	if(gender == MALE)
		return "[pick(GLOB.first_names_male_spinwarder)] [pick(GLOB.last_names_male_spinwarder)]"
	return "[pick(GLOB.first_names_female_spinwarder)] [pick(GLOB.last_names_female_spinwarder)]"
