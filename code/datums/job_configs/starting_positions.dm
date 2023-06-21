/// The number of positions a job can have at the start of the round.
/datum/job_config_type/starting_positions
	name = JOB_CONFIG_SPAWN_POSITIONS
	datum_var_name = "spawn_positions"

/datum/job_config_type/starting_positions/validate_value(value)
	if(isnum(value))
		return TRUE
	return FALSE

