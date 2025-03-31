#define IMPORTANT_ACTION_COOLDOWN (60 SECONDS)
#define EMERGENCY_ACCESS_COOLDOWN (30 SECONDS)

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
	req_access = list(ACCESS_COMMAND)
	circuit = /obj/item/circuitboard/computer/communications
	light_color = LIGHT_COLOR_BLUE

	/// If the battlecruiser has been called
	var/static/battlecruiser_called = FALSE

	/// Cooldown for important actions, such as messaging CentCom or other sectors
	COOLDOWN_DECLARE(static/important_action_cooldown)
	COOLDOWN_DECLARE(static/emergency_access_cooldown)

	/// Whether syndicate mode is enabled or not.
	var/syndicate = FALSE

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

	/// The timer ID for sending the next cross-comms message
	var/send_cross_comms_message_timer

	/// The last lines used for changing the status display
	var/static/last_status_display

	///how many uses the console has done of toggling the emergency access
	var/toggle_uses = 0
	///how many uses can you toggle emergency access with before cooldowns start occuring BOTH ENABLE/DISABLE
	var/toggle_max_uses = 3
	///when was emergency access last toggled
	var/last_toggled

/obj/machinery/computer/communications/syndicate
	icon_screen = "commsyndie"
	circuit = /obj/item/circuitboard/computer/communications/syndicate
	req_access = list(ACCESS_SYNDICATE_LEADER)
	light_color = LIGHT_COLOR_BLOOD_MAGIC

	syndicate = TRUE

/obj/machinery/computer/communications/syndicate/emag_act(mob/user, obj/item/card/emag/emag_card)
	return FALSE

/obj/machinery/computer/communications/syndicate/can_buy_shuttles(mob/user)
	return FALSE

/obj/machinery/computer/communications/syndicate/can_send_messages_to_other_sectors(mob/user)
	return FALSE

/obj/machinery/computer/communications/syndicate/authenticated_as_silicon_or_captain(mob/user)
	return FALSE

/obj/machinery/computer/communications/syndicate/get_communication_players()
	var/list/targets = list()
	for(var/mob/target in GLOB.player_list)
		if(target.stat == DEAD || target.z == z || target.mind?.has_antag_datum(/datum/antagonist/battlecruiser))
			targets += target
	return targets

/obj/machinery/computer/communications/Initialize(mapload)
	. = ..()
	// All maps should have at least 1 comms console
	REGISTER_REQUIRED_MAP_ITEM(1, INFINITY)

	GLOB.shuttle_caller_list += src

/// Are we NOT a silicon, AND we're logged in as the captain?
/obj/machinery/computer/communications/proc/authenticated_as_non_silicon_captain(mob/user)
	if (HAS_SILICON_ACCESS(user))
		return FALSE
	return ACCESS_CAPTAIN in authorize_access

/// Are we a silicon, OR we're logged in as the captain?
/obj/machinery/computer/communications/proc/authenticated_as_silicon_or_captain(mob/user)
	if (HAS_SILICON_ACCESS(user))
		return TRUE
	return ACCESS_CAPTAIN in authorize_access

/// Are we a silicon, OR logged in?
/obj/machinery/computer/communications/proc/authenticated(mob/user)
	if (HAS_SILICON_ACCESS(user))
		return TRUE
	return authenticated

/obj/machinery/computer/communications/attackby(obj/I, mob/user, params)
	if(isidcard(I))
		attack_hand(user)
	else
		return ..()

/obj/machinery/computer/communications/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(istype(emag_card, /obj/item/card/emag/battlecruiser))
		var/obj/item/card/emag/battlecruiser/caller_card = emag_card
		if (user)
			if(!IS_TRAITOR(user))
				to_chat(user, span_danger("You get the feeling this is a bad idea."))
				return FALSE
		if(battlecruiser_called)
			if (user)
				to_chat(user, span_danger("The card reports a long-range message already sent to the Syndicate fleet...?"))
			return FALSE
		battlecruiser_called = TRUE
		caller_card.use_charge(user)
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(summon_battlecruiser), caller_card.team), rand(20 SECONDS, 1 MINUTES))
		playsound(src, 'sound/machines/terminal/terminal_alert.ogg', 50, FALSE)
		return TRUE

	if(obj_flags & EMAGGED)
		return FALSE
	obj_flags |= EMAGGED
	if (authenticated)
		authorize_access = SSid_access.get_region_access_list(list(REGION_ALL_STATION))
	balloon_alert(user, "routing circuits scrambled")
	playsound(src, 'sound/machines/terminal/terminal_alert.ogg', 50, FALSE)
	return TRUE

