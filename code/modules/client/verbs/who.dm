#define DEFAULT_WHO_CELLS_PER_ROW 4

/client/verb/who()
	set name = "Who"
	set category = "OOC"

	var/msg = "<b>Current Players:</b>\n"

	var/list/Lines = list()
	var/columns_per_row = DEFAULT_WHO_CELLS_PER_ROW

	if(holder)
		if (check_rights(R_ADMIN,0) && isobserver(src.mob))//If they have +ADMIN and are a ghost they can see players IC names and statuses.
			columns_per_row = 1
			var/mob/dead/observer/G = src.mob
			if(!G.started_as_observer)//If you aghost to do this, KorPhaeron will deadmin you in your sleep.
				log_admin("[key_name(usr)] checked advanced who in-round")
			for(var/client/client in GLOB.clients)
				var/entry = "\t[client.key]"
				if(client.holder && client.holder.fakekey)
					entry += " <i>(as [client.holder.fakekey])</i>"
				if (isnewplayer(client.mob))
					entry += " - <font color='darkgray'><b>In Lobby</b></font>"
				else
					entry += " - Playing as [client.mob.real_name]"
					switch(client.mob.stat)
						if(UNCONSCIOUS, HARD_CRIT)
							entry += " - <font color='darkgray'><b>Unconscious</b></font>"
						if(DEAD)
							if(isobserver(client.mob))
								var/mob/dead/observer/O = client.mob
								if(O.started_as_observer)
									entry += " - <font color='gray'>Observing</font>"
								else
									entry += " - <font color='black'><b>DEAD</b></font>"
							else
								entry += " - <font color='black'><b>DEAD</b></font>"
					if(is_special_character(client.mob))
						entry += " - <b><font color='red'>Antagonist</font></b>"
				entry += " [ADMIN_QUE(client.mob)]"
				entry += " ([round(client.avgping, 1)]ms)"
				Lines += entry
		else//If they don't have +ADMIN, only show hidden admins
			for(var/client/client in GLOB.clients)
				var/entry = "[client.key]"
				if(client.holder && client.holder.fakekey)
					entry += " <i>(as [client.holder.fakekey])</i>"
				entry += " ([round(client.avgping, 1)]ms)"
				Lines += entry
	else
		for(var/client/client in GLOB.clients)
			if(client.holder && client.holder.fakekey)
				Lines += "[client.holder.fakekey] ([round(client.avgping, 1)]ms)"
			else
				Lines += "[client.key] ([round(client.avgping, 1)]ms)"

	var/num_lines = 0
	msg += "<table style='width: 100%; table-layout: fixed'><tr>"
	for(var/line in sort_list(Lines))
		msg += "<td>[line]</td>"

		num_lines += 1
		if (num_lines == columns_per_row)
			num_lines = 0
			msg += "</tr><tr>"
	msg += "</tr></table>"

	msg += "<b>Total Players: [length(Lines)]</b>"
	to_chat(src, "<span class='infoplain'>[msg]</span>")

/client/verb/adminwho()
	set category = "Admin"
	set name = "Adminwho"

	var/msg = "<b>Current Admins:</b>\n"
	var/display_name
	if(holder)
		for(var/client/client in GLOB.admins)
			var/feedback_link = client.holder.feedback_link()
			display_name = feedback_link ? "<a href=[feedback_link]>[client]</a>" : client

			msg += "\t[display_name] is a [client.holder.rank_names()]"

			if(client.holder.fakekey)
				msg += " <i>(as [client.holder.fakekey])</i>"

			if(isobserver(client.mob))
				msg += " - Observing"
			else if(isnewplayer(client.mob))
				if(SSticker.current_state <= GAME_STATE_PREGAME)
					var/mob/dead/new_player/lobbied_admin = client.mob
					if(lobbied_admin.ready == PLAYER_READY_TO_PLAY)
						msg += " - Lobby (Readied)"
					else
						msg += " - Lobby (Not readied)"
				else
					msg += " - Lobby"
			else
				msg += " - Playing"

			if(client.is_afk())
				msg += " (AFK)"
			msg += "\n"
	else
		for(var/client/client in GLOB.admins)
			var/feedback_link = client.holder.feedback_link()
			display_name = feedback_link ? "<a href=[feedback_link]>[client]</a>" : client

			if(client.is_afk())
				continue //Don't show afk admins to adminwho
			if(!client.holder.fakekey)
				msg += "\t[display_name] is a [client.holder.rank_names()]\n"
		msg += span_info("Adminhelps are also sent through TGS to services like IRC and Discord. If no admins are available in game, sending an adminhelp might still be noticed and responded to.")
	to_chat(src, msg)

#undef DEFAULT_WHO_CELLS_PER_ROW
