/datum/computer_file/program/messenger
	filename = "nt_messenger"
	filedesc = "Direct Messenger"
	category = PROGRAM_CATEGORY_MISC
	program_icon_state = "command"
	program_state = PROGRAM_STATE_BACKGROUND
	extended_desc = "This program allows old-school communication with other modular devices."
	size = 0
	undeletable = TRUE // It comes by default in tablets, can't be downloaded, takes no space and should obviously not be able to be deleted.
	available_on_ntnet = FALSE
	usage_flags = PROGRAM_TABLET
	ui_header = "ntnrc_idle.gif"
	tgui_id = "NtosMessenger"
	program_icon = "comment-alt"
	alert_able = TRUE

	/// The current ringtone (displayed in the chat when a message is received).
	var/ringtone = "beep"
	/// Whether or not the ringtone is currently on.
	var/ringer_status = TRUE
	/// Whether or not we're sending and receiving messages.
	var/sending_and_receiving = TRUE
	/// The messages currently saved in the app.
	var/messages = list()
	/// great wisdom from PDA.dm - "no spamming" (prevents people from spamming the same message over and over)
	var/last_text
	/// even more wisdom from PDA.dm - "no everyone spamming" (prevents people from spamming the same message over and over)
	var/last_text_everyone
	/// Scanned photo for sending purposes.
	var/datum/picture/picture
	/// Whether or not we allow emojis to be sent by the user.
	var/allow_emojis = FALSE
	/// Whether or not we're currently looking at the message list.
	var/viewing_messages = FALSE
	// Whether or not this device is currently hidden from the message monitor.
	var/monitor_hidden = FALSE
	// Whether or not we're sorting by job.
	var/sort_by_job = TRUE
	// Whether or not we're sending (or trying to send) a virus.
	var/sending_virus = FALSE

	/// The path for the current loaded image in rsc
	var/photo_path

	/// Whether or not this app is loaded on a silicon's tablet.
	var/is_silicon = FALSE
	/// Whether or not we're in a mime PDA.
	var/mime_mode = FALSE
	/// Whether this app can send messages to all.
	var/spam_mode = FALSE

/datum/computer_file/program/messenger/proc/ScrubMessengerList()
	var/list/dictionary = list()

	for(var/obj/item/modular_computer/messenger in GetViewableDevices(sort_by_job))
		if(messenger.saved_identification && messenger.saved_job && !(messenger == computer))
			var/list/data = list()
			data["name"] = messenger.saved_identification
			data["job"] = messenger.saved_job
			data["ref"] = REF(messenger)

			//if(data["ref"] != REF(computer)) // you cannot message yourself (despite all my rage)
			dictionary += list(data)

	return dictionary

/proc/GetViewableDevices(sort_by_job = FALSE)
	var/list/dictionary = list()

	var/sortmode
	if(sort_by_job)
		sortmode = /proc/cmp_pdajob_asc
	else
		sortmode = /proc/cmp_pdaname_asc

	for(var/obj/item/modular_computer/P in sort_list(GLOB.TabletMessengers, sortmode))
		var/obj/item/computer_hardware/hard_drive/drive = P.all_components[MC_HDD]
		if(!drive)
			continue
		for(var/datum/computer_file/program/messenger/app in drive.stored_files)
			if(!P.saved_identification || !P.saved_job || P.invisible || app.monitor_hidden)
				continue
			dictionary += P

	return dictionary

/datum/computer_file/program/messenger/proc/StringifyMessengerTarget(obj/item/modular_computer/messenger)
	return "[messenger.saved_identification] ([messenger.saved_job])"

/datum/computer_file/program/messenger/proc/ProcessPhoto()
	if(computer.saved_image)
		var/icon/img = computer.saved_image.picture_image
		var/deter_path = "tmp_msg_photo[rand(0, 99999)].png"
		usr << browse_rsc(img, deter_path) // funny random assignment for now, i'll make an actual key later
		photo_path = deter_path

/datum/computer_file/program/messenger/ui_state(mob/user)
	if(istype(user, /mob/living/silicon))
		return GLOB.reverse_contained_state
	return GLOB.default_state

