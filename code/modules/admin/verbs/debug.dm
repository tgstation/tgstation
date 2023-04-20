
ADMIN_VERB(debug_game, "Debug-Game", "Toggle debugging for the game.", R_DEBUG, VERB_CATEGORY_DEBUG)
	if(GLOB.Debug2)
		GLOB.Debug2 = FALSE
		message_admins("[key_name(user)] toggled debugging off.")
		log_admin("[key_name(user)] toggled debugging off.")
	else
		GLOB.Debug2 = TRUE
		message_admins("[key_name(user)] toggled debugging on.")
		log_admin("[key_name(user)] toggled debugging on.")

ADMIN_VERB_HIDDEN(air_status_here, "Air Status in Location", "View the air status for your current turf.", R_DEBUG, VERB_CATEGORY_DEBUG)
	atmos_scan(user=user.mob, target=get_turf(user.mob), silent=TRUE)

/client/proc/cmd_admin_robotize(mob/M in GLOB.mob_list)
	set category = "Admin.Fun"
	set name = "Make Cyborg"

	if(!SSticker.HasRoundStarted())
		tgui_alert(usr,"Wait until the game starts")
		return
	log_admin("[key_name(src)] has robotized [M.key].")
	INVOKE_ASYNC(M, TYPE_PROC_REF(/mob, Robotize))

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

ADMIN_VERB(del_all, "Del-All", "Delete all objects of a given type.", R_SERVER|R_DEBUG, VERB_CATEGORY_DEBUG, object as text)
	var/type_to_del = user.poll_type_to_del(object)
	if(!type_to_del)
		return

	var/counter = 0
	for(var/atom/O in world)
		if(istype(O, type_to_del))
			counter++
			qdel(O)
		CHECK_TICK
	log_admin("[key_name(user)] has deleted all ([counter]) instances of [type_to_del].")
	message_admins("[key_name_admin(user)] has deleted all ([counter]) instances of [type_to_del].")

ADMIN_VERB(del_all_force, "Force-Del-All", "Delete all objects of a given type, forcibly.", R_SERVER|R_DEBUG, VERB_CATEGORY_DEBUG, object as text)
	var/type_to_del = user.poll_type_to_del(object)
	if(!type_to_del)
		return

	var/counter = 0
	for(var/atom/O in world)
		if(istype(O, type_to_del))
			counter++
			qdel(O, force = TRUE)
		CHECK_TICK
	log_admin("[key_name(user)] has force-deleted all ([counter]) instances of [type_to_del].")
	message_admins("[key_name_admin(user)] has force-deleted all ([counter]) instances of [type_to_del].")

ADMIN_VERB(del_all_hard, "Hard-Del-All", "Delete all objects of a given type using byond's built in GC.", R_SERVER|R_DEBUG, VERB_CATEGORY_DEBUG, object as text)
	var/type_to_del = user.poll_type_to_del(object)
	if(!type_to_del)
		return

	var/choice = alert(user, "ARE YOU SURE that you want to hard delete this type? It will cause MASSIVE lag.", "Hoooo lad what happen?", "Yes", "No")
	if(choice != "Yes")
		return

	choice = alert(user, "Do you want to pre qdelete the atom? This will speed things up significantly, but may break depending on your level of fuckup.", "How do you even get it that bad", "Yes", "No")
	var/should_pre_qdel = TRUE
	if(choice == "No")
		should_pre_qdel = FALSE

	choice = alert(user, "Ok one last thing, do you want to yield to the game? or do it all at once. These are hard deletes remember.", "Jesus christ man", "Yield", "Ignore the server")
	var/should_check_tick = TRUE
	if(choice == "Ignore the server")
		should_check_tick = FALSE

	var/counter = 0
	if(should_check_tick)
		for(var/atom/O in world)
			if(istype(O, type_to_del))
				counter++
				if(should_pre_qdel)
					qdel(O)
				del(O)
			CHECK_TICK
	else
		for(var/atom/O in world)
			if(istype(O, type_to_del))
				counter++
				if(should_pre_qdel)
					qdel(O)
				del(O)
			CHECK_TICK
	log_admin("[key_name(user)] has hard deleted all ([counter]) instances of [type_to_del].")
	message_admins("[key_name_admin(user)] has hard deleted all ([counter]) instances of [type_to_del].")

ADMIN_VERB(make_powernets, "Make Powernets", "Forcibly recreates all powernets.", R_DEBUG, VERB_CATEGORY_DEBUG)
	SSmachines.makepowernets()
	log_admin("[key_name(user)] has remade the powernet. makepowernets() called.")
	message_admins("[key_name_admin(user)] has remade the powernets. makepowernets() called.")

