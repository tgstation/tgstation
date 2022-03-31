/datum/computer_file/program/messenger
	filename = "nt_messenger"
	filedesc = "Direct Messenger"
	category = PROGRAM_CATEGORY_MISC
	program_icon_state = "command"
	extended_desc = "This program allows old-school communication with other modular devices."
	size = 8
	requires_ntnet = TRUE
	requires_ntnet_feature = NTNET_COMMUNICATION
	ui_header = "ntnrc_idle.gif"
	available_on_ntnet = TRUE
	tgui_id = "NtosMessenger"
	program_icon = "comment-alt"
	alert_able = TRUE

	var/tTone = "beep" // the current ringtone
	var/ringerStatus = TRUE // whether or not the ringtone is currently on
	var/sAndR = TRUE // whether or not we're sending and receiving messages
	var/messages = list() // the messages currently saved
	var/last_text // great wisdom from PDA.dm - "no spamming"
	var/last_text_everyone // even more wisdom from PDA.dm - "no everyone spamming"
	var/datum/picture/picture // scanned photo
	var/allow_emojis = FALSE // whether or not we allow emojis
	var/viewingMessages = FALSE // whether or not we're looking at messages atm
	var/monitor_hidden = FALSE // whether or not this device is currently hidden from the message monitor
	var/sort = TRUE // whether or not we're sorting by job

	var/is_silicon = FALSE // basically easy mode (no ID needed, cant disable message receiving (fuck you), etc.)

/datum/computer_file/program/messenger/proc/ScrubMessengerList()
	var/list/dictionary = list()

	for(var/obj/item/modular_computer/messenger in GetViewableDevices(sort))
		if(messenger.saved_identification && messenger.saved_job)
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

	for(var/obj/item/modular_computer/P in sort_list(GLOB.MMessengers, sortmode))
		var/obj/item/computer_hardware/hard_drive/drive = P.all_components[MC_HDD]
		if(!drive)
			continue
		for(var/datum/computer_file/program/messenger/app in drive.stored_files)
			if(!P.saved_identification || !P.saved_job || !app.sAndR || app.monitor_hidden)
				continue
			dictionary += P

	return dictionary

/datum/computer_file/program/messenger/proc/StringifyMessengerTarget(obj/item/modular_computer/messenger)
	return "[messenger.saved_identification] ([messenger.saved_job])"

/datum/computer_file/program/messenger/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	switch(action)
		if("PDA_ringSet")
			var/t = tgui_input_text(usr, "Enter a new ringtone", "Computer Ringtone", tTone, 20)
			var/mob/living/usr_mob = usr
			if(in_range(computer, usr_mob) && computer.loc == usr_mob && t)
				if(SEND_SIGNAL(computer, COMSIG_PDA_CHANGE_RINGTONE, usr_mob, t) & COMPONENT_STOP_RINGTONE_CHANGE)
					return
				else
					tTone = t
		if("PDA_ringerStatus")
			ringerStatus = !ringerStatus
			return(UI_UPDATE)
		if("PDA_sAndR")
			sAndR = !sAndR
			return(UI_UPDATE)
		if("PDA_viewMessages")
			viewingMessages = !viewingMessages
			return(UI_UPDATE)
		if("PDA_clearMessages")
			messages = list()
			return(UI_UPDATE)
		if("PDA_changeSortStyle")
			sort = !sort
			return(UI_UPDATE)
		if("PDA_sendEveryone")
			if(!sAndR)
				to_chat(usr, span_notice("ERROR: Device has sending disabled."))
				return

			var/list/targets = list()

			for(var/obj/item/modular_computer/mc in GetViewableDevices())
				targets += mc

			if(targets.len > 0)
				send_message(usr, targets, TRUE)

			return(UI_UPDATE)
		if("PDA_sendMessage")
			if(!sAndR)
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
				if(!app.sAndR)
					to_chat(usr, span_notice("ERROR: Device has receiving disabled."))
					return
				send_message(usr, list(target))
				return(UI_UPDATE)

