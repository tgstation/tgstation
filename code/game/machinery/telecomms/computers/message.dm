/*
	The monitoring computer for the messaging server.
	Lets you read PDA and request console messages.
*/

#define LINKED_SERVER_NONRESPONSIVE  (!linkedServer || (linkedServer.machine_stat & (NOPOWER|BROKEN)))

#define MSG_MON_SCREEN_MAIN 0
#define MSG_MON_SCREEN_LOGS 1
#define MSG_MON_SCREEN_REQUEST_LOGS 2
#define MSG_MON_SCREEN_HACKED 3

/obj/machinery/computer/message_monitor
	name = "message monitor console"
	desc = "Used to monitor the crew's PDA messages, as well as request console messages."
	icon_screen = "comm_logs"
	circuit = /obj/item/circuitboard/computer/message_monitor
	light_color = LIGHT_COLOR_GREEN
	/// Server linked to.
	var/obj/machinery/telecomms/message_server/linkedServer = null
	/// Sparks effect - For emag
	var/datum/effect_system/spark_spread/spark_system
	/// Computer properties
	var/screen = MSG_MON_SCREEN_MAIN // 0 = Main menu, 1 = Message Logs, 2 = Hacked screen, 3 = Custom Message
	var/message = "System bootup complete. Please select an option." // The message that shows on the main menu.
	var/auth = FALSE // Are they authenticated?
	/// Error, Success & Notice messages
	var/error_message = ""
	var/notice_message = ""
	var/succes_message = ""
	/// Decrypt password
	var/password = ""

/obj/machinery/computer/message_monitor/screwdriver_act(mob/living/user, obj/item/I)
	if(obj_flags & EMAGGED)
		//Stops people from just unscrewing the monitor and putting it back to get the console working again.
		to_chat(user, span_warning("It is too hot to mess with!"))
		return TRUE
	return ..()

/obj/machinery/computer/message_monitor/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	if(!isnull(linkedServer))
		obj_flags |= EMAGGED
		screen = MSG_MON_SCREEN_HACKED
		spark_system.set_up(5, 0, src)
		spark_system.start()
		var/obj/item/paper/monitorkey/monitor_key_paper = new(loc, linkedServer)
		// Will help make emagging the console not so easy to get away with.
		monitor_key_paper.add_raw_text("<br><br><font color='red'>£%@%(*$%&(£&?*(%&£/{}</font>")
		var/time = 100 * length(linkedServer.decryptkey)
		addtimer(CALLBACK(src, PROC_REF(unemag_console)), time)
		error_message = "%$&(£: Critical %$$@ Error // !RestArting! <lOadiNg backUp iNput ouTput> - ?pLeaSe wAit!"
		linkedServer.toggled = FALSE
	else
		to_chat(user, span_notice("A no server error appears on the screen."))

/// Removing the emag effect from the console
/obj/machinery/computer/message_monitor/proc/unemag_console()
	screen = MSG_MON_SCREEN_MAIN
	linkedServer.toggled = TRUE
	error_message = ""
	obj_flags &= ~EMAGGED

/obj/machinery/computer/message_monitor/Initialize(mapload)
	..()
	spark_system = new
	GLOB.telecomms_list += src
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/computer/message_monitor/LateInitialize()
	//Is the server isn't linked to a server, and there's a server available, default it to the first one in the list.
	if(!linkedServer)
		for(var/obj/machinery/telecomms/message_server/S in GLOB.telecomms_list)
			linkedServer = S
			break

/obj/machinery/computer/message_monitor/Destroy()
	GLOB.telecomms_list -= src
	linkedServer = null
	return ..()

