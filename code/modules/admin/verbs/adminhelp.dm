/proc/keywords_lookup(msg,irc)

	//This is a list of words which are ignored by the parser when comparing message contents for names. MUST BE IN LOWER CASE!
	var/list/adminhelp_ignored_words = list("unknown","the","a","an","of","monkey","alien","as", "i")

	//explode the input msg into a list
	var/list/msglist = splittext(msg, " ")

	//generate keywords lookup
	var/list/surnames = list()
	var/list/forenames = list()
	var/list/ckeys = list()
	var/founds = ""
	for(var/mob/M in GLOB.mob_list)
		var/list/indexing = list(M.real_name, M.name)
		if(M.mind)
			indexing += M.mind.name

		for(var/string in indexing)
			var/list/L = splittext(string, " ")
			var/surname_found = 0
			//surnames
			for(var/i=L.len, i>=1, i--)
				var/word = ckey(L[i])
				if(word)
					surnames[word] = M
					surname_found = i
					break
			//forenames
			for(var/i=1, i<surname_found, i++)
				var/word = ckey(L[i])
				if(word)
					forenames[word] = M
			//ckeys
			ckeys[M.ckey] = M

	var/ai_found = 0
	msg = ""
	var/list/mobs_found = list()
	for(var/original_word in msglist)
		var/word = ckey(original_word)
		if(word)
			if(!(word in adminhelp_ignored_words))
				if(word == "ai")
					ai_found = 1
				else
					var/mob/found = ckeys[word]
					if(!found)
						found = surnames[word]
						if(!found)
							found = forenames[word]
					if(found)
						if(!(found in mobs_found))
							mobs_found += found
							if(!ai_found && isAI(found))
								ai_found = 1
							var/is_antag = 0
							if(found.mind && found.mind.special_role)
								is_antag = 1
							founds += "Name: [found.name]([found.real_name]) Ckey: [found.ckey] [is_antag ? "(Antag)" : null] "
							msg += "[original_word]<font size='1' color='[is_antag ? "red" : "black"]'>(<A HREF='?_src_=holder;adminmoreinfo=\ref[found]'>?</A>|<A HREF='?_src_=holder;adminplayerobservefollow=\ref[found]'>F</A>)</font> "
							continue
		msg += "[original_word] "
	if(irc)
		if(founds == "")
			return "Search Failed"
		else
			return founds

	return msg


/client/var/adminhelptimerid = 0
/client/var/datum/admin_help/current_ticket

GLOBAL_DATUM_INIT(ahelp_tickets, /datum/admin_help_tickets, new)

/datum/admin_help_tickets
	var/list/active_tickets = list()
	var/list/closed_tickets = list()
	var/list/resolved_tickets = list()

	var/obj/effect/statclick/ticket_list/astatclick = new(null, null, AHELP_ACTIVE)
	var/obj/effect/statclick/ticket_list/cstatclick = new(null, null, AHELP_CLOSED)
	var/obj/effect/statclick/ticket_list/rstatclick = new(null, null, AHELP_RESOLVED)

/datum/admin_help_tickets/proc/BrowseTickets(state)
	var/list/l2b
	var/title
	switch(state)
		if(AHELP_ACTIVE)
			l2b = active_tickets
			title = "Active Tickets"
		if(AHELP_CLOSED)
			l2b = closed_tickets
			title = "Closed Tickets"
		if(AHELP_RESOLVED)
			l2b = resolved_tickets
			title = "Resolved Tickets"
	if(!l2b)
		return
	var/list/dat = list()
	for(var/I in l2b)
		var/datum/admin_help/AH = I
		dat += "<span class='adminnotice'><b><font color=red>Ticket #[AH.id]</font>: <A HREF='?_src_=holder;ahelp=\ref[AH];ahelp_action=ticket'>[key_name(AH.initiator)]: [AH.original_message]</A></span>"
		
	var/datum/browser/popup = new(usr, "ahelp_list[state]", title, 600, 480)
	popup.set_content(dat.Join())
	popup.open()

/datum/admin_help_tickets/Destroy()
	for(var/I in active_tickets)
		qdel(I)
	for(var/I in closed_tickets)
		qdel(I)
	for(var/I in resolved_tickets)
		qdel(I)
	QDEL_NULL(astatclick)
	QDEL_NULL(cstatclick)
	QDEL_NULL(rstatclick)
	return ..()

