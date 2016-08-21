/client/verb/mentorhelp(msg as text)
	set category = "Mentor"
	set name = "Mentorhelp"

	//remove out adminhelp verb temporarily to prevent spamming of mentors.
	src.verbs -= /client/verb/mentorhelp
	spawn(300)
		src.verbs += /client/verb/mentorhelp	// 30 second cool-down for mentorhelp

	//clean the input msg
	if(!msg)	return
	msg = sanitize(copytext(msg,1,MAX_MESSAGE_LEN))
	if(!msg)	return
	if(!mob)	return						//this doesn't happen

	var/show_char = config.mentors_mobname_only
	var/mentor_msg = "<span class='mentornotice'><b><font color='purple'>MENTORHELP:</b> <b>[key_name_mentor(src, 1, 0, 1, show_char)]</b>: [msg]</font></span>"
	log_mentor("MENTORHELP: [key_name_mentor(src, 0, 0, 0, 0)]: [msg]")

	for(var/client/X in mentors)
		X << 'sound/items/bikehorn.ogg'
		X << mentor_msg

	for(var/client/A in admins)
		A << 'sound/items/bikehorn.ogg'
		A << mentor_msg

	src << "<span class='mentornotice'><font color='purple'>PM to-<b>Mentors</b>: [msg]</font></span>"
	return

/proc/key_name_mentor(var/whom, var/include_link = null, var/include_name = 0, var/include_follow = 0, var/char_name_only = 0)
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
		C = directory[ckey]
		if(C)
			M = C.mob
	else
		return "*invalid*"

	. = ""

	if(!ckey)
		include_link = 0

	if(key)
		if(include_link)
			if(config.mentors_mobname_only)
				. += "<a href='?mentor_msg=\ref[M]'>"
			else
				. += "<a href='?mentor_msg=[ckey]'>"

		if(C && C.holder && C.holder.fakekey)
			. += "Administrator"
		else if (char_name_only && config.mentors_mobname_only)
			if(istype(C.mob,/mob/new_player) || istype(C.mob, /mob/dead/observer)) //If they're in the lobby or observing, display their ckey
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

	if(include_follow)
		. += " (<a href='?mentor_follow=\ref[M]'>F</a>)"

	return .