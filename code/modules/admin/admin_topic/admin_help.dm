// ALL ADMIN HELP RELATED DATUMS ARE IN HERE



/datum/datum_topic/admins_topic/ahelp
	keyword= "ahelp"
	log = FALSE

/datum/datum_topic/admins_topic/ahelp/TryRun(list/input,var/datum/admin/A)
	if(!check_rights(R_ADMIN, TRUE))
		return

	var/ahelp_ref = input["ahelp"]
	var/datum/admin_help/AH = locate(ahelp_ref)
	if(AH)
		AH.Action(input["ahelp_action"])
	else
		to_chat(usr, "Ticket [ahelp_ref] has been deleted!")

/datum/datum_topic/admins_topic/ahelp_tickets
	keyword= "ahelp_tickets"
	log = FALSE

/datum/datum_topic/admins_topic/ahelp_tickets/TryRun(list/input,var/datum/admin/A)
	GLOB.ahelp_tickets.BrowseTickets(text2num(input["ahelp_tickets"]))