/datum/admin_help_tickets/proc/stat_entry()
	stat("Active Tickets:", astatclick.update("[active_tickets.len]"))
	for(var/I in active_tickets)
		var/datum/admin_help/AH = I
		stat("Ticket #[AH.id]:", AH.statclick)
	stat("Closed Tickets:", cstatclick.update("[closed_tickets.len]"))
	stat("Resolved Tickets:", rstatclick.update("[resolved_tickets.len]"))

/obj/effect/statclick/ticket_list
	var/current_state

/obj/effect/statclick/ticket_list/New(loc, name, state)
	current_state = state
	..()

/obj/effect/statclick/ticket_list/Click()
	GLOB.ahelp_tickets.BrowseTickets(current_state)

/datum/admin_help
	var/id
	var/state = AHELP_ACTIVE

	var/opened_at
	var/closed_at

	var/client/initiator
	var/initiator_key_name

	var/original_message
	var/parsed_message

	var/list/interactions

	var/obj/effect/statclick/ahelp/statclick

	var/static/ticket_counter = 0

/datum/admin_help/New(msg, client/C)
	//clean the input msg
	msg = sanitize(copytext(msg,1,MAX_MESSAGE_LEN))
	if(!msg || !C.mob)
		qdel(src)
		return

	id = ++ticket_counter
	opened_at = world.time

	original_message = msg

	//remove our adminhelp verb temporarily to prevent spamming of admins.
	initiator = C
	initiator_key_name = key_name_admin(initiator)
	initiator.current_ticket = src
	initiator.verbs -= /client/verb/adminhelp
	initiator.adminhelptimerid = addtimer(CALLBACK(initiator, /client/proc/giveadminhelpverb), 1200, TIMER_STOPPABLE) //2 minute cooldown of admin helps

	parsed_message = keywords_lookup(msg)
	interactions = list("<font color='red'>[LinkedReplyName()]: [parsed_message]</font>")

	statclick = new(null, src)

	MessageNoRecipient(parsed_message)

	//show it to the person adminhelping too
	to_chat(C, "<span class='adminnotice'>PM to-<b>Admins</b>: [original_message]</span>")

	//send it to irc if nobody is on and tell us how many were on
	var/admin_number_present = send2irc_adminless_only(initiator.ckey,original_message)
	log_admin_private("HELP: [key_name(initiator)]: [original_message] - heard by [admin_number_present] non-AFK admins who have +BAN.")
	if(admin_number_present <= 0)
		to_chat(C, "<span class='notice'>No active admins are online, your adminhelp was sent to the admin irc.</span>")

	GLOB.ahelp_tickets.active_tickets += src

/datum/admin_help/proc/FullMonty(ref_src)
	if(!ref_src)
		ref_src = "\ref[src]"
	. = ADMIN_FULLMONTY_NONAME(initiator.mob)
	if(state == AHELP_ACTIVE)
		. += " (<A HREF='?_src_=holder;ahelp=[ref_src];ahelp_action=reject'>REJT</A>)"
		. += " (<A HREF='?_src_=holder;ahelp=[ref_src];ahelp_action=icissue'>IC</A>) (<A HREF='?_src_=holder;ahelp=[ref_src];ahelp_action=close'>CLOSE</A>)"
		. += " (<A HREF='?_src_=holder;ahelp=[ref_src];ahelp_action=resolve'>RSLVE</A>)"

/datum/admin_help/proc/LinkedReplyName(ref_src)
	if(!ref_src)
		ref_src = "\ref[src]"
	return "</font><A HREF='?_src_=holder;ahelp=[ref_src];ahelp_action=reply'>[initiator_key_name]</A>"

/datum/admin_help/proc/TicketHref(msg, ref_src)
	if(!ref_src)
		ref_src = "\ref[src]"
	return "<A HREF='?_src_=holder;ahelp=[ref_src];ahelp_action=ticket'>[msg]</A>"

//message from the initiator without a target
/datum/admin_help/proc/MessageNoRecipient(msg)
	var/ref_src = "\ref[src]"
	var/chat_msg = "<span class='adminnotice'><b><font color=red>Ticket [TicketHref("#[id]", ref_src)]: [LinkedReplyName(ref_src)] [FullMonty(ref_src)] :</b> [parsed_message]</span>"

	//send this msg to all admins

	for(var/client/X in GLOB.admins)
		if(X.prefs.toggles & SOUND_ADMINHELP)
			X << 'sound/effects/adminhelp.ogg'
		window_flash(X, ignorepref = TRUE)
		to_chat(X, chat_msg)

