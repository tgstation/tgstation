/client/proc/Debug2()
	set category = "Debug"
	set name = "Debug-Game"
	if(!check_rights(R_DEBUG))
		return

	if(GLOB.Debug2)
		GLOB.Debug2 = 0
		message_admins("[key_name(src)] toggled debugging off.")
		log_admin("[key_name(src)] toggled debugging off.")
	else
		GLOB.Debug2 = 1
		message_admins("[key_name(src)] toggled debugging on.")
		log_admin("[key_name(src)] toggled debugging on.")

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Toggle Debug Two") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!



/* 21st Sept 2010
Updated by Skie -- Still not perfect but better!
Stuff you can't do:
Call proc /mob/proc/Dizzy() for some player
Because if you select a player mob as owner it tries to do the proc for
/mob/living/carbon/human/ instead. And that gives a run-time error.
But you can call procs that are of type /mob/living/carbon/human/proc/ for that player.
*/

/client/proc/Cell()
	set category = "Debug"
	set name = "Air Status in Location"
	if(!mob)
		return
	var/turf/T = get_turf(mob)
	if(!isturf(T))
		return
	atmosanalyzer_scan(usr, T, TRUE)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Air Status In Location") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_robotize(mob/M in GLOB.mob_list)
	set category = "Admin.Fun"
	set name = "Make Cyborg"

	if(!SSticker.HasRoundStarted())
		tgui_alert(usr,"Wait until the game starts")
		return
	log_admin("[key_name(src)] has robotized [M.key].")
	INVOKE_ASYNC(M, /mob.proc/Robotize)

/client/proc/makepAI(turf/T in GLOB.mob_list)
	set category = "Admin.Fun"
	set name = "Make pAI"
	set desc = "Specify a location to spawn a pAI device, then specify a key to play that pAI"

	var/list/available = list()
	for(var/mob/C in GLOB.mob_list)
		if(C.key)
			available.Add(C)
	var/mob/choice = tgui_input_list(usr, "Choose a player to play the pAI", "Spawn pAI", sort_names(available))
	if(isnull(choice))
		return
	if(!isobserver(choice))
		var/confirm = tgui_alert(usr, "[choice.key] isn't ghosting right now. Are you sure you want to yank them out of their body and place them in this pAI?", "Spawn pAI Confirmation", list("Yes", "No"))
		if(confirm != "Yes")
			return
	var/obj/item/paicard/card = new(T)
	var/mob/living/silicon/pai/pai = new(card)

	var/chosen_name = input(choice, "Enter your pAI name:", "pAI Name", "Personal AI") as text|null

	if (isnull(chosen_name))
		return

	pai.name = chosen_name
	pai.real_name = pai.name
	pai.key = choice.key
	card.setPersonality(pai)
	for(var/datum/pai_candidate/candidate in SSpai.candidates)
		if(candidate.key == choice.key)
			SSpai.candidates.Remove(candidate)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Make pAI") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

