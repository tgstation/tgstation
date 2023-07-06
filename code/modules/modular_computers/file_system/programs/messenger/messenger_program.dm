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

	/// Whether the user is invisible to the message list.
	var/invisible = FALSE
	// Whether or not this device is currently hidden from the message monitor.
	var/monitor_hidden = FALSE
	/// great wisdom from PDA.dm - "no spamming" (prevents people from spamming the same message over and over)
	var/last_text
	/// even more wisdom from PDA.dm - "no everyone spamming" (prevents people from spamming the same message over and over)
	var/last_text_everyone
	/// Whether or not we're in a mime PDA.
	var/mime_mode = FALSE
	/// Whether this app can send messages to all.
	var/spam_mode = FALSE

	/// An asssociative list of chats we have started, format: chatref -> pda_chat.
	var/list/datum/pda_chat/saved_chats = list()
	/// Associative list of unread messages, format: chatref -> number of unreads
	var/list/unread_chats = list()
	/// Whose chatlogs we currently have open. If we are in the contacts list, this is null.
	var/viewing_messages_of = null

	/// The current ringtone (displayed in the chat when a message is received).
	var/ringtone = MESSENGER_RINGTONE_DEFAULT
	// Whether or not we're sorting by job.
	var/sort_by_job = TRUE
	/// Whether or not we're sending and receiving messages.
	var/sending_and_receiving = TRUE
	/// Scanned photo for sending purposes.
	var/datum/picture/saved_image
	/// The path for the current loaded image in rsc
	var/photo_path
	// Whether or not we're sending (or trying to send) a virus.
	var/sending_virus = FALSE

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

		if("PDA_toggleAlerts")
			alert_silenced = !alert_silenced
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
				saved_chats.Remove(user_ref)
			else
				saved_chats = list()
			viewing_messages_of = null
			return TRUE

		if("PDA_changeSortStyle")
			sort_by_job = !sort_by_job
			return TRUE

		if("PDA_sendEveryone")
			if(!sending_and_receiving)
				to_chat(usr, span_notice("ERROR: This device has sending disabled."))
				return FALSE

			if(!spam_mode)
				to_chat(usr, span_notice("ERROR: Device does not have mass-messaging perms."))
				return FALSE

			if(can_send_everyone_message())
				return FALSE

			return send_message_to_all(usr, params["msg"])

		if("PDA_sendMessage")
			if(!sending_and_receiving)
				to_chat(usr, span_notice("ERROR: This device has sending disabled."))
				return FALSE

			if(!(params["ref"] in saved_chats))
				return FALSE

			var/datum/pda_chat/target = saved_chats[params["ref"]]

			if(!(target.recipient.reference in GLOB.TabletMessengers))
				to_chat(usr, span_notice("ERROR: Recipient no longer exists."))
				return FALSE

			var/datum/computer_file/program/messenger/target_msgr = target.recipient.resolve()

			if(isnull(target_msgr)) // we don't want tommy sending his message to nullspace
				return FALSE

			if(!target_msgr.sending_and_receiving && !sending_virus)
				to_chat(usr, span_notice("ERROR: Recipient has receiving disabled."))
				return FALSE

			if(sending_virus)
				var/obj/item/computer_disk/virus/disk = computer.inserted_disk
				if(istype(disk))
					disk.send_virus(computer, target, usr)
					return TRUE

			return send_message(usr, list(target), params["msg"])

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

	data["owner"] = ((REF(src) in GLOB.TabletMessengers) ? list(
			"name" = computer.saved_identification,
			"job" = computer.saved_job,
			"ref" = REF(src)
		) : null)
	data["can_spam"] = spam_mode
	data["is_silicon"] = issilicon(user)

	return data

/datum/computer_file/program/messenger/ui_data(mob/user)
	var/list/data = list()

	var/list/messengers = get_messengers()

	data["saved_chats"] = saved_chats
	data["unreads"] = unread_chats
	data["messengers"] = messengers
	data["sort_by_job"] = sort_by_job
	data["alert_silenced"] = alert_silenced
	data["sending_and_receiving"] = sending_and_receiving
	data["open_chat"] = saved_chats[viewing_messages_of]
	data["photo"] = photo_path
	data["on_spam_cooldown"] = can_send_everyone_message()

	var/obj/item/computer_disk/virus/disk = computer.inserted_disk
	if(disk && istype(disk))
		data["virus_attach"] = TRUE
		data["sending_virus"] = sending_virus
	return data

//////////////////////
// MESSAGE HANDLING //
//////////////////////

/// Brings up the quick reply prompt to send a message.
/datum/computer_file/program/messenger/proc/quick_reply_prompt(mob/living/user, datum/pda_chat/chat)
	var/datum/computer_file/program/messenger/target = chat.recipient.resolve()
	if(isnull(target) || isnull(target.computer))
		return
	var/target_name = target.computer.saved_identification
	var/input_message = tgui_input_text(user, "Enter [mime_mode ? "emojis":"a message"]", "NT Messaging[target_name ? " ([target_name])" : ""]", encode = FALSE)
	send_message(user, list(target), input_message)

