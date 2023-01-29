/******************** Requests Console ********************/
/** Originally written by errorage, updated by: Carn, needs more work though. I just added some security fixes */

GLOBAL_LIST_EMPTY(req_console_assistance)
GLOBAL_LIST_EMPTY(req_console_supplies)
GLOBAL_LIST_EMPTY(req_console_information)
GLOBAL_LIST_EMPTY(allConsoles)
GLOBAL_LIST_EMPTY(req_console_ckey_departments)


#define REQ_SCREEN_MAIN 0
#define REQ_SCREEN_REQ_ASSISTANCE 1
#define REQ_SCREEN_REQ_SUPPLIES 2
#define REQ_SCREEN_RELAY 3
#define REQ_SCREEN_WRITE 4
#define REQ_SCREEN_CHOOSE 5
#define REQ_SCREEN_SENT 6
#define REQ_SCREEN_ERR 7
#define REQ_SCREEN_VIEW_MSGS 8
#define REQ_SCREEN_AUTHENTICATE 9
#define REQ_SCREEN_ANNOUNCE 10

#define REQ_EMERGENCY_SECURITY 1
#define REQ_EMERGENCY_ENGINEERING 2
#define REQ_EMERGENCY_MEDICAL 3

/obj/machinery/requests_console
	name = "requests console"
	desc = "A console intended to send requests to different departments on the station."
	icon = 'icons/obj/terminals.dmi'
	icon_state = "req_comp_off"
	base_icon_state = "req_comp"
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * 0.15
	var/area/area // Reference to our area
	var/areastring = null // Mapper helper to tie an apc to another area
	var/auto_name = FALSE // Autonaming by area on?
	var/department = "" //Department name (Determined from this variable on each unit) Set this to the same thing if you want several consoles in one department
	var/list/messages = list() // List of all messages
	var/departmentType = 0 // bitflag, DEPRECATED. If maps no longer contain this var, delete it. Use the flags. -fippe
		// 0 = none (not listed, can only replied to)
		// assistance = 1
		// supplies = 2
		// info = 4
		// assistance + supplies = 3
		// assistance + info = 5
		// supplies + info = 6
		// assistance + supplies + info = 7
	var/newmessagepriority = REQ_NO_NEW_MESSAGE
	var/screen = REQ_SCREEN_MAIN
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
	var/silent = FALSE // set to 1 for it not to beep all the time
	var/hackState = FALSE
	var/announcementConsole = FALSE // FALSE = This console cannot be used to send department announcements, TRUE = This console can send department announcements
	var/open = FALSE // TRUE if open
	var/announceAuth = FALSE //Will be set to 1 when you authenticate yourself for announcements
	var/msgVerified = "" //Will contain the name of the person who verified it
	var/msgStamped = "" //If a message is stamped, this will contain the stamp name
	var/message = ""
	var/to_department = "" //the department which will be receiving the message
	var/priority = REQ_NO_NEW_MESSAGE //Priority of the message being sent
	var/obj/item/radio/Radio
	var/emergency //If an emergency has been called by this device. Acts as both a cooldown and lets the responder know where it the emergency was triggered from
	var/receive_ore_updates = FALSE // If ore redemption machines will send an update when it receives new ores.
	var/assistance_requestable = FALSE // Can others request assistance from this terminal?
	var/supplies_requestable = FALSE // Can others request supplies from this terminal?
	var/anon_tips_receiver = FALSE // Can you relay information to this console?
	max_integrity = 300
	armor_type = /datum/armor/machinery_requests_console

/datum/armor/machinery_requests_console
	melee = 70
	bullet = 30
	laser = 30
	energy = 30
	fire = 90
	acid = 90

/obj/machinery/requests_console/update_appearance(updates=ALL)
	. = ..()
	if(machine_stat & NOPOWER)
		set_light(0)
		return
	set_light(1.4,0.7,"#34D352")//green light

/obj/machinery/requests_console/update_icon_state()
	if(open)
		icon_state = "[base_icon_state]_[hackState ? "rewired" : "open"]"
		return ..()
	icon_state = "[base_icon_state]_off"
	return ..()

