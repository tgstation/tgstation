// Admin Tab - Admin Verbs

ADMIN_VERB(admin, show_tip, "Sends a tip, which you specify, to all players", R_ADMIN)
	var/input = input(usr, "Please specify your tip that you want to send to the players.", "Tip", "") as message|null
	if(!input)
		return

	if(!SSticker.initialized)
		to_chat(usr, span_warning("Please wait for the game to initialize!"))
		return

	// If we've already tipped, then send it straight away.
	if(SSticker.tipped)
		send_tip_of_the_round(world, input)
	else
		SSticker.selected_tip = input

	message_admins("[key_name_admin(usr)] sent a tip of the round.")
	log_admin("[key_name(usr)] sent \"[input]\" as the Tip of the Round.")

ADMIN_VERB(admin, release_from_prison, "", R_ADMIN, mob/freeing in world)
	if(is_centcom_level(freeing.z))
		SSjob.SendToLateJoin(freeing)
		message_admins("[key_name_admin(usr)] has unprisoned [key_name_admin(freeing)]")
		log_admin("[key_name(usr)] has unprisoned [key_name(freeing)]")
	else
		tgui_alert(usr,"[freeing.name] is not prisoned.")

ADMIN_VERB(admin, player_playtime, "Check the playtime for connected players", R_ADMIN)
	if(!CONFIG_GET(flag/use_exp_tracking))
		to_chat(usr, span_warning("Tracking is disabled in the server configuration file."), confidential = TRUE)
		return

	var/list/msg = list()
	msg += "<html><head><meta http-equiv='Content-Type' content='text/html; charset=UTF-8'><title>Playtime Report</title></head><body>Playtime:<BR><UL>"
	for(var/client/client in sort_list(GLOB.clients, GLOBAL_PROC_REF(cmp_playtime_asc)))
		msg += "<LI> [ADMIN_PP(client.mob)] [key_name_admin(client)]: <A href='?_src_=holder;[HrefToken()];getplaytimewindow=[REF(client.mob)]'>" + client.get_exp_living() + "</a></LI>"
	msg += "</UL></BODY></HTML>"
	usr << browse(msg.Join(), "window=Player_playtime_check")

ADMIN_VERB(admin, trigger_centcom_recall, "", R_ADMIN)
	var/message = pick(GLOB.admiral_messages)
	message = input("Enter message from the on-call admiral to be put in the recall report.", "Admiral Message", message) as message|null

	if(!message)
		return

	message_admins("[key_name_admin(usr)] triggered a CentCom recall, with the admiral message of: [message]")
	usr.log_message("triggered a CentCom recall, with the message of: [message]", LOG_GAME)
	SSshuttle.centcom_recall(SSshuttle.emergency.timer, message)

ADMIN_VERB(admin, player_panel, "", R_ADMIN)
	usr.client.holder?.player_panel_new()

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

	var/add_or_remove = input("Remove/Add?", "Trait Remove/Add") as null|anything in list("Add","Remove")
	if(!add_or_remove)
		return
	var/list/available_traits = list()

	switch(add_or_remove)
		if("Add")
			for(var/key in GLOB.traits_by_type)
				if(istype(D,key))
					available_traits += GLOB.traits_by_type[key]
		if("Remove")
			if(!GLOB.trait_name_map)
				GLOB.trait_name_map = generate_trait_name_map()
			for(var/trait in D.status_traits)
				var/name = GLOB.trait_name_map[trait] || trait
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
					source = input("Source to be removed","Trait Remove/Add") as null|anything in sort_list(D.status_traits[chosen_trait])
					if(!source)
						return
			REMOVE_TRAIT(D,chosen_trait,source)

///////////////////////////////////////////////////////////////////////////////////////////////

ADMIN_VERB(admin, drop_everything, "", R_ADMIN, mob/target in world)
	var/confirm = tgui_alert(usr, "Make [target] drop everything?", "Message", list("Yes", "No"))
	if(confirm != "Yes")
		return

	for(var/obj/item/held in target)
		if(!target.dropItemToGround(held))
			qdel(held)
	target.regenerate_icons()

	log_admin("[key_name(usr)] made [key_name(target)] drop everything!")
	var/msg = "[key_name_admin(usr)] made [ADMIN_LOOKUPFLW(target)] drop everything!"
	message_admins(msg)
	admin_ticket_log(target, msg)

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
		SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Auto Mute [feedback_string]", "1")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
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
	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Mute [feedback_string]", "[P.muted & mute_type]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

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