/datum/admin_verb_holder/grant_full_access/starts_hidden = TRUE
ADMIN_VERB_CONTEXT_MENU(grant_full_access, "Grant Full Access", R_DEBUG, mob/living/carbon/human/target in world)
	if(!SSticker.HasRoundStarted())
		tgui_alert(user,"Wait until the game starts")
		return

	var/obj/item/worn = target.wear_id
	var/obj/item/card/id/id = worn?.GetID()
	if(!isnull(id))
		if(id == worn)
			worn = null
		qdel(id)

	id = new /obj/item/card/id/advanced/debug
	id.registered_name = target.real_name
	id.update_label()
	id.update_appearance()

	if(!isnull(worn))
		if(istype(worn, /obj/item/modular_computer/pda))
			worn.InsertID(id, target)

		else if(istype(worn, /obj/item/storage/wallet))
			var/obj/item/storage/wallet/wallet = worn
			wallet.front_id = id
			id.forceMove(wallet)
			wallet.update_appearance()

		else
			to_chat(user, "Couldn't figure out how to handle giving them the ID. Dropping it at their feet.")
			id.forceMove(target.drop_location())

	else
		target.equip_to_slot(id, ITEM_SLOT_ID)

	log_admin("[key_name(user)] has granted [key_name(target)] full access.")
	message_admins(span_adminnotice("[key_name_admin(user)] has granted [key_name_admin(target)] full access."))

/datum/admin_verb_holder/direct_control_take/starts_hidden = TRUE
ADMIN_VERB_CONTEXT_MENU(direct_control_take, "Assume Direct Control", R_ADMIN|R_DEBUG, mob/M in world)
	if(M.ckey)
		if(tgui_alert(user,"This mob is being controlled by [M.key]. Are you sure you wish to assume control of it? [M.key] will be made a ghost.",,list("Yes","No")) != "Yes")
			return
	if(!M || QDELETED(M))
		to_chat(user, span_warning("The target mob no longer exists."))
		return
	message_admins(span_adminnotice("[key_name_admin(user)] assumed direct control of [M]."))
	log_admin("[key_name(user)] assumed direct control of [M].")
	var/mob/adminmob = user.mob
	if(M.ckey)
		M.ghostize(FALSE)
	M.key = user.key
	user.init_verbs()
	if(isobserver(adminmob))
		qdel(adminmob)

/datum/admin_verb_holder/direct_control_give/starts_hidden = TRUE
ADMIN_VERB_CONTEXT_MENU(direct_control_give, "Give Direct Control", R_ADMIN|R_DEBUG, mob/M in world)
	if(M.ckey)
		if(tgui_alert(user,"This mob is being controlled by [M.key]. Are you sure you wish to give someone else control of it? [M.key] will be made a ghost.",,list("Yes","No")) != "Yes")
			return
	var/client/newkey = input(user, "Pick the player to put in control.", "New player") as null|anything in sort_list(GLOB.clients)
	var/mob/oldmob = newkey.mob
	var/delmob = FALSE
	if((isobserver(oldmob) || tgui_alert(user,"Do you want to delete [newkey]'s old mob?","Delete?",list("Yes","No")) != "No"))
		delmob = TRUE
	if(!M || QDELETED(M))
		to_chat(user, span_warning("The target mob no longer exists, aborting."))
		return
	if(M.ckey)
		M.ghostize(FALSE)
	M.ckey = newkey.key
	M.client?.init_verbs()
	if(delmob)
		qdel(oldmob)
	message_admins(span_adminnotice("[key_name_admin(user)] gave away direct control of [M] to [newkey]."))
	log_admin("[key_name(user)] gave away direct control of [M] to [newkey].")

/client/proc/cmd_admin_areatest(on_station, filter_maint)
	set category = "Mapping"
	set name = "Test Areas"

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

	for(var/obj/machinery/airalarm/AA in GLOB.air_alarms)
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

ADMIN_VERB_HIDDEN(area_test_station, "Test Areas (STATION ONLY)", "", R_DEBUG, VERB_CATEGORY_MAPPING)
	user.cmd_admin_areatest(TRUE)

ADMIN_VERB_HIDDEN(area_test_station_no_maintenence, "Test Areas (STATION - NO MAINT)", "", R_DEBUG, VERB_CATEGORY_MAPPING)
	user.cmd_admin_areatest(on_station = TRUE, filter_maint = TRUE)