/datum/computer_file/program/messenger/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	switch(action)
		if("PDA_ringSet")
			var/t = tgui_input_text(usr, "Enter a new ringtone", "Ringtone", "", 20)
			var/mob/living/usr_mob = usr
			if(in_range(computer, usr_mob) && computer.loc == usr_mob && t)
				if(SEND_SIGNAL(computer, COMSIG_TABLET_CHANGE_ID, usr_mob, t) & COMPONENT_STOP_RINGTONE_CHANGE)
					return
				else
					ringtone = t
					return(UI_UPDATE)
		if("PDA_ringer_status")
			ringer_status = !ringer_status
			return(UI_UPDATE)
		if("PDA_sAndR")
			sending_and_receiving = !sending_and_receiving
			return(UI_UPDATE)
		if("PDA_viewMessages")
			viewing_messages = !viewing_messages
			return(UI_UPDATE)
		if("PDA_clearMessages")
			messages = list()
			return(UI_UPDATE)
		if("PDA_changeSortStyle")
			sort_by_job = !sort_by_job
			return(UI_UPDATE)
		if("PDA_sendEveryone")
			if(!sending_and_receiving)
				to_chat(usr, span_notice("ERROR: Device has sending disabled."))
				return
			if(!spam_mode)
				to_chat(usr, span_notice("ERROR: Device does not have mass-messaging perms."))
				return

			var/list/targets = list()

			for(var/obj/item/modular_computer/mc in GetViewableDevices())
				targets += mc

			if(targets.len > 0)
				send_message(usr, targets, TRUE)

			return(UI_UPDATE)
		if("PDA_sendMessage")
			if(!sending_and_receiving)
				to_chat(usr, span_notice("ERROR: Device has sending disabled."))
				return
			var/obj/item/modular_computer/target = locate(params["ref"])
			if(!target)
				return // we don't want tommy sending his messages to nullspace
			if(!(target.saved_identification == params["name"] && target.saved_job == params["job"]))
				to_chat(usr, span_notice("ERROR: User no longer exists."))
				return

			var/obj/item/computer_hardware/hard_drive/drive = target.all_components[MC_HDD]

			for(var/datum/computer_file/program/messenger/app in drive.stored_files)
				if(!app.sending_and_receiving && !sending_virus)
					to_chat(usr, span_notice("ERROR: Device has receiving disabled."))
					return
				if(sending_virus)
					var/obj/item/computer_hardware/hard_drive/portable/virus/disk = computer.all_components[MC_SDD]
					if(istype(disk))
						disk.send_virus(target, usr)
						return(UI_UPDATE)
				send_message(usr, list(target))
				return(UI_UPDATE)
		if("PDA_clearPhoto")
			computer.saved_image = null
			photo_path = null
			return(UI_UPDATE)
		if("PDA_toggleVirus")
			sending_virus = !sending_virus
			return(UI_UPDATE)


/datum/computer_file/program/messenger/ui_data(mob/user)
	var/list/data = get_header_data()

	data["owner"] = computer.saved_identification
	data["messages"] = messages
	data["ringer_status"] = ringer_status
	data["sending_and_receiving"] = sending_and_receiving
	data["messengers"] = ScrubMessengerList()
	data["viewing_messages"] = viewing_messages
	data["sortByJob"] = sort_by_job
	data["isSilicon"] = is_silicon
	data["photo"] = photo_path
	data["canSpam"] = spam_mode

	var/obj/item/computer_hardware/hard_drive/portable/virus/disk = computer.all_components[MC_SDD]
	if(disk)
		data["virus_attach"] = istype(disk, /obj/item/computer_hardware/hard_drive/portable/virus)
		data["sending_virus"] = sending_virus

	return data

////////////////////////
// MESSAGE HANDLING
////////////////////////

// How I Learned To Stop Being A PDA Bloat Chump And Learn To Embrace The Lightweight

// Gets the input for a message being sent.

/datum/computer_file/program/messenger/proc/msg_input(mob/living/U = usr, rigged = FALSE)
	var/t = null

	if(mime_mode)
		t = emoji_sanitize(tgui_input_text(U, "Enter emojis", "NT Messaging"))
	else
		t = tgui_input_text(U, "Enter a message", "NT Messaging")

	if (!t || !sending_and_receiving)
		return
	if(!U.canUseTopic(computer, BE_CLOSE))
		return
	return sanitize(t)

