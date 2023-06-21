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

/// Validate the value of the config type for a given job. There can be overrides for special instances on subtypes.
/// Isn't meant for in-depth logic, just bare-bones sanity checks. Like: is this number a number? Is this string a string? Any sanity thing involving a specific job datum goes in set_current_value.
/// Will return TRUE if the value is valid, FALSE if it is not.
/datum/job_config_type/proc/validate_value(value)
	SHOULD_CALL_PARENT(FALSE)
	stack_trace("Attempted to validate value for the default job config! You're doing something wrong!!")
	return FALSE

/// This is the proc that we actually invoke to set the config-based values for each job. Is also intended to handle all in-depth logic checks pertient to the job datum itself.
/// Return TRUE if the value was set successfully (or if expected behavior did indeed occur), FALSE if it was not.
/datum/job_config_type/proc/set_current_value(datum/job/occupation, value)
	SHOULD_CALL_PARENT(TRUE)
	if(validate_value(value))
		return TRUE

	return FALSE