/obj/machinery/computer/message_monitor/ui_data(mob/user)
	var/list/data = list(
		"screen" = screen,
		"error" = error_message,
		"notice" = notice_message,
		"succes" = succes_message,
		"auth" = auth,
		"server_status" = !LINKED_SERVER_NONRESPONSIVE
	)

	switch(screen)
		if(MSG_MON_SCREEN_MAIN)
			data["password"] = password
			data["status"] = linkedServer.on
			// Check is AI or cyboeg malf
			var/mob/living/silicon/S = user
			if(istype(S) && S.hack_software)
				data["is_malf"] = TRUE
			else
				data["is_malf"] = FALSE

		if(MSG_MON_SCREEN_LOGS)
			var/list/message_list = list()
			for(var/datum/data_tablet_msg/pda in linkedServer.pda_msgs)
				message_list += list(list("ref" = REF(pda), "sender" = pda.sender, "recipient" = pda.recipient, "message" = pda.message))
			data["messages"] = message_list
		if(MSG_MON_SCREEN_REQUEST_LOGS)
			var/list/request_list = list()
			for(var/datum/data_rc_msg/rc in linkedServer.rc_msgs)
				request_list += list(list("ref" = REF(rc), "message" = rc.message, "stamp" = rc.stamp, "id_auth" = rc.id_auth, "departament" = rc.send_dpt))
			data["requests"] = request_list
	return data

/obj/machinery/computer/message_monitor/ui_act(action, params)
	. = ..()
	if(.)
		return

	error_message = ""
	succes_message = ""
	notice_message = ""

	switch(action)
		if("auth")
			// Get auth pass
			var/authPass = params["password"]

			if(auth)
				auth = FALSE
				return

			if(linkedServer.decryptkey != authPass)
				error_message = "ALERT: Incorrect decryption key!"
				return

			auth = TRUE
			succes_message = "YOU SUCCESFULLY LOGGED IN!"

			return
		if("link_server")
			var/list/message_servers = list()
			for (var/obj/machinery/telecomms/message_server/M in GLOB.telecomms_list)
				message_servers += M

			if(length(message_servers) > 1)
				linkedServer = tgui_input_list(usr, "Please select a server", "Server Selection", message_servers)
				if(linkedServer)
					notice_message = "NOTICE: Server selected."
				else if(length(message_servers) > 0)
					linkedServer = message_servers[1]
					notice_message = "NOTICE: Only Single Server Detected - Server selected."
				else
					error_message = "ALERT: No server detected."
			screen = MSG_MON_SCREEN_MAIN
			return
		if("turn_server")
			if(LINKED_SERVER_NONRESPONSIVE)
				error_message = "ALERT: No server detected."
				return

			linkedServer.toggled = !linkedServer.toggled
			return
		if("view_message_logs")
			screen = MSG_MON_SCREEN_LOGS
			return
		if("view_request_logs")
			screen = MSG_MON_SCREEN_REQUEST_LOGS
			return
		if("clear_message_logs")
			linkedServer.pda_msgs = list()
			notice_message = "NOTICE: Logs cleared."
			return
		if("clear_request_logs")
			linkedServer.rc_msgs = list()
			notice_message = "NOTICE: Logs cleared."
		if("set_key")
			var/dkey = tgui_input_text(usr, "Please enter the decryption key", "Telecomms Decryption")
			if(dkey && dkey != "")
				if(linkedServer.decryptkey == dkey)
					var/newkey = tgui_input_text(usr, "Please enter the new key (3 - 16 characters max)", "New Key")
					if(length(newkey) <= 3)
						notice_message = "NOTICE: Decryption key too short!"
					else if(newkey && newkey != "")
						linkedServer.decryptkey = newkey
					notice_message = "NOTICE: Decryption key set."
				else
					error_message = "ALERT: Incorrect decryption key!"
			return
		if("return_home")
			screen = MSG_MON_SCREEN_MAIN
			return
		if("delete_message")
			linkedServer.pda_msgs -= locate(params["ref"]) in linkedServer.pda_msgs
			succes_message = "Log Deleted!"
			return
		if("delete_request")
			linkedServer.rc_msgs -= locate(params["ref"]) in linkedServer.rc_msgs
			succes_message = "Log Deleted!"
			return
		if("connect_server")
			if(!linkedServer)
				for(var/obj/machinery/telecomms/message_server/S in GLOB.telecomms_list)
					linkedServer = S
					break
			return
		if("send_fake_message")
			//Get custom sender
			var/sender = tgui_input_text(usr, "What is the sender's name?", "Sender")
			//Get job
			var/job = tgui_input_text(usr, "What is the sender's job?", "Job")
			//Get recipient
			var/recipient
			var/list/viewable_tablets = list()
			for (var/obj/item/modular_computer/tablet as anything in GLOB.TabletMessengers)
				var/datum/computer_file/program/messenger/message_app = locate() in tablet.stored_files
				if(!message_app || message_app.invisible)
					continue
				if(!tablet.saved_identification)
					continue
				viewable_tablets += tablet
			if(length(viewable_tablets) > 0)
				recipient = tgui_input_list(usr, "Select a tablet from the list", "Tablet Selection", viewable_tablets)
			else
				recipient = null
			//Get message
			var/message = tgui_input_text(usr, "Please enter your message", "Message")
			if(isnull(sender) || sender == "")
				sender = "UNKNOWN"
			// Checking parametrs
			if(isnull(recipient))
				notice_message = "NOTICE: No recipient selected!"
				return attack_hand(usr)
			if(isnull(message) || message == "")
				notice_message = "NOTICE: No message entered!"
				return attack_hand(usr)

			var/datum/signal/subspace/messaging/tablet_msg/signal = new(src, list(
				"name" = "[sender]",
				"job" = "[job]",
				"message" = html_decode(message),
				"ref" = REF(src),
				"targets" = list(recipient),
				"rigged" = FALSE,
				"automated" = FALSE,
			))
			// This will log the signal and transmit it to the target
			linkedServer.receive_information(signal, null)
			usr.log_message("(Tablet: [name] | [usr.real_name]) sent \"[message]\" to [signal.format_target()]", LOG_PDA)
			return
		// Malfunction AI and cyborgs can hack console. This will auth console, but you need to wait password selection
		if("hack")
			var/time = 10 SECONDS * length(linkedServer.decryptkey)
			addtimer(CALLBACK(src, PROC_REF(unemag_console)), time)
			screen = MSG_MON_SCREEN_HACKED
			error_message = "%$&(£: Critical %$$@ Error // !RestArting! <lOadiNg backUp iNput ouTput> - ?pLeaSe wAit!"
			linkedServer.toggled = FALSE
			auth = TRUE
			return
	return TRUE

