SUBSYSTEM_DEF(id_access)
	name = "IDs and Access"
	init_order = INIT_ORDER_IDACCESS
	flags = SS_NO_FIRE

	/// Dictionary of trims. Keys are job titles, including on-station job titles, Centcom, Syndie, ERT, etc. Values are icon states of their associated trims.
	var/list/trims_by_title = list()

/datum/controller/subsystem/id_access/Initialize(timeofday)
	setup_trims()
	return ..()

/// Populates the trims_by_title dictionary.
/datum/controller/subsystem/id_access/proc/setup_trims()
	var/list/all_hud_jobs = get_all_job_icons() + get_all_prisoner_jobs()

	for(var/title in all_hud_jobs)
		trims_by_title[title] = "trim_[ckey(title)]"

	var/list/all_centcom_jobs = get_all_centcom_jobs()

	for(var/title in all_centcom_jobs)
		trims_by_title[title] = "trim_centcom"

	var/list/all_syndicate_jobs = get_all_syndicate_jobs()

	for(var/title in all_syndicate_jobs)
		trims_by_title[title] = "trim_syndicate"

	trims_by_title["Jannie"] = "trim_janitorialresponseofficer"
	trims_by_title["Unknown"] = "trim_unknown"

/// Takes a title and returns an appropriate ID card card trim icon state.
/datum/controller/subsystem/id_access/proc/title_to_trim_icon(title)
	return trims_by_title[title] ? trims_by_title[title] : trims_by_title["Unknown"]
