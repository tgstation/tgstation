ADMIN_VERB(debug, toggle_global_debugging, "", R_DEBUG)
	GLOB.Debug2 = !GLOB.Debug2
	var/message = "has toggled global debugging [(GLOB.Debug2 ? "on" : "off")]"
	log_admin("[key_name(usr)] [message]")
	message_admins("[key_name_admin(usr)] [message]")

ADMIN_VERB(debug, get_air_status, "", R_DEBUG)
	atmos_scan(user=usr, target=get_turf(usr), silent=TRUE)

ADMIN_VERB(debug, make_cyborg, "", R_DEBUG, mob/target in GLOB.mob_list)
	if(!SSticker.HasRoundStarted())
		tgui_alert(usr, "Wait until the game starts")
		return

	log_admin("[key_name(usr)] has robotized [key_name(target)].")
	INVOKE_ASYNC(target, TYPE_PROC_REF(/mob, Robotize))

/client/proc/poll_type_to_del(search_string)
	var/list/types = get_fancy_list_of_atom_types()
	if (!isnull(search_string) && search_string != "")
		types = filter_fancy_list(types, search_string)

	if(!length(types))
		return

	var/key = input(usr, "Choose an object to delete.", "Delete:") as null|anything in sort_list(types)

	if(!key)
		return
	return types[key]

ADMIN_VERB(debug, delete_all_of_type, "", R_DEBUG, object as text)
	var/type_to_del = usr.client.poll_type_to_del(object)
	if(!type_to_del)
		return

	var/force_del = tgui_alert(usr, "Force Deletion?", "Del-All", list("Yes", "No", "Cancel"))
	if(force_del == "Cancel")
		return
	force_del = (force_del == "Yes")

	var/counter = 0
	var/atom/target
	while((target = locate(type_to_del) in world))
		counter++
		qdel(target, force = force_del)
		CHECK_TICK

	var/message = "has [(force_del ? "forcibly" : "")] deleted all ([counter]) instances of '[type_to_del]'"
	log_admin("[key_name(usr)] [message]")
	message_admins("[key_name_admin(usr)] [message]")

ADMIN_VERB(debug, hard_delete_all_of_type, "", R_DEBUG, object as text)
	var/type_to_del = usr.client.poll_type_to_del(object)
	if(!type_to_del)
		return

	var/choice = tgui_alert(
		usr,
		"ARE YOU SURE that you want to hard delete this type? This will cause MASSIVE lag!",
		"What the fuck happened?",
		list("Yes", "No"),
		)
	if(choice != "Yes")
		return

	choice = tgui_alert(
		usr,
		"Do you want to pre qdelete the atom? This will speed things up significantly, but may break depending on your level of fuckup.",
		"How do you even get it that bad",
		list("Yes", "No"),
		)
	var/should_pre_qdel = TRUE
	if(choice == "No")
		should_pre_qdel = FALSE

	choice = tgui_alert(
		usr,
		"Ok one last thing, do you want to yield to the game? or do it all at once. These are hard deletes remember.",
		"Jesus christ man",
		list("Yield", "Ignore the server"),
		)
	var/should_check_tick = TRUE
	if(choice == "Ignore the server")
		should_check_tick = FALSE

	var/counter = 0
	var/atom/target
	while((target = locate(type_to_del) in world))
		counter++
		if(should_pre_qdel)
			qdel(target)
		del(target)

		if(should_check_tick)
			CHECK_TICK

	var/message = "has HARD DELETED all ([counter]) instances of '[type_to_del]'"
	log_admin("[key_name(usr)] [message]")
	message_admins("[key_name_admin(usr)] [message]")

ADMIN_VERB(debug, make_powernets, "", R_DEBUG)
	SSmachines.makepowernets()
	log_admin("[key_name(usr)] has remade the powernet.")
	message_admins("[key_name_admin(usr)] has remade the powernets.")

ADMIN_VERB(game, grant_full_access, "", R_ADMIN, mob/living/carbon/human/target in view())
	if(!SSticker.HasRoundStarted())
		tgui_alert(usr, "Wait until the game starts")
		return

	var/obj/item/worn = target.wear_id
	var/obj/item/card/id/id = null

	if(worn)
		id = worn.GetID()
	if(id)
		if(id == worn)
			worn = null
		qdel(id)

	id = new /obj/item/card/id/advanced/debug()

	id.registered_name = target.real_name
	id.update_label()
	id.update_icon()

	if(worn)
		if(istype(worn, /obj/item/modular_computer/pda))
			var/obj/item/modular_computer/pda/PDA = worn
			PDA.InsertID(id, target)

		else if(istype(worn, /obj/item/storage/wallet))
			var/obj/item/storage/wallet/wallet = worn
			wallet.front_id = id
			id.forceMove(target)
			target.update_icon()
	else
		target.equip_to_slot(id, ITEM_SLOT_ID)

	log_admin("[key_name(usr)] has granted [key_name(target)] full access.")
	message_admins("[key_name_admin(usr)] has granted [key_name_admin(target)] full access.")

ADMIN_VERB(game, assume_direct_control, "", R_ADMIN, mob/target in view())
	if(target.ckey)
		var/force = tgui_alert(
			usr,
			"This mob is already being controlled by '[target.ckey]'. Are you sure you wish to assume control of it? The existing client will be made a ghost.",
			"Assuming Control",
			list("Yes", "No"),
			)
		if(force != "Yes")
			return

	if(QDELETED(target))
		to_chat(usr, span_warning("The target mob no longer exists."))
		return

	var/target_name = key_name(target)
	if(target.ckey)
		target.ghostize(FALSE)

	var/adminmob = usr
	target.key = usr.key
	if(isobserver(adminmob))
		qdel(adminmob)

	message_admins(span_adminnotice("[key_name_admin(usr)] assumed direct control of [target_name]."))
	log_admin("[key_name(usr)] assumed direct control of [target_name].")

