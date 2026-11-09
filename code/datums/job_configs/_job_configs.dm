// This contains the types of configurations that can be set for each job.
// Just add a new datum (and add the define name to __defines/jobs.dm) and the applicable procs and you should be good to go.
// Remember, there's a verb in the Server tab called "Generate Job Configuration" that will generate the config file for you.
// You don't need to waste time copy-pasting values if you add a datum here. Just use that verb and it'll do it for you.
// Use the verb. Use the verb. It's your life you're wasting otherwise.

/// Lightweight datum simply used to store the applicable config type for each job such that the whole system is a tad bit more flexible.
/datum/job_config_type
	/// The name that will be used in the config file. This is also the key for the accessing the singleton.
	/// Use the JOB_CONFIG_* defines in __defines/jobs.dm to make sure you don't typo.
	var/name = "DEFAULT"

	/// The name of the variable on the job datum that we will be accessing.
	var/datum_var_name = "type" // we use this as the default because A) it always exists and B) if we try and modify it, we runtime. perfect for what we need

/datum/job_config_type/New()
	. = ..()
	if(PERFORM_ALL_TESTS(focus_only/missing_job_datum_variables))
		var/datum/job/test_occupation = new()
		if(!test_occupation.vars.Find(datum_var_name))
			stack_trace("'[datum_var_name]' is not a valid variable on /datum/job!")
		qdel(test_occupation)

/// Simply gets the value of the config type for a given job. There can be overrides for special instances on subtypes.
/datum/job_config_type/proc/get_current_value(datum/job/occupation)
	return occupation.vars[datum_var_name]

/// Validate the value of the config type for a given job. There can be overrides for special instances on subtypes.
/// Isn't meant for in-depth logic, just bare-bones sanity checks. Like: is this number a number? Is this string a string? Any sanity thing involving a specific job datum goes in set_current_value.
/// Will return TRUE if the value is valid, FALSE if it is not.
/datum/job_config_type/proc/validate_value(value)
	SHOULD_CALL_PARENT(FALSE)
	stack_trace("Attempted to validate value for the default job config! You're doing something wrong!!")
	return FALSE

/// Check if the config entry should be made for a specific job
/// By default returns TRUE, meaning that by default every job will have the config entry created by the datum
/// An example of what this could be used for is: A value that only appears if the job is a head of staff
/datum/job_config_type/proc/validate_entry(datum/job/occupation)
	return TRUE

/// This is the proc that we actually invoke to set the config-based values for each job. Is also intended to handle all in-depth logic checks pertient to the job datum itself.
/// Return TRUE if the value was set successfully (or if expected behavior did indeed occur), FALSE if it was not.
/datum/job_config_type/proc/set_current_value(datum/job/occupation, value)
	if(!validate_value(value))
		return FALSE
	occupation.vars[datum_var_name] = value
	return TRUE