/datum/admin_help/Destroy()
	RemoveActive()
	GLOB.ahelp_tickets.closed_tickets -= src
	GLOB.ahelp_tickets.resolved_tickets -= src
	return ..()

/datum/admin_help/proc/RemoveActive()
	closed_at = world.time
	QDEL_NULL(statclick)
	GLOB.ahelp_tickets.active_tickets -= src
	if(initiator && initiator.current_ticket == src)
		initiator.current_ticket = null

/datum/admin_help/proc/Close()
	if(state != AHELP_ACTIVE)
		return
	RemoveActive()
	GLOB.ahelp_tickets.closed_tickets += src
	state = AHELP_CLOSED
	interactions += "Closed by [key_name_admin(usr)]."
	message_admins("Ticket #[id] closed by [key_name(usr)]")
	log_admin_private("Ticket #[id] closed by [key_name_admin(usr)].")

/datum/admin_help/proc/Resolve()
	if(state != AHELP_ACTIVE)
		return
	RemoveActive()
	GLOB.ahelp_tickets.resolved_tickets += src
	
	if(initiator)
		initiator.giveadminhelpverb()	//only practical difference between resolved and closed

	state = AHELP_RESOLVED
	interactions += "Resolved by [key_name_admin(usr)]."
	message_admins("Ticket #[id] resolved by [key_name_admin(usr)]")
	log_admin_private("Ticket #[id] resolved by [key_name(usr)].")

/datum/admin_help/proc/TicketPanel()
	var/list/dat = list("<h3>Admin Help Ticket #[id]: [LinkedReplyName()]</h3>")
	if(initiator)
		dat += "<b>Actions:</b> [FullMonty()]<br>"
	else
		dat += "<b>DISCONNECTED</b>"
	dat += "<br>[TicketHref("Refresh")]<br>"
	dat += "<br><b>Log:</b><br><br>"
	for(var/I in interactions)
		dat += "[I]<br>"

	var/datum/browser/popup = new(usr, "ahelp[id]", "Ticket #[id]", 600, 480)
	popup.set_content(dat.Join())
	popup.open()

/datum/admin_help/proc/Reject()
	var/cd = usr.client.holder.spamcooldown
	if(world.time && cd > world.time)
		to_chat(usr, "Please wait [max(round((cd - world.time)*0.1, 0.1), 0)] seconds.")
		return
	
	if(!initiator)
		return

	initiator.giveadminhelpverb()

	initiator << 'sound/effects/adminhelp.ogg'

	to_chat(initiator, "<font color='red' size='4'><b>- AdminHelp Rejected! -</b></font>")
	to_chat(initiator, "<font color='red'><b>Your admin help was rejected.</b> The adminhelp verb has been returned to you so that you may try again.</font>")
	to_chat(initiator, "Please try to be calm, clear, and descriptive in admin helps, do not assume the admin has seen any related events, and clearly state the names of anybody you are reporting.")

	message_admins("[key_name_admin(usr)] Rejected [initiator.key]'s admin help. [initiator.key]'s Adminhelp verb has been returned to them.")
	log_admin_private("[key_name(usr)] Rejected [initiator.key]'s admin help.")
	usr.client.holder.spamcooldown = world.time + 150 // 15 seconds
	interactions += "Rejected by [key_name_admin(usr)]."
	Close()

/datum/admin_help/proc/ICIssue()
	var/cd = usr.client.holder.spamcooldown
	if(world.time && cd > world.time)
		to_chat(usr, "Please wait [max(round((cd - world.time)*0.1, 0.1), 0)] seconds.")
		return

	var/msg = "<font color='red' size='4'><b>- AdminHelp marked as IC issue! -</b></font><br>"
	msg += "<font color='red'><b>Losing is part of the game!</b></font><br>"
	msg += "<font color='red'>Your character will frequently die, sometimes without even a possibility of avoiding it. Events will often be out of your control. No matter how good or prepared you are, sometimes you just lose.</font>"

	to_chat(initiator, msg)

	message_admins("[key_name_admin(usr)] marked [initiator.key]'s admin help as an IC issue.")
	interactions += "Marked as IC issue by [key_name_admin(usr)]"
	log_admin_private("[key_name(usr)] marked [initiator.key]'s admin help as an IC issue.")
	usr.client.holder.spamcooldown = world.time + 150 // 15 seconds

