/datum/computer_file/program/borg_monitor
	filename = "siliconnect"
	filedesc = "SiliConnect"
	category = PROGRAM_CATEGORY_ROBO
	ui_header = "borg_mon.gif"
	program_icon_state = "generic"
	extended_desc = "This program allows for remote monitoring of station cyborgs."
	requires_ntnet = TRUE
	transfer_access = ACCESS_ROBOTICS
	size = 5
	tgui_id = "NtosCyborgRemoteMonitor"
	program_icon = "project-diagram"
	var/emagged = FALSE ///Bool of if this app has already been emagged
	var/list/loglist = list() ///A list to copy a borg's IC log list into
	var/mob/living/silicon/robot/DL_source ///reference of a borg if we're downloading a log, or null if not.
	var/DL_progress = -1 ///Progress of current download, 0 to 100, -1 for no current download

/datum/computer_file/program/borg_monitor/Destroy()
	loglist = null
	DL_source = null
	return ..()

/datum/computer_file/program/borg_monitor/kill_program(forced = FALSE)
	loglist = null //Not everything is saved if you close an app
	DL_source = null
	DL_progress = 0
	return ..()

/datum/computer_file/program/borg_monitor/run_emag()
	if(emagged)
		return FALSE
	emagged = TRUE
	return TRUE

/datum/computer_file/program/borg_monitor/tap(atom/A, mob/living/user, params)
	var/mob/living/silicon/robot/borgo = A
	if(!istype(borgo) || !borgo.modularInterface)
		return FALSE
	DL_source = borgo
	DL_progress = 0

	var/username = "unknown user"
	var/obj/item/card/id/stored_card = computer.GetID()
	if(istype(stored_card) && stored_card.registered_name)
		username = "user [stored_card.registered_name]"
	to_chat(borgo, span_userdanger("Request received from [username] for the system log file. Upload in progress."))//Damning evidence may be contained, so warn the borg
	borgo.logevent("File request by [username]: /var/logs/syslog")
	return TRUE

/datum/computer_file/program/borg_monitor/process_tick()
	if(!DL_source)
		DL_progress = -1
		return

	var/turf/here = get_turf(computer)
	var/turf/there = get_turf(DL_source)
	if(!here.Adjacent(there))//If someone walked away, cancel the download
		to_chat(DL_source, span_danger("Log upload failed: general connection error."))//Let the borg know the upload stopped
		DL_source = null
		DL_progress = -1
		return

	if(DL_progress == 100)
		if(!DL_source || !DL_source.modularInterface) //sanity check, in case the borg or their modular tablet poofs somehow
			loglist = list("System log of unit [DL_source.name]")
			loglist += "Error -- Download corrupted."
		else
			loglist = DL_source.modularInterface.borglog.Copy()
			loglist.Insert(1,"System log of unit [DL_source.name]")
		DL_progress = -1
		DL_source = null
		for(var/datum/tgui/window in SStgui.open_uis_by_src[REF(src)])
			window.send_full_update()
		return

	DL_progress += 25

/datum/computer_file/program/borg_monitor/ui_data(mob/user)
	var/list/data = get_header_data()

	data["card"] = FALSE
	if(checkID())
		data["card"] = TRUE

	data["cyborgs"] = list()
	for(var/mob/living/silicon/robot/R in GLOB.silicon_mobs)
		if(!evaluate_borg(R))
			continue

		var/list/upgrade
		for(var/obj/item/borg/upgrade/I in R.upgrades)
			upgrade += "\[[I.name]\] "

		var/shell = FALSE
		if(R.shell && !R.ckey)
			shell = TRUE

		var/list/cyborg_data = list(
			name = R.name,
			integ = round((R.health + 100) / 2), //mob heath is -100 to 100, we want to scale that to 0 - 100
			locked_down = R.lockcharge,
			status = R.stat,
			shell_discon = shell,
			charge = R.cell ? round(R.cell.percent()) : null,
			module = R.model ? "[R.model.name] Model" : "No Model Detected",
			upgrades = upgrade,
			ref = REF(R)
		)
		data["cyborgs"] += list(cyborg_data)
		data["DL_progress"] = DL_progress
	return data

/datum/computer_file/program/borg_monitor/ui_static_data(mob/user)
	var/list/data = list()
	data["borglog"] = loglist
	return data

/datum/computer_file/program/borg_monitor/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("messagebot")
			var/mob/living/silicon/robot/R = locate(params["ref"]) in GLOB.silicon_mobs
			if(!istype(R))
				return
			var/ID = checkID()
			if(!ID)
				return
			if(R.stat == DEAD) //Dead borgs will listen to you no longer
				to_chat(usr, span_warning("Error -- Could not open a connection to unit:[R]"))
			var/message = tgui_input_text(usr, "Message to be sent to remote cyborg", "Send Message")
			if(!message)
				return
			to_chat(R, "<br><br>[span_notice("Message from [ID] -- \"[message]\"")]<br>")
			to_chat(usr, "Message sent to [R]: [message]")
			R.logevent("Message from [ID] -- \"[message]\"")
			SEND_SOUND(R, 'sound/machines/twobeep_high.ogg')
			if(R.connected_ai)
				to_chat(R.connected_ai, "<br><br>[span_notice("Message from [ID] to [R] -- \"[message]\"")]<br>")
				SEND_SOUND(R.connected_ai, 'sound/machines/twobeep_high.ogg')
			usr.log_talk(message, LOG_PDA, tag="Cyborg Monitor Program: ID name \"[ID]\" to [R]")

///This proc is used to determin if a borg should be shown in the list (based on the borg's scrambledcodes var). Syndicate version overrides this to show only syndicate borgs.
/datum/computer_file/program/borg_monitor/proc/evaluate_borg(mob/living/silicon/robot/R)
	if((get_turf(computer)).z != (get_turf(R)).z)
		return FALSE
	if(R.scrambledcodes)
		return FALSE
	return TRUE

///Gets the ID's name, if one is inserted into the device. This is a separate proc solely to be overridden by the syndicate version of the app.
/datum/computer_file/program/borg_monitor/proc/checkID()
	var/obj/item/card/id/ID = computer.GetID()
	if(!ID)
		if(emagged)
			return "STDERR:UNDF"
		return FALSE
	return ID.registered_name

/datum/computer_file/program/borg_monitor/syndicate
	filename = "roboverlord"
	filedesc = "Roboverlord"
	category = PROGRAM_CATEGORY_ROBO
	ui_header = "borg_mon.gif"
	program_icon_state = "generic"
	extended_desc = "This program allows for remote monitoring of mission-assigned cyborgs."
	requires_ntnet = FALSE
	available_on_ntnet = FALSE
	available_on_syndinet = TRUE
	transfer_access = null
	tgui_id = "NtosCyborgRemoteMonitorSyndicate"

/datum/computer_file/program/borg_monitor/syndicate/run_emag()
	return FALSE

/datum/computer_file/program/borg_monitor/syndicate/evaluate_borg(mob/living/silicon/robot/R)
	if((get_turf(computer)).z != (get_turf(R)).z)
		return FALSE
	if(!R.scrambledcodes)
		return FALSE
	return TRUE

/datum/computer_file/program/borg_monitor/syndicate/checkID()
	return "\[CLASSIFIED\]" //no ID is needed for the syndicate version's message function, and the borg will see "[CLASSIFIED]" as the message sender.
