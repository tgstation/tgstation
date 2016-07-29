<<<<<<< HEAD
//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

var/const/CALL_SHUTTLE_REASON_LENGTH = 12

// The communications computer
/obj/machinery/computer/communications
	name = "communications console"
	desc = "This can be used for various important functions. Still under developement."
	icon_screen = "comm"
	icon_keyboard = "tech_key"
	req_access = list(access_heads)
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

	var/status_display_freq = "1435"
	var/stat_msg1
	var/stat_msg2


/obj/machinery/computer/communications/New()
	shuttle_caller_list += src
	..()

/obj/machinery/computer/communications/process()
	if(..())
		if(state != STATE_STATUSDISPLAY)
			src.updateDialog()


/obj/machinery/computer/communications/Topic(href, href_list)
	if(..())
		return
	if (src.z > ZLEVEL_CENTCOM) //Can only use on centcom and SS13
		usr << "<span class='boldannounce'>Unable to establish a connection</span>: \black You're too far away from the station!"
		return
	usr.set_machine(src)

	if(!href_list["operation"])
		return
	var/obj/item/weapon/circuitboard/computer/communications/CM = circuit
	switch(href_list["operation"])
		// main interface
		if("main")
			src.state = STATE_DEFAULT
		if("login")
			var/mob/M = usr
			var/obj/item/weapon/card/id/I = M.get_active_hand()
			if (istype(I, /obj/item/device/pda))
				var/obj/item/device/pda/pda = I
				I = pda.id
			if (I && istype(I))
				if(src.check_access(I))
					authenticated = 1
					auth_id = "[I.registered_name] ([I.assignment])"
					if((20 in I.access))
						authenticated = 2
				if(src.emagged)
					authenticated = 2
					auth_id = "Unknown"
		if("logout")
			authenticated = 0

		if("swipeidseclevel")
			var/mob/M = usr
			var/obj/item/weapon/card/id/I = M.get_active_hand()
			if (istype(I, /obj/item/device/pda))
				var/obj/item/device/pda/pda = I
				I = pda.id
			if (I && istype(I))
				if(access_captain in I.access)
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
					usr << "<span class='warning'>You are not authorized to do this!</span>"
					tmp_alertlevel = 0
				state = STATE_DEFAULT
			else
				usr << "<span class='warning'>You need to swipe your ID!</span>"

		if("announce")
			if(src.authenticated==2 && !message_cooldown)
				make_announcement(usr)
			else if (src.authenticated==2 && message_cooldown)
				usr << "Intercomms recharging. Please stand by."

		if("crossserver")
			if(authenticated==2)
				if(CM.lastTimeUsed + 600 > world.time)
					usr << "Arrays recycling.  Please stand by."
					return
				var/input = stripped_multiline_input(usr, "Please choose a message to transmit to an allied station.  Please be aware that this process is very expensive, and abuse will lead to... termination.", "Send a message to an allied station.", "")
				if(!input || !(usr in view(1,src)))
					return
				send2otherserver("[station_name()]", input,"Comms_Console")
				minor_announce(input, title = "Outgoing message to allied station")
				log_say("[key_name(usr)] has sent a message to the other server: [input]")
				message_admins("[key_name_admin(usr)] has sent a message to the other server.")
				CM.lastTimeUsed = world.time

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
				if(CM.lastTimeUsed + 600 > world.time)
					usr << "Arrays recycling.  Please stand by."
					return
				var/input = stripped_input(usr, "Please choose a message to transmit to Centcom via quantum entanglement.  Please be aware that this process is very expensive, and abuse will lead to... termination.  Transmission does not guarantee a response.", "Send a message to Centcomm.", "")
				if(!input || !(usr in view(1,src)))
					return
				Centcomm_announce(input, usr)
				usr << "Message transmitted."
				log_say("[key_name(usr)] has made a Centcom announcement: [input]")
				CM.lastTimeUsed = world.time


		// OMG SYNDICATE ...LETTERHEAD
		if("MessageSyndicate")
			if((src.authenticated==2) && (src.emagged))
				if(CM.lastTimeUsed + 600 > world.time)
					usr << "Arrays recycling.  Please stand by."
					return
				var/input = stripped_input(usr, "Please choose a message to transmit to \[ABNORMAL ROUTING COORDINATES\] via quantum entanglement.  Please be aware that this process is very expensive, and abuse will lead to... termination. Transmission does not guarantee a response.", "Send a message to /??????/.", "")
				if(!input || !(usr in view(1,src)))
					return
				Syndicate_announce(input, usr)
				usr << "Message transmitted."
				log_say("[key_name(usr)] has made a Syndicate announcement: [input]")
				CM.lastTimeUsed = world.time

		if("RestoreBackup")
			usr << "Backup routing data restored!"
			src.emagged = 0
			src.updateDialog()

		if("nukerequest") //When there's no other way
			if(src.authenticated==2)
				if(CM.lastTimeUsed + 600 > world.time)
					usr << "Arrays recycling. Please stand by."
					return
				var/input = stripped_input(usr, "Please enter the reason for requesting the nuclear self-destruct codes. Misuse of the nuclear request system will not be tolerated under any circumstances.  Transmission does not guarantee a response.", "Self Destruct Code Request.","")
				if(!input || !(usr in view(1,src)))
					return
				Nuke_request(input, usr)
				usr << "Request sent."
				log_say("[key_name(usr)] has requested the nuclear codes from Centcomm")
				priority_announce("The codes for the on-station nuclear self-destruct have been requested by [usr]. Confirmation or denial of this request will be sent shortly.", "Nuclear Self Destruct Codes Requested",'sound/AI/commandreport.ogg')
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
			if(!ai_message_cooldown)
				make_announcement(usr, 1)
		if("ai-securitylevel")
			src.tmp_alertlevel = text2num( href_list["newalertlevel"] )
			if(!tmp_alertlevel) tmp_alertlevel = 0
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
		user << "<span class='notice'>You scramble the communication routing circuits.</span>"

