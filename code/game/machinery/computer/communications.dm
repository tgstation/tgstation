//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

// The communications computer
/obj/machinery/computer/communications
	name = "Communications Console"
	desc = "Can be used to call for help and escape. Broken in case of emergency."
	icon_state = "comm"
	req_access = list(access_heads)
	circuit = "/obj/item/weapon/circuitboard/communications"
	var/prints_intercept = 1
	var/authenticated = 0
	var/list/messagetitle = list()
	var/list/messagetext = list()
	var/currmsg = 0
	var/aicurrmsg = 0
	var/state = STATE_DEFAULT
	var/aistate = STATE_DEFAULT
	var/cooldown_time = 0 // The next time (world.timeofday) you can send a message
	var/const/STATE_DEFAULT = 1
	var/const/STATE_CALLSHUTTLE = 2
	var/const/STATE_CANCELSHUTTLE = 3
	var/const/STATE_MESSAGELIST = 4
	var/const/STATE_VIEWMESSAGE = 5
	var/const/STATE_DELMESSAGE = 6
	var/const/STATE_STATUSDISPLAY = 7
	var/const/STATE_ALERT_LEVEL = 8

	var/status_display_freq = "1435"
	var/stat_msg1
	var/stat_msg2


/obj/machinery/computer/communications/New()
	shuttle_caller_list += src
	cycle_cooldown(5)
	..()

/obj/machinery/computer/communications/process()
	if(..())
		if(state != STATE_STATUSDISPLAY)
			src.updateDialog()


