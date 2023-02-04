#define EXTERNALREPLYCOUNT 2
#define EXTERNAL_PM_USER "IRCKEY"

// HEY FUCKO, IMPORTANT NOTE!
// This file, and pretty much everything that directly handles ahelps, is VERY important
// An admin pm dropping by coding error is disastorus, because it gives no feedback to admins, so they think they're being ignored
// It is imparitive that this does not happen. Therefore, runtimes are not allowed in this file
// Additionally, any runtimes here would cause admin tickets to leak into the runtime logs
// This is less of a big deal, but still bad
//
// In service of this goal of NO RUNTIMES then, we make ABSOLUTELY sure to never trust the nullness of a value
// That's why variables are so separated from logic here. It's not a good pattern typically, but it helps make assumptions clear here
// We also make SURE to fail loud, IE: if something stops the message from reaching the recipient, the sender HAS to know
// If you "refactor" this to make it "cleaner" I will send you to hell

/// Allows the admin to send an AdminPM directly to the client of a mob
ADMIN_CONTEXT_ENTRY(contextcmd_admin_pm, "Admin PM Mob", NONE, mob/target in GLOB.mob_list)
	if(!istype(target))
		to_chat(src, type = MESSAGE_TYPE_ADMINPM, html = span_danger("Error: Admin-PM-Context: Target mob is somehow not a mob!"))
		return

	cmd_admin_pm(target.client, null)

/// Replys to some existing ahelp, reply to whom, which can be a client or ckey
/client/proc/cmd_ahelp_reply(whom)
	if(IsAdminAdvancedProcCall())
		return FALSE

	if(prefs.muted & MUTE_ADMINHELP)
		to_chat(src,
			type = MESSAGE_TYPE_ADMINPM,
			html = span_danger("Error: Admin-PM-Reply: You are unable to use admin PM-s (muted)."),
			confidential = TRUE)
		return

	// We use the ckey here rather then keeping the client to ensure resistance to client logouts mid execution
	if(istype(whom, /client))
		var/client/boi = whom
		whom = boi.ckey

	var/ambiguious_recipient = disambiguate_client(whom)
	if(!istype(ambiguious_recipient, /client))
		if(holder)
			to_chat(src,
				type = MESSAGE_TYPE_ADMINPM,
				html = span_danger("Error: Admin-PM-Reply: Client not found."),
				confidential = TRUE)
		return

	// Existing client case
	var/client/recipient = ambiguious_recipient

	// The ticket our recipient is using
	var/datum/admin_help/recipient_ticket = recipient?.current_ticket
	// Any past interactions with the recipient ticket
	var/datum/admin_help/recipient_interactions = recipient_ticket?.ticket_interactions
	// Any opening interactions with the recipient ticket, IE: interactions started before the ticket first recieves a response
	var/datum/admin_help/opening_interactions = recipient_ticket?.opening_responders
	// Our recipient's admin holder, if one exists
	var/datum/admins/recipient_holder = recipient?.holder
	// The ckey of our recipient
	var/recipient_ckey = recipient?.ckey
	// Our recipient's fake key, if they are faking their ckey
	var/recipient_fake_key = recipient_holder?.fakekey
	// Our ckey, with our mob's name if one exists, formatted with a reply link
	var/our_linked_name = key_name_admin(src)
	// The recipient's ckey, formatted with a reply link
	var/recipient_linked_ckey = key_name_admin(recipient, FALSE)
	// The recipient's ckey, formatted slightly with html
	var/formatted_recipient_ckey = key_name(recipient, FALSE, FALSE)

	var/message_prompt = "Message:"
	if(recipient_ticket)
		message_admins("[our_linked_name] has started replying to [recipient_linked_ckey]'s admin help.")
		// If none's interacted with the ticket yet
		if(length(recipient_interactions) == 1)
			if(length(opening_interactions)) // Inform the admin that they aren't the first
				var/printable_interators = english_list(opening_interactions)
				SEND_SOUND(src, sound('sound/machines/buzz-sigh.ogg', volume=30))
				message_prompt += "\n\n**This ticket is already being responded to by: [printable_interators]**"
			// add the admin who is currently responding to the list of people responding
			LAZYADD(recipient_ticket.opening_responders, src)

	var/request = "Private message to"
	if(recipient_fake_key)
		request = "[request] an Administrator."
	else
		request = "[request] [formatted_recipient_ckey]."

	var/message = input(src, message_prompt, request) as message|null

	if(recipient_ticket)
		LAZYREMOVE(recipient_ticket.opening_responders, src)

	if (!message)
		message_admins("[our_linked_name] has cancelled their reply to [recipient_linked_ckey]'s admin help.")
		return

	if(!recipient) //We lost the client during input, disconnected or relogged.
		if(GLOB.directory[recipient_ckey]) // Client has reconnected, lets try to recover
			whom = GLOB.directory[recipient_ckey]
		else
			to_chat(src,
				type = MESSAGE_TYPE_ADMINPM,
				html = span_danger("Error: Admin-PM-Reply: Client not found."),
				confidential = TRUE)
			to_chat(src,
				type = MESSAGE_TYPE_ADMINPM,
				html = "[span_danger("<b>Message not sent:</b>")]<br>[message]",
				confidential = TRUE)
			if(recipient_ticket)
				recipient_ticket.AddInteraction("<b>No client found, message not sent:</b><br>[message]")
			return
	cmd_admin_pm(whom, message)

