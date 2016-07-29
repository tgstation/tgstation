<<<<<<< HEAD
/******************** Requests Console ********************/
/** Originally written by errorage, updated by: Carn, needs more work though. I just added some security fixes */

var/req_console_assistance = list()
var/req_console_supplies = list()
var/req_console_information = list()
var/list/obj/machinery/requests_console/allConsoles = list()

/obj/machinery/requests_console
	name = "requests console"
	desc = "A console intended to send requests to different departments on the station."
	anchored = 1
	icon = 'icons/obj/terminals.dmi'
	icon_state = "req_comp0"
	var/department = "Unknown" //The list of all departments on the station (Determined from this variable on each unit) Set this to the same thing if you want several consoles in one department
	var/list/messages = list() //List of all messages
	var/departmentType = 0
		// 0 = none (not listed, can only replied to)
		// 1 = assistance
		// 2 = supplies
		// 3 = info
		// 4 = ass + sup //Erro goddamn you just HAD to shorten "assistance" down to "ass"
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
		// 1 = This console can send department announcements
	var/open = 0 // 1 if open
	var/announceAuth = 0 //Will be set to 1 when you authenticate yourself for announcements
	var/msgVerified = "" //Will contain the name of the person who verified it
	var/msgStamped = "" //If a message is stamped, this will contain the stamp name
	var/message = "";
	var/dpt = ""; //the department which will be receiving the message
	var/priority = -1 ; //Priority of the message being sent
	var/obj/item/device/radio/Radio
	var/emergency //If an emergency has been called by this device. Acts as both a cooldown and lets the responder know where it the emergency was triggered from
	luminosity = 0

/obj/machinery/requests_console/power_change()
	..()
	update_icon()

/obj/machinery/requests_console/update_icon()
	if(open)
		if(!hackState)
			icon_state="req_comp_open"
		else
			icon_state="req_comp_rewired"
	else if(stat & NOPOWER)
		if(icon_state != "req_comp_off")
			icon_state = "req_comp_off"
	else
		if(emergency || (newmessagepriority == 3))
			icon_state = "req_comp3"
		else if(newmessagepriority == 2)
			icon_state = "req_comp2"
		else if(newmessagepriority == 1)
			icon_state = "req_comp1"
		else
			icon_state = "req_comp0"

/obj/machinery/requests_console/New()
	name = "\improper [department] requests console"
	allConsoles += src
	//req_console_departments += department
	switch(departmentType)
		if(1)
			if(!("[department]" in req_console_assistance))
				req_console_assistance += department
		if(2)
			if(!("[department]" in req_console_supplies))
				req_console_supplies += department
		if(3)
			if(!("[department]" in req_console_information))
				req_console_information += department
		if(4)
			if(!("[department]" in req_console_assistance))
				req_console_assistance += department
			if(!("[department]" in req_console_supplies))
				req_console_supplies += department
		if(5)
			if(!("[department]" in req_console_assistance))
				req_console_assistance += department
			if(!("[department]" in req_console_information))
				req_console_information += department
		if(6)
			if(!("[department]" in req_console_supplies))
				req_console_supplies += department
			if(!("[department]" in req_console_information))
				req_console_information += department
		if(7)
			if(!("[department]" in req_console_assistance))
				req_console_assistance += department
			if(!("[department]" in req_console_supplies))
				req_console_supplies += department
			if(!("[department]" in req_console_information))
				req_console_information += department

	Radio = new /obj/item/device/radio(src)
	Radio.listening = 0

