/// The number of positions a job can have at any given time.
/datum/job_config_type/default_positions
	name = JOB_CONFIG_TOTAL_POSITIONS
	datum_var_name = "total_positions"

/datum/job_config_type/default_positions/validate_value(value)
	if(isnum(value))
		return TRUE
	return FALSE