/// Helper proc that sends a message to everyone
/datum/computer_file/program/messenger/proc/send_message_to_all(mob/living/user, message)
	var/list/datum/pda_chat/chats = list()
	var/list/msgr_targets = list()

	for(var/mc in get_messengers())
		msgr_targets += mc

	for(var/chatref in saved_chats)
		var/datum/pda_chat/chat = saved_chats[chatref]
		if(chat.recipient.reference in msgr_targets) // if its in msgr_targets, it's valid
			msgr_targets -= chat.recipient.reference
			chats += chat

	for(var/missing_msgr in msgr_targets)
		var/datum/pda_chat/new_chat = create_chat(GLOB.TabletMessengers[missing_msgr])
		chats += new_chat

	send_message(user, chats, message, everyone = TRUE)
	last_text_everyone = world.time

/datum/computer_file/program/messenger/proc/create_chat(datum/computer_file/program/messenger/recipient, name)
	if(!(REF(recipient) in GLOB.TabletMessengers))
		CRASH("tried to create a chat with a messenger that isn't registered")

	var/datum/pda_chat/new_chat = new /datum/pda_chat(recipient)
	// this is a chat with a "fake user" (automated or rigged message)
	if(isnull(recipient) && istext(name))
		new_chat.cached_name = name
	saved_chats += new_chat

	return new_chat

/datum/computer_file/program/messenger/proc/find_chat_by_recp(recipient, fake_user = FALSE)
	for(var/datum/pda_chat/chat as anything in saved_chats)
		if(fake_user && chat.cached_name == recipient)
			return chat
		else if(chat.recipient.reference == recipient)
			return chat
	return null

// TODO: this proc is way too large and needs to be refactored
/// Sends a message to targets via PDA. When sending to everyone, set `everyone` to true so the message is formatted accordingly
/datum/computer_file/program/messenger/proc/send_message(mob/living/sender, list/datum/pda_chat/targets, message, everyone = FALSE, rigged = FALSE, fake_name = null, fake_job = null)
	if(!sender.can_perform_action(computer))
		return FALSE

	if(!istype(targets) && !length(targets))
		return FALSE

	if(mime_mode)
		message = emoji_sanitize(message)

	message = html_encode(message)

	// message at this point is not html escaped
	if(!message)
		return FALSE

	// check for jammers
	var/turf/position = get_turf(computer)
	for(var/obj/item/jammer/jammer as anything in GLOB.active_jammers)
		var/turf/jammer_turf = get_turf(jammer)
		if(position?.z == jammer_turf.z && (get_dist(position, jammer_turf) <= jammer.range))
			to_chat(sender, span_notice("ERROR: Server communication failed."))
			if(!alert_silenced)
				playsound(src, 'sound/machines/terminal_error.ogg', 15, TRUE)
			return FALSE

	// check message against filter
	if(!check_pda_msg_against_filter(message, sender))
		return FALSE

	var/sent_prob = 1
	if(ishuman(sender))
		var/mob/living/carbon/human/old_person = sender
		sent_prob = old_person.age >= 30 ? 25 : sent_prob
	if (prob(sent_prob))
		message += "\n Sent from my PDA"

	var/datum/pda_msg/message_datum = new(message, saved_image, photo_path, everyone)

	// our sender targets
	var/list/datum/computer_file/program/messenger/target_msgrs = list()
	// used for logging
	var/list/stringified_targets = list()

	// filter out invalid targets
	for(var/datum/pda_chat/target_chat in targets.Copy())
		var/datum/computer_file/program/messenger/msgr = target_chat.recipient.resolve()
		if(isnull(msgr))
			target_chat.owner_deleted = TRUE
			targets -= target_chat
			continue
		if(!msgr.sending_and_receiving)
			targets -= target_chat
			continue
		target_msgrs += msgr
		stringified_targets += get_messenger_name(msgr.computer)

	if(!length(target_msgrs))
		return

	var/datum/signal/subspace/messaging/tablet_msg/signal = new(computer, list(
		"ref" = REF(src),
		"message" = message_datum,
		"targets" = target_msgrs,
		"rigged" = rigged,
		"automated" = FALSE,
	))
	if(rigged) //Will skip the message server and go straight to the hub so it can't be cheesed by disabling the message server machine
		signal.data["fakename"] = fake_name
		signal.data["fakejob"] = fake_job
		signal.server_type = /obj/machinery/telecomms/hub
		signal.data["reject"] = FALSE // Do not refuse the message

	signal.send_to_receivers()

	// If it didn't reach, note that fact
	if (!signal.data["done"])
		to_chat(sender, span_notice("ERROR: Server is not responding."))
		if(!alert_silenced)
			playsound(src, 'sound/machines/terminal_error.ogg', 15, TRUE)
		return FALSE

	message = emoji_parse(message)//already sent- this just shows the sent emoji as one to the sender in the to_chat

	// Log it in our logs
	var/list/message_data = list()
	for(var/datum/pda_chat/target_chat as anything in targets)
		target_chat.add_msg(message_datum, show_in_recents = FALSE)

	// Show it to ghosts
	var/ghost_message = span_name("[message_data["name"]] </span><span class='game say'>[rigged ? "Rigged" : ""] PDA Message</span> --> [span_name("[signal.format_target()]")]: <span class='message'>[signal.format_message()]")
	for(var/mob/player_mob as anything in GLOB.current_observers_list)
		if(player_mob.client && !player_mob.client?.prefs)
			stack_trace("[player_mob] ([player_mob.ckey]) had null prefs, which shouldn't be possible!")
			continue

		if(isobserver(player_mob) && (player_mob.client?.prefs.chat_toggles & CHAT_GHOSTPDA))
			to_chat(player_mob, "[FOLLOW_LINK(player_mob, sender)] [ghost_message]")

	// Log in the talk log
	sender.log_talk(message, LOG_PDA, tag="[rigged ? "Rigged" : ""] PDA: [message_data["name"]] to [signal.format_target()]")
	if(rigged)
		log_bomber(sender, "sent a rigged PDA message (Name: [message_data["name"]]. Job: [message_data["job"]]) to [english_list(stringified_targets)] [!is_special_character(sender) ? "(SENT BY NON-ANTAG)" : ""]")
	to_chat(sender, span_info("PDA message sent to [signal.format_target()]: [sanitize(html_decode(signal.format_message()))]"))

	if (!alert_silenced)
		computer.send_sound()

	last_text = world.time

	saved_image = null
	photo_path = null
	return TRUE