/obj/machinery/requests_console/update_overlays()
	. = ..()

	if(open || (machine_stat & NOPOWER))
		return

	var/screen_state

	if(emergency || (newmessagepriority == REQ_EXTREME_MESSAGE_PRIORITY))
		screen_state = "[base_icon_state]3"
	else if(newmessagepriority == REQ_HIGH_MESSAGE_PRIORITY)
		screen_state = "[base_icon_state]2"
	else if(newmessagepriority == REQ_NORMAL_MESSAGE_PRIORITY)
		screen_state = "[base_icon_state]1"
	else
		screen_state = "[base_icon_state]0"

	. += mutable_appearance(icon, screen_state)
	. += emissive_appearance(icon, screen_state, src, alpha = src.alpha)

/obj/machinery/requests_console/Initialize(mapload)
	. = ..()

	// Init by checking our area, stolen from APC code
	area = get_area(loc)

	// Naming and department sets
	if(auto_name) // If autonaming, just pick department and name from the area code.
		department = "[get_area_name(area, TRUE)]"
		name = "\improper [department] requests console"
	else
		if(!(department) && (name != "requests console")) // if we have a map-set name, let's default that for the department.
			department = name
		else if(!(department)) // if we have no department and no name, we'll have to be Unknown.
			department = "Unknown"
			name = "\improper [department] requests console"
		else
			name = "\improper [department] requests console" // and if we have a 'department', our name should reflect that.

	GLOB.allConsoles += src

	if(departmentType) // Do we have department type flags? Old, deletable once all req consoles are cleaned
		if((departmentType & REQ_DEP_TYPE_ASSISTANCE) && !(department in GLOB.req_console_assistance))
			assistance_requestable = TRUE

		if((departmentType & REQ_DEP_TYPE_SUPPLIES) && !(department in GLOB.req_console_supplies))
			supplies_requestable = TRUE

		if((departmentType & REQ_DEP_TYPE_INFORMATION) && !(department in GLOB.req_console_information))
			anon_tips_receiver = TRUE
	// once all request consoles on every map are cleaned, this section above can be deleted

	if((assistance_requestable) && !(department in GLOB.req_console_assistance)) // adding to assistance list if not already present
		GLOB.req_console_assistance += department

	if((supplies_requestable) && !(department in GLOB.req_console_supplies)) // supplier list
		GLOB.req_console_supplies += department

	if((anon_tips_receiver) && !(department in GLOB.req_console_information)) // tips lists
		GLOB.req_console_information += department

	GLOB.req_console_ckey_departments[ckey(department)] = department // and then we set ourselves a listed name

	Radio = new /obj/item/radio(src)
	Radio.set_listening(FALSE)

/obj/machinery/requests_console/Destroy()
	QDEL_NULL(Radio)
	GLOB.allConsoles -= src
	return ..()