/obj/machinery/computer/communications/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/ui_state)
	var/static/list/approved_states = list(STATE_BUYING_SHUTTLE, STATE_CHANGING_STATUS, STATE_MAIN, STATE_MESSAGES)

	. = ..()
	if (.)
		return

	if (!has_communication())
		return

	var/mob/user = ui.user
	. = TRUE

	switch (action)
		if ("answerMessage")
			if (!authenticated(user))
				return

			var/answer_index = params["answer"]
			var/message_index = params["message"]

			// If either of these aren't numbers, then bad voodoo.
			if(!isnum(answer_index) || !isnum(message_index))
				message_admins("[ADMIN_LOOKUPFLW(user)] provided an invalid index type when replying to a message on [src] [ADMIN_JMP(src)]. This should not happen. Please check with a maintainer and/or consult tgui logs.")
				CRASH("Non-numeric index provided when answering comms console message.")

			if (!answer_index || !message_index || answer_index < 1 || message_index < 1)
				return
			var/datum/comm_message/message = messages[message_index]
			if (message.answered)
				return
			message.answered = answer_index
			message.answer_callback.InvokeAsync()
		if ("callShuttle")
			if (!authenticated(user) || syndicate)
				return
			var/reason = trim(params["reason"], MAX_MESSAGE_LEN)
			if (length(reason) < CALL_SHUTTLE_REASON_LENGTH)
				return
			SSshuttle.requestEvac(user, reason)
			post_status("shuttle")
		if ("changeSecurityLevel")
			if (!authenticated_as_silicon_or_captain(user))
				return

			// Check if they have
			if (!HAS_SILICON_ACCESS(user))
				var/obj/item/held_item = user.get_active_held_item()
				var/obj/item/card/id/id_card = held_item?.GetID()
				if (!istype(id_card))
					to_chat(user, span_warning("You need to swipe your ID!"))
					playsound(src, 'sound/machines/terminal/terminal_prompt_deny.ogg', 50, FALSE)
					return
				if (!(ACCESS_CAPTAIN in id_card.access))
					to_chat(user, span_warning("You are not authorized to do this!"))
					playsound(src, 'sound/machines/terminal/terminal_prompt_deny.ogg', 50, FALSE)
					return

			var/new_sec_level = SSsecurity_level.text_level_to_number(params["newSecurityLevel"])
			if (new_sec_level != SEC_LEVEL_GREEN && new_sec_level != SEC_LEVEL_BLUE)
				return
			if (SSsecurity_level.get_current_level_as_number() >= SEC_LEVEL_DELTA)
				to_chat(user, span_warning("Central Command has placed a lock on the alert level due to a doomsday!"))
				return
			if (SSsecurity_level.get_current_level_as_number() == new_sec_level)
				return

			SSsecurity_level.set_level(new_sec_level)

			to_chat(user, span_notice("Authorization confirmed. Modifying security level."))
			playsound(src, 'sound/machines/terminal/terminal_prompt_confirm.ogg', 50, FALSE)

			// Only notify people if an actual change happened
			user.log_message("changed the security level to [params["newSecurityLevel"]] with [src].", LOG_GAME)
			message_admins("[ADMIN_LOOKUPFLW(user)] has changed the security level to [params["newSecurityLevel"]] with [src] at [AREACOORD(user)].")
			deadchat_broadcast(" has changed the security level to [params["newSecurityLevel"]] with [src] at [span_name("[get_area_name(user, TRUE)]")].", span_name("[user.real_name]"), user, message_type=DEADCHAT_ANNOUNCEMENT)

			alert_level_tick += 1
		if ("deleteMessage")
			if (!authenticated(user))
				return
			var/message_index = text2num(params["message"])
			if (!message_index)
				return
			LAZYREMOVE(messages, LAZYACCESS(messages, message_index))
		if ("makePriorityAnnouncement")
			if (!authenticated_as_silicon_or_captain(user) && !syndicate)
				return
			make_announcement(user)
		if ("messageAssociates")
			if (!authenticated_as_non_silicon_captain(user))
				return
			if (!COOLDOWN_FINISHED(src, important_action_cooldown))
				return

			playsound(src, 'sound/machines/terminal/terminal_prompt_confirm.ogg', 50, FALSE)
			var/message = trim(html_encode(params["message"]), MAX_MESSAGE_LEN)

			var/emagged = obj_flags & EMAGGED
			if (emagged)
				message_syndicate(message, user)
				to_chat(user, span_danger("SYSERR @l(19833)of(transmit.dm): !@$ MESSAGE TRANSMITTED TO SYNDICATE COMMAND."))
			else if(syndicate)
				message_syndicate(message, user)
				to_chat(user, span_danger("Message transmitted to Syndicate Command."))
			else
				message_centcom(message, user)
				to_chat(user, span_notice("Message transmitted to Central Command."))

			var/associates = (emagged || syndicate) ? "the Syndicate": "CentCom"
			user.log_talk(message, LOG_SAY, tag = "message to [associates]")
			deadchat_broadcast(" has messaged [associates], \"[message]\" at [span_name("[get_area_name(user, TRUE)]")].", span_name("[user.real_name]"), user, message_type = DEADCHAT_ANNOUNCEMENT)
			COOLDOWN_START(src, important_action_cooldown, IMPORTANT_ACTION_COOLDOWN)
		if ("purchaseShuttle")
			var/can_buy_shuttles_or_fail_reason = can_buy_shuttles(user)
			if (can_buy_shuttles_or_fail_reason != TRUE)
				if (can_buy_shuttles_or_fail_reason != FALSE)
					to_chat(user, span_alert("[can_buy_shuttles_or_fail_reason]"))
				return
			var/list/shuttles = flatten_list(SSmapping.shuttle_templates)
			var/datum/map_template/shuttle/shuttle = locate(params["shuttle"]) in shuttles
			if (!istype(shuttle))
				return
			if (!can_purchase_this_shuttle(shuttle))
				return
			if (!shuttle.prerequisites_met())
				to_chat(user, span_alert("You have not met the requirements for purchasing this shuttle."))
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

			var/purchaser_name = (obj_flags & EMAGGED) ? scramble_message_replace_chars("AUTHENTICATION FAILURE: CVE-2018-17107", 60) : user.real_name
			minor_announce("[purchaser_name] has purchased [shuttle.name] for [shuttle.credit_cost] credits.[shuttle.extra_desc ? " [shuttle.extra_desc]" : ""]" , "Shuttle Purchase")

			message_admins("[ADMIN_LOOKUPFLW(user)] purchased [shuttle.name].")
			log_shuttle("[key_name(user)] has purchased [shuttle.name].")
			SSblackbox.record_feedback("text", "shuttle_purchase", 1, shuttle.name)
			state = STATE_MAIN
		if ("recallShuttle")
			// AIs cannot recall the shuttle
			if (!authenticated(user) || HAS_SILICON_ACCESS(user) || syndicate)
				return
			SSshuttle.cancelEvac(user)
		if ("requestNukeCodes")
			if (!authenticated_as_non_silicon_captain(user))
				return
			if (!COOLDOWN_FINISHED(src, important_action_cooldown))
				return
			var/reason = trim(html_encode(params["reason"]), MAX_MESSAGE_LEN)
			nuke_request(reason, user)
			to_chat(user, span_notice("Request sent."))
			user.log_message("has requested the nuclear codes from CentCom with reason \"[reason]\"", LOG_SAY)
			priority_announce("The codes for the on-station nuclear self-destruct have been requested by [user]. Confirmation or denial of this request will be sent shortly.", "Nuclear Self-Destruct Codes Requested", SSstation.announcer.get_rand_report_sound())
			playsound(src, 'sound/machines/terminal/terminal_prompt.ogg', 50, FALSE)
			COOLDOWN_START(src, important_action_cooldown, IMPORTANT_ACTION_COOLDOWN)
		if ("restoreBackupRoutingData")
			if (!authenticated_as_non_silicon_captain(user))
				return
			if (!(obj_flags & EMAGGED))
				return
			to_chat(user, span_notice("Backup routing data restored."))
			playsound(src, 'sound/machines/terminal/terminal_prompt_confirm.ogg', 50, FALSE)
			obj_flags &= ~EMAGGED
		if ("sendToOtherSector")
			if (!authenticated_as_non_silicon_captain(user))
				return
			if (!can_send_messages_to_other_sectors(user))
				return
			if (!COOLDOWN_FINISHED(src, important_action_cooldown))
				return

			var/message = trim(html_encode(params["message"]), MAX_MESSAGE_LEN)
			if (!message)
				return

			GLOB.communications_controller.soft_filtering = FALSE
			var/list/hard_filter_result = is_ic_filtered(message)
			if(hard_filter_result)
				tgui_alert(user, "Your message contains: (\"[hard_filter_result[CHAT_FILTER_INDEX_WORD]]\"), which is not allowed on this server.")
				return

			var/list/soft_filter_result = is_soft_ooc_filtered(message)
			if(soft_filter_result)
				if(tgui_alert(user,"Your message contains \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\". \"[soft_filter_result[CHAT_FILTER_INDEX_REASON]]\", Are you sure you want to use it?", "Soft Blocked Word", list("Yes", "No")) != "Yes")
					return
				message_admins("[ADMIN_LOOKUPFLW(user)] has passed the soft filter for \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\". They may be using a disallowed term for a cross-station message. Increasing delay time to reject.\n\n Message: \"[message]\"")
				log_admin_private("[key_name(user)] has passed the soft filter for \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\". They may be using a disallowed term for a cross-station message. Increasing delay time to reject.\n\n Message: \"[message]\"")
				GLOB.communications_controller.soft_filtering = TRUE

			playsound(src, 'sound/machines/terminal/terminal_prompt_confirm.ogg', 50, FALSE)

			var/destination = params["destination"]
			if (!(destination in CONFIG_GET(keyed_list/cross_server)) && destination != "all")
				message_admins("[ADMIN_LOOKUPFLW(user)] has passed an invalid destination into comms console cross-sector message. Message: \"[message]\"")
				return

			user.log_message("is about to send the following message to [destination]: [message]", LOG_GAME)
			to_chat(
				GLOB.admins,
				span_adminnotice( \
					"<b color='orange'>CROSS-SECTOR MESSAGE (OUTGOING):</b> [ADMIN_LOOKUPFLW(user)] is about to send \
					the following message to <b>[destination]</b> (will autoapprove in [GLOB.communications_controller.soft_filtering ? DisplayTimeText(EXTENDED_CROSS_SECTOR_CANCEL_TIME) : DisplayTimeText(CROSS_SECTOR_CANCEL_TIME)]): \
					<b><a href='byond://?src=[REF(src)];reject_cross_comms_message=1'>REJECT</a></b><br> \
					[message]" \
				)
			)

			send_cross_comms_message_timer = addtimer(CALLBACK(src, PROC_REF(send_cross_comms_message), user, destination, message), GLOB.communications_controller.soft_filtering ? EXTENDED_CROSS_SECTOR_CANCEL_TIME : CROSS_SECTOR_CANCEL_TIME, TIMER_STOPPABLE)

			COOLDOWN_START(src, important_action_cooldown, IMPORTANT_ACTION_COOLDOWN)
		if ("setState")
			if (!authenticated(user))
				return
			if (!(params["state"] in approved_states))
				return
			if (state == STATE_BUYING_SHUTTLE && can_buy_shuttles(user) != TRUE)
				return
			set_state(usr, params["state"])
		if ("setStatusMessage")
			if (!authenticated(user))
				return
			var/line_one = reject_bad_text(params["upperText"] || "", MAX_STATUS_LINE_LENGTH)
			var/line_two = reject_bad_text(params["lowerText"] || "", MAX_STATUS_LINE_LENGTH)
			post_status("message", line_one, line_two)
			last_status_display = list(line_one, line_two)
		if ("setStatusPicture")
			if (!authenticated(user))
				return
			var/picture = params["picture"]
			if (!(picture in GLOB.status_display_approved_pictures))
				return
			if(picture in GLOB.status_display_state_pictures)
				post_status(picture)
			else
				if(picture == "currentalert") // You cannot set Code Blue display during Code Red and similiar
					post_status("alert", SSsecurity_level?.current_security_level?.status_display_icon_state || "greenalert")
				else
					post_status("alert", picture)

		if ("toggleAuthentication")
			// Log out if we're logged in
			if (authorize_name)
				authenticated = FALSE
				authorize_access = null
				authorize_name = null
				playsound(src, 'sound/machines/terminal/terminal_off.ogg', 50, FALSE)
				return

			if (obj_flags & EMAGGED)
				authenticated = TRUE
				authorize_access = SSid_access.get_region_access_list(list(REGION_ALL_STATION))
				authorize_name = "Unknown"
				to_chat(user, span_warning("[src] lets out a quiet alarm as its login is overridden."))
				playsound(src, 'sound/machines/terminal/terminal_alert.ogg', 25, FALSE)
			else if(isliving(user))
				var/mob/living/L = user
				var/obj/item/card/id/id_card = L.get_idcard(hand_first = TRUE)
				if (check_access(id_card))
					authenticated = TRUE
					authorize_access = id_card.access.Copy()
					authorize_name = "[id_card.registered_name] - [id_card.assignment]"

			state = STATE_MAIN
			playsound(src, 'sound/machines/terminal/terminal_on.ogg', 50, FALSE)
			imprint_gps("Encrypted Communications Channel")

		if ("toggleEmergencyAccess")
			if(emergency_access_cooldown(user)) //if were in cooldown, dont allow the following code
				return
			if (!authenticated_as_silicon_or_captain(user))
				return
			if (GLOB.emergency_access)
				revoke_maint_all_access()
				user.log_message("disabled emergency maintenance access.", LOG_GAME)
				message_admins("[ADMIN_LOOKUPFLW(user)] disabled emergency maintenance access.")
				deadchat_broadcast(" disabled emergency maintenance access at [span_name("[get_area_name(user, TRUE)]")].", span_name("[user.real_name]"), user, message_type = DEADCHAT_ANNOUNCEMENT)
			else
				make_maint_all_access()
				user.log_message("enabled emergency maintenance access.", LOG_GAME)
				message_admins("[ADMIN_LOOKUPFLW(user)] enabled emergency maintenance access.")
				deadchat_broadcast(" enabled emergency maintenance access at [span_name("[get_area_name(user, TRUE)]")].", span_name("[user.real_name]"), user, message_type = DEADCHAT_ANNOUNCEMENT)
		// Request codes for the Captain's Spare ID safe.
		if("requestSafeCodes")
			if(SSjob.assigned_captain)
				to_chat(user, span_warning("There is already an assigned Captain or Acting Captain on deck!"))
				return

			if(SSjob.safe_code_timer_id)
				to_chat(user, span_warning("The safe code has already been requested and is being delivered to your station!"))
				return

			if(SSjob.safe_code_requested)
				to_chat(user, span_warning("The safe code has already been requested and delivered to your station!"))
				return

			if(!SSid_access.spare_id_safe_code)
				to_chat(user, span_warning("There is no safe code to deliver to your station!"))
				return

			var/turf/pod_location = get_turf(src)

			SSjob.safe_code_request_loc = pod_location
			SSjob.safe_code_requested = TRUE
			SSjob.safe_code_timer_id = addtimer(CALLBACK(SSjob, TYPE_PROC_REF(/datum/controller/subsystem/job, send_spare_id_safe_code), pod_location), 120 SECONDS, TIMER_UNIQUE | TIMER_STOPPABLE)
			minor_announce("Due to staff shortages, your station has been approved for delivery of access codes to secure the Captain's Spare ID. Delivery via drop pod at [get_area(pod_location)]. ETA 120 seconds.")

