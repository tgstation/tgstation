#define IRCREPLYCOUNT 2


//allows right clicking mobs to send an admin PM to their client, forwards the selected mob's client to cmd_admin_pm
/client/proc/cmd_admin_pm_context(mob/M in GLOB.mob_list)
	set category = null
	set name = "Admin PM Mob"
	if(!holder)
		to_chat(src, "<font color='red'>Error: Admin-PM-Context: Only administrators may use this command.</font>")
		return
	if( !ismob(M) || !M.client )
		return
	cmd_admin_pm(M.client,null)
	SSblackbox.add_details("admin_verb","Admin PM Mob") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

//shows a list of clients we could send PMs to, then forwards our choice to cmd_admin_pm
/client/proc/cmd_admin_pm_panel()
	set category = "Admin"
	set name = "Admin PM"
	if(!holder)
		to_chat(src, "<font color='red'>Error: Admin-PM-Panel: Only administrators may use this command.</font>")
		return
	var/list/client/targets[0]
	for(var/client/T)
		if(T.mob)
			if(isnewplayer(T.mob))
				targets["(New Player) - [T]"] = T
			else if(isobserver(T.mob))
				targets["[T.mob.name](Ghost) - [T]"] = T
			else
				targets["[T.mob.real_name](as [T.mob.name]) - [T]"] = T
		else
			targets["(No Mob) - [T]"] = T
	var/target = input(src,"To whom shall we send a message?","Admin PM",null) as null|anything in sortList(targets)
	cmd_admin_pm(targets[target],null)
	SSblackbox.add_details("admin_verb","Admin PM") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_ahelp_reply(whom)
	if(prefs.muted & MUTE_ADMINHELP)
		to_chat(src, "<font color='red'>Error: Admin-PM: You are unable to use admin PM-s (muted).</font>")
		return
	var/client/C
	if(istext(whom))
		if(cmptext(copytext(whom,1,2),"@"))
			whom = findStealthKey(whom)
		C = GLOB.directory[whom]
	else if(istype(whom,/client))
		C = whom
	if(!C)
		if(holder)
			to_chat(src, "<font color='red'>Error: Admin-PM: Client not found.</font>")
		return
	
	var/datum/admin_help/AH = C.current_ticket

	if(AH)
		message_admins("[key_name_admin(src)] has started replying to [key_name(C, 0, 0)]'s admin help.")
	var/msg = input(src,"Message:", "Private message to [key_name(C, 0, 0)]") as text|null
	if (!msg)
		message_admins("[key_name_admin(src)] has cancelled their reply to [key_name(C, 0, 0)]'s admin help.")
		return
	cmd_admin_pm(whom, msg)

