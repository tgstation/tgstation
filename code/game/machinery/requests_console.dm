GLOBAL_LIST_EMPTY(req_console_assistance)
GLOBAL_LIST_EMPTY(req_console_supplies)
GLOBAL_LIST_EMPTY(req_console_information)
GLOBAL_LIST_EMPTY(req_console_all)
GLOBAL_LIST_EMPTY(req_console_ckey_departments)

#define REQ_EMERGENCY_SECURITY "Security"
#define REQ_EMERGENCY_ENGINEERING "Engineering"
#define REQ_EMERGENCY_MEDICAL "Medical"

#define ANNOUNCEMENT_COOLDOWN_TIME (30 SECONDS)

/obj/machinery/requests_console
	name = "requests console"
	desc = "A console intended to send requests to different departments on the station."
	icon = 'icons/obj/machines/wallmounts.dmi'
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
	///If an emergency has been called by this device. Acts as both a cooldown and lets the responder know where it the emergency was triggered from
	var/emergency
	/// If ore redemption machines will send an update when it receives new ores.
	var/receive_ore_updates = FALSE
	/// Did we error in the last mail?
	var/has_mail_send_error = FALSE
	/// Cooldown to prevent announcement spam
	COOLDOWN_DECLARE(announcement_cooldown)

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

	GLOB.req_console_ckey_departments[ckey(department)] = department // and then we set ourselves a listed name

	// Register this console for RETA UI updates - code/modules/reta/reta_system.dm
	var/dept_key = reta_get_user_department_by_name(department)
	if(dept_key)
		LAZYADD(GLOB.reta_consoles_by_origin[dept_key], src)

	find_and_hang_on_wall()

/obj/machinery/requests_console/Destroy()
	QDEL_LIST(messages)
	GLOB.req_console_all -= src

	// Remove from RETA console registry
	var/dept_key = reta_get_user_department_by_name(department)
	if(dept_key)
		LAZYREMOVE(GLOB.reta_consoles_by_origin[dept_key], src)

	return ..()

/obj/machinery/requests_console/ui_interact(mob/user, datum/tgui/ui)
	if(open)
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RequestsConsole")
		ui.set_autoupdate(FALSE)
		ui.open()

