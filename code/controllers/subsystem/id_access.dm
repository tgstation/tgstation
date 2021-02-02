SUBSYSTEM_DEF(id_access)
	name = "IDs and Access"
	init_order = INIT_ORDER_IDACCESS
	flags = SS_NO_FIRE

	/// Dictionary of trim icon states. Keys are job titles, including on-station job titles, Centcom, Syndie, ERT, etc. Values are icon states of their associated trims.
	var/list/trim_states_by_title = list()
	/// Dictionary of access flags. Keys are accesses. Values are their associated bitflags.
	var/list/flags_by_access = list()

/datum/controller/subsystem/id_access/Initialize(timeofday)
	setup_trims()
	setup_access_flags()
	return ..()

/// Populates the trim_states_by_title dictionary.
/datum/controller/subsystem/id_access/proc/setup_trims()
	var/list/all_hud_jobs = get_all_job_icons() + get_all_prisoner_jobs()

	for(var/title in all_hud_jobs)
		trim_states_by_title[title] = "trim_[ckey(title)]"

	var/list/all_centcom_jobs = get_all_centcom_jobs()

	for(var/title in all_centcom_jobs)
		trim_states_by_title[title] = "trim_centcom"

	var/list/all_syndicate_jobs = get_all_syndicate_jobs()

	for(var/title in all_syndicate_jobs)
		trim_states_by_title[title] = "trim_syndicate"

	trim_states_by_title["Jannie"] = "trim_janitorialresponseofficer"
	trim_states_by_title["Unknown"] = "trim_unknown"

/datum/controller/subsystem/id_access/proc/setup_access_flags()
	for(var/access in COMMON_ACCESS)
		flags_by_access[access] = ACCESS_FLAG_COMMON
	for(var/access in COMMAND_ACCESS)
		flags_by_access[access] = ACCESS_FLAG_COMMAND
	for(var/access in PRIVATE_COMMAND_ACCESS)
		flags_by_access[access] = ACCESS_FLAG_PRV_COMMAND
	for(var/access in CAPTAIN_ACCESS)
		flags_by_access[access] = ACCESS_FLAG_CAPTAIN
	for(var/access in CENTCOM_ACCESS)
		flags_by_access[access] = ACCESS_FLAG_CENTCOM
	for(var/access in SYNDICATE_ACCESS)
		flags_by_access[access] = ACCESS_FLAG_SYNDICATE
	for(var/access in AWAY_ACCESS)
		flags_by_access[access] = ACCESS_FLAG_AWAY
	for(var/access in CULT_ACCESS)
		flags_by_access[access] = ACCESS_FLAG_SPECIAL

/// Takes a title and returns an appropriate ID card card trim icon state.
/datum/controller/subsystem/id_access/proc/title_to_trim_icon(title)
	return trim_states_by_title[title] ? trim_states_by_title[title] : trim_states_by_title["Unknown"]

/datum/controller/subsystem/id_access/proc/access_to_flag(access)
	return flags_by_access[access] ? flags_by_access[access] : ACCESS_FLAG_SPECIAL
