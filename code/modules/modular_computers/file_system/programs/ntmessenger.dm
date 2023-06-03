GLOBAL_LIST_EMPTY_TYPED(TabletMessengers, /datum/computer_file/program/messenger) // a list of all active and visible messengers

///Registers an NTMessenger instance to the list of TabletMessengers. If it exists, updates it.
/proc/add_messenger(datum/computer_file/program/messenger/msgr)
	var/obj/item/modular_computer/messenger_device = msgr.computer
	// a bunch of empty PDAs are normally allocated, we don't want that clutter
	if(!messenger_device.saved_identification || !messenger_device.saved_job)
		return

	if(!istype(msgr))
		return

	var/msgr_ref = REF(msgr)
	if(msgr_ref in GLOB.TabletMessengers)
		return

	GLOB.TabletMessengers[msgr_ref] = msgr

///Unregisters an NTMessenger instance from the TabletMessengers table.
/proc/remove_messenger(datum/computer_file/program/messenger/msgr)
	if(!istype(msgr))
		return

	var/msgr_ref = REF(msgr)
	if(!(msgr_ref in GLOB.TabletMessengers))
		return

	GLOB.TabletMessengers.Remove(msgr_ref)

/proc/get_messengers_sorted(sort_by_job = FALSE)
	var/sortmode
	if(sort_by_job)
		sortmode = GLOBAL_PROC_REF(cmp_pdajob_asc)
	else
		sortmode = GLOBAL_PROC_REF(cmp_pdaname_asc)

	return sortTim(GLOB.TabletMessengers.Copy(), sortmode, associative = TRUE)

/proc/StringifyMessengerTarget(obj/item/modular_computer/messenger)
	return STRINGIFY_PDA_TARGET(messenger.saved_identification, messenger.saved_job)

/datum/computer_file/program/messenger
	filename = "nt_messenger"
	filedesc = "Direct Messenger"
	category = PROGRAM_CATEGORY_MISC
	program_icon_state = "command"
	extended_desc = "This program allows old-school communication with other modular devices."
	size = 0
	undeletable = TRUE // It comes by default in tablets, can't be downloaded, takes no space and should obviously not be able to be deleted.
	header_program = TRUE
	available_on_ntnet = FALSE
	usage_flags = PROGRAM_TABLET
	ui_header = "ntnrc_idle.gif"
	tgui_id = "NtosMessenger"
	program_icon = "comment-alt"
	alert_able = TRUE

	/// The current ringtone (displayed in the chat when a message is received).
	var/ringtone = MESSENGER_RINGTONE_DEFAULT
	/// Whether or not the ringtone is currently on.
	var/ringer_status = TRUE
	/// Whether or not we're sending and receiving messages.
	var/sending_and_receiving = TRUE
	/// The messages currently saved in the app.
	var/list/messages = list()
	/// great wisdom from PDA.dm - "no spamming" (prevents people from spamming the same message over and over)
	var/last_text
	/// even more wisdom from PDA.dm - "no everyone spamming" (prevents people from spamming the same message over and over)
	var/last_text_everyone
	/// Scanned photo for sending purposes.
	var/datum/picture/saved_image
	/// Whether the user is invisible to the message list.
	var/invisible = FALSE
	/// Whose chatlogs we currently have open. If we are in the contacts list, this is null.
	var/viewing_messages_of = null
	// Whether or not this device is currently hidden from the message monitor.
	var/monitor_hidden = FALSE
	// Whether or not we're sorting by job.
	var/sort_by_job = TRUE
	// Whether or not we're sending (or trying to send) a virus.
	var/sending_virus = FALSE

	/// The path for the current loaded image in rsc
	var/photo_path

	/// Whether or not we're in a mime PDA.
	var/mime_mode = FALSE
	/// Whether this app can send messages to all.
	var/spam_mode = FALSE

/datum/computer_file/program/messenger/on_install()
	. = ..()
	RegisterSignal(computer, COMSIG_MODPC_IMPRINT_UPDATED, PROC_REF(on_imprint_added))
	RegisterSignal(computer, COMSIG_MODPC_IMPRINT_RESET, PROC_REF(on_imprint_reset))

