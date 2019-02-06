




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