/obj/machinery/requests_console/ui_interact(mob/user)
	. = ..()
	var/dat = ""
	if(!open)
		switch(screen)
			if(REQ_SCREEN_MAIN)
				announceAuth = FALSE
				if (newmessagepriority == REQ_NORMAL_MESSAGE_PRIORITY)
					dat += "<div class='notice'>There are new messages</div><BR>"
				else if (newmessagepriority == REQ_HIGH_MESSAGE_PRIORITY)
					dat += "<div class='notice'>There are new <b>PRIORITY</b> messages</div><BR>"
				else if (newmessagepriority == REQ_EXTREME_MESSAGE_PRIORITY)
					dat += "<div class='notice'>There are new <b>EXTREME PRIORITY</b> messages</div><BR>"
				dat += "<A href='?src=[REF(src)];setScreen=[REQ_SCREEN_VIEW_MSGS]'>View Messages</A><BR><BR>"

				dat += "<A href='?src=[REF(src)];setScreen=[REQ_SCREEN_REQ_ASSISTANCE]'>Request Assistance</A><BR>"
				dat += "<A href='?src=[REF(src)];setScreen=[REQ_SCREEN_REQ_SUPPLIES]'>Request Supplies</A><BR>"
				dat += "<A href='?src=[REF(src)];setScreen=[REQ_SCREEN_RELAY]'>Relay Anonymous Information</A><BR><BR>"

				if(!emergency)
					dat += "<A href='?src=[REF(src)];emergency=[REQ_EMERGENCY_SECURITY]'>Emergency: Security</A><BR>"
					dat += "<A href='?src=[REF(src)];emergency=[REQ_EMERGENCY_ENGINEERING]'>Emergency: Engineering</A><BR>"
					dat += "<A href='?src=[REF(src)];emergency=[REQ_EMERGENCY_MEDICAL]'>Emergency: Medical</A><BR><BR>"
				else
					dat += "<B><font color='red'>[emergency] has been dispatched to this location.</font></B><BR><BR>"

				if(announcementConsole)
					dat += "<A href='?src=[REF(src)];setScreen=[REQ_SCREEN_ANNOUNCE]'>Send Station-wide Announcement</A><BR><BR>"
				if (silent)
					dat += "Speaker <A href='?src=[REF(src)];setSilent=0'>OFF</A>"
				else
					dat += "Speaker <A href='?src=[REF(src)];setSilent=1'>ON</A>"
			if(REQ_SCREEN_REQ_ASSISTANCE)
				dat += "Which department do you need assistance from?<BR><BR>"
				dat += departments_table(GLOB.req_console_assistance)

			if(REQ_SCREEN_REQ_SUPPLIES)
				dat += "Which department do you need supplies from?<BR><BR>"
				dat += departments_table(GLOB.req_console_supplies)

			if(REQ_SCREEN_RELAY)
				dat += "Which department would you like to send information to?<BR><BR>"
				dat += departments_table(GLOB.req_console_information)

			if(REQ_SCREEN_SENT)
				dat += "<span class='good'>Message sent.</span><BR><BR>"
				dat += "<A href='?src=[REF(src)];setScreen=[REQ_SCREEN_MAIN]'><< Back</A><BR>"

			if(REQ_SCREEN_ERR)
				dat += "<span class='bad'>An error occurred.</span><BR><BR>"
				dat += "<A href='?src=[REF(src)];setScreen=[REQ_SCREEN_MAIN]'><< Back</A><BR>"

			if(REQ_SCREEN_VIEW_MSGS)
				for (var/obj/machinery/requests_console/Console in GLOB.allConsoles)
					if (Console.department == department)
						Console.newmessagepriority = REQ_NO_NEW_MESSAGE
						Console.update_appearance()

				newmessagepriority = REQ_NO_NEW_MESSAGE
				update_appearance()
				var/messageComposite = ""
				for(var/msg in messages) // This puts more recent messages at the *top*, where they belong.
					messageComposite = "<div class='block'>[msg]</div>" + messageComposite
				dat += messageComposite
				dat += "<BR><A href='?src=[REF(src)];setScreen=[REQ_SCREEN_MAIN]'><< Back to Main Menu</A><BR>"

			if(REQ_SCREEN_AUTHENTICATE)
				dat += "<B>Message Authentication</B><BR><BR>"
				dat += "<b>Message for [to_department]: </b>[message]<BR><BR>"
				dat += "<div class='notice'>You may authenticate your message now by scanning your ID or your stamp</div><BR>"
				dat += "<b>Validated by:</b> [msgVerified ? msgVerified : "<i>Not Validated</i>"]<br>"
				dat += "<b>Stamped by:</b> [msgStamped ? msgStamped : "<i>Not Stamped</i>"]<br><br>"
				dat += "<A href='?src=[REF(src)];send=[TRUE]'>Send Message</A><BR>"
				dat += "<BR><A href='?src=[REF(src)];setScreen=[REQ_SCREEN_MAIN]'><< Discard Message</A><BR>"

			if(REQ_SCREEN_ANNOUNCE)
				dat += "<h3>Station-wide Announcement</h3>"
				if(announceAuth)
					dat += "<div class='notice'>Authentication accepted</div><BR>"
				else
					dat += "<div class='notice'>Swipe your card to authenticate yourself</div><BR>"
				dat += "<b>Message: </b>[message ? message : "<i>No Message</i>"]<BR>"
				dat += "<A href='?src=[REF(src)];writeAnnouncement=1'>[message ? "Edit" : "Write"] Message</A><BR><BR>"
				if ((announceAuth || isAdminGhostAI(user)) && message)
					dat += "<A href='?src=[REF(src)];sendAnnouncement=1'>Announce Message</A><BR>"
				else
					dat += "<span class='linkOff'>Announce Message</span><BR>"
				dat += "<BR><A href='?src=[REF(src)];setScreen=[REQ_SCREEN_MAIN]'><< Back</A><BR>"

		if(!dat)
			CRASH("No UI for src. Screen var is: [screen]")
		var/datum/browser/popup = new(user, "req_console", "[name]", 450, 440)
		popup.set_content(dat)
		popup.open()
	return

