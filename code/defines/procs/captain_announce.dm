/proc/captain_announce(var/text)
	to_chat(world, "<h1 class='alert'>Priority Announcement</h1>")
	to_chat(world, "<span class='alert'>[html_encode(text)]</span>")
	to_chat(world, "<br>")

