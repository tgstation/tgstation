
#define COMM_SCREEN_MAIN		1
#define COMM_SCREEN_STAT		2
#define COMM_SCREEN_MESSAGES	3
#define COMM_SCREEN_SECLEVEL	4

var/shuttle_call/shuttle_calls[0]

#define SHUTTLE_RECALL  -1
#define SHUTTLE_CALL     1
#define SHUTTLE_TRANSFER 2

/shuttle_call
	var/direction=0
	var/who=""
	var/ckey=""
	var/turf/from=null
	var/where=""
	var/when
	var/eta=null

/shuttle_call/New(var/mob/user,var/obj/machinery/computer/communications/computer,var/dir)
	direction=dir
	if(user)
		who="[user]"
		ckey="[user.key]"
	if(computer)
		where="[computer]"
		from=get_turf(computer)
	when=worldtime2text()
	if(dir==SHUTTLE_RECALL)
		var/timeleft=emergency_shuttle.timeleft()
		eta="[timeleft / 60 % 60]:[add_zero(num2text(timeleft % 60), 2)]"

// The communications computer
/obj/machinery/computer/communications
	name = "Communications Console"
	desc = "This can be used for various important functions. Still under developement."
	icon_state = "comm"
	req_access = list(access_heads)
	circuit = "/obj/item/weapon/circuitboard/communications"
	var/prints_intercept = 1
	var/authenticated = 0
	var/list/messagetitle = list()
	var/list/messagetext = list()
	var/currmsg = 0
	var/aicurrmsg = 0
	var/menu_state = COMM_SCREEN_MAIN
	var/ai_menu_state = COMM_SCREEN_MAIN
	var/message_cooldown = 0
	var/centcomm_message_cooldown = 0
	var/tmp_alertlevel = 0

	var/status_display_freq = "1435"
	var/stat_msg1
	var/stat_msg2
	var/display_type="blank"

	l_color = "#0000FF"