/obj/machinery/requests_console/attack_hand(mob/user)
	if(..())
		return
	var/dat = ""
	if(!open)
		switch(screen)
			if(1)	//req. assistance
				dat += "Which department do you need assistance from?<BR><BR>"
				dat += "<table width='100%'>"
				for(var/dpt in req_console_assistance)
					if (dpt != department)
						dat += "<tr>"
						dat += "<td width='55%'>[dpt]</td>"
						dat += "<td width='45%'><A href='?src=\ref[src];write=[ckey(dpt)]'>Normal</A> <A href='?src=\ref[src];write=[ckey(dpt)];priority=2'>High</A>"
						if(hackState)
							dat += "<A href='?src=\ref[src];write=[ckey(dpt)];priority=3'>EXTREME</A>"
						dat += "</td>"
						dat += "</tr>"
				dat += "</table>"
				dat += "<BR><A href='?src=\ref[src];setScreen=0'><< Back</A><BR>"

			if(2)	//req. supplies
				dat += "Which department do you need supplies from?<BR><BR>"
				dat += "<table width='100%'>"
				for(var/dpt in req_console_supplies)
					if (dpt != department)
						dat += "<tr>"
						dat += "<td width='55%'>[dpt]</td>"
						dat += "<td width='45%'><A href='?src=\ref[src];write=[ckey(dpt)]'>Normal</A> <A href='?src=\ref[src];write=[ckey(dpt)];priority=2'>High</A>"
						if(hackState)
							dat += "<A href='?src=\ref[src];write=[ckey(dpt)];priority=3'>EXTREME</A>"
						dat += "</td>"
						dat += "</tr>"
				dat += "</table>"
				dat += "<BR><A href='?src=\ref[src];setScreen=0'><< Back</A><BR>"

			if(3)	//relay information
				dat += "Which department would you like to send information to?<BR><BR>"
				dat += "<table width='100%'>"
				for(var/dpt in req_console_information)
					if (dpt != department)
						dat += "<tr>"
						dat += "<td width='55%'>[dpt]</td>"
						dat += "<td width='45%'><A href='?src=\ref[src];write=[ckey(dpt)]'>Normal</A> <A href='?src=\ref[src];write=[ckey(dpt)];priority=2'>High</A>"
						if(hackState)
							dat += "<A href='?src=\ref[src];write=[ckey(dpt)];priority=3'>EXTREME</A>"
						dat += "</td>"
						dat += "</tr>"
				dat += "</table>"
				dat += "<BR><A href='?src=\ref[src];setScreen=0'><< Back</A><BR>"

			if(6)	//sent successfully
				dat += "<span class='good'>Message sent.</span><BR><BR>"
				dat += "<A href='?src=\ref[src];setScreen=0'>Continue</A><BR>"

			if(7)	//unsuccessful; not sent
				dat += "<span class='bad'>An error occurred.</span><BR><BR>"
				dat += "<A href='?src=\ref[src];setScreen=0'>Continue</A><BR>"

			if(8)	//view messages
				for (var/obj/machinery/requests_console/Console in allConsoles)
					if (Console.department == department)
						Console.newmessagepriority = 0
						Console.update_icon()
						Console.SetLuminosity(1)
				newmessagepriority = 0
				update_icon()
				var/messageComposite = ""
				for(var/msg in messages) // This puts more recent messages at the *top*, where they belong.
					messageComposite = "<div class='block'>[msg]</div>" + messageComposite
				dat += messageComposite
				dat += "<BR><A href='?src=\ref[src];setScreen=0'><< Back to Main Menu</A><BR>"

			if(9)	//authentication before sending
				dat += "<B>Message Authentication</B><BR><BR>"
				dat += "<b>Message for [dpt]: </b>[message]<BR><BR>"
				dat += "<div class='notice'>You may authenticate your message now by scanning your ID or your stamp</div><BR>"
				dat += "<b>Validated by:</b> [msgVerified ? msgVerified : "<i>Not Validated</i>"]<br>"
				dat += "<b>Stamped by:</b> [msgStamped ? msgStamped : "<i>Not Stamped</i>"]<br><br>"
				dat += "<A href='?src=\ref[src];department=[dpt]'>Send Message</A><BR>"
				dat += "<BR><A href='?src=\ref[src];setScreen=0'><< Discard Message</A><BR>"

			if(10)	//send announcement
				dat += "<h3>Station-wide Announcement</h3>"
				if(announceAuth)
					dat += "<div class='notice'>Authentication accepted</div><BR>"
				else
					dat += "<div class='notice'>Swipe your card to authenticate yourself</div><BR>"
				dat += "<b>Message: </b>[message ? message : "<i>No Message</i>"]<BR>"
				dat += "<A href='?src=\ref[src];writeAnnouncement=1'>[message ? "Edit" : "Write"] Message</A><BR><BR>"
				if ((announceAuth || IsAdminGhost(user)) && message)
					dat += "<A href='?src=\ref[src];sendAnnouncement=1'>Announce Message</A><BR>"
				else
					dat += "<span class='linkOff'>Announce Message</span><BR>"
				dat += "<BR><A href='?src=\ref[src];setScreen=0'><< Back</A><BR>"

			else	//main menu
				screen = 0
				announceAuth = 0
				if (newmessagepriority == 1)
					dat += "<div class='notice'>There are new messages</div><BR>"
				if (newmessagepriority == 2)
					dat += "<div class='notice'>There are new <b>PRIORITY</b> messages</div><BR>"
				if (newmessagepriority == 3)
					dat += "<div class='notice'>There are new <b>EXTREME PRIORITY</b> messages</div><BR>"
				dat += "<A href='?src=\ref[src];setScreen=8'>View Messages</A><BR><BR>"

				dat += "<A href='?src=\ref[src];setScreen=1'>Request Assistance</A><BR>"
				dat += "<A href='?src=\ref[src];setScreen=2'>Request Supplies</A><BR>"
				dat += "<A href='?src=\ref[src];setScreen=3'>Relay Anonymous Information</A><BR><BR>"

				if(!emergency)
					dat += "<A href='?src=\ref[src];emergency=1'>Emergency: Security</A><BR>"
					dat += "<A href='?src=\ref[src];emergency=2'>Emergency: Engineering</A><BR>"
					dat += "<A href='?src=\ref[src];emergency=3'>Emergency: Medical</A><BR><BR>"
				else
					dat += "<B><font color='red'>[emergency] has been dispatched to this location.</font></B><BR><BR>"

				if(announcementConsole)
					dat += "<A href='?src=\ref[src];setScreen=10'>Send Station-wide Announcement</A><BR><BR>"
				if (silent)
					dat += "Speaker <A href='?src=\ref[src];setSilent=0'>OFF</A>"
				else
					dat += "Speaker <A href='?src=\ref[src];setSilent=1'>ON</A>"

		//user << browse("[dat]", "window=request_console")
		//onclose(user, "req_console")
		var/datum/browser/popup = new(user, "req_console", "[department] Requests Console", 450, 440)
		popup.set_content(dat)
		popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
		popup.open()
	return

