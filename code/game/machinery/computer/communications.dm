// The communications computer
/obj/machinery/computer/communications
	name = "communications console"
	desc = "A console used for high-priority announcements and emergencies."
	icon_screen = "comm"
	icon_keyboard = "tech_key"
	req_access = list(GLOB.access_heads)
	circuit = /obj/item/weapon/circuitboard/computer/communications
	var/authenticated = 0
	var/auth_id = "Unknown" //Who is currently logged in?
	var/list/messagetitle = list()
	var/list/messagetext = list()
	var/currmsg = 0
	var/aicurrmsg = 0
	var/state = STATE_DEFAULT
	var/aistate = STATE_DEFAULT
	var/message_cooldown = 0
	var/ai_message_cooldown = 0
	var/tmp_alertlevel = 0
	var/const/STATE_DEFAULT = 1
	var/const/STATE_CALLSHUTTLE = 2
	var/const/STATE_CANCELSHUTTLE = 3
	var/const/STATE_MESSAGELIST = 4
	var/const/STATE_VIEWMESSAGE = 5
	var/const/STATE_DELMESSAGE = 6
	var/const/STATE_STATUSDISPLAY = 7
	var/const/STATE_ALERT_LEVEL = 8
	var/const/STATE_CONFIRM_LEVEL = 9
	var/const/STATE_TOGGLE_EMERGENCY = 10
	var/const/STATE_PURCHASE = 11

	var/status_display_freq = "1435"
	var/stat_msg1
	var/stat_msg2

	light_color = LIGHT_COLOR_BLUE

/obj/machinery/computer/communications/proc/checkCCcooldown()
	var/obj/item/weapon/circuitboard/computer/communications/CM = circuit
	if(CM.lastTimeUsed + 600 > world.time)
		return FALSE
	return TRUE

/obj/machinery/computer/communications/New()
	GLOB.shuttle_caller_list += src
	..()

/obj/machinery/computer/communications/process()
	if(..())
		if(state != STATE_STATUSDISPLAY)
			src.updateDialog()


