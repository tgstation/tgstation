ADMIN_VERB(show_tip, R_ADMIN, "Show Tip", "Sends a tip to all players.", ADMIN_CATEGORY_MAIN)
	var/input = input(user, "Please specify your tip that you want to send to the players.", "Tip", "") as message|null
	if(!input)
		return

	if(!SSticker)
		return

	// If we've already tipped, then send it straight away.
	if(SSticker.tipped)
		send_tip_of_the_round(world, input)
	else
		SSticker.selected_tip = input

	message_admins("[key_name_admin(user)] sent a tip of the round.")
	log_admin("[key_name(user)] sent \"[input]\" as the Tip of the Round.")
	BLACKBOX_LOG_ADMIN_VERB("Show Tip")

ADMIN_VERB(announce, R_ADMIN, "Announce", "Announce your desires to the world.", ADMIN_CATEGORY_MAIN)
	var/message = input(user, "Global message to send:", "Admin Announce")  as message|null
	if(!message)
		return

	if(!user.holder.check_for_rights(R_SERVER))
		message = adminscrub(message,500)
	send_ooc_announcement(message, "From [user.holder.fakekey ? "Administrator" : user.key]")
	log_admin("Announce: [key_name(user)] : [message]")
	BLACKBOX_LOG_ADMIN_VERB("Announce")

ADMIN_VERB(unprison, R_ADMIN, "UnPrison", ADMIN_VERB_NO_DESCRIPTION, ADMIN_CATEGORY_HIDDEN, mob/prisoner in GLOB.mob_list)
	if(!is_centcom_level(prisoner.z))
		tgui_alert(user, "[prisoner.name] is not prisoned.")
		return

	SSjob.send_to_late_join(prisoner)
	message_admins("[key_name_admin(user)] has unprisoned [key_name_admin(prisoner)]")
	log_admin("[key_name(user)] has unprisoned [key_name(prisoner)]")
	BLACKBOX_LOG_ADMIN_VERB("Unprison")

ADMIN_VERB(cmd_admin_check_player_exp, R_ADMIN, "Player Playtime", "View player playtime.", ADMIN_CATEGORY_MAIN)
	if(!CONFIG_GET(flag/use_exp_tracking))
		to_chat(user, span_warning("Tracking is disabled in the server configuration file."), confidential = TRUE)
		return

	var/list/msg = list()
	msg += "<html><head><meta http-equiv='Content-Type' content='text/html; charset=UTF-8'><title>Playtime Report</title></head><body>Playtime:<BR><UL>"
	for(var/client/client in sort_list(GLOB.clients, GLOBAL_PROC_REF(cmp_playtime_asc)))
		msg += "<LI> [ADMIN_PP(client.mob)] [key_name_admin(client)]: <A href='byond://?_src_=holder;[HrefToken()];getplaytimewindow=[REF(client.mob)]'>" + client.get_exp_living() + "</a></LI>"
	msg += "</UL></BODY></HTML>"
	user << browse(msg.Join(), "window=Player_playtime_check")

/client/proc/trigger_centcom_recall()
	if(!check_rights(R_ADMIN))
		return
	var/message = pick(GLOB.admiral_messages)
	message = input("Enter message from the on-call admiral to be put in the recall report.", "Admiral Message", message) as text|null

	if(!message)
		return

	message_admins("[key_name_admin(usr)] triggered a CentCom recall, with the admiral message of: [message]")
	usr.log_message("triggered a CentCom recall, with the message of: [message]", LOG_GAME)
	SSshuttle.centcom_recall(SSshuttle.emergency.timer, message)

/datum/admins/proc/cmd_show_exp_panel(client/client_to_check)
	if(!check_rights(R_ADMIN))
		return
	if(!client_to_check)
		to_chat(usr, span_danger("ERROR: Client not found."), confidential = TRUE)
		return
	if(!CONFIG_GET(flag/use_exp_tracking))
		to_chat(usr, span_warning("Tracking is disabled in the server configuration file."), confidential = TRUE)
		return

	new /datum/job_report_menu(client_to_check, usr)

/datum/admins/proc/toggle_exempt_status(client/C)
	if(!check_rights(R_ADMIN))
		return
	if(!C)
		to_chat(usr, span_danger("ERROR: Client not found."), confidential = TRUE)
		return

	if(!C.set_db_player_flags())
		to_chat(usr, span_danger("ERROR: Unable read player flags from database. Please check logs."), confidential = TRUE)
	var/dbflags = C.prefs.db_flags
	var/newstate = FALSE
	if(dbflags & DB_FLAG_EXEMPT)
		newstate = FALSE
	else
		newstate = TRUE

	if(C.update_flag_db(DB_FLAG_EXEMPT, newstate))
		to_chat(usr, span_danger("ERROR: Unable to update player flags. Please check logs."), confidential = TRUE)
	else
		message_admins("[key_name_admin(usr)] has [newstate ? "activated" : "deactivated"] job exp exempt status on [key_name_admin(C)]")
		log_admin("[key_name(usr)] has [newstate ? "activated" : "deactivated"] job exp exempt status on [key_name(C)]")