/obj/machinery/computer/communications/attack_hand(mob/user)
	if(..())
		return
	if (src.z > 6)
		user << "<span class='boldannounce'>Unable to establish a connection</span>: \black You're too far away from the station!"
		return

	user.set_machine(src)
	var/dat = ""
	if(SSshuttle.emergency.mode == SHUTTLE_CALL)
		var/timeleft = SSshuttle.emergency.timeLeft()
		dat += "<B>Emergency shuttle</B>\n<BR>\nETA: [timeleft / 60 % 60]:[add_zero(num2text(timeleft % 60), 2)]"


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
				if(SSshuttle.emergencyLastCallLoc)
					dat += "<BR>Most recent shuttle call/recall traced to: <b>[format_text(SSshuttle.emergencyLastCallLoc.name)]</b>"
				else
					dat += "<BR>Unable to trace most recent shuttle call/recall signal."
				dat += "<BR>Logged in as: [auth_id]"
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
					if(cross_allowed)
						dat += "<BR>\[ <A HREF='?src=\ref[src];operation=crossserver'>Send a message to an allied station</A> \]"
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
		if(STATE_CANCELSHUTTLE)
			dat += get_cancel_shuttle_form()
		if(STATE_MESSAGELIST)
			dat += "Messages:"
			for(var/i = 1; i<=src.messagetitle.len; i++)
				dat += "<BR><A HREF='?src=\ref[src];operation=viewmessage;message-num=[i]'>[src.messagetitle[i]]</A>"
		if(STATE_VIEWMESSAGE)
			if (src.currmsg)
				dat += "<B>[src.messagetitle[src.currmsg]]</B><BR><BR>[src.messagetext[src.currmsg]]"
				if (src.authenticated)
					dat += "<BR><BR>\[ <A HREF='?src=\ref[src];operation=delmessage'>Delete \]"
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
		if(STATE_ALERT_LEVEL)
			dat += "Current alert level: [get_security_level()]<BR>"
			if(security_level == SEC_LEVEL_DELTA)
				dat += "<font color='red'><b>The self-destruct mechanism is active. Find a way to deactivate the mechanism to lower the alert level or evacuate.</b></font>"
			else
				dat += "<A HREF='?src=\ref[src];operation=securitylevel;newalertlevel=[SEC_LEVEL_BLUE]'>Blue</A><BR>"
				dat += "<A HREF='?src=\ref[src];operation=securitylevel;newalertlevel=[SEC_LEVEL_GREEN]'>Green</A>"
		if(STATE_CONFIRM_LEVEL)
			dat += "Current alert level: [get_security_level()]<BR>"
			dat += "Confirm the change to: [num2seclevel(tmp_alertlevel)]<BR>"
			dat += "<A HREF='?src=\ref[src];operation=swipeidseclevel'>Swipe ID</A> to confirm change.<BR>"
		if(STATE_TOGGLE_EMERGENCY)
			if(emergency_access == 1)
				dat += "<b>Emergency Maintenance Access is currently <font color='red'>ENABLED</font></b>"
				dat += "<BR>Restore maintenance access restrictions? <BR>\[ <A HREF='?src=\ref[src];operation=disableemergency'>OK</A> | <A HREF='?src=\ref[src];operation=viewmessage'>Cancel</A> \]"
			else
				dat += "<b>Emergency Maintenance Access is currently <font color='green'>DISABLED</font></b>"
				dat += "<BR>Lift access restrictions on maintenance and external airlocks? <BR>\[ <A HREF='?src=\ref[src];operation=enableemergency'>OK</A> | <A HREF='?src=\ref[src];operation=viewmessage'>Cancel</A> \]"

	dat += "<BR><BR>\[ [(src.state != STATE_DEFAULT) ? "<A HREF='?src=\ref[src];operation=main'>Main Menu</A> | " : ""]<A HREF='?src=\ref[user];mach_close=communications'>Close</A> \]"
	//user << browse(dat, "window=communications;size=400x500")
	//onclose(user, "communications")
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
			if(SSshuttle.emergencyLastCallLoc)
				dat += "<BR>Latest emergency signal trace attempt successful.<BR>Last signal origin: <b>[format_text(SSshuttle.emergencyLastCallLoc.name)]</b>.<BR>"
			else
				dat += "<BR>Latest emergency signal trace attempt failed.<BR>"
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
			if(security_level == SEC_LEVEL_DELTA)
				dat += "<font color='red'><b>The self-destruct mechanism is active. Find a way to deactivate the mechanism to lower the alert level or evacuate.</b></font>"
			else
				dat += "<A HREF='?src=\ref[src];operation=ai-securitylevel;newalertlevel=[SEC_LEVEL_BLUE]'>Blue</A><BR>"
				dat += "<A HREF='?src=\ref[src];operation=ai-securitylevel;newalertlevel=[SEC_LEVEL_GREEN]'>Green</A>"

		if(STATE_TOGGLE_EMERGENCY)
			if(emergency_access == 1)
				dat += "<b>Emergency Maintenance Access is currently <font color='red'>ENABLED</font></b>"
				dat += "<BR>Restore maintenance access restrictions? <BR>\[ <A HREF='?src=\ref[src];operation=ai-disableemergency'>OK</A> | <A HREF='?src=\ref[src];operation=ai-viewmessage'>Cancel</A> \]"
			else
				dat += "<b>Emergency Maintenance Access is currently <font color='green'>DISABLED</font></b>"
				dat += "<BR>Lift access restrictions on maintenance and external airlocks? <BR>\[ <A HREF='?src=\ref[src];operation=ai-enableemergency'>OK</A> | <A HREF='?src=\ref[src];operation=ai-viewmessage'>Cancel</A> \]"

	dat += "<BR><BR>\[ [(src.aistate != STATE_DEFAULT) ? "<A HREF='?src=\ref[src];operation=ai-main'>Main Menu</A> | " : ""]<A HREF='?src=\ref[user];mach_close=communications'>Close</A> \]"
	return dat