/obj/machinery/computer/communications/proc/emergency_access_cooldown(mob/user)
	if(toggle_uses == toggle_max_uses) //you have used up free uses already, do it one more time and start a cooldown
		to_chat(user, span_warning("This was your last free use without cooldown, you will not be able to use this again for [DisplayTimeText(EMERGENCY_ACCESS_COOLDOWN)]."))
		COOLDOWN_START(src, emergency_access_cooldown, EMERGENCY_ACCESS_COOLDOWN)
		++toggle_uses //add a use so that this if() is false the next time you try this button
		return FALSE

	if(!COOLDOWN_FINISHED(src, emergency_access_cooldown))
		var/time_left = DisplayTimeText(COOLDOWN_TIMELEFT(src, emergency_access_cooldown), 1)
		to_chat(user, span_warning("Emergency Access is still in cooldown for [time_left]!"))
		return TRUE //dont use the button, we are in cooldown
	else if((last_toggled + EMERGENCY_ACCESS_COOLDOWN) < world.time)
		toggle_uses = 0 //either cooldown is done, or we just havent touched it in 30 seconds, either way reset uses

	++toggle_uses //add a use
	last_toggled = world.time
	return FALSE //if we are not in cooldown, allow using the button

/obj/machinery/computer/communications/proc/send_cross_comms_message(mob/user, destination, message)
	send_cross_comms_message_timer = null

	var/list/payload = list()

	payload["sender_ckey"] = user.ckey
	var/network_name = CONFIG_GET(string/cross_comms_network)
	if(network_name)
		payload["network"] = network_name
	if(GLOB.communications_controller.soft_filtering)
		payload["is_filtered"] = TRUE

	send2otherserver(html_decode(station_name()), message, "Comms_Console", destination == "all" ? null : list(destination), additional_data = payload)
	minor_announce(message, title = "Outgoing message to allied station")
	user.log_talk(message, LOG_SAY, tag = "message to the other server")
	message_admins("[ADMIN_LOOKUPFLW(user)] has sent a message to the other server\[s].")
	deadchat_broadcast(" has sent an outgoing message to the other station(s).</span>", "<span class='bold'>[user.real_name]", user, message_type = DEADCHAT_ANNOUNCEMENT)
	GLOB.communications_controller.soft_filtering = FALSE // set it to false at the end of the proc to ensure that everything prior reads as intended