ADMIN_VERB(game, give_direct_control, "", R_DEBUG, mob/pawn in view())
	if(pawn.ckey)
		if(tgui_alert(usr,"This mob is being controlled by [pawn.key]. Are you sure you wish to give someone else control of it? [pawn.key] will be made a ghost.",,list("Yes","No")) != "Yes")
			return
	var/client/newkey = input(src, "Pick the player to put in control.", "New player") as null|anything in sort_list(GLOB.clients)
	var/mob/oldmob = newkey.mob
	var/delmob = FALSE
	if((isobserver(oldmob) || tgui_alert(usr,"Do you want to delete [newkey]'s old mob?","Delete?",list("Yes","No")) != "No"))
		delmob = TRUE
	if(QDELETED(pawn))
		to_chat(usr, span_warning("The target mob no longer exists, aborting."))
		return

	if(pawn.ckey)
		pawn.ghostize(FALSE)
	pawn.ckey = newkey.key
	pawn.client?.init_verbs()
	if(delmob)
		qdel(oldmob)
	message_admins(span_adminnotice("[key_name_admin(usr)] gave away direct control of [pawn] to [newkey]."))
	log_admin("[key_name(usr)] gave away direct control of [pawn] to [newkey].")

/datum/admins/proc/cmd_admin_areatest(on_station = FALSE, filter_maint = FALSE)
	var/list/dat = list()
	var/list/areas_all = list()
	var/list/areas_with_APC = list()
	var/list/areas_with_multiple_APCs = list()
	var/list/areas_with_air_alarm = list()
	var/list/areas_with_RC = list()
	var/list/areas_with_light = list()
	var/list/areas_with_LS = list()
	var/list/areas_with_intercom = list()
	var/list/areas_with_camera = list()
	/**We whitelist in case we're doing something on a planetary station that shares multiple different types of areas, this should only be full of "station" area types.
	This only goes into effect when we explicitly do the "on station" Areas Test.
	*/
	var/static/list/station_areas_whitelist = typecacheof(list(
		/area/station,
	))
	///Additionally, blacklist in order to filter out the types of areas that can show up on station Z-levels that we never need to test for.
	var/static/list/station_areas_blacklist = typecacheof(list(
		/area/centcom/asteroid,
		/area/mine,
		/area/ruin,
		/area/shuttle,
		/area/space,
		/area/station/engineering/supermatter,
		/area/station/holodeck/rec_center,
		/area/station/science/ordnance/bomb,
		/area/station/solars,
	))

	if(SSticker.current_state == GAME_STATE_STARTUP)
		to_chat(usr, "Game still loading, please hold!", confidential = TRUE)
		return

	var/log_message
	if(on_station)
		dat += "<b>Only checking areas on station z-levels.</b><br><br>"
		log_message = "station z-levels"
	else
		log_message = "all z-levels"
	if(filter_maint)
		dat += "<b>Maintenance Areas Filtered Out</b>"
		log_message += ", with no maintenance areas"

	message_admins(span_adminnotice("[key_name_admin(usr)] used the Test Areas debug command checking [log_message]."))
	log_admin("[key_name(usr)] used the Test Areas debug command checking [log_message].")

	for(var/area/A as anything in GLOB.areas)
		if(on_station)
			var/list/area_turfs = get_area_turfs(A.type)
			if (!length(area_turfs))
				continue
			var/turf/picked = pick(area_turfs)
			if(is_station_level(picked.z))
				if(!(A.type in areas_all) && !is_type_in_typecache(A, station_areas_blacklist) && is_type_in_typecache(A, station_areas_whitelist))
					if(filter_maint && istype(A, /area/station/maintenance))
						continue
					areas_all.Add(A.type)
		else if(!(A.type in areas_all))
			areas_all.Add(A.type)
		CHECK_TICK

	for(var/obj/machinery/power/apc/APC in GLOB.apcs_list)
		var/area/A = APC.area
		if(!A)
			dat += "Skipped over [APC] in invalid location, [APC.loc]."
			continue
		if(!(A.type in areas_with_APC))
			areas_with_APC.Add(A.type)
		else if(A.type in areas_all)
			areas_with_multiple_APCs.Add(A.type)
		CHECK_TICK

	for(var/obj/machinery/airalarm/AA in GLOB.machines)
		var/area/A = get_area(AA)
		if(!A) //Make sure the target isn't inside an object, which results in runtimes.
			dat += "Skipped over [AA] in invalid location, [AA.loc].<br>"
			continue
		if(!(A.type in areas_with_air_alarm))
			areas_with_air_alarm.Add(A.type)
		CHECK_TICK

	for(var/obj/machinery/requests_console/RC in GLOB.allConsoles)
		var/area/A = get_area(RC)
		if(!A)
			dat += "Skipped over [RC] in invalid location, [RC.loc].<br>"
			continue
		if(!(A.type in areas_with_RC))
			areas_with_RC.Add(A.type)
		CHECK_TICK

	for(var/obj/machinery/light/L in GLOB.machines)
		var/area/A = get_area(L)
		if(!A)
			dat += "Skipped over [L] in invalid location, [L.loc].<br>"
			continue
		if(!(A.type in areas_with_light))
			areas_with_light.Add(A.type)
		CHECK_TICK

	for(var/obj/machinery/light_switch/LS in GLOB.machines)
		var/area/A = get_area(LS)
		if(!A)
			dat += "Skipped over [LS] in invalid location, [LS.loc].<br>"
			continue
		if(!(A.type in areas_with_LS))
			areas_with_LS.Add(A.type)
		CHECK_TICK

	for(var/obj/item/radio/intercom/I as anything in GLOB.intercoms_list)
		var/area/A = get_area(I)
		if(!A)
			dat += "Skipped over [I] in invalid location, [I.loc].<br>"
			continue
		if(!(A.type in areas_with_intercom))
			areas_with_intercom.Add(A.type)
		CHECK_TICK

	for(var/obj/machinery/camera/C as anything in GLOB.cameranet.cameras)
		var/area/A = get_area(C)
		if(!A)
			dat += "Skipped over [C] in invalid location, [C.loc].<br>"
			continue
		if(!(A.type in areas_with_camera))
			areas_with_camera.Add(A.type)
		CHECK_TICK

	var/list/areas_without_APC = areas_all - areas_with_APC
	var/list/areas_without_air_alarm = areas_all - areas_with_air_alarm
	var/list/areas_without_RC = areas_all - areas_with_RC
	var/list/areas_without_light = areas_all - areas_with_light
	var/list/areas_without_LS = areas_all - areas_with_LS
	var/list/areas_without_intercom = areas_all - areas_with_intercom
	var/list/areas_without_camera = areas_all - areas_with_camera

	if(areas_without_APC.len)
		dat += "<h1>AREAS WITHOUT AN APC:</h1>"
		for(var/areatype in areas_without_APC)
			dat += "[areatype]<br>"
			CHECK_TICK

	if(areas_with_multiple_APCs.len)
		dat += "<h1>AREAS WITH MULTIPLE APCS:</h1>"
		for(var/areatype in areas_with_multiple_APCs)
			dat += "[areatype]<br>"
			CHECK_TICK

	if(areas_without_air_alarm.len)
		dat += "<h1>AREAS WITHOUT AN AIR ALARM:</h1>"
		for(var/areatype in areas_without_air_alarm)
			dat += "[areatype]<br>"
			CHECK_TICK

	if(areas_without_RC.len)
		dat += "<h1>AREAS WITHOUT A REQUEST CONSOLE:</h1>"
		for(var/areatype in areas_without_RC)
			dat += "[areatype]<br>"
			CHECK_TICK

	if(areas_without_light.len)
		dat += "<h1>AREAS WITHOUT ANY LIGHTS:</h1>"
		for(var/areatype in areas_without_light)
			dat += "[areatype]<br>"
			CHECK_TICK

	if(areas_without_LS.len)
		dat += "<h1>AREAS WITHOUT A LIGHT SWITCH:</h1>"
		for(var/areatype in areas_without_LS)
			dat += "[areatype]<br>"
			CHECK_TICK

	if(areas_without_intercom.len)
		dat += "<h1>AREAS WITHOUT ANY INTERCOMS:</h1>"
		for(var/areatype in areas_without_intercom)
			dat += "[areatype]<br>"
			CHECK_TICK

	if(areas_without_camera.len)
		dat += "<h1>AREAS WITHOUT ANY CAMERAS:</h1>"
		for(var/areatype in areas_without_camera)
			dat += "[areatype]<br>"
			CHECK_TICK

	if(!(areas_with_APC.len || areas_with_multiple_APCs.len || areas_with_air_alarm.len || areas_with_RC.len || areas_with_light.len || areas_with_LS.len || areas_with_intercom.len || areas_with_camera.len))
		dat += "<b>No problem areas!</b>"

	var/datum/browser/popup = new(usr, "testareas", "Test Areas", 500, 750)
	popup.set_content(dat.Join())
	popup.open()

