#define EXTERNALREPLYCOUNT 2
#define EXTERNAL_PM_USER "IRCKEY"

//allows right clicking mobs to send an admin PM to their client, forwards the selected mob's client to cmd_admin_pm
/client/proc/cmd_admin_pm_context(mob/M in GLOB.mob_list)
	set category = null
	set name = "Admin PM Mob"
	if(!holder)
		to_chat(src,
			type = MESSAGE_TYPE_ADMINPM,
			html = span_danger("Error: Admin-PM-Context: Only administrators may use this command."),
			confidential = TRUE)
		return
	if(!ismob(M))
		to_chat(src,
			type = MESSAGE_TYPE_ADMINPM,
			html = span_danger("Error: Admin-PM-Context: Target mob is not a mob, somehow."),
			confidential = TRUE)
		return
	cmd_admin_pm(M.client, null)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Admin PM Mob") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

//shows a list of clients we could send PMs to, then forwards our choice to cmd_admin_pm
/client/proc/cmd_admin_pm_panel()
	set category = "Admin"
	set name = "Admin PM"
	if(!holder)
		to_chat(src,
			type = MESSAGE_TYPE_ADMINPM,
			html = span_danger("Error: Admin-PM-Panel: Only administrators may use this command."),
			confidential = TRUE)
		return

	var/list/targets = list()
	for(var/client/client in GLOB.clients)
		var/nametag = ""
		var/mob/lad = client.mob
		var/mob_name = lad?.name
		var/real_mob_name = lad?.real_name
		if(!lad)
			nametag = "(No Mob)"
		else if(isnewplayer(lad))
			nametag = "(New Player)"
		else if(isobserver(lad))
			nametag = "[mob_name](Ghost)"
		else
			nametag = "[real_mob_name](as [mob_name])"
		targets["[nametag] - [client]"] = client

	var/target = input(src,"To whom shall we send a message?", "Admin PM", null) as null|anything in sort_list(targets)
	cmd_admin_pm(targets[target], null)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Admin PM") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_ahelp_reply(whom)
	if(IsAdminAdvancedProcCall())
		return FALSE

	if(prefs.muted & MUTE_ADMINHELP)
		to_chat(src,
			type = MESSAGE_TYPE_ADMINPM,
			html = span_danger("Error: Admin-PM: You are unable to use admin PM-s (muted)."),
			confidential = TRUE)
		return
	var/client/C

	// Lemon todo: bring this behavior back, check diffs
	if(!C)
		if(holder)
			to_chat(src,
				type = MESSAGE_TYPE_ADMINPM,
				html = span_danger("Error: Admin-PM: Client not found."),
				confidential = TRUE)
		return

	var/datum/admin_help/AH = C.current_ticket

	var/message_prompt = "Message:"

	if(AH?.opening_responders && length(AH.ticket_interactions) == 1)
		SEND_SOUND(src, sound('sound/machines/buzz-sigh.ogg', volume=30))
		message_prompt += "\n\n**This ticket is already being responded to by: [english_list(AH.opening_responders)]**"

	if(AH)
		message_admins("[key_name_admin(src)] has started replying to [key_name_admin(C, 0, 0)]'s admin help.")
		if(length(AH.ticket_interactions) == 1) // add the admin who is currently responding to the list of people responding
			LAZYADD(AH.opening_responders, src)

	var/msg = input(src, message_prompt, "Private message to [C.holder?.fakekey ? "an Administrator" : key_name(C, 0, 0)].") as message|null
	LAZYREMOVE(AH.opening_responders, src)
	if (!msg)
		message_admins("[key_name_admin(src)] has cancelled their reply to [key_name_admin(C, 0, 0)]'s admin help.")
		return
	if(!C) //We lost the client during input, disconnected or relogged.
		if(GLOB.directory[AH.initiator_ckey]) // Client has reconnected, lets try to recover
			whom = GLOB.directory[AH.initiator_ckey]
		else
			to_chat(src,
				type = MESSAGE_TYPE_ADMINPM,
				html = span_danger("Error: Admin-PM: Client not found."),
				confidential = TRUE)
			to_chat(src,
				type = MESSAGE_TYPE_ADMINPM,
				html = "[span_danger("<b>Message not sent:</b>")]<br>[msg]",
				confidential = TRUE)
			AH.AddInteraction("<b>No client found, message not sent:</b><br>[msg]")
			return
	cmd_admin_pm(whom, msg)