/obj/machinery/computer/communications/proc/make_announcement(mob/living/user, is_silicon)
	var/input = stripped_input(user, "Please choose a message to announce to the station crew.", "What?")
	if(!input || !user.canUseTopic(src))
		return
	if(is_silicon)
		minor_announce(input,"[user.name] Announces:")
		ai_message_cooldown = 1
		spawn(600)//One minute cooldown
			ai_message_cooldown = 0
	else
		priority_announce(html_decode(input), null, 'sound/misc/announce.ogg', "Captain")
		message_cooldown = 1
		spawn(600)//One minute cooldown
			message_cooldown = 0
	log_say("[key_name(user)] has made a priority announcement: [input]")
	message_admins("[key_name_admin(user)] has made a priority announcement.")



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
	shuttle_caller_list -= src
	SSshuttle.autoEvac()
	return ..()

/obj/machinery/computer/communications/proc/overrideCooldown()
	var/obj/item/weapon/circuitboard/computer/communications/CM = circuit
	CM.lastTimeUsed = 0
=======

#define COMM_SCREEN_MAIN		1
#define COMM_SCREEN_STAT		2
#define COMM_SCREEN_MESSAGES	3
#define COMM_SCREEN_SECLEVEL	4
#define COMM_SCREEN_ERT			5

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

	light_color = LIGHT_COLOR_BLUE