/obj/machinery/computer/communications/ui_data(mob/user)
	var/list/data = list(
		"authenticated" = FALSE,
		"emagged" = FALSE,
		"syndicate" = syndicate,
	)

	var/ui_state = HAS_SILICON_ACCESS(user) ? cyborg_state : state

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

	if (authenticated || HAS_SILICON_ACCESS(user))
		data["authenticated"] = TRUE
		data["canLogOut"] = !HAS_SILICON_ACCESS(user)
		data["page"] = ui_state

		if ((obj_flags & EMAGGED) || syndicate)
			data["emagged"] = TRUE

		switch (ui_state)
			if (STATE_MAIN)
				data["canBuyShuttles"] = can_buy_shuttles(user)
				data["canMakeAnnouncement"] = FALSE
				data["canMessageAssociates"] = FALSE
				data["canRecallShuttles"] = !HAS_SILICON_ACCESS(user)
				data["canRequestNuke"] = FALSE
				data["canSendToSectors"] = FALSE
				data["canSetAlertLevel"] = FALSE
				data["canToggleEmergencyAccess"] = FALSE
				data["importantActionReady"] = COOLDOWN_FINISHED(src, important_action_cooldown)
				data["shuttleCalled"] = FALSE
				data["shuttleLastCalled"] = FALSE
				data["aprilFools"] = check_holidays(APRIL_FOOLS)
				data["alertLevel"] = SSsecurity_level.get_current_level_as_text()
				data["authorizeName"] = authorize_name
				data["canLogOut"] = !HAS_SILICON_ACCESS(user)
				data["shuttleCanEvacOrFailReason"] = SSshuttle.canEvac()
				if(syndicate)
					data["shuttleCanEvacOrFailReason"] = "You cannot summon the shuttle from this console!"

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
					data["canSetAlertLevel"] = HAS_SILICON_ACCESS(user) ? "NO_SWIPE_NEEDED" : "SWIPE_NEEDED"
				else if(syndicate)
					data["canMakeAnnouncement"] = TRUE

				if (SSshuttle.emergency.mode != SHUTTLE_IDLE && SSshuttle.emergency.mode != SHUTTLE_RECALL)
					data["shuttleCalled"] = TRUE
					data["shuttleRecallable"] = SSshuttle.canRecall() || syndicate

				if (SSshuttle.emergencyCallAmount)
					data["shuttleCalledPreviously"] = TRUE
					if (SSshuttle.emergency_last_call_loc)
						data["shuttleLastCalled"] = format_text(SSshuttle.emergency_last_call_loc.name)
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

					shuttles += list(list(
						"name" = shuttle_template.name,
						"description" = shuttle_template.description,
						"occupancy_limit" = shuttle_template.occupancy_limit,
						"creditCost" = shuttle_template.credit_cost,
						"initial_cost" = initial(shuttle_template.credit_cost),
						"emagOnly" = shuttle_template.emag_only,
						"prerequisites" = shuttle_template.prerequisites,
						"ref" = REF(shuttle_template),
					))

				data["budget"] = bank_account.account_balance
				data["shuttles"] = shuttles
			if (STATE_CHANGING_STATUS)
				data["upperText"] = last_status_display ? last_status_display[1] : ""
				data["lowerText"] = last_status_display ? last_status_display[2] : ""

	return data

