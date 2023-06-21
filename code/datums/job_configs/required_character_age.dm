/// The required age a character must be to join a job (which is in years).
/datum/job_config_type/required_character_age
	name = JOB_CONFIG_REQUIRED_CHARACTER_AGE

/datum/job_config_type/required_character_age/get_compile_time_value(datum/job/occupation)
	return initial(occupation.required_character_age) || 0 // edge case here, this is typically null by default and returning null causes issues. Returning 0 is a safe default.

/datum/job_config_type/required_character_age/validate_value(value)
	if(isnum(value))
		return TRUE
	return FALSE

/datum/job_config_type/required_character_age/set_current_value(datum/job/occupation, value)
	. = ..()

	if(!.)
		return FALSE

	if(value > AGE_MIN && value < AGE_MAX)
		occupation.required_character_age = value
		return TRUE

	if(value == 0)
		occupation.required_character_age = null // they're opting out of the codebase-set required character age, so set it to null since that's what the code needs to ignore it
		return TRUE

	var/error_string = "Invalid value for [name] for [occupation.title] (with config tag [occupation.config_tag])! Value must be between [AGE_MIN] and [AGE_MAX]!"
	error_string += "\n[occupation.title]'s required age will remain the default value of [occupation.required_character_age || "0 (OFF)"]!"
	log_config(error_string)
	return FALSE
