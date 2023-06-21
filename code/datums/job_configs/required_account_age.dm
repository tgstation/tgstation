/// The amount of time required to have an account to join a job (days).
/datum/job_config_type/required_account_age
	name = JOB_CONFIG_REQUIRED_ACCOUNT_AGE

/datum/job_config_type/required_account_age/get_compile_time_value(datum/job/occupation)
	return initial(occupation.minimal_player_age)

/datum/job_config_type/required_account_age/validate_value(value)
	if(isnum(value))
		return TRUE
	return FALSE

/datum/job_config_type/required_account_age/set_current_value(datum/job/occupation, value)
	. = ..()

	if(!.)
		return FALSE

	occupation.minimal_player_age = value
	return TRUE