/obj/machinery/computer/communications/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
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

/obj/machinery/computer/communications/Topic(href, href_list)
	if (href_list["reject_cross_comms_message"])
		if (!usr.client?.holder)
			usr.log_message("tried to reject a cross-comms message without being an admin.", LOG_ADMIN)
			message_admins("[key_name(usr)] tried to reject a cross-comms message without being an admin.")
			return

		if (isnull(send_cross_comms_message_timer))
			to_chat(usr, span_warning("It's too late!"))
			return

		deltimer(send_cross_comms_message_timer)
		GLOB.communications_controller.soft_filtering = FALSE
		send_cross_comms_message_timer = null

		log_admin("[key_name(usr)] has cancelled the outgoing cross-comms message.")
		message_admins("[key_name(usr)] has cancelled the outgoing cross-comms message.")

		return TRUE

	return ..()

/// Returns whether or not the communications console can communicate with the station
/obj/machinery/computer/communications/proc/has_communication()
	var/turf/current_turf = get_turf(src)
	var/z_level = current_turf.z
	if(syndicate)
		return TRUE
	return is_station_level(z_level) || is_centcom_level(z_level)

/obj/machinery/computer/communications/proc/set_state(mob/user, new_state)
	if (HAS_SILICON_ACCESS(user))
		cyborg_state = new_state
	else
		state = new_state