ADMIN_VERB(mapping, test_station_areas, "", R_DEBUG)
	usr.client.holder.cmd_admin_areatest(on_station = TRUE)

ADMIN_VERB(mapping, test_station_areas_without_maint, "", R_DEBUG)
	usr.client.holder.cmd_admin_areatest(on_station = TRUE, filter_maint = TRUE)

ADMIN_VERB(mapping, test_all_areas, "", R_DEBUG)
	usr.client.holder.cmd_admin_areatest()

/client/proc/robust_dress_shop()
	var/list/baseoutfits = list("Naked","Custom","As Job...", "As Plasmaman...")
	var/list/outfits = list()
	var/list/paths = subtypesof(/datum/outfit) - typesof(/datum/outfit/job) - typesof(/datum/outfit/plasmaman)

	for(var/path in paths)
		var/datum/outfit/O = path //not much to initalize here but whatever
		outfits[initial(O.name)] = path

	var/dresscode = input("Select outfit", "Robust quick dress shop") as null|anything in baseoutfits + sort_list(outfits)
	if (isnull(dresscode))
		return

	if (outfits[dresscode])
		dresscode = outfits[dresscode]

	if (dresscode == "As Job...")
		var/list/job_paths = subtypesof(/datum/outfit/job)
		var/list/job_outfits = list()
		for(var/path in job_paths)
			var/datum/outfit/O = path
			job_outfits[initial(O.name)] = path

		dresscode = input("Select job equipment", "Robust quick dress shop") as null|anything in sort_list(job_outfits)
		dresscode = job_outfits[dresscode]
		if(isnull(dresscode))
			return

	if (dresscode == "As Plasmaman...")
		var/list/plasmaman_paths = typesof(/datum/outfit/plasmaman)
		var/list/plasmaman_outfits = list()
		for(var/path in plasmaman_paths)
			var/datum/outfit/O = path
			plasmaman_outfits[initial(O.name)] = path

		dresscode = input("Select plasmeme equipment", "Robust quick dress shop") as null|anything in sort_list(plasmaman_outfits)
		dresscode = plasmaman_outfits[dresscode]
		if(isnull(dresscode))
			return

	if (dresscode == "Custom")
		var/list/custom_names = list()
		for(var/datum/outfit/D in GLOB.custom_outfits)
			custom_names[D.name] = D
		var/selected_name = input("Select outfit", "Robust quick dress shop") as null|anything in sort_list(custom_names)
		dresscode = custom_names[selected_name]
		if(isnull(dresscode))
			return

	return dresscode