ADMIN_VERB_HIDDEN(area_test_all, "Test Areas (ALL)", "", R_DEBUG, VERB_CATEGORY_MAPPING)
	user.cmd_admin_areatest(FALSE)

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

// why is this tucked away in the mapping verb list?
ADMIN_VERB_HIDDEN(rejuvenate, "Rejuvenate", "", R_DEBUG|R_ADMIN, VERB_CATEGORY_DEBUG, mob/living/M in world)
	M.revive(ADMIN_HEAL_ALL)
	log_admin("[key_name(user)] healed / revived [key_name(M)]")
	var/msg = span_danger("Admin [key_name_admin(user)] healed / revived [ADMIN_LOOKUPFLW(M)]!")
	message_admins(msg)
	admin_ticket_log(M, msg)

ADMIN_VERB_CONTEXT_MENU(delete, "Delete", R_SERVER|R_ADMIN|R_DEBUG|R_SPAWN, atom/target as obj|mob|turf in world)
	user.admin_delete(target)

ADMIN_VERB_CONTEXT_MENU(check_contents, "Check Contents", R_ADMIN|R_DEBUG, mob/living/target as mob in world)
	for(var/atom/movable/held as anything in target.get_contents())
		to_chat(user, "[held.name] [ADMIN_VV(held)] [ADMIN_TAG(held)]")

ADMIN_VERB(modify_goals, "Modify Goals", "View the station's goals and modify then.", R_ADMIN, VERB_CATEGORY_ADMIN)
	user.holder.modify_goals()

/datum/admins/proc/modify_goals()
	var/dat = ""
	for(var/datum/station_goal/S in GLOB.station_goals)
		dat += "[S.name] - <a href='?src=[REF(S)];[HrefToken()];announce=1'>Announce</a> | <a href='?src=[REF(S)];[HrefToken()];remove=1'>Remove</a><br>"
	dat += "<br><a href='?src=[REF(src)];[HrefToken()];add_station_goal=1'>Add New Goal</a>"
	usr << browse(dat, "window=goals;size=400x400")

ADMIN_VERB(debug_mob_lists, "Debug Mob Lists", "What broke this time.", R_DEBUG, VERB_CATEGORY_DEBUG)
	var/chosen_list = tgui_input_list(user, "Which list?", "Select List", list("Players","Admins","Mobs","Living Mobs","Dead Mobs","Clients","Joined Clients"))
	if(isnull(chosen_list))
		return
	switch(chosen_list)
		if("Players")
			to_chat(user, jointext(GLOB.player_list,","), confidential = TRUE)
		if("Admins")
			to_chat(user, jointext(GLOB.admins,","), confidential = TRUE)
		if("Mobs")
			to_chat(user, jointext(GLOB.mob_list,","), confidential = TRUE)
		if("Living Mobs")
			to_chat(user, jointext(GLOB.alive_mob_list,","), confidential = TRUE)
		if("Dead Mobs")
			to_chat(user, jointext(GLOB.dead_mob_list,","), confidential = TRUE)
		if("Clients")
			to_chat(user, jointext(GLOB.clients,","), confidential = TRUE)
		if("Joined Clients")
			to_chat(user, jointext(GLOB.joined_player_list,","), confidential = TRUE)

ADMIN_VERB(display_del_log, "Display Del Log", "Display the log which shows everything that has been deleted this round.", R_DEBUG, VERB_CATEGORY_DEBUG)
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
	user << browse(dellog.Join(), "window=dellog")

ADMIN_VERB(display_overlay_log, "Display Overlay Log", "Display the log of all overlays that have gone through SSoverlays.", R_DEBUG, VERB_CATEGORY_DEBUG)
	render_stats(SSoverlays.stats, user)

ADMIN_VERB(display_initialize_log, "Display Initialize Log", "Display the log of all datums that didn't Initialize properly.", R_DEBUG, VERB_CATEGORY_DEBUG)
	user << browse(replacetext(SSatoms.InitLog(), "\n", "<br>"), "window=initlog")

ADMIN_VERB(colorblind_test, "Coloring Testing", "Change your view to budget colorblindness to test for usability.", R_DEBUG, VERB_CATEGORY_DEBUG)
	user.holder.color_test.ui_interact(user.mob)

ADMIN_VERB(debug_plane_masters, "Edit/Debug Planes", "Edit and visualize plane masters and their connections (relays).", R_DEBUG, VERB_CATEGORY_DEBUG)
	user.edit_plane_masters()