//TODO: merge the vievars version into this or something maybe mayhaps
/client/proc/cmd_debug_del_all(object as text)
	set category = "Debug"
	set name = "Del-All"

	var/list/matches = get_fancy_list_of_atom_types()
	if (!isnull(object) && object!="")
		matches = filter_fancy_list(matches, object)

	if(matches.len==0)
		return
	var/hsbitem = input(usr, "Choose an object to delete.", "Delete:") as null|anything in sort_list(matches)
	if(hsbitem)
		hsbitem = matches[hsbitem]
		var/counter = 0
		for(var/atom/O in world)
			if(istype(O, hsbitem))
				counter++
				qdel(O)
			CHECK_TICK
		log_admin("[key_name(src)] has deleted all ([counter]) instances of [hsbitem].")
		message_admins("[key_name_admin(src)] has deleted all ([counter]) instances of [hsbitem].")
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Delete All") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/proc/cmd_debug_make_powernets()
	set category = "Debug"
	set name = "Make Powernets"
	SSmachines.makepowernets()
	log_admin("[key_name(src)] has remade the powernet. makepowernets() called.")
	message_admins("[key_name_admin(src)] has remade the powernets. makepowernets() called.")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Make Powernets") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_grantfullaccess(mob/M in GLOB.mob_list)
	set category = "Debug"
	set name = "Grant Full Access"

	if(!SSticker.HasRoundStarted())
		tgui_alert(usr,"Wait until the game starts")
		return
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/worn = H.wear_id
		var/obj/item/card/id/id = null

		if(worn)
			id = worn.GetID()
		if(id)
			if(id == worn)
				worn = null
			qdel(id)

		id = new /obj/item/card/id/advanced/debug()

		id.registered_name = H.real_name
		id.update_label()
		id.update_icon()

		if(worn)
			if(istype(worn, /obj/item/pda))
				var/obj/item/pda/PDA = worn
				PDA.id = id
				id.forceMove(PDA)
			else if(istype(worn, /obj/item/storage/wallet))
				var/obj/item/storage/wallet/W = worn
				W.front_id = id
				id.forceMove(W)
				W.update_icon()
		else
			H.equip_to_slot(id,ITEM_SLOT_ID)

	else
		tgui_alert(usr,"Invalid mob")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Grant Full Access") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	log_admin("[key_name(src)] has granted [M.key] full access.")
	message_admins(span_adminnotice("[key_name_admin(usr)] has granted [M.key] full access."))

/client/proc/cmd_assume_direct_control(mob/M in GLOB.mob_list)
	set category = "Admin.Game"
	set name = "Assume direct control"
	set desc = "Direct intervention"

	if(M.ckey)
		if(tgui_alert(usr,"This mob is being controlled by [M.key]. Are you sure you wish to assume control of it? [M.key] will be made a ghost.",,list("Yes","No")) != "Yes")
			return
	if(!M || QDELETED(M))
		to_chat(usr, span_warning("The target mob no longer exists."))
		return
	message_admins(span_adminnotice("[key_name_admin(usr)] assumed direct control of [M]."))
	log_admin("[key_name(usr)] assumed direct control of [M].")
	var/mob/adminmob = mob
	if(M.ckey)
		M.ghostize(FALSE)
	M.key = key
	init_verbs()
	if(isobserver(adminmob))
		qdel(adminmob)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Assume Direct Control") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_give_direct_control(mob/M in GLOB.mob_list)
	set category = "Admin.Game"
	set name = "Give direct control"

	if(!M)
		return
	if(M.ckey)
		if(tgui_alert(usr,"This mob is being controlled by [M.key]. Are you sure you wish to give someone else control of it? [M.key] will be made a ghost.",,list("Yes","No")) != "Yes")
			return
	var/client/newkey = input(src, "Pick the player to put in control.", "New player") as null|anything in sort_list(GLOB.clients)
	var/mob/oldmob = newkey.mob
	var/delmob = FALSE
	if((isobserver(oldmob) || tgui_alert(usr,"Do you want to delete [newkey]'s old mob?","Delete?",list("Yes","No")) != "No"))
		delmob = TRUE
	if(!M || QDELETED(M))
		to_chat(usr, span_warning("The target mob no longer exists, aborting."))
		return
	if(M.ckey)
		M.ghostize(FALSE)
	M.ckey = newkey.key
	M.client?.init_verbs()
	if(delmob)
		qdel(oldmob)
	message_admins(span_adminnotice("[key_name_admin(usr)] gave away direct control of [M] to [newkey]."))
	log_admin("[key_name(usr)] gave away direct control of [M] to [newkey].")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Give Direct Control") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_test_atmos_controllers()
	set category = "Mapping"
	set name = "Test Atmos Monitoring Consoles"

	var/list/dat = list()

	if(SSticker.current_state == GAME_STATE_STARTUP)
		to_chat(usr, "Game still loading, please hold!", confidential = TRUE)
		return

	message_admins(span_adminnotice("[key_name_admin(usr)] used the Test Atmos Monitor debug command."))
	log_admin("[key_name(usr)] used the Test Atmos Monitor debug command.")

	var/bad_shit = 0
	for(var/obj/machinery/computer/atmos_control/tank/console in GLOB.atmos_air_controllers)
		dat += "<h1>[console] at [AREACOORD(console)]:</h1><br>"
		if(console.input_tag == console.output_tag)
			dat += "Error: input_tag is the same as the output_tag, \"[console.input_tag]\"!<br>"
			bad_shit++
		if(!LAZYLEN(console.input_info))
			dat += "Failed to find a valid outlet injector as an input with the tag [console.input_tag].<br>"
			bad_shit++
		if(!LAZYLEN(console.output_info))
			dat += "Failed to find a valid siphon pump as an outlet with the tag [console.output_tag].<br>"
			bad_shit++
		if(!bad_shit)
			dat += "<B>STATUS:</B> NORMAL"
		else
			bad_shit = 0
		dat += "<br>"
		CHECK_TICK

	var/datum/browser/popup = new(usr, "testatmoscontroller", "Test Atmos Monitoring Consoles", 500, 750)
	popup.set_content(dat.Join())
	popup.open()

