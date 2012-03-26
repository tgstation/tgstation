/******************** Requests Console ********************/
/** Originally written by errorage, updated by: <sign your updates here> **/

var/req_console_assistance = list()
var/req_console_supplies = list()
var/req_console_information = list()
var/list/obj/machinery/requests_console/allConsoles = list()

/obj/machinery/requests_console
	name = "Requests Console"
	desc = "A console intended to send requests to diferent departments on the station."
	anchored = 1
	icon = 'terminals.dmi'
	icon_state = "req_comp0"
	var/department = "Unknown" //The list of all departments on the station (Determined from this variable on each unit) Set this to the same thing if you want several consoles in one department
	var/list/messages = list() //List of all messages
	var/departmentType = 0
		// 0 = none (not listed, can only repeplied to)
		// 1 = assistance
		// 2 = supplies
		// 3 = info
		// 4 = ass + sup
		// 5 = ass + info
		// 6 = sup + info
		// 7 = ass + sup + info
	var/newmessagepriority = 0
		// 0 = no new message
		// 1 = normal priority
		// 2 = high priority
		// 3 = extreme priority - not implemented, will probably require some hacking... everything needs to have a hidden feature in this game.
	var/screen = 0
		// 0 = main menu,
		// 1 = req. assistance,
		// 2 = req. supplies
		// 3 = relay information
		// 4 = write msg - not used
		// 5 = choose priority - not used
		// 6 = sent successfully
		// 7 = sent unsuccessfully
		// 8 = view messages
		// 9 = authentication before sending
		// 10 = send announcement
	var/silent = 0 // set to 1 for it not to beep all the time
	var/hackState = 0
		// 0 = not hacked
		// 1 = hacked
	var/announcementConsole = 0
		// 0 = This console cannot be used to send department announcements
		// 1 = This console can send department announcementsf
	var/open = 0 // 1 if open
	var/announceAuth = 0 //Will be set to 1 when you authenticate yourself for announcements
	var/msgVerified = "" //Will contain the name of the person who varified it
	var/msgStamped = "" //If a message is stamped, this will contain the stamp name
	var/message = "";
	var/dpt = ""; //the department which will be receiving the message
	var/priority = -1 ; //Priority of the message being sent
	luminosity = 0

/obj/machinery/requests_console/New()
	src.name = "[src.department] Requests Console"
	allConsoles += src
	//req_console_departments += department
	switch(src.departmentType)
		if(1)
			if(!("[src.department]" in req_console_assistance))
				req_console_assistance += department
		if(2)
			if(!("[src.department]" in req_console_supplies))
				req_console_supplies += department
		if(3)
			if(!("[src.department]" in req_console_information))
				req_console_information += department
		if(4)
			if(!("[src.department]" in req_console_assistance))
				req_console_assistance += department
			if(!("[src.department]" in req_console_supplies))
				req_console_supplies += department
		if(5)
			if(!("[src.department]" in req_console_assistance))
				req_console_assistance += department
			if(!("[src.department]" in req_console_information))
				req_console_information += department
		if(6)
			if(!("[src.department]" in req_console_supplies))
				req_console_supplies += department
			if(!("[src.department]" in req_console_information))
				req_console_information += department
		if(7)
			if(!("[src.department]" in req_console_assistance))
				req_console_assistance += department
			if(!("[src.department]" in req_console_supplies))
				req_console_supplies += department
			if(!("[src.department]" in req_console_information))
				req_console_information += department