/obj/machinery/requests_console/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)
	add_fingerprint(usr)

	if(reject_bad_text(href_list["write"]))
		dpt = ckey(href_list["write"]) //write contains the string of the receiving department's name

		var/new_message = copytext(reject_bad_text(input(usr, "Write your message:", "Awaiting Input", "")),1,MAX_MESSAGE_LEN)
		if(new_message)
			message = new_message
			screen = 9
			if (text2num(href_list["priority"]) < 2)
				priority = -1
			else
				priority = text2num(href_list["priority"])
		else
			dpt = "";
			msgVerified = ""
			msgStamped = ""
			screen = 0
			priority = -1

	if(href_list["writeAnnouncement"])
		var/new_message = copytext(reject_bad_text(input(usr, "Write your message:", "Awaiting Input", "")),1,MAX_MESSAGE_LEN)
		if(new_message)
			message = new_message
			if (text2num(href_list["priority"]) < 2)
				priority = -1
			else
				priority = text2num(href_list["priority"])
		else
			message = ""
			announceAuth = 0
			screen = 0

	if(href_list["sendAnnouncement"])
		if(!announcementConsole)
			return
		minor_announce(message, "[department] Announcement:")
		news_network.SubmitArticle(message, department, "Station Announcements", null)
		log_say("[key_name(usr)] has made a station announcement: [message]")
		message_admins("[key_name_admin(usr)] has made a station announcement.")
		announceAuth = 0
		message = ""
		screen = 0

	if(href_list["emergency"])
		if(!emergency)
			var/radio_freq
			switch(text2num(href_list["emergency"]))
				if(1) //Security
					radio_freq = SEC_FREQ
					emergency = "Security"
				if(2) //Engineering
					radio_freq = ENG_FREQ
					emergency = "Engineering"
				if(3) //Medical
					radio_freq = MED_FREQ
					emergency = "Medical"
			if(radio_freq)
				Radio.set_frequency(radio_freq)
				Radio.talk_into(src,"[emergency] emergency in [department]!!",radio_freq)
				update_icon()
				spawn(3000)
					emergency = null
					update_icon()

	if( href_list["department"] && message )
		var/log_msg = message
		var/sending = message
		sending += "<br>"
		if (msgVerified)
			sending += msgVerified
			sending += "<br>"
		if (msgStamped)
			sending += msgStamped
			sending += "<br>"
		screen = 7 //if it's successful, this will get overrwritten (7 = unsufccessfull, 6 = successfull)
		if (sending)
			var/pass = 0
			for (var/obj/machinery/message_server/MS in machines)
				if(!MS.active) continue
				MS.send_rc_message(href_list["department"],department,log_msg,msgStamped,msgVerified,priority)
				pass = 1

			if(pass)
				var/radio_freq = 0
				switch(href_list["department"])
					if("bridge")
						radio_freq = COMM_FREQ
					if("medbay")
						radio_freq = MED_FREQ
					if("science")
						radio_freq = SCI_FREQ
					if("engineering")
						radio_freq = ENG_FREQ
					if("security")
						radio_freq = SEC_FREQ
					if("cargobay" || "mining")
						radio_freq = SUPP_FREQ
				Radio.set_frequency(radio_freq)
				var/authentic
				if(msgVerified || msgStamped)
					authentic = " (Authenticated)"

				var/alert = ""
				for (var/obj/machinery/requests_console/Console in allConsoles)
					if (ckey(Console.department) == ckey(href_list["department"]))
						switch(priority)
							if(2)		//High priority
								alert = "PRIORITY Alert in [department][authentic]"
								Console.createmessage(src, alert, sending, 2, 1)
							if(3)		// Extreme Priority
								alert = "EXTREME PRIORITY Alert from [department][authentic]"
								Console.createmessage(src, alert , sending, 3, 1)
							else		// Normal priority
								alert = "Message from [department][authentic]"
								Console.createmessage(src, alert , sending, 1, 1)
						screen = 6
						Console.SetLuminosity(2)

				if(radio_freq)
					Radio.talk_into(src,"[alert]: <i>[message]</i>",radio_freq)

				switch(priority)
					if(2)
						messages += "<span class='bad'>High Priority</span><BR><b>To:</b> [dpt]<BR>[sending]"
					else
						messages += "<b>To: [dpt]</b><BR>[sending]"
			else
				say("NOTICE: No server detected!")


	//Handle screen switching
	switch(text2num(href_list["setScreen"]))
		if(null)	//skip
		if(1)		//req. assistance
			screen = 1
		if(2)		//req. supplies
			screen = 2
		if(3)		//relay information
			screen = 3