//takes input from cmd_admin_pm_context or /client/Topic and sends them a PM.
//Fetching a message if needed.
//whom here is a client, a ckey, or [EXTERNAL_PM_USER] if this is from tgs. message is the default message to send
/client/proc/cmd_admin_pm(whom, message)
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
			html = span_notice("Message: [message]"),
			confidential = TRUE)
		return

	// We use the ckey here rather then keeping the client to ensure resistance to client logouts mid execution
	if(istype(whom, /client))
		var/client/boi = whom
		whom = boi.ckey

	var/message_to_send = request_adminpm_message(disambiguate_client(whom), message)
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
	var/recipient_ckey = recipient?.ckey
	// Stored in case client is deleted between this and after the message is input
	var/datum/admin_help/recipient_ticket = recipient?.current_ticket
	// Our current active ticket
	var/datum/admin_help/our_ticket = current_ticket
	// If our recipient is an admin, this is their admins datum
	var/datum/admins/recipient_holder = recipient?.holder
	// If our recipient has a fake name, this is it
	var/recipient_fake_key = recipient_holder?.fakekey
	// Just the recipient's ckey, formatted for htmlifying stuff
	var/recipient_print_key = key_name(recipient, FALSE, FALSE)

	// The message we intend on returning
	var/msg = ""
	if(existing_message)
		msg = existing_message
	else
		var/request = "Private message to"
		if(recipient_fake_key)
			request = "[request] an Administrator."
		else
			request = "[request] [recipient_print_key]."
		//get message text, limit it's length.and clean/escape html
		msg = input(src,"Message:", request) as message|null
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

	send_message = adminpm_filter_text(ambiguious_recipient, send_message)
	if(!send_message)
		return null

	if (handle_spam_prevention(send_message, MUTE_ADMINHELP))
		// handle_spam_prevention does its own "hey buddy ya fucker up here's what happen"
		return FALSE

	var/raw_message = send_message

	if(holder)
		send_message = emoji_parse(send_message)

	var/keyword_parsed_msg = keywords_lookup(send_message)
	// Stores a bit of html with our ckey, name, and a linkified string to click and rely to us with
	var/name_key_with_link = key_name(src, TRUE, TRUE)

	if(ambiguious_recipient == EXTERNAL_PM_USER)
		var/datum/admin_help/new_admin_help = admin_ticket_log(src,
			"<font color='red'>Reply PM from-<b>[name_key_with_link]</b> to <i>External</i>: [keyword_parsed_msg]</font>",
			player_message = "<font color='red'>Reply PM from-<b>[name_key_with_link]</b> to <i>External</i>: [send_message]</font>")

		new_admin_help.reply_to_admins_notification(raw_message)

		var/new_help_id = new_admin_help?.id

		externalreplyamount--

		var/category = "Reply: [ckey]"
		if(new_admin_help)
			category = "#[new_help_id] [category]"

		send2adminchat(category, raw_message)
		return TRUE

	if(!istype(ambiguious_recipient, /client))
		to_chat(src,
			type = MESSAGE_TYPE_ADMINPM,
			html = span_danger("Error: Admin-PM-Send: Client not found."),
			confidential = TRUE)
		return FALSE

	var/client/recipient = ambiguious_recipient
	var/datum/admins/recipient_holder = recipient.holder
	var/datum/admins/our_holder = holder

	// The sound preferences of the recipient, at least that's how we'll be using it here
	var/sound_prefs = recipient?.prefs?.toggles
	// Stores a bit of html that contains the ckey of the recipient, its mob's name if any exist, and a link to reply to them with
	var/their_name_with_link = key_name(recipient, TRUE, TRUE)
	// Stores a bit of html with our ckey highlighted as a reply link
	var/link_to_us = key_name(src, TRUE, FALSE)
	// Stores a bit of html with outhe ckey of the recipientr highlighted as a reply link
	var/link_to_their = key_name(recipient, TRUE, FALSE)
	// Our ckey
	var/our_ckey = ckey
	// Recipient ckey
	var/recip_ckey = recipient?.ckey
	// Our current ticket, can (supposedly) be null here
	var/datum/admin_help/ticket = current_ticket
	// The recipient's current ticket, could in theory? maybe? be null here
	var/datum/admin_help/recipient_ticket = recipient?.current_ticket
	// I use -1 as a default for both of these
	// Our ticket ID
	var/ticket_id = ticket?.id
	// The recipient's ticket id
	var/recipient_ticket_id = recipient_ticket?.id

	// If we should do a full on boink, so with the text and extra flair and everything
	// We want to always do this so long as WE are an admin, and we're messaging the "loser" of the converstation
	var/full_boink = FALSE
	// Only admins can perform boinks
	if(our_holder)
		full_boink = TRUE
	// Tickets will only generate for the non admin/admin being boinked. This check is to ensure boinked admins don't send the same
	// ADMINISTRAITOR PRIVATE MESSAGE text to their boinker every time they respond
	if(recipient_holder && ticket)
		full_boink = FALSE

	// If we're gonna boink em, do it now
	// It is worth noting this will always generate the target a ticket if they don't already have one (tickets will generate if a player ahelps automatically, outside this logic)
	// So past this point, because of our block above here, we can be reasonably guarenteed that the user will have a ticket
	if(full_boink)
		// Do BIG RED TEXT
		var/already_logged = FALSE
		// Full boinks will always be done to players, so we are not guarenteed that they won't have a ticket
		if(!recipient_ticket)
			new /datum/admin_help(send_message, recipient, TRUE)
			already_logged = TRUE
			// This action mutates our existing cached ticket information, so we recache
			ticket = current_ticket
			recipient_ticket = recipient?.current_ticket
			ticket_id = ticket?.id
			recipient_ticket_id = recipient_ticket?.id
			SSblackbox.LogAhelp(recipient_ticket_id, "Ticket Opened", send_message, recipient.ckey, src.ckey)

		to_chat(recipient,
			type = MESSAGE_TYPE_ADMINPM,
			html = "<font color='red' size='4'><b>-- Administrator private message --</b></font>",
			confidential = TRUE)

		recipient.receive_ahelp(
			link_to_us,
			span_linkify(send_message),
		)

		to_chat(recipient,
			type = MESSAGE_TYPE_ADMINPM,
			html = span_adminsay("<i>Click on the administrator's name to reply.</i>"),
			confidential = TRUE)
		to_chat(src,
			type = MESSAGE_TYPE_ADMINPM,
			html = span_notice("Admin PM to-<b>[their_name_with_link]</b>: [span_linkify(send_message)]"),
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

	// Ok if we're here, either this message is for an admin, or someone somehow figured out how to send a new message as a player
	// First case well, first
	if(!our_holder && !recipient_holder) //neither are admins
		if(!ticket)
			to_chat(src,
				type = MESSAGE_TYPE_ADMINPM,
				html = span_danger("Error: Admin-PM-Send: Non-admin to non-admin PM communication is forbidden."),
				confidential = TRUE)
			to_chat(src,
				type = MESSAGE_TYPE_ADMINPM,
				html = "[span_danger("<b>Message not sent:</b>")]<br>[send_message]",
				confidential = TRUE)
			return FALSE
		ticket.MessageNoRecipient(send_message)
		return TRUE

	// Ok by this point the recipient has to be an admin, and this is either an admin on admin event, or a player replying to an admin

	// You're replying to a ticket that is closed. Bad move. You must have started replying before the close, and then got input()'d
	// Lets be nice and pass this off to a new ticket, as we recomend above
	if(!ticket)
		to_chat(src,
			type = MESSAGE_TYPE_ADMINPM,
			html = span_danger("Error: Admin-PM-Send: Attempted to send a reply to a closed ticket."),
			confidential = TRUE)
		to_chat(src,
			type = MESSAGE_TYPE_ADMINPM,
			html = span_notice("Relaying message to a new admin help."),
			confidential = TRUE)
		GLOB.admin_help_ui_handler.perform_adminhelp(src, raw_message, FALSE)
		return FALSE

	// Let's play some music for the admin, only if they want it tho
	if(sound_prefs & SOUND_ADMINHELP)
		SEND_SOUND(recipient, sound('sound/effects/adminhelp.ogg'))

	SEND_SIGNAL(ticket, COMSIG_ADMIN_HELP_REPLIED)

	// Admin on admin violence first
	if(our_holder)
		recipient.receive_ahelp(
			name_key_with_link,
			span_linkify(keyword_parsed_msg),
			"danger",
		)

		to_chat(src,
			type = MESSAGE_TYPE_ADMINPM,
			html = span_notice("Admin PM to-<b>[their_name_with_link]</b>: [span_linkify(keyword_parsed_msg)]"),
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

	// This is us (a player) trying to talk to the recipient (an admin)
	var/replymsg = "Reply PM from-<b>[name_key_with_link]</b>: [span_linkify(keyword_parsed_msg)]"
	var/player_replymsg = "Reply PM from-<b>[link_to_us]</b>: [span_linkify(send_message)]"
	admin_ticket_log(src,
		"<font color='red'>[replymsg]</font>",
		log_in_blackbox = FALSE,
		player_message = player_replymsg)
	to_chat(recipient,
		type = MESSAGE_TYPE_ADMINPM,
		html = span_danger("[replymsg]"),
		confidential = TRUE)

	ticket.reply_to_admins_notification(send_message)
	SSblackbox.LogAhelp(ticket_id, "Reply", send_message, recip_ckey, our_ckey)

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
	log_message = adminpm_filter_text(ambiguious_recipient, log_message)
	if(!log_message)
		return

	var/raw_message = log_message

	if(holder)
		log_message = emoji_parse(log_message)

	var/keyword_parsed_msg = keywords_lookup(log_message)
	// Shows our ckey and the name of any mob we might be possessing
	var/our_name = key_name(src)
	// Shows our ckey/name embedded inside a clickable link to reply to this message
	var/our_linked_ckey = key_name(src, TRUE, FALSE)
	// Our current active ticket
	var/datum/admin_help/ticket = current_ticket
	// Our current ticket id, if one exists
	var/ticket_id = ticket?.id

	if(ambiguious_recipient == EXTERNAL_PM_USER)
		// Guard against the possibility of a null, since it'll runtime and spit out the contents of what should be a private ticket.
		if(ticket)
			log_admin_private("PM: Ticket #[ticket_id]: [our_name]->External: [sanitize_text(trim(raw_message))]")
		else
			log_admin_private("PM: [our_name]->External: [sanitize_text(trim(raw_message))]")
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
	// The key of our recipient
	var/recipient_key = recipient?.key
	// Shows the recipient's ckey and the name of any mob it might be possessing
	var/recipient_name = key_name(recipient)
	// Shows the recipient's ckey/name embedded inside a clickable link to reply to this message
	var/recipient_linked_ckey = key_name(recipient, TRUE, FALSE)

	window_flash(recipient, ignorepref = TRUE)
	if(ticket)
		log_admin_private("PM: Ticket #[ticket_id]: [our_name]->[recipient_name]: [sanitize_text(trim(raw_message))]")
	else
		log_admin_private("PM: [our_name]->[recipient_name]: [sanitize_text(trim(raw_message))]")
	//we don't use message_admins here because the sender/receiver might get it too
	for(var/client/lad in GLOB.admins)
		if(lad.key == key || lad.key == recipient_key) //check to make sure client/lad isn't the sender or recipient
			continue
		to_chat(lad,
			type = MESSAGE_TYPE_ADMINPM,
			html = span_notice("<B>PM: [our_linked_ckey]-&gt;[recipient_linked_ckey]:</B> [keyword_parsed_msg]") ,
			confidential = TRUE)

/// Accepts a message and an ambiguious recipient (some sort of client representative, or [EXTERNAL_PM_USER])
/// Returns the filtered message if it passes all checks, or null if the send fails
/client/proc/adminpm_filter_text(ambiguious_recipient, message)
	if(prefs.muted & MUTE_ADMINHELP)
		to_chat(src,
			type = MESSAGE_TYPE_ADMINPM,
			html = span_danger("Error: Admin-PM-Filter: You are unable to use admin PM-s (muted)."),
			confidential = TRUE)
		return

	//clean the message if it's not sent by a high-rank admin
	if(!check_rights(R_SERVER|R_DEBUG, 0) || ambiguious_recipient == EXTERNAL_PM_USER)//no sending html to the poor bots
		message = sanitize(copytext_char(message, 1, MAX_MESSAGE_LEN))
		if(!message)
			to_chat(src,
				type = MESSAGE_TYPE_ADMINPM,
				html = span_danger("Error: Admin-PM-Filter: Your message contained only HTML, it's been sanitized away and the message disregarded."),
				confidential = TRUE)
			return
	return message

#define TGS_AHELP_USAGE "Usage: ticket <close|resolve|icissue|reject|reopen \[ticket #\]|list>"
/proc/TgsPm(target, message, sender)
	var/requested_ckey = ckey(target)
	var/ambiguious_target = disambiguate_client(requested_ckey)

	var/client/recipient
	// This might seem like hiding a failure condition, but we want to be able to send commands to the ticket without the client being logged in
	if(istype(ambiguious_target, /client))
		recipient = ambiguious_target

	// The ticket we want to talk about here. Either the target's active ticket, or the last one it had
	var/datum/admin_help/ticket
	if(recipient)
		ticket = recipient.current_ticket
	else
		GLOB.ahelp_tickets.CKey2ActiveTicket(requested_ckey)
	// The ticket's id
	var/ticket_id = ticket?.id

	var/compliant_msg = trim(lowertext(message))
	var/tgs_tagged = "[sender](TGS/External)"
	var/list/splits = splittext(compliant_msg, " ")
	var/split_size = length(splits)

	if(split_size && splits[1] == "ticket")
		if(split_size < 2)
			return TGS_AHELP_USAGE
		switch(splits[2])
			if("close")
				if(ticket)
					ticket.Close(tgs_tagged)
					return "Ticket #[ticket_id] successfully closed"
			if("resolve")
				if(ticket)
					ticket.Resolve(tgs_tagged)
					return "Ticket #[ticket_id] successfully resolved"
			if("icissue")
				if(ticket)
					ticket.ICIssue(tgs_tagged)
					return "Ticket #[ticket_id] successfully marked as IC issue"
			if("reject")
				if(ticket)
					ticket.Reject(tgs_tagged)
					return "Ticket #[ticket_id] successfully rejected"
			if("reopen")
				if(ticket)
					return "Error: [target] already has ticket #[ticket_id] open"
				var/ticket_num
				// If the passed in command actually has a ticket id arg
				if(split_size >= 3)
					ticket_num = text2num(splits[3])

				if(isnull(ticket_num))
					return "Error: No/Invalid ticket id specified. [TGS_AHELP_USAGE]"

				// The active ticket we're trying to reopen, if one exists
				var/datum/admin_help/active_ticket = GLOB.ahelp_tickets.TicketByID(ticket_num)
				// The ckey of the player to be targeted BY the ticket
				// Not the initiator all the time
				var/boinked_ckey = active_ticket?.initiator_ckey

				if(!active_ticket)
					return "Error: Ticket #[ticket_num] not found"
				if(boinked_ckey != target)
					return "Error: Ticket #[ticket_num] belongs to [boinked_ckey]"

				active_ticket.Reopen()
				return "Ticket #[ticket_num] successfully reopened"
			if("list")
				var/list/tickets = GLOB.ahelp_tickets.TicketsByCKey(target)
				var/tickets_length = length(tickets)

				if(!tickets_length)
					return "None"
				var/list/printable_tickets = list()
				for(var/datum/admin_help/iterated_ticket in tickets)
					// The id of the iterated adminhelp
					var/iterated_id = iterated_ticket?.id
					var/text = ""
					if(iterated_ticket == ticket)
						text += "Active: "
					text += "#[iterated_id]"
					printable_tickets += text
				return printable_tickets.Join(", ")
			else
				return TGS_AHELP_USAGE
		return "Error: Ticket could not be found"

	// Now that we've handled command processing, we can actually send messages to the client
	if(!recipient)
		return "Error: No client"

	var/adminname
	if(CONFIG_GET(flag/show_irc_name))
		adminname = tgs_tagged
	else
		adminname = "Administrator"

	var/stealthkey = GetTgsStealthKey()

	message = sanitize(copytext_char(message, 1, MAX_MESSAGE_LEN))
	message = emoji_parse(message)

	if(!message)
		return "Error: No message"

	// The ckey of our recipient, with a reply link, and their mob if one exists
	var/recipient_name_linked = key_name_admin(recipient)
	// The ckey of our recipient, with their mob if one exists. No link
	var/recipient_name = key_name_admin(recipient)

	message_admins("External message from [sender] to [recipient_name_linked] : [message]")
	log_admin_private("External PM: [sender] -> [recipient_name] : [message]")

	to_chat(recipient,
		type = MESSAGE_TYPE_ADMINPM,
		html = "<font color='red' size='4'><b>-- Administrator private message --</b></font>",
		confidential = TRUE)

	recipient.receive_ahelp(
		"<a href='?priv_msg=[stealthkey]'>[adminname]</a>",
		message,
	)

	to_chat(recipient,
		type = MESSAGE_TYPE_ADMINPM,
		html = span_adminsay("<i>Click on the administrator's name to reply.</i>"),
		confidential = TRUE)

	admin_ticket_log(recipient, "<font color='purple'>PM From [tgs_tagged]: [message]</font>", log_in_blackbox = FALSE)

	window_flash(recipient, ignorepref = TRUE)
	// Nullcheck because we run a winset in window flash and I do not trust byond
	if(recipient)
		//always play non-admin recipients the adminhelp sound
		SEND_SOUND(recipient, 'sound/effects/adminhelp.ogg')

		recipient.externalreplyamount = EXTERNALREPLYCOUNT
	return "Message Successful"

/// Gets TGS's stealth key, generates one if none is found
/proc/GetTgsStealthKey()
	var/static/tgsStealthKey
	if(tgsStealthKey)
		return tgsStealthKey

	tgsStealthKey = generateStealthCkey()
	GLOB.stealthminID[EXTERNAL_PM_USER] = tgsStealthKey
	return tgsStealthKey

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

/client/proc/receive_ahelp(reply_to, message, span_class = "adminsay")
	to_chat(
		src,
		type = MESSAGE_TYPE_ADMINPM,
		html = "<span class='[span_class]'>Admin PM from-<b>[reply_to]</b>: [message]</span>",
		confidential = TRUE,
	)

	current_ticket?.player_replied = FALSE

	SEND_SIGNAL(src, COMSIG_ADMIN_HELP_RECEIVED, message)

#undef EXTERNAL_PM_USER
#undef EXTERNALREPLYCOUNT