/obj/machinery/computer/communications/Topic(href, href_list)
	if(..(href, href_list))
		return

	if(href_list["close"])
		if(usr.machine == src) usr.unset_machine()
		return 1

	if (!(src.z in list(STATION_Z,CENTCOMM_Z)))
		to_chat(usr, "<span class='danger'>Unable to establish a connection: </span>You're too far away from the station!")
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
			if (istype(I,/obj/item/weapon/card/emag))
				emag(usr)
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
					to_chat(usr, "You are not authorized to do this.")
					tmp_alertlevel = 0
				setMenuState(usr,COMM_SCREEN_MAIN)
			else
				to_chat(usr, "You need to swipe your ID.")

		if("announce")
			if(src.authenticated==2 && !issilicon(usr))
				if(message_cooldown)	return
				var/input = stripped_input(usr, "Please choose a message to announce to the station crew.", "What?")
				if(!input || !(usr in view(1,src)))
					return
				captain_announce(input)//This should really tell who is, IE HoP, CE, HoS, RD, Captain
				var/turf/T = get_turf(usr)
				log_say("[key_name(usr)] (@[T.x],[T.y],[T.z]) has made a captain announcement: [input]")
				message_admins("[key_name_admin(usr)] has made a captain announcement.", 1)
				message_cooldown = 1
				spawn(600)//One minute cooldown
					message_cooldown = 0

		if("emergency_screen")
			var/mob/M = usr
			var/obj/item/weapon/card/id/I = M.get_active_hand()
			if (istype(I, /obj/item/device/pda))
				var/obj/item/device/pda/pda = I
				I = pda.id
			if (I && istype(I))
				if(access_captain in I.access)
					authenticated = 2
			if(authenticated != 2)
				to_chat(usr, "<span class='warning'>You do not have clearance to use this function.</span>")
				return
			setMenuState(usr,COMM_SCREEN_ERT)
			return
		if("request_emergency_team")
			if(!map.linked_to_centcomm)
				to_chat(usr, "<span class='danger'>Error: No connection can be made to central command.</span>")
				return
			if(menu_state != COMM_SCREEN_ERT) return //Not on the right screen.
			if ((!(ticker) || emergency_shuttle.location))
				to_chat(usr, "<span class='warning'>Warning: The evac shuttle has already arrived.</span>")
				return

			if(!universe.OnShuttleCall(usr))
				to_chat(usr, "<span class='notice'>\The [src.name] cannot establish a bluespace connection.</span>")
				return

			if(sent_strike_team)
				to_chat(usr, "<span class='warning'>PKI AUTH ERROR: SERVER REPORTS BLACKLISTED COMMUNICATION KEY PLEASE CONTACT SERVICE TECHNICIAN</span>")
				return

			if(world.time < 6000)
				to_chat(usr, "<span class='notice'>The emergency response team is away on another mission, Please wait another [round((6000-world.time)/600)] minute\s before trying again.</span>")
				return
			if(emergency_shuttle.online)
				to_chat(usr, "The emergency shuttle is already on its way.")
				return
			if(!(get_security_level() in list("red", "delta")))
				to_chat(usr, "<span class='notice'>The station must be in an emergency to request a Response Team.</span>")
				return
			if(authenticated != 2 || issilicon(usr))
				to_chat(usr, "<span class='warning'>\The [src.name]'s screen flashes, \"Access Denied\".</span>")
				return
			if(send_emergency_team)
				to_chat(usr, "<span class='notice'>Central Command has already dispatched a Response Team to [station_name()]</span>")
				return

			var/response = alert(usr,"Are you sure you want to request a response team?", "ERT Request", "Yes", "No")
			if(response != "Yes")
				return
			trigger_armed_response_team(1)
			setMenuState(usr,COMM_SCREEN_MAIN)
			return

		if("callshuttle")
			if(src.authenticated)
				if(!map.linked_to_centcomm)
					to_chat(usr, "<span class='danger'>Error: No connection can be made to central command.</span>")
					return
				var/justification = stripped_input(usr, "Please input a concise justification for the shuttle call. Note that failure to properly justify a shuttle call may lead to recall or termination.", "Nanotrasen Anti-Comdom Systems")
				if(!justification || !(usr in view(1,src)))
					return
				var/response = alert("Are you sure you wish to call the shuttle?", "Confirm", "Yes", "Cancel")
				if(response == "Yes")
					call_shuttle_proc(usr, justification)
					if(emergency_shuttle.online)
						post_status("shuttle")
			setMenuState(usr,COMM_SCREEN_MAIN)
		if("cancelshuttle")
			if(!map.linked_to_centcomm)
				to_chat(usr, "<span class='danger'>Error: No connection can be made to central command.</span>")
				return
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
				if(!map.linked_to_centcomm)
					to_chat(usr, "<span class='danger'>Error: No connection can be made to central command.</span>")
					return
				if(centcomm_message_cooldown)
					to_chat(usr, "<span class='warning'>Arrays recycling.  Please stand by for a few seconds.</span>")
					return
				var/input = stripped_input(usr, "Please choose a message to transmit to Centcomm via quantum entanglement.  Please be aware that this process is very expensive, and abuse will lead to... termination.  Transmission does not guarantee a response. There is a 30 second delay before you may send another message, be clear, full and concise.", "To abort, send an empty message.", "")
				if(!input || !(usr in view(1,src)))
					return
				Centcomm_announce(input, usr)
				to_chat(usr, "<span class='notice'>Message transmitted.</span>")
				var/turf/T = get_turf(usr)
				log_say("[key_name(usr)] (@[T.x],[T.y],[T.z]) has sent a bluespace message to Centcomm: [input]")
				centcomm_message_cooldown = 1
				spawn(300)//30 seconds cooldown
					centcomm_message_cooldown = 0
			setMenuState(usr,COMM_SCREEN_MAIN)


		// OMG SYNDICATE ...LETTERHEAD
		if("MessageSyndicate")
			if((src.authenticated==2) && (src.emagged))
				if(!map.linked_to_centcomm)
					to_chat(usr, "<span class='danger'>Error: No connection can be made to \[ABNORMAL ROUTING CORDINATES\] .</span>")
					return
				if(centcomm_message_cooldown)
					to_chat(usr, "<span class='warning'>Arrays recycling.  Please stand by for a few seconds.</span>")
					return
				var/input = stripped_input(usr, "Please choose a message to transmit to \[ABNORMAL ROUTING CORDINATES\] via quantum entanglement.  Please be aware that this process is very expensive, and abuse will lead to... termination. Transmission does not guarantee a response. There is a 30 second delay before you may send another message, be clear, full and concise.", "To abort, send an empty message.", "")
				if(!input || !(usr in view(1,src)))
					return
				Syndicate_announce(input, usr)
				to_chat(usr, "<span class='notice'>Message transmitted.</span>")
				var/turf/T = get_turf(usr)
				log_say("[key_name(usr)] (@[T.x],[T.y],[T.z]) has sent a bluespace message to the syndicate: [input]")
				centcomm_message_cooldown = 1
				spawn(300)//30 seconds cooldown
					centcomm_message_cooldown = 0
			setMenuState(usr,COMM_SCREEN_MAIN)

		if("RestoreBackup")
			to_chat(usr, "Backup routing data restored!")
			src.emagged = 0
			setMenuState(usr,COMM_SCREEN_MAIN)
			update_icon()

	return 1