/obj/machinery/computer/communications/Topic(href, href_list)
	if(..())
		return
	if (z != ZLEVEL_STATION && z != ZLEVEL_CENTCOM) //Can only use on centcom and SS13
		to_chat(usr, "<span class='boldannounce'>Unable to establish a connection</span>: \black You're too far away from the station!")
		return
	usr.set_machine(src)

	if(!href_list["operation"])
		return
	var/obj/item/weapon/circuitboard/computer/communications/CM = circuit
	switch(href_list["operation"])
		// main interface
		if("main")
			src.state = STATE_DEFAULT
			playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
		if("login")
			var/mob/M = usr

			var/obj/item/weapon/card/id/I = M.get_active_held_item()
			if(!istype(I))
				I = M.get_idcard()

			if(I && istype(I))
				if(src.check_access(I))
					authenticated = 1
					auth_id = "[I.registered_name] ([I.assignment])"
					if((20 in I.access))
						authenticated = 2
					playsound(src, 'sound/machines/terminal_on.ogg', 50, 0)
				if(src.emagged)
					authenticated = 2
					auth_id = "Unknown"
					to_chat(M, "<span class='warning'>[src] lets out a quiet alarm as its login is overriden.</span>")
					playsound(src, 'sound/machines/terminal_on.ogg', 50, 0)
					playsound(src, 'sound/machines/terminal_alert.ogg', 25, 0)
					if(prob(25))
						for(var/mob/living/silicon/ai/AI in active_ais())
							AI << sound('sound/machines/terminal_alert.ogg', volume = 10) //Very quiet for balance reasons
		if("logout")
			authenticated = 0
			playsound(src, 'sound/machines/terminal_off.ogg', 50, 0)

		if("swipeidseclevel")
			var/mob/M = usr
			var/obj/item/weapon/card/id/I = M.get_active_held_item()
			if (istype(I, /obj/item/device/pda))
				var/obj/item/device/pda/pda = I
				I = pda.id
			if (I && istype(I))
				if(GLOB.access_captain in I.access)
					var/old_level = GLOB.security_level
					if(!tmp_alertlevel) tmp_alertlevel = SEC_LEVEL_GREEN
					if(tmp_alertlevel < SEC_LEVEL_GREEN) tmp_alertlevel = SEC_LEVEL_GREEN
					if(tmp_alertlevel > SEC_LEVEL_BLUE) tmp_alertlevel = SEC_LEVEL_BLUE //Cannot engage delta with this
					set_security_level(tmp_alertlevel)
					if(GLOB.security_level != old_level)
						to_chat(usr, "<span class='notice'>Authorization confirmed. Modifying security level.</span>")
						playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, 0)
						//Only notify the admins if an actual change happened
						log_game("[key_name(usr)] has changed the security level to [get_security_level()].")
						message_admins("[key_name_admin(usr)] has changed the security level to [get_security_level()].")
						switch(GLOB.security_level)
							if(SEC_LEVEL_GREEN)
								SSblackbox.inc("alert_comms_green",1)
							if(SEC_LEVEL_BLUE)
								SSblackbox.inc("alert_comms_blue",1)
					tmp_alertlevel = 0
				else
					to_chat(usr, "<span class='warning'>You are not authorized to do this!</span>")
					playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
					tmp_alertlevel = 0
				state = STATE_DEFAULT
			else
				to_chat(usr, "<span class='warning'>You need to swipe your ID!</span>")
				playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)

		if("announce")
			if(src.authenticated==2)
				playsound(src, 'sound/machines/terminal_prompt.ogg', 50, 0)
				make_announcement(usr)

		if("crossserver")
			if(authenticated==2)
				if(CM.lastTimeUsed + 600 > world.time)
					to_chat(usr, "<span class='warning'>Arrays recycling.  Please stand by.</span>")
					playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
					return
				var/input = stripped_multiline_input(usr, "Please choose a message to transmit to an allied station.  Please be aware that this process is very expensive, and abuse will lead to... termination.", "Send a message to an allied station.", "")
				if(!input || !(usr in view(1,src)))
					return
				playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, 0)
				send2otherserver("[station_name()]", input,"Comms_Console")
				minor_announce(input, title = "Outgoing message to allied station")
				log_talk(usr,"[key_name(usr)] has sent a message to the other server: [input]",LOGSAY)
				message_admins("[key_name_admin(usr)] has sent a message to the other server.")
				CM.lastTimeUsed = world.time

		if("purchase_menu")
			state = STATE_PURCHASE

		if("buyshuttle")
			if(authenticated==2)
				var/list/shuttles = flatten_list(SSmapping.shuttle_templates)
				var/datum/map_template/shuttle/S = locate(href_list["chosen_shuttle"]) in shuttles
				if(S && istype(S))
					if(SSshuttle.emergency.mode != SHUTTLE_RECALL && SSshuttle.emergency.mode != SHUTTLE_IDLE)
						to_chat(usr, "It's a bit late to buy a new shuttle, don't you think?")
						return
					if(SSshuttle.shuttle_purchased)
						to_chat(usr, "A replacement shuttle has already been purchased.")
					else if(!S.prerequisites_met())
						to_chat(usr, "You have not met the requirements for purchasing this shuttle.")
					else
						if(SSshuttle.points >= S.credit_cost)
							var/obj/machinery/shuttle_manipulator/M = locate() in GLOB.machines
							if(M)
								SSshuttle.shuttle_purchased = TRUE
								M.unload_preview()
								M.load_template(S)
								M.existing_shuttle = SSshuttle.emergency
								M.action_load(S)
								SSshuttle.points -= S.credit_cost
								minor_announce("[usr.name] has purchased [S.name] for [S.credit_cost] credits." , "Shuttle Purchase")
								message_admins("[key_name_admin(usr)] purchased [S.name].")
								SSblackbox.add_details("shuttle_purchase", S.name)
							else
								to_chat(usr, "Something went wrong! The shuttle exchange system seems to be down.")
						else
							to_chat(usr, "Not enough credits.")

		if("callshuttle")
			src.state = STATE_DEFAULT
			if(src.authenticated)
				src.state = STATE_CALLSHUTTLE
		if("callshuttle2")
			if(src.authenticated)
				SSshuttle.requestEvac(usr, href_list["call"])
				if(SSshuttle.emergency.timer)
					post_status("shuttle")
			src.state = STATE_DEFAULT
		if("cancelshuttle")
			src.state = STATE_DEFAULT
			if(src.authenticated)
				src.state = STATE_CANCELSHUTTLE
		if("cancelshuttle2")
			if(src.authenticated)
				SSshuttle.cancelEvac(usr)
			src.state = STATE_DEFAULT
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
		if("status")
			src.state = STATE_STATUSDISPLAY

		if("securitylevel")
			src.tmp_alertlevel = text2num( href_list["newalertlevel"] )
			if(!tmp_alertlevel) tmp_alertlevel = 0
			state = STATE_CONFIRM_LEVEL
		if("changeseclevel")
			state = STATE_ALERT_LEVEL

		if("emergencyaccess")
			state = STATE_TOGGLE_EMERGENCY
		if("enableemergency")
			make_maint_all_access()
			log_game("[key_name(usr)] enabled emergency maintenance access.")
			message_admins("[key_name_admin(usr)] enabled emergency maintenance access.")
			src.state = STATE_DEFAULT
		if("disableemergency")
			revoke_maint_all_access()
			log_game("[key_name(usr)] disabled emergency maintenance access.")
			message_admins("[key_name_admin(usr)] disabled emergency maintenance access.")
			src.state = STATE_DEFAULT

		// Status display stuff
		if("setstat")
			playsound(src, "terminal_type", 50, 0)
			switch(href_list["statdisp"])
				if("message")
					post_status("message", stat_msg1, stat_msg2)
				if("alert")
					post_status("alert", href_list["alert"])
				else
					post_status(href_list["statdisp"])

		if("setmsg1")
			stat_msg1 = reject_bad_text(input("Line 1", "Enter Message Text", stat_msg1) as text|null, 40)
			src.updateDialog()
		if("setmsg2")
			stat_msg2 = reject_bad_text(input("Line 2", "Enter Message Text", stat_msg2) as text|null, 40)
			src.updateDialog()

		// OMG CENTCOM LETTERHEAD
		if("MessageCentcomm")
			if(src.authenticated==2)
				if(!checkCCcooldown())
					to_chat(usr, "<span class='warning'>Arrays recycling.  Please stand by.</span>")
					return
				var/input = stripped_input(usr, "Please choose a message to transmit to Centcom via quantum entanglement.  Please be aware that this process is very expensive, and abuse will lead to... termination.  Transmission does not guarantee a response.", "Send a message to Centcomm.", "")
				if(!input || !(usr in view(1,src)) || !checkCCcooldown())
					return
				playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, 0)
				Centcomm_announce(input, usr)
				to_chat(usr, "<span class='notice'>Message transmitted to Central Command.</span>")
				log_talk(usr,"[key_name(usr)] has made a Centcom announcement: [input]",LOGSAY)
				CM.lastTimeUsed = world.time


		// OMG SYNDICATE ...LETTERHEAD
		if("MessageSyndicate")
			if((src.authenticated==2) && (src.emagged))
				if(!checkCCcooldown())
					to_chat(usr, "<span class='warning'>Arrays recycling.  Please stand by.</span>")
					playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
					return
				var/input = stripped_input(usr, "Please choose a message to transmit to \[ABNORMAL ROUTING COORDINATES\] via quantum entanglement.  Please be aware that this process is very expensive, and abuse will lead to... termination. Transmission does not guarantee a response.", "Send a message to /??????/.", "")
				if(!input || !(usr in view(1,src)) || !checkCCcooldown())
					return
				playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, 0)
				Syndicate_announce(input, usr)
				to_chat(usr, "<span class='danger'>SYSERR @l(19833)of(transmit.dm): !@$ MESSAGE TRANSMITTED TO SYNDICATE COMMAND.</span>")
				log_talk(usr,"[key_name(usr)] has made a Syndicate announcement: [input]",LOGSAY)
				CM.lastTimeUsed = world.time

		if("RestoreBackup")
			to_chat(usr, "<span class='notice'>Backup routing data restored!</span>")
			playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, 0)
			src.emagged = 0
			src.updateDialog()

		if("nukerequest") //When there's no other way
			if(src.authenticated==2)
				if(!checkCCcooldown())
					to_chat(usr, "<span class='warning'>Arrays recycling. Please stand by.</span>")
					return
				var/input = stripped_input(usr, "Please enter the reason for requesting the nuclear self-destruct codes. Misuse of the nuclear request system will not be tolerated under any circumstances.  Transmission does not guarantee a response.", "Self Destruct Code Request.","")
				if(!input || !(usr in view(1,src)) || !checkCCcooldown())
					return
				Nuke_request(input, usr)
				to_chat(usr, "<span class='notice'>Request sent.</span>")
				log_talk(usr,"[key_name(usr)] has requested the nuclear codes from Centcomm",LOGSAY)
				priority_announce("The codes for the on-station nuclear self-destruct have been requested by [usr]. Confirmation or denial of this request will be sent shortly.", "Nuclear Self Destruct Codes Requested",'sound/ai/commandreport.ogg')
				CM.lastTimeUsed = world.time


		// AI interface
		if("ai-main")
			src.aicurrmsg = 0
			src.aistate = STATE_DEFAULT
		if("ai-callshuttle")
			src.aistate = STATE_CALLSHUTTLE
		if("ai-callshuttle2")
			SSshuttle.requestEvac(usr, href_list["call"])
			src.aistate = STATE_DEFAULT
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
		if("ai-announce")
			make_announcement(usr, 1)
		if("ai-securitylevel")
			src.tmp_alertlevel = text2num( href_list["newalertlevel"] )
			if(!tmp_alertlevel) tmp_alertlevel = 0
			var/old_level = GLOB.security_level
			if(!tmp_alertlevel) tmp_alertlevel = SEC_LEVEL_GREEN
			if(tmp_alertlevel < SEC_LEVEL_GREEN) tmp_alertlevel = SEC_LEVEL_GREEN
			if(tmp_alertlevel > SEC_LEVEL_BLUE) tmp_alertlevel = SEC_LEVEL_BLUE //Cannot engage delta with this
			set_security_level(tmp_alertlevel)
			if(GLOB.security_level != old_level)
				//Only notify the admins if an actual change happened
				log_game("[key_name(usr)] has changed the security level to [get_security_level()].")
				message_admins("[key_name_admin(usr)] has changed the security level to [get_security_level()].")
				switch(GLOB.security_level)
					if(SEC_LEVEL_GREEN)
						SSblackbox.inc("alert_comms_green",1)
					if(SEC_LEVEL_BLUE)
						SSblackbox.inc("alert_comms_blue",1)
			tmp_alertlevel = 0
			src.aistate = STATE_DEFAULT
		if("ai-changeseclevel")
			src.aistate = STATE_ALERT_LEVEL

		if("ai-emergencyaccess")
			src.aistate = STATE_TOGGLE_EMERGENCY
		if("ai-enableemergency")
			make_maint_all_access()
			log_game("[key_name(usr)] enabled emergency maintenance access.")
			message_admins("[key_name_admin(usr)] enabled emergency maintenance access.")
			src.aistate = STATE_DEFAULT
		if("ai-disableemergency")
			revoke_maint_all_access()
			log_game("[key_name(usr)] disabled emergency maintenance access.")
			message_admins("[key_name_admin(usr)] disabled emergency maintenance access.")
			src.aistate = STATE_DEFAULT

	src.updateUsrDialog()