//		if(4)		//write message
//			screen = 4
		if(5)		//choose priority
			screen = 5
		if(6)		//sent successfully
			screen = 6
		if(7)		//unsuccessfull; not sent
			screen = 7
		if(8)		//view messages
			screen = 8
		if(9)		//authentication
			screen = 9
		if(10)		//send announcement
			if(!announcementConsole)
				return
			screen = 10
		else		//main menu
			dpt = ""
			msgVerified = ""
			msgStamped = ""
			message = ""
			priority = -1
			screen = 0

	//Handle silencing the console
	switch( href_list["setSilent"] )
		if(null)	//skip
		if("1")
			silent = 1
		else
			silent = 0

	updateUsrDialog()
	return

/obj/machinery/say_quote(input, list/spans)
	var/ending = copytext(input, length(input) - 2)
	if (ending == "!!!")
		return "blares, \"[attach_spans(input, spans)]\""

	return ..()

/obj/machinery/requests_console/proc/createmessage(source, title, message, priority)
	var/linkedsender
	if(istype(source, /obj/machinery/requests_console))
		var/obj/machinery/requests_console/sender = source
		linkedsender = "<a href='?src=\ref[src];write=[ckey(sender.department)]'>[sender.department]</a>"
	else
		capitalize(source)
		linkedsender = source
	capitalize(title)
	switch(priority)
		if(2)		//High priority
			if(src.newmessagepriority < 2)
				src.newmessagepriority = 2
				src.update_icon()
			if(!src.silent)
				playsound(src.loc, 'sound/machines/twobeep.ogg', 50, 1)
				say(title)
				src.messages += "<span class='bad'>High Priority</span><BR><b>From:</b> [linkedsender]<BR>[message]"

		if(3)		// Extreme Priority
			if(src.newmessagepriority < 3)
				src.newmessagepriority = 3
				src.update_icon()
			if(1)
				playsound(src.loc, 'sound/machines/twobeep.ogg', 50, 1)
				say(title)
			src.messages += "<span class='bad'>!!!Extreme Priority!!!</span><BR><b>From:</b> [linkedsender]<BR>[message]"

		else		// Normal priority
			if(src.newmessagepriority < 1)
				src.newmessagepriority = 1
				src.update_icon()
			if(!src.silent)
				playsound(src.loc, 'sound/machines/twobeep.ogg', 50, 1)
				say(title)
			src.messages += "<b>From:</b> [linkedsender]<BR>[message]"
	SetLuminosity(2)

/obj/machinery/requests_console/attackby(obj/item/weapon/O, mob/user, params)
	if(istype(O, /obj/item/weapon/crowbar))
		if(open)
			user << "<span class='notice'>You close the maintenance panel.</span>"
			open = 0
		else
			user << "<span class='notice'>You open the maintenance panel.</span>"
			open = 1
		update_icon()
		return
	if(istype(O, /obj/item/weapon/screwdriver))
		if(open)
			hackState = !hackState
			if(hackState)
				user << "<span class='notice'>You modify the wiring.</span>"
			else
				user << "<span class='notice'>You reset the wiring.</span>"
			update_icon()
		else
			user << "<span class='warning'>You must open the maintenance panel first!</span>"
		return

	var/obj/item/weapon/card/id/ID = O.GetID()
	if(ID)
		if(screen == 9)
			msgVerified = "<font color='green'><b>Verified by [ID.registered_name] ([ID.assignment])</b></font>"
			updateUsrDialog()
		if(screen == 10)
			if (access_RC_announce in ID.access)
				announceAuth = 1
			else
				announceAuth = 0
				user << "<span class='warning'>You are not authorized to send announcements!</span>"
			updateUsrDialog()
		return
	if (istype(O, /obj/item/weapon/stamp))
		if(screen == 9)
			var/obj/item/weapon/stamp/T = O
			msgStamped = "<span class='boldnotice'>Stamped with the [T.name]</span>"
			updateUsrDialog()
		return
	return ..()
