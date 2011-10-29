/proc/captain_announce(var/text)
	world << "<h1 class='alert'>Captain Announces</h1>"

	world << "<span class='alert'>[html_encode(text)]</span>"
	world << "<br>"

