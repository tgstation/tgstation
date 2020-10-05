#define STATE_MAIN "main"
#define STATE_MESSAGES "messages"
#define STATE_BUYING_SHUTTLE "buying_shuttle"
#define STATE_CHANGING_STATUS "changing_status"

// The communications computer
/obj/machinery/computer/communications
	name = "communications console"
	desc = "A console used for high-priority announcements and emergencies."
	icon_screen = "comm"
	icon_keyboard = "tech_key"
	req_access = list(ACCESS_HEADS)
	circuit = /obj/item/circuitboard/computer/communications
	light_color = LIGHT_COLOR_BLUE

	/// Cooldown for important actions, such as messaging CentCom or other sectors
	COOLDOWN_DECLARE(static/important_action_cooldown)

	/// The current state of the UI
	var/state = STATE_MAIN

	/// The current state of the UI for AIs
	var/ai_state = STATE_MAIN

	/// The name of the user who logged in
	var/authorize_name

	/// The access that the card had on login
	var/list/authorize_access

	/// The messages this console has been sent
	var/list/datum/comm_message/messages = list()

/obj/machinery/computer/communications/Initialize()
	. = ..()
	GLOB.shuttle_caller_list += src

/obj/machinery/computer/communications/proc/authenticated_as_non_ai_captain(mob/user)
	if (isAI(user))
		return FALSE
	return ACCESS_CAPTAIN in authorize_access

/obj/machinery/computer/communications/proc/authenticated_as_ai_or_captain(mob/user)
	if (isAI(user))
		return TRUE
	return ACCESS_CAPTAIN in authorize_access

/obj/machinery/computer/communications/attackby(obj/I, mob/user, params)
	if(istype(I, /obj/item/card/id))
		attack_hand(user)
	else
		return ..()

/obj/machinery/computer/communications/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	obj_flags |= EMAGGED
	if(authenticated == 1)
		authenticated = 2
	to_chat(user, "<span class='danger'>You scramble the communication routing circuits!</span>")
	playsound(src, 'sound/machines/terminal_alert.ogg', 50, FALSE)

/obj/machinery/computer/communications/ui_act(action, list/params)
	. = ..()
	if (.)
		return

	. = TRUE

	switch(action)
		if("callShuttle")
			if (!authenticated)
				return
			var/reason = params["reason"]
			if (length(reason) < CALL_SHUTTLE_REASON_LENGTH)
				return
			SSshuttle.requestEvac(usr, reason)
			post_status("shuttle")
		if("makePriorityAnnouncement")
			if (!authenticated_as_ai_or_captain(usr))
				return
			make_announcement(usr)
		if("toggleAuthentication")
			// Log out if we're logged in
			if (authorize_name)
				authenticated = FALSE
				authorize_access = null
				authorize_name = null
				playsound(src, 'sound/machines/terminal_off.ogg', 50, FALSE)
				return

			var/obj/item/card/id/id_card = usr.get_idcard(hand_first = TRUE)
			if (check_access(id_card))
				authenticated = TRUE
				authorize_access = id_card.access
				authorize_name = "[id_card.registered_name] - [id_card.assignment]"
				playsound(src, 'sound/machines/terminal_on.ogg', 50, FALSE)