=======
/******************** Requests Console ********************/

var/req_console_assistance = list()
var/req_console_supplies = list()
var/req_console_information = list()
var/list/obj/machinery/requests_console/allConsoles = list()

/obj/machinery/requests_console
	name = "requests console"
	desc = "A console intended to send requests to diferent departments on the station."
	anchored = 1
	icon = 'icons/obj/terminals.dmi'
	icon_state = "req_comp0"
	var/department = "Unknown" //The list of all departments on the station (Determined from this variable on each unit) Set this to the same thing if you want several consoles in one department
	var/list/messages = list() //List of all messages
	var/departmentType = 0
		// 0 = none (not listed, can only repeplied to)
		// 1 = assistance
		// 2 = supplies
		// 3 = info
		// 4 = ass + sup //Erro goddamn you just HAD to shorten "assistance" down to "ass"
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
		// 5 = configure panel
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
	var/announceSound = 'sound/vox/bloop.wav'
	luminosity = 0

/obj/machinery/requests_console/power_change()
	..()
	update_icon()

/obj/machinery/requests_console/update_icon()
	if(stat & NOPOWER)
		if(icon_state != "req_comp_off")
			icon_state = "req_comp_off"
	else
		if(icon_state == "req_comp_off")
			icon_state = "req_comp0"

/obj/machinery/requests_console/New()
	allConsoles.Add(src)
	set_department(department,departmentType)
	return ..()

/obj/machinery/requests_console/proc/set_department(var/name, var/D)
	department = name
	departmentType = D
	name = "[department] Requests Console"
	if("[department]" in req_console_assistance)
		req_console_assistance -= department
	if("[department]" in req_console_supplies)
		req_console_supplies -= department
	if("[department]" in req_console_information)
		req_console_information -= department
	switch(departmentType)
		if(1)
			if(!("[department]" in req_console_assistance))
				req_console_assistance += department
		if(2)
			if(!("[department]" in req_console_supplies))
				req_console_supplies += department
		if(3)
			if(!("[department]" in req_console_information))
				req_console_information += department
		if(4)
			if(!("[department]" in req_console_assistance))
				req_console_assistance += department
			if(!("[department]" in req_console_supplies))
				req_console_supplies += department
		if(5)
			if(!("[department]" in req_console_assistance))
				req_console_assistance += department
			if(!("[department]" in req_console_information))
				req_console_information += department
		if(6)
			if(!("[department]" in req_console_supplies))
				req_console_supplies += department
			if(!("[department]" in req_console_information))
				req_console_information += department
		if(7)
			if(!("[department]" in req_console_assistance))
				req_console_assistance += department
			if(!("[department]" in req_console_supplies))
				req_console_supplies += department
			if(!("[department]" in req_console_information))
				req_console_information += department

/obj/machinery/requests_console/attack_hand(user as mob)
	if(..(user))
		return
	var/dat
	dat = text("<HEAD><TITLE>Requests Console</TITLE></HEAD><H3>[department] Requests Console</H3>")
	if(!open)
		switch(screen)
			if(1)	//req. assistance
				dat += text("Which department do you need assistance from?<BR><BR>")
				for(var/dpt in req_console_assistance)
					if (dpt != department)
						dat += text("[dpt] (<A href='?src=\ref[src];write=[ckey(dpt)]'>Message</A> or ")
						dat += text("<A href='?src=\ref[src];write=[ckey(dpt)];priority=2'>High Priority</A>")
//						if (hackState == 1)
//							dat += text(" or <A href='?src=\ref[src];write=[ckey(dpt)];priority=3'>EXTREME</A>)")
						dat += text(")<BR>")
				dat += text("<BR><A href='?src=\ref[src];setScreen=0'>Back</A><BR>")

			if(2)	//req. supplies
				dat += text("Which department do you need supplies from?<BR><BR>")
				for(var/dpt in req_console_supplies)
					if (dpt != department)
						dat += text("[dpt] (<A href='?src=\ref[src];write=[ckey(dpt)]'>Message</A> or ")
						dat += text("<A href='?src=\ref[src];write=[ckey(dpt)];priority=2'>High Priority</A>")