/datum/computer_file/program/messenger/proc/receive_message(datum/signal/subspace/messaging/tablet_msg/signal)
	var/datum/pda_msg/message = signal.data["message"]
	var/datum/pda_chat/chat = null

	var/is_rigged = signal.data["rigged"]
	var/is_automated = signal.data["automated"]
	var/is_fake_user = is_rigged || is_automated
	var/fake_identity = is_fake_user ? STRINGIFY_PDA_TARGET(signal.data["fakename"], signal.data["fakejob"]) : null

	if(!is_rigged)
		message = message.copy()
		chat = find_chat_by_recp(is_automated ? fake_identity : signal.data["ref"], is_automated)
		if(isnull(chat))
			chat = create_chat(is_automated ? null : signal.data["ref"], fake_identity)
		chat.add_msg(message)

	var/mob/living/L = null
	//Check our immediate loc
	if(isliving(computer.loc))
		L = computer.loc
	//Maybe they are a silicon!
	else
		L = get(computer, /mob/living/silicon)

	var/should_ring = !alert_silenced || is_rigged

	if(istype(L) && should_ring && (L.stat == CONSCIOUS || L.stat == SOFT_CRIT))
		var/reply = "(<a href='byond://?src=[REF(src)];choice=[signal.data["rigged"] ? "mess_us_up" : "Message"];skiprefresh=1;target=[REF(chat)]'>Reply</a>)"
		// resolving w/o nullcheck here, assume the messenger exists if they sent a message
		var/sender_name = is_fake_user ? signal.data["fakename"] : get_messenger_name(chat.recipient.resolve())
		var/hrefstart
		var/hrefend
		if (isAI(L))
			hrefstart = "<a href='?src=[REF(L)];track=[html_encode(sender_name)]'>"
			hrefend = "</a>"

		if(signal.data["automated"])
			reply = "\[Automated Message\]"

		var/inbound_message = signal.format_message()
		inbound_message = emoji_parse(inbound_message)

		if(L.is_literate())
			var/photo_message = message.photo ? " (<a href='byond://?src=[REF(signal.logged)];photo=1'>Photo</a>)" : ""
			to_chat(L, span_infoplain("[icon2html(computer)] <b>PDA message from [hrefstart][sender_name][hrefend], </b>[sanitize(html_decode(inbound_message))][photo_message] [reply]"))

	if (should_ring)
		computer.ring(ringtone)

	SStgui.update_uis(computer)

/// topic call that answers to people pressing "(Reply)" in chat
/datum/computer_file/program/messenger/Topic(href, href_list)
	..()
	if(QDELETED(src))
		return
	// send an activation message and open the messenger
	if(!((computer.enabled || computer.turn_on(usr, open_ui = FALSE)) && (computer.active_program == src || computer.open_program(usr, src, open_ui = FALSE))))
		return
	if(!href_list["close"] && usr.can_perform_action(computer, FORBID_TELEKINESIS_REACH))
		switch(href_list["choice"])
			if("Message")
				quick_reply_prompt(usr, locate(href_list["target"]) in saved_chats)
			if("mess_us_up")
				if(!HAS_TRAIT(src, TRAIT_PDA_CAN_EXPLODE))
					var/obj/item/modular_computer/pda/comp = computer
					comp.explode(usr, from_message_menu = TRUE)
					return