/obj/machinery/computer/communications/ui_data(mob/user)
	var/list/data = list(
		"authenticated" = FALSE,
		"canBuyShuttles" = FALSE,
		"canMessageAssociated" = FALSE,
		"canRequestNuke" = FALSE,
		"canSendToSectors" = FALSE,
		"emagged" = FALSE,
		"shuttleCalled" = FALSE,
		"shuttleLastCalled" = FALSE,
	)

	var/ui_state = isAI(user) ? ai_state : state

	if (authenticated || isAI(user))
		data["authenticated"] = TRUE
		data["canLogOut"] = !isAI(user)
		data["page"] = ui_state
		data["shuttleCanEvacOrFailReason"] = SSshuttle.canEvac(user)

		switch (ui_state)
			if (STATE_MAIN)
				data["alertLevel"] = get_security_level()
				data["authorizeName"] = authorize_name
				data["canLogOut"] = !isAI(user)

				if (authenticated_as_non_ai_captain(user))
					if (SSmapping.config.allow_custom_shuttles)
						data["canBuyShuttles"] = TRUE

					var/list/cross_servers = CONFIG_GET(keyed_list/cross_server)
					if (cross_servers.len)
						data["canSendToSectors"] = TRUE

					data["canMessageAssociates"] = TRUE
					if (obj_flags & EMAGGED)
						data["emagged"] = TRUE

					data["canRequestNuke"] = TRUE

				if (authenticated_as_ai_or_captain(user))
					data["canToggleEmergencyAccess"] = TRUE
					data["emergencyAccess"] = GLOB.emergency_access

					data["canMakeAnnouncement"] = TRUE
					data["canSetAlertLevel"] = TRUE

				if (SSshuttle.emergency.mode != SHUTTLE_IDLE && SSshuttle.emergency.mode != SHUTTLE_RECALL)
					data["shuttleCalled"] = TRUE
					data["shuttleRecallable"] = SSshuttle.canRecall()

				if (SSshuttle.emergencyCallAmount)
					data["shuttleCalledPreviously"] = TRUE
					if (SSshuttle.emergencyLastCallLoc)
						data["shuttleLastCalled"] = format_text(SSshuttle.emergencyLastCallLoc.name)
			if (STATE_MESSAGES)
				data["messages"] = list()

				for (var/_message in messages)
					var/datum/comm_message/message = _message
					data["messages"] += list(list(
						"content" = message.content,
						"title" = message.title,
						"possibleAnswers" = message.possible_answers,
					))
			if (STATE_BUYING_SHUTTLE)
				// NYI
				pass()
			if (STATE_CHANGING_STATUS)
				// NYI
				pass()

	return data

/obj/machinery/computer/communications/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "CommunicationsConsole")
		ui.open()

/obj/machinery/computer/communications/ui_static_data(mob/user)
	return list(
		"callShuttleReasonMinLength" = CALL_SHUTTLE_REASON_LENGTH,
	)

/obj/machinery/computer/communications/proc/make_announcement(mob/living/user)
	var/is_ai = isAI(user)
	if(!SScommunications.can_announce(user, is_ai))
		to_chat(user, "<span class='alert'>Intercomms recharging. Please stand by.</span>")
		return
	var/input = stripped_input(user, "Please choose a message to announce to the station crew.", "What?")
	if(!input || !user.canUseTopic(src, !issilicon(usr)))
		return
	if(!(user.can_speak())) //No more cheating, mime/random mute guy!
		input = "..."
		to_chat(user, "<span class='warning'>You find yourself unable to speak.</span>")
	else
		input = user.treat_message(input) //Adds slurs and so on. Someone should make this use languages too.
	SScommunications.make_announcement(user, is_ai, input)
	deadchat_broadcast(" made a priority announcement from <span class='name'>[get_area_name(usr, TRUE)]</span>.", "<span class='name'>[user.real_name]</span>", user, message_type=DEADCHAT_ANNOUNCEMENT)

/obj/machinery/computer/communications/proc/post_status(command, data1, data2)

	var/datum/radio_frequency/frequency = SSradio.return_frequency(FREQ_STATUS_DISPLAYS)

	if(!frequency)
		return

	var/datum/signal/status_signal = new(list("command" = command))
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

/// Override the cooldown for special actions
/// Used in places such as CentCom messaging back so that the crew can answer right away
/obj/machinery/computer/communications/proc/override_cooldown()
	COOLDOWN_RESET(src, important_action_cooldown)

/obj/machinery/computer/communications/proc/add_message(datum/comm_message/new_message)
	messages += new_message

/datum/comm_message
	var/title
	var/content
	var/list/possible_answers = list()
	var/answered
	var/datum/callback/answer_callback

/datum/comm_message/New(new_title,new_content,new_possible_answers)
	..()
	if(new_title)
		title = new_title
	if(new_content)
		content = new_content
	if(new_possible_answers)
		possible_answers = new_possible_answers

#undef STATE_MAIN
#undef STATE_MESSAGES
#undef STATE_BUYING_SHUTTLE
#undef STATE_CHANGING_STATUS