//						if (hackState == 1)
//							dat += text(" or <A href='?src=\ref[src];write=[ckey(dpt)];priority=3'>EXTREME</A>)")
						dat += text(")<BR>")
				dat += text("<BR><A href='?src=\ref[src];setScreen=0'>Back</A><BR>")

			if(3)	//relay information
				dat += text("Which department would you like to send information to?<BR><BR>")
				for(var/dpt in req_console_information)
					if (dpt != department)
						dat += text("[dpt] (<A href='?src=\ref[src];write=[ckey(dpt)]'>Message</A> or ")
						dat += text("<A href='?src=\ref[src];write=[ckey(dpt)];priority=2'>High Priority</A>")
//						if (hackState == 1)
//							dat += text(" or <A href='?src=\ref[src];write=[ckey(dpt)];priority=3'>EXTREME</A>)")
						dat += text(")<BR>")
				dat += text("<BR><A href='?src=\ref[src];setScreen=0'>Back</A><BR>")
			if(5)   //configure panel
				dat += text("<B>Configure Panel</B><BR><BR>")
				if(announceAuth)
					dat += text("<b>Authentication accepted</b><BR><BR>")
				else
					dat += text("Swipe your card to authenticate yourself.<BR><BR>")
				if (announceAuth)
					dat += text("Configure department. Set to 0 to release internal locks for deconstruction.<BR><BR>")
					dat += text("<A href='?src=\ref[src];setDepartment=0'>No Contact</A><BR>")
					dat += text("<A href='?src=\ref[src];setDepartment=1'>Assistance</A><BR>")
					dat += text("<A href='?src=\ref[src];setDepartment=2'>Supply</A><BR>")
					dat += text("<A href='?src=\ref[src];setDepartment=3'>Anonymous Tip Recipient</A><BR>")
					dat += text("<A href='?src=\ref[src];setDepartment=4'>Assistance + Supply</A><BR>")
					dat += text("<A href='?src=\ref[src];setDepartment=5'>Assistance + Tips</A><BR>")
					dat += text("<A href='?src=\ref[src];setDepartment=6'>Supply + Tips</A><BR>")
					dat += text("<A href='?src=\ref[src];setDepartment=7'>All</A><BR>")
				dat += text("<BR><A href='?src=\ref[src];setScreen=0'>Back</A><BR>")
			if(6)	//sent successfully
				dat += text("<FONT COLOR='GREEN'>Message sent</FONT><BR><BR>")
				dat += text("<A href='?src=\ref[src];setScreen=0'>Continue</A><BR>")

			if(7)	//unsuccessful; not sent
				dat += text("<FONT COLOR='RED'>An error occurred. </FONT><BR><BR>")
				dat += text("<A href='?src=\ref[src];setScreen=0'>Continue</A><BR>")

			if(8)	//view messages
				for (var/obj/machinery/requests_console/Console in allConsoles)
					if (Console.department == department)
						Console.newmessagepriority = 0
						Console.icon_state = "req_comp0"
						Console.set_light(1)
				newmessagepriority = 0
				icon_state = "req_comp0"
				for(var/msg in messages)
					dat += text("[msg]<BR>")
				dat += text("<A href='?src=\ref[src];setScreen=0'>Back to main menu</A><BR>")

			if(9)	//authentication before sending
				dat += text("<B>Message Authentication</B><BR><BR>")
				dat += text("<b>Message for [dpt]: </b>[message]<BR><BR>")
				dat += text("You may authenticate your message now by scanning your ID or your stamp<BR><BR>")
				dat += text("Validated by: [msgVerified]<br>");
				dat += text("Stamped by: [msgStamped]<br>");
				dat += text("<A href='?src=\ref[src];department=[dpt]'>Send</A><BR>");
				dat += text("<BR><A href='?src=\ref[src];setScreen=0'>Back</A><BR>")

			if(10)	//send announcement
				dat += text("<B>Station wide announcement</B><BR><BR>")
				if(announceAuth)
					dat += text("<b>Authentication accepted</b><BR><BR>")
				else
					dat += text("Swipe your card to authenticate yourself.<BR><BR>")
				dat += text("<b>Message: </b>[message] <A href='?src=\ref[src];writeAnnouncement=1'>Write</A><BR><BR>")
				if (announceAuth && message)
					dat += text("<A href='?src=\ref[src];sendAnnouncement=1'>Announce</A><BR>");
				dat += text("<BR><A href='?src=\ref[src];setScreen=0'>Back</A><BR>")

			else	//main menu
				screen = 0
				announceAuth = 0
				if (newmessagepriority == 1)
					dat += text("<FONT COLOR='RED'>There are new messages</FONT><BR>")
				if (newmessagepriority == 2)
					dat += text("<FONT COLOR='RED'><B>NEW PRIORITY MESSAGES</B></FONT><BR>")
				dat += text("<A href='?src=\ref[src];setScreen=8'>View Messages</A><BR><BR>")

				dat += text("<A href='?src=\ref[src];setScreen=1'>Request Assistance</A><BR>")
				dat += text("<A href='?src=\ref[src];setScreen=2'>Request Supplies</A><BR>")
				dat += text("<A href='?src=\ref[src];setScreen=3'>Relay Anonymous Information</A><BR><BR>")
				dat += text("<A href='?src=\ref[src];setScreen=5'>Configure Panel</A><BR><BR>")
				if(announcementConsole)
					dat += text("<A href='?src=\ref[src];setScreen=10'>Send station-wide announcement</A><BR><BR>")
				if (silent)
					dat += text("Speaker <A href='?src=\ref[src];setSilent=0'>OFF</A>")
				else
					dat += text("Speaker <A href='?src=\ref[src];setSilent=1'>ON</A>")

		user << browse("[dat]", "window=request_console")
		onclose(user, "req_console")
	return