/obj/machinery/requests_console/proc/departments_table(list/req_consoles)
	var/dat = ""
	dat += "<table width='100%'>"
	for(var/req_dpt in req_consoles)
		if (req_dpt != department)
			dat += "<tr>"
			dat += "<td width='55%'>[req_dpt]</td>"
			dat += "<td width='45%'><A href='?src=[REF(src)];write=[ckey(req_dpt)];priority=[REQ_NORMAL_MESSAGE_PRIORITY]'>Normal</A> <A href='?src=[REF(src)];write=[ckey(req_dpt)];priority=[REQ_HIGH_MESSAGE_PRIORITY]'>High</A>"
			if(hackState)
				dat += "<A href='?src=[REF(src)];write=[ckey(req_dpt)];priority=[REQ_EXTREME_MESSAGE_PRIORITY]'>EXTREME</A>"
			dat += "</td>"
			dat += "</tr>"
	dat += "</table>"
	dat += "<BR><A href='?src=[REF(src)];setScreen=[REQ_SCREEN_MAIN]'><< Back</A><BR>"
	return dat

/obj/machinery/requests_console/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)
	add_fingerprint(usr)

	if(href_list["write"])
		to_department = ckey(reject_bad_text(href_list["write"])) //write contains the string of the receiving department's name

		var/new_message = (to_department in GLOB.req_console_ckey_departments) && tgui_input_text(usr, "Write your message", "Awaiting Input")
		if(new_message)
			to_department = GLOB.req_console_ckey_departments[to_department]
			message = new_message
			screen = REQ_SCREEN_AUTHENTICATE
			priority = clamp(text2num(href_list["priority"]), REQ_NORMAL_MESSAGE_PRIORITY, REQ_EXTREME_MESSAGE_PRIORITY)

	if(href_list["writeAnnouncement"])
		var/new_message = reject_bad_text(tgui_input_text(usr, "Write your message", "Awaiting Input"))
		if(new_message)
			message = new_message
			priority = clamp(text2num(href_list["priority"]) || REQ_NORMAL_MESSAGE_PRIORITY, REQ_NORMAL_MESSAGE_PRIORITY, REQ_EXTREME_MESSAGE_PRIORITY)
		else
			message = ""
			announceAuth = FALSE
			screen = REQ_SCREEN_MAIN

	if(href_list["sendAnnouncement"])
		if(!announcementConsole)
			return
		if(!(announceAuth || isAdminGhostAI(usr)))
			return
		if(isliving(usr))
			var/mob/living/L = usr
			message = L.treat_message(message)
		minor_announce(message, "[department] Announcement:", html_encode = FALSE)
		GLOB.news_network.submit_article(message, department, "Station Announcements", null)
		usr.log_talk(message, LOG_SAY, tag="station announcement from [src]")
		message_admins("[ADMIN_LOOKUPFLW(usr)] has made a station announcement from [src] at [AREACOORD(usr)].")
		deadchat_broadcast(" made a station announcement from [span_name("[get_area_name(usr, TRUE)]")].", span_name("[usr.real_name]"), usr, message_type=DEADCHAT_ANNOUNCEMENT)
		announceAuth = FALSE
		message = ""
		screen = REQ_SCREEN_MAIN

	if(href_list["emergency"])
		if(!emergency)
			var/radio_freq
			switch(text2num(href_list["emergency"]))
				if(REQ_EMERGENCY_SECURITY) //Security
					radio_freq = FREQ_SECURITY
					emergency = "Security"
				if(REQ_EMERGENCY_ENGINEERING) //Engineering
					radio_freq = FREQ_ENGINEERING
					emergency = "Engineering"
				if(REQ_EMERGENCY_MEDICAL) //Medical
					radio_freq = FREQ_MEDICAL
					emergency = "Medical"
			if(radio_freq)
				Radio.set_frequency(radio_freq)
				Radio.talk_into(src,"[emergency] emergency in [department]!!",radio_freq)
				update_appearance()
				addtimer(CALLBACK(src, PROC_REF(clear_emergency)), 5 MINUTES)

	if(href_list["send"] && message && to_department && priority)

		var/radio_freq
		switch(ckey(to_department))
			if("bridge")
				radio_freq = FREQ_COMMAND
			if("medbay")
				radio_freq = FREQ_MEDICAL
			if("science")
				radio_freq = FREQ_SCIENCE
			if("engineering")
				radio_freq = FREQ_ENGINEERING
			if("security")
				radio_freq = FREQ_SECURITY
			if("cargobay", "mining")
				radio_freq = FREQ_SUPPLY

		var/datum/signal/subspace/messaging/rc/signal = new(src, list(
			"sender" = department,
			"rec_dpt" = to_department,
			"send_dpt" = department,
			"message" = message,
			"verified" = msgVerified,
			"stamped" = msgStamped,
			"priority" = priority,
			"notify_freq" = radio_freq
		))
		signal.send_to_receivers()

		screen = signal.data["done"] ? REQ_SCREEN_SENT : REQ_SCREEN_ERR

	//Handle screen switching
	if(href_list["setScreen"])
		var/set_screen = clamp(text2num(href_list["setScreen"]) || 0, REQ_SCREEN_MAIN, REQ_SCREEN_ANNOUNCE)
		switch(set_screen)
			if(REQ_SCREEN_MAIN)
				to_department = ""
				msgVerified = ""
				msgStamped = ""
				message = ""
				priority = -1
			if(REQ_SCREEN_ANNOUNCE)
				if(!announcementConsole)
					return
		screen = set_screen

	//Handle silencing the console
	if(href_list["setSilent"])
		silent = text2num(href_list["setSilent"]) ? TRUE : FALSE

	updateUsrDialog()

