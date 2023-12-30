/datum/mind/proc/make_contractor_support()
	if(has_antag_datum(/datum/antagonist/traitor/contractor_support))
		return
	add_antag_datum(/datum/antagonist/traitor/contractor_support)
