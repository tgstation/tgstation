/datum/computer_file/program/borg_monitor
	filename = "siliconnect"
	filedesc = "SiliConnect"
	ui_header = "borg_mon.gif"
	program_icon_state = "generic"
	extended_desc = "This program allows for remote monitoring of station cyborgs."
	requires_ntnet = TRUE
	transfer_access = ACCESS_ROBOTICS
	size = 5
	tgui_id = "NtosCyborgRemoteMonitor"
	program_icon = "project-diagram"
	var/emagged = FALSE

/datum/computer_file/program/borg_monitor/run_emag()
	if(emagged)
		return FALSE
	emagged = TRUE
	return TRUE

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
			locked_down = R.lockcharge,
			status = R.stat,
			shell_discon = shell,
			charge = R.cell ? round(R.cell.percent()) : null,
			module = R.model ? "[R.model.name] Model" : "No Model Detected",
			upgrades = upgrade,
			ref = REF(R)
		)
		data["cyborgs"] += list(cyborg_data)
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
				to_chat(usr, "<span class='warn'>Error -- Could not open a connection to unit:[R]</span>")
			var/message = stripped_input(usr, message = "Enter message to be sent to remote cyborg.", title = "Send Message")
			if(!message)
				return
			to_chat(R, "<br><br><span class='notice'>Message from [ID] -- \"[message]\"</span><br>")
			to_chat(usr, "Message sent to [R]: [message]")
			R.logevent("Message from [ID] -- \"[message]\"")
			SEND_SOUND(R, 'sound/machines/twobeep_high.ogg')
			if(R.connected_ai)
				to_chat(R.connected_ai, "<br><br><span class='notice'>Message from [ID] to [R] -- \"[message]\"</span><br>")
				SEND_SOUND(R.connected_ai, 'sound/machines/twobeep_high.ogg')
			usr.log_talk(message, LOG_PDA, tag="Cyborg Monitor Program: ID name \"[ID]\" to [R]")

///This proc is used to determin if a borg should be shown in the list (based on the borg's scrambledcodes var). Syndicate version overrides this to show only syndicate borgs.
/datum/computer_file/program/borg_monitor/proc/evaluate_borg(mob/living/silicon/robot/R)
	if((get_turf(computer)).z != (get_turf(R)).z)
		return FALSE
	if(R.scrambledcodes)
		return FALSE
	return TRUE

///Gets the ID's name, if one is inserted into the device. This is a seperate proc solely to be overridden by the syndicate version of the app.
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