ADMIN_CONTEXT_ENTRY(context_rejuvenate, "Rejuvenate", R_ADMIN, mob/living/fallen in world)
	fallen.revive(ADMIN_HEAL_ALL)
	log_admin("[key_name(usr)] healed / revived [key_name(fallen)]")
	var/msg = span_danger("Admin [key_name_admin(usr)] healed / revived [ADMIN_LOOKUPFLW(fallen)]!")
	message_admins(msg)
	admin_ticket_log(fallen, msg)

ADMIN_CONTEXT_ENTRY(context_delete, "Delete", (R_SPAWN|R_DEBUG), atom/target as obj|mob|turf in world)
	holder.admin_delete(target)

ADMIN_CONTEXT_ENTRY(context_check_contents, "Check Contents", R_ADMIN, mob/living/target in world)
	var/list/all_contents = target.get_contents()
	for(var/content in all_contents)
		to_chat(usr, "[content] [ADMIN_VV(content)] [ADMIN_TAG(content)]", confidential = TRUE)

ADMIN_VERB(debug, modify_goals, "", R_ADMIN)
	var/dat = ""
	for(var/datum/station_goal/S in GLOB.station_goals)
		dat += "[S.name] - <a href='?src=[REF(S)];[HrefToken()];announce=1'>Announce</a> | <a href='?src=[REF(S)];[HrefToken()];remove=1'>Remove</a><br>"
	dat += "<br><a href='?src=[REF(usr)];[HrefToken()];add_station_goal=1'>Add New Goal</a>"
	usr << browse(dat, "window=goals;size=400x400")

#define MOB_LIST_PLAYERS "Players"
#define MOB_LIST_ADMINS "Admins"
#define MOB_LIST_MOBS "Mobs"
#define MOB_LIST_MOBS_LIVING "Living Mobs"
#define MOB_LIST_MOBS_DEAD "Dead Mobs"
#define MOB_LIST_CLIENTS "Clients"
#define MOB_LIST_CLIENTS_JOINED "Joined Clients"
// Theres probably a better name for this
#define MOB_LIST_LIST list( \
	MOB_LIST_PLAYERS, \
	MOB_LIST_ADMINS, \
	MOB_LIST_MOBS, \
	MOB_LIST_MOBS_LIVING, \
	MOB_LIST_MOBS_DEAD, \
	MOB_LIST_CLIENTS, \
	MOB_LIST_CLIENTS_JOINED)

ADMIN_VERB(debug, debug_mob_lists, "For when you just gotta know", R_DEBUG)
	var/chosen_list = tgui_input_list(usr, "Which list?", "Select List", MOB_LIST_LIST)
	if(isnull(chosen_list))
		return
	switch(chosen_list)
		if(MOB_LIST_PLAYERS)
			to_chat(usr, jointext(GLOB.player_list,","), confidential = TRUE)
		if(MOB_LIST_ADMINS)
			to_chat(usr, jointext(GLOB.admins,","), confidential = TRUE)
		if(MOB_LIST_MOBS)
			to_chat(usr, jointext(GLOB.mob_list,","), confidential = TRUE)
		if(MOB_LIST_MOBS_LIVING)
			to_chat(usr, jointext(GLOB.alive_mob_list,","), confidential = TRUE)
		if(MOB_LIST_MOBS_DEAD)
			to_chat(usr, jointext(GLOB.dead_mob_list,","), confidential = TRUE)
		if(MOB_LIST_CLIENTS)
			to_chat(usr, jointext(GLOB.clients,","), confidential = TRUE)
		if(MOB_LIST_CLIENTS_JOINED)
			to_chat(usr, jointext(GLOB.joined_player_list,","), confidential = TRUE)

ADMIN_VERB(debug, display_del_log, "Display del's log of everything that's passed through it", R_DEBUG)
	var/list/dellog = list("<B>List of things that have gone through qdel this round</B><BR><BR><ol>")
	sortTim(SSgarbage.items, cmp=/proc/cmp_qdel_item_time, associative = TRUE)
	for(var/path in SSgarbage.items)
		var/datum/qdel_item/I = SSgarbage.items[path]
		dellog += "<li><u>[path]</u><ul>"
		if (I.qdel_flags & QDEL_ITEM_SUSPENDED_FOR_LAG)
			dellog += "<li>SUSPENDED FOR LAG</li>"
		if (I.failures)
			dellog += "<li>Failures: [I.failures]</li>"
		dellog += "<li>qdel() Count: [I.qdels]</li>"
		dellog += "<li>Destroy() Cost: [I.destroy_time]ms</li>"
		if (I.hard_deletes)
			dellog += "<li>Total Hard Deletes [I.hard_deletes]</li>"
			dellog += "<li>Time Spent Hard Deleting: [I.hard_delete_time]ms</li>"
			dellog += "<li>Highest Time Spent Hard Deleting: [I.hard_delete_max]ms</li>"
			if (I.hard_deletes_over_threshold)
				dellog += "<li>Hard Deletes Over Threshold: [I.hard_deletes_over_threshold]</li>"
		if (I.slept_destroy)
			dellog += "<li>Sleeps: [I.slept_destroy]</li>"
		if (I.no_respect_force)
			dellog += "<li>Ignored force: [I.no_respect_force]</li>"
		if (I.no_hint)
			dellog += "<li>No hint: [I.no_hint]</li>"
		dellog += "</ul></li>"

	dellog += "</ol>"

	usr << browse(dellog.Join(), "window=dellog")