/obj/machinery/computer/communications/Topic(href, href_list)
	if(..(href, href_list))
		return

	if (!(src.z in list(STATION_Z,CENTCOMM_Z)))
		usr << "\red <b>Unable to establish a connection</b>: \black You're too far away from the station!"
		return

	usr.set_machine(src)

	if(!href_list["operation"])
		return
	switch(href_list["operation"])
		// main interface
		if("main")
			setMenuState(usr,COMM_SCREEN_MAIN)
		if("login")
			var/mob/M = usr
			var/obj/item/weapon/card/id/I = M.get_active_hand()
			if (istype(I, /obj/item/device/pda))
				var/obj/item/device/pda/pda = I
				I = pda.id
			if (I && istype(I))
				if(src.check_access(I))
					authenticated = 1
				if(20 in I.access)
					authenticated = 2
		if("logout")
			authenticated = 0
			setMenuState(usr,COMM_SCREEN_MAIN)

		// ALART LAVUL
		if("changeseclevel")
			setMenuState(usr,COMM_SCREEN_SECLEVEL)

		if("newalertlevel")
			if(issilicon(usr))
				return
			tmp_alertlevel = text2num(href_list["level"])
			var/mob/M = usr
			var/obj/item/weapon/card/id/I = M.get_active_hand()
			if (istype(I, /obj/item/device/pda))
				var/obj/item/device/pda/pda = I
				I = pda.id
			if (I && istype(I))
				if(access_captain in I.access || access_heads in I.access) //Let heads change the alert level.
					var/old_level = security_level
					if(!tmp_alertlevel) tmp_alertlevel = SEC_LEVEL_GREEN
					if(tmp_alertlevel < SEC_LEVEL_GREEN) tmp_alertlevel = SEC_LEVEL_GREEN
					if(tmp_alertlevel > SEC_LEVEL_BLUE) tmp_alertlevel = SEC_LEVEL_BLUE //Cannot engage delta with this
					set_security_level(tmp_alertlevel)
					if(security_level != old_level)
						//Only notify the admins if an actual change happened
						log_game("[key_name(usr)] has changed the security level to [get_security_level()].")
						message_admins("[key_name_admin(usr)] has changed the security level to [get_security_level()].")
						switch(security_level)
							if(SEC_LEVEL_GREEN)
								feedback_inc("alert_comms_green",1)
							if(SEC_LEVEL_BLUE)
								feedback_inc("alert_comms_blue",1)
					tmp_alertlevel = 0
				else:
					usr << "You are not authorized to do this."
					tmp_alertlevel = 0
				setMenuState(usr,COMM_SCREEN_MAIN)
			else
				usr << "You need to swipe your ID."

		if("announce")
			if(src.authenticated==2 && !issilicon(usr))
				if(message_cooldown)	return
				var/input = stripped_input(usr, "Please choose a message to announce to the station crew.", "What?")
				if(!input || !(usr in view(1,src)))
					return
				captain_announce(input)//This should really tell who is, IE HoP, CE, HoS, RD, Captain
				log_say("[key_name(usr)] has made a captain announcement: [input]")
				message_admins("[key_name_admin(usr)] has made a captain announcement.", 1)
				message_cooldown = 1
				spawn(600)//One minute cooldown
					message_cooldown = 0

		if("callshuttle")
			if(src.authenticated)
				var/response = alert("Are you sure you wish to call the shuttle?", "Confirm", "Yes", "No")
				if(response == "Yes")
					var/justification = stripped_input(usr, "Please input a concise justification for the shuttle call. Note that failure to properly justify a shuttle call may lead to recall or termination", "Nanotrasen Anti-Comdom Systems")
					if(!justification || !(usr in view(1,src)))
						return
					call_shuttle_proc(usr, justification)
					if(emergency_shuttle.online)
						post_status("shuttle")
			setMenuState(usr,COMM_SCREEN_MAIN)
		if("cancelshuttle")
			if(issilicon(usr)) return
			if(src.authenticated)
				var/response = alert("Are you sure you wish to recall the shuttle?", "Confirm", "Yes", "No")
				if(response == "Yes")
					recall_shuttle(usr)
					if(emergency_shuttle.online)
						post_status("shuttle")
			setMenuState(usr,COMM_SCREEN_MAIN)
		if("messagelist")
			src.currmsg = 0
			if(href_list["msgid"])
				setCurrentMessage(usr, text2num(href_list["msgid"]))
			setMenuState(usr,COMM_SCREEN_MESSAGES)
		if("delmessage")
			if(href_list["msgid"])
				src.currmsg = text2num(href_list["msgid"])
			var/response = alert("Are you sure you wish to delete this message?", "Confirm", "Yes", "No")
			if(response == "Yes")
				if(src.currmsg)
					var/id = getCurrentMessage()
					var/title = src.messagetitle[id]
					var/text  = src.messagetext[id]
					src.messagetitle.Remove(title)
					src.messagetext.Remove(text)
					if(currmsg==id) currmsg=0
					if(aicurrmsg==id) aicurrmsg=0
			setMenuState(usr,COMM_SCREEN_MESSAGES)

		if("status")
			setMenuState(usr,COMM_SCREEN_STAT)

		// Status display stuff
		if("setstat")
			display_type=href_list["statdisp"]
			switch(display_type)
				if("message")
					post_status("message", stat_msg1, stat_msg2)
				if("alert")
					post_status("alert", href_list["alert"])
					display_type = href_list["alert"]
				else
					post_status(href_list["statdisp"])
			setMenuState(usr,COMM_SCREEN_STAT)

		if("setmsg1")
			stat_msg1 = reject_bad_text(trim(copytext(sanitize(input("Line 1", "Enter Message Text", stat_msg1) as text|null), 1, 40)), 40)
			setMenuState(usr,COMM_SCREEN_STAT)
		if("setmsg2")
			stat_msg2 = reject_bad_text(trim(copytext(sanitize(input("Line 2", "Enter Message Text", stat_msg2) as text|null), 1, 40)), 40)
			setMenuState(usr,COMM_SCREEN_STAT)

		// OMG CENTCOMM LETTERHEAD
		if("MessageCentcomm")
			if(src.authenticated==2)
				if(centcomm_message_cooldown)
					usr << "\red Arrays recycling.  Please stand by."
					return
				var/input = stripped_input(usr, "Please choose a message to transmit to Centcomm via quantum entanglement.  Please be aware that this process is very expensive, and abuse will lead to... termination.  Transmission does not guarantee a response. There is a 30 second delay before you may send another message, be clear, full and concise.", "To abort, send an empty message.", "")
				if(!input || !(usr in view(1,src)))
					return
				Centcomm_announce(input, usr)
				usr << "\blue Message transmitted."
				log_say("[key_name(usr)] has made an IA Centcomm announcement: [input]")
				centcomm_message_cooldown = 1
				spawn(300)//10 minute cooldown
					centcomm_message_cooldown = 0
			setMenuState(usr,COMM_SCREEN_MAIN)


		// OMG SYNDICATE ...LETTERHEAD
		if("MessageSyndicate")
			if((src.authenticated==2) && (src.emagged))
				if(centcomm_message_cooldown)
					usr << "\red Arrays recycling.  Please stand by."
					return
				var/input = stripped_input(usr, "Please choose a message to transmit to \[ABNORMAL ROUTING CORDINATES\] via quantum entanglement.  Please be aware that this process is very expensive, and abuse will lead to... termination. Transmission does not guarantee a response. There is a 30 second delay before you may send another message, be clear, full and concise.", "To abort, send an empty message.", "")
				if(!input || !(usr in view(1,src)))
					return
				Syndicate_announce(input, usr)
				usr << "\blue Message transmitted."
				log_say("[key_name(usr)] has made a Syndicate announcement: [input]")
				centcomm_message_cooldown = 1
				spawn(300)//10 minute cooldown
					centcomm_message_cooldown = 0
			setMenuState(usr,COMM_SCREEN_MAIN)

		if("RestoreBackup")
			usr << "Backup routing data restored!"
			src.emagged = 0
			setMenuState(usr,COMM_SCREEN_MAIN)

	return 1