/// Returns TRUE if the user can buy shuttles.
/// If they cannot, returns FALSE or a string detailing why.
/obj/machinery/computer/communications/proc/can_buy_shuttles(mob/user)
	if (!SSmapping.current_map.allow_custom_shuttles)
		return FALSE
	if (HAS_SILICON_ACCESS(user))
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

	if (shuttle_template.emag_only)
		return !!(obj_flags & EMAGGED)

	for (var/access in authorize_access)
		if (access in shuttle_template.who_can_purchase)
			return TRUE

	return FALSE

/obj/machinery/computer/communications/proc/can_send_messages_to_other_sectors(mob/user)
	if (!authenticated_as_non_silicon_captain(user))
		return

	return length(CONFIG_GET(keyed_list/cross_server)) > 0

/obj/machinery/computer/communications/proc/make_announcement(mob/living/user)
	var/is_ai = HAS_SILICON_ACCESS(user)
	if(!GLOB.communications_controller.can_announce(user, is_ai))
		to_chat(user, span_alert("Intercomms recharging. Please stand by."))
		return
	var/input = tgui_input_text(user, "Message to announce to the station crew", "Announcement", max_length = MAX_MESSAGE_LEN)
	if(!input || !user.can_perform_action(src, ALLOW_SILICON_REACH))
		return
	if(user.try_speak(input))
		//Adds slurs and so on. Someone should make this use languages too.
		var/list/input_data = user.treat_message(input)
		input = input_data["message"]
	else
		//No cheating, mime/random mute guy!
		input = "..."
		user.visible_message(
			span_notice("[user] holds down [src]'s announcement button, leaving the mic on in awkward silence."),
			span_notice("You leave the mic on in awkward silence..."),
			span_hear("You hear an awkward silence, somehow."),
			vision_distance = 4,
		)

	var/list/players = get_communication_players()
	GLOB.communications_controller.make_announcement(user, is_ai, input, syndicate || (obj_flags & EMAGGED), players)
	deadchat_broadcast(" made a priority announcement from [span_name("[get_area_name(user, TRUE)]")].", span_name("[user.real_name]"), user, message_type=DEADCHAT_ANNOUNCEMENT)