/datum/admin_help/proc/Action(action)
	testing("Ahelp action: [action]")
	switch(action)
		if("ticket")
			TicketPanel()
		if("reject")
			Reject()
		if("reply")
			usr.client.cmd_ahelp_reply(initiator)
		if("icissue")
			ICIssue()
		if("close")
			Close()
		if("resolve")
			Resolve()

/obj/effect/statclick/ahelp
	var/datum/admin_help/ahelp_datum

/obj/effect/statclick/ahelp/New(loc, datum/admin_help/AH)
	ahelp_datum = AH
	..(loc, AH.interactions[1])

/obj/effect/statclick/ahelp/Click()
	ahelp_datum.TicketPanel()

/obj/effect/statclick/ahelp/Destroy()
	ahelp_datum = null
	return ..()

/client/proc/giveadminhelpverb()
	src.verbs |= /client/verb/adminhelp
	deltimer(adminhelptimerid)
	adminhelptimerid = 0

/client/verb/adminhelp(msg as text)
	set category = "Admin"
	set name = "Adminhelp"

	if(GLOB.say_disabled)	//This is here to try to identify lag problems
		to_chat(usr, "<span class='danger'>Speech is currently admin-disabled.</span>")
		return

	//handle muting and automuting
	if(prefs.muted & MUTE_ADMINHELP)
		to_chat(src, "<span class='danger'>Error: Admin-PM: You cannot send adminhelps (Muted).</span>")
		return
	if(handle_spam_prevention(msg,MUTE_ADMINHELP))
		return

	if(!msg)
		return

	feedback_add_details("admin_verb","AH") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	if(current_ticket)
		if(alert(usr, "You already have a ticket open. Is this for the same issue?",,"Yes","No") != "Yes")
			current_ticket.MessageNoRecipient(msg)
			return
		current_ticket.interactions += "[key_name_admin(usr)] opened a new ticket."
		current_ticket.Close()

	new /datum/admin_help(msg, src)

/proc/get_admin_counts(requiredflags = R_BAN)
	. = list("total" = list(), "noflags" = list(), "afk" = list(), "stealth" = list(), "present" = list())
	for(var/client/X in GLOB.admins)
		.["total"] += X
		if(requiredflags != 0 && !check_rights_for(X, requiredflags))
			.["noflags"] += X
		else if(X.is_afk())
			.["afk"] += X
		else if(X.holder.fakekey)
			.["stealth"] += X
		else
			.["present"] += X

/proc/send2irc_adminless_only(source, msg, requiredflags = R_BAN)
	var/list/adm = get_admin_counts(requiredflags)
	var/list/activemins = adm["present"]
	. = activemins.len
	if(. <= 0)
		var/final = ""
		var/list/afkmins = adm["afk"]
		var/list/stealthmins = adm["stealth"]
		var/list/powerlessmins = adm["noflags"]
		var/list/allmins = adm["total"]
		if(!afkmins.len && !stealthmins.len && !powerlessmins.len)
			final = "[msg] - No admins online"
		else
			final = "[msg] - All admins stealthed\[[english_list(stealthmins)]\], AFK\[[english_list(afkmins)]\], or lacks +BAN\[[english_list(powerlessmins)]\]! Total: [allmins.len] "
		send2irc(source,final)
		send2otherserver(source,final)


/proc/send2irc(msg,msg2)
	if(config.useircbot)
		shell("python nudge.py [msg] [msg2]")
	return

/proc/send2otherserver(source,msg,type = "Ahelp")
	if(config.cross_allowed)
		var/list/message = list()
		message["message_sender"] = source
		message["message"] = msg
		message["source"] = "([config.cross_name])"
		message["key"] = GLOB.comms_key
		message["crossmessage"] = type

		world.Export("[config.cross_address]?[list2params(message)]")


/proc/ircadminwho()
	var/list/message = list("Admins: ")
	var/list/admin_keys = list()
	for(var/adm in GLOB.admins)
		var/client/C = adm
		admin_keys += "[C][C.holder.fakekey ? "(Stealth)" : ""][C.is_afk() ? "(AFK)" : ""]"

	for(var/admin in admin_keys)
		if(LAZYLEN(admin_keys) > 1)
			message += ", [admin]"
		else
			message += "[admin]"

	return jointext(message, "")

/proc/admin_ticket_log(what, message)
	var/client/C = what
	var/mob/Mob = what
	if(istype(Mob))
		C = Mob.client
	if(istype(C) && C.current_ticket)
		C.current_ticket.interactions += message
		