/datum/computer_file/program/messenger/proc/on_imprint_added()
	SIGNAL_HANDLER
	add_messenger(src)

/datum/computer_file/program/messenger/proc/on_imprint_reset()
	SIGNAL_HANDLER
	remove_messenger(src)

/datum/computer_file/program/messenger/Destroy(force)
	if(!QDELETED(computer))
		stack_trace("Attempted to qdel messenger of [computer] without qdeling computer, this will cause problems later")
	remove_messenger(src)
	UnregisterSignal(computer, COMSIG_MODPC_IMPRINT_UPDATED)
	UnregisterSignal(computer, COMSIG_MODPC_IMPRINT_RESET)
	return ..()

/datum/computer_file/program/messenger/application_attackby(obj/item/attacking_item, mob/living/user)
	if(!istype(attacking_item, /obj/item/photo))
		return FALSE
	var/obj/item/photo/pic = attacking_item
	saved_image = pic.picture
	ProcessPhoto()
	user.balloon_alert(user, "photo uploaded")
	return TRUE

/datum/computer_file/program/messenger/proc/get_messengers()
	var/list/dictionary = list()

	var/list/messengers_sorted = get_messengers_sorted(sort_by_job)

	for(var/messenger_ref in messengers_sorted)
		var/datum/computer_file/program/messenger/msgr = messengers_sorted[messenger_ref]
		if(msgr == src || msgr.monitor_hidden || msgr.invisible) continue

		var/list/data = list()
		data["name"] = msgr.computer.saved_identification
		data["job"] = msgr.computer.saved_job
		data["ref"] = REF(msgr)

		dictionary += list(data["ref"] = data)

	return dictionary

/datum/computer_file/program/messenger/proc/ProcessPhoto()
	if(saved_image)
		var/icon/img = saved_image.picture_image
		var/deter_path = "tmp_msg_photo[rand(0, 99999)].png"
		usr << browse_rsc(img, deter_path) // funny random assignment for now, i'll make an actual key later
		photo_path = deter_path

/datum/computer_file/program/messenger/proc/can_send_everyone_message()
	return (last_text && world.time < last_text + 10) || (last_text_everyone && world.time < last_text_everyone + 2 MINUTES)

/datum/computer_file/program/messenger/ui_state(mob/user)
	if(issilicon(user))
		return GLOB.reverse_contained_state
	return GLOB.default_state

/datum/computer_file/program/messenger/ui_act(action, list/params, datum/tgui/ui)
	switch(action)
		if("PDA_ringSet")
			var/new_ringtone = tgui_input_text(usr, "Enter a new ringtone", "Ringtone", ringtone, MESSENGER_RINGTONE_MAX_LENGTH)
			var/mob/living/usr_mob = usr
			if(!new_ringtone || !in_range(computer, usr_mob) || computer.loc != usr_mob)
				return

			if(SEND_SIGNAL(computer, COMSIG_TABLET_CHANGE_ID, usr_mob, new_ringtone) & COMPONENT_STOP_RINGTONE_CHANGE)
				return

			ringtone = new_ringtone
			return TRUE

		if("PDA_ringer_status")
			ringer_status = !ringer_status
			return TRUE

		if("PDA_sAndR")
			sending_and_receiving = !sending_and_receiving
			return TRUE

		if("PDA_viewMessages")
			viewing_messages_of = params["ref"]
			return TRUE

		if("PDA_clearMessages")
			var/user_ref = params["ref"]
			if(user_ref)
				for(var/list/message in messages)
					if((user_ref in message["targets"]) || message["sender"] == user_ref)
						messages -= list(message)
			else
				messages = list()
			viewing_messages_of = null
			return TRUE

		if("PDA_changeSortStyle")
			sort_by_job = !sort_by_job
			return TRUE

		if("PDA_sendEveryone")
			if(!sending_and_receiving)
				to_chat(usr, span_notice("ERROR: Device has sending disabled."))
				return

			if(!spam_mode)
				to_chat(usr, span_notice("ERROR: Device does not have mass-messaging perms."))
				return

			if(can_send_everyone_message())
				to_chat(usr, span_warning("The subspace transmitter of your tablet is still cooling down!"))
				return

			send_message_to_all(usr, params["msg"])

			return TRUE

		if("PDA_sendMessage")
			if(!sending_and_receiving)
				to_chat(usr, span_notice("ERROR: Device has sending disabled."))
				return TRUE

			var/target_ref = params["ref"]

			if(!(target_ref in GLOB.TabletMessengers))
				to_chat(usr, span_notice("ERROR: User no longer exists."))
				return TRUE

			var/datum/computer_file/program/messenger/target = GLOB.TabletMessengers[target_ref]
			if(!istype(target))
				return TRUE // we don't want tommy sending his messages to nullspace

			if(!target.sending_and_receiving && !sending_virus)
				to_chat(usr, span_notice("ERROR: Recipient has receiving disabled."))
				return TRUE

			if(sending_virus)
				var/obj/item/computer_disk/virus/disk = computer.inserted_disk
				if(istype(disk))
					disk.send_virus(computer, target, usr)
					update_static_data(usr, ui)
					return TRUE

			send_message(usr, list(target), params["msg"])
			return TRUE

		if("PDA_clearPhoto")
			saved_image = null
			photo_path = null
			return TRUE

		if("PDA_toggleVirus")
			sending_virus = !sending_virus
			return TRUE

		if("PDA_selectPhoto")
			if(!issilicon(usr))
				return
			var/mob/living/silicon/user = usr
			if(!user.aicamera)
				return
			var/datum/picture/selected_photo = user.aicamera.selectpicture(user)
			if(!selected_photo)
				return
			saved_image = selected_photo
			ProcessPhoto()
			return TRUE