/obj/machinery/computer/communcations/emag(mob/user as mob)
	src.emagged = 1
	user << "You scramble the communication routing circuits!"

/obj/machinery/computer/communications/attack_ai(var/mob/user as mob)
	src.add_hiddenprint(user)
	return src.attack_hand(user)

/obj/machinery/computer/communications/attack_paw(var/mob/user as mob)
	return src.attack_hand(user)


/obj/machinery/computer/communications/attack_hand(var/mob/user as mob)
	if(..(user))
		return

	if (!(src.z in list(STATION_Z, CENTCOMM_Z)))
		user << "\red <b>Unable to establish a connection</b>: \black You're too far away from the station!"
		return

	ui_interact(user)



/obj/machinery/computer/communications/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null)
	if(user.stat)
		return

	// this is the data which will be sent to the ui
	var/data[0]
	data["is_ai"] = issilicon(user)
	data["menu_state"] = data["is_ai"] ? ai_menu_state : menu_state
	data["emagged"] = emagged
	data["authenticated"] = authenticated
	data["screen"] = getMenuState(usr)

	data["stat_display"] = list(
		"type"=display_type,
		"line_1"=(stat_msg1 ? stat_msg1 : "-----"),
		"line_2"=(stat_msg2 ? stat_msg2 : "-----"),
		"presets"=list(
			list("name"="blank",    "label"="Clear",       "desc"="Blank slate"),
			list("name"="shuttle",  "label"="Shuttle ETA", "desc"="Display how much time is left."),
			list("name"="message",  "label"="Message",     "desc"="A custom message.")
		),
		"alerts"=list(
			list("alert"="default",   "label"="NanoTrasen",  "desc"="Oh god."),
			list("alert"="redalert",  "label"="Red Alert",   "desc"="Nothing to do with communists."),
			list("alert"="lockdown",  "label"="Lockdown",    "desc"="Let everyone know they're on lockdown."),
			list("alert"="biohazard", "label"="Biohazard",   "desc"="Great for virus outbreaks and parties."),
		)
	)
	data["security_level"] = security_level
	data["str_security_level"] = get_security_level()
	data["levels"] = list(
		list("id"=SEC_LEVEL_GREEN, "name"="Green"),
		list("id"=SEC_LEVEL_BLUE,  "name"="Blue"),
		//SEC_LEVEL_RED = list("name"="Red"),
	)

	var/msg_data[0]
	for(var/i=1;i<=src.messagetext.len;i++)
		var/cur_msg[0]
		cur_msg["title"]=messagetitle[i]
		cur_msg["body"]=messagetext[i]
		cur_msg["id"] = i
		msg_data += list(cur_msg)
	data["messages"] = msg_data
	data["current_message"] = data["is_ai"] ? aicurrmsg : currmsg

	var/shuttle[0]
	shuttle["on"]=emergency_shuttle.online
	if (emergency_shuttle.online && emergency_shuttle.location==0)
		var/timeleft=emergency_shuttle.timeleft()
		shuttle["eta"]="[timeleft / 60 % 60]:[add_zero(num2text(timeleft % 60), 2)]"
	shuttle["pos"] = emergency_shuttle.location
	shuttle["can_recall"]=!(recall_time_limit && world.time >= recall_time_limit)

	data["shuttle"]=shuttle

	// update the ui if it exists, returns null if no ui is passed/found
	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data)
	if (!ui)
		// the ui does not exist, so we'll create a new() one
        // for a list of parameters and their descriptions see the code docs in \code\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "comm_console.tmpl", "Communications Console", 400, 500)
		// when the ui is first opened this is the data it will use
		ui.set_initial_data(data)
		// open the new ui window
		ui.open()
		// auto update every Master Controller tick
		ui.set_auto_update(1)