/obj/machinery/computer/communications/Topic(href, href_list)
	if(..())
		return
	if (src.z > 1)
		usr << "\red <b>Unable to establish a connection</b>: \black You're too far away from the station!"
		return
	usr.set_machine(src)

	if(!href_list["operation"])
		return
	switch(href_list["operation"])
		// main interface
		if("main")
			src.state = STATE_DEFAULT
		if("login")
			if(allowed(usr))
				authenticated = 1
				req_access = list(access_captain) //Hacky but it works
				if(allowed(usr))
					authenticated = 2
				req_access = list(access_heads)
		if("logout")
			authenticated = 0

		if("ShowChangeAlertScreen")
			var/cooldown = check_cooldown()
			if(src.authenticated==2)
				if(cooldown)
					usr << "Please wait [cooldown] seconds while the equipment calibrates and the arrays recycle."
				else
					state = STATE_ALERT_LEVEL
		if("ChangeAlertLevel")
			if(src.authenticated==2)
				var/cooldown = check_cooldown() //Need to check again because of topic spoofing
				if(cooldown)
					usr << "Please wait [cooldown] seconds while the equipment calibrates and the arrays recycle."
				else
					var/tmp_alertlevel = text2num( href_list["newalertlevel"] )
					if(!tmp_alertlevel) tmp_alertlevel = SEC_LEVEL_GREEN
					if(tmp_alertlevel < SEC_LEVEL_GREEN) tmp_alertlevel = SEC_LEVEL_GREEN
					if(tmp_alertlevel > SEC_LEVEL_BLUE) tmp_alertlevel = SEC_LEVEL_BLUE //Cannot engage delta with this

					if(security_level != tmp_alertlevel) //Only continue if an actual change is happening
						set_security_level(tmp_alertlevel)
						log_game("[key_name(usr)] has changed the security level to [get_security_level()].")
						message_admins("[key_name_admin(usr)] has changed the security level to [get_security_level()].")
						cycle_cooldown(2)
						switch(security_level)
							if(SEC_LEVEL_GREEN)
								feedback_inc("alert_comms_green",1)
							if(SEC_LEVEL_BLUE)
								feedback_inc("alert_comms_blue",1)
			state = STATE_DEFAULT

		if("announce")
			if(src.authenticated==2)
				var/cooldown = check_cooldown()
				if(cooldown)
					usr << "Please wait [cooldown] seconds while the equipment calibrates and the arrays recycle."
				else
					var/input = stripped_input(usr, "Please choose a message to announce to the station crew.", "What?")
					if(!input || !(usr in view(1,src)))
						return
					captain_announce(input)//This should really tell who is, IE HoP, CE, HoS, RD, Captain
					log_say("[key_name(usr)] has made a captain announcement: [input]")
					message_admins("[key_name_admin(usr)] has made a captain announcement.", 1)
					cycle_cooldown(2)

		if("callshuttle")
			src.state = STATE_DEFAULT
			if(src.authenticated)
				src.state = STATE_CALLSHUTTLE
		if("callshuttle2")
			src.state = STATE_DEFAULT
			if(src.authenticated)
				call_shuttle_proc(usr)
				if(emergency_shuttle.online)
					post_status("shuttle")
		if("cancelshuttle")
			src.state = STATE_DEFAULT
			if(src.authenticated)
				src.state = STATE_CANCELSHUTTLE
		if("cancelshuttle2")
			src.state = STATE_DEFAULT
			if(src.authenticated)
				cancel_call_proc(usr)

		if("messagelist")
			src.currmsg = 0
			src.state = STATE_MESSAGELIST
		if("viewmessage")
			src.state = STATE_VIEWMESSAGE
			if (!src.currmsg)
				if(href_list["message-num"])
					src.currmsg = text2num(href_list["message-num"])
				else
					src.state = STATE_MESSAGELIST
		if("delmessage")
			src.state = (src.currmsg) ? STATE_DELMESSAGE : STATE_MESSAGELIST
		if("delmessage2")
			if(src.authenticated)
				if(src.currmsg)
					var/title = src.messagetitle[src.currmsg]
					var/text  = src.messagetext[src.currmsg]
					src.messagetitle.Remove(title)
					src.messagetext.Remove(text)
					if(src.currmsg == src.aicurrmsg)
						src.aicurrmsg = 0
					src.currmsg = 0
				src.state = STATE_MESSAGELIST
			else
				src.state = STATE_VIEWMESSAGE

		// Status display stuff
		if("status")
			src.state = STATE_STATUSDISPLAY
		if("setstat")
			if(src.authenticated)
				switch(href_list["statdisp"])
					if("message")
						post_status("message", stat_msg1, stat_msg2)
					if("alert")
						post_status("alert", href_list["alert"])
					else
						post_status(href_list["statdisp"])
		if("setmsg1")
			if(src.authenticated)
				stat_msg1 = reject_bad_text(input("Line 1", "Enter Message Text", stat_msg1) as text|null, 40)
				src.updateDialog()
		if("setmsg2")
			if(src.authenticated)
				stat_msg2 = reject_bad_text(input("Line 2", "Enter Message Text", stat_msg2) as text|null, 40)
				src.updateDialog()

		// OMG CENTCOMM LETTERHEAD
		if("MessageCentcomm")
			if(src.authenticated==2)
				var/cooldown = check_cooldown()
				if(cooldown)
					usr << "Please wait [cooldown] seconds while the equipment calibrates and the arrays recycle."
					return
				var/input = stripped_input(usr, "Please choose a message to transmit to Centcomm via quantum entanglement.  Please be aware that this process is very expensive, and abuse will lead to... termination.  Transmission does not guarantee a response.", "To abort, send an empty message.", "")
				if(!input || !(usr in view(1,src)))
					return
				Centcomm_announce(input, usr)
				usr << "Message transmitted."
				log_say("[key_name(usr)] has made a Centcomm announcement: [input]")
				cycle_cooldown(5) // 5 minute cooldown


		// OMG SYNDICATE ...LETTERHEAD
		if("MessageSyndicate")
			if((src.authenticated==2) && (src.emagged))
				var/cooldown = check_cooldown()
				if(cooldown)
					usr << "Please wait [cooldown] seconds while the equipment calibrates and the arrays recylce."
					return
				var/input = stripped_input(usr, "Please choose a message to transmit to \[ABNORMAL ROUTING CORDINATES\] via quantum entanglement.  Please be aware that this process is very expensive, and abuse will lead to... termination. Transmission does not guarantee a response.", "To abort, send an empty message.", "")
				if(!input || !(usr in view(1,src)))
					return
				Syndicate_announce(input, usr)
				usr << "Message transmitted."
				log_say("[key_name(usr)] has made a Syndicate announcement: [input]")
				cycle_cooldown(5) // 5 minute cooldown

		if("RestoreBackup")
			usr << "Backup routing data restored!"
			src.emagged = 0
			src.updateDialog()



		// AI interface
	if(istype(usr,/mob/living/silicon/ai))
		switch(href_list["operation"])
			if("ai-main")
				src.aicurrmsg = 0
				src.aistate = STATE_DEFAULT
			if("ai-callshuttle")
				src.aistate = STATE_CALLSHUTTLE
			if("ai-callshuttle2")
				src.aistate = STATE_DEFAULT
				call_shuttle_proc(usr)
			if("ai-messagelist")
				src.aicurrmsg = 0
				src.aistate = STATE_MESSAGELIST
			if("ai-viewmessage")
				src.aistate = STATE_VIEWMESSAGE
				if (!src.aicurrmsg)
					if(href_list["message-num"])
						src.aicurrmsg = text2num(href_list["message-num"])
					else
						src.aistate = STATE_MESSAGELIST
			if("ai-delmessage")
				src.aistate = (src.aicurrmsg) ? STATE_DELMESSAGE : STATE_MESSAGELIST
			if("ai-delmessage2")
				if(src.aicurrmsg)
					var/title = src.messagetitle[src.aicurrmsg]
					var/text  = src.messagetext[src.aicurrmsg]
					src.messagetitle.Remove(title)
					src.messagetext.Remove(text)
					if(src.currmsg == src.aicurrmsg)
						src.currmsg = 0
					src.aicurrmsg = 0
				src.aistate = STATE_MESSAGELIST
			if("ai-status")
				src.aistate = STATE_STATUSDISPLAY


	src.updateUsrDialog()

