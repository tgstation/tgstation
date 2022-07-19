#define EXTERNALREPLYCOUNT 2

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
	if(!ismob(M) || !M.client)
		return
	cmd_admin_pm(M.client,null)
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
	for(var/client/client as anything in GLOB.clients)
		if(client.mob)
			if(isnewplayer(client.mob))
				targets["(New Player) - [client]"] = client
			else if(isobserver(client.mob))
				targets["[client.mob.name](Ghost) - [client]"] = client
			else
				targets["[client.mob.real_name](as [client.mob.name]) - [client]"] = client
		else
			targets["(No Mob) - [client]"] = client
	var/target = input(src,"To whom shall we send a message?","Admin PM",null) as null|anything in sort_list(targets)
	cmd_admin_pm(targets[target],null)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Admin PM") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_ahelp_reply(whom)
	if(prefs.muted & MUTE_ADMINHELP)
		to_chat(src,
			type = MESSAGE_TYPE_ADMINPM,
			html = span_danger("Error: Admin-PM: You are unable to use admin PM-s (muted)."),
			confidential = TRUE)
		return
	var/client/C
	if(istext(whom))
		if(whom[1] == "@")
			whom = findStealthKey(whom)
		C = GLOB.directory[whom]
	else if(istype(whom, /client))
		C = whom
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

	var/client/recipient
	var/recipient_ckey // Stored in case client is deleted between this and after the message is input
	var/datum/admin_help/recipient_ticket // Stored in case client is deleted between this and after the message is input
	var/external = 0
	if(istext(whom))
		if(whom[1] == "@")
			whom = findStealthKey(whom)
		if(whom == "IRCKEY")
			external = 1
		else
			recipient = GLOB.directory[whom]
	else if(istype(whom, /client))
		recipient = whom

	if(!recipient)
		to_chat(src,
			type = MESSAGE_TYPE_ADMINPM,
			html = span_danger("Error: Admin-PM: Client not found."),
			confidential = TRUE)
		return

	recipient_ckey = recipient.ckey
	recipient_ticket = recipient.current_ticket

	if(external)
		if(!externalreplyamount) //to prevent people from spamming irc/discord
			return
		if(!msg)
			msg = input(src,"Message:", "Private message to Administrator") as message|null

		if(!msg)
			return
		if(holder)
			to_chat(src,
				type = MESSAGE_TYPE_ADMINPM,
				html = span_danger("Error: Use the admin IRC/Discord channel, nerd."),
				confidential = TRUE)
			return


	else
		//get message text, limit it's length.and clean/escape html
		if(!msg)
			msg = input(src,"Message:", "Private message to [recipient.holder?.fakekey ? "an Administrator" : key_name(recipient, 0, 0)].") as message|null
			msg = trim(msg)
			if(!msg)
				return

		if(!recipient)
			if(GLOB.directory[recipient_ckey]) // Client has reconnected, lets try to recover
				recipient = GLOB.directory[recipient_ckey]
			else
				if(holder)
					to_chat(src,
						type = MESSAGE_TYPE_ADMINPM,
						html = span_danger("Error: Admin-PM: Client not found."),
						confidential = TRUE)
					to_chat(src,
						type = MESSAGE_TYPE_ADMINPM,
						html = "[span_danger("<b>Message not sent:</b>")]<br>[msg]",
						confidential = TRUE)
					if(recipient_ticket)
						recipient_ticket.AddInteraction("<b>No client found, message not sent:</b><br>[msg]")
					return
				else
					current_ticket.MessageNoRecipient(msg)
					return


	if(prefs.muted & MUTE_ADMINHELP)
		to_chat(src,
			type = MESSAGE_TYPE_ADMINPM,
			html = span_danger("Error: Admin-PM: You are unable to use admin PM-s (muted)."),
			confidential = TRUE)
		return

	if (src.handle_spam_prevention(msg,MUTE_ADMINHELP))
		return

	//clean the message if it's not sent by a high-rank admin
	if(!check_rights(R_SERVER|R_DEBUG,0)||external)//no sending html to the poor bots
		msg = sanitize(copytext_char(msg, 1, MAX_MESSAGE_LEN))
		if(!msg)
			return

	var/rawmsg = msg

	if(holder)
		msg = emoji_parse(msg)

	var/keywordparsedmsg = keywords_lookup(msg)

	if(external)
		to_chat(src,
			type = MESSAGE_TYPE_ADMINPM,
			html = span_notice("PM to-<b>Admins</b>: <span class='linkify'>[rawmsg]</span>"),
			confidential = TRUE)
		var/datum/admin_help/new_admin_help = admin_ticket_log(src, "<font color='red'>Reply PM from-<b>[key_name(src, TRUE, TRUE)]</b> to <i>External</i>: [keywordparsedmsg]</font>", player_message = "<font color='red'>Reply PM from-<b>[key_name(src, TRUE, FALSE)]</b> to <i>External</i>: [msg]</font>")
		externalreplyamount--
		send2adminchat("[new_admin_help ? "#[new_admin_help.id] " : ""]Reply: [ckey]", rawmsg)
	else
		var/badmin = FALSE //Lets figure out if an admin is getting bwoinked.
		if(holder && recipient.holder && !current_ticket) //Both are admins, and this is not a reply to our own ticket.
			badmin = TRUE
		if(recipient.holder && !badmin)
			SEND_SIGNAL(current_ticket, COMSIG_ADMIN_HELP_REPLIED)

			if(holder)
				to_chat(recipient,
					type = MESSAGE_TYPE_ADMINPM,
					html = span_danger("Admin PM from-<b>[key_name(src, recipient, 1)]</b>: <span class='linkify'>[keywordparsedmsg]</span>"),
					confidential = TRUE)
				to_chat(src,
					type = MESSAGE_TYPE_ADMINPM,
					html = span_notice("Admin PM to-<b>[key_name(recipient, src, 1)]</b>: <span class='linkify'>[keywordparsedmsg]</span>"),
					confidential = TRUE)
				//omg this is dumb, just fill in both their tickets
				var/interaction_message = "<font color='purple'>PM from-<b>[key_name(src, recipient, TRUE)]</b> to-<b>[key_name(recipient, src, TRUE)]</b>: [keywordparsedmsg]</font>"
				var/player_interaction_message = "<font color='purple'>PM from-<b>[key_name(src, recipient, FALSE)]</b> to-<b>[key_name(recipient, src, FALSE)]</b>: [msg]</font>"
				admin_ticket_log(src, interaction_message, log_in_blackbox = FALSE, player_message = player_interaction_message)
				if(recipient != src) //reeee
					admin_ticket_log(recipient, interaction_message, log_in_blackbox = FALSE, player_message = player_interaction_message)
				SSblackbox.LogAhelp(current_ticket.id, "Reply", msg, recipient.ckey, src.ckey)
			else //recipient is an admin but sender is not
				var/replymsg = "Reply PM from-<b>[key_name(src, recipient, TRUE)]</b>: <span class='linkify'>[keywordparsedmsg]</span>"
				var/player_replymsg = "Reply PM from-<b>[key_name(src, recipient, FALSE)]</b>: <span class='linkify'>[msg]</span>"
				admin_ticket_log(src, "<font color='red'>[replymsg]</font>", log_in_blackbox = FALSE, player_message = player_replymsg)
				to_chat(recipient,
					type = MESSAGE_TYPE_ADMINPM,
					html = span_danger("[replymsg]"),
					confidential = TRUE)
				to_chat(src,
					type = MESSAGE_TYPE_ADMINPM,
					html = span_notice("PM to-<b>Admins</b>: <span class='linkify'>[msg]</span>"),
					confidential = TRUE)
				SSblackbox.LogAhelp(current_ticket.id, "Reply", msg, recipient.ckey, src.ckey)

			//play the receiving admin the adminhelp sound (if they have them enabled)
			if(recipient.prefs.toggles & SOUND_ADMINHELP)
				SEND_SOUND(recipient, sound('sound/effects/adminhelp.ogg'))
		else
			if(holder) //sender is an admin but recipient is not. Do BIG RED TEXT
				var/already_logged = FALSE
				if(!recipient.current_ticket)
					new /datum/admin_help(msg, recipient, TRUE)
					already_logged = TRUE
					SSblackbox.LogAhelp(recipient.current_ticket.id, "Ticket Opened", msg, recipient.ckey, src.ckey)

				to_chat(recipient,
					type = MESSAGE_TYPE_ADMINPM,
					html = "<font color='red' size='4'><b>-- Administrator private message --</b></font>",
					confidential = TRUE)
				to_chat(recipient,
					type = MESSAGE_TYPE_ADMINPM,
					html = span_adminsay("Admin PM from-<b>[key_name(src, recipient, 0)]</b>: <span class='linkify'>[msg]</span>"),
					confidential = TRUE)
				to_chat(recipient,
					type = MESSAGE_TYPE_ADMINPM,
					html = span_adminsay("<i>Click on the administrator's name to reply.</i>"),
					confidential = TRUE)
				to_chat(src,
					type = MESSAGE_TYPE_ADMINPM,
					html = span_notice("Admin PM to-<b>[key_name(recipient, src, 1)]</b>: <span class='linkify'>[msg]</span>"),
					confidential = TRUE)

				admin_ticket_log(recipient, "<font color='purple'>PM From [key_name_admin(src)]: [keywordparsedmsg]</font>", log_in_blackbox = FALSE, player_message = "<font color='purple'>PM From [key_name_admin(src, include_name = FALSE)]: [msg]</font>")

				if(!already_logged) //Reply to an existing ticket
					SSblackbox.LogAhelp(recipient.current_ticket.id, "Reply", msg, recipient.ckey, src.ckey)

				//always play non-admin recipients the adminhelp sound
				SEND_SOUND(recipient, sound('sound/effects/adminhelp.ogg'))

			else //neither are admins
				if(!current_ticket)
					to_chat(src,
						type = MESSAGE_TYPE_ADMINPM,
						html = span_danger("Error: Admin-PM: Non-admin to non-admin PM communication is forbidden."),
						confidential = TRUE)
					to_chat(src,
						type = MESSAGE_TYPE_ADMINPM,
						html = "[span_danger("<b>Message not sent:</b>")]<br>[msg]",
						confidential = TRUE)
					return
				current_ticket.MessageNoRecipient(msg)

	if(external)
		// Guard against the possibility of a null, since it'll runtime and spit out the contents of what should be a private ticket.
		if(current_ticket)
			log_admin_private("PM: Ticket #[current_ticket.id]: [key_name(src)]->External: [rawmsg]")
		else
			log_admin_private("PM: [key_name(src)]->External: [rawmsg]")
		for(var/client/X in GLOB.admins)
			to_chat(X,
				type = MESSAGE_TYPE_ADMINPM,
				html = span_notice("<B>PM: [key_name(src, X, 0)]-&gt;External:</B> [keywordparsedmsg]"),
				confidential = TRUE)
	else
		window_flash(recipient, ignorepref = TRUE)
		if(current_ticket)
			log_admin_private("PM: Ticket #[current_ticket.id]: [key_name(src)]->[key_name(recipient)]: [rawmsg]")
		else
			log_admin_private("PM: [key_name(src)]->[key_name(recipient)]: [rawmsg]")
		//we don't use message_admins here because the sender/receiver might get it too
		for(var/client/X in GLOB.admins)
			if(X.key!=key && X.key!=recipient.key) //check client/X is an admin and isn't the sender or recipient
				to_chat(X,
					type = MESSAGE_TYPE_ADMINPM,
					html = span_notice("<B>PM: [key_name(src, X, 0)]-&gt;[key_name(recipient, X, 0)]:</B> [keywordparsedmsg]") ,
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
	GLOB.stealthminID["IRCKEY"] = stealth
	return stealth

#undef EXTERNALREPLYCOUNT