ADMIN_VERB(debug, display_overlay_log, "Display SSoverlays log of everything that's passed through it", R_DEBUG)
	render_stats(SSoverlays.stats, usr)

ADMIN_VERB(debug, display_initailize_log, "Displays a list of things that didn't handle Initialize() properly", R_DEBUG)
	usr << browse(replacetext(SSatoms.InitLog(), "\n", "<br>"), "window=initlog")

ADMIN_VERB(debug, colorblind_testing, "Change your view to a budger version of colorblindness to test for usability", R_DEBUG)
	usr.client.holder.color_test.ui_interact(usr)

ADMIN_VERB(debug, edit_debug_planes, "Edit and visuaize plane masters and their connections (relays)", R_DEBUG)
	usr.client.holder.edit_plane_masters()

/datum/admins/proc/edit_plane_masters(mob/debug_on)
	if(debug_on)
		owner.holder.plane_debug.set_mirroring(TRUE)
		owner.holder.plane_debug.set_target(debug_on)
	else
		owner.holder.plane_debug.set_mirroring(FALSE)
	owner.holder.plane_debug.ui_interact(usr)

ADMIN_VERB(debug, debug_huds, "Debug one of the HUDs", R_DEBUG)
	var/list/choices = list()
	for(var/idx in 1 to length(GLOB.huds))
		var/datum/hud = GLOB.huds[idx]
		choices["[hud.type]"] = hud

	var/choice = tgui_input_list(usr, "Select Hud Type", "Debug HUDs", choices)
	if(!choice)
		return
	SSadmin_verbs.dynamic_invoke_admin_verb(usr, /mob/admin_module_holder/debug/view_variables, choices[choice])

ADMIN_VERB(debug, jump_to_ruin, "Displays a list of all placed ruins for teleporting", R_DEBUG)
	var/list/names = list()
	for(var/obj/effect/landmark/ruin/ruin_landmark as anything in GLOB.ruin_landmarks)
		var/datum/map_template/ruin/template = ruin_landmark.ruin_template

		var/count = 1
		var/name = template.name
		var/original_name = name

		while(name in names)
			count++
			name = "[original_name] ([count])"

		names[name] = ruin_landmark

	var/ruinname = input("Select ruin", "Jump to Ruin") as null|anything in sort_list(names)
	var/obj/effect/landmark/ruin/landmark = names[ruinname]

	if(istype(landmark))
		var/datum/map_template/ruin/template = landmark.ruin_template
		if(!isobserver(usr))
			SSadmin_verbs.dynamic_invoke_admin_verb(usr, /mob/admin_module_holder/game/aghost)
			if(!isobserver(usr))
				to_chat(usr, span_warning("Failed to aghost."))
				return

		usr.abstract_move(get_turf(landmark))
		to_chat(usr, span_name("[template.name]"), confidential = TRUE)
		to_chat(usr, "<span class='italics'>[template.description]</span>", confidential = TRUE)

ADMIN_VERB(debug, spawn_ruin, "Attempt to randomly place a specific ruin", R_DEBUG)
	var/list/exists = list()
	for(var/landmark in GLOB.ruin_landmarks)
		var/obj/effect/landmark/ruin/L = landmark
		exists[L.ruin_template] = landmark

	var/list/names = list()
	var/list/themed_names
	for (var/theme in SSmapping.themed_ruins)
		names += "---- [theme] ----"
		themed_names = list()
		for (var/name in SSmapping.themed_ruins[theme])
			var/datum/map_template/ruin/ruin = SSmapping.themed_ruins[theme][name]
			themed_names[name] = list(ruin, theme, list(ruin.default_area))
		names += sort_list(themed_names)

	var/ruinname = input("Select ruin", "Spawn Ruin") as null|anything in names
	var/data = names[ruinname]
	if (!data)
		return
	var/datum/map_template/ruin/template = data[1]
	if (exists[template])
		var/response = tgui_alert(usr,"There is already a [template] in existence.", "Spawn Ruin", list("Jump", "Place Another", "Cancel"))
		if (response == "Jump")
			if(!isobserver(usr))
				SSadmin_verbs.dynamic_invoke_admin_verb(usr, /mob/admin_module_holder/game/aghost)
				if(!isobserver(usr))
					to_chat(usr, span_warning("Failed to aghost."))
					return
			usr.forceMove(get_turf(exists[template]))
			return
		else if (response == "Cancel")
			return

	var/len = GLOB.ruin_landmarks.len
	seedRuins(SSmapping.levels_by_trait(data[2]), max(1, template.cost), data[3], list(ruinname = template))
	if (GLOB.ruin_landmarks.len > len)
		var/obj/effect/landmark/ruin/landmark = GLOB.ruin_landmarks[GLOB.ruin_landmarks.len]
		log_admin("[key_name(usr)] randomly spawned ruin [ruinname] at [COORD(landmark)].")
		usr.forceMove(get_turf(landmark))
		to_chat(usr, span_name("[template.name]"), confidential = TRUE)
		to_chat(usr, "<span class='italics'>[template.description]</span>", confidential = TRUE)
	else
		to_chat(usr, span_warning("Failed to place [template.name]."), confidential = TRUE)