/client/proc/cmd_admin_areatest(on_station)
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
	var/static/list/station_areas_blacklist = typecacheof(list(/area/holodeck/rec_center, /area/shuttle, /area/engineering/supermatter, /area/science/test_area, /area/space, /area/solars, /area/mine, /area/ruin, /area/asteroid))

	if(SSticker.current_state == GAME_STATE_STARTUP)
		to_chat(usr, "Game still loading, please hold!", confidential = TRUE)
		return

	var/log_message
	if(on_station)
		dat += "<b>Only checking areas on station z-levels.</b><br><br>"
		log_message = "station z-levels"
	else
		log_message = "all z-levels"

	message_admins(span_adminnotice("[key_name_admin(usr)] used the Test Areas debug command checking [log_message]."))
	log_admin("[key_name(usr)] used the Test Areas debug command checking [log_message].")

	for(var/area/A in world)
		if(on_station)
			var/list/area_turfs = get_area_turfs(A.type)
			if (!length(area_turfs))
				continue
			var/turf/picked = pick(area_turfs)
			if(is_station_level(picked.z))
				if(!(A.type in areas_all) && !is_type_in_typecache(A, station_areas_blacklist))
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

	for(var/obj/machinery/requests_console/RC in GLOB.machines)
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

	for(var/obj/item/radio/intercom/I in GLOB.machines)
		var/area/A = get_area(I)
		if(!A)
			dat += "Skipped over [I] in invalid location, [I.loc].<br>"
			continue
		if(!(A.type in areas_with_intercom))
			areas_with_intercom.Add(A.type)
		CHECK_TICK

	for(var/obj/machinery/camera/C in GLOB.machines)
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


/client/proc/cmd_admin_areatest_station()
	set category = "Mapping"
	set name = "Test Areas (STATION Z)"
	cmd_admin_areatest(TRUE)

/client/proc/cmd_admin_areatest_all()
	set category = "Mapping"
	set name = "Test Areas (ALL)"
	cmd_admin_areatest(FALSE)

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

/client/proc/cmd_admin_rejuvenate(mob/living/M in GLOB.mob_list)
	set category = "Debug"
	set name = "Rejuvenate"

	if(!check_rights(R_ADMIN))
		return

	if(!mob)
		return
	if(!istype(M))
		tgui_alert(usr,"Cannot revive a ghost")
		return
	M.revive(full_heal = TRUE, admin_revive = TRUE)

	log_admin("[key_name(usr)] healed / revived [key_name(M)]")
	var/msg = span_danger("Admin [key_name_admin(usr)] healed / revived [ADMIN_LOOKUPFLW(M)]!")
	message_admins(msg)
	admin_ticket_log(M, msg)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Rejuvenate") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_delete(atom/A as obj|mob|turf in world)
	set category = "Debug"
	set name = "Delete"

	if(!check_rights(R_SPAWN|R_DEBUG))
		return

	admin_delete(A)