/obj/machinery/requests_console/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("clear_message_status")
			has_mail_send_error = FALSE
			for (var/obj/machinery/requests_console/console in GLOB.req_console_all)
				if (console.department == department)
					console.new_message_priority = REQ_NO_NEW_MESSAGE
					console.update_appearance()
			return TRUE
		if("clear_authentication")
			message_stamped_by = ""
			message_verified_by = ""
			announcement_authenticated = FALSE
			return TRUE
		if("toggle_silent")
			silent = !silent
			return TRUE
		if("set_emergency")
			if(emergency)
				return

			// Check for RETA eligibility
			var/emergency_type = params["emergency"]
			var/origin_dept = reta_get_user_department_by_name(department)
			var/target_dept = null

			switch(emergency_type)
				if(REQ_EMERGENCY_SECURITY)
					target_dept = "Security"
				if(REQ_EMERGENCY_ENGINEERING)
					target_dept = "Engineering"
				if(REQ_EMERGENCY_MEDICAL)
					target_dept = "Medical"

			// Check if user can call this emergency (prevent self-calls) RETA
			var/user_dept = reta_get_user_department(usr)
			if(user_dept == target_dept)
				to_chat(usr, span_alert("You cannot call your own department for emergency assistance."))
				return

			// Check cooldown RETA
			if(origin_dept && target_dept && reta_on_cooldown(origin_dept, target_dept))
				to_chat(usr, span_alert("Emergency calls to [target_dept] are on cooldown."))
				return

			emergency = emergency_type

			// Grant RETA if conditions are met
			if(origin_dept && target_dept && CONFIG_GET(flag/reta_enabled))
				// Set cooldown
				var/cooldown_ds = CONFIG_GET(number/reta_dept_cooldown_ds) || 150
				reta_set_cooldown(origin_dept, target_dept, cooldown_ds)

				// Find responders and grant access to their ID cards
				var/duration_ds = CONFIG_GET(number/reta_duration_ds) || 3000
				var/granted_count = reta_find_and_grant_access(target_dept, origin_dept, duration_ds)

				// Track this call for multiple department analysis
				reta_track_call(origin_dept, target_dept)

				// Enhanced announcement with caller info
				var/caller_info = ""
				if(usr)
					var/caller_name = usr.real_name || "Unknown"
					var/caller_title = "Unknown Position"
					if(usr?.mind?.assigned_role)
						caller_title = usr.mind.assigned_role.title
					caller_info = " (Called by [caller_name], [caller_title])"

				var/enhanced_location = "[department][caller_info]"

				switch(emergency_type)
					if(REQ_EMERGENCY_SECURITY)
						aas_config_announce(/datum/aas_config_entry/rc_emergency, list("LOCATION" = enhanced_location), null, list(RADIO_CHANNEL_SECURITY), REQ_EMERGENCY_SECURITY)
					if(REQ_EMERGENCY_ENGINEERING)
						aas_config_announce(/datum/aas_config_entry/rc_emergency, list("LOCATION" = enhanced_location), null, list(RADIO_CHANNEL_ENGINEERING), REQ_EMERGENCY_ENGINEERING)
					if(REQ_EMERGENCY_MEDICAL)
						aas_config_announce(/datum/aas_config_entry/rc_emergency, list("LOCATION" = enhanced_location), null, list(RADIO_CHANNEL_MEDICAL), REQ_EMERGENCY_MEDICAL)

				// Send confirmation to the calling department about the RETA activation
				var/calling_message = "RETA activated[caller_info]. [target_dept] personnel now have temporary access to your areas."

				// Get an announcement system to send simple radio messages
				var/obj/machinery/announcement_system/announcer = get_announcement_system(null, null, list(RADIO_CHANNEL_COMMON))
				if(announcer)
					switch(origin_dept)
						if("Security")
							announcer.radio.talk_into(announcer, calling_message, RADIO_CHANNEL_SECURITY)
						if("Engineering")
							announcer.radio.talk_into(announcer, calling_message, RADIO_CHANNEL_ENGINEERING)
						if("Medical")
							announcer.radio.talk_into(announcer, calling_message, RADIO_CHANNEL_MEDICAL)
						if("Science")
							announcer.radio.talk_into(announcer, calling_message, RADIO_CHANNEL_SCIENCE)
						if("Service")
							announcer.radio.talk_into(announcer, calling_message, RADIO_CHANNEL_SERVICE)
						if("Command")
							announcer.radio.talk_into(announcer, calling_message, RADIO_CHANNEL_COMMAND)
						if("Cargo")
							announcer.radio.talk_into(announcer, calling_message, RADIO_CHANNEL_SUPPLY)
						if("Mining")
							announcer.radio.talk_into(announcer, calling_message, RADIO_CHANNEL_SUPPLY)

				// Log RETA activity
				log_game("RETA: [origin_dept] called [target_dept] emergency, granted access to [granted_count] responder IDs for [duration_ds/10] seconds")

				// Push UI updates to consoles in the same origin department
				reta_push_ui_updates(origin_dept, target_dept)
			else
				// Normal emergency call without RETA
				switch(emergency_type)
					if(REQ_EMERGENCY_SECURITY)
						aas_config_announce(/datum/aas_config_entry/rc_emergency, list("LOCATION" = department), null, list(RADIO_CHANNEL_SECURITY), REQ_EMERGENCY_SECURITY)
					if(REQ_EMERGENCY_ENGINEERING)
						aas_config_announce(/datum/aas_config_entry/rc_emergency, list("LOCATION" = department), null, list(RADIO_CHANNEL_ENGINEERING), REQ_EMERGENCY_ENGINEERING)
					if(REQ_EMERGENCY_MEDICAL)
						aas_config_announce(/datum/aas_config_entry/rc_emergency, list("LOCATION" = department), null, list(RADIO_CHANNEL_MEDICAL), REQ_EMERGENCY_MEDICAL)

			update_appearance()
			addtimer(CALLBACK(src, PROC_REF(clear_emergency)), 5 MINUTES)
			return TRUE
		if("send_announcement")
			if(!COOLDOWN_FINISHED(src, announcement_cooldown))
				to_chat(usr, span_alert("Intercomms recharging. Please stand by."))
				return
			if(!can_send_announcements)
				return
			if(!(announcement_authenticated || isAdminGhostAI(usr)))
				return

			var/message = reject_bad_text(trim(html_encode(params["message"]), MAX_MESSAGE_LEN), ascii_only = FALSE)
			if(!message)
				to_chat(usr, span_alert("Invalid message."))
				return
			if(isliving(usr))
				var/mob/living/L = usr
				message = L.treat_message(message)["message"]

			minor_announce(message, "[department] Announcement:", html_encode = FALSE, sound_override = 'sound/announcer/announcement/announce_dig.ogg')
			GLOB.news_network.submit_article(message, department, NEWSCASTER_STATION_ANNOUNCEMENTS, null)
			usr.log_talk(message, LOG_SAY, tag="station announcement from [src]")
			message_admins("[ADMIN_LOOKUPFLW(usr)] has made a station announcement from [src] at [AREACOORD(usr)].")
			deadchat_broadcast(" made a station announcement from [span_name("[get_area_name(usr, TRUE)]")].", span_name("[usr.real_name]"), usr, message_type=DEADCHAT_ANNOUNCEMENT)

			COOLDOWN_START(src, announcement_cooldown, ANNOUNCEMENT_COOLDOWN_TIME)
			announcement_authenticated = FALSE
			return TRUE
		if("quick_reply")
			var/recipient = params["reply_recipient"]

			var/reply_message = reject_bad_text(tgui_input_text(usr, "Write a quick reply to [recipient]", "Awaiting Input"), ascii_only = FALSE)
			if(QDELETED(ui) || ui.status != UI_INTERACTIVE)
				return
			if(!reply_message)
				has_mail_send_error = TRUE
				playsound(src, 'sound/machines/buzz/buzz-two.ogg', 50, TRUE)
				return TRUE

			send_message(recipient, reply_message, REQ_NORMAL_MESSAGE_PRIORITY, REPLY_REQUEST)
			return TRUE
		if("send_message")
			var/recipient = params["recipient"]
			if(!recipient)
				return
			var/priority = params["priority"]
			if(!priority)
				return
			var/message = reject_bad_text(trim(html_encode(params["message"]), MAX_MESSAGE_LEN), ascii_only = FALSE)
			if(!message)
				to_chat(usr, span_alert("Invalid message."))
				has_mail_send_error = TRUE
				return TRUE
			var/request_type = params["request_type"]
			if(!request_type)
				return
			send_message(recipient, message, priority, request_type)
			return TRUE

