#define IMPORTANT_ACTION_COOLDOWN (60 SECONDS)
#define MAX_STATUS_LINE_LENGTH 40

#define STATE_BUYING_SHUTTLE "buying_shuttle"
#define STATE_CHANGING_STATUS "changing_status"
#define STATE_MAIN "main"
#define STATE_MESSAGES "messages"

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
	var/cyborg_state = STATE_MAIN

	/// The name of the user who logged in
	var/authorize_name

	/// The access that the card had on login
	var/list/authorize_access

	/// The messages this console has been sent
	var/list/datum/comm_message/messages

	/// How many times the alert level has been changed
	/// Used to clear the modal to change alert level
	var/alert_level_tick = 0

	/// The last lines used for changing the status display
	var/static/last_status_display

/obj/machinery/computer/communications/Initialize()
	. = ..()
	GLOB.shuttle_caller_list += src
	AddComponent(/datum/component/gps, "Secured Communications Signal")

/// Are we NOT a silicon, AND we're logged in as the captain?
/obj/machinery/computer/communications/proc/authenticated_as_non_silicon_captain(mob/user)
	if (issilicon(user))
		return FALSE
	return ACCESS_CAPTAIN in authorize_access

/// Are we a silicon, OR we're logged in as the captain?
/obj/machinery/computer/communications/proc/authenticated_as_silicon_or_captain(mob/user)
	if (issilicon(user))
		return TRUE
	return ACCESS_CAPTAIN in authorize_access

/// Are we a silicon, OR logged in?
/obj/machinery/computer/communications/proc/authenticated(mob/user)
	if (issilicon(user))
		return TRUE
	return authenticated

/obj/machinery/computer/communications/attackby(obj/I, mob/user, params)
	if(istype(I, /obj/item/card/id))
		attack_hand(user)
	else
		return ..()

/obj/machinery/computer/communications/emag_act(mob/user)
	if (obj_flags & EMAGGED)
		return
	obj_flags |= EMAGGED
	if (authenticated)
		authorize_access = SSid_access.get_region_access_list(list(REGION_ALL_STATION))
	to_chat(user, "<span class='danger'>You scramble the communication routing circuits!</span>")
	playsound(src, 'sound/machines/terminal_alert.ogg', 50, FALSE)

