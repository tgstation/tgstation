#define STATE_DEFAULT	1
#define STATE_MESSAGELIST	2
#define STATE_VIEWMESSAGE	3
#define STATE_STATUSDISPLAY	4
#define STATE_ALERT_LEVEL	5
/datum/computer_file/program/comm
	filename = "comm"
	filedesc = "Command and communications program."
	program_icon_state = "comm"
	nanomodule_path = /datum/nano_module/program/comm
	extended_desc = "Used to command and control the station. Can relay long-range communications. This program can not be run on tablet computers."
	required_access = access_heads
	requires_ntnet = 1
	size = 12
	usage_flags = PROGRAM_CONSOLE | PROGRAM_LAPTOP
	network_destination = "station long-range communication array"
	var/datum/comm_message_listener/message_core = new

/datum/computer_file/program/comm/clone()
	var/datum/computer_file/program/comm/temp = ..()
	temp.message_core.messages = null
	temp.message_core.messages = message_core.messages.Copy()
	return temp

/datum/nano_module/program/comm
	name = "Command and communications program"
	available_to_ai = TRUE
	var/current_status = STATE_DEFAULT
	var/msg_line1 = ""
	var/msg_line2 = ""
	var/centcomm_message_cooldown = 0
	var/announcment_cooldown = 0
	var/datum/announcement/priority/crew_announcement = new
	var/current_viewing_message_id = 0
	var/current_viewing_message = null

/datum/nano_module/program/comm/New()
	..()
	crew_announcement.newscast = 1

/datum/nano_module/program/comm/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1, var/datum/topic_state/state = default_state)
	var/list/data = host.initial_data()

	if(program)
		data["emagged"] = program.computer_emagged
		data["net_comms"] = !!program.get_signal(NTNET_COMMUNICATION) //Double !! is needed to get 1 or 0 answer
		data["net_syscont"] = !!program.get_signal(NTNET_SYSTEMCONTROL)
		if(program.computer)
			data["have_printer"] = !!program.computer.nano_printer
		else
			data["have_printer"] = 0
	else
		data["emagged"] = 0
		data["net_comms"] = 1
		data["net_syscont"] = 1
		data["have_printer"] = 0

	data["message_line1"] = msg_line1
	data["message_line2"] = msg_line2
	data["state"] = current_status
	data["isAI"] = issilicon(usr)
	data["authenticated"] = is_autenthicated(user)
	data["boss_short"] = boss_short
	data["current_security_level"] = security_level
	data["current_security_level_title"] = num2seclevel(security_level)

	data["def_SEC_LEVEL_DELTA"] = SEC_LEVEL_DELTA
	data["def_SEC_LEVEL_BLUE"] = SEC_LEVEL_BLUE
	data["def_SEC_LEVEL_GREEN"] = SEC_LEVEL_GREEN

	var/datum/comm_message_listener/l = obtain_message_listener()
	data["messages"] = l.messages
	data["message_deletion_allowed"] = l != global_message_listener
	data["message_current_id"] = current_viewing_message_id
	if(current_viewing_message)
		data["message_current"] = current_viewing_message

	if(emergency_shuttle.location())
		data["have_shuttle"] = 1
		if(emergency_shuttle.online())
			data["have_shuttle_called"] = 1
		else
			data["have_shuttle_called"] = 0
	else
		data["have_shuttle"] = 0

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "communication.tmpl", name, 550, 420, state = state)
		ui.auto_update_layout = 1
		ui.set_initial_data(data)
		ui.open()

/datum/nano_module/program/comm/proc/is_autenthicated(var/mob/user)
	if(program)
		return program.can_run(user)
	return 1

/datum/nano_module/program/comm/proc/obtain_message_listener()
	if(program)
		var/datum/computer_file/program/comm/P = program
		return P.message_core
	return global_message_listener

