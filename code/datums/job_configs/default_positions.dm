/// The number of positions a job can have at any given time.
/datum/job_config_type/default_positions
	name = JOB_CONFIG_TOTAL_POSITIONS

/datum/job_config_type/default_positions/get_compile_time_value(datum/job/occupation)
	if(is_assistant_job(occupation)) // yeah i know it's not the "compile time" value but this is just to remain parity with the old system groooan
		return -1
	return initial(occupation.total_positions)

/datum/job_config_type/default_positions/validate_value(value)
	if(isnum(value))
		return TRUE
	return FALSE

/datum/job_config_type/default_positions/set_current_value(datum/job/occupation, value)
	. = ..()

	if(!.)
		return FALSE

	occupation.total_positions = value
	return TRUE