ADMIN_VERB(debug, unload_ctf, "Despawns CTF", R_DEBUG)
	toggle_id_ctf(usr, unload=TRUE)

ADMIN_VERB(debug, run_empty_query, "Runs a query that does nothing", R_DEBUG, val as num)
	var/list/queries = list()
	for(var/i in 1 to val)
		var/datum/db_query/query = SSdbcore.NewQuery("NULL")
		INVOKE_ASYNC(query, TYPE_PROC_REF(/datum/db_query, Execute))
		queries += query

	for(var/datum/db_query/query as anything in queries)
		query.sync()
		qdel(query)
	queries.Cut()

	message_admins("[key_name_admin(usr)] ran [val] empty queries.")

//Debug procs
ADMIN_VERB(debug, test_movable_UI, "", R_DEBUG)
	var/atom/movable/screen/movable/M = new()
	M.name = "Movable UI Object"
	M.icon_state = "block"
	M.maptext = MAPTEXT("Movable")
	M.maptext_width = 64

	var/screen_l = input(usr,"Where on the screen? (Formatted as 'X,Y' e.g: '1,1' for bottom left)","Spawn Movable UI Object") as text|null
	if(!screen_l)
		return

	M.screen_loc = screen_l

	usr.client.screen += M

// Debug verbs.
ADMIN_VERB(debug, restart_controller, "Restart one of the two main controllers for the game (be careful!)", R_DEBUG, controller in list("Master", "Failsafe"))
	switch(controller)
		if("Master")
			Recreate_MC()
		if("Failsafe")
			new /datum/controller/failsafe()
		else
			stack_trace("Invalid controller type [controller] passed to restart_controller()")
	message_admins("Admin [key_name_admin(usr)] has restarted the [controller] controller.")

ADMIN_VERB(debug, debug_controller, "Debug one of the subsystem controllers", R_DEBUG)
	var/list/controllers = list()
	var/list/controller_choices = list()

	for (var/datum/controller/controller in world)
		if (istype(controller, /datum/controller/subsystem))
			continue
		controllers["[controller] (controller.type)"] = controller //we use an associated list to ensure clients can't hold references to controllers
		controller_choices += "[controller] (controller.type)"

	var/datum/controller/controller_string = input("Select controller to debug", "Debug Controller") as null|anything in controller_choices
	var/datum/controller/controller = controllers[controller_string]

	if (!istype(controller))
		return
	SSadmin_verbs.dynamic_invoke_admin_verb(usr, /mob/admin_module_holder/debug/view_variables, controller)
	message_admins("Admin [key_name_admin(usr)] is debugging the [controller] controller.")

ADMIN_VERB(debug, spawn_snap_ui_object, "", R_DEBUG)
	var/atom/movable/screen/movable/snap/S = new()
	S.name = "Snap UI Object"
	S.icon_state = "block"
	S.maptext = MAPTEXT("Snap")
	S.maptext_width = 64

	var/screen_l = input(usr, "Where on the screen? (Formatted as 'X,Y' e.g: '1,1' for bottom left)","Spawn Snap UI Object") as text|null
	if(!screen_l)
		return

	S.screen_loc = screen_l

	usr.client.screen += S

/// Debug verb for getting the weight of each distinct type within the random_hallucination_weighted_list
ADMIN_VERB(debug, show_hallucination_weights, "", R_DEBUG)
	var/header = "<tr><th>Type</th> <th>Weight</th> <th>Percent</th>"

	var/total_weight = debug_hallucination_weighted_list()
	var/list/all_weights = list()
	var/datum/hallucination/last_type
	var/last_type_weight = 0
	for(var/datum/hallucination/hallucination_type as anything in GLOB.random_hallucination_weighted_list)
		var/this_weight = GLOB.random_hallucination_weighted_list[hallucination_type]
		// Last_type is the abstract parent of the last hallucination type we iterated over
		if(last_type)
			// If this hallucination is the same path as the last type (subtype), add it to the total of the last type weight
			if(ispath(hallucination_type, last_type))
				last_type_weight += this_weight
				continue

			// Otherwise we moved onto the next hallucination subtype so we can stop
			else
				all_weights["<tr><td>[last_type]</td> <td>[last_type_weight] / [total_weight]</td> <td>[round(100 * (last_type_weight / total_weight), 0.01)]% chance</td></tr>"] = last_type_weight

		// Set last_type to the abstract parent of this hallucination
		last_type = initial(hallucination_type.abstract_hallucination_parent)
		// If last_type is the base hallucination it has no distinct subtypes so we can total it up immediately
		if(last_type == /datum/hallucination)
			all_weights["<tr><td>[hallucination_type]</td> <td>[this_weight] / [total_weight]</td> <td>[round(100 * (this_weight / total_weight), 0.01)]% chance</td></tr>"] = this_weight
			last_type = null

		// Otherwise we start the weight sum for the next entry here
		else
			last_type_weight = this_weight

	// Sort by weight descending, where weight is the values (not the keys). We assoc_to_keys later to get JUST the text
	all_weights = sortTim(all_weights, GLOBAL_PROC_REF(cmp_numeric_dsc), associative = TRUE)

	var/page_style = "<style>table, th, td {border: 1px solid black;border-collapse: collapse;}</style>"
	var/page_contents = "[page_style]<table style=\"width:100%\">[header][jointext(assoc_to_keys(all_weights), "")]</table>"
	var/datum/browser/popup = new(usr, "hallucinationdebug", "Hallucination Weights", 600, 400)
	popup.set_content(page_contents)
	popup.open()

