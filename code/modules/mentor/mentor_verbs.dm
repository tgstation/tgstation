GLOBAL_LIST_INIT(mentor_follow_whitelist, typecacheof(/mob/dead))

/client/verb/mentorhelp(msg as text)
	set category = "Mentor"
	set name = "Mentorhelp"

	//clean the input msg
	if(!msg)
		return
	msg = sanitize(copytext(msg,1,MAX_MESSAGE_LEN))
	if(!msg)
		return
	if(!mob) //this doesn't happen
		return
	if(prefs.muted & MUTE_MENTORHELP)
		to_chat(src, "<font color='red'>You are unable to use mentorhelp (muted).</font>")
		return
	var/show_char = CONFIG_GET(flag/mentors_mobname_only)
	var/mentor_msg = ""
	log_mentor("MENTORHELP: [key_name_mentor(src, 0, 0, 0, 0)]: [msg]")

	for(var/client/X in mentors_and_admins())
		SEND_SOUND(X, 'sound/items/bikehorn.ogg')
		mentor_msg = "<span class='mentornotice'><b><font color='#3280ff'>MENTORHELP:</b> <b>"
		if(check_rights_for(X, R_ADMIN) || (CONFIG_GET(flag/mentors_can_always_follow) || !is_type_in_typecache(X.mob, GLOB.mentor_follow_whitelist)))
			mentor_msg += FOLLOW_LINK(X, src)
		mentor_msg += " [key_name_mentor(src, 1, 0, show_char)]</b>:</font> [msg]</span>"
		to_chat(X, mentor_msg)


	to_chat(src, "<span class='mentornotice'><font color='purple'>PM to-<b>Mentors</b>: [msg]</font></span>")
	return

/proc/key_name_mentor(var/whom, var/include_link = null, var/include_name = FALSE, var/char_name_only = FALSE)
	var/mob/M
	var/client/C
	var/key
	var/ckey

	if(!whom)	return "*null*"
	if(istype(whom, /client))
		C = whom
		M = C.mob
		key = C.key
		ckey = C.ckey
	else if(ismob(whom))
		M = whom
		C = M.client
		key = M.key
		ckey = M.ckey
	else if(istext(whom))
		key = whom
		ckey = ckey(whom)
		C = GLOB.directory[ckey]
		if(C)
			M = C.mob
	else
		return "*invalid*"

	. = ""

	if(!ckey)
		include_link = 0

	if(key)
		if(include_link)
			if(CONFIG_GET(flag/mentors_mobname_only))
				. += "<a href='?mentor_msg=[REF(M)]'>"
			else
				. += "<a href='?mentor_msg=[ckey]'>"

		if(C && C.holder && C.holder.fakekey)
			. += "Administrator"
		else if (char_name_only && CONFIG_GET(flag/mentors_mobname_only))
			if(is_type_in_typecache(C.mob, GLOB.mentor_follow_whitelist)) //If they're in the lobby or observing, display their ckey
				. += key
			else if(C && C.mob) //If they're playing/in the round, only show the mob name
				. += C.mob.name
			else //If for some reason neither of those are applicable and they're mentorhelping, show ckey
				. += key
		else
			. += key
		if(!C)
			. += "\[DC\]"

		if(include_link)
			. += "</a>"
	else
		. += "*no key*"

	return .