/obj/machinery/computer/communications/attack_ai(var/mob/user as mob)
	src.add_hiddenprint(user)
	return src.attack_hand(user)

/obj/machinery/computer/communications/attack_paw(var/mob/user as mob)
	return src.attack_hand(user)


/obj/machinery/computer/communications/attack_hand(var/mob/user as mob)
	if(..(user))
		return

	if (!(src.z in list(STATION_Z, CENTCOMM_Z)))
		to_chat(user, "<span class='danger'>Unable to establish a connection: </span>You're too far away from the station!")
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
			list("alert"="default",   "label"="Nanotrasen",  "desc"="Oh god."),
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
	data["ert_sent"] = send_emergency_team

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
        // for a list of parameters and their descriptions see the code docs in \code\\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "comm_console.tmpl", "Communications Console", 400, 500)
		// when the ui is first opened this is the data it will use
		ui.set_initial_data(data)
		// open the new ui window
		ui.open()
		// auto update every Master Controller tick
		ui.set_auto_update(1)

/obj/machinery/computer/communications/emag(mob/user as mob)
	if(!emagged)
		emagged = 1
		to_chat(user, "Syndicate routing data uploaded!")
		new/obj/effect/effect/sparks(get_turf(src))
		playsound(loc,"sparks",50,1)
		authenticated = 2
		setMenuState(usr,COMM_SCREEN_MAIN)
		update_icon()
		return 1
	return