/client/proc/edit_plane_masters(mob/debug_on)
	if(!holder)
		return
	if(debug_on)
		holder.plane_debug.set_mirroring(TRUE)
		holder.plane_debug.set_target(debug_on)
	else
		holder.plane_debug.set_mirroring(FALSE)
	holder.plane_debug.ui_interact(mob)

ADMIN_VERB(debug_huds, "Debug HUDs", "Debug the data or antag HUDs.", R_DEBUG, VERB_CATEGORY_DEBUG, hud_idx as num)
	hud_idx ||= tgui_input_number(
		user,
		"Hud index to debug?",
		"Debug HUDs",
		0,
		max_value = length(GLOB.huds),
	)
	if(!hud_idx)
		return

	SSadmin_verbs.dynamic_invoke_verb(src, /datum/admin_verb_holder/view_variables, GLOB.huds[hud_idx])

ADMIN_VERB(jump_to_ruin, "Jump to Ruin", "Displays a list of all placed ruins to teleport to.", R_DEBUG, VERB_CATEGORY_DEBUG)
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

	var/ruinname = input(user, "Select ruin", "Jump to Ruin") as null|anything in sort_list(names)
	var/obj/effect/landmark/ruin/landmark = names[ruinname]
	if(isnull(landmark))
		return

	var/datum/map_template/ruin/template = landmark.ruin_template
	if(!isobserver(user.mob))
		SSadmin_verbs.dynamic_invoke_verb(user, /datum/admin_verb_holder/admin_ghost)
	user.mob.forceMove(get_turf(landmark))
	to_chat(user, span_name("[template.name]"))
	to_chat(user, "<span class='italics'>[template.description]</span>")

ADMIN_VERB_HIDDEN(place_ruin, "Spawn Ruin", "Attempt to randomly place a specific ruin.", R_DEBUG, VERB_CATEGORY_MAPPING)
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

	var/ruinname = input(user, "Select ruin", "Spawn Ruin") as null|anything in names
	var/data = names[ruinname]
	if (!data)
		return
	var/datum/map_template/ruin/template = data[1]
	if (exists[template])
		var/response = tgui_alert(user,"There is already a [template] in existence.", "Spawn Ruin", list("Jump", "Place Another", "Cancel"))
		if (response == "Jump")
			user.mob.forceMove(get_turf(exists[template]))
			return
		else if (response == "Cancel")
			return

	var/len = GLOB.ruin_landmarks.len
	seedRuins(SSmapping.levels_by_trait(data[2]), max(1, template.cost), data[3], list(ruinname = template))
	if (GLOB.ruin_landmarks.len > len)
		var/obj/effect/landmark/ruin/landmark = GLOB.ruin_landmarks[GLOB.ruin_landmarks.len]
		log_admin("[key_name(user)] randomly spawned ruin [ruinname] at [COORD(landmark)].")
		usr.forceMove(get_turf(landmark))
		to_chat(user, span_name("[template.name]"), confidential = TRUE)
		to_chat(user, "<span class='italics'>[template.description]</span>", confidential = TRUE)
	else
		to_chat(user, span_warning("Failed to place [template.name]."), confidential = TRUE)

ADMIN_VERB(unload_ctf, "Unload CTF", "Despawn CTF.", R_DEBUG, VERB_CATEGORY_DEBUG)
	toggle_id_ctf(user.mob, CTF_GHOST_CTF_GAME_ID, unload=TRUE)

ADMIN_VERB(run_empty_queries, "Run Empty Query", "Run empty queries.", R_DEBUG, VERB_CATEGORY_DEBUG, amount as num)
	var/list/queries = list()
	for(var/i in 1 to amount)
		var/datum/db_query/query = SSdbcore.NewQuery("NULL")
		queries += query
		ASYNC
			query.Execute()

	for(var/datum/db_query/query as anything in queries)
		query.sync()
		qdel(query)
	queries.Cut()
	message_admins("[key_name_admin(user)] ran [amount] empty queries.")

ADMIN_VERB(clear_dynamic_transit, "Clear Dynamic Turf Reservations", "Deallocates all reserved space.", R_DEBUG, VERB_CATEGORY_DEBUG)
	var/answer = tgui_alert(
		user,
		"WARNING: THIS WILL WIPE ALL RESERVED SPACE TO A CLEAN SLATE! ANY MOVING SHUTTLES, LAZY TEMPLATES, ELEVATORS, OR IN-PROGRESS PHOTOGRAPHY WILL BE DELETED!",
		"Really wipe dynamic turfs?",
		list("Yes", "No"),
		)
	if(answer != "Yes")
		return

	if(length(SSmapping.loaded_lazy_templates))
		answer = tgui_alert(
			user,
			"WARNING: THERE ARE LOADED LAZY TEMPLATES, THIS WILL WIPE THEM TOO!",
			"Are you sure?",
			list("Yes", "No"),
			)
		if(answer != "Yes")
			return

	message_admins(span_adminnotice("[key_name_admin(user)] cleared dynamic transit space."))
	log_admin("[key_name(user)] cleared dynamic transit space.")
	SSmapping.wipe_reservations()

