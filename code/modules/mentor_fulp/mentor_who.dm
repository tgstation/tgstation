/client/verb/mentorwho()
	set category = "Mentor"
	set name = "Mentorwho"

	var/msg = "<b>Current Mentors:</b>\n"
	if(holder)
		for(var/client/C in GLOB.mentors)
			if(C.mentor_datum && !check_rights_for(C, R_ADMIN,0))
				msg += "\t[C] is a mentor"
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
		for(var/client/C in GLOB.mentors)
			if(C.is_afk())
				continue
			if(C.mentor_datum && !check_rights_for(C, R_ADMIN,0))
				msg += "\t[C] is a Mentor\n"
	to_chat(src, msg)