/obj/machinery/computer/communications/update_icon()
	..()
	var/initial_icon = initial(icon_state)
	icon_state = "[emagged ? "[initial_icon]-emag" : "[initial_icon]"]"
	if(stat & BROKEN)
		icon_state = "[initial_icon]b"
	else if(stat & NOPOWER)
		icon_state = "[initial_icon]0"


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
	for(var/obj/machinery/computer/prison_shuttle/PS in machines)
		PS.allowedtocall = !(PS.allowedtocall)

/proc/call_shuttle_proc(var/mob/user, var/justification)
	if ((!(ticker) || emergency_shuttle.location))
		return

	if(!universe.OnShuttleCall(user))
		return
	if(!map.linked_to_centcomm)
		to_chat(usr, "<span class='danger'>Error: No connection can be made to central command .</span>")
		return
	if(sent_strike_team == 1)
		to_chat(user, "Centcom will not allow the shuttle to be called. Consider all contracts terminated.")
		return

	if(world.time < 6000) // Ten minute grace period to let the game get going without lolmetagaming. -- TLE
		to_chat(user, "The emergency shuttle is refueling. Please wait another [round((6000-world.time)/600)] minute\s before trying again.")
		return

	if(emergency_shuttle.direction == -1)
		to_chat(user, "The emergency shuttle may not be called while returning to CentCom.")
		return

	if(emergency_shuttle.online)
		to_chat(user, "The emergency shuttle is already on its way.")
		return

	if(ticker.mode.name == "blob")
		to_chat(user, "Under directive 7-10, [station_name()] is quarantined until further notice.")
		return

	emergency_shuttle.incall()
	if(!justification)
		justification = "#??!7E/_1$*/ARR-CON�FAIL!!*$^?" //Can happen for reasons, let's deal with it IC
	log_game("[key_name(user)] has called the shuttle. Justification given : '[justification]'")
	message_admins("[key_name_admin(user)] has called the shuttle. Justification given : '[justification]'. You are encouraged to act if that justification is shit", 1)
	captain_announce("The emergency shuttle has been called. It will arrive in [round(emergency_shuttle.timeleft()/60)] minutes. Justification : '[justification]'")
	world << sound('sound/AI/shuttlecalled.ogg')

	return

/proc/init_shift_change(var/mob/user, var/force = 0)
	if ((!( ticker ) || emergency_shuttle.location))
		return

	if(emergency_shuttle.direction == -1)
		to_chat(user, "The shuttle may not be called while returning to CentCom.")
		return

	if(emergency_shuttle.online)
		to_chat(user, "The shuttle is already on its way.")
		return

	// if force is 0, some things may stop the shuttle call
	if(!force)
		if(!universe.OnShuttleCall(user))
			return

		if(emergency_shuttle.deny_shuttle)
			to_chat(user, "Centcom does not currently have a shuttle available in your sector. Please try again later.")
			return

		if(sent_strike_team == 1)
			to_chat(user, "Centcom will not allow the shuttle to be called. Consider all contracts terminated.")
			return

		if(world.time < 54000) // 30 minute grace period to let the game get going
			to_chat(user, "The shuttle is refueling. Please wait another [round((54000-world.time)/600)] minutes before trying again.")//may need to change "/600"

			return

		if(ticker.mode.name == "revolution" || ticker.mode.name == "AI malfunction" || ticker.mode.name == "sandbox")
			//New version pretends to call the shuttle but cause the shuttle to return after a random duration.
			emergency_shuttle.fake_recall = rand(300,500)

		if(ticker.mode.name == "blob" || ticker.mode.name == "epidemic")
			to_chat(user, "Under directive 7-10, [station_name()] is quarantined until further notice.")
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

	var/datum/signal/status_signal = getFromPool(/datum/signal)
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

	for(var/obj/machinery/computer/communications/commconsole in machines)
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

	for(var/obj/machinery/computer/communications/commconsole in machines)
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
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