/datum/computer_file/program/messenger/proc/send_message(mob/living/user, list/obj/item/modular_computer/targets, everyone = FALSE, rigged = FALSE, fake_name = null, fake_job = null)
	var/message = msg_input(user, rigged)
	if(!message || !targets.len)
		return FALSE
	if((last_text && world.time < last_text + 10) || (everyone && last_text_everyone && world.time < last_text_everyone + 2 MINUTES))
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
		message_admins("[ADMIN_LOOKUPFLW(usr)] has passed the soft filter for \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\" they may be using a disallowed term in PDA messages. Message: \"[html_encode(message)]\"")
		log_admin_private("[key_name(usr)] has passed the soft filter for \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\" they may be using a disallowed term in PDA messages. Message: \"[message]\"")

	// Send the signal
	var/list/string_targets = list()
	for (var/obj/item/modular_computer/comp in targets)
		if (comp.saved_identification && comp.saved_job)  // != src is checked by the UI
			string_targets += STRINGIFY_PDA_TARGET(comp.saved_identification, comp.saved_job)

	if (!string_targets.len)
		return FALSE

	var/datum/signal/subspace/messaging/tablet_msg/signal = new(computer, list(
		"name" = fake_name || computer.saved_identification,
		"job" = fake_job || computer.saved_job,
		"message" = html_decode(message),
		"ref" = REF(computer),
		"targets" = targets,
		"emojis" = allow_emojis,
		"rigged" = rigged,
		"photo" = photo_path,
		"automated" = FALSE,
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

	if(allow_emojis)
		message = emoji_parse(message)//already sent- this just shows the sent emoji as one to the sender in the to_chat
		signal.data["message"] = emoji_parse(signal.data["message"])

	// Log it in our logs
	var/list/message_data = list()
	message_data["name"] = signal.data["name"]
	message_data["job"] = signal.data["job"]
	message_data["contents"] = html_decode(signal.format_message())
	message_data["outgoing"] = TRUE
	message_data["ref"] = signal.data["ref"]
	message_data["photo"] = signal.data["photo"]

	// Show it to ghosts
	var/ghost_message = span_name("[message_data["name"]] </span><span class='game say'>[rigged ? "Rigged" : ""] PDA Message</span> --> [span_name("[signal.format_target()]")]: <span class='message'>[signal.format_message()]")
	for(var/mob/M in GLOB.player_list)
		if(isobserver(M) && (M.client?.prefs.chat_toggles & CHAT_GHOSTPDA))
			to_chat(M, "[FOLLOW_LINK(M, user)] [ghost_message]")

	// Log in the talk log
	user.log_talk(message, LOG_PDA, tag="[rigged ? "Rigged" : ""] PDA: [message_data["name"]] to [signal.format_target()]")
	if(rigged)
		log_bomber(user, "sent a rigged PDA message (Name: [message_data["name"]]. Job: [message_data["job"]]) to [english_list(string_targets)] [!is_special_character(user) ? "(SENT BY NON-ANTAG)" : ""]")
	to_chat(user, span_info("PDA message sent to [signal.format_target()]: [signal.format_message()]"))

	if (ringer_status)
		computer.send_sound()

	last_text = world.time
	if (everyone)
		message_data["name"] = "Everyone"
		message_data["job"] = ""
		last_text_everyone = world.time

	messages += list(message_data)
	return TRUE

/datum/computer_file/program/messenger/proc/receive_message(datum/signal/subspace/messaging/tablet_msg/signal)
	var/list/message_data = list()
	message_data["name"] = signal.data["name"]
	message_data["job"] = signal.data["job"]
	message_data["contents"] = signal.format_message()
	message_data["outgoing"] = FALSE
	message_data["ref"] = signal.data["ref"]
	message_data["automated"] = signal.data["automated"]
	message_data["photo"] = signal.data["photo"]
	messages += list(message_data)

	var/mob/living/L = null
	if(holder.holder.loc && isliving(holder.holder.loc))
		L = holder.holder.loc
	//Maybe they are a pAI!
	else
		L = get(holder.holder, /mob/living/silicon)

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
		if(signal.data["emojis"] == TRUE)//so will not parse emojis as such from pdas that don't send emojis
			inbound_message = emoji_parse(inbound_message)

		if(ringer_status && L.is_literate())
			to_chat(L, "<span class='infoplain'>[icon2html(src)] <b>PDA message from [hrefstart][signal.data["name"]] ([signal.data["job"]])[hrefend], </b>[inbound_message] [reply]</span>")


	if (ringer_status)
		computer.ring(ringtone)

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
		if(!computer.open_program(usr, src))
			return
	if(!href_list["close"] && usr.canUseTopic(computer, BE_CLOSE, FALSE, NO_TK))
		switch(href_list["choice"])
			if("Message")
				send_message(usr, list(locate(href_list["target"])))
			if("mess_us_up")
				if(!HAS_TRAIT(src, TRAIT_PDA_CAN_EXPLODE))
					var/obj/item/modular_computer/tablet/comp = computer
					comp.explode(usr, from_message_menu = TRUE)
					return