/// Allow admin to add or remove traits of datum
/datum/admins/proc/modify_traits(datum/D)
	if(!D)
		return
	if(!check_rights(R_VAREDIT))
		return

	var/add_or_remove = input("Remove/Add?", "Trait Remove/Add") as null|anything in list("Add","Remove")
	if(!add_or_remove)
		return
	var/list/available_traits = list()

	switch(add_or_remove)
		if("Add")
			for(var/key in GLOB.admin_visible_traits)
				if(istype(D,key))
					available_traits += GLOB.admin_visible_traits[key]
		if("Remove")
			if(!GLOB.admin_trait_name_map)
				GLOB.admin_trait_name_map = generate_admin_trait_name_map()
			for(var/trait in D._status_traits)
				var/name = GLOB.admin_trait_name_map[trait] || trait
				available_traits[name] = trait

	var/chosen_trait = input("Select trait to modify", "Trait") as null|anything in sort_list(available_traits)
	if(!chosen_trait)
		return
	chosen_trait = available_traits[chosen_trait]

	var/source = "adminabuse"
	switch(add_or_remove)
		if("Add") //Not doing source choosing here intentionally to make this bit faster to use, you can always vv it.
			if(GLOB.movement_type_trait_to_flag[chosen_trait]) //include the required element.
				D.AddElement(/datum/element/movetype_handler)
			ADD_TRAIT(D,chosen_trait,source)
		if("Remove")
			var/specific = input("All or specific source ?", "Trait Remove/Add") as null|anything in list("All","Specific")
			if(!specific)
				return
			switch(specific)
				if("All")
					source = null
				if("Specific")
					source = input("Source to be removed","Trait Remove/Add") as null|anything in sort_list(GET_TRAIT_SOURCES(D, chosen_trait))
					if(!source)
						return
			REMOVE_TRAIT(D,chosen_trait,source)

///////////////////////////////////////////////////////////////////////////////////////////////

ADMIN_VERB(drop_everything, R_ADMIN, "Drop Everything", ADMIN_VERB_NO_DESCRIPTION, ADMIN_CATEGORY_HIDDEN, mob/living/dropee in GLOB.mob_list)
	var/confirm = tgui_alert(user, "Make [dropee] drop everything?", "Message", list("Yes", "No"))
	if(confirm != "Yes")
		return

	dropee.drop_everything(del_on_drop = FALSE, force = TRUE, del_if_nodrop = TRUE)
	dropee.regenerate_icons()

	log_admin("[key_name(user)] made [key_name(dropee)] drop everything!")
	var/msg = "[key_name_admin(user)] made [ADMIN_LOOKUPFLW(dropee)] drop everything!"
	message_admins(msg)
	admin_ticket_log(dropee, msg)
	BLACKBOX_LOG_ADMIN_VERB("Drop Everything")

/proc/cmd_admin_mute(whom, mute_type, automute = 0)
	if(!whom)
		return

	var/muteunmute
	var/mute_string
	var/feedback_string
	switch(mute_type)
		if(MUTE_IC)
			mute_string = "IC (say and emote)"
			feedback_string = "IC"
		if(MUTE_OOC)
			mute_string = "OOC"
			feedback_string = "OOC"
		if(MUTE_PRAY)
			mute_string = "pray"
			feedback_string = "Pray"
		if(MUTE_ADMINHELP)
			mute_string = "adminhelp, admin PM and ASAY"
			feedback_string = "Adminhelp"
		if(MUTE_DEADCHAT)
			mute_string = "deadchat and DSAY"
			feedback_string = "Deadchat"
		// DOPPLER EDIT ADDITION START - LOOC muting.
		if(MUTE_LOOC)
			mute_string = "LOOC"
			feedback_string = "LOOC"
		// DOPPLER EDIT ADDITION END - LOOC muting.
		if(MUTE_INTERNET_REQUEST)
			mute_string = "internet sound requests"
			feedback_string = "Internet Sound Requests"
		if(MUTE_ALL)
			mute_string = "everything"
			feedback_string = "Everything"
		else
			return

	var/client/C
	if(istype(whom, /client))
		C = whom
	else if(istext(whom))
		C = GLOB.directory[whom]
	else
		return

	var/datum/preferences/P
	if(C)
		P = C.prefs
	else
		P = GLOB.preferences_datums[whom]
	if(!P)
		return

	if(automute)
		if(!CONFIG_GET(flag/automute_on))
			return
	else
		if(!check_rights())
			return

	if(automute)
		muteunmute = "auto-muted"
		P.muted |= mute_type
		log_admin("SPAM AUTOMUTE: [muteunmute] [key_name(whom)] from [mute_string]")
		message_admins("SPAM AUTOMUTE: [muteunmute] [key_name_admin(whom)] from [mute_string].")
		if(C)
			to_chat(C, "You have been [muteunmute] from [mute_string] by the SPAM AUTOMUTE system. Contact an admin.", confidential = TRUE)
		SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Auto Mute [feedback_string]", "1")) // If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!
		return

	if(P.muted & mute_type)
		muteunmute = "unmuted"
		P.muted &= ~mute_type
	else
		muteunmute = "muted"
		P.muted |= mute_type

	log_admin("[key_name(usr)] has [muteunmute] [key_name(whom)] from [mute_string]")
	message_admins("[key_name_admin(usr)] has [muteunmute] [key_name_admin(whom)] from [mute_string].")
	if(C)
		to_chat(C, "You have been [muteunmute] from [mute_string] by [key_name(usr, include_name = FALSE)].", confidential = TRUE)
	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Mute [feedback_string]", "[P.muted & mute_type]")) // If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!

/proc/immerse_player(mob/living/carbon/target, toggle=TRUE, remove=FALSE)
	var/list/immersion_components = list(/datum/component/manual_breathing, /datum/component/manual_blinking)

	for(var/immersies in immersion_components)
		var/has_component = target.GetComponent(immersies)

		if(has_component && (toggle || remove))
			qdel(has_component)
		else if(toggle || !remove)
			target.AddComponent(immersies)

/proc/mass_immerse(remove=FALSE)
	for(var/mob/living/carbon/M in GLOB.mob_list)
		immerse_player(M, toggle=FALSE, remove=remove)