///Sends the message from the request console
/obj/machinery/requests_console/proc/send_message(recipient, message, priority, request_type)
	var/radio_channel
	// They all naming them wrong, all the time... I'll probably rewrite this later in separate PR.
	// Automatically from areas or via mapping helpers. (ther is no "Cargobay Request Console" in any map)
	switch(ckey(recipient))
		if("bridge")
			radio_channel = RADIO_CHANNEL_COMMAND
		if("medbay")
			radio_channel = RADIO_CHANNEL_MEDICAL
		if("science")
			radio_channel = RADIO_CHANNEL_SCIENCE
		if("engineering")
			radio_channel = RADIO_CHANNEL_ENGINEERING
		if("security")
			radio_channel = RADIO_CHANNEL_SECURITY
		if("cargobay", "mining")
			radio_channel = RADIO_CHANNEL_SUPPLY

	var/datum/signal/subspace/messaging/rc/signal = new(src, list(
		"sender_department" = department,
		"recipient_department" = recipient,
		"message" = message,
		"verified" = message_verified_by,
		"stamped" = message_stamped_by,
		"priority" = priority,
		"notify_channel" = radio_channel,
		"request_type" = request_type,
	))
	signal.send_to_receivers()

	has_mail_send_error = !signal.data["done"]

	if(!silent)
		if(has_mail_send_error)
			playsound(src, 'sound/machines/buzz/buzz-two.ogg', 50, TRUE)
		else
			playsound(src, 'sound/machines/beep/twobeep.ogg', 50, TRUE)

	message_stamped_by = ""
	message_verified_by = ""

/obj/machinery/requests_console/ui_data(mob/user)
	var/list/data = list()
	data["is_admin_ghost_ai"] = isAdminGhostAI()
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
	for (var/datum/request_message/message in messages)
		data["messages"] += list(message.message_ui_data())

	// Add RETA data
	data["reta_enabled"] = CONFIG_GET(flag/reta_enabled)
	var/origin_dept = reta_get_user_department_by_name(department)
	var/user_dept = reta_get_user_department(user)

	data["reta_cooldowns"] = list()
	if(origin_dept)
		data["reta_cooldowns"]["Security"] = reta_on_cooldown(origin_dept, "Security")
		data["reta_cooldowns"]["Engineering"] = reta_on_cooldown(origin_dept, "Engineering")
		data["reta_cooldowns"]["Medical"] = reta_on_cooldown(origin_dept, "Medical")

	data["reta_user_dept"] = user_dept

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

/// Updates the UI for all viewers
/obj/machinery/requests_console/proc/ui_update()
	SStgui.update_uis(src)