/datum/nano_module/program/comm/Topic(href, href_list)
	if(..())
		return 1
	var/mob/user = usr
	var/ntn_comm = program ? !!program.get_signal(NTNET_COMMUNICATION) : 1
	var/ntn_cont = program ? !!program.get_signal(NTNET_SYSTEMCONTROL) : 1
	var/datum/comm_message_listener/l = obtain_message_listener()
	switch(href_list["action"])
		if("sw_menu")
			. = 1
			current_status = text2num(href_list["target"])
		if("announce")
			. = 1
			if(is_autenthicated(user) && !issilicon(usr) && ntn_comm)
				if(user)
					var/obj/item/weapon/card/id/id_card = user.GetIdCard()
					crew_announcement.announcer = GetNameAndAssignmentFromId(id_card)
				else
					crew_announcement.announcer = "Unknown"
				if(announcment_cooldown)
					usr << "Please allow at least one minute to pass between announcements"
					return TRUE
				var/input = input(usr, "Please write a message to announce to the station crew.", "Priority Announcement") as null|text
				if(!input || !can_still_topic())
					return 1
				crew_announcement.Announce(input)
				announcment_cooldown = 1
				spawn(600)//One minute cooldown
					announcment_cooldown = 0
		if("message")
			. = 1
			if(href_list["target"] == "emagged")
				if(program)
					if(is_autenthicated(user) && program.computer_emagged && !issilicon(usr) && ntn_comm)
						if(centcomm_message_cooldown)
							usr << "<span class='warning'>Arrays recycling. Please stand by.</span>"
							nanomanager.update_uis(src)
							return
						var/input = sanitize(input(usr, "Please choose a message to transmit to \[ABNORMAL ROUTING CORDINATES\] via quantum entanglement.  Please be aware that this process is very expensive, and abuse will lead to... termination. Transmission does not guarantee a response. There is a 30 second delay before you may send another message, be clear, full and concise.", "To abort, send an empty message.", "") as null|text)
						if(!input || !can_still_topic())
							return 1
						Syndicate_announce(input, usr)
						usr << "<span class='notice'>Message transmitted.</span>"
						log_say("[key_name(usr)] has made an illegal announcement: [input]")
						centcomm_message_cooldown = 1
						spawn(300)//30 second cooldown
							centcomm_message_cooldown = 0
			else if(href_list["target"] == "regular")
				if(is_autenthicated(user) && !issilicon(usr) && ntn_comm)
					if(centcomm_message_cooldown)
						usr << "<span class='warning'>Arrays recycling. Please stand by.</span>"
						nanomanager.update_uis(src)
						return
					if(!is_relay_online())//Contact Centcom has a check, Syndie doesn't to allow for Traitor funs.
						usr <<"<span class='warning'>No Emergency Bluespace Relay detected. Unable to transmit message.</span>"
						return 1
					var/input = sanitize(input("Please choose a message to transmit to [boss_short] via quantum entanglement.  Please be aware that this process is very expensive, and abuse will lead to... termination.  Transmission does not guarantee a response. There is a 30 second delay before you may send another message, be clear, full and concise.", "To abort, send an empty message.", "") as null|text)
					if(!input || !can_still_topic())
						return 1
					Centcomm_announce(input, usr)
					usr << "<span class='notice'>Message transmitted.</span>"
					log_say("[key_name(usr)] has made an IA [boss_short] announcement: [input]")
					centcomm_message_cooldown = 1
					spawn(300) //30 second cooldown
						centcomm_message_cooldown = 0
		if("shuttle")
			. = 1
			if(is_autenthicated(user) && ntn_cont)
				if(href_list["target"] == "call")
					var/confirm = alert("Are you sure you want to call the shuttle?", name, "No", "Yes")
					if(confirm == "Yes" && can_still_topic())
						call_shuttle_proc(usr)
				if(href_list["target"] == "cancel" && !issilicon(usr))
					var/confirm = alert("Are you sure you want to cancel the shuttle?", name, "No", "Yes")
					if(confirm == "Yes" && can_still_topic())
						cancel_call_proc(usr)
		if("setstatus")
			. = 1
			if(is_autenthicated(user) && ntn_cont)
				switch(href_list["target"])
					if("line1")
						var/linput = reject_bad_text(sanitize(input("Line 1", "Enter Message Text", msg_line1) as text|null, 40), 40)
						if(can_still_topic())
							msg_line1 = linput
					if("line2")
						var/linput = reject_bad_text(sanitize(input("Line 2", "Enter Message Text", msg_line2) as text|null, 40), 40)
						if(can_still_topic())
							msg_line2 = linput
					if("message")
						post_status("message", msg_line1, msg_line2)
					if("alert")
						post_status("alert", href_list["alert"])
					else
						post_status(href_list["target"])
		if("setalert")
			. = 1
			if(is_autenthicated(user) && !issilicon(usr) && ntn_cont && ntn_comm)
				var/current_level = text2num(href_list["target"])
				var/confirm = alert("Are you sure you want to change alert level to [num2seclevel(current_level)]?", name, "No", "Yes")
				if(confirm == "Yes" && can_still_topic())
					var/old_level = security_level
					if(!current_level) current_level = SEC_LEVEL_GREEN
					if(current_level < SEC_LEVEL_GREEN) current_level = SEC_LEVEL_GREEN
					if(current_level > SEC_LEVEL_BLUE) current_level = SEC_LEVEL_BLUE //Cannot engage delta with this
					set_security_level(current_level)
					if(security_level != old_level)
						log_game("[key_name(usr)] has changed the security level to [get_security_level()].")
						message_admins("[key_name_admin(usr)] has changed the security level to [get_security_level()].")
						switch(security_level)
							if(SEC_LEVEL_GREEN)
								feedback_inc("alert_comms_green",1)
							if(SEC_LEVEL_BLUE)
								feedback_inc("alert_comms_blue",1)
			else
				usr << "You press button, but red light flashes and nothing happens." //This should never happen
			current_status = STATE_DEFAULT
		if("viewmessage")
			. = 1
			if(is_autenthicated(user) && ntn_comm)
				current_viewing_message_id = text2num(href_list["target"])
				for(var/list/m in l.messages)
					if(m["id"] == current_viewing_message_id)
						current_viewing_message = m
				current_status = STATE_VIEWMESSAGE
		if("delmessage")
			. = 1
			if(is_autenthicated(user) && ntn_comm && l != global_message_listener)
				l.Remove(current_viewing_message)
			current_status = STATE_MESSAGELIST
		if("printmessage")
			. = 1
			if(is_autenthicated(user) && ntn_comm)
				if(program && program.computer && program.computer.nano_printer)
					if(!program.computer.nano_printer.print_text(current_viewing_message["contents"],current_viewing_message["title"]))
						usr << "<span class='notice'>Hardware error: Printer was unable to print the file. It may be out of paper.</span>"
					else
						program.computer.visible_message("<span class='notice'>\The [program.computer] prints out paper.</span>")