/obj/machinery/requests_console/attack_hand(user as mob)
	var/dat
	dat = text("<HEAD><TITLE>Requests Console</TITLE></HEAD><H3>[src.department] Requests Console</H3>")
	if(!src.open)
		if (src.screen == 0)
			announceAuth = 0
			if (src.newmessagepriority == 1)
				dat += text("<FONT COLOR='RED'>There are new messages</FONT><BR>")
			if (src.newmessagepriority == 2)
				dat += text("<FONT COLOR='RED'><B>NEW PRIORITY MESSAGES</B></FONT><BR>")
			dat += text("<A href='?src=\ref[src];setScreen=[8]'>View Messages</A><BR><BR>")

			dat += text("<A href='?src=\ref[src];setScreen=[1]'>Request Assistance</A><BR>")
			dat += text("<A href='?src=\ref[src];setScreen=[2]'>Request Supplies</A><BR>")
			dat += text("<A href='?src=\ref[src];setScreen=[3]'>Relay Anonymous Information</A><BR><BR>")
			if(announcementConsole)
				dat += text("<A href='?src=\ref[src];setScreen=[10]'>Send station-wide announcement</A><BR><BR>")
			//dat += text("<BR><A href='?src=\ref[src];callMailman=[1];location=[src.department]'>Call Mailman</A><BR><BR>")   // This is the line to call the mailman, it's intended for it to message him on his PDA
			if (src.silent)
				dat += text("Speaker <A href='?src=\ref[src];setSilent=[0]'>OFF</A>")
			else
				dat += text("Speaker <A href='?src=\ref[src];setSilent=[1]'>ON</A>")
		if (src.screen == 1)
			dat += text("Which department do you need assistance from?<BR><BR>")
			for(var/dpt in req_console_assistance)
				if (dpt != src.department)
					dat += text("[dpt] (<A href='?src=\ref[src];write=[ckey(dpt)]'>Message</A> or ")
					dat += text("<A href='?src=\ref[src];write=[ckey(dpt)];priority=[2]'>High Priority</A>")
					if (src.hackState == 1)
						dat += text(" or <A href='?src=\ref[src];write=[ckey(dpt)];priority=[3]'>EXTREME</A>)")
					dat += text(")<BR>")
			dat += text("<BR><A href='?src=\ref[src];setScreen=[0]'>Back</A><BR>")
		if (src.screen == 2)
			dat += text("Which department do you need supplies from?<BR><BR>")
			for(var/dpt in req_console_supplies)
				if (dpt != src.department)
					dat += text("[dpt] (<A href='?src=\ref[src];write=[ckey(dpt)]'>Message</A> or ")
					dat += text("<A href='?src=\ref[src];write=[ckey(dpt)];priority=[2]'>High Priority</A>")
					if (src.hackState == 1)
						dat += text(" or <A href='?src=\ref[src];write=[ckey(dpt)];priority=[3]'>EXTREME</A>)")
					dat += text(")<BR>")
			dat += text("<BR><A href='?src=\ref[src];setScreen=[0]'>Back</A><BR>")
		if (src.screen == 3)
			dat += text("Which department would you like to send information to?<BR><BR>")
			for(var/dpt in req_console_information)
				if (dpt != src.department)
					dat += text("[dpt] (<A href='?src=\ref[src];write=[ckey(dpt)]'>Message</A> or ")
					dat += text("<A href='?src=\ref[src];write=[ckey(dpt)];priority=[2]'>High Priority</A>")
					if (src.hackState == 1)
						dat += text(" or <A href='?src=\ref[src];write=[ckey(dpt)];priority=[3]'>EXTREME</A>)")
					dat += text(")<BR>")
			dat += text("<BR><A href='?src=\ref[src];setScreen=[0]'>Back</A><BR>")
		if (src.screen == 6)
			dat += text("<FONT COLOR='GREEN'>Message sent</FONT><BR><BR>")
			dat += text("<A href='?src=\ref[src];setScreen=[0]'>Continue</A><BR>")
		if (src.screen == 7)
			dat += text("<FONT COLOR='RED'>An error occurred. </FONT><BR><BR>")
			dat += text("<A href='?src=\ref[src];setScreen=[0]'>Continue</A><BR>")
		if (src.screen == 8)
			for (var/obj/machinery/requests_console/CONSOLE in allConsoles)
				if (CONSOLE.department == src.department)
					CONSOLE.newmessagepriority = 0
					CONSOLE.icon_state = "req_comp0"
					CONSOLE.luminosity = 1
			src.newmessagepriority = 0
			icon_state = "req_comp0"
			for(var/msg in src.messages)
				dat += text("[msg]<BR>")
			dat += text("<A href='?src=\ref[src];setScreen=[0]'>Back to main menu</A><BR>")
		if (src.screen == 9)
			dat += text("<B>Message Authentication</B><BR><BR>")
			dat += text("<b>Message for [src.dpt]: </b>[message]<BR><BR>")
			dat += text("You may authenticate your message now by scanning your ID or your stamp<BR><BR>")
			dat += text("Validated by: [msgVerified]<br>");
			dat += text("Stamped by: [msgStamped]<br>");
			dat += text("<A href='?src=\ref[src];department=[src.dpt]'>Send</A><BR>");
			dat += text("<BR><A href='?src=\ref[src];setScreen=[0]'>Back</A><BR>")
		if (src.screen == 10)
			dat += text("<B>Station wide announcement</B><BR><BR>")
			if(announceAuth)
				dat += text("<b>Authentication accepted</b><BR><BR>")
			else
				dat += text("Swipe your card to authenticate yourself.<BR><BR>")
			dat += text("<b>Message: </b>[message] <A href='?src=\ref[src];writeAnnouncement=[1]'>Write</A><BR><BR>")
			if (announceAuth && message)
				dat += text("<A href='?src=\ref[src];sendAnnouncement=[1]'>Announce</A><BR>");
			dat += text("<BR><A href='?src=\ref[src];setScreen=[0]'>Back</A><BR>")
		user << browse("[dat]", "")
		onclose(user, "req_console")
	return