/client/proc/cmd_admin_check_contents(mob/living/M in GLOB.mob_list)
	set category = "Debug"
	set name = "Check Contents"

	var/list/L = M.get_contents()
	for(var/t in L)
		to_chat(usr, "[t]", confidential = TRUE)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Check Contents") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/modify_goals()
	set category = "Debug"
	set name = "Modify goals"

	if(!check_rights(R_ADMIN))
		return

	holder.modify_goals()

/datum/admins/proc/modify_goals()
	var/dat = ""
	for(var/datum/station_goal/S in GLOB.station_goals)
		dat += "[S.name] - <a href='?src=[REF(S)];[HrefToken()];announce=1'>Announce</a> | <a href='?src=[REF(S)];[HrefToken()];remove=1'>Remove</a><br>"
	dat += "<br><a href='?src=[REF(src)];[HrefToken()];add_station_goal=1'>Add New Goal</a>"
	usr << browse(dat, "window=goals;size=400x400")

/client/proc/cmd_debug_mob_lists()
	set category = "Debug"
	set name = "Debug Mob Lists"
	set desc = "For when you just gotta know"
	var/chosen_list = tgui_input_list(usr, "Which list?", "Select List", list("Players","Admins","Mobs","Living Mobs","Dead Mobs","Clients","Joined Clients"))
	if(isnull(chosen_list))
		return
	switch(chosen_list)
		if("Players")
			to_chat(usr, jointext(GLOB.player_list,","), confidential = TRUE)
		if("Admins")
			to_chat(usr, jointext(GLOB.admins,","), confidential = TRUE)
		if("Mobs")
			to_chat(usr, jointext(GLOB.mob_list,","), confidential = TRUE)
		if("Living Mobs")
			to_chat(usr, jointext(GLOB.alive_mob_list,","), confidential = TRUE)
		if("Dead Mobs")
			to_chat(usr, jointext(GLOB.dead_mob_list,","), confidential = TRUE)
		if("Clients")
			to_chat(usr, jointext(GLOB.clients,","), confidential = TRUE)
		if("Joined Clients")
			to_chat(usr, jointext(GLOB.joined_player_list,","), confidential = TRUE)

/client/proc/cmd_display_del_log()
	set category = "Debug"
	set name = "Display del() Log"
	set desc = "Display del's log of everything that's passed through it."

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

/client/proc/cmd_display_overlay_log()
	set category = "Debug"
	set name = "Display overlay Log"
	set desc = "Display SSoverlays log of everything that's passed through it."

	render_stats(SSoverlays.stats, src)

/client/proc/cmd_display_init_log()
	set category = "Debug"
	set name = "Display Initialize() Log"
	set desc = "Displays a list of things that didn't handle Initialize() properly"

	usr << browse(replacetext(SSatoms.InitLog(), "\n", "<br>"), "window=initlog")

/client/proc/debug_huds(i as num)
	set category = "Debug"
	set name = "Debug HUDs"
	set desc = "Debug the data or antag HUDs"

	if(!holder)
		return
	debug_variables(GLOB.huds[i])

/client/proc/jump_to_ruin()
	set category = "Debug"
	set name = "Jump to Ruin"
	set desc = "Displays a list of all placed ruins to teleport to."
	if(!holder)
		return
	var/list/names = list()
	for(var/i in GLOB.ruin_landmarks)
		var/obj/effect/landmark/ruin/ruin_landmark = i
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
		usr.forceMove(get_turf(landmark))
		to_chat(usr, span_name("[template.name]"), confidential = TRUE)
		to_chat(usr, "<span class='italics'>[template.description]</span>", confidential = TRUE)