/obj/machinery/requests_console/Topic(href, href_list)
	if(..())	return
	usr.set_machine(src)
	add_fingerprint(usr)

	if(reject_bad_text(href_list["write"]))
		dpt = ckey(href_list["write"]) //write contains the string of the receiving department's name

		var/new_message = copytext(reject_bad_text(input(usr, "Write your message:", "Awaiting Input", "")),1,MAX_MESSAGE_LEN)
		if(new_message)
			message = new_message
			screen = 9
			switch(href_list["priority"])
				if("2")	priority = 2
				else	priority = -1
		else
			dpt = "";
			msgVerified = ""
			msgStamped = ""
			screen = 0
			priority = -1

	if(href_list["writeAnnouncement"])
		var/new_message = copytext(reject_bad_text(input(usr, "Write your message:", "Awaiting Input", "")),1,MAX_MESSAGE_LEN)
		if(new_message)
			message = new_message
			switch(href_list["priority"])
				if("2")	priority = 2
				else	priority = -1
		else
			message = ""
			announceAuth = 0
			screen = 0

	if(href_list["sendAnnouncement"])
		if(!announcementConsole)	return
		for(var/mob/M in player_list)
			if(!istype(M,/mob/new_player) && M.client)
				to_chat(M, "<b><font size = 3><font color = red>[department] announcement:</font color> [message]</font size></b>")
				M << sound(announceSound)
		announceAuth = 0
		message = ""
		screen = 0

	if( href_list["department"] && message )
		var/log_msg = message
		var/sending = message
		sending += "<br>"
		if (msgVerified)
			sending += msgVerified
			sending += "<br>"
		if (msgStamped)
			sending += msgStamped
			sending += "<br>"
		screen = 7 //if it's successful, this will get overrwritten (7 = unsufccessfull, 6 = successfull)
		if (sending)
			var/pass = 0
			for (var/obj/machinery/message_server/MS in message_servers)
				if(!MS.active) continue
				MS.send_rc_message(href_list["department"],department,log_msg,msgStamped,msgVerified,priority)
				pass = 1

			if(pass)

				for (var/obj/machinery/requests_console/Console in allConsoles)
					if (ckey(Console.department) == ckey(href_list["department"]))

						switch(priority)
							if(2)		//High priority
								if(Console.newmessagepriority < 2)
									Console.newmessagepriority = 2
									Console.icon_state = "req_comp3"
								if(!Console.silent)
									playsound(Console.loc, 'sound/machines/request_urgent.ogg', 50, 1)
									say("PRIORITY Alert in [department]")
								Console.messages += "<B><FONT color='red'>High Priority message from <A href='?src=\ref[Console];write=[ckey(department)]'>[department]</A></FONT></B><BR>[sending]"

		//					if("3")		//Not implemanted, but will be 		//Removed as it doesn't look like anybody intends on implimenting it ~Carn
		//						if(Console.newmessagepriority < 3)
		//							Console.newmessagepriority = 3
		//							Console.icon_state = "req_comp3"
		//						if(!Console.silent)
		//							playsound(Console.loc, 'sound/machines/twobeep.ogg', 50, 1)
		//							for (var/mob/O in hearers(7, Console.loc))
		//								O.show_message(text("[bicon(Console)] *The Requests Console yells: 'EXTREME PRIORITY alert in [department]'"))
		//						Console.messages += "<B><FONT color='red'>Extreme Priority message from [ckey(department)]</FONT></B><BR>[message]"

							else		// Normal priority
								if(Console.newmessagepriority < 1)
									Console.newmessagepriority = 1
									Console.icon_state = "req_comp2"
								if(!Console.silent)
									playsound(Console.loc, 'sound/machines/request.ogg', 50, 1)
									say("Message from [department]")
								Console.messages += "<B>Message from <A href='?src=\ref[Console];write=[ckey(department)]'>[department]</A></FONT></B><BR>[message]"

						screen = 6
						Console.set_light(2)
				messages += "<B>Message sent to [dpt]</B><BR>[message]"
			else
				say("NOTICE: No server detected!")


	//Handle screen switching
	switch(text2num(href_list["setScreen"]))
		if(null)	//skip
		if(1)		//req. assistance
			screen = 1
		if(2)		//req. supplies
			screen = 2
		if(3)		//relay information
			screen = 3