/obj/machinery/requests_console/Topic(href, href_list)
	if(..())
		return
	usr.machine = src
	src.add_fingerprint(usr)
	if(href_list["write"])
		src.dpt = href_list["write"] //write contains the string of the receiving department's name
		src.message = strip_html(input(usr, "Write your message", "Messanger", ""))
		src.priority = href_list["priority"]
		while (findtext(src.message," ") == 1)
			src.message = copytext(src.message,2,lentext(src.message)+1)
		if (findtext(src.message," ") == 1)
			src.message = "";
		if (src.message != "")
			screen = 9
		else
			dpt = "";
			msgVerified = "";
			msgStamped = "";
			screen = 0
			priority = -1
	if(href_list["writeAnnouncement"])
		src.message = input(usr, "Write your message", "Messanger", "")
		src.priority = href_list["priority"]
		while (findtext(src.message," ") == 1)
			src.message = copytext(src.message,2,lentext(src.message)+1)
		if (findtext(src.message," ") == 1)
			src.message = "";
		if (src.message == "")
			announceAuth = 0;
			screen = 0
	if(href_list["sendAnnouncement"])
		world << "<b><font size = 3> <font color = red>[department] announcement:</font color> [html_encode(message)]</font size></b>"
		announceAuth = 0
		message = ""
		screen = 0
	if(href_list["department"] && src.message)
		var/log_msg = src.message
		var/message = src.message;
		message += "<br>"
		if (src.msgVerified)
			message += src.msgVerified
			message += "<br>"
		if (src.msgStamped)
			message += src.msgStamped
			message += "<br>"
		src.screen = 7 //if it's successful, this will get overrwritten (7 = unsufccessfull, 6 = successfull)
		if (message)
			for (var/obj/machinery/message_server/MS in world)
				MS.send_rc_message(href_list["department"],src.department,log_msg,msgStamped,msgVerified,priority)
			for (var/obj/machinery/requests_console/CONSOLE in allConsoles)
				if (ckey(CONSOLE.department) == ckey(href_list["department"]))
					if(src.priority == "2") //High priority
						if(CONSOLE.newmessagepriority < 2)
							CONSOLE.newmessagepriority = 2
							CONSOLE.icon_state = "req_comp2"
						if(!CONSOLE.silent)
							playsound(CONSOLE.loc, 'twobeep.ogg', 50, 1)
							for (var/mob/O in hearers(5, CONSOLE.loc))
								O.show_message(text("\icon[CONSOLE] *The Requests Console beeps: 'PRIORITY Alert in [src.department]'"))
						CONSOLE.messages += "<B><FONT color='red'>High Priority message from <A href='?src=\ref[CONSOLE];write=[ckey(src.department)]'>[src.department]</A></FONT></B><BR>[message]"
					else if(src.priority == "3"
					) //Not implemanted, but will be
						if(CONSOLE.newmessagepriority < 3)
							CONSOLE.newmessagepriority = 3
							CONSOLE.icon_state = "req_comp3"
						if(!CONSOLE.silent)
							playsound(CONSOLE.loc, 'twobeep.ogg', 50, 1)
							for (var/mob/O in hearers(7, CONSOLE.loc))
								O.show_message(text("\icon[CONSOLE] *The Requests Console yells: 'EXTREME PRIORITY alert in [src.department]'"))
						CONSOLE.messages += "<B><FONT color='red'>Extreme Priority message from [ckey(src.department)]</FONT></B><BR>[message]"
					else							// Normal priority
						if(CONSOLE.newmessagepriority < 1)
							CONSOLE.newmessagepriority = 1
							CONSOLE.icon_state = "req_comp1"
						if(!CONSOLE.silent)
							playsound(CONSOLE.loc, 'twobeep.ogg', 50, 1)
							for (var/mob/O in hearers(4, CONSOLE.loc))
								O.show_message(text("\icon[CONSOLE] *The Requests Console beeps: 'Message from [src.department]'"))
						CONSOLE.messages += "<B>Message from <A href='?src=\ref[CONSOLE];write=[ckey(src.department)]'>[src.department]</A></FONT></B><BR>[message]"
					src.screen = 6
					CONSOLE.luminosity = 2
			src.messages += "<B>Message sent to [src.dpt]</B><BR>[message]"
	if(href_list["setScreen"])
		src.screen = text2num(href_list["setScreen"])
		if (src.screen == 0)
			dpt = "";
			msgVerified = "";
			msgStamped = "";
			message = "";
			priority = -1;
	if(href_list["setSilent"])
		src.silent = text2num(href_list["setSilent"])
	src.updateUsrDialog()
	return

					//err... hacking code, which has no reason for existing... but anyway... it's supposed to unlock priority 3 messanging on that console (EXTREME priority...) the code for that actually exists.