/client/proc/place_ruin()
	set category = "Debug"
	set name = "Spawn Ruin"
	set desc = "Attempt to randomly place a specific ruin."
	if (!holder)
		return

	var/list/exists = list()
	for(var/landmark in GLOB.ruin_landmarks)
		var/obj/effect/landmark/ruin/L = landmark
		exists[L.ruin_template] = landmark

	var/list/names = list()
	names += "---- Space Ruins ----"
	for(var/name in SSmapping.space_ruins_templates)
		names[name] = list(SSmapping.space_ruins_templates[name], ZTRAIT_SPACE_RUINS, list(/area/space))
	names += "---- Lava Ruins ----"
	for(var/name in SSmapping.lava_ruins_templates)
		names[name] = list(SSmapping.lava_ruins_templates[name], ZTRAIT_LAVA_RUINS, list(/area/lavaland/surface/outdoors/unexplored))
	names += "---- Ice Ruins ----"
	for(var/name in SSmapping.ice_ruins_templates)
		names[name] = list(SSmapping.ice_ruins_templates[name], ZTRAIT_ICE_RUINS, list(/area/icemoon/surface/outdoors/unexplored, /area/icemoon/underground/unexplored))
	names += "---- Ice Underground Ruins ----"
	for(var/name in SSmapping.ice_ruins_underground_templates)
		names[name] = list(SSmapping.ice_ruins_underground_templates[name], ZTRAIT_ICE_RUINS_UNDERGROUND, list(/area/icemoon/underground/unexplored))

	var/ruinname = input("Select ruin", "Spawn Ruin") as null|anything in sort_list(names)
	var/data = names[ruinname]
	if (!data)
		return
	var/datum/map_template/ruin/template = data[1]
	if (exists[template])
		var/response = tgui_alert(usr,"There is already a [template] in existence.", "Spawn Ruin", list("Jump", "Place Another", "Cancel"))
		if (response == "Jump")
			usr.forceMove(get_turf(exists[template]))
			return
		else if (response == "Cancel")
			return

	var/len = GLOB.ruin_landmarks.len
	seedRuins(SSmapping.levels_by_trait(data[2]), max(1, template.cost), data[3], list(ruinname = template))
	if (GLOB.ruin_landmarks.len > len)
		var/obj/effect/landmark/ruin/landmark = GLOB.ruin_landmarks[GLOB.ruin_landmarks.len]
		log_admin("[key_name(src)] randomly spawned ruin [ruinname] at [COORD(landmark)].")
		usr.forceMove(get_turf(landmark))
		to_chat(src, span_name("[template.name]"), confidential = TRUE)
		to_chat(src, "<span class='italics'>[template.description]</span>", confidential = TRUE)
	else
		to_chat(src, span_warning("Failed to place [template.name]."), confidential = TRUE)

/client/proc/run_empty_query(val as num)
	set category = "Debug"
	set name = "Run empty query"
	set desc = "Amount of queries to run"

	var/list/queries = list()
	for(var/i in 1 to val)
		var/datum/db_query/query = SSdbcore.NewQuery("NULL")
		INVOKE_ASYNC(query, /datum/db_query.proc/Execute)
		queries += query

	for(var/datum/db_query/query as anything in queries)
		query.sync()
		qdel(query)
	queries.Cut()

	message_admins("[key_name_admin(src)] ran [val] empty queries.")

/client/proc/clear_dynamic_transit()
	set category = "Debug"
	set name = "Clear Dynamic Turf Reservations"
	set desc = "Deallocates all reserved space, restoring it to round start conditions."
	if(!holder)
		return
	var/answer = tgui_alert(usr,"WARNING: THIS WILL WIPE ALL RESERVED SPACE TO A CLEAN SLATE! ANY MOVING SHUTTLES, ELEVATORS, OR IN-PROGRESS PHOTOGRAPHY WILL BE DELETED!", "Really wipe dynamic turfs?", list("YES", "NO"))
	if(answer != "YES")
		return
	message_admins(span_adminnotice("[key_name_admin(src)] cleared dynamic transit space."))
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Clear Dynamic Transit") // If...
	log_admin("[key_name(src)] cleared dynamic transit space.")
	SSmapping.wipe_reservations() //this goes after it's logged, incase something horrible happens.

