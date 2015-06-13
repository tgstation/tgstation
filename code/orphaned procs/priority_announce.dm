/proc/priority_announce(var/text, var/title = "", var/sound = 'sound/AI/attention.ogg', var/type)
	if(!text)
		return

	var/announcement

	if(type == "Priority")
		announcement += "<h1 class='alert'>Priority Announcement</h1>"
		if (title && length(title) > 0)
			announcement += "<br><h2 class='alert'>[html_encode(title)]</h2>"
	else if(type == "Captain")
		announcement += "<h1 class='alert'>Captain Announces</h1>"
		news_network.SubmitArticle(text, "Captain's Announcement", "Station Announcements", null)

	else
		announcement += "<h1 class='alert'>[command_name()] Update</h1>"
		if (title && length(title) > 0)
			announcement += "<br><h2 class='alert'>[html_encode(title)]</h2>"
		if(title == "")
			news_network.SubmitArticle(text, "Central Command Update", "Station Announcements", null)
		else
			news_network.SubmitArticle(title + "<br><br>" + text, "Central Command", "Station Announcements", null)

	announcement += "<br><span class='alert'>[html_encode(text)]</span><br>"
	announcement += "<br>"

	for(var/mob/M in player_list)
		if(!istype(M,/mob/new_player) && !M.ear_deaf)
			M << announcement
			M << sound(sound)

/proc/print_command_report(var/text = "", var/title = "Central Command Update")
	for (var/obj/machinery/computer/communications/C in machines)
		if(!(C.stat & (BROKEN|NOPOWER)) && C.z == ZLEVEL_STATION)
			var/obj/item/weapon/paper/P = new /obj/item/weapon/paper( C.loc )
			P.name = "paper- '[title]'"
			P.info = text
			C.messagetitle.Add("[title]")
			C.messagetext.Add(text)

/proc/minor_announce(var/message, var/title = "Attention:", var/alert)
	if(!message)
		return

	for(var/mob/M in player_list)
		if(!istype(M,/mob/new_player) && !M.ear_deaf)
			M << "<b><font size = 3><font color = red>[title]</font color><BR>[message]</font size></b><BR>"
			if(alert)
				M << sound('sound/misc/notice1.ogg')
			else
				M << sound('sound/misc/notice2.ogg')