/obj/machinery/computer/communications/attackby(var/obj/I as obj, var/mob/user as mob)
	if(istype(I,/obj/item/weapon/card/emag/))
		src.emagged = 1
		user << "You scramble the communication routing circuits!"
	..()

/obj/machinery/computer/communications/attack_ai(var/mob/user as mob)
	return src.attack_hand(user)


/obj/machinery/computer/communications/attack_paw(var/mob/user as mob)
	return src.attack_hand(user)


/obj/machinery/computer/communications/attack_hand(var/mob/user as mob)
	if(..())
		return
	if (src.z > 6)
		user << "\red <b>Unable to establish a connection</b>: \black You're too far away from the station!"
		return

	user.set_machine(src)
	var/dat = ""
	if (emergency_shuttle.online && emergency_shuttle.location==0)
		var/timeleft = emergency_shuttle.timeleft()
		dat += "<B>Emergency shuttle</B>\n<BR>\nETA: [timeleft / 60 % 60]:[add_zero(num2text(timeleft % 60), 2)]<BR>"


	var/datum/browser/popup = new(user, "communications", "Communications Console", 400, 500)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))

	if (istype(user, /mob/living/silicon))
		var/dat2 = src.interact_ai(user) // give the AI a different interact proc to limit its access
		if(dat2)
			dat +=  dat2
			//user << browse(dat, "window=communications;size=400x500")
			//onclose(user, "communications")

			popup.set_content(dat)
			popup.open()
		return

	switch(src.state)
		if(STATE_DEFAULT)
			if (src.authenticated)
				dat += "<BR>\[ <A HREF='?src=\ref[src];operation=logout'>Log Out</A> \]"
				if (src.authenticated==2)
					dat += "<BR>\[ <A HREF='?src=\ref[src];operation=announce'>Make An Announcement</A> \]"
					if(src.emagged == 0)
						dat += "<BR>\[ <A HREF='?src=\ref[src];operation=MessageCentcomm'>Send an emergency message to Centcomm</A> \]"
					else
						dat += "<BR>\[ <A HREF='?src=\ref[src];operation=MessageSyndicate'>Send an emergency message to \[UNKNOWN\]</A> \]"
						dat += "<BR>\[ <A HREF='?src=\ref[src];operation=RestoreBackup'>Restore Backup Routing Data</A> \]"

					dat += "<BR>\[ <A HREF='?src=\ref[src];operation=ShowChangeAlertScreen'>Change alert level</A> \]"
				if(emergency_shuttle.location==0)
					if (emergency_shuttle.online)
						dat += "<BR>\[ <A HREF='?src=\ref[src];operation=cancelshuttle'>Cancel Shuttle Call</A> \]"
					else
						dat += "<BR>\[ <A HREF='?src=\ref[src];operation=callshuttle'>Call Emergency Shuttle</A> \]"

				dat += "<BR>\[ <A HREF='?src=\ref[src];operation=status'>Set Status Display</A> \]"
			else
				dat += "<BR>\[ <A HREF='?src=\ref[src];operation=login'>Log In</A> \]"
			dat += "<BR>\[ <A HREF='?src=\ref[src];operation=messagelist'>Message List</A> \]"
		if(STATE_CALLSHUTTLE)
			dat += "Are you sure you want to call the shuttle? \[ <A HREF='?src=\ref[src];operation=callshuttle2'>OK</A> | <A HREF='?src=\ref[src];operation=main'>Cancel</A> \]"
		if(STATE_CANCELSHUTTLE)
			dat += "Are you sure you want to cancel the shuttle? \[ <A HREF='?src=\ref[src];operation=cancelshuttle2'>OK</A> | <A HREF='?src=\ref[src];operation=main'>Cancel</A> \]"
		if(STATE_MESSAGELIST)
			dat += "Messages:"
			for(var/i = 1; i<=src.messagetitle.len; i++)
				dat += "<BR><A HREF='?src=\ref[src];operation=viewmessage;message-num=[i]'>[src.messagetitle[i]]</A>"
		if(STATE_VIEWMESSAGE)
			if (src.currmsg)
				dat += "<B>[src.messagetitle[src.currmsg]]</B><BR><BR>[src.messagetext[src.currmsg]]"
				if (src.authenticated)
					dat += "<BR><BR>\[ <A HREF='?src=\ref[src];operation=delmessage'>Delete</A> \]"
			else
				src.state = STATE_MESSAGELIST
				src.attack_hand(user)
				return
		if(STATE_DELMESSAGE)
			if (src.currmsg)
				dat += "Are you sure you want to delete this message? <BR>\[ <A HREF='?src=\ref[src];operation=delmessage2'>OK</A> | <A HREF='?src=\ref[src];operation=viewmessage'>Cancel</A> \]"
			else
				src.state = STATE_MESSAGELIST
				src.attack_hand(user)
				return
		if(STATE_STATUSDISPLAY)
			dat += "Set Status Displays<BR>"
			dat += "\[ <A HREF='?src=\ref[src];operation=setstat;statdisp=blank'>Clear</A> \]<BR>"
			dat += "\[ <A HREF='?src=\ref[src];operation=setstat;statdisp=shuttle'>Shuttle ETA</A> \]<BR>"
			dat += "\[ <A HREF='?src=\ref[src];operation=setstat;statdisp=message'>Message</A> \]"
			dat += "<ul><li> Line 1: <A HREF='?src=\ref[src];operation=setmsg1'>[ stat_msg1 ? stat_msg1 : "(none)"]</A>"
			dat += "<li> Line 2: <A HREF='?src=\ref[src];operation=setmsg2'>[ stat_msg2 ? stat_msg2 : "(none)"]</A></ul><br>"
			dat += "\[ Alert: <A HREF='?src=\ref[src];operation=setstat;statdisp=alert;alert=default'>None</A> |"
			dat += " <A HREF='?src=\ref[src];operation=setstat;statdisp=alert;alert=redalert'>Red Alert</A> |"
			dat += " <A HREF='?src=\ref[src];operation=setstat;statdisp=alert;alert=lockdown'>Lockdown</A> |"
			dat += " <A HREF='?src=\ref[src];operation=setstat;statdisp=alert;alert=biohazard'>Biohazard</A> \]<BR><HR>"
		if(STATE_ALERT_LEVEL)
			dat += "Current alert level: [get_security_level()]<BR>"
			if(security_level == SEC_LEVEL_DELTA)
				dat += "<font color='red'><b>The self-destruct mechanism is active. Find a way to deactivate the mechanism to lower the alert level or evacuate.</b></font>"
			else
				dat += "<A HREF='?src=\ref[src];operation=ChangeAlertLevel;newalertlevel=[SEC_LEVEL_BLUE]'>Blue</A><BR>"
				dat += "<A HREF='?src=\ref[src];operation=ChangeAlertLevel;newalertlevel=[SEC_LEVEL_GREEN]'>Green</A>"

	dat += "<BR>\[ [(src.state != STATE_DEFAULT) ? "<A HREF='?src=\ref[src];operation=main'>Main Menu</A> | " : ""]<A HREF='?src=\ref[user];mach_close=communications'>Close</A> \]"
	//user << browse(dat, "window=communications;size=400x500")
	//onclose(user, "communications")
	popup.set_content(dat)
	popup.open()