/client/proc/toggle_medal_disable()
	set category = "Debug"
	set name = "Toggle Medal Disable"
	set desc = "Toggles the safety lock on trying to contact the medal hub."

	if(!check_rights(R_DEBUG))
		return

	SSachievements.achievements_enabled = !SSachievements.achievements_enabled

	message_admins(span_adminnotice("[key_name_admin(src)] [SSachievements.achievements_enabled ? "disabled" : "enabled"] the medal hub lockout."))
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Toggle Medal Disable") // If...
	log_admin("[key_name(src)] [SSachievements.achievements_enabled ? "disabled" : "enabled"] the medal hub lockout.")

/client/proc/view_runtimes()
	set category = "Debug"
	set name = "View Runtimes"
	set desc = "Open the runtime Viewer"

	if(!holder)
		return

	GLOB.error_cache.show_to(src)

/client/proc/pump_random_event()
	set category = "Debug"
	set name = "Pump Random Event"
	set desc = "Schedules the event subsystem to fire a new random event immediately. Some events may fire without notification."
	if(!holder)
		return

	SSevents.scheduled = world.time

	message_admins(span_adminnotice("[key_name_admin(src)] pumped a random event."))
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Pump Random Event")
	log_admin("[key_name(src)] pumped a random event.")

/client/proc/start_line_profiling()
	set category = "Profile"
	set name = "Start Line Profiling"
	set desc = "Starts tracking line by line profiling for code lines that support it"

	LINE_PROFILE_START

	message_admins(span_adminnotice("[key_name_admin(src)] started line by line profiling."))
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Start Line Profiling")
	log_admin("[key_name(src)] started line by line profiling.")

/client/proc/stop_line_profiling()
	set category = "Profile"
	set name = "Stops Line Profiling"
	set desc = "Stops tracking line by line profiling for code lines that support it"

	LINE_PROFILE_STOP

	message_admins(span_adminnotice("[key_name_admin(src)] stopped line by line profiling."))
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Stop Line Profiling")
	log_admin("[key_name(src)] stopped line by line profiling.")

/client/proc/show_line_profiling()
	set category = "Profile"
	set name = "Show Line Profiling"
	set desc = "Shows tracked profiling info from code lines that support it"

	var/sortlist = list(
		"Avg time" = /proc/cmp_profile_avg_time_dsc,
		"Total Time" = /proc/cmp_profile_time_dsc,
		"Call Count" = /proc/cmp_profile_count_dsc
	)
	var/sort = input(src, "Sort type?", "Sort Type", "Avg time") as null|anything in sortlist
	if (!sort)
		return
	sort = sortlist[sort]
	profile_show(src, sort)

/client/proc/reload_configuration()
	set category = "Debug"
	set name = "Reload Configuration"
	set desc = "Force config reload to world default"
	if(!check_rights(R_DEBUG))
		return
	if(tgui_alert(usr, "Are you absolutely sure you want to reload the configuration from the default path on the disk, wiping any in-round modificatoins?", "Really reset?", list("No", "Yes")) == "Yes")
		config.admin_reload()