/datum/computer_file/program/messenger/ui_static_data(mob/user)
	var/list/data = ..()

	data["owner"] = list(
		"name" = computer.saved_identification,
		"job" = computer.saved_job,
		"ref" = REF(src),
	)
	data["is_silicon"] = issilicon(user)

	return data

/datum/computer_file/program/messenger/ui_data(mob/user)
	var/list/data = list()

	var/list/messengers = get_messengers()
	// im very unhappy about this, but pda code has forced my hand
	if(viewing_messages_of && !(viewing_messages_of in messengers))
		viewing_messages_of = null

	data["messages"] = messages
	data["messengers"] = messengers
	data["sort_by_job"] = sort_by_job
	data["ringer_status"] = ringer_status
	data["sending_and_receiving"] = sending_and_receiving
	data["viewing_messages_of"] = viewing_messages_of ? messengers[viewing_messages_of] : null
	data["photo"] = photo_path
	data["can_spam"] = spam_mode
	data["on_spam_cooldown"] = can_send_everyone_message()

	var/obj/item/computer_disk/virus/disk = computer.inserted_disk
	if(disk && istype(disk))
		data["virus_attach"] = TRUE
		data["sending_virus"] = sending_virus
	return data

//////////////////////
// MESSAGE HANDLING //
//////////////////////

///Brings up the quick reply prompt to send a message.
/datum/computer_file/program/messenger/proc/quick_reply_prompt(mob/living/user, datum/computer_file/program/messenger/target)
	var/target_name = target.computer.saved_identification
	var/input_message = tgui_input_text(user, "Enter [mime_mode ? "emojis":"a message"]", "NT Messaging[target_name ? " ([target_name])" : ""]", encode = FALSE)
	send_message(user, list(target), input_message)

/datum/computer_file/program/messenger/proc/send_message_to_all(mob/living/user, message)
	var/list/targets = list()
	for(var/mc in get_messengers())
		targets += GLOB.TabletMessengers[mc]
	send_message(user, targets, message, everyone = TRUE)
	last_text_everyone = world.time

