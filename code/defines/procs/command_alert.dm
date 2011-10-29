/proc/command_alert(var/text, var/title = "")
	world << "<h1 class='alert'>[command_name()] Update</h1>"

	if (title && length(title) > 0)
		world << "<h2 class='alert'>[html_encode(title)]</h2>"

	world << "<span class='alert'>[html_encode(text)]</span>"
	world << "<br>"