/// A debug verb to check the sources of currently running timers
/client/proc/check_timer_sources()
	set category = "Debug"
	set name = "Check Timer Sources"
	set desc = "Checks the sources of the running timers"
	if (!check_rights(R_DEBUG))
		return

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
	sorted = sortTim(sorted, .proc/cmp_timer_data)

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
/client/proc/check_missing_sprites()
	set category = "Debug"
	set name = "Debug Worn Item Sprites"
	set desc = "We're cancelling the Spritemageddon. (This will create a LOT of runtimes! Don't use on a live server!)"
	var/actual_file_name
	for(var/test_obj in subtypesof(/obj/item))
		var/obj/item/sprite = new test_obj
		if(!sprite.slot_flags || (sprite.item_flags & ABSTRACT))
			continue
		//Is there an explicit worn_icon to pick against the worn_icon_state? Easy street expected behavior.
		if(sprite.worn_icon)
			if(!(sprite.icon_state in icon_states(sprite.worn_icon)))
				to_chat(src, span_warning("ERROR sprites for [sprite.type]. Slot Flags are [sprite.slot_flags]."), confidential = TRUE)
		else if(sprite.worn_icon_state)
			if(sprite.slot_flags & ITEM_SLOT_MASK)
				actual_file_name = 'icons/mob/clothing/mask.dmi'
				if(!(sprite.worn_icon_state in icon_states(actual_file_name)))
					to_chat(src, span_warning("ERROR sprites for [sprite.type]. Mask slot."), confidential = TRUE)
			if(sprite.slot_flags & ITEM_SLOT_NECK)
				actual_file_name = 'icons/mob/clothing/neck.dmi'
				if(!(sprite.worn_icon_state in icon_states(actual_file_name)))
					to_chat(src, span_warning("ERROR sprites for [sprite.type]. Neck slot."), confidential = TRUE)
			if(sprite.slot_flags & ITEM_SLOT_BACK)
				actual_file_name = 'icons/mob/clothing/back.dmi'
				if(!(sprite.worn_icon_state in icon_states(actual_file_name)))
					to_chat(src, span_warning("ERROR sprites for [sprite.type]. Back slot."), confidential = TRUE)
			if(sprite.slot_flags & ITEM_SLOT_HEAD)
				actual_file_name = 'icons/mob/clothing/head.dmi'
				if(!(sprite.worn_icon_state in icon_states(actual_file_name)))
					to_chat(src, span_warning("ERROR sprites for [sprite.type]. Head slot."), confidential = TRUE)
			if(sprite.slot_flags & ITEM_SLOT_BELT)
				actual_file_name = 'icons/mob/clothing/belt.dmi'
				if(!(sprite.worn_icon_state in icon_states(actual_file_name)))
					to_chat(src, span_warning("ERROR sprites for [sprite.type]. Belt slot."), confidential = TRUE)
			if(sprite.slot_flags & ITEM_SLOT_SUITSTORE)
				actual_file_name = 'icons/mob/clothing/belt_mirror.dmi'
				if(!(sprite.worn_icon_state in icon_states(actual_file_name)))
					to_chat(src, span_warning("ERROR sprites for [sprite.type]. Suit Storage slot."), confidential = TRUE)
		else if(sprite.icon_state)
			if(sprite.slot_flags & ITEM_SLOT_MASK)
				actual_file_name = 'icons/mob/clothing/mask.dmi'
				if(!(sprite.icon_state in icon_states(actual_file_name)))
					to_chat(src, span_warning("ERROR sprites for [sprite.type]. Mask slot."), confidential = TRUE)
			if(sprite.slot_flags & ITEM_SLOT_NECK)
				actual_file_name = 'icons/mob/clothing/neck.dmi'
				if(!(sprite.icon_state in icon_states(actual_file_name)))
					to_chat(src, span_warning("ERROR sprites for [sprite.type]. Neck slot."), confidential = TRUE)
			if(sprite.slot_flags & ITEM_SLOT_BACK)
				actual_file_name = 'icons/mob/clothing/back.dmi'
				if(!(sprite.icon_state in icon_states(actual_file_name)))
					to_chat(src, span_warning("ERROR sprites for [sprite.type]. Back slot."), confidential = TRUE)
			if(sprite.slot_flags & ITEM_SLOT_HEAD)
				actual_file_name = 'icons/mob/clothing/head.dmi'
				if(!(sprite.icon_state in icon_states(actual_file_name)))
					to_chat(src, span_warning("ERROR sprites for [sprite.type]. Head slot."), confidential = TRUE)
			if(sprite.slot_flags & ITEM_SLOT_BELT)
				actual_file_name = 'icons/mob/clothing/belt.dmi'
				if(!(sprite.icon_state in icon_states(actual_file_name)))
					to_chat(src, span_warning("ERROR sprites for [sprite.type]. Belt slot."), confidential = TRUE)
			if(sprite.slot_flags & ITEM_SLOT_SUITSTORE)
				actual_file_name = 'icons/mob/clothing/belt_mirror.dmi'
				if(!(sprite.icon_state in icon_states(actual_file_name)))
					to_chat(src, span_warning("ERROR sprites for [sprite.type]. Suit Storage slot."), confidential = TRUE)
#endif