#undef STATE_DEFAULT
#undef STATE_MESSAGELIST
#undef STATE_VIEWMESSAGE
#undef STATE_STATUSDISPLAY
#undef STATE_ALERT_LEVEL

/*
General message handling stuff
*/
var/list/comm_message_listeners = list() //We first have to initialize list then we can use it.
var/datum/comm_message_listener/global_message_listener = new //May be used by admins
var/last_message_id = 0

/proc/get_comm_message_id()
	last_message_id = last_message_id + 1
	return last_message_id

/proc/post_comm_message(var/message_title, var/message_text)
	var/list/message = list()
	message["id"] = get_comm_message_id()
	message["title"] = message_title
	message["contents"] = message_text

	for (var/datum/comm_message_listener/l in comm_message_listeners)
		l.Add(message)

	for (var/obj/machinery/modular_computer/console/preset/command/main/computer in global_modular_computers)
		if(!(computer.stat & (BROKEN | NOPOWER)) && computer.cpu)
			if(computer.cpu.hard_drive)
				var/datum/computer_file/program/comm/C = locate(/datum/computer_file/program/comm) in computer.cpu.hard_drive.stored_files
				if(C)
					var/obj/item/weapon/paper/intercept = new /obj/item/weapon/paper(computer.loc)
					intercept.name = message_title
					intercept.info = message_text

/datum/comm_message_listener
	var/list/messages

/datum/comm_message_listener/New()
	..()
	messages = list()
	comm_message_listeners.Add(src)

/datum/comm_message_listener/proc/Add(var/list/message)
	messages[++messages.len] = message

/datum/comm_message_listener/proc/Remove(var/list/message)
	messages -= list(message)

