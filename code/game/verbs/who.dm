/client/verb/who()
	set name = "Who"
	set category = "OOC"

	var/msg = "\n<b>Current Players:</b>\n"

	var/list/Lines = list()

	//for admins
	var/living = 0 //Currently alive and in the round (possibly unconscious, but not officially dead)
	var/dead = 0 //Have been in the round but are now deceased
	var/observers = 0 //Have never been in the round (thus observing)
	var/lobby = 0 //Are currently in the lobby
	var/living_antags = 0 //Are antagonists, and currently alive
	var/dead_antags = 0 //Are antagonists, and have finally met their match

	if(holder)
		for(var/client/C in clients)
			var/entry = "\t[C.key]"

			if(C.holder && C.holder.fakekey)
				entry += " <i>(as [C.holder.fakekey])</i>"

			if(C.mob.real_name)
				entry += " - Playing as [C.mob.real_name]"

			switch(C.mob.stat)
				if(UNCONSCIOUS)
					entry += " - <span style='color:darkgray'><b>Unconscious</b></span>"

				if(DEAD)
					if(isobserver(C.mob))
						var/mob/dead/observer/O = C.mob

						if(O.started_as_observer)
							entry += " - <span style='color:gray'>Observing</span>"
							observers++
						else
							entry += " - <b>DEAD</b>"
							dead++
					else if (isnewplayer(C.mob))
						entry += " - <span style='color:gray'><i>Lobby</i></span>"
						lobby++
					else
						entry += " - <b>DEAD</b>"
						dead++
				else
					living++

			if(is_special_character(C.mob))
				entry += " - <b><span class='red'>Antagonist</span></b>"
				if(!(C.mob.isDead()))
					living_antags++
				else
					dead_antags++

			entry += " (<A HREF='?_src_=holder;adminmoreinfo=\ref[C.mob]'>?</A>)"
			Lines += entry

		log_admin("[key_name(usr)] used who verb advanced (shows OOC key - IC name, status and if antagonist)")
	else
		for(var/client/C in clients)
			if(C.holder && C.holder.fakekey)
				Lines += C.holder.fakekey
			else
				Lines += C.key

	for(var/line in sortList(Lines))
		msg += "[line]\n"
	if(holder)
		msg += "<b><span class='notice'>Total Living: [living]</span> | Total Dead: [dead] | <span style='color:gray'>Observing: [observers]</span> | <span style='color:gray'><i>In Lobby: [lobby]</i></span> | <span class='bad'>Living Antags: [living_antags]</span> | <span class='good'>Dead Antags: [dead_antags]</span></b>\n"
	msg += "<b>Total Players: [length(Lines)]</b>\n"
	to_chat(src, msg)

/client/verb/adminwho()
	set category = "Admin"
	set name = "Adminwho"

	var/aNames = ""
	var/mNames = ""
	var/numAdminsOnline = 0
	var/numModsOnline = 0

	if (holder)
		for (var/client/C in admins)
			if (R_ADMIN & C.holder.rights || !(R_MOD & C.holder.rights))
				aNames += "\t[C] is a [C.holder.rank]"

				if (C.holder.fakekey)
					aNames += " <i>(as [C.holder.fakekey])</i>"

				if (isobserver(C.mob))
					aNames += " - Observing"
				else if (istype(C.mob,/mob/new_player))
					aNames += " - Lobby"
				else
					aNames += " - Playing"

				if (C.is_afk())
					aNames += " (AFK)"

				aNames += "\n"
				numAdminsOnline++
			else
				mNames += "\t[C] is a [C.holder.rank]"

				if (C.holder.fakekey)
					mNames += " <i>(as [C.holder.fakekey])</i>"

				if (isobserver(C.mob))
					mNames += " - Observing"
				else if (istype(C.mob,/mob/new_player))
					mNames += " - Lobby"
				else
					mNames += " - Playing"

				if (C.is_afk())
					mNames += " (AFK)"

				mNames += "\n"
				numModsOnline++
	else
		for (var/client/C in admins)
			if (R_ADMIN & C.holder.rights || !(R_MOD & C.holder.rights))
				if (!C.holder.fakekey)
					aNames += "\t[C] is a [C.holder.rank]\n"
					numAdminsOnline++
			else
				if (!C.holder.fakekey)
					mNames += "\t[C] is a [C.holder.rank]\n"
					numModsOnline++

	to_chat(src, "\n<b>Current Admins ([numAdminsOnline]):</b>\n" + aNames + "\n<b>Current Moderators ([numModsOnline]):</b>\n" + mNames + "\n")