/obj/machinery/computer/communications/proc/interact_ai(var/mob/living/silicon/ai/user as mob)
	var/dat = ""
	switch(src.aistate)
		if(STATE_DEFAULT)
			if(emergency_shuttle.location==0 && !emergency_shuttle.online)
				dat += "<BR>\[ <A HREF='?src=\ref[src];operation=ai-callshuttle'>Call Emergency Shuttle</A> \]"
			dat += "<BR>\[ <A HREF='?src=\ref[src];operation=ai-messagelist'>Message List</A> \]"
			dat += "<BR>\[ <A HREF='?src=\ref[src];operation=ai-status'>Set Status Display</A> \]"
		if(STATE_CALLSHUTTLE)
			dat += "Are you sure you want to call the shuttle? \[ <A HREF='?src=\ref[src];operation=ai-callshuttle2'>OK</A> | <A HREF='?src=\ref[src];operation=ai-main'>Cancel</A> \]"
		if(STATE_MESSAGELIST)
			dat += "Messages:"
			for(var/i = 1; i<=src.messagetitle.len; i++)
				dat += "<BR><A HREF='?src=\ref[src];operation=ai-viewmessage;message-num=[i]'>[src.messagetitle[i]]</A>"
		if(STATE_VIEWMESSAGE)
			if (src.aicurrmsg)
				dat += "<B>[src.messagetitle[src.aicurrmsg]]</B><BR><BR>[src.messagetext[src.aicurrmsg]]"
				dat += "<BR><BR>\[ <A HREF='?src=\ref[src];operation=ai-delmessage'>Delete</A> \]"
			else
				src.aistate = STATE_MESSAGELIST
				src.attack_hand(user)
				return null
		if(STATE_DELMESSAGE)
			if(src.aicurrmsg)
				dat += "Are you sure you want to delete this message? <BR>\[ <A HREF='?src=\ref[src];operation=ai-delmessage2'>OK</A> | <A HREF='?src=\ref[src];operation=ai-viewmessage'>Cancel</A> \]"
			else
				src.aistate = STATE_MESSAGELIST
				src.attack_hand(user)
				return

		if(STATE_STATUSDISPLAY)
			dat += "Set Status Displays<BR>"
			dat += "\[ <A HREF='?src=\ref[src];operation=setstat;statdisp=blank'>Clear</A> \]<BR>"
			dat += "\[ <A HREF='?src=\ref[src];operation=setstat;statdisp=shuttle'>Shuttle ETA</A> \]<BR>"
			dat += "\[ <A HREF='?src=\ref[src];operation=setstat;statdisp=message'>Message</A> \]"
			dat += "<ul><li> Line 1: <A HREF='?src=\ref[src];operation=setmsg1'>[ stat_msg1 ? stat_msg1 : "(none)"]</A>"
			dat += "<li> Line 2: <A HREF='?src=\ref[src];operation=setmsg2'>[ stat_msg2 ? stat_msg2 : "(none)"]</A></ul><br>"
			dat += "\[ Alert: <A HREF='?src=\ref[src];operation=setstat;statdisp=alert;alert=default'>None</A> |"
			dat += " <A HREF='?src=\ref[src];operation=setstat;statdisp=alert;alert=redalert'>Red Alert</A> |"
			dat += " <A HREF='?src=\ref[src];operation=setstat;statdisp=alert;alert=lockdown'>Lockdown</A> |"
			dat += " <A HREF='?src=\ref[src];operation=setstat;statdisp=alert;alert=biohazard'>Biohazard</A> \]<BR><HR>"


	dat += "<BR>\[ [(src.aistate != STATE_DEFAULT) ? "<A HREF='?src=\ref[src];operation=ai-main'>Main Menu</A> | " : ""]<A HREF='?src=\ref[user];mach_close=communications'>Close</A> \]"
	return dat


