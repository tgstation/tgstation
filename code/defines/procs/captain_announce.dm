/proc/captain_announce(var/text)
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/captain_announce() called tick#: [world.time]")
	world << "<h1 class='alert'>Priority Announcement</h1>"
	world << "<span class='alert'>[html_encode(text)]</span>"
	world << "<br>"