/obj/machinery/requests_console/say_mod(input, list/message_mods = list())
	if(spantext_char(input, "!", -3))
		return "blares"
	else
		. = ..()

/obj/machinery/requests_console/proc/clear_emergency()
	emergency = null
	update_appearance()

//from message_server.dm: Console.createmessage(data["sender"], data["send_dpt"], data["message"], data["verified"], data["stamped"], data["priority"], data["notify_freq"])
/obj/machinery/requests_console/proc/createmessage(source, source_department, message, msgVerified, msgStamped, priority, radio_freq)
	var/linkedsender

	var/sending = "[message]<br>"
	if(msgVerified)
		sending = "[sending][msgVerified]<br>"
	if(msgStamped)
		sending = "[sending][msgStamped]<br>"

	linkedsender = source_department ? "<a href='?src=[REF(src)];write=[ckey(source_department)]'>[source_department]</a>" : (source || "unknown")

	var/authentic = (msgVerified || msgStamped) && " (Authenticated)"
	var/alert = "Message from [source][authentic]"
	var/silenced = silent
	var/header = "<b>From:</b> [linkedsender] Received: [station_time_timestamp()]<BR>"

	switch(priority)
		if(REQ_NORMAL_MESSAGE_PRIORITY)
			if(newmessagepriority < REQ_NORMAL_MESSAGE_PRIORITY)
				newmessagepriority = REQ_NORMAL_MESSAGE_PRIORITY
				update_appearance()

		if(REQ_HIGH_MESSAGE_PRIORITY)
			header = "<span class='bad'>High Priority</span><BR>[header]"
			alert = "PRIORITY Alert from [source][authentic]"
			if(newmessagepriority < REQ_HIGH_MESSAGE_PRIORITY)
				newmessagepriority = REQ_HIGH_MESSAGE_PRIORITY
				update_appearance()

		if(REQ_EXTREME_MESSAGE_PRIORITY)
			header = "<span class='bad'>!!!Extreme Priority!!!</span><BR>[header]"
			alert = "EXTREME PRIORITY Alert from [source][authentic]"
			silenced = FALSE
			if(newmessagepriority < REQ_EXTREME_MESSAGE_PRIORITY)
				newmessagepriority = REQ_EXTREME_MESSAGE_PRIORITY
				update_appearance()

	messages += "[header][sending]"

	if(!silenced)
		playsound(src, 'sound/machines/twobeep_high.ogg', 50, TRUE)
		say(alert)

	if(radio_freq)
		Radio.set_frequency(radio_freq)
		Radio.talk_into(src, "[alert]: <i>[message]</i>", radio_freq)