/obj/machinery/computer/communications/proc/get_communication_players()
	return GLOB.player_list

/obj/machinery/computer/communications/proc/post_status(command, data1, data2)

	var/datum/radio_frequency/frequency = SSradio.return_frequency(FREQ_STATUS_DISPLAYS)

	if(!frequency)
		return

	var/datum/signal/status_signal = new(list("command" = command))
	switch(command)
		if("message")
			status_signal.data["top_text"] = data1
			status_signal.data["bottom_text"] = data2
			log_game("[key_name(usr)] has changed the station status display message to \"[data1] [data2]\" [loc_name(usr)]")

		if("alert")
			status_signal.data["picture_state"] = data1
			log_game("[key_name(usr)] has changed the station status display message to \"[data1]\" [loc_name(usr)]")


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

/// Defines for the various hack results.
#define HACK_PIRATE "Pirates"
#define HACK_FUGITIVES "Fugitives"
#define HACK_SLEEPER "Sleeper Agents"
#define HACK_THREAT "Threat Boost"

/// The minimum number of ghosts / observers to have the chance of spawning pirates.
#define MIN_GHOSTS_FOR_PIRATES 4
/// The minimum number of ghosts / observers to have the chance of spawning fugitives.
#define MIN_GHOSTS_FOR_FUGITIVES 6
/// The maximum percentage of the population to be ghosts before we no longer have the chance of spawning Sleeper Agents.
#define MAX_PERCENT_GHOSTS_FOR_SLEEPER 0.2

/// Begin the process of hacking into the comms console to call in a threat.
/obj/machinery/computer/communications/proc/try_hack_console(mob/living/hacker, duration = 30 SECONDS)
	if(!can_hack(hacker, feedback = TRUE))
		return FALSE

	AI_notify_hack()
	if(!do_after(hacker, duration, src, extra_checks = CALLBACK(src, PROC_REF(can_hack), hacker)))
		return FALSE

	hack_console(hacker)
	return TRUE

/// Checks if this console is hackable. Used as a callback during try_hack_console's doafter as well.
/obj/machinery/computer/communications/proc/can_hack(mob/living/hacker, feedback = FALSE)
	if(machine_stat & (NOPOWER|BROKEN))
		if(feedback && hacker)
			balloon_alert(hacker, "can't hack!")
		return FALSE
	var/area/console_area = get_area(src)
	if(!console_area || !(console_area.area_flags & VALID_TERRITORY))
		if(feedback && hacker)
			balloon_alert(hacker, "signal too weak!")
		return FALSE
	return TRUE

/**
 * The communications console hack,
 * called by certain antagonist actions.
 *
 * Brings in additional threats to the round.
 *
 * hacker - the mob that caused the hack
 */
