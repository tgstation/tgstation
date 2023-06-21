/// The number of positions a job can have at the start of the round.
/datum/job_config_type/starting_positions
	name = JOB_CONFIG_SPAWN_POSITIONS

/datum/job_config_type/starting_positions/get_compile_time_value(datum/job/occupation)
	if(is_assistant_job(occupation)) // yeah i know it's not the "compile time" value but this is just to remain parity with the old system groooan
		return -1
	return initial(occupation.spawn_positions)

/datum/job_config_type/starting_positions/validate_value(value)
	if(isnum(value))
		return TRUE
	return FALSE

/datum/job_config_type/starting_positions/set_current_value(datum/job/occupation, value)
	. = ..()

	if(!.)
		return FALSE

	occupation.spawn_positions = value
	return TRUE