/proc/post_status(var/command, var/data1, var/data2)

	var/datum/radio_frequency/frequency = radio_controller.return_frequency(1435)

	if(!frequency) return


	var/datum/signal/status_signal = new
	status_signal.source = src
	status_signal.transmission_method = 1
	status_signal.data["command"] = command

	switch(command)
		if("message")
			status_signal.data["msg1"] = data1
			status_signal.data["msg2"] = data2
			log_admin("STATUS: [key_name(usr)] set status screen message with [src]: [data1] [data2]")
		if("alert")
			status_signal.data["picture_state"] = data1

	frequency.post_signal(src, status_signal)

/proc/cancel_call_proc(var/mob/user)
	if (!( ticker ) || !emergency_shuttle.can_recall())
		return
	if((ticker.mode.name == "blob")||(ticker.mode.name == "Meteor"))
		return

	if(!emergency_shuttle.going_to_centcom()) //check that shuttle isn't already heading to centcomm
		emergency_shuttle.recall()
		log_game("[key_name(user)] has recalled the shuttle.")
		message_admins("[key_name_admin(user)] has recalled the shuttle.", 1)
	return


/proc/is_relay_online()
    for(var/obj/machinery/bluespacerelay/M in machines)
        if(M.stat == 0)
            return 1
    return 0

/proc/enable_prison_shuttle(var/mob/user)
	for(var/obj/machinery/computer/prison_shuttle/PS in machines)
		PS.allowedtocall = !(PS.allowedtocall)

/proc/call_shuttle_proc(var/mob/user)
	if ((!( ticker ) || !emergency_shuttle.location()))
		return

	if(!universe.OnShuttleCall(usr))
		user << "<span class='notice'>Cannot establish a bluespace connection.</span>"
		return

	if(deathsquad.deployed)
		user << "[boss_short] will not allow the shuttle to be called. Consider all contracts terminated."
		return

	if(emergency_shuttle.deny_shuttle)
		user << "The emergency shuttle may not be sent at this time. Please try again later."
		return

	if(world.time < 6000) // Ten minute grace period to let the game get going without lolmetagaming. -- TLE
		user << "The emergency shuttle is refueling. Please wait another [round((6000-world.time)/600)] minute\s before trying again."
		return

	if(emergency_shuttle.going_to_centcom())
		user << "The emergency shuttle may not be called while returning to [boss_short]."
		return

	if(emergency_shuttle.online())
		user << "The emergency shuttle is already on its way."
		return

	if(ticker.mode.name == "blob" || ticker.mode.name == "epidemic")
		user << "Under directive 7-10, [station_name()] is quarantined until further notice."
		return

	if(!emergency_shuttle.call_evac(user))
		return
	log_and_message_admins("has called the shuttle.")

/proc/init_shift_change(var/mob/user, var/force = 0)
	if ((!( ticker ) || !emergency_shuttle.location()))
		return

	if(emergency_shuttle.going_to_centcom())
		user << "The shuttle may not be called while returning to [boss_short]."
		return

	if(emergency_shuttle.online())
		user << "The shuttle is already on its way."
		return

	// if force is 0, some things may stop the shuttle call
	if(!force)
		if(emergency_shuttle.deny_shuttle)
			user << "[boss_short] does not currently have a shuttle available in your sector. Please try again later."
			return

		if(deathsquad.deployed == 1)
			user << "[boss_short] will not allow the shuttle to be called. Consider all contracts terminated."
			return

		if(world.time < 54000) // 30 minute grace period to let the game get going
			user << "The shuttle is refueling. Please wait another [round((54000-world.time)/60)] minutes before trying again."
			return

		if(ticker.mode.auto_recall_shuttle)
			//New version pretends to call the shuttle but cause the shuttle to return after a random duration.
			emergency_shuttle.auto_recall = 1

		if(ticker.mode.name == "blob" || ticker.mode.name == "epidemic")
			user << "Under directive 7-10, [station_name()] is quarantined until further notice."
			return

	emergency_shuttle.call_transfer()

	//delay events in case of an autotransfer
	if (isnull(user))
		event_manager.delay_events(EVENT_LEVEL_MODERATE, 10200) //17 minutes
		event_manager.delay_events(EVENT_LEVEL_MAJOR, 10200)

	log_game("[user? key_name(user) : "Autotransfer"] has called the shuttle.")
	message_admins("[user? key_name_admin(user) : "Autotransfer"] has called the shuttle.", 1)

	return