/obj/machinery/computer/message_monitor/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "MessageMonitor", name)
		ui.open()


#undef MSG_MON_SCREEN_MAIN
#undef MSG_MON_SCREEN_LOGS
#undef MSG_MON_SCREEN_REQUEST_LOGS
#undef MSG_MON_SCREEN_HACKED
#undef LINKED_SERVER_NONRESPONSIVE

// Monitor decryption key paper

/obj/item/paper/monitorkey
	name = "monitor decryption key"

/obj/item/paper/monitorkey/Initialize(mapload, obj/machinery/telecomms/message_server/server)
	..()
	if (server)
		print(server)
		return INITIALIZE_HINT_NORMAL
	else
		return INITIALIZE_HINT_LATELOAD

/obj/item/paper/monitorkey/proc/print(obj/machinery/telecomms/message_server/server)
	add_raw_text("<center><h2>Daily Key Reset</h2></center><br>The new message monitor key is <b>[server.decryptkey]</b>.<br>Please keep this a secret and away from the clown.<br>If necessary, change the password to a more secure one.")
	add_overlay("paper_words")
	update_appearance()

/obj/item/paper/monitorkey/LateInitialize()
	for (var/obj/machinery/telecomms/message_server/preset/server in GLOB.telecomms_list)
		if (server.decryptkey)
			print(server)
			break
