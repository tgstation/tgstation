/// The amount of playtime required to join a job (minutes).
/datum/job_config_type/playtime_requirements
	name = JOB_CONFIG_PLAYTIME_REQUIREMENTS

/datum/job_config_type/playtime_requirements/get_compile_time_value(datum/job/occupation)
	return initial(occupation.exp_requirements)

/datum/job_config_type/playtime_requirements/validate_value(value)
	if(isnum(value))
		return TRUE
	return FALSE

/datum/job_config_type/playtime_requirements/set_current_value(datum/job/occupation, value)
	. = ..()

	if(!.)
		return FALSE

	occupation.exp_requirements = value
	return TRUE
