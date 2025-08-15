////////////////////////////////
/proc/message_admins(msg)
	msg = "<span class=\"admin\"><span class=\"prefix\">ADMIN LOG:</span> <span class=\"message\">[msg]</span></span>"
	to_chat(GLOB.admins,
		type = MESSAGE_TYPE_ADMINLOG,
		html = msg,
		confidential = TRUE)

/proc/relay_msg_admins(msg)
	msg = "<span class=\"admin\"><span class=\"prefix\">RELAY:</span> <span class=\"message\">[msg]</span></span>"
	to_chat(GLOB.admins,
		type = MESSAGE_TYPE_ADMINLOG,
		html = msg,
		confidential = TRUE)

///////////////////////////////////////////////////////////////////////////////////////////////Panels

/datum/admins/proc/Game()
	if(!check_rights(0))
		return

	var/dat

	dat += "<a href='byond://?src=[REF(src)];[HrefToken()];gamemode_panel=1'>Dynamic Panel</a><BR>"
	dat += "<hr/>"
	dat += {"
		<A href='byond://?src=[REF(src)];[HrefToken()];create_object=1'>Create Object</A><br>
		<A href='byond://?src=[REF(src)];[HrefToken()];quick_create_object=1'>Quick Create Object</A><br>
		<A href='byond://?src=[REF(src)];[HrefToken()];create_turf=1'>Create Turf</A><br>
		<A href='byond://?src=[REF(src)];[HrefToken()];create_mob=1'>Create Mob</A><br>
		"}

	if(marked_datum && istype(marked_datum, /atom))
		dat += "<A href='byond://?src=[REF(src)];[HrefToken()];dupe_marked_datum=1'>Duplicate Marked Datum</A><br>"

	var/datum/browser/browser = new(usr, "admin2", "Game Panel", 240, 280)
	browser.set_content(dat)
	browser.open()
	return

////////////////////////////////////////////////////////////////////////////////////////////////ADMIN HELPER PROCS

ADMIN_VERB(spawn_atom, R_SPAWN, "Spawn", "Spawn an atom.", ADMIN_CATEGORY_DEBUG, object as text)
	if(!object)
		return
	var/list/preparsed = splittext(object,":")
	var/path = preparsed[1]
	var/amount = 1
	if(preparsed.len > 1)
		amount = clamp(text2num(preparsed[2]),1,ADMIN_SPAWN_CAP)

	var/chosen = pick_closest_path(path)
	if(!chosen)
		return
	var/turf/T = get_turf(user.mob)

	if(ispath(chosen, /turf))
		T.ChangeTurf(chosen)
	else
		for(var/i in 1 to amount)
			var/atom/A = new chosen(T)
			A.flags_1 |= ADMIN_SPAWNED_1

	log_admin("[key_name(user)] spawned [amount] x [chosen] at [AREACOORD(user.mob)]")
	BLACKBOX_LOG_ADMIN_VERB("Spawn Atom")

ADMIN_VERB(spawn_atom_pod, R_SPAWN, "PodSpawn", "Spawn an atom via supply drop.", ADMIN_CATEGORY_DEBUG, object as text)
	var/chosen = pick_closest_path(object)
	if(!chosen)
		return
	var/turf/target_turf = get_turf(user.mob)

	if(ispath(chosen, /turf))
		target_turf.ChangeTurf(chosen)
	else
		var/obj/structure/closet/supplypod/pod = podspawn(list(
			"target" = target_turf,
			"path" = /obj/structure/closet/supplypod/centcompod,
		))
		//we need to set the admin spawn flag for the spawned items so we do it outside of the podspawn proc
		var/atom/A = new chosen(pod)
		A.flags_1 |= ADMIN_SPAWNED_1

	log_admin("[key_name(user)] pod-spawned [chosen] at [AREACOORD(user.mob)]")
	BLACKBOX_LOG_ADMIN_VERB("Podspawn Atom")

ADMIN_VERB(spawn_cargo, R_SPAWN, "Spawn Cargo", "Spawn a cargo crate.", ADMIN_CATEGORY_DEBUG, object as text)
	var/chosen = pick_closest_path(object, make_types_fancy(subtypesof(/datum/supply_pack)))
	if(!chosen)
		return
	var/datum/supply_pack/S = new chosen
	S.admin_spawned = TRUE
	S.generate(get_turf(user.mob))

	log_admin("[key_name(user)] spawned cargo pack [chosen] at [AREACOORD(user.mob)]")
	BLACKBOX_LOG_ADMIN_VERB("Spawn Cargo")

ADMIN_VERB(create_or_modify_area, R_DEBUG, "Create Or Modify Area", "Create of modify an area. wow.", ADMIN_CATEGORY_DEBUG)
	create_area(user.mob)

//Kicks all the clients currently in the lobby. The second parameter (kick_only_afk) determins if an is_afk() check is ran, or if all clients are kicked
//defaults to kicking everyone (afk + non afk clients in the lobby)
//returns a list of ckeys of the kicked clients
/proc/kick_clients_in_lobby(message, kick_only_afk = 0)
	var/list/kicked_client_names = list()
	for(var/client/C in GLOB.clients)
		if(isnewplayer(C.mob))
			if(kick_only_afk && !C.is_afk()) //Ignore clients who are not afk
				continue
			if(message)
				to_chat(C, message, confidential = TRUE)
			kicked_client_names.Add("[C.key]")
			qdel(C)
	return kicked_client_names

//returns TRUE to let the dragdrop code know we are trapping this event
//returns FALSE if we don't plan to trap the event
/datum/admins/proc/cmd_ghost_drag(mob/dead/observer/frommob, mob/tomob)

	//this is the exact two check rights checks required to edit a ckey with vv.
	if (!check_rights(R_VAREDIT,0) || !check_rights(R_SPAWN|R_DEBUG,0))
		return FALSE

	if (!frommob.ckey)
		return FALSE

	var/question = ""
	if (tomob.ckey)
		question = "This mob already has a user ([tomob.key]) in control of it! "
	question += "Are you sure you want to place [frommob.name]([frommob.key]) in control of [tomob.name]?"

	var/ask = tgui_alert(usr, question, "Place ghost in control of mob?", list("Yes", "No"))
	if (ask != "Yes")
		return TRUE

	if (!frommob || !tomob) //make sure the mobs don't go away while we waited for a response
		return TRUE

	// Disassociates observer mind from the body mind
	if(tomob.client)
		tomob.ghostize(FALSE)
	else
		for(var/mob/dead/observer/ghost in GLOB.dead_mob_list)
			if(tomob.mind == ghost.mind)
				ghost.mind = null

	message_admins(span_adminnotice("[key_name_admin(usr)] has put [frommob.key] in control of [tomob.name]."))
	log_admin("[key_name(usr)] stuffed [frommob.key] into [tomob.name].")
	BLACKBOX_LOG_ADMIN_VERB("Ghost Drag Control")

	tomob.PossessByPlayer(frommob.key)
	tomob.client?.init_verbs()
	qdel(frommob)

	return TRUE

/// Sends a message to adminchat when anyone with a holder logs in or logs out.
/// Is dependent on admin preferences and configuration settings, which means that this proc can fire without sending a message.
/client/proc/adminGreet(logout = FALSE)
	if(!SSticker.HasRoundStarted())
		return

	if(logout && CONFIG_GET(flag/announce_admin_logout))
		message_admins("Admin logout: [key_name(src)]")
		return

	if(!logout && CONFIG_GET(flag/announce_admin_login) && (prefs.toggles & ANNOUNCE_LOGIN))
		message_admins("Admin login: [key_name(src)]")
		return