//takes input from cmd_admin_pm_context, cmd_admin_pm_panel or /client/Topic and sends them a PM.
//Fetching a message if needed. src is the sender and C is the target client
/client/proc/cmd_admin_pm(whom, msg)
	if(prefs.muted & MUTE_ADMINHELP)
		to_chat(src,
			type = MESSAGE_TYPE_ADMINPM,
			html = span_danger("Error: Admin-PM: You are unable to use admin PM-s (muted)."),
			confidential = TRUE)
		return

	if(!holder && !current_ticket) //no ticket? https://www.youtube.com/watch?v=iHSPf6x1Fdo
		to_chat(src,
			type = MESSAGE_TYPE_ADMINPM,
			html = span_danger("You can no longer reply to this ticket, please open another one by using the Adminhelp verb if need be."),
			confidential = TRUE)
		to_chat(src,
			type = MESSAGE_TYPE_ADMINPM,
			html = span_notice("Message: [msg]"),
			confidential = TRUE)
		return

	// We use the ckey here rather then keeping the client to ensure resistance to client logouts mid execution
	if(istype(whom, /client))
		var/client/boi = whom
		whom = boi.ckey

	var/message_to_send = request_adminpm_message(disambiguate_client(whom), msg)
	if(!message_to_send)
		return

	if(!sends_adminpm_message(disambiguate_client(whom), message_to_send))
		return

	notify_adminpm_message(disambiguate_client(whom), message_to_send)


/// Requests an admin pm message to send
/// message_target here can be either [EXTERNAL_PM_USER], indicating that this message is intended for some external chat channel
/// or a /client, which we will then store info about to ensure logout -> logins are protected as expected
/// Accepts an optional existing message, which will be used in place of asking the recipient assuming all other conditions are met
/// Returns the message to send or null if no message is found
/// Sleeps
/client/proc/request_adminpm_message(ambiguious_recipient, existing_message = null)
	if(IsAdminAdvancedProcCall())
		return null

	if(ambiguious_recipient == EXTERNAL_PM_USER)
		if(!externalreplyamount) //to prevent people from spamming irc/discord
			to_chat(src,
				type = MESSAGE_TYPE_ADMINPM,
				html = span_danger("Error: Admin-PM-Message: External reply cap hit."),
				confidential = TRUE)
			return null
		var/msg = ""
		if(existing_message)
			msg = existing_message
		else
			msg = input(src,"Message:", "Private message to Administrator") as message|null

		if(!msg)
			to_chat(src,
				type = MESSAGE_TYPE_ADMINPM,
				html = span_danger("Error: Admin-PM-Message: No message input."),
				confidential = TRUE)
			return null

		if(holder)
			to_chat(src,
				type = MESSAGE_TYPE_ADMINPM,
				html = span_danger("Error: Admin-PM-Message: Use the admin IRC/Discord channel, nerd."),
				confidential = TRUE)
			return null
		return msg

	if(!istype(ambiguious_recipient, /client))
		to_chat(src,
			type = MESSAGE_TYPE_ADMINPM,
			html = span_danger("Error: Admin-PM-Message: Client not found."),
			confidential = TRUE)
		return null

	var/client/recipient = ambiguious_recipient
	// Stored in case client is deleted between this and after the message is input
	var/recipient_ckey = recipient.ckey
	// Stored in case client is deleted between this and after the message is input
	var/datum/admin_help/recipient_ticket = recipient.current_ticket
	// Our current active ticket
	var/datum/admin_help/our_ticket = current_ticket

	// The message we intend on returning
	var/msg = ""

	if(existing_message)
		msg = existing_message
	else
		//get message text, limit it's length.and clean/escape html
		msg = input(src,"Message:", "Private message to [recipient.holder?.fakekey ? "an Administrator" : key_name(recipient, 0, 0)].") as message|null
		msg = trim(msg)

	if(!msg)
		to_chat(src,
			type = MESSAGE_TYPE_ADMINPM,
			html = span_danger("Error: Admin-PM-Message: No message input."),
			confidential = TRUE)
		return null

	if(recipient)
		return msg
	// Client has disappeared due to logout
	if(GLOB.directory[recipient_ckey]) // Client has reconnected, lets try to recover
		recipient = GLOB.directory[recipient_ckey]
		return msg

	// We don't tell standard users if a ticket drops because admins have a way to actually see
	// Past tickets, and well, admins are the ones who might ban you if you ignore them
	if(holder)
		to_chat(src,
			type = MESSAGE_TYPE_ADMINPM,
			html = span_danger("Error: Admin-PM-Message: Client not found."),
			confidential = TRUE)
		to_chat(src,
			type = MESSAGE_TYPE_ADMINPM,
			html = "[span_danger("<b>Message not sent:</b>")]<br>[msg]",
			confidential = TRUE)
		if(recipient_ticket)
			recipient_ticket.AddInteraction("<b>No client found, message not sent:</b><br>[msg]")
		return null
	if(our_ticket)
		our_ticket.MessageNoRecipient(msg)
	return null

