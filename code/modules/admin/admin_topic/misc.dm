



/datum/datum_topic/admins_topic/stickyban
	keyword= "stickyban"
	log = FALSE

/datum/datum_topic/admins_topic/stickyban/Run(list/input,var/datum/admin/A)
	stickyban(input["stickyban"],input)

/datum/datum_topic/admins_topic/getplaytime
	keyword= "getplaytimewindow"
	log = FALSE

/datum/datum_topic/admins_topic/getplaytime/Run(list/input,var/datum/admin/A)
	if(!check_rights(R_ADMIN))
		return
	var/mob/M = locate(input["getplaytimewindow"]) in GLOB.mob_list
	if(!M)
		to_chat(usr, "<span class='danger'>ERROR: Mob not found.</span>")
		return
	cmd_show_exp_panel(M.client)

/datum/datum_topic/admins_topic/toggleexempt
	keyword= "toggleexempt"
	log = FALSE

/datum/datum_topic/admins_topic/toggleexempt/Run(list/input,var/datum/admin/A)
	if(!check_rights(R_ADMIN))
		return
	var/client/C = locate(input["toggleexempt"]) in GLOB.clients
	if(!C)
		to_chat(usr, "<span class='danger'>ERROR: Client not found.</span>")
		return
	toggle_exempt_status(C)