/obj/machinery/computer/communications/proc/setCurrentMessage(var/mob/user,var/value)
	if(issilicon(user))
		aicurrmsg=value
	else
		currmsg=value

/obj/machinery/computer/communications/proc/getCurrentMessage(var/mob/user)
	if(issilicon(user))
		return aicurrmsg
	else
		return currmsg

/obj/machinery/computer/communications/proc/setMenuState(var/mob/user,var/value)
	if(issilicon(user))
		ai_menu_state=value
	else
		menu_state=value

/obj/machinery/computer/communications/proc/getMenuState(var/mob/user)
	if(issilicon(user))
		return ai_menu_state
	else
		return menu_state

/proc/enable_prison_shuttle(var/mob/user)
	for(var/obj/machinery/computer/prison_shuttle/PS in world)
		PS.allowedtocall = !(PS.allowedtocall)

/proc/call_shuttle_proc(var/mob/user, var/justification)
	if ((!(ticker) || emergency_shuttle.location))
		return

	if(!universe.OnShuttleCall(user))
		return

	if(sent_strike_team == 1)
		user << "Centcom will not allow the shuttle to be called. Consider all contracts terminated."
		return

	if(world.time < 6000) // Ten minute grace period to let the game get going without lolmetagaming. -- TLE
		user << "The emergency shuttle is refueling. Please wait another [round((6000-world.time)/600)] minutes before trying again."
		return

	if(emergency_shuttle.direction == -1)
		user << "The emergency shuttle may not be called while returning to CentCom."
		return

	if(emergency_shuttle.online)
		user << "The emergency shuttle is already on its way."
		return

	if(ticker.mode.name == "blob")
		user << "Under directive 7-10, [station_name()] is quarantined until further notice."
		return

	emergency_shuttle.incall()
	if(!justification)
		justification = "#??!7E/_1$*/ARR-CON²FAIL!!*$^?" //Can happen for reasons, let's deal with it IC
	log_game("[key_name(user)] has called the shuttle. Justification given : '[justification]'")
	message_admins("[key_name_admin(user)] has called the shuttle. Justification given : '[justification]'. You are encouraged to act if that justification is shit", 1)
	captain_announce("The emergency shuttle has been called. It will arrive in [round(emergency_shuttle.timeleft()/60)] minutes. Justification : '[justification]'")
	world << sound('sound/AI/shuttlecalled.ogg')

	return