ADMIN_VERB(debug, clear_dynamic_turf_reserverations, "Deallocates all reserved space, restoring it to round start conditions", R_DEBUG)
	if(length(SSmapping.loaded_lazy_templates))
		to_chat(usr, span_boldbig("WARNING, THERE ARE LOADED LAZY TEMPLATES, THIS WILL CAUSE THEM TO BE UNLOADED AND POTENTIALLY RUIN THE ROUND"))

	var/answer = tgui_alert(usr,"WARNING: THIS WILL WIPE ALL RESERVED SPACE TO A CLEAN SLATE! ANY MOVING SHUTTLES, ELEVATORS, OR IN-PROGRESS PHOTOGRAPHY WILL BE DELETED!", "Really wipe dynamic turfs?", list("YES", "NO"))
	if(answer != "YES")
		return

	message_admins(span_adminnotice("[key_name_admin(src)] cleared dynamic transit space."))
	log_admin("[key_name(src)] cleared dynamic transit space.")
	SSmapping.wipe_reservations() //this goes after it's logged, incase something horrible happens.

ADMIN_VERB(debug, toggle_medal_disable, "Toggles the safety lock on trying to contact the medal hub", R_DEBUG)
	SSachievements.achievements_enabled = !SSachievements.achievements_enabled
	message_admins(span_adminnotice("[key_name_admin(usr)] [SSachievements.achievements_enabled ? "disabled" : "enabled"] the medal hub lockout."))
	log_admin("[key_name(usr)] [SSachievements.achievements_enabled ? "disabled" : "enabled"] the medal hub lockout.")

ADMIN_VERB(debug, view_runtimes, "Opem the Runtime Viewer", R_DEBUG)
	GLOB.error_cache.show_to(usr)

	// The runtime viewer has the potential to crash the server if there's a LOT of runtimes
	// this has happened before, multiple times, so we'll just leave an alert on it
	if(GLOB.total_runtimes >= 50000) // arbitrary number, I don't know when exactly it happens
		var/warning = "There are a lot of runtimes, clicking any button (especially \"linear\") can have the potential to lag or crash the server"
		if(GLOB.total_runtimes >= 100000)
			warning = "There are a TON of runtimes, clicking any button (especially \"linear\") WILL LIKELY crash the server"
		// Not using TGUI alert, because it's view runtimes, stuff is probably broken
		alert(usr, "[warning]. Proceed with caution. If you really need to see the runtimes, download the runtime log and view it in a text editor.", "HEED THIS WARNING CAREFULLY MORTAL")

ADMIN_VERB(debug, pump_random_event, "Schedules the event subsystem to fire a new random event immediately. Some events may fire without notification", R_FUN)
	SSevents.scheduled = world.time
	message_admins(span_adminnotice("[key_name_admin(usr)] pumped a random event."))
	log_admin("[key_name(usr)] pumped a random event.")

ADMIN_VERB(debug, start_line_profiling, "Starts tracking line by line profiling for code lines that support it", R_DEBUG)
	LINE_PROFILE_START
	message_admins(span_adminnotice("[key_name_admin(src)] started line by line profiling."))
	log_admin("[key_name(src)] started line by line profiling.")

ADMIN_VERB(debug, stop_line_profiling, "Stops tracking line by line profiling for code lines that support it", R_DEBUG)
	LINE_PROFILE_STOP
	message_admins(span_adminnotice("[key_name_admin(src)] stopped line by line profiling."))
	log_admin("[key_name(src)] stopped line by line profiling.")

ADMIN_VERB(debug, show_line_profiling, "Shows tracked profiling info from code lines that support it", R_DEBUG)
	var/sortlist = list(
		"Avg time" = GLOBAL_PROC_REF(cmp_profile_avg_time_dsc),
		"Total Time" = GLOBAL_PROC_REF(cmp_profile_time_dsc),
		"Call Count" = GLOBAL_PROC_REF(cmp_profile_count_dsc)
	)
	var/sort = input(usr, "Sort type?", "Sort Type", "Avg time") as null|anything in sortlist
	if (!sort)
		return
	sort = sortlist[sort]
	profile_show(usr, sort)

ADMIN_VERB(debug, reload_configuration, "Force config reload to world default", R_DEBUG)
	if(tgui_alert(usr, "Are you absolutely sure you want to reload the configuration from the default path on the disk, wiping any in-round modificatoins?", "Really reset?", list("No", "Yes")) == "Yes")
		config.admin_reload()

