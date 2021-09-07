/datum/preference/choiced/jobless_role
	savefile_key = "joblessrole"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/choiced/jobless_role/create_default_value()
	return BERANDOMJOB

/datum/preference/choiced/jobless_role/init_possible_values()
	return list(BEOVERFLOW, BERANDOMJOB, RETURNTOLOBBY)
