/// The amount of time required to have an account to join a job (days).
/datum/job_config_type/required_account_age
	name = JOB_CONFIG_REQUIRED_ACCOUNT_AGE
	datum_var_name = "minimal_player_age"

/datum/job_config_type/required_account_age/validate_value(value)
	if(isnum(value))
		return TRUE
	return FALSE

