GLOBAL_LIST_EMPTY(req_console_assistance)
GLOBAL_LIST_EMPTY(req_console_supplies)
GLOBAL_LIST_EMPTY(req_console_information)
GLOBAL_LIST_EMPTY(req_console_all)
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

#define REQ_EMERGENCY_SECURITY "Security"
#define REQ_EMERGENCY_ENGINEERING "Engineering"
#define REQ_EMERGENCY_MEDICAL "Medical"

/obj/machinery/requests_console
	name = "requests console"
	desc = "A console intended to send requests to different departments on the station."
	icon = 'icons/obj/terminals.dmi'
	icon_state = "req_comp_off"
	base_icon_state = "req_comp"
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * 0.15
	max_integrity = 300
	armor_type = /datum/armor/machinery_requests_console
	/// Reference to our area
	var/area/area
	/// Is autonaming by area on?
	var/auto_name = FALSE
	/// Department name (Determined from this variable on each unit) Set this to the same thing if you want several consoles in one department
	var/department = ""
	/// List of all messages
	var/list/messages = list()
	/// Priority of the latest message
	var/new_message_priority = REQ_NO_NEW_MESSAGE
	// Is the console silent? Set to TRUE for it not to beep all the time
	var/silent = FALSE
	// Is the console hacked? Enables EXTREME priority if TRUE
	var/hack_state = FALSE
	/// FALSE = This console cannot be used to send department announcements, TRUE = This console can send department announcements
	var/can_send_announcements = FALSE
	// TRUE if maintenance panel is open
	var/open = FALSE
	/// Will be set to TRUE when you authenticate yourself for announcements
	var/announcement_authenticated = FALSE
	/// Will contain the name of the person who verified it
	var/message_verified_by = ""
	/// If a message is stamped, this will contain the stamp name
	var/message_stamped_by = ""
	/// Reference to the internal radio
	var/obj/item/radio/radio
	///If an emergency has been called by this device. Acts as both a cooldown and lets the responder know where it the emergency was triggered from
	var/emergency
	/// If ore redemption machines will send an update when it receives new ores.
	var/receive_ore_updates = FALSE
	/// Can others request assistance from this terminal?
	var/assistance_requestable = FALSE
	/// Can others request supplies from this terminal?
	var/supplies_requestable = FALSE
	/// Can you relay information to this console?
	var/anon_tips_receiver = FALSE
	/// Did we error in the last mail?
	var/has_mail_send_error = FALSE

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
	set_light(1.5, 0.7, "#34D352")//green light

/obj/machinery/requests_console/examine(mob/user)
	. = ..()
	if(!open)
		. += span_notice("It looks like you can pry open the panel with <b>a crowbar</b>.")
	else
		. += span_warning("The panel was pried open, you can close it with <b>a crowbar</b>.")

	if(hack_state)
		. += span_warning("The console seems to have been tampered with!")

/obj/machinery/requests_console/update_overlays()
	. = ..()

	if(open)
		. += mutable_appearance(icon, "req_comp_open")

	if(open || (machine_stat & NOPOWER))
		return

	var/screen_state

	if(emergency || (new_message_priority == REQ_EXTREME_MESSAGE_PRIORITY))
		screen_state = "[base_icon_state]3"
	else if(new_message_priority == REQ_HIGH_MESSAGE_PRIORITY)
		screen_state = "[base_icon_state]2"
	else if(new_message_priority == REQ_NORMAL_MESSAGE_PRIORITY)
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

	GLOB.req_console_all += src

	if((assistance_requestable)) // adding to assistance list if not already present
		GLOB.req_console_assistance |= department

	if((supplies_requestable)) // supplier list
		GLOB.req_console_supplies |= department

	if((anon_tips_receiver)) // tips lists
		GLOB.req_console_information |= department

	GLOB.req_console_ckey_departments[ckey(department)] = department // and then we set ourselves a listed name

	radio = new /obj/item/radio(src)
	radio.set_listening(FALSE)

/obj/machinery/requests_console/Destroy()
	QDEL_NULL(radio)
	GLOB.req_console_all -= src
	return ..()

/obj/machinery/requests_console/ui_interact(mob/user, datum/tgui/ui)
	if(open)
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RequestsConsole")
		ui.set_autoupdate(FALSE)
		ui.open()

/obj/machinery/requests_console/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("clear_header_and_verification")
			message_stamped_by = null
			message_verified_by = null
			announcement_authenticated = FALSE
			has_mail_send_error = FALSE
			for (var/obj/machinery/requests_console/console in GLOB.req_console_all)
				if (console.department == department)
					console.new_message_priority = REQ_NO_NEW_MESSAGE
					console.update_appearance()
			return TRUE
		if("toggle_silent")
			silent = !silent
			return TRUE
		if("set_emergency")
			if(emergency)
				return
			var/radio_freq
			switch(params["emergency"])
				if(REQ_EMERGENCY_SECURITY) //Security
					radio_freq = FREQ_SECURITY
				if(REQ_EMERGENCY_ENGINEERING) //Engineering
					radio_freq = FREQ_ENGINEERING
				if(REQ_EMERGENCY_MEDICAL) //Medical
					radio_freq = FREQ_MEDICAL
			if(radio_freq)
				emergency = params["emergency"]
				radio.set_frequency(radio_freq)
				radio.talk_into(src,"[emergency] emergency in [department]!!",radio_freq)
				update_appearance()
				addtimer(CALLBACK(src, PROC_REF(clear_emergency)), 5 MINUTES)
			return TRUE
		if("send_message")
			var/recipient = params["recipient"]
			if(!recipient)
				return
			var/priority = params["priority"]
			if(!priority)
				return
			var/message = params["message"]
			if(!message)
				return
			var/request_type = params["request_type"]
			if(!request_type)
				return
			var/list/authentication_data = params["authentication_data"]


			var/radio_freq
			switch(ckey(recipient))
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
				"rec_dpt" = recipient,
				"send_dpt" = department,
				"message" = message,
				"verified" = authentication_data["message_verified_by"],
				"stamped" = authentication_data["message_stamped_by"],
				"priority" = priority,
				"notify_freq" = radio_freq
			))
			signal.send_to_receivers()

			has_mail_send_error = signal.data["done"]

			if(!silent)
				playsound(src, 'sound/machines/twobeep.ogg', 50, TRUE)