/obj/machinery/requests_console/crowbar_act(mob/living/user, obj/item/tool)
	tool.play_tool_sound(src, 50)
	if(open)
		to_chat(user, span_notice("You close the maintenance panel."))
		open = FALSE
	else
		to_chat(user, span_notice("You open the maintenance panel."))
		open = TRUE
	update_appearance()
	return TRUE

/obj/machinery/requests_console/screwdriver_act(mob/living/user, obj/item/tool)
	if(open)
		hackState = !hackState
		if(hackState)
			to_chat(user, span_notice("You modify the wiring."))
		else
			to_chat(user, span_notice("You reset the wiring."))
		update_appearance()
		tool.play_tool_sound(src, 50)
	else
		to_chat(user, span_warning("You must open the maintenance panel first!"))
	return TRUE

/obj/machinery/requests_console/attackby(obj/item/O, mob/user, params)
	var/obj/item/card/id/ID = O.GetID()
	if(ID)
		if(screen == REQ_SCREEN_AUTHENTICATE)
			msgVerified = "<font color='green'><b>Verified by [ID.registered_name] ([ID.assignment])</b></font>"
			updateUsrDialog()
		if(screen == REQ_SCREEN_ANNOUNCE)
			if (ACCESS_RC_ANNOUNCE in ID.access)
				announceAuth = TRUE
			else
				announceAuth = FALSE
				to_chat(user, span_warning("You are not authorized to send announcements!"))
			updateUsrDialog()
		return
	if (istype(O, /obj/item/stamp))
		if(screen == REQ_SCREEN_AUTHENTICATE)
			var/obj/item/stamp/T = O
			msgStamped = span_boldnotice("Stamped with the [T.name]")
			updateUsrDialog()
		return
	return ..()

/obj/machinery/requests_console/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		new /obj/item/wallframe/requests_console(loc)
	qdel(src)

/obj/machinery/requests_console/auto_name // Register an autoname variant and then make the directional helpers before undefing all the magic bits
	auto_name = TRUE

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/requests_console, 30)
MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/requests_console/auto_name, 30)

/obj/item/wallframe/requests_console
	name = "requests console"
	desc = "An unmounted requests console. Attach it to a wall to use."
	icon = 'icons/obj/terminals.dmi'
	icon_state = "req_comp_off"
	result_path = /obj/machinery/requests_console/auto_name
	pixel_shift = 30

#undef REQ_EMERGENCY_SECURITY
#undef REQ_EMERGENCY_ENGINEERING
#undef REQ_EMERGENCY_MEDICAL

#undef REQ_SCREEN_MAIN
#undef REQ_SCREEN_REQ_ASSISTANCE
#undef REQ_SCREEN_REQ_SUPPLIES
#undef REQ_SCREEN_RELAY
#undef REQ_SCREEN_WRITE
#undef REQ_SCREEN_CHOOSE
#undef REQ_SCREEN_SENT
#undef REQ_SCREEN_ERR
#undef REQ_SCREEN_VIEW_MSGS
#undef REQ_SCREEN_AUTHENTICATE
#undef REQ_SCREEN_ANNOUNCE