ADMIN_VERB(toggle_medal_disable, "Toggle Medal Disable", "Toggles the safety lock on trying to contact the medal hub.", R_DEBUG, VERB_CATEGORY_DEBUG)
	SSachievements.achievements_enabled = !SSachievements.achievements_enabled
	message_admins(span_adminnotice("[key_name_admin(user)] [SSachievements.achievements_enabled ? "disabled" : "enabled"] the medal hub lockout."))
	log_admin("[key_name(user)] [SSachievements.achievements_enabled ? "disabled" : "enabled"] the medal hub lockout.")

ADMIN_VERB(view_runtimes, "View Runtimes", "Open the Runtime Viewer.", R_DEBUG, VERB_CATEGORY_DEBUG)
	GLOB.error_cache.show_to(user)

	// The runtime viewer has the potential to crash the server if there's a LOT of runtimes
	// this has happened before, multiple times, so we'll just leave an alert on it
	if(GLOB.total_runtimes >= 50000) // arbitrary number, I don't know when exactly it happens
		var/warning = "There are a lot of runtimes, clicking any button (especially \"linear\") can have the potential to lag or crash the server"
		if(GLOB.total_runtimes >= 100000)
			warning = "There are a TON of runtimes, clicking any button (especially \"linear\") WILL LIKELY crash the server"
		// Not using TGUI alert, because it's view runtimes, stuff is probably broken
		alert(user, "[warning]. Proceed with caution. If you really need to see the runtimes, download the runtime log and view it in a text editor.", "HEED THIS WARNING CAREFULLY MORTAL")

ADMIN_VERB(pump_random_event, "Pump Random Event", "Schedules the event subsystem to fire a new random event immediately.", R_DEBUG, VERB_CATEGORY_DEBUG)
	SSevents.scheduled = world.time
	message_admins(span_adminnotice("[key_name_admin(user)] pumped a random event."))
	log_admin("[key_name(user)] pumped a random event.")

ADMIN_VERB_HIDDEN(line_profile_start, "Start Line Profiling", "Starts tracking line by line profiling for code lines that support it.", R_DEBUG, VERB_CATEGORY_DEBUG)
	LINE_PROFILE_START

	message_admins(span_adminnotice("[key_name_admin(user)] started line by line profiling."))
	log_admin("[key_name(user)] started line by line profiling.")

ADMIN_VERB_HIDDEN(line_profile_stop, "Stop Line Profiling", "Stops tracking line by line profiling.", R_DEBUG, VERB_CATEGORY_DEBUG)
	LINE_PROFILE_STOP

	message_admins(span_adminnotice("[key_name_admin(user)] stopped line by line profiling."))
	log_admin("[key_name(user)] stopped line by line profiling.")

ADMIN_VERB_HIDDEN(line_profile_show, "Show Line Profiling", "Shows tracked profiling info from tracked data.", R_DEBUG, VERB_CATEGORY_DEBUG)
	var/sortlist = list(
		"Avg time" = GLOBAL_PROC_REF(cmp_profile_avg_time_dsc),
		"Total Time" = GLOBAL_PROC_REF(cmp_profile_time_dsc),
		"Call Count" = GLOBAL_PROC_REF(cmp_profile_count_dsc)
	)
	var/sort = input(user, "Sort type?", "Sort Type", "Avg time") as null|anything in sortlist
	if (!sort)
		return
	sort = sortlist[sort]
	profile_show(user, sort)

ADMIN_VERB(reload_configuration, "Reload Configuration", "Force config reload to world default.", R_DEBUG|R_SERVER, VERB_CATEGORY_DEBUG)
	if(tgui_alert(user, "Are you absolutely sure you want to reload the configuration from the default path on the disk, wiping any in-round modifications?", "Really reset?", list("No", "Yes")) == "Yes")
		config.admin_reload()

ADMIN_VERB(check_timer_sources, "Check Timer Sources", "Checks the sources of running timers.", R_DEBUG, VERB_CATEGORY_DEBUG)
	var/bucket_list_output = generate_timer_source_output(SStimer.bucket_list)
	var/second_queue = generate_timer_source_output(SStimer.second_queue)

	user << browse({"
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