//takes input from cmd_admin_pm_context, cmd_admin_pm_panel or /client/Topic and sends them a PM.
//Fetching a message if needed. src is the sender and C is the target client
/client/proc/cmd_admin_pm(whom, msg)
	if(prefs.muted & MUTE_ADMINHELP)
		to_chat(src, "<font color='red'>Error: Admin-PM: You are unable to use admin PM-s (muted).</font>")
		return

	if(!holder && !current_ticket)	//no ticket? https://www.youtube.com/watch?v=iHSPf6x1Fdo
		to_chat(src, "<font color='red'>You can no longer reply to this ticket, please open another one by using the Adminhelp verb if need be.</font>")
		to_chat(src, "<font color='blue'>Message: [msg]</font>")
		return

	var/client/recipient
	var/irc = 0
	if(istext(whom))
		if(cmptext(copytext(whom,1,2),"@"))
			whom = findStealthKey(whom)
		if(whom == "IRCKEY")
			irc = 1
		else
			recipient = GLOB.directory[whom]
	else if(istype(whom,/client))
		recipient = whom
	

	if(irc)
		if(!ircreplyamount)	//to prevent people from spamming irc
			return
		if(!msg)
			msg = input(src,"Message:", "Private message to Administrator") as text|null

		if(!msg)
			return
		if(holder)
			to_chat(src, "<font color='red'>Error: Use the admin IRC channel, nerd.</font>")
			return


	else
		if(!recipient)
			if(holder)
				to_chat(src, "<font color='red'>Error: Admin-PM: Client not found.</font>")
				to_chat(src, msg)
			else
				current_ticket.MessageNoRecipient(msg)
			return

		//get message text, limit it's length.and clean/escape html
		if(!msg)
			msg = input(src,"Message:", "Private message to [key_name(recipient, 0, 0)]") as text|null

			if(!msg)
				return

			if(prefs.muted & MUTE_ADMINHELP)
				to_chat(src, "<font color='red'>Error: Admin-PM: You are unable to use admin PM-s (muted).</font>")
				return

			if(!recipient)
				if(holder)
					to_chat(src, "<font color='red'>Error: Admin-PM: Client not found.</font>")
				else
					current_ticket.MessageNoRecipient(msg)
				return

	if (src.handle_spam_prevention(msg,MUTE_ADMINHELP))
		return

	//clean the message if it's not sent by a high-rank admin
	if(!check_rights(R_SERVER|R_DEBUG,0)||irc)//no sending html to the poor bots
		msg = sanitize(copytext(msg,1,MAX_MESSAGE_LEN))
		if(!msg)
			return

	var/rawmsg = msg

	if(holder)
		msg = emoji_parse(msg)

	var/keywordparsedmsg = keywords_lookup(msg)

	if(irc)
		to_chat(src, "<font color='blue'>PM to-<b>Admins</b>: [rawmsg]</font>")
		var/datum/admin_help/AH = admin_ticket_log(src, "<font color='red'>Reply PM from-<b>[key_name(src, TRUE, TRUE)] to <i>IRC</i>: [keywordparsedmsg]</font>")
		ircreplyamount--
		send2irc("[AH ? "#[AH.id] " : ""]Reply: [ckey]", rawmsg)
	else
		if(recipient.holder)
			if(holder)	//both are admins
				to_chat(recipient, "<font color='red'>Admin PM from-<b>[key_name(src, recipient, 1)]</b>: [keywordparsedmsg]</font>")
				to_chat(src, "<font color='blue'>Admin PM to-<b>[key_name(recipient, src, 1)]</b>: [keywordparsedmsg]</font>")

				//omg this is dumb, just fill in both their tickets
				var/interaction_message = "<font color='purple'>PM from-<b>[key_name(src, recipient, 1)]</b> to-<b>[key_name(recipient, src, 1)]</b>: [keywordparsedmsg]</font>"
				admin_ticket_log(src, interaction_message)
				if(recipient != src)	//reeee
					admin_ticket_log(recipient, interaction_message)

			else		//recipient is an admin but sender is not
				var/replymsg = "<font color='red'>Reply PM from-<b>[key_name(src, recipient, 1)]</b>: [keywordparsedmsg]</font>"
				admin_ticket_log(src, replymsg)
				to_chat(recipient, replymsg)
				to_chat(src, "<font color='blue'>PM to-<b>Admins</b>: [msg]</font>")

			//play the recieving admin the adminhelp sound (if they have them enabled)
			if(recipient.prefs.toggles & SOUND_ADMINHELP)
				recipient << 'sound/effects/adminhelp.ogg'

		else
			if(holder)	//sender is an admin but recipient is not. Do BIG RED TEXT
				if(!recipient.current_ticket)
					new /datum/admin_help(msg, recipient, TRUE)

				to_chat(recipient, "<font color='red' size='4'><b>-- Administrator private message --</b></font>")
				to_chat(recipient, "<font color='red'>Admin PM from-<b>[key_name(src, recipient, 0)]</b>: [msg]</font>")
				to_chat(recipient, "<font color='red'><i>Click on the administrator's name to reply.</i></font>")
				to_chat(src, "<font color='blue'>Admin PM to-<b>[key_name(recipient, src, 1)]</b>: [msg]</font>")

				admin_ticket_log(recipient, "<font color='blue'>PM From [key_name_admin(src)]: [keywordparsedmsg]</font>")

				//always play non-admin recipients the adminhelp sound
				recipient << 'sound/effects/adminhelp.ogg'

				//AdminPM popup for ApocStation and anybody else who wants to use it. Set it with POPUP_ADMIN_PM in config.txt ~Carn
				if(config.popup_admin_pm)
					spawn()	//so we don't hold the caller proc up
						var/sender = src
						var/sendername = key
						var/reply = input(recipient, msg,"Admin PM from-[sendername]", "") as text|null		//show message and await a reply
						if(recipient && reply)
							if(sender)
								recipient.cmd_admin_pm(sender,reply)										//sender is still about, let's reply to them
							else
								adminhelp(reply)													//sender has left, adminhelp instead
						return

			else		//neither are admins
				to_chat(src, "<font color='red'>Error: Admin-PM: Non-admin to non-admin PM communication is forbidden.</font>")
				return

	if(irc)
		log_admin_private("PM: [key_name(src)]->IRC: [rawmsg]")
		for(var/client/X in GLOB.admins)
			to_chat(X, "<font color='blue'><B>PM: [key_name(src, X, 0)]-&gt;IRC:</B> [keywordparsedmsg]</font>")
	else
		window_flash(recipient, ignorepref = TRUE)
		log_admin_private("PM: [key_name(src)]->[key_name(recipient)]: [rawmsg]")
		//we don't use message_admins here because the sender/receiver might get it too
		for(var/client/X in GLOB.admins)
			if(X.key!=key && X.key!=recipient.key)	//check client/X is an admin and isn't the sender or recipient
				to_chat(X, "<font color='blue'><B>PM: [key_name(src, X, 0)]-&gt;[key_name(recipient, X, 0)]:</B> [keywordparsedmsg]</font>" )



#define IRC_AHELP_USAGE "Usage: ticket <close|resolve|icissue|reject|reopen \[ticket #\]|list>"
/proc/IrcPm(target,msg,sender)
	target = ckey(target)
	var/client/C = GLOB.directory[target]

	var/datum/admin_help/ticket = C ? C.current_ticket : GLOB.ahelp_tickets.CKey2ActiveTicket(target)
	var/compliant_msg = trim(lowertext(msg))
	var/irc_tagged = "[sender](IRC)"
	var/list/splits = splittext(compliant_msg, " ")
	if(splits.len && splits[1] == "ticket")
		if(splits.len < 2)
			return IRC_AHELP_USAGE
		switch(splits[2])
			if("close")
				if(ticket)
					ticket.Close(irc_tagged)
					return "Ticket #[ticket.id] successfully closed"
			if("resolve")
				if(ticket)
					ticket.Resolve(irc_tagged)
					return "Ticket #[ticket.id] successfully resolved"
			if("icissue")
				if(ticket)
					ticket.ICIssue(irc_tagged)
					return "Ticket #[ticket.id] successfully marked as IC issue"
			if("reject")
				if(ticket)
					ticket.Reject(irc_tagged)
					return "Ticket #[ticket.id] successfully rejected"
			if("reopen")
				if(ticket)
					return "Error: [target] already has ticket #[ticket.id] open"
				var/fail = splits.len < 3 ? null : -1
				if(!isnull(fail))
					fail = text2num(splits[3])
				if(isnull(fail))
					return "Error: No/Invalid ticket id specified. [IRC_AHELP_USAGE]"
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
				return IRC_AHELP_USAGE
		return "Error: Ticket could not be found"

	var/static/stealthkey
	var/adminname = config.showircname ? irc_tagged : "Administrator"

	if(!C)
		return "Error: No client"

	if(!stealthkey)
		stealthkey = GenIrcStealthKey()

	msg = sanitize(copytext(msg,1,MAX_MESSAGE_LEN))
	if(!msg)
		return "Error: No message"

	message_admins("IRC message from [sender] to [key_name_admin(C)] : [msg]")
	log_admin_private("IRC PM: [sender] -> [key_name(C)] : [msg]")
	msg = emoji_parse(msg)

	to_chat(C, "<font color='red' size='4'><b>-- Administrator private message --</b></font>")
	to_chat(C, "<font color='red'>Admin PM from-<b><a href='?priv_msg=[stealthkey]'>[adminname]</A></b>: [msg]</font>")
	to_chat(C, "<font color='red'><i>Click on the administrator's name to reply.</i></font>")

	admin_ticket_log(C, "<font color='blue'>PM From [irc_tagged]: [msg]</font>")

	window_flash(C, ignorepref = TRUE)
	//always play non-admin recipients the adminhelp sound
	C << 'sound/effects/adminhelp.ogg'

	C.ircreplyamount = IRCREPLYCOUNT

	return "Message Successful"

/proc/GenIrcStealthKey()
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
	return	stealth

#undef IRCREPLYCOUNT