//		if(4)		//write message
//			screen = 4
		if(5)		//configure
			screen = 5
		if(6)		//sent successfully
			screen = 6
		if(7)		//unsuccessfull; not sent
			screen = 7
		if(8)		//view messages
			screen = 8
		if(9)		//authentication
			screen = 9
		if(10)		//send announcement
			if(!announcementConsole)	return
			screen = 10
		else		//main menu
			dpt = ""
			msgVerified = ""
			msgStamped = ""
			message = ""
			priority = -1
			screen = 0

	//Handle silencing the console
	switch( href_list["setSilent"] )
		if(null)	//skip
		if("1")	silent = 1
		else	silent = 0

	switch( href_list["setDepartment"] )
		if(null)	//skip
		else
			var/name = reject_bad_text(input(usr,"Name:","Name this department.","Public") as null|text)
			set_department(name,text2num(href_list["setDepartment"]))

	updateUsrDialog()
	return

/obj/machinery/say_quote(var/text)
	var/ending = copytext(text, length(text) - 2)
	if(ending == "!!!")
		return "blares, [text]"

	return "beeps, [text]"

					//deconstruction and hacking
/obj/machinery/requests_console/attackby(var/obj/item/weapon/O as obj, var/mob/user as mob)
	if (iscrowbar(O))
		if(open)
			open = 0
			icon_state="req_comp0"
		else
			open = 1
			if(!hackState)
				icon_state="req_comp_open"
			else
				icon_state="req_comp_rewired"
	if (isscrewdriver(O))
		if(open)
			if(!hackState)
				hackState = 1
				icon_state="req_comp_rewired"
			else
				hackState = 0
				icon_state="req_comp_open"
		else
			to_chat(user, "You can't do much with that.")
	if(iswrench(O) && open && !departmentType)
		user.visible_message("<span class='notice'>[user] disassembles the [src]!</span>", "<span class='notice'>You disassemble the [src]</span>")
		playsound(get_turf(src), 'sound/items/Ratchet.ogg', 100, 1)
		new /obj/item/stack/sheet/metal (src.loc,2)
		qdel(src)
		return
	if (istype(O, /obj/item/weapon/card/id) || istype(O, /obj/item/device/pda))
		if(screen == 5)
			var/obj/item/weapon/card/id/ID = O.GetID()
			if (hackState || ID.access.Find(access_engine_equip))
				announceAuth = 1
			else
				announceAuth = 0
				to_chat(user, "<span class='warning'>You are not authorized to configure this panel.</span>")
			updateUsrDialog()
		if(screen == 9)
			var/obj/item/weapon/card/id/ID = O.GetID()
			msgVerified = "<font color='green'><b>Verified by [ID.registered_name] ([ID.assignment])</b></font>"
			updateUsrDialog()
		if (screen == 10)
			var/obj/item/weapon/card/id/ID = O.GetID()

			if (!isnull(ID) && ID.access.Find(access_RC_announce) || hackState)
				announceAuth = TRUE
			else
				announceAuth = FALSE
				to_chat(user, "<span class='warning'>You are not authorized to send announcements.</span>")

			updateUsrDialog()
	if (istype(O, /obj/item/weapon/stamp))
		if(screen == 9)
			var/obj/item/weapon/stamp/T = O
			msgStamped = text("<font color='blue'><b>Stamped with the [T.name]</b></font>")
			updateUsrDialog()
	return

/obj/machinery/requests_console/mechanic
	name = "\improper Mechanics requests console"
	department = "Mechanics"
	departmentType = 4
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