ADMIN_VERB(debug, check_timer_sources, "Checks the sources of the running timers", R_DEBUG)
	var/bucket_list_output = generate_timer_source_output(SStimer.bucket_list)
	var/second_queue = generate_timer_source_output(SStimer.second_queue)

	usr << browse({"
		<h3>bucket_list</h3>
		[bucket_list_output]

		<h3>second_queue</h3>
		[second_queue]
	"}, "window=check_timer_sources;size=700x700")

/proc/generate_timer_source_output(list/datum/timedevent/events)
	var/list/per_source = list()

	// Collate all events and figure out what sources are creating the most
	for (var/_event in events)
		if (!_event)
			continue
		var/datum/timedevent/event = _event

		do
			if (event.source)
				if (per_source[event.source] == null)
					per_source[event.source] = 1
				else
					per_source[event.source] += 1
			event = event.next
		while (event && event != _event)

	// Now, sort them in order
	var/list/sorted = list()
	for (var/source in per_source)
		sorted += list(list("source" = source, "count" = per_source[source]))
	sorted = sortTim(sorted, GLOBAL_PROC_REF(cmp_timer_data))

	// Now that everything is sorted, compile them into an HTML output
	var/output = "<table border='1'>"

	for (var/_timer_data in sorted)
		var/list/timer_data = _timer_data
		output += {"<tr>
			<td><b>[timer_data["source"]]</b></td>
			<td>[timer_data["count"]]</td>
		</tr>"}

	output += "</table>"

	return output

/proc/cmp_timer_data(list/a, list/b)
	return b["count"] - a["count"]

#ifdef TESTING
ADMIN_VERB(debug, check_missing_sprites, "We're cancelling the Spritemageddon. (This will create a LOT of runtimes! Don't use on a live server!)", R_DEBUG)
	var/actual_file_name
	for(var/test_obj in subtypesof(/obj/item))
		var/obj/item/sprite = new test_obj
		if(!sprite.slot_flags || (sprite.item_flags & ABSTRACT))
			continue
		//Is there an explicit worn_icon to pick against the worn_icon_state? Easy street expected behavior.
		if(sprite.worn_icon)
			if(!(sprite.icon_state in icon_states(sprite.worn_icon)))
				to_chat(usr, span_warning("ERROR sprites for [sprite.type]. Slot Flags are [sprite.slot_flags]."), confidential = TRUE)
		else if(sprite.worn_icon_state)
			if(sprite.slot_flags & ITEM_SLOT_MASK)
				actual_file_name = 'icons/mob/clothing/mask.dmi'
				if(!(sprite.worn_icon_state in icon_states(actual_file_name)))
					to_chat(usr, span_warning("ERROR sprites for [sprite.type]. Mask slot."), confidential = TRUE)
			if(sprite.slot_flags & ITEM_SLOT_NECK)
				actual_file_name = 'icons/mob/clothing/neck.dmi'
				if(!(sprite.worn_icon_state in icon_states(actual_file_name)))
					to_chat(usr, span_warning("ERROR sprites for [sprite.type]. Neck slot."), confidential = TRUE)
			if(sprite.slot_flags & ITEM_SLOT_BACK)
				actual_file_name = 'icons/mob/clothing/back.dmi'
				if(!(sprite.worn_icon_state in icon_states(actual_file_name)))
					to_chat(usr, span_warning("ERROR sprites for [sprite.type]. Back slot."), confidential = TRUE)
			if(sprite.slot_flags & ITEM_SLOT_HEAD)
				actual_file_name = 'icons/mob/clothing/head/default.dmi'
				if(!(sprite.worn_icon_state in icon_states(actual_file_name)))
					to_chat(usr, span_warning("ERROR sprites for [sprite.type]. Head slot."), confidential = TRUE)
			if(sprite.slot_flags & ITEM_SLOT_BELT)
				actual_file_name = 'icons/mob/clothing/belt.dmi'
				if(!(sprite.worn_icon_state in icon_states(actual_file_name)))
					to_chat(usr, span_warning("ERROR sprites for [sprite.type]. Belt slot."), confidential = TRUE)
			if(sprite.slot_flags & ITEM_SLOT_SUITSTORE)
				actual_file_name = 'icons/mob/clothing/belt_mirror.dmi'
				if(!(sprite.worn_icon_state in icon_states(actual_file_name)))
					to_chat(usr, span_warning("ERROR sprites for [sprite.type]. Suit Storage slot."), confidential = TRUE)
		else if(sprite.icon_state)
			if(sprite.slot_flags & ITEM_SLOT_MASK)
				actual_file_name = 'icons/mob/clothing/mask.dmi'
				if(!(sprite.icon_state in icon_states(actual_file_name)))
					to_chat(usr, span_warning("ERROR sprites for [sprite.type]. Mask slot."), confidential = TRUE)
			if(sprite.slot_flags & ITEM_SLOT_NECK)
				actual_file_name = 'icons/mob/clothing/neck.dmi'
				if(!(sprite.icon_state in icon_states(actual_file_name)))
					to_chat(usr, span_warning("ERROR sprites for [sprite.type]. Neck slot."), confidential = TRUE)
			if(sprite.slot_flags & ITEM_SLOT_BACK)
				actual_file_name = 'icons/mob/clothing/back.dmi'
				if(!(sprite.icon_state in icon_states(actual_file_name)))
					to_chat(usr, span_warning("ERROR sprites for [sprite.type]. Back slot."), confidential = TRUE)
			if(sprite.slot_flags & ITEM_SLOT_HEAD)
				actual_file_name = 'icons/mob/clothing/head/default.dmi'
				if(!(sprite.icon_state in icon_states(actual_file_name)))
					to_chat(usr, span_warning("ERROR sprites for [sprite.type]. Head slot."), confidential = TRUE)
			if(sprite.slot_flags & ITEM_SLOT_BELT)
				actual_file_name = 'icons/mob/clothing/belt.dmi'
				if(!(sprite.icon_state in icon_states(actual_file_name)))
					to_chat(usr, span_warning("ERROR sprites for [sprite.type]. Belt slot."), confidential = TRUE)
			if(sprite.slot_flags & ITEM_SLOT_SUITSTORE)
				actual_file_name = 'icons/mob/clothing/belt_mirror.dmi'
				if(!(sprite.icon_state in icon_states(actual_file_name)))
					to_chat(usr, span_warning("ERROR sprites for [sprite.type]. Suit Storage slot."), confidential = TRUE)
#endif