/datum/computer_file/program/messenger/ui_data(mob/user)
	var/list/data = get_header_data()

	data["owner"] = computer.saved_identification
	data["messages"] = messages
	data["ringerStatus"] = ringerStatus
	data["sAndR"] = sAndR
	data["messengers"] = ScrubMessengerList()
	data["viewingMessages"] = viewingMessages
	data["sortByJob"] = sort

	var/obj/item/computer_hardware/cartridge_slot = computer.all_components[MC_CART]

	if(cartridge_slot)
		data["canSpam"] = cartridge_slot.CanSpam()

	return data

////////////////////////
// MESSAGE HANDLING
////////////////////////

// How I Learned To Stop Being A PDA Bloat Chump And Learn To Embrace The Lightweight

// Gets the input for a message being sent.

/datum/computer_file/program/messenger/proc/msg_input(mob/living/U = usr, rigged = FALSE)
	var/t = tgui_input_text(U, "Enter a message", "NT Messaging")
	if (!t || !sAndR)
		return
	if(computer.loc != U)
		return
	return t

/datum/computer_file/program/messenger/proc/send_message(mob/living/user, list/obj/item/modular_computer/targets, everyone = FALSE, rigged = FALSE)
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

	for (var/obj/machinery/computer/message_monitor/M in targets)
		// In case of "Reply" to a message from a console, this will make the
		// message be logged successfully. If the console is impersonating
		// someone by matching their name and job, the reply will reach the
		// impersonated PDA.
		string_targets += STRINGIFY_PDA_TARGET(M.customsender, M.customjob)
	if (!string_targets.len)
		return FALSE

	var/datum/signal/subspace/messaging/modular/signal = new(computer, list(
		"name" = computer.saved_identification,
		"job" = computer.saved_job,
		"message" = message,
		"ref" = REF(computer),
		"targets" = targets,
		"emojis" = allow_emojis,
		"rigged" = rigged,
		"photo" = null,
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
		//if(!silent)
			//playsound(src, 'sound/machines/terminal_error.ogg', 15, TRUE)
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

	if (!ringerStatus)
		computer.send_sound()

	last_text = world.time
	if (everyone)
		message_data["name"] = "Everyone"
		message_data["job"] = ""
		last_text_everyone = world.time

	messages += list(message_data)
	return TRUE

/datum/computer_file/program/messenger/proc/receive_message(datum/signal/subspace/messaging/modular/signal)
	var/list/message_data = list()
	message_data["name"] = signal.data["name"]
	message_data["job"] = signal.data["job"]
	message_data["contents"] = html_decode(signal.format_message())
	message_data["outgoing"] = FALSE
	message_data["ref"] = signal.data["ref"]
	message_data["automated"] = signal.data["automated"]
	messages += list(message_data)

	var/mob/living/L = null
	if(computer.loc && isliving(computer.loc))
		L = computer.loc
	//Maybe they are a pAI!
	else
		L = get(computer, /mob/living/silicon)

	if(L && (L.stat == CONSCIOUS || L.stat == SOFT_CRIT))
		var/reply = "(<a href='byond://?src=[REF(src)];choice=[signal.data["rigged"] ? "Mess_us_up" : "Message"];skiprefresh=1;target=[signal.data["ref"]]'>Reply</a>)"
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

		to_chat(L, "<span class='infoplain'>[icon2html(src)] <b>PDA message from [hrefstart][signal.data["name"]] ([signal.data["job"]])[hrefend], </b>[inbound_message] [reply]</span>")


	if (ringerStatus)
		computer.ring(tTone)

/datum/computer_file/program/messenger/Topic(href, href_list)
	..()

	if(!href_list["close"] && usr.canUseTopic(computer, BE_CLOSE, FALSE, NO_TK))
		var/choice = text2num(href_list["choice"]) || href_list["choice"]
		switch(choice)
			if("Message")
				send_message(usr, list(locate(href_list["target"])))
