/datum/computer_file/program/borg_monitor
	filename = "cyborgmonitor"
	filedesc = "Cyborg Remote Monitoring"
	ui_header = "borg_mon.gif"
	program_icon_state = "generic"
	extended_desc = "This program allows for remote monitoring of station cyborgs."
	requires_ntnet = TRUE
	transfer_access = ACCESS_ROBOTICS
	network_destination = "cyborg remote monitoring"
	size = 5
	tgui_id = "ntos_cyborg_monitor"
	ui_x = 600
	ui_y = 800

/datum/computer_file/program/borg_monitor/ui_data(mob/user)
	var/list/data = get_header_data()

	data["card"] = FALSE
	if(computer.GetID())
		data["card"] = TRUE

	data["cyborgs"] = list()
	for(var/mob/living/silicon/robot/R in GLOB.silicon_mobs)
		if((get_turf(computer)).z != (get_turf(R)).z)
			continue
		if(R.scrambledcodes)
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
			module = R.module ? "[R.module.name] Module" : "No Module Detected",
			upgrades = upgrade,
			ref = REF(R)
		)
		data["cyborgs"] += list(cyborg_data)
	return data

/datum/computer_file/program/borg_monitor/ui_act(action, params)
	if(..())
		return

	switch(action)
		if("messagebot")
			var/mob/living/silicon/robot/R = locate(params["ref"]) in GLOB.silicon_mobs
			if(!istype(R))
				return
			var/obj/item/card/id/ID = computer.GetID()
			if(!ID)
				return
			var/message = stripped_input(usr, message = "Enter message to be sent to remote cyborg.", title = "Send Message")
			if(!message)
				return
			to_chat(R, "<br><br><span class='notice'>Message from [ID.registered_name] -- \"[message]\"</span><br>")
			SEND_SOUND(R, 'sound/machines/twobeep_high.ogg')
			if(R.connected_ai)
				to_chat(R.connected_ai, "<br><br><span class='notice'>Message from [ID.registered_name] to [R] -- \"[message]\"</span><br>")
				SEND_SOUND(R.connected_ai, 'sound/machines/twobeep_high.ogg')