/obj/machinery/computer/communications/ui_act(action, list/params)
	var/static/list/approved_states = list(STATE_BUYING_SHUTTLE, STATE_CHANGING_STATUS, STATE_MAIN, STATE_MESSAGES)
	var/static/list/approved_status_pictures = list("biohazard", "blank", "default", "lockdown", "redalert", "shuttle")

	. = ..()
	if (.)
		return

	if (!has_communication())
		return

	. = TRUE

	switch (action)
		if ("answerMessage")
			if (!authenticated(usr))
				return

			var/answer_index = params["answer"]
			var/message_index = params["message"]

			// If either of these aren't numbers, then bad voodoo.
			if(!isnum(answer_index) || !isnum(message_index))
				message_admins("[ADMIN_LOOKUPFLW(usr)] provided an invalid index type when replying to a message on [src] [ADMIN_JMP(src)]. This should not happen. Please check with a maintainer and/or consult tgui logs.")
				CRASH("Non-numeric index provided when answering comms console message.")

			if (!answer_index || !message_index || answer_index < 1 || message_index < 1)
				return
			var/datum/comm_message/message = messages[message_index]
			if (message.answered)
				return
			message.answered = answer_index
			message.answer_callback.InvokeAsync()
		if ("callShuttle")
			if (!authenticated(usr))
				return
			var/reason = trim(params["reason"], MAX_MESSAGE_LEN)
			if (length(reason) < CALL_SHUTTLE_REASON_LENGTH)
				return
			SSshuttle.requestEvac(usr, reason)
			post_status("shuttle")
		if ("changeSecurityLevel")
			if (!authenticated_as_silicon_or_captain(usr))
				return

			// Check if they have
			if (!issilicon(usr))
				var/obj/item/held_item = usr.get_active_held_item()
				var/obj/item/card/id/id_card = held_item?.GetID()
				if (!istype(id_card))
					to_chat(usr, "<span class='warning'>You need to swipe your ID!</span>")
					playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, FALSE)
					return
				if (!(ACCESS_CAPTAIN in id_card.access))
					to_chat(usr, "<span class='warning'>You are not authorized to do this!</span>")
					playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, FALSE)
					return

			var/new_sec_level = seclevel2num(params["newSecurityLevel"])
			if (new_sec_level != SEC_LEVEL_GREEN && new_sec_level != SEC_LEVEL_BLUE)
				return
			if (SSsecurity_level.current_level == new_sec_level)
				return

			set_security_level(new_sec_level)

			to_chat(usr, "<span class='notice'>Authorization confirmed. Modifying security level.</span>")
			playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, FALSE)

			// Only notify people if an actual change happened
			log_game("[key_name(usr)] has changed the security level to [params["newSecurityLevel"]] with [src] at [AREACOORD(usr)].")
			message_admins("[ADMIN_LOOKUPFLW(usr)] has changed the security level to [params["newSecurityLevel"]] with [src] at [AREACOORD(usr)].")
			deadchat_broadcast(" has changed the security level to [params["newSecurityLevel"]] with [src] at <span class='name'>[get_area_name(usr, TRUE)]</span>.", "<span class='name'>[usr.real_name]</span>", usr, message_type=DEADCHAT_ANNOUNCEMENT)

			alert_level_tick += 1
		if ("deleteMessage")
			if (!authenticated(usr))
				return
			var/message_index = text2num(params["message"])
			if (!message_index)
				return
			LAZYREMOVE(messages, LAZYACCESS(messages, message_index))
		if ("emergency_meeting")
			if(!(SSevents.holidays && SSevents.holidays[APRIL_FOOLS]))
				return
			if (!authenticated_as_silicon_or_captain(usr))
				return
			emergency_meeting(usr)
		if ("makePriorityAnnouncement")
			if (!authenticated_as_silicon_or_captain(usr))
				return
			make_announcement(usr)
		if ("messageAssociates")
			if (!authenticated_as_non_silicon_captain(usr))
				return
			if (!COOLDOWN_FINISHED(src, important_action_cooldown))
				return

			playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, FALSE)
			var/message = trim(html_encode(params["message"]), MAX_MESSAGE_LEN)

			var/emagged = obj_flags & EMAGGED
			if (emagged)
				message_syndicate(message, usr)
				to_chat(usr, "<span class='danger'>SYSERR @l(19833)of(transmit.dm): !@$ MESSAGE TRANSMITTED TO SYNDICATE COMMAND.</span>")
			else
				message_centcom(message, usr)
				to_chat(usr, "<span class='notice'>Message transmitted to Central Command.</span>")

			var/associates = emagged ? "the Syndicate": "CentCom"
			usr.log_talk(message, LOG_SAY, tag = "message to [associates]")
			deadchat_broadcast(" has messaged [associates], \"[message]\" at <span class='name'>[get_area_name(usr, TRUE)]</span>.", "<span class='name'>[usr.real_name]</span>", usr, message_type = DEADCHAT_ANNOUNCEMENT)
			COOLDOWN_START(src, important_action_cooldown, IMPORTANT_ACTION_COOLDOWN)
		if ("purchaseShuttle")
			var/can_buy_shuttles_or_fail_reason = can_buy_shuttles(usr)
			if (can_buy_shuttles_or_fail_reason != TRUE)
				if (can_buy_shuttles_or_fail_reason != FALSE)
					to_chat(usr, "<span class='alert'>[can_buy_shuttles_or_fail_reason]</span>")
				return
			var/list/shuttles = flatten_list(SSmapping.shuttle_templates)
			var/datum/map_template/shuttle/shuttle = locate(params["shuttle"]) in shuttles
			if (!istype(shuttle))
				return
			if (!can_purchase_this_shuttle(shuttle))
				return
			if (!shuttle.prerequisites_met())
				to_chat(usr, "<span class='alert'>You have not met the requirements for purchasing this shuttle.</span>")
				return
			var/datum/bank_account/bank_account = SSeconomy.get_dep_account(ACCOUNT_CAR)
			if (bank_account.account_balance < shuttle.credit_cost)
				return
			SSshuttle.shuttle_purchased = SHUTTLEPURCHASE_PURCHASED
			for(var/datum/round_event_control/shuttle_insurance/insurance_event in SSevents.control)
				insurance_event.weight *= 20
			SSshuttle.unload_preview()
			SSshuttle.existing_shuttle = SSshuttle.emergency
			SSshuttle.action_load(shuttle, replace = TRUE)
			bank_account.adjust_money(-shuttle.credit_cost)
			minor_announce("[usr.real_name] has purchased [shuttle.name] for [shuttle.credit_cost] credits.[shuttle.extra_desc ? " [shuttle.extra_desc]" : ""]" , "Shuttle Purchase")
			message_admins("[ADMIN_LOOKUPFLW(usr)] purchased [shuttle.name].")
			log_shuttle("[key_name(usr)] has purchased [shuttle.name].")
			SSblackbox.record_feedback("text", "shuttle_purchase", 1, shuttle.name)
			state = STATE_MAIN
		if ("recallShuttle")
			// AIs cannot recall the shuttle
			if (!authenticated(usr) || issilicon(usr))
				return
			SSshuttle.cancelEvac(usr)
		if ("requestNukeCodes")
			if (!authenticated_as_non_silicon_captain(usr))
				return
			if (!COOLDOWN_FINISHED(src, important_action_cooldown))
				return
			var/reason = trim(html_encode(params["reason"]), MAX_MESSAGE_LEN)
			nuke_request(reason, usr)
			to_chat(usr, "<span class='notice'>Request sent.</span>")
			usr.log_message("has requested the nuclear codes from CentCom with reason \"[reason]\"", LOG_SAY)
			priority_announce("The codes for the on-station nuclear self-destruct have been requested by [usr]. Confirmation or denial of this request will be sent shortly.", "Nuclear Self-Destruct Codes Requested", SSstation.announcer.get_rand_report_sound())
			playsound(src, 'sound/machines/terminal_prompt.ogg', 50, FALSE)
			COOLDOWN_START(src, important_action_cooldown, IMPORTANT_ACTION_COOLDOWN)
		if ("restoreBackupRoutingData")
			if (!authenticated_as_non_silicon_captain(usr))
				return
			if (!(obj_flags & EMAGGED))
				return
			to_chat(usr, "<span class='notice'>Backup routing data restored.</span>")
			playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, FALSE)
			obj_flags &= ~EMAGGED
		if ("sendToOtherSector")
			if (!authenticated_as_non_silicon_captain(usr))
				return
			if (!can_send_messages_to_other_sectors(usr))
				return
			if (!COOLDOWN_FINISHED(src, important_action_cooldown))
				return

			var/message = trim(html_encode(params["message"]), MAX_MESSAGE_LEN)
			if (!message)
				return

			playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, FALSE)

			var/destination = params["destination"]
			var/list/payload = list()

			var/network_name = CONFIG_GET(string/cross_comms_network)
			if (network_name)
				payload["network"] = network_name
			payload["sender_ckey"] = usr.ckey

			send2otherserver(station_name(), message, "Comms_Console", destination == "all" ? null : list(destination), additional_data = payload)
			minor_announce(message, title = "Outgoing message to allied station")
			usr.log_talk(message, LOG_SAY, tag = "message to the other server")
			message_admins("[ADMIN_LOOKUPFLW(usr)] has sent a message to the other server\[s].")
			deadchat_broadcast(" has sent an outgoing message to the other station(s).</span>", "<span class='bold'>[usr.real_name]", usr, message_type = DEADCHAT_ANNOUNCEMENT)

			COOLDOWN_START(src, important_action_cooldown, IMPORTANT_ACTION_COOLDOWN)
		if ("setState")
			if (!authenticated(usr))
				return
			if (!(params["state"] in approved_states))
				return
			if (state == STATE_BUYING_SHUTTLE && can_buy_shuttles(usr) != TRUE)
				return
			set_state(usr, params["state"])
			playsound(src, "terminal_type", 50, FALSE)
		if ("setStatusMessage")
			if (!authenticated(usr))
				return
			var/line_one = reject_bad_text(params["lineOne"] || "", MAX_STATUS_LINE_LENGTH)
			var/line_two = reject_bad_text(params["lineTwo"] || "", MAX_STATUS_LINE_LENGTH)
			post_status("alert", "blank")
			post_status("message", line_one, line_two)
			last_status_display = list(line_one, line_two)
			playsound(src, "terminal_type", 50, FALSE)
		if ("setStatusPicture")
			if (!authenticated(usr))
				return
			var/picture = params["picture"]
			if (!(picture in approved_status_pictures))
				return
			post_status("alert", picture)
			playsound(src, "terminal_type", 50, FALSE)
		if ("toggleAuthentication")
			// Log out if we're logged in
			if (authorize_name)
				authenticated = FALSE
				authorize_access = null
				authorize_name = null
				playsound(src, 'sound/machines/terminal_off.ogg', 50, FALSE)
				return

			if (obj_flags & EMAGGED)
				authenticated = TRUE
				authorize_access = SSid_access.get_region_access_list(list(REGION_ALL_STATION))
				authorize_name = "Unknown"
				to_chat(usr, "<span class='warning'>[src] lets out a quiet alarm as its login is overridden.</span>")
				playsound(src, 'sound/machines/terminal_alert.ogg', 25, FALSE)
			else if(isliving(usr))
				var/mob/living/L = usr
				var/obj/item/card/id/id_card = L.get_idcard(hand_first = TRUE)
				if (check_access(id_card))
					authenticated = TRUE
					authorize_access = id_card.access.Copy()
					authorize_name = "[id_card.registered_name] - [id_card.assignment]"

			state = STATE_MAIN
			playsound(src, 'sound/machines/terminal_on.ogg', 50, FALSE)
		if ("toggleEmergencyAccess")
			if (!authenticated_as_silicon_or_captain(usr))
				return
			if (GLOB.emergency_access)
				revoke_maint_all_access()
				log_game("[key_name(usr)] disabled emergency maintenance access.")
				message_admins("[ADMIN_LOOKUPFLW(usr)] disabled emergency maintenance access.")
				deadchat_broadcast(" disabled emergency maintenance access at <span class='name'>[get_area_name(usr, TRUE)]</span>.", "<span class='name'>[usr.real_name]</span>", usr, message_type = DEADCHAT_ANNOUNCEMENT)
			else
				make_maint_all_access()
				log_game("[key_name(usr)] enabled emergency maintenance access.")
				message_admins("[ADMIN_LOOKUPFLW(usr)] enabled emergency maintenance access.")
				deadchat_broadcast(" enabled emergency maintenance access at <span class='name'>[get_area_name(usr, TRUE)]</span>.", "<span class='name'>[usr.real_name]</span>", usr, message_type = DEADCHAT_ANNOUNCEMENT)
		// Request codes for the Captain's Spare ID safe.
		if("requestSafeCodes")
			if(SSjob.assigned_captain)
				to_chat(usr, "<span class='warning'>There is already an assigned Captain or Acting Captain on deck!</span>")
				return

			if(SSjob.safe_code_timer_id)
				to_chat(usr, "<span class='warning'>The safe code has already been requested and is being delivered to your station!</span>")
				return

			if(SSjob.safe_code_requested)
				to_chat(usr, "<span class='warning'>The safe code has already been requested and delivered to your station!</span>")
				return

			if(!SSid_access.spare_id_safe_code)
				to_chat(usr, "<span class='warning'>There is no safe code to deliver to your station!</span>")
				return

			var/turf/pod_location = get_turf(src)

			SSjob.safe_code_request_loc = pod_location
			SSjob.safe_code_requested = TRUE
			SSjob.safe_code_timer_id = addtimer(CALLBACK(SSjob, /datum/controller/subsystem/job.proc/send_spare_id_safe_code, pod_location), 120 SECONDS, TIMER_UNIQUE | TIMER_STOPPABLE)
			minor_announce("Due to staff shortages, your station has been approved for delivery of access codes to secure the Captain's Spare ID. Delivery via drop pod at [get_area(pod_location)]. ETA 120 seconds.")