/obj/machinery/computer/communications/attackby(obj/I, mob/user, params)
	if(istype(I, /obj/item/weapon/card/id))
		attack_hand(user)
	else
		return ..()

/obj/machinery/computer/communications/emag_act(mob/user)
	if(!emagged)
		src.emagged = 1
		if(authenticated == 1)
			authenticated = 2
		to_chat(user, "<span class='danger'>You scramble the communication routing circuits!</span>")
		playsound(src, 'sound/machines/terminal_alert.ogg', 50, 0)

/obj/machinery/computer/communications/attack_hand(mob/user)
	if(..())
		return
	if (src.z > 6)
		to_chat(user, "<span class='boldannounce'>Unable to establish a connection</span>: \black You're too far away from the station!")
		return

	user.set_machine(src)
	var/dat = ""
	if(SSshuttle.emergency.mode == SHUTTLE_CALL)
		var/timeleft = SSshuttle.emergency.timeLeft()
		dat += "<B>Emergency shuttle</B>\n<BR>\nETA: [timeleft / 60 % 60]:[add_zero(num2text(timeleft % 60), 2)]"


	var/datum/browser/popup = new(user, "communications", "Communications Console", 400, 500)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))

	if(issilicon(user))
		var/dat2 = src.interact_ai(user) // give the AI a different interact proc to limit its access
		if(dat2)
			dat +=  dat2
			popup.set_content(dat)
			popup.open()
		return

	switch(src.state)
		if(STATE_DEFAULT)
			if (src.authenticated)
				if(SSshuttle.emergencyCallAmount)
					if(SSshuttle.emergencyLastCallLoc)
						dat += "Most recent shuttle call/recall traced to: <b>[format_text(SSshuttle.emergencyLastCallLoc.name)]</b><BR>"
					else
						dat += "Unable to trace most recent shuttle call/recall signal.<BR>"
				dat += "Logged in as: [auth_id]"
				dat += "<BR>"
				dat += "<BR>\[ <A HREF='?src=\ref[src];operation=logout'>Log Out</A> \]<BR>"
				dat += "<BR><B>General Functions</B>"
				dat += "<BR>\[ <A HREF='?src=\ref[src];operation=messagelist'>Message List</A> \]"
				switch(SSshuttle.emergency.mode)
					if(SHUTTLE_IDLE, SHUTTLE_RECALL)
						dat += "<BR>\[ <A HREF='?src=\ref[src];operation=callshuttle'>Call Emergency Shuttle</A> \]"
					else
						dat += "<BR>\[ <A HREF='?src=\ref[src];operation=cancelshuttle'>Cancel Shuttle Call</A> \]"

				dat += "<BR>\[ <A HREF='?src=\ref[src];operation=status'>Set Status Display</A> \]"
				if (src.authenticated==2)
					dat += "<BR><BR><B>Captain Functions</B>"
					dat += "<BR>\[ <A HREF='?src=\ref[src];operation=announce'>Make a Captain's Announcement</A> \]"
					if(config.cross_allowed)
						dat += "<BR>\[ <A HREF='?src=\ref[src];operation=crossserver'>Send a message to an allied station</A> \]"
					dat += "<BR>\[ <A HREF='?src=\ref[src];operation=purchase_menu'>Purchase Shuttle</A> \]"
					dat += "<BR>\[ <A HREF='?src=\ref[src];operation=changeseclevel'>Change Alert Level</A> \]"
					dat += "<BR>\[ <A HREF='?src=\ref[src];operation=emergencyaccess'>Emergency Maintenance Access</A> \]"
					dat += "<BR>\[ <A HREF='?src=\ref[src];operation=nukerequest'>Request Nuclear Authentication Codes</A> \]"
					if(src.emagged == 0)
						dat += "<BR>\[ <A HREF='?src=\ref[src];operation=MessageCentcomm'>Send Message to Centcom</A> \]"
					else
						dat += "<BR>\[ <A HREF='?src=\ref[src];operation=MessageSyndicate'>Send Message to \[UNKNOWN\]</A> \]"
						dat += "<BR>\[ <A HREF='?src=\ref[src];operation=RestoreBackup'>Restore Backup Routing Data</A> \]"
			else
				dat += "<BR>\[ <A HREF='?src=\ref[src];operation=login'>Log In</A> \]"
		if(STATE_CALLSHUTTLE)
			dat += get_call_shuttle_form()
			playsound(src, 'sound/machines/terminal_prompt.ogg', 50, 0)
		if(STATE_CANCELSHUTTLE)
			dat += get_cancel_shuttle_form()
			playsound(src, 'sound/machines/terminal_prompt.ogg', 50, 0)
		if(STATE_MESSAGELIST)
			dat += "Messages:"
			for(var/i = 1; i<=src.messagetitle.len; i++)
				dat += "<BR><A HREF='?src=\ref[src];operation=viewmessage;message-num=[i]'>[src.messagetitle[i]]</A>"
			playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, 0)
		if(STATE_VIEWMESSAGE)
			if (src.currmsg)
				dat += "<B>[src.messagetitle[src.currmsg]]</B><BR><BR>[src.messagetext[src.currmsg]]"
				if (src.authenticated)
					dat += "<BR><BR>\[ <A HREF='?src=\ref[src];operation=delmessage'>Delete</a> \]"
			else
				src.state = STATE_MESSAGELIST
				src.attack_hand(user)
				return
		if(STATE_DELMESSAGE)
			if (src.currmsg)
				dat += "Are you sure you want to delete this message? \[ <A HREF='?src=\ref[src];operation=delmessage2'>OK</A> | <A HREF='?src=\ref[src];operation=viewmessage'>Cancel</A> \]"
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
			playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, 0)
		if(STATE_ALERT_LEVEL)
			dat += "Current alert level: [get_security_level()]<BR>"
			if(GLOB.security_level == SEC_LEVEL_DELTA)
				dat += "<font color='red'><b>The self-destruct mechanism is active. Find a way to deactivate the mechanism to lower the alert level or evacuate.</b></font>"
			else
				dat += "<A HREF='?src=\ref[src];operation=securitylevel;newalertlevel=[SEC_LEVEL_BLUE]'>Blue</A><BR>"
				dat += "<A HREF='?src=\ref[src];operation=securitylevel;newalertlevel=[SEC_LEVEL_GREEN]'>Green</A>"
		if(STATE_CONFIRM_LEVEL)
			dat += "Current alert level: [get_security_level()]<BR>"
			dat += "Confirm the change to: [num2seclevel(tmp_alertlevel)]<BR>"
			dat += "<A HREF='?src=\ref[src];operation=swipeidseclevel'>Swipe ID</A> to confirm change.<BR>"
		if(STATE_TOGGLE_EMERGENCY)
			playsound(src, 'sound/machines/terminal_prompt.ogg', 50, 0)
			if(GLOB.emergency_access == 1)
				dat += "<b>Emergency Maintenance Access is currently <font color='red'>ENABLED</font></b>"
				dat += "<BR>Restore maintenance access restrictions? <BR>\[ <A HREF='?src=\ref[src];operation=disableemergency'>OK</A> | <A HREF='?src=\ref[src];operation=viewmessage'>Cancel</A> \]"
			else
				dat += "<b>Emergency Maintenance Access is currently <font color='green'>DISABLED</font></b>"
				dat += "<BR>Lift access restrictions on maintenance and external airlocks? <BR>\[ <A HREF='?src=\ref[src];operation=enableemergency'>OK</A> | <A HREF='?src=\ref[src];operation=viewmessage'>Cancel</A> \]"

		if(STATE_PURCHASE)
			dat += "Budget: [SSshuttle.points] Credits.<BR>"
			for(var/shuttle_id in SSmapping.shuttle_templates)
				var/datum/map_template/shuttle/S = SSmapping.shuttle_templates[shuttle_id]
				if(S.can_be_bought && S.credit_cost < INFINITY)
					dat += "[S.name] | [S.credit_cost] Credits<BR>"
					dat += "[S.description]<BR>"
					if(S.prerequisites)
						dat += "Prerequisites: [S.prerequisites]<BR>"
					dat += "<A href='?src=\ref[src];operation=buyshuttle;chosen_shuttle=\ref[S]'>(<font color=red><i>Purchase</i></font>)</A><BR><BR>"

	dat += "<BR><BR>\[ [(src.state != STATE_DEFAULT) ? "<A HREF='?src=\ref[src];operation=main'>Main Menu</A> | " : ""]<A HREF='?src=\ref[user];mach_close=communications'>Close</A> \]"

	popup.set_content(dat)
	popup.open()
	popup.set_content(dat)
	popup.open()