/obj/machinery/requests_console/attackby(var/obj/item/weapon/O as obj, var/mob/user as mob)
	/*
	if (istype(O, /obj/item/weapon/crowbar))
		if(src.open)
			src.open = 0
			src.icon_state="req_comp0"
		else
			src.open = 1
			if(src.hackState == 0)
				src.icon_state="req_comp_open"
			else if(src.hackState == 1)
				src.icon_state="req_comp_rewired"
	if (istype(O, /obj/item/weapon/screwdriver))
		if(src.open)
			if(src.hackState == 0)
				src.hackState = 1
				src.icon_state="req_comp_rewired"
			else if(src.hackState == 1)
				src.hackState = 0
				src.icon_state="req_comp_open"
		else
			user << "You can't do much with that."*/

	if (istype(O, /obj/item/weapon/card/id))
		if(src.screen == 9)
			var/obj/item/weapon/card/id/T = O
			src.msgVerified = text("<font color='green'><b>Verified by [T.registered] ([T.assignment])</b></font>")
			src.updateUsrDialog()
		if(src.screen == 10)
			var/obj/item/weapon/card/id/ID = O
			if (access_RC_announce in ID.access)
				announceAuth = 1
			else
				announceAuth = 0
				user << "\red You are not authorized to send announcements."
			src.updateUsrDialog()
	if (istype(O, /obj/item/weapon/stamp))
		if(src.screen == 9)
			var/obj/item/weapon/stamp/T = O
			src.msgStamped = text("<font color='blue'><b>Stamped with the [T.name]</b></font>")
			src.updateUsrDialog()
	return