/obj/machinery/computer/communications/ui_data(mob/user)
	var/list/data = list(
		"authenticated" = FALSE,
		"emagged" = FALSE,
	)

	var/ui_state = issilicon(user) ? cyborg_state : state

	var/has_connection = has_communication()
	data["hasConnection"] = has_connection

	if(!SSjob.assigned_captain && !SSjob.safe_code_requested && SSid_access.spare_id_safe_code && has_connection)
		data["canRequestSafeCode"] = TRUE
		data["safeCodeDeliveryWait"] = 0
	else
		data["canRequestSafeCode"] = FALSE
		if(SSjob.safe_code_timer_id && has_connection)
			data["safeCodeDeliveryWait"] = timeleft(SSjob.safe_code_timer_id)
			data["safeCodeDeliveryArea"] = get_area(SSjob.safe_code_request_loc)
		else
			data["safeCodeDeliveryWait"] = 0
			data["safeCodeDeliveryArea"] = null

	if (authenticated || issilicon(user))
		data["authenticated"] = TRUE
		data["canLogOut"] = !issilicon(user)
		data["page"] = ui_state

		if (obj_flags & EMAGGED)
			data["emagged"] = TRUE

		switch (ui_state)
			if (STATE_MAIN)
				data["canBuyShuttles"] = can_buy_shuttles(user)
				data["canMakeAnnouncement"] = FALSE
				data["canMessageAssociates"] = FALSE
				data["canRecallShuttles"] = !issilicon(user)
				data["canRequestNuke"] = FALSE
				data["canSendToSectors"] = FALSE
				data["canSetAlertLevel"] = FALSE
				data["canToggleEmergencyAccess"] = FALSE
				data["importantActionReady"] = COOLDOWN_FINISHED(src, important_action_cooldown)
				data["shuttleCalled"] = FALSE
				data["shuttleLastCalled"] = FALSE
				data["aprilFools"] = SSevents.holidays && SSevents.holidays[APRIL_FOOLS]
				data["alertLevel"] = get_security_level()
				data["authorizeName"] = authorize_name
				data["canLogOut"] = !issilicon(user)
				data["shuttleCanEvacOrFailReason"] = SSshuttle.canEvac(user)

				if (authenticated_as_non_silicon_captain(user))
					data["canMessageAssociates"] = TRUE
					data["canRequestNuke"] = TRUE

				if (can_send_messages_to_other_sectors(user))
					data["canSendToSectors"] = TRUE

					var/list/sectors = list()
					var/our_id = CONFIG_GET(string/cross_comms_name)

					for (var/server in CONFIG_GET(keyed_list/cross_server))
						if (server == our_id)
							continue
						sectors += server

					data["sectors"] = sectors

				if (authenticated_as_silicon_or_captain(user))
					data["canToggleEmergencyAccess"] = TRUE
					data["emergencyAccess"] = GLOB.emergency_access

					data["alertLevelTick"] = alert_level_tick
					data["canMakeAnnouncement"] = TRUE
					data["canSetAlertLevel"] = issilicon(user) ? "NO_SWIPE_NEEDED" : "SWIPE_NEEDED"

				if (SSshuttle.emergency.mode != SHUTTLE_IDLE && SSshuttle.emergency.mode != SHUTTLE_RECALL)
					data["shuttleCalled"] = TRUE
					data["shuttleRecallable"] = SSshuttle.canRecall()

				if (SSshuttle.emergencyCallAmount)
					data["shuttleCalledPreviously"] = TRUE
					if (SSshuttle.emergencyLastCallLoc)
						data["shuttleLastCalled"] = format_text(SSshuttle.emergencyLastCallLoc.name)
			if (STATE_MESSAGES)
				data["messages"] = list()

				if (messages)
					for (var/_message in messages)
						var/datum/comm_message/message = _message
						data["messages"] += list(list(
							"answered" = message.answered,
							"content" = message.content,
							"title" = message.title,
							"possibleAnswers" = message.possible_answers,
						))
			if (STATE_BUYING_SHUTTLE)
				var/datum/bank_account/bank_account = SSeconomy.get_dep_account(ACCOUNT_CAR)
				var/list/shuttles = list()

				for (var/shuttle_id in SSmapping.shuttle_templates)
					var/datum/map_template/shuttle/shuttle_template = SSmapping.shuttle_templates[shuttle_id]

					if (shuttle_template.credit_cost == INFINITY)
						continue

					if (!can_purchase_this_shuttle(shuttle_template))
						continue

					var/has_access = FALSE

					for (var/purchase_access in shuttle_template.who_can_purchase)
						if (purchase_access in authorize_access)
							has_access = TRUE
							break

					if (!has_access)
						continue

					shuttles += list(list(
						"name" = shuttle_template.name,
						"description" = shuttle_template.description,
						"creditCost" = shuttle_template.credit_cost,
						"prerequisites" = shuttle_template.prerequisites,
						"ref" = REF(shuttle_template),
					))

				data["budget"] = bank_account.account_balance
				data["shuttles"] = shuttles
			if (STATE_CHANGING_STATUS)
				data["lineOne"] = last_status_display ? last_status_display[1] : ""
				data["lineTwo"] = last_status_display ? last_status_display[2] : ""

	return data

