/proc/priority_announce(text, title = "", sound = 'sound/AI/attention.ogg', type)
	if(!text)
		return

	var/announcement

	if(type == "Priority")
		announcement += "<h1 class='alert'>Priority Announcement</h1>"
		if (title && length(title) > 0)
			announcement += "<br><h2 class='alert'>[(title)]</h2>"
	else if(type == "Captain")
		announcement += "<h1 class='alert'>Captain Announces</h1>"
		sanitize_russian(news_network.SubmitArticle(text, "Captain's Announcement", "Station Announcements", null), 1)

	else
		announcement += "<h1 class='alert'>[command_name()] Update</h1>"
		if (title && length(title) > 0)
			announcement += "<br><h2 class='alert'>[(title)]</h2>"
		if(title == "")
			sanitize_russian(news_network.SubmitArticle(text, "Central Command Update", "Station Announcements", null), 1)
		else
			sanitize_russian(news_network.SubmitArticle(title + "<br><br>" + text, "Central Command", "Station Announcements", null), 1)

	announcement += "<br><span class='alert'>[sanitize_russian(text)]</span><br>"
	announcement += "<br>"

	for(var/mob/M in player_list)
		if(!istype(M,/mob/new_player) && !M.ear_deaf)
			M << sanitize_russian(announcement)
			if(M.client.prefs.toggles & SOUND_ANNOUNCMENTS)
				M << sound(sound)

/proc/print_command_report(text = "", title = "Central Command Update")
	for (var/obj/machinery/computer/communications/C in machines)
		if(!(C.stat & (BROKEN|NOPOWER)) && C.z == ZLEVEL_STATION)
			var/obj/item/weapon/paper/P = new /obj/item/weapon/paper( C.loc )
			P.name = "paper- '[title]'"
			P.info = sanitize_russian(text)
			C.messagetitle.Add("[title]")
			C.messagetext.Add(sanitize_russian(text))

/proc/minor_announce(message, title = "Attention:", alert)
	if(!message)
		return

	for(var/mob/M in player_list)
		if(!istype(M,/mob/new_player) && !M.ear_deaf)
			M << "<b><font size = 3><font color = red>[title]</font color><BR>[sanitize_russian(message)]</font size></b><BR>"
			if(M.client.prefs.toggles & SOUND_ANNOUNCMENTS)
				if(alert)
					M << sound('sound/misc/notice1.ogg')
				else
					M << sound('sound/misc/notice2.ogg')