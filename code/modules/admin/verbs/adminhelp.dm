/proc/keywords_lookup(msg)

	//This is a list of words which are ignored by the parser when comparing message contents for names. MUST BE IN LOWER CASE!
	var/list/adminhelp_ignored_words = list("unknown","the","a","an","of","monkey","alien","as", "i")

	//explode the input msg into a list
	var/list/msglist = splittext(msg, " ")

	//generate keywords lookup
	var/list/surnames = list()
	var/list/forenames = list()
	var/list/ckeys = list()
	for(var/mob/M in mob_list)
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
							msg += "[original_word]<font size='1' color='[is_antag ? "red" : "black"]'>(<A HREF='?_src_=holder;adminmoreinfo=\ref[found]'>?</A>|<A HREF='?_src_=holder;adminplayerobservefollow=\ref[found]'>F</A>)</font> "
							continue
		msg += "[original_word] "
	return msg


/client/var/adminhelptimerid = 0

/client/proc/giveadminhelpverb()
	src.verbs |= /client/verb/adminhelp
	adminhelptimerid = 0

/client/verb/adminhelp(msg as text)
	set category = "Admin"
	set name = "Adminhelp"

	if(say_disabled)	//This is here to try to identify lag problems
		usr << "<span class='danger'>Speech is currently admin-disabled.</span>"
		return

	//handle muting and automuting
	if(prefs.muted & MUTE_ADMINHELP)
		src << "<span class='danger'>Error: Admin-PM: You cannot send adminhelps (Muted).</span>"
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
	adminhelptimerid = addtimer(src, "giveadminhelpverb", 1200, FALSE) //2 minute cooldown of admin helps

	msg = keywords_lookup(msg)

	if(!mob)
		return						//this doesn't happen

	var/ref_mob = "\ref[mob]"
	var/ref_client = "\ref[src]"
	msg = "<span class='adminnotice'><b><font color=red>HELP: </font><A HREF='?priv_msg=[ckey];ahelp_reply=1'>[key_name(src)]</A> (<A HREF='?_src_=holder;adminmoreinfo=[ref_mob]'>?</A>) (<A HREF='?_src_=holder;adminplayeropts=[ref_mob]'>PP</A>) (<A HREF='?_src_=vars;Vars=[ref_mob]'>VV</A>) (<A HREF='?_src_=holder;subtlemessage=[ref_mob]'>SM</A>) (<A HREF='?_src_=holder;adminplayerobservefollow=[ref_mob]'>FLW</A>) (<A HREF='?_src_=holder;traitor=[ref_mob]'>TP</A>) (<A HREF='?_src_=holder;rejectadminhelp=[ref_client]'>REJT</A>):</b> [msg]</span>"

	//send this msg to all admins

	for(var/client/X in admins)
		if(X.prefs.toggles & SOUND_ADMINHELP)
			X << 'sound/effects/adminhelp.ogg'
		X << msg


	//show it to the person adminhelping too
	src << "<span class='adminnotice'>PM to-<b>Admins</b>: [original_msg]</span>"

	//send it to irc if nobody is on and tell us how many were on
	var/admin_number_present = send2irc_adminless_only(ckey,original_msg)
	log_admin("HELP: [key_name(src)]: [original_msg] - heard by [admin_number_present] non-AFK admins who have +BAN.")
	feedback_add_details("admin_verb","AH") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/proc/get_admin_counts(requiredflags = R_BAN)
	. = list("total" = 0, "noflags" = 0, "afk" = 0, "stealth" = 0, "present" = 0)
	for(var/client/X in admins)
		.["total"]++
		if(requiredflags != 0 && !check_rights_for(X, requiredflags))
			.["noflags"]++
		else if(X.is_afk())
			.["afk"]++
		else if(X.holder.fakekey)
			.["stealth"]++
		else
			.["present"]++

/proc/send2irc_adminless_only(source, msg, requiredflags = R_BAN)
	var/list/adm = get_admin_counts(requiredflags)
	. = adm["present"]
	if(. <= 0)
		if(!adm["afk"] && !adm["stealth"] && !adm["noflags"])
			send2irc(source, "[msg] - No admins online")
		else
			send2irc(source, "[msg] - All admins AFK ([adm["afk"]]/[adm["total"]]), stealthminned ([adm["stealth"]]/[adm["total"]]), or lack[rights2text(requiredflags, " ")] ([adm["noflags"]]/[adm["total"]])")

/proc/send2irc(msg,msg2)
	if(config.useircbot)
		shell("python nudge.py [msg] [msg2]")
	return