/obj/machinery/computer/communications/proc/get_javascript_header(form_id)
	var/dat = {"<script type="text/javascript">
						function getLength(){
							var reasonField = document.getElementById('reasonfield');
							if(reasonField.value.length >= [CALL_SHUTTLE_REASON_LENGTH]){
								reasonField.style.backgroundColor = "#DDFFDD";
							}
							else {
								reasonField.style.backgroundColor = "#FFDDDD";
							}
						}
						function submit() {
							document.getElementById('[form_id]').submit();
						}
					</script>"}
	return dat

/obj/machinery/computer/communications/proc/get_call_shuttle_form(ai_interface = 0)
	var/form_id = "callshuttle"
	var/dat = get_javascript_header(form_id)
	dat += "<form name='callshuttle' id='[form_id]' action='?src=\ref[src]' method='get' style='display: inline'>"
	dat += "<input type='hidden' name='src' value='\ref[src]'>"
	dat += "<input type='hidden' name='operation' value='[ai_interface ? "ai-callshuttle2" : "callshuttle2"]'>"
	dat += "<b>Nature of emergency:</b><BR> <input type='text' id='reasonfield' name='call' style='width:250px; background-color:#FFDDDD; onkeydown='getLength() onkeyup='getLength()' onkeypress='getLength()'>"
	dat += "<BR>Are you sure you want to call the shuttle? \[ <a href='#' onclick='submit()'>Call</a> \]"
	return dat

/obj/machinery/computer/communications/proc/get_cancel_shuttle_form()
	var/form_id = "cancelshuttle"
	var/dat = get_javascript_header(form_id)
	dat += "<form name='cancelshuttle' id='[form_id]' action='?src=\ref[src]' method='get' style='display: inline'>"
	dat += "<input type='hidden' name='src' value='\ref[src]'>"
	dat += "<input type='hidden' name='operation' value='cancelshuttle2'>"

	dat += "<BR>Are you sure you want to cancel the shuttle? \[ <a href='#' onclick='submit()'>Cancel</a> \]"
	return dat

/obj/machinery/computer/communications/proc/interact_ai(mob/living/silicon/ai/user)
	var/dat = ""
	switch(src.aistate)
		if(STATE_DEFAULT)
			if(SSshuttle.emergencyCallAmount)
				if(SSshuttle.emergencyLastCallLoc)
					dat += "Latest emergency signal trace attempt successful.<BR>Last signal origin: <b>[format_text(SSshuttle.emergencyLastCallLoc.name)]</b>.<BR>"
				else
					dat += "Latest emergency signal trace attempt failed.<BR>"
			if(authenticated)
				dat += "Current login: [auth_id]"
			else
				dat += "Current login: None"
			dat += "<BR><BR><B>General Functions</B>"
			dat += "<BR>\[ <A HREF='?src=\ref[src];operation=ai-messagelist'>Message List</A> \]"
			if(SSshuttle.emergency.mode == SHUTTLE_IDLE)
				dat += "<BR>\[ <A HREF='?src=\ref[src];operation=ai-callshuttle'>Call Emergency Shuttle</A> \]"
			dat += "<BR>\[ <A HREF='?src=\ref[src];operation=ai-status'>Set Status Display</A> \]"
			dat += "<BR><BR><B>Special Functions</B>"
			dat += "<BR>\[ <A HREF='?src=\ref[src];operation=ai-announce'>Make an Announcement</A> \]"
			dat += "<BR>\[ <A HREF='?src=\ref[src];operation=ai-changeseclevel'>Change Alert Level</A> \]"
			dat += "<BR>\[ <A HREF='?src=\ref[src];operation=ai-emergencyaccess'>Emergency Maintenance Access</A> \]"
		if(STATE_CALLSHUTTLE)
			dat += get_call_shuttle_form(1)
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
				dat += "Are you sure you want to delete this message? \[ <A HREF='?src=\ref[src];operation=ai-delmessage2'>OK</A> | <A HREF='?src=\ref[src];operation=ai-viewmessage'>Cancel</A> \]"
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

		if(STATE_ALERT_LEVEL)
			dat += "Current alert level: [get_security_level()]<BR>"
			if(GLOB.security_level == SEC_LEVEL_DELTA)
				dat += "<font color='red'><b>The self-destruct mechanism is active. Find a way to deactivate the mechanism to lower the alert level or evacuate.</b></font>"
			else
				dat += "<A HREF='?src=\ref[src];operation=ai-securitylevel;newalertlevel=[SEC_LEVEL_BLUE]'>Blue</A><BR>"
				dat += "<A HREF='?src=\ref[src];operation=ai-securitylevel;newalertlevel=[SEC_LEVEL_GREEN]'>Green</A>"

		if(STATE_TOGGLE_EMERGENCY)
			if(GLOB.emergency_access == 1)
				dat += "<b>Emergency Maintenance Access is currently <font color='red'>ENABLED</font></b>"
				dat += "<BR>Restore maintenance access restrictions? <BR>\[ <A HREF='?src=\ref[src];operation=ai-disableemergency'>OK</A> | <A HREF='?src=\ref[src];operation=ai-viewmessage'>Cancel</A> \]"
			else
				dat += "<b>Emergency Maintenance Access is currently <font color='green'>DISABLED</font></b>"
				dat += "<BR>Lift access restrictions on maintenance and external airlocks? <BR>\[ <A HREF='?src=\ref[src];operation=ai-enableemergency'>OK</A> | <A HREF='?src=\ref[src];operation=ai-viewmessage'>Cancel</A> \]"

	dat += "<BR><BR>\[ [(src.aistate != STATE_DEFAULT) ? "<A HREF='?src=\ref[src];operation=ai-main'>Main Menu</A> | " : ""]<A HREF='?src=\ref[user];mach_close=communications'>Close</A> \]"
	return dat

/obj/machinery/computer/communications/proc/make_announcement(mob/living/user, is_silicon)
	if(!SScommunications.can_announce(user, is_silicon))
		to_chat(user, "Intercomms recharging. Please stand by.")
		return
	var/input = stripped_input(user, "Please choose a message to announce to the station crew.", "What?")
	if(!input || !user.canUseTopic(src))
		return
	SScommunications.make_announcement(user, is_silicon, input)

/obj/machinery/computer/communications/proc/post_status(command, data1, data2)

	var/datum/radio_frequency/frequency = SSradio.return_frequency(1435)

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


/obj/machinery/computer/communications/Destroy()
	GLOB.shuttle_caller_list -= src
	SSshuttle.autoEvac()
	return ..()

/obj/machinery/computer/communications/proc/overrideCooldown()
	var/obj/item/weapon/circuitboard/computer/communications/CM = circuit
	CM.lastTimeUsed = 0