///Sends a message to targets via PDA. When sending to everyone, set `everyone` to true so the message is formatted accordingly
/datum/computer_file/program/messenger/proc/send_message(mob/living/user, list/datum/computer_file/program/messenger/targets, message, everyone = FALSE, rigged = FALSE, fake_name = null, fake_job = null)
	if(!user.can_perform_action(computer))
		return

	if(!length(targets))
		return FALSE

	if(mime_mode)
		message = emoji_sanitize(message)

	message = html_encode(message)

	// message at this point is not html escaped
	if(!message)
		return FALSE

	var/turf/position = get_turf(computer)
	for(var/obj/item/jammer/jammer as anything in GLOB.active_jammers)
		var/turf/jammer_turf = get_turf(jammer)
		if(position?.z == jammer_turf.z && (get_dist(position, jammer_turf) <= jammer.range))
			return FALSE

	var/list/filter_result = CAN_BYPASS_FILTER(user) ? null : is_ic_filtered_for_pdas(message)
	if (filter_result)
		REPORT_CHAT_FILTER_TO_USER(user, filter_result)
		return FALSE

	var/list/soft_filter_result = CAN_BYPASS_FILTER(user) ? null : is_soft_ic_filtered_for_pdas(message)
	if (soft_filter_result)
		if(tgui_alert(usr,"Your message contains \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\". \"[soft_filter_result[CHAT_FILTER_INDEX_REASON]]\", Are you sure you want to send it?", "Soft Blocked Word", list("Yes", "No")) != "Yes")
			return FALSE
		message_admins("[ADMIN_LOOKUPFLW(usr)] has passed the soft filter for \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\" they may be using a disallowed term in PDA messages. Message: \"[message]\"")
		log_admin_private("[key_name(usr)] has passed the soft filter for \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\" they may be using a disallowed term in PDA messages. Message: \"[message]\"")

	// Send the signal
	var/list/string_targets = list()
	for (var/datum/computer_file/program/messenger/program in targets)
		var/obj/item/modular_computer/comp = program.computer
		if (comp.saved_identification && comp.saved_job)  // != src is checked by the UI
			string_targets += STRINGIFY_PDA_TARGET(comp.saved_identification, comp.saved_job)

	if (!string_targets.len)
		return FALSE
	var/sent_prob = 1
	if(ishuman(user))
		var/mob/living/carbon/human/old_person = user
		sent_prob = old_person.age >= 30 ? 25 : sent_prob
	if (prob(sent_prob))
		message += " Sent from my PDA"

	var/datum/signal/subspace/messaging/tablet_msg/signal = new(computer, list(
		"name" = fake_name || computer.saved_identification,
		"job" = fake_job || computer.saved_job,
		"message" = message,
		"ref" = REF(src),
		"targets" = targets,
		"rigged" = rigged,
		"photo" = saved_image,
		"photo_path" = photo_path,
		"automated" = FALSE,
		"everyone" = everyone,
	))
	if(rigged) //Will skip the message server and go straight to the hub so it can't be cheesed by disabling the message server machine
		signal.data["rigged_user"] = REF(user) // Used for bomb logging
		signal.server_type = /obj/machinery/telecomms/hub
		signal.data["reject"] = FALSE // Do not refuse the message

	signal.send_to_receivers()

	// If it didn't reach, note that fact
	if (!signal.data["done"])
		to_chat(user, span_notice("ERROR: Server isn't responding."))
		if(ringer_status)
			playsound(src, 'sound/machines/terminal_error.ogg', 15, TRUE)
		return FALSE

	message = emoji_parse(message)//already sent- this just shows the sent emoji as one to the sender in the to_chat
	signal.data["message"] = emoji_parse(signal.data["message"])

	// produce references to our targets and send those to UI
	var/list/target_refs = list()
	for(var/datum/computer_file/program/messenger/target_computer in signal.data["targets"])
		target_refs += REF(target_computer)

	// Log it in our logs
	var/list/message_data = list()
	message_data["name"] = signal.data["name"]
	message_data["job"] = signal.data["job"]
	message_data["contents"] = signal.data["message"]
	message_data["outgoing"] = TRUE
	message_data["sender"] = signal.data["ref"]
	message_data["photo_path"] = signal.data["photo_path"]
	message_data["photo"] = signal.data["photo"]
	message_data["targets"] = target_refs
	message_data["target_details"] = signal.format_target()
	message_data["everyone"] = everyone

	// Show it to ghosts
	var/ghost_message = span_name("[message_data["name"]] </span><span class='game say'>[rigged ? "Rigged" : ""] PDA Message</span> --> [span_name("[signal.format_target()]")]: <span class='message'>[signal.format_message()]")
	for(var/mob/player_mob in GLOB.player_list)
		if(player_mob.client && !player_mob.client?.prefs)
			stack_trace("[player_mob] ([player_mob.ckey]) had null prefs, which shouldn't be possible!")
			continue

		if(isobserver(player_mob) && (player_mob.client?.prefs.chat_toggles & CHAT_GHOSTPDA))
			to_chat(player_mob, "[FOLLOW_LINK(player_mob, user)] [ghost_message]")

	// Log in the talk log
	user.log_talk(message, LOG_PDA, tag="[rigged ? "Rigged" : ""] PDA: [message_data["name"]] to [signal.format_target()]")
	if(rigged)
		log_bomber(user, "sent a rigged PDA message (Name: [message_data["name"]]. Job: [message_data["job"]]) to [english_list(string_targets)] [!is_special_character(user) ? "(SENT BY NON-ANTAG)" : ""]")
	to_chat(user, span_info("PDA message sent to [signal.format_target()]: [sanitize(html_decode(signal.format_message()))]"))

	if (ringer_status)
		computer.send_sound()

	last_text = world.time
	if (everyone)
		message_data["name"] = "Everyone"
		message_data["job"] = ""

	messages += list(message_data)
	saved_image = null
	photo_path = null
	return TRUE

