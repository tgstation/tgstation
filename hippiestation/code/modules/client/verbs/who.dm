/client/verb/mentorwho()
	set category = "Mentor"
	set name = "Mentorwho"
	var/msg = "<b>Current Mentors:</b>\n"
	for(var/X in GLOB.admins)
		var/client/C = X
		if(check_rights_for(C, R_ADMIN))
			continue
		if(check_rights_for(C, R_MENTOR))
			var/suffix = ""
			if(holder)
				if(isobserver(C.mob))
					suffix += " - Observing"
				else if(istype(C.mob,/mob/dead/new_player))
					suffix += " - Lobby"
				else
					suffix += " - Playing"

				if(C.is_afk())
					suffix += " (AFK)"
			msg += "\t[C][suffix]\n"
	to_chat(src, msg)

/client/verb/who()
	set name = "Who"
	set category = "OOC"

	var/msg = ""

	var/list/Lines = list()
	if(length(GLOB.admins) > 0)
		var/list/adminslist = list()
		var/list/mentorslist = list()
		for(var/X in GLOB.admins)
			var/client/C = X
			if(check_rights_for(C, R_ADMIN))
				adminslist += C
			else if(check_rights_for(C, R_MENTOR))
				mentorslist += C
		if(adminslist.len)
			Lines += "<b>Admins:</b>"
			for(var/X in adminslist)
				var/client/C = X
				if(!C.holder.fakekey)
					Lines += "\t <font color='#FF0000'>[C.key]</font>[show_info(C)] ([round(C.avgping, 1)]ms)"
		if(mentorslist.len)
			Lines += "<b>Mentors:</b>"
			for(var/X in mentorslist)
				var/client/C = X
				Lines += "\t <font color='#0033CC'>[C.key]</font>[show_info(C)] ([round(C.avgping, 1)]ms)"

	Lines += "<b>Players:</b>"
	for(var/X in sortList(GLOB.clients))
		var/client/C = X
		if(!check_rights_for(C, R_MENTOR) || C.holder.fakekey)
			Lines += "\t [C.key][show_info(C)] ([round(C.avgping, 1)]ms)"

	for(var/line in Lines)
		msg += "[line]\n"

	msg += "<b>Total Players: [length(GLOB.clients)]</b>"
	to_chat(src, msg)

/client/proc/show_info(var/client/C)
	if(!C)
		return ""

	if(!check_rights_for(src, R_ADMIN))
		return ""

	var/entry = ""
	if(C.holder && C.holder.fakekey)
		entry += " <i>(as [C.holder.fakekey])</i>"
	if (isnewplayer(C.mob))
		entry += " - <font color='darkgray'><b>In Lobby</b></font>"
	else
		entry += " - Playing as [C.mob.real_name]"
		switch(C.mob.stat)
			if(UNCONSCIOUS)
				entry += " - <font color='darkgray'><b>Unconscious</b></font>"
			if(DEAD)
				if(isobserver(C.mob))
					var/mob/dead/observer/O = C.mob
					if(O.started_as_observer)
						entry += " - <font color='gray'>Observing</font>"
					else
						entry += " - <font color='black'><b>DEAD</b></font>"
				else
					entry += " - <font color='black'><b>DEAD</b></font>"
		if(is_special_character(C.mob))
			entry += " - <b><font color='red'>Antagonist</font></b>"
	entry += " (<A HREF='?_src_=holder;adminmoreinfo=\ref[C.mob]'>?</A>)"
	return entry

/client/verb/adminwho()
	set category = "Admin"
	set name = "Adminwho"

	var/msg = "<b>Current Admins:</b>\n"
	if(check_rights_for(src, R_ADMIN))
		for(var/X in GLOB.admins)
			var/client/C = X
			if(!check_rights_for(C, R_ADMIN))
				continue
			msg += "\t[C] is a [C.holder.rank]"

			if(C.holder.fakekey)
				msg += " <i>(as [C.holder.fakekey])</i>"

			if(isobserver(C.mob))
				msg += " - Observing"
			else if(isnewplayer(C.mob))
				msg += " - Lobby"
			else
				msg += " - Playing"

			if(C.is_afk())
				msg += " (AFK)"
			msg += "\n"
	else
		for(var/X in GLOB.admins)
			var/client/C = X
			if(!check_rights_for(C, R_ADMIN))
				continue
			if(C.is_afk())
				continue //Don't show afk admins to adminwho
			if(!C.holder.fakekey)
				msg += "\t[C] is a [C.holder.rank]\n"
		msg += "<span class='info'>Adminhelps are also sent to Discord. If no admins are available in game adminhelp anyways and an admin on Discord will see it and respond.</span>"
	to_chat(src, msg)