/// Sends a pm message via the tickets system
/// message_target here can be either [EXTERNAL_PM_USER], indicating that this message is intended for some external chat channel
/// or a /client, in which case we send in the standard form
/// send_message is the raw message to send, it will be filtered and treated to ensure we do not break any text handling
/// Returns FALSE if the send failed, TRUE otherwise
/client/proc/sends_adminpm_message(ambiguious_recipient, send_message)
	if(IsAdminAdvancedProcCall())
		return FALSE

	if(prefs.muted & MUTE_ADMINHELP)
		to_chat(src,
			type = MESSAGE_TYPE_ADMINPM,
			html = span_danger("Error: Admin-PM-Send: You are unable to use admin PM-s (muted)."),
			confidential = TRUE)
		return FALSE

	if (handle_spam_prevention(send_message, MUTE_ADMINHELP))
		// handle_spam_prevention does its own "hey buddy ya fucker up here's what happen"
		return FALSE

	//clean the message if it's not sent by a high-rank admin
	if(!check_rights(R_SERVER|R_DEBUG, 0) || ambiguious_recipient == EXTERNAL_PM_USER)//no sending html to the poor bots
		send_message = sanitize(copytext_char(send_message, 1, MAX_MESSAGE_LEN))
		if(!send_message)
			to_chat(src,
				type = MESSAGE_TYPE_ADMINPM,
				html = span_danger("Error: Admin-PM-Send: Your message contained only HTML, it's been sanitized away and the message disregarded."),
				confidential = TRUE)
			return FALSE

	var/raw_messsage = send_message

	if(holder)
		send_message = emoji_parse(send_message)

	var/keyword_parsed_msg = keywords_lookup(send_message)
	// Stores a bit of html with our ckey, name, and a linkified string to click and rely to us with
	var/name_key_with_link = key_name(src, TRUE, TRUE)

	if(ambiguious_recipient == EXTERNAL_PM_USER)
		to_chat(src,
			type = MESSAGE_TYPE_ADMINPM,
			html = span_notice("PM to-<b>Admins</b>: <span class='linkify'>[raw_messsage]</span>"),
			confidential = TRUE)
		var/datum/admin_help/new_admin_help = admin_ticket_log(src,
			"<font color='red'>Reply PM from-<b>[name_key_with_link]</b> to <i>External</i>: [keyword_parsed_msg]</font>",
			player_message = "<font color='red'>Reply PM from-<b>[name_key_with_link]</b> to <i>External</i>: [send_message]</font>")
		externalreplyamount--

		var/category = "Reply: [ckey]"
		if(new_admin_help)
			var/new_help_id = new_admin_help.id
			category = "#[new_help_id] [category]"

		send2adminchat(category, raw_messsage)
		return TRUE

	if(!istype(ambiguious_recipient, /client))
		to_chat(src,
			type = MESSAGE_TYPE_ADMINPM,
			html = span_danger("Error: Admin-PM-Send: Client not found."),
			confidential = TRUE)
		return FALSE

	var/client/recipient = ambiguious_recipient
	var/datum/admins/recipient_holder = recipient.holder

	// Stores a bit of html that contains the ckey of the recipient, its mob's name if any exist, and a link to reply to them with
	var/their_name_with_link = key_name(recipient, TRUE, TRUE)
	// Stores a bit of html with our ckey highlighted as a reply link
	var/link_to_us = key_name(src, TRUE, FALSE)
	// Stores a bit of html with outhe ckey of the recipientr highlighted as a reply link
	var/link_to_their = key_name(recipient, TRUE, FALSE)
	// Our ckey
	var/our_ckey = ckey
	// Recipient ckey
	var/recip_ckey = recipient.ckey
	// Our current ticket, can (supposedly) be null here
	var/datum/admin_help/ticket = current_ticket
	// The recipient's current ticket, could in theory? maybe? be null here
	var/datum/admin_help/recipient_ticket = recipient.current_ticket
	// I use -1 as a default for both of these
	// Our ticket ID
	var/ticket_id = ticket?.id || -1
	// The recipient's ticket id
	var/recipient_ticket_id = recipient_ticket?.id || -1


	// If this message is for an admin, and either we're not an admin or this isn't a new ticket
	// (basically if this isn't an admin on admin boink)
	if(recipient_holder && (!holder || current_ticket))
		SEND_SIGNAL(current_ticket, COMSIG_ADMIN_HELP_REPLIED)

		//play the receiving admin the adminhelp sound (if they have them enabled)
		if(recipient.prefs.toggles & SOUND_ADMINHELP)
			SEND_SOUND(recipient, sound('sound/effects/adminhelp.ogg'))

		// If we're an admin, it's admin on admin violence
		if(holder)
			to_chat(recipient,
				type = MESSAGE_TYPE_ADMINPM,
				html = span_danger("Admin PM from-<b>[name_key_with_link]</b>: <span class='linkify'>[keyword_parsed_msg]</span>"),
				confidential = TRUE)
			to_chat(src,
				type = MESSAGE_TYPE_ADMINPM,
				html = span_notice("Admin PM to-<b>[their_name_with_link]</b>: <span class='linkify'>[keyword_parsed_msg]</span>"),
				confidential = TRUE)

			//omg this is dumb, just fill in both their logs
			var/interaction_message = "<font color='purple'>PM from-<b>[name_key_with_link]</b> to-<b>[their_name_with_link]</b>: [keyword_parsed_msg]</font>"
			var/player_interaction_message = "<font color='purple'>PM from-<b>[link_to_us]</b> to-<b>[link_to_their]</b>: [send_message]</font>"
			admin_ticket_log(src,
				interaction_message,
				log_in_blackbox = FALSE,
				player_message = player_interaction_message)
			if(recipient != src) //reeee
				admin_ticket_log(recipient,
					interaction_message,
					log_in_blackbox = FALSE,
					player_message = player_interaction_message)

			SSblackbox.LogAhelp(ticket_id, "Reply", send_message, recip_ckey, our_ckey)
			return TRUE
		//recipient is an admin but sender is not
		var/replymsg = "Reply PM from-<b>[name_key_with_link]</b>: <span class='linkify'>[keyword_parsed_msg]</span>"
		var/player_replymsg = "Reply PM from-<b>[link_to_us]</b>: <span class='linkify'>[send_message]</span>"
		admin_ticket_log(src,
			"<font color='red'>[replymsg]</font>",
			log_in_blackbox = FALSE,
			player_message = player_replymsg)
		to_chat(recipient,
			type = MESSAGE_TYPE_ADMINPM,
			html = span_danger("[replymsg]"),
			confidential = TRUE)
		to_chat(src,
			type = MESSAGE_TYPE_ADMINPM,
			html = span_notice("PM to-<b>Admins</b>: <span class='linkify'>[send_message]</span>"),
			confidential = TRUE)
		SSblackbox.LogAhelp(ticket_id, "Reply", send_message, recip_ckey, our_ckey)
		return TRUE

	if(!holder) //neither are admins (or the recipient is but we aren't and there's no active ticket so fuck off)
		if(!current_ticket)
			to_chat(src,
				type = MESSAGE_TYPE_ADMINPM,
				html = span_danger("Error: Admin-PM-Send: Non-admin to non-admin PM communication is forbidden."),
				confidential = TRUE)
			to_chat(src,
				type = MESSAGE_TYPE_ADMINPM,
				html = "[span_danger("<b>Message not sent:</b>")]<br>[send_message]",
				confidential = TRUE)
			return FALSE
		current_ticket.MessageNoRecipient(send_message)
		return TRUE

	//sender is an admin but recipient is not. Do BIG RED TEXT
	var/already_logged = FALSE
	if(!recipient.current_ticket)
		new /datum/admin_help(send_message, recipient, TRUE)
		already_logged = TRUE
		// This action mutates our existing cached ticket information, so we recache
		ticket = current_ticket
		recipient_ticket = recipient.current_ticket
		ticket_id = ticket?.id || -1
		recipient_ticket_id = recipient_ticket?.id || -1
		SSblackbox.LogAhelp(recipient_ticket_id, "Ticket Opened", send_message, recipient.ckey, src.ckey)

	to_chat(recipient,
		type = MESSAGE_TYPE_ADMINPM,
		html = "<font color='red' size='4'><b>-- Administrator private message --</b></font>",
		confidential = TRUE)
	to_chat(recipient,
		type = MESSAGE_TYPE_ADMINPM,
		html = span_adminsay("Admin PM from-<b>[link_to_us]</b>: <span class='linkify'>[send_message]</span>"),
		confidential = TRUE)
	to_chat(recipient,
		type = MESSAGE_TYPE_ADMINPM,
		html = span_adminsay("<i>Click on the administrator's name to reply.</i>"),
		confidential = TRUE)
	to_chat(src,
		type = MESSAGE_TYPE_ADMINPM,
		html = span_notice("Admin PM to-<b>[their_name_with_link]</b>: <span class='linkify'>[send_message]</span>"),
		confidential = TRUE)

	admin_ticket_log(recipient,
		"<font color='purple'>PM From [name_key_with_link]: [keyword_parsed_msg]</font>",
		log_in_blackbox = FALSE,
		player_message = "<font color='purple'>PM From [link_to_us]: [send_message]</font>")

	if(!already_logged) //Reply to an existing ticket
		SSblackbox.LogAhelp(recipient_ticket_id, "Reply", send_message, recip_ckey, our_ckey)

	//always play non-admin recipients the adminhelp sound
	SEND_SOUND(recipient, sound('sound/effects/adminhelp.ogg'))
	return TRUE