/datum/computer_file/program/messenger/proc/receive_message(datum/signal/subspace/messaging/tablet_msg/signal)
	var/list/message_data = list()
	message_data["name"] = signal.data["name"]
	message_data["job"] = signal.data["job"]
	message_data["contents"] = signal.data["message"]
	message_data["outgoing"] = FALSE
	message_data["sender"] = signal.data["ref"]
	message_data["automated"] = signal.data["automated"]
	message_data["photo_path"] = signal.data["photo_path"]
	message_data["photo"] = signal.data["photo"]
	message_data["everyone"] = signal.data["everyone"]
	messages += list(message_data)

	var/mob/living/L = null
	if(computer.loc && isliving(computer.loc))
		L = computer.loc
	//Maybe they are a pAI!
	else
		L = get(computer, /mob/living/silicon)

	if(L && (L.stat == CONSCIOUS || L.stat == SOFT_CRIT))
		var/reply = "(<a href='byond://?src=[REF(src)];choice=[signal.data["rigged"] ? "mess_us_up" : "Message"];skiprefresh=1;target=[signal.data["ref"]]'>Reply</a>)"
		var/hrefstart
		var/hrefend
		if (isAI(L))
			hrefstart = "<a href='?src=[REF(L)];track=[html_encode(signal.data["name"])]'>"
			hrefend = "</a>"

		if(signal.data["automated"])
			reply = "\[Automated Message\]"

		var/inbound_message = signal.format_message()
		inbound_message = emoji_parse(inbound_message)

		if(L.is_literate())
			var/photo_message = message_data["photo"] ? " (<a href='byond://?src=[REF(signal.logged)];photo=1'>Photo</a>)" : ""
			to_chat(L, span_infoplain("[icon2html(computer)] <b>PDA message from [hrefstart][STRINGIFY_PDA_TARGET(signal.data["name"], signal.data["job"])][hrefend], </b>[sanitize(html_decode(inbound_message))][photo_message] [reply]"))

	if (ringer_status)
		computer.ring(ringtone)

	SStgui.update_uis(computer)

/// topic call that answers to people pressing "(Reply)" in chat
/datum/computer_file/program/messenger/Topic(href, href_list)
	..()
	if(QDELETED(src))
		return
	// send an activation message, open the messenger, kill whoever reads this nesting mess
	if(!computer.enabled)
		if(!computer.turn_on(usr, open_ui = FALSE))
			return
	if(computer.active_program != src)
		if(!computer.open_program(usr, src, open_ui = FALSE))
			return
	if(!href_list["close"] && usr.can_perform_action(computer, FORBID_TELEKINESIS_REACH))
		switch(href_list["choice"])
			if("Message")
				quick_reply_prompt(usr, locate(href_list["target"]))
			if("mess_us_up")
				if(!HAS_TRAIT(src, TRAIT_PDA_CAN_EXPLODE))
					var/obj/item/modular_computer/pda/comp = computer
					comp.explode(usr, from_message_menu = TRUE)
					return