/proc/call_shuttle_proc(var/mob/user)
	if ((!( ticker ) || emergency_shuttle.location))
		return
/* DEATH SQUADS
	if(sent_strike_team == 1)
		user << "Centcom will not allow the shuttle to be called. Consider all contracts terminated."
		return
*/
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
	log_game("[key_name(user)] has called the shuttle.")
	message_admins("[key_name_admin(user)] has called the shuttle.", 1)
	captain_announce("The emergency shuttle has been called. It will arrive in [round(emergency_shuttle.timeleft()/60)] minutes.")
	world << sound('sound/AI/shuttlecalled.ogg')

	return


/proc/cancel_call_proc(var/mob/user)
	if ((!( ticker ) || emergency_shuttle.location || emergency_shuttle.direction == 0 || emergency_shuttle.timeleft() < 300))
		return
	if((ticker.mode.name == "blob")||(ticker.mode.name == "meteor"))
		return

	if(emergency_shuttle.direction != -1 && emergency_shuttle.online) //check that shuttle isn't already heading to centcomm
		emergency_shuttle.recall()
		log_game("[key_name(user)] has recalled the shuttle.")
		message_admins("[key_name_admin(user)] has recalled the shuttle.", 1)
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
		if("alert")
			status_signal.data["picture_state"] = data1

	frequency.post_signal(src, status_signal)


/obj/machinery/computer/communications/proc/cycle_cooldown(minutes = 1)
	var/deciseconds = minutes * 600
	cooldown_time = world.timeofday + deciseconds

/obj/machinery/computer/communications/proc/check_cooldown()
	var/world_time = world.timeofday
	if(cooldown_time > world_time)
		. = round((cooldown_time - world_time) / 10)
		world << "DEBUG: cooldown is [.] seconds"
	if(. > 1e5 ) //Midnight rollover protection (12:61 - 0:00)
		. = null

/obj/machinery/computer/communications/Del()
	shuttle_caller_list -= src
	emergency_shuttle.autoshuttlecall()
	..()