/obj/machinery/computer/communications/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "CommunicationsConsole")
		ui.open()

/obj/machinery/computer/communications/ui_static_data(mob/user)
	return list(
		"callShuttleReasonMinLength" = CALL_SHUTTLE_REASON_LENGTH,
		"maxStatusLineLength" = MAX_STATUS_LINE_LENGTH,
		"maxMessageLength" = MAX_MESSAGE_LEN,
	)

/// Returns whether or not the communications console can communicate with the station
/obj/machinery/computer/communications/proc/has_communication()
	var/turf/current_turf = get_turf(src)
	var/z_level = current_turf.z
	return is_station_level(z_level) || is_centcom_level(z_level)

/obj/machinery/computer/communications/proc/set_state(mob/user, new_state)
	if (issilicon(user))
		cyborg_state = new_state
	else
		state = new_state

/// Returns TRUE if the user can buy shuttles.
/// If they cannot, returns FALSE or a string detailing why.
/obj/machinery/computer/communications/proc/can_buy_shuttles(mob/user)
	if (!SSmapping.config.allow_custom_shuttles)
		return FALSE
	if (issilicon(user))
		return FALSE

	var/has_access = FALSE

	for (var/access in SSshuttle.has_purchase_shuttle_access)
		if (access in authorize_access)
			has_access = TRUE
			break

	if (!has_access)
		return FALSE

	if (SSshuttle.emergency.mode != SHUTTLE_RECALL && SSshuttle.emergency.mode != SHUTTLE_IDLE)
		return "The shuttle is already in transit."
	if (SSshuttle.shuttle_purchased == SHUTTLEPURCHASE_PURCHASED)
		return "A replacement shuttle has already been purchased."
	if (SSshuttle.shuttle_purchased == SHUTTLEPURCHASE_FORCED)
		return "Due to unforseen circumstances, shuttle purchasing is no longer available."
	return TRUE