/// From message_server.dm: Console.create_message(data)
/obj/machinery/requests_console/proc/create_message(data)

	var/datum/request_message/new_message = new(data)

	switch(new_message.priority)
		if(REQ_NORMAL_MESSAGE_PRIORITY)
			if(new_message_priority < REQ_NORMAL_MESSAGE_PRIORITY)
				new_message_priority = REQ_NORMAL_MESSAGE_PRIORITY
				update_appearance()

		if(REQ_HIGH_MESSAGE_PRIORITY)
			if(new_message_priority < REQ_HIGH_MESSAGE_PRIORITY)
				new_message_priority = REQ_HIGH_MESSAGE_PRIORITY
				update_appearance()

		if(REQ_EXTREME_MESSAGE_PRIORITY)
			silent = FALSE
			if(new_message_priority < REQ_EXTREME_MESSAGE_PRIORITY)
				new_message_priority = REQ_EXTREME_MESSAGE_PRIORITY
				update_appearance()

	messages.Insert(1, new_message) //reverse order

	SStgui.update_uis(src)

	if(!silent)
		playsound(src, 'sound/machines/beep/twobeep_high.ogg', 50, TRUE)
		say(new_message.get_alert())

	if(new_message.radio_channel)
		var/authentication
		var/announcement_line = "Unauthenticated"
		if (new_message.message_verified_by)
			authentication = new_message.message_verified_by
			announcement_line = "Verified with ID"
		else if (new_message.message_stamped_by)
			authentication = new_message.message_stamped_by
			announcement_line = "Stamped with stamp"

		aas_config_announce(/datum/aas_config_entry/rc_new_message, list(
			"AUTHENTICATION" = authentication,
			"SENDER" = new_message.sender_department,
			"RECEIVER" = department,
			"MESSAGE" = new_message.content
			), null, list(new_message.radio_channel), announcement_line, new_message.priority == REQ_EXTREME_MESSAGE_PRIORITY)

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

/obj/machinery/requests_console/attackby(obj/item/attacking_item, mob/user, list/modifiers, list/attack_modifiers)
	var/obj/item/card/id/ID = attacking_item.GetID()
	if(ID)
		message_verified_by = "[ID.registered_name] ([ID.assignment])"
		announcement_authenticated = (ACCESS_RC_ANNOUNCE in ID.access)
		SStgui.update_uis(src)
		return
	if (istype(attacking_item, /obj/item/stamp))
		var/obj/item/stamp/attacking_stamp = attacking_item
		message_stamped_by = attacking_stamp.name
		SStgui.update_uis(src)
		return
	return ..()

/obj/machinery/requests_console/on_deconstruction(disassembled)
	new /obj/item/wallframe/requests_console(loc)

/obj/machinery/requests_console/auto_name // Register an autoname variant and then make the directional helpers before undefing all the magic bits
	auto_name = TRUE

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/requests_console, 30)
MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/requests_console/auto_name, 30)

/obj/item/wallframe/requests_console
	name = "requests console"
	desc = "An unmounted requests console. Attach it to a wall to use."
	icon = 'icons/obj/machines/wallmounts.dmi'
	icon_state = "req_comp_off"
	result_path = /obj/machinery/requests_console/auto_name
	pixel_shift = 30

/datum/aas_config_entry/rc_emergency
	name = "RC Alert: Emergency"
	announcement_lines_map = list(
		"Security" = "SECURITY EMERGENCY in %LOCATION - RETA door access granted to responders!",
		"Engineering" = "ENGINEERING EMERGENCY in %LOCATION - RETA door access granted to responders!",
		"Medical" = "MEDICAL EMERGENCY in %LOCATION - RETA door access granted to responders!",
	)
	vars_and_tooltips_map = list(
		"LOCATION" = "will be replaced with the department name and caller information (Name, Job Title)",
	)

/datum/aas_config_entry/rc_new_message
	name = "RC Alert: New Message "
	// Yes, players can't use html tags, however they can use speech mods like | or +, but sh-sh-sh, don't tell them!
	announcement_lines_map = list(
		"Unauthenticated" = "Message from %SENDER to %RECEIVER: <i>%MESSAGE</i>",
		"Verified with ID" = "Message from %SENDER to %RECEIVER, Verified by %AUTHENTICATION (Authenticated): <i>%MESSAGE</i>",
		"Stamped with stamp" = "Message from %SENDER to %RECEIVER, Stamped by %AUTHENTICATION (Authenticated): <i>%MESSAGE</i>",
	)
	vars_and_tooltips_map = list(
		"AUTHENTICATION" = "will be replaced with ID or stamp, if present",
		"SENDER" = "with the sender department ",
		"RECEIVER" = "with the receiver department",
		"MESSAGE" = "with the message content",
	)

#undef REQ_EMERGENCY_SECURITY
#undef REQ_EMERGENCY_ENGINEERING
#undef REQ_EMERGENCY_MEDICAL

#undef ANNOUNCEMENT_COOLDOWN_TIME
