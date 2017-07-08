/proc/priority_announce(text, title = "", sound = 'sound/ai/attention.ogg', type)
	if(!text)
		return

	var/announcement

	if(type == "Priority")
		announcement += "<h1 class='alert'>Priority Announcement</h1>"
		if (title && length(title) > 0)
			announcement += "<br><h2 class='alert'>[html_encode(title)]</h2>"
	else if(type == "Captain")
		announcement += "<h1 class='alert'>Captain Announces</h1>"
		GLOB.news_network.SubmitArticle(text, "Captain's Announcement", "Station Announcements", null)

	else
		announcement += "<h1 class='alert'>[command_name()] Update</h1>"
		if (title && length(title) > 0)
			announcement += "<br><h2 class='alert'>[html_encode(title)]</h2>"
		if(title == "")
			GLOB.news_network.SubmitArticle(text, "Central Command Update", "Station Announcements", null)
		else
			GLOB.news_network.SubmitArticle(title + "<br><br>" + text, "Central Command", "Station Announcements", null)

	announcement += "<br><span class='alert'>[html_encode(text)]</span><br>"
	announcement += "<br>"

	for(var/mob/M in GLOB.player_list)
		if(!isnewplayer(M) && M.can_hear())
			to_chat(M, announcement)
			if(M.client.prefs.toggles & SOUND_ANNOUNCEMENTS)
				M << sound(sound)

/proc/print_command_report(text = "", title = null, announce=TRUE)
	if(!title)
		title = "Classified [command_name()] Update"

	if(announce)
		priority_announce("A report has been downloaded and printed out at all communications consoles.", "Incoming Classified Message", 'sound/ai/commandreport.ogg')

	for(var/obj/machinery/computer/communications/C in GLOB.machines)
		if(!(C.stat & (BROKEN|NOPOWER)) && C.z == ZLEVEL_STATION)
			var/obj/item/weapon/paper/P = new /obj/item/weapon/paper(C.loc)
			P.name = "paper - '[title]'"
			P.info = text
			C.messagetitle.Add("[title]")
			C.messagetext.Add(text)
			P.update_icon()

/proc/minor_announce(message, title = "Attention:", alert)
	if(!message)
		return

	for(var/mob/M in GLOB.player_list)
		if(!isnewplayer(M) && M.can_hear())
			to_chat(M, "<b><font size = 3><font color = red>[title]</font color><BR>[message]</font size></b><BR>")
			if(M.client.prefs.toggles & SOUND_ANNOUNCEMENTS)
				if(alert)
					M << sound('sound/misc/notice1.ogg')
				else
					M << sound('sound/misc/notice2.ogg')