/// Notifies all admins about the existance of an admin pm, then logs the pm
/// message_target here can be either [EXTERNAL_PM_USER], indicating that this message is intended for some external chat channel
/// or a /client, in which case we send in the standard form
/// log_message is the raw message to send, it will be filtered and treated to ensure we do not break any text handling
/client/proc/notify_adminpm_message(ambiguious_recipient, log_message)
	if(IsAdminAdvancedProcCall())
		return

	// First we filter, because these procs can be called by anyone with debug, and I don't trust that check
	// gotta make sure none's fucking about
	if(prefs.muted & MUTE_ADMINHELP)
		to_chat(src,
			type = MESSAGE_TYPE_ADMINPM,
			html = span_danger("Error: Admin-PM-Notify: You are unable to use admin PM-s (muted)."),
			confidential = TRUE)
		return

	//clean the message if it's not sent by a high-rank admin
	if(!check_rights(R_SERVER|R_DEBUG, 0) || ambiguious_recipient == EXTERNAL_PM_USER)//no sending html to the poor bots
		log_message = sanitize(copytext_char(log_message, 1, MAX_MESSAGE_LEN))
		if(!log_message)
			to_chat(src,
				type = MESSAGE_TYPE_ADMINPM,
				html = span_danger("Error: Admin-PM-Notify: Your message contained only HTML, it's been sanitized away and the message disregarded."),
				confidential = TRUE)
			return

	var/raw_messsage = log_message

	if(holder)
		log_message = emoji_parse(log_message)

	var/keyword_parsed_msg = keywords_lookup(log_message)
	// Shows our ckey and the name of any mob we might be possessing
	var/our_name = key_name(src)
	// Shows our ckey/name embedded inside a clickable link to reply to this message
	var/our_linked_ckey = key_name(src, TRUE, FALSE)

	if(ambiguious_recipient == EXTERNAL_PM_USER)
		// Guard against the possibility of a null, since it'll runtime and spit out the contents of what should be a private ticket.
		if(current_ticket)
			log_admin_private("PM: Ticket #[current_ticket.id]: [our_name]->External: [raw_messsage]")
		else
			log_admin_private("PM: [our_name]->External: [raw_messsage]")
		for(var/client/lad in GLOB.admins)
			to_chat(lad,
				type = MESSAGE_TYPE_ADMINPM,
				html = span_notice("<B>PM: [our_linked_ckey]-&gt;External:</B> [keyword_parsed_msg]"),
				confidential = TRUE)
		return
	if(!istype(ambiguious_recipient, /client))
		to_chat(src,
			type = MESSAGE_TYPE_ADMINPM,
			html = span_danger("Error: Admin-PM-Notify: Client not found."),
			confidential = TRUE)
		return

	var/client/recipient = ambiguious_recipient
	// Shows the recipient's ckey and the name of any mob it might be possessing
	var/recipient_name = key_name(recipient)
	// Shows the recipient's ckey/name embedded inside a clickable link to reply to this message
	var/recipient_linked_ckey = key_name(recipient, TRUE, FALSE)

	window_flash(recipient, ignorepref = TRUE)
	if(current_ticket)
		log_admin_private("PM: Ticket #[current_ticket.id]: [our_name]->[recipient_name]: [raw_messsage]")
	else
		log_admin_private("PM: [our_name]->[recipient_name]: [raw_messsage]")
	//we don't use message_admins here because the sender/receiver might get it too
	for(var/client/lad in GLOB.admins)
		if(lad.key == key || lad.key == recipient.key) //check to make sure client/lad isn't the sender or recipient
			continue
		to_chat(lad,
			type = MESSAGE_TYPE_ADMINPM,
			html = span_notice("<B>PM: [our_linked_ckey]-&gt;[recipient_linked_ckey]:</B> [keyword_parsed_msg]") ,
			confidential = TRUE)