/// Returns whether we are authorized to buy this specific shuttle.
/// Does not handle prerequisite checks, as those should still *show*.
/obj/machinery/computer/communications/proc/can_purchase_this_shuttle(datum/map_template/shuttle/shuttle_template)
	if (isnull(shuttle_template.who_can_purchase))
		return FALSE

	for (var/access in authorize_access)
		if (access in shuttle_template.who_can_purchase)
			return TRUE

	return FALSE

/obj/machinery/computer/communications/proc/can_send_messages_to_other_sectors(mob/user)
	if (!authenticated_as_non_silicon_captain(user))
		return

	return length(CONFIG_GET(keyed_list/cross_server)) > 0

/**
 * Call an emergency meeting
 *
 * Comm Console wrapper for the Communications subsystem wrapper for the call_emergency_meeting world proc.
 * Checks to make sure the proc can be called, and handles relevant feedback, logging and timing.
 * See the SScommunications proc definition for more detail, in short, teleports the entire crew to
 * the bridge for a meetup. Should only really happen during april fools.
 * Arguments:
 * * user - Mob who called the meeting
 */
/obj/machinery/computer/communications/proc/emergency_meeting(mob/living/user)
	if(!SScommunications.can_make_emergency_meeting(user))
		to_chat(user, "<span class='alert'>The emergency meeting button doesn't seem to work right now. Please stand by.</span>")
		return
	SScommunications.emergency_meeting(user)
	deadchat_broadcast(" called an emergency meeting from <span class='name'>[get_area_name(usr, TRUE)]</span>.", "<span class='name'>[user.real_name]</span>", user, message_type=DEADCHAT_ANNOUNCEMENT)

/obj/machinery/computer/communications/proc/make_announcement(mob/living/user)
	var/is_ai = issilicon(user)
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
	LAZYADD(messages, new_message)

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

#undef IMPORTANT_ACTION_COOLDOWN
#undef MAX_STATUS_LINE_LENGTH
#undef STATE_BUYING_SHUTTLE
#undef STATE_CHANGING_STATUS
#undef STATE_MAIN
#undef STATE_MESSAGES