/obj/machinery/requests_console/ui_data(mob/user)
	var/list/data = list()
	data["can_send_announcements"] = can_send_announcements
	data["department"] = department
	data["emergency"] = emergency
	data["hack_state"] = hack_state
	data["new_message_priority"] = new_message_priority
	data["silent"] = silent
	data["has_mail_send_error"] = has_mail_send_error
	data["authentication_data"] = list(
		"message_verified_by" = message_verified_by,
		"message_stamped_by" = message_stamped_by,
		"announcement_authenticated" = announcement_authenticated,
	)
	data["messages"] = list()
	for (var/message in messages)
		var/list/message_data = list(
			content = message,
			)
		data["messages"] += list(message_data)
	return data


/obj/machinery/requests_console/ui_static_data(mob/user)
	var/list/data = list()

	data["assistance_consoles"] = GLOB.req_console_assistance - department
	data["supply_consoles"] = GLOB.req_console_supplies - department
	data["information_consoles"] = GLOB.req_console_information - department

	return data

/obj/machinery/requests_console/say_mod(input, list/message_mods = list())
	if(spantext_char(input, "!", -3))
		return "blares"
	else
		. = ..()

/// Turns the emergency console back to its normal sprite once the emergency has timed out
/obj/machinery/requests_console/proc/clear_emergency()
	emergency = null
	update_appearance()

/// From message_server.dm: Console.create_message(data["sender"], data["send_dpt"], data["message"], data["verified"], data["stamped"], data["priority"], data["notify_freq"])
/obj/machinery/requests_console/proc/create_message(source, source_department, message, message_verified_by, message_stamped_by, priority, radio_freq)
	var/linkedsender

	var/sending = "[message]<br>"
	if(message_verified_by)
		sending = "[sending][message_verified_by]<br>"
	if(message_stamped_by)
		sending = "[sending][message_stamped_by]<br>"

	linkedsender = source_department ? "<a href='?src=[REF(src)];write=[ckey(source_department)]'>[source_department]</a>" : (source || "unknown")

	var/authentic = (message_verified_by || message_stamped_by) && " (Authenticated)"
	var/alert = "Message from [source][authentic]"
	var/silenced = silent
	var/header = "<b>From:</b> [linkedsender] Received: [station_time_timestamp()]<BR>"

	switch(priority)
		if(REQ_NORMAL_MESSAGE_PRIORITY)
			if(new_message_priority < REQ_NORMAL_MESSAGE_PRIORITY)
				new_message_priority = REQ_NORMAL_MESSAGE_PRIORITY
				update_appearance()

		if(REQ_HIGH_MESSAGE_PRIORITY)
			header = "<span class='bad'>High Priority</span><BR>[header]"
			alert = "PRIORITY Alert from [source][authentic]"
			if(new_message_priority < REQ_HIGH_MESSAGE_PRIORITY)
				new_message_priority = REQ_HIGH_MESSAGE_PRIORITY
				update_appearance()

		if(REQ_EXTREME_MESSAGE_PRIORITY)
			header = "<span class='bad'>!!!Extreme Priority!!!</span><BR>[header]"
			alert = "EXTREME PRIORITY Alert from [source][authentic]"
			silenced = FALSE
			if(new_message_priority < REQ_EXTREME_MESSAGE_PRIORITY)
				new_message_priority = REQ_EXTREME_MESSAGE_PRIORITY
				update_appearance()

	messages.Insert(1, "[header][sending]") //reverse order

	SStgui.update_uis(src)

	if(!silenced)
		playsound(src, 'sound/machines/twobeep_high.ogg', 50, TRUE)
		say(alert)

	if(radio_freq)
		radio.set_frequency(radio_freq)
		radio.talk_into(src, "[alert]: <i>[message]</i>", radio_freq)

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
		hack_state = !hack_state
		if(hack_state)
			to_chat(user, span_notice("You modify the wiring."))
		else
			to_chat(user, span_notice("You reset the wiring."))
		update_appearance()
		tool.play_tool_sound(src, 50)
	else
		to_chat(user, span_warning("You must open the maintenance panel first!"))
	return TRUE

/obj/machinery/requests_console/attackby(obj/item/attacking_item, mob/user, params)
	var/obj/item/card/id/ID = attacking_item.GetID()
	if(ID)
		message_verified_by = "[ID.registered_name] ([ID.assignment])"
		SStgui.update_uis(src)
		announcement_authenticated = (ACCESS_RC_ANNOUNCE in ID.access)
		SStgui.update_uis(src)
		return
	if (istype(attacking_item, /obj/item/stamp))
		var/obj/item/stamp/attacking_stamp = attacking_item
		message_stamped_by = attacking_stamp.name
		SStgui.update_uis(src)
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
