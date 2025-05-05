#define DEFAULT_WHO_CELLS_PER_ROW 4
#define NO_ADMINS_ONLINE_MESSAGE "Adminhelps are also sent through TGS to services like IRC and Discord. If no admins are available in game, sending an adminhelp might still be noticed and responded to."

/client/verb/who()
	set name = "Who"
	set category = "OOC"

	var/msg = ""

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
	to_chat(src, fieldset_block(span_bold("Current Players"), span_infoplain(msg), "boxed_message"), type = MESSAGE_TYPE_INFO)

/client/verb/adminwho()
	set category = "Admin"
	set name = "Adminwho"

	var/list/lines = list()
	var/payload_string = generate_adminwho_string()
	var/header = (payload_string == NO_ADMINS_ONLINE_MESSAGE) ? "No Admins Currently Online" : "Current Admins"

	lines += span_bold(header)
	lines += payload_string

	to_chat(src, fieldset_block(span_bold(header), jointext(lines, "\n"), "boxed_message"), type = MESSAGE_TYPE_INFO)

/// Proc that generates the applicable string to dispatch to the client for adminwho.
/client/proc/generate_adminwho_string()
	var/list/list_of_admins = get_list_of_admins()
	if(isnull(list_of_admins))
		return NO_ADMINS_ONLINE_MESSAGE

	var/list/message_strings = list()
	if(isnull(holder))
		message_strings += get_general_adminwho_information(list_of_admins)
		message_strings += NO_ADMINS_ONLINE_MESSAGE
	else
		message_strings += get_sensitive_adminwho_information(list_of_admins)

	return jointext(message_strings, "\n")

/// Proc that returns a list of cliented admins. Remember that this list can contain nulls!
/// Also, will return null if we don't have any admins.
/proc/get_list_of_admins()
	var/returnable_list = list()

	for(var/client/admin in GLOB.admins)
		returnable_list += admin

	if(length(returnable_list) == 0)
		return null

	return returnable_list

/// Proc that will return the applicable display name, linkified or not, based on the input client reference.
/proc/get_linked_admin_name(client/admin)
	var/feedback_link = admin.holder.feedback_link()
	return isnull(feedback_link) ? admin : "<a href=[feedback_link]>[admin]</a>"

/// Proc that gathers adminwho information for a general player, which will only give information if an admin isn't AFK, and handles potential fakekeying.
/// Will return a list of strings.
/proc/get_general_adminwho_information(list/checkable_admins)
	var/returnable_list = list()

	for(var/client/admin in checkable_admins)
		if(admin.is_afk() || !isnull(admin.holder.fakekey))
			continue //Don't show afk or fakekeyed admins to adminwho

		returnable_list += "• [get_linked_admin_name(admin)] is a [admin.holder.rank_names()]"

	return returnable_list

/// Proc that gathers adminwho information for admins, which will contain information on if the admin is AFK, readied to join, etc. Only arg is a list of clients to use.
/// Will return a list of strings.
/proc/get_sensitive_adminwho_information(list/checkable_admins)
	var/returnable_list = list()

	for(var/client/admin in checkable_admins)
		var/list/admin_strings = list()

		admin_strings += "• [get_linked_admin_name(admin)] is a [admin.holder.rank_names()]"

		if(admin.holder.fakekey)
			admin_strings += "<i>(as [admin.holder.fakekey])</i>"

		if(isobserver(admin.mob))
			admin_strings += "- Observing"
		else if(isnewplayer(admin.mob))
			if(SSticker.current_state <= GAME_STATE_PREGAME)
				var/mob/dead/new_player/lobbied_admin = admin.mob
				if(lobbied_admin.ready == PLAYER_READY_TO_PLAY)
					admin_strings += "- Lobby (Readied)"
				else
					admin_strings += "- Lobby (Not Readied)"
			else
				admin_strings += "- Lobby"
		else
			admin_strings += "- Playing"

		if(admin.is_afk())
			admin_strings += "(AFK)"

		returnable_list += jointext(admin_strings, " ")

	return returnable_list

#undef DEFAULT_WHO_CELLS_PER_ROW
#undef NO_ADMINS_ONLINE_MESSAGE
