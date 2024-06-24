/datum/job
	/// The minimum antag opt-in any holder of this job must use. If null, will defer to the mind's opt in level.
	var/minimum_opt_in_level
	/// Can this job be targetted as a heretic sacrifice target?
	var/heretic_sac_target
	/// Is this job targetable by contractors?
	var/contractable

/// Updates [minimum_opt_in_level] [heretic_sac_target] and [contractable].
/datum/job/proc/update_opt_in_vars()
	if(CONFIG_GET(flag/disable_antag_opt_in_preferences))
		return

	if(isnull(minimum_opt_in_level))
		minimum_opt_in_level = get_initial_opt_in_level()
	if(isnull(heretic_sac_target))
		heretic_sac_target = initialize_heretic_target_status()
	if(isnull(contractable))
		contractable = initialize_contractable_status()

	update_opt_in_desc_suffix()

/// Returns this job's initial opt in level, taking into account departmental bitflags.
/datum/job/proc/get_initial_opt_in_level()
	if (departments_bitflags & (DEPARTMENT_BITFLAG_SECURITY))
		return SECURITY_OPT_IN_LEVEL
	if (departments_bitflags & (DEPARTMENT_BITFLAG_COMMAND))
		return COMMAND_OPT_IN_LEVEL

/// Determines if this job should be sacrificable by heretics.
/datum/job/proc/initialize_heretic_target_status()
	if (departments_bitflags & (DEPARTMENT_BITFLAG_SECURITY | DEPARTMENT_BITFLAG_COMMAND))
		return TRUE

	return FALSE

/// Determines if this job should be targetable by contractors.
/datum/job/proc/initialize_contractable_status()
	if (departments_bitflags & (DEPARTMENT_BITFLAG_SECURITY | DEPARTMENT_BITFLAG_COMMAND))
		return TRUE

	return FALSE

/// Generates and sets a suffix appended to our description detailing our opt-in variables.
/datum/job/proc/update_opt_in_desc_suffix()
	var/list/suffixes = list()

	if (minimum_opt_in_level)
		suffixes += " Forces a minimum of [GLOB.antag_opt_in_strings["[minimum_opt_in_level]"]] antag opt-in."
	if (contractable)
		suffixes += " Targetable by contractors."
	if (heretic_sac_target)
		suffixes += " Targetable by heretics."
	if (length(suffixes))
		var/suffix = jointext(suffixes, "")
		set_opt_in_desc_suffix(suffix)

/// Setter for [new_suffix]. Resets desc then appends the new suffix.
/datum/job/proc/set_opt_in_desc_suffix(new_suffix)
	description = initial(description)

	if (new_suffix)
		description += new_suffix

/datum/controller/subsystem/job/SetupOccupations()
	. = ..()

	if(CONFIG_GET(flag/disable_antag_opt_in_preferences))
		return

	for(var/datum/job/job as anything in all_occupations)
		job.update_opt_in_vars()