/proc/init_shift_change(var/mob/user, var/force = 0)
	if ((!( ticker ) || emergency_shuttle.location))
		return

	if(emergency_shuttle.direction == -1)
		user << "The shuttle may not be called while returning to CentCom."
		return

	if(emergency_shuttle.online)
		user << "The shuttle is already on its way."
		return

	// if force is 0, some things may stop the shuttle call
	if(!force)
		if(!universe.OnShuttleCall(user))
			return

		if(emergency_shuttle.deny_shuttle)
			user << "Centcom does not currently have a shuttle available in your sector. Please try again later."
			return

		if(sent_strike_team == 1)
			user << "Centcom will not allow the shuttle to be called. Consider all contracts terminated."
			return

		if(world.time < 54000) // 30 minute grace period to let the game get going
			user << "The shuttle is refueling. Please wait another [round((54000-world.time)/600)] minutes before trying again."//may need to change "/600"
			return

		if(ticker.mode.name == "revolution" || ticker.mode.name == "AI malfunction" || ticker.mode.name == "sandbox")
			//New version pretends to call the shuttle but cause the shuttle to return after a random duration.
			emergency_shuttle.fake_recall = rand(300,500)

		if(ticker.mode.name == "blob" || ticker.mode.name == "epidemic")
			user << "Under directive 7-10, [station_name()] is quarantined until further notice."
			return

	emergency_shuttle.shuttlealert(1)
	emergency_shuttle.incall()
	log_game("[key_name(user)] has called the shuttle.")
	message_admins("[key_name_admin(user)] has called the shuttle - [formatJumpTo(user)].", 1)
	captain_announce("A crew transfer has been initiated. The shuttle has been called. It will arrive in [round(emergency_shuttle.timeleft()/60)] minutes.")

	return

/proc/recall_shuttle(var/mob/user)
	if ((!( ticker ) || emergency_shuttle.location || emergency_shuttle.direction == 0 || emergency_shuttle.timeleft() < 300))
		return
	if( ticker.mode.name == "blob" || ticker.mode.name == "meteor")
		return

	if(emergency_shuttle.direction != -1 && emergency_shuttle.online) //check that shuttle isn't already heading to centcomm
		emergency_shuttle.recall()
		log_game("[key_name(user)] has recalled the shuttle.")
		message_admins("[key_name_admin(user)] has recalled the shuttle - [formatJumpTo(user)].", 1)
	return

/obj/machinery/computer/communications/proc/post_status(var/command, var/data1, var/data2)

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
			log_admin("STATUS: [src.fingerprintslast] set status screen message with [src]: [data1] [data2]")
			//message_admins("STATUS: [user] set status screen with [PDA]. Message: [data1] [data2]")
		if("alert")
			status_signal.data["picture_state"] = data1

	frequency.post_signal(src, status_signal)


/obj/machinery/computer/communications/Destroy()

	for(var/obj/machinery/computer/communications/commconsole in world)
		if(istype(commconsole.loc,/turf) && commconsole != src)
			return ..()

	for(var/obj/item/weapon/circuitboard/communications/commboard in world)
		if(istype(commboard.loc,/turf) || istype(commboard.loc,/obj/item/weapon/storage))
			return ..()

	for(var/mob/living/silicon/ai/shuttlecaller in player_list)
		if(!shuttlecaller.stat && shuttlecaller.client && istype(shuttlecaller.loc,/turf))
			return ..()

	if(ticker.mode.name == "revolution" || ticker.mode.name == "AI malfunction" || sent_strike_team)
		return ..()

	emergency_shuttle.incall(2)
	log_game("All the AIs, comm consoles and boards are destroyed. Shuttle called.")
	message_admins("All the AIs, comm consoles and boards are destroyed. Shuttle called.", 1)
	captain_announce("The emergency shuttle has been called. It will arrive in [round(emergency_shuttle.timeleft()/60)] minutes.")
	world << sound('sound/AI/shuttlecalled.ogg')

	..()

/obj/item/weapon/circuitboard/communications/Destroy()

	for(var/obj/machinery/computer/communications/commconsole in world)
		if(istype(commconsole.loc,/turf))
			return ..()

	for(var/obj/item/weapon/circuitboard/communications/commboard in world)
		if((istype(commboard.loc,/turf) || istype(commboard.loc,/obj/item/weapon/storage)) && commboard != src)
			return ..()

	for(var/mob/living/silicon/ai/shuttlecaller in player_list)
		if(!shuttlecaller.stat && shuttlecaller.client && istype(shuttlecaller.loc,/turf))
			return ..()

	if(ticker.mode.name == "revolution" || ticker.mode.name == "AI malfunction" || sent_strike_team)
		return ..()

	emergency_shuttle.incall(2)
	log_game("All the AIs, comm consoles and boards are destroyed. Shuttle called.")
	message_admins("All the AIs, comm consoles and boards are destroyed. Shuttle called.", 1)
	captain_announce("The emergency shuttle has been called. It will arrive in [round(emergency_shuttle.timeleft()/60)] minutes.")
	world << sound('sound/AI/shuttlecalled.ogg')

	..()
