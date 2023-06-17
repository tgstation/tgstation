// This contains the types of configurations that can be set for each job.
// Just add a new datum (and add the define name to __defines/jobs.dm) and the applicable procs and you should be good to go.
// Remember, there's a verb in the Server tab called "Generate Job Configuration" that will generate the config file for you.
// You don't need to waste time copy-pasting values if you add a datum here. Just use that verb and it'll do it for you.
// Use the verb. Use the verb. It's your life you're wasting otherwise.

/// Lightweight datum simply used to store the applicable config type for each job such that the whole system is a tad bit more flexible.
/datum/job_config_type
	var/name = "DEFAULT"

/// Simply gets the value of the config type for a given job. There can be overrides for special instances on subtypes.
/datum/job_config_type/proc/get_compile_time_value(datum/job/occupation)
	SHOULD_CALL_PARENT(FALSE)
	stack_trace("Attempted to get value for the default job config for [occupation.title] (with config tag [occupation.config_tag])! This is not allowed!")

/// This is the proc that we actually invoke to set the config-based values for each job. Is also intended to handle all sanity checks.
/// Will return TRUE if the value was set successfully, FALSE otherwise.
/datum/job_config_type/proc/set_current_value(datum/job/occupation, value)
	SHOULD_CALL_PARENT(FALSE)
	CRASH("Attempted to set value for the default job config for [occupation.title] (with config tag [occupation.config_tag])! This is not allowed!")

/// The number of positions a job can have at any given time.
/datum/job_config_type/default_positions
	name = JOB_CONFIG_TOTAL_POSITIONS

/datum/job_config_type/default_positions/get_compile_time_value(datum/job/occupation)
	if(is_assistant_job(occupation)) // yeah i know it's not the "compile time" value but this is just to remain parity with the old system groooan
		return -1
	return initial(occupation.total_positions)

/datum/job_config_type/default_positions/set_current_value(datum/job/occupation, value)
	if(!isnum(config_value)) // This will mean that the value was commented out, which means that the server operator didn't want to override the codebase default. So, we skip it.
		return FALSE
	occupation.total_positions = value
	return TRUE

/// The number of positions a job can have at the start of the round.
/datum/job_config_type/starting_positions
	name = JOB_CONFIG_SPAWN_POSITIONS

/datum/job_config_type/starting_positions/get_compile_time_value(datum/job/occupation)
	if(is_assistant_job(occupation)) // yeah i know it's not the "compile time" value but this is just to remain parity with the old system groooan
		return -1
	return initial(occupation.spawn_positions)

/datum/job_config_type/starting_positions/set_current_value(datum/job/occupation, value)
	if(!isnum(config_value)) // This will mean that the value was commented out, which means that the server operator didn't want to override the codebase default. So, we skip it.
		return FALSE
	occupation.spawn_positions = value
	return TRUE

/// The amount of playtime required to join a job (minutes).
/datum/job_config_type/playtime_requirements
	name = JOB_CONFIG_PLAYTIME_REQUIREMENTS

/datum/job_config_type/playtime_requirements/get_compile_time_value(datum/job/occupation)
	return initial(occupation.exp_requirements)

/datum/job_config_type/playtime_requirements/set_current_value(datum/job/occupation, value)
	if(!isnum(config_value)) // This will mean that the value was commented out, which means that the server operator didn't want to override the codebase default. So, we skip it.
		return FALSE
	occupation.exp_requirements = value
	return TRUE

/// The amount of time required to have an account to join a job (days).
/datum/job_config_type/required_account_age
	name = JOB_CONFIG_REQUIRED_ACCOUNT_AGE

/datum/job_config_type/required_account_age/get_compile_time_value(datum/job/occupation)
	return initial(occupation.minimal_player_age)

/datum/job_config_type/required_account_age/set_current_value(datum/job/occupation, value)
	if(!isnum(config_value)) // This will mean that the value was commented out, which means that the server operator didn't want to override the codebase default. So, we skip it.
		return FALSE
	occupation.minimal_player_age = value
	return TRUE

/// The required age a character must be to join a job (which is in years).
/datum/job_config_type/required_character_age
	name = JOB_CONFIG_REQUIRED_CHARACTER_AGE

/datum/job_config_type/required_character_age/get_compile_time_value(datum/job/occupation)
	return initial(occupation.required_character_age) || 0 // edge case here, this is typically null by default and returning null causes issues. Returning 0 is a safe default.

/datum/job_config_type/required_character_age/set_current_value(datum/job/occupation, value)
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
