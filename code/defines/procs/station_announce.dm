/proc/station_announce(var/tmp/header, var/tmp/text)
	if(!header)	header = "Priority Announcement"
	world << "<h1 class='alert'>[header]</h1>"
	world << "<span class='alert'>[html_encode(text)]</span>"
	world << "<br>"