#define TGS_AHELP_USAGE "Usage: ticket <close|resolve|icissue|reject|reopen \[ticket #\]|list>"
/proc/TgsPm(target,msg,sender)
	target = ckey(target)
	var/client/C = GLOB.directory[target]

	var/datum/admin_help/ticket = C ? C.current_ticket : GLOB.ahelp_tickets.CKey2ActiveTicket(target)
	var/compliant_msg = trim(lowertext(msg))
	var/tgs_tagged = "[sender](TGS/External)"
	var/list/splits = splittext(compliant_msg, " ")
	if(splits.len && splits[1] == "ticket")
		if(splits.len < 2)
			return TGS_AHELP_USAGE
		switch(splits[2])
			if("close")
				if(ticket)
					ticket.Close(tgs_tagged)
					return "Ticket #[ticket.id] successfully closed"
			if("resolve")
				if(ticket)
					ticket.Resolve(tgs_tagged)
					return "Ticket #[ticket.id] successfully resolved"
			if("icissue")
				if(ticket)
					ticket.ICIssue(tgs_tagged)
					return "Ticket #[ticket.id] successfully marked as IC issue"
			if("reject")
				if(ticket)
					ticket.Reject(tgs_tagged)
					return "Ticket #[ticket.id] successfully rejected"
			if("reopen")
				if(ticket)
					return "Error: [target] already has ticket #[ticket.id] open"
				var/fail = splits.len < 3 ? null : -1
				if(!isnull(fail))
					fail = text2num(splits[3])
				if(isnull(fail))
					return "Error: No/Invalid ticket id specified. [TGS_AHELP_USAGE]"
				var/datum/admin_help/AH = GLOB.ahelp_tickets.TicketByID(fail)
				if(!AH)
					return "Error: Ticket #[fail] not found"
				if(AH.initiator_ckey != target)
					return "Error: Ticket #[fail] belongs to [AH.initiator_ckey]"
				AH.Reopen()
				return "Ticket #[ticket.id] successfully reopened"
			if("list")
				var/list/tickets = GLOB.ahelp_tickets.TicketsByCKey(target)
				if(!tickets.len)
					return "None"
				. = ""
				for(var/I in tickets)
					var/datum/admin_help/AH = I
					if(.)
						. += ", "
					if(AH == ticket)
						. += "Active: "
					. += "#[AH.id]"
				return
			else
				return TGS_AHELP_USAGE
		return "Error: Ticket could not be found"

	var/static/stealthkey
	var/adminname = CONFIG_GET(flag/show_irc_name) ? tgs_tagged : "Administrator"

	if(!C)
		return "Error: No client"

	if(!stealthkey)
		stealthkey = GenTgsStealthKey()

	msg = sanitize(copytext_char(msg, 1, MAX_MESSAGE_LEN))
	if(!msg)
		return "Error: No message"

	message_admins("External message from [sender] to [key_name_admin(C)] : [msg]")
	log_admin_private("External PM: [sender] -> [key_name(C)] : [msg]")
	msg = emoji_parse(msg)

	to_chat(C,
		type = MESSAGE_TYPE_ADMINPM,
		html = "<font color='red' size='4'><b>-- Administrator private message --</b></font>",
		confidential = TRUE)
	to_chat(C,
		type = MESSAGE_TYPE_ADMINPM,
		html = span_adminsay("Admin PM from-<b><a href='?priv_msg=[stealthkey]'>[adminname]</A></b>: [msg]"),
		confidential = TRUE)
	to_chat(C,
		type = MESSAGE_TYPE_ADMINPM,
		html = span_adminsay("<i>Click on the administrator's name to reply.</i>"),
		confidential = TRUE)

	admin_ticket_log(C, "<font color='purple'>PM From [tgs_tagged]: [msg]</font>", log_in_blackbox = FALSE)

	window_flash(C, ignorepref = TRUE)
	//always play non-admin recipients the adminhelp sound
	SEND_SOUND(C, 'sound/effects/adminhelp.ogg')

	C.externalreplyamount = EXTERNALREPLYCOUNT

	return "Message Successful"

/proc/GenTgsStealthKey()
	var/num = (rand(0,1000))
	var/i = 0
	while(i == 0)
		i = 1
		for(var/P in GLOB.stealthminID)
			if(num == GLOB.stealthminID[P])
				num++
				i = 0
	var/stealth = "@[num2text(num)]"
	GLOB.stealthminID[EXTERNAL_PM_USER] = stealth
	return stealth

/// Takes an argument which could be either a ckey, /client, or IRC marker, and returns a client if possible
/// Returns [EXTERNAL_PM_USER] if an IRC marker is detected
/// Otherwise returns null
/proc/disambiguate_client(whom)
	if(istype(whom, /client))
		return whom

	if(!istext(whom) || !(length(whom) >= 1))
		return null

	var/searching_ckey = whom
	if(whom[1] == "@")
		searching_ckey = findTrueKey(whom)

	if(searching_ckey == EXTERNAL_PM_USER)
		return EXTERNAL_PM_USER

	return GLOB.directory[searching_ckey]

#undef EXTERNAL_PM_USER
#undef EXTERNALREPLYCOUNT