/obj/machinery/computer/communications/proc/hack_console(mob/living/hacker)
	// All hack results we'll choose from.
	var/list/hack_options = list(HACK_THREAT)

	// If we have a certain amount of ghosts, we'll add some more !!fun!! options to the list
	var/num_ghosts = length(GLOB.current_observers_list) + length(GLOB.dead_player_list)

	// Pirates / Fugitives have enough lead in time that there's no point summoning them if the shuttle is called
	// Both of these events also summon space ships and so cannot run on planetary maps
	if (EMERGENCY_IDLE_OR_RECALLED && !SSmapping.is_planetary())
		// Pirates require ghosts for the pirates obviously
		if(num_ghosts >= MIN_GHOSTS_FOR_PIRATES)
			hack_options += HACK_PIRATE
		// Fugitives require ghosts for both fugitives and hunters (Please no waldo)
		if(num_ghosts >= MIN_GHOSTS_FOR_FUGITIVES)
			hack_options += HACK_FUGITIVES

	if (!EMERGENCY_PAST_POINT_OF_NO_RETURN)
		// If less than a certain percent of the population is ghosts, consider sleeper agents
		if(num_ghosts < (length(GLOB.clients) * MAX_PERCENT_GHOSTS_FOR_SLEEPER))
			hack_options += HACK_SLEEPER

	var/picked_option = pick(hack_options)
	message_admins("[ADMIN_LOOKUPFLW(hacker)] hacked a [name] located at [ADMIN_VERBOSEJMP(src)], resulting in: [picked_option]!")
	hacker.log_message("hacked a communications console, resulting in: [picked_option].", LOG_GAME, log_globally = TRUE)
	switch(picked_option)
		if(HACK_PIRATE) // Triggers pirates, which the crew may be able to pay off to prevent
			var/list/pirate_rulesets = list(
				/datum/dynamic_ruleset/midround/pirates,
				/datum/dynamic_ruleset/midround/dangerous_pirates,
			)
			priority_announce(
				"Attention crew: sector monitoring reports a massive jump-trace from an enemy vessel destined for your system. Prepare for imminent hostile contact.",
				"[command_name()] High-Priority Update",
			)
			SSdynamic.picking_specific_rule(pick(pirate_rulesets), forced = TRUE, ignore_cost = TRUE)

		if(HACK_FUGITIVES) // Triggers fugitives, which can cause confusion / chaos as the crew decides which side help
			priority_announce(
				"Attention crew: sector monitoring reports a jump-trace from an unidentified vessel destined for your system. Prepare for probable contact.",
				"[command_name()] High-Priority Update",
			)

			force_event_after(/datum/round_event_control/fugitives, "[hacker] hacking a communications console", rand(20 SECONDS, 1 MINUTES))

		if(HACK_THREAT) // Force an unfavorable situation on the crew
			priority_announce(
				"Attention crew, the Nanotrasen Department of Intelligence has received intel suggesting increased enemy activity in your sector beyond that initially reported in today's threat advisory.",
				"[command_name()] High-Priority Update",
			)

			for(var/mob/crew_member as anything in GLOB.player_list)
				if(!is_station_level(crew_member.z))
					continue
				shake_camera(crew_member, 15, 1)

			SSdynamic.unfavorable_situation()

		if(HACK_SLEEPER) // Trigger one or multiple sleeper agents with the crew (or for latejoining crew)
			var/datum/dynamic_ruleset/midround/sleeper_agent_type = /datum/dynamic_ruleset/midround/from_living/autotraitor
			var/max_number_of_sleepers = clamp(round(length(GLOB.alive_player_list) / 20), 1, 3)
			var/num_agents_created = 0
			for(var/num_agents in 1 to rand(1, max_number_of_sleepers))
				if(!SSdynamic.picking_specific_rule(sleeper_agent_type, forced = TRUE, ignore_cost = TRUE))
					break
				num_agents_created++

			if(num_agents_created <= 0)
				// We failed to run any midround sleeper agents, so let's be patient and run latejoin traitor
				SSdynamic.picking_specific_rule(/datum/dynamic_ruleset/latejoin/infiltrator, forced = TRUE, ignore_cost = TRUE)

			else
				// We spawned some sleeper agents, nice - give them a report to kickstart the paranoia
				priority_announce(
					"Attention crew, it appears that someone on your station has hijacked your telecommunications and broadcasted an unknown signal.",
					"[command_name()] High-Priority Update",
				)

#undef HACK_PIRATE
#undef HACK_FUGITIVES
#undef HACK_SLEEPER
#undef HACK_THREAT

#undef MIN_GHOSTS_FOR_PIRATES
#undef MIN_GHOSTS_FOR_FUGITIVES
#undef MAX_PERCENT_GHOSTS_FOR_SLEEPER

/datum/comm_message
	var/title
	var/content
	var/list/possible_answers = list()
	var/answered = FALSE
	var/datum/callback/answer_callback

/datum/comm_message/New(new_title,new_content,new_possible_answers)
	..()
	if(new_title)
		title = new_title
	if(new_content)
		content = new_content
	if(new_possible_answers)
		possible_answers = new_possible_answers

/datum/comm_message/Destroy()
	answer_callback = null
	return ..()

#undef IMPORTANT_ACTION_COOLDOWN
#undef EMERGENCY_ACCESS_COOLDOWN
#undef STATE_BUYING_SHUTTLE
#undef STATE_CHANGING_STATUS
#undef STATE_MAIN
#undef STATE_MESSAGES
