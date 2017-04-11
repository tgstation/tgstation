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

/client/proc/giveadminhelpverb()
	src.verbs |= /client/verb/adminhelp
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
	if(src.handle_spam_prevention(msg,MUTE_ADMINHELP))
		return

	//clean the input msg
	if(!msg)
		return
	msg = sanitize(copytext(msg,1,MAX_MESSAGE_LEN))
	if(!msg)	return
	var/original_msg = msg

	//remove our adminhelp verb temporarily to prevent spamming of admins.
	src.verbs -= /client/verb/adminhelp
	adminhelptimerid = addtimer(CALLBACK(src, .proc/giveadminhelpverb), 1200, TIMER_STOPPABLE) //2 minute cooldown of admin helps

	msg = keywords_lookup(msg)

	if(!mob)
		return						//this doesn't happen

	var/ref_client = "\ref[src]"
	msg = "<span class='adminnotice'><b><font color=red>HELP: </font><A HREF='?priv_msg=[ckey];ahelp_reply=1'>[key_name(src)]</A> [ADMIN_FULLMONTY_NONAME(mob)] [ADMIN_SMITE(mob)] (<A HREF='?_src_=holder;rejectadminhelp=[ref_client]'>REJT</A>) (<A HREF='?_src_=holder;icissue=[ref_client]'>IC</A>):</b> [msg]</span>"

	//send this msg to all admins

	for(var/client/X in GLOB.admins)
		if(X.prefs.toggles & SOUND_ADMINHELP)
			X << 'sound/effects/adminhelp.ogg'
		window_flash(X, ignorepref = TRUE)
		to_chat(X, msg)


	//show it to the person adminhelping too
	to_chat(src, "<span class='adminnotice'>PM to-<b>Admins</b>: [original_msg]</span>")

	//send it to irc if nobody is on and tell us how many were on
	var/admin_number_present = send2irc_adminless_only(ckey,original_msg)
	log_admin_private("HELP: [key_name(src)]: [original_msg] - heard by [admin_number_present] non-AFK admins who have +BAN.")
	if(admin_number_present <= 0)
		to_chat(src, "<span class='notice'>No active admins are online, your adminhelp was sent to the admin irc.</span>")
	feedback_add_details("admin_verb","Adminhelp") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

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
		message["key"] = global.comms_key
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
