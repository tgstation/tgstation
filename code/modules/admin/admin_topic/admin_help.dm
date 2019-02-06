// ALL ADMIN HELP RELATED DATUMS ARE IN HERE



/datum/datum_topic/admins_topic/ahelp
	keyword= "ahelp"
	log = FALSE

/datum/datum_topic/admins_topic/ahelp/Run(list/input)
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

/datum/datum_topic/admins_topic/ahelp_tickets/Run(list/input)
	GLOB.ahelp_tickets.BrowseTickets(text2num(input["ahelp_tickets"]))