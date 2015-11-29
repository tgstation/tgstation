/proc/command_alert(var/text, var/title = "")
	var/command
	command += "<h1 class='alert'>[command_name()] Update</h1>"
	if (title && length(title) > 0)
		command += "<br><h2 class='alert'>[html_encode(title)]</h2>"


	// AUTOFIXED BY fix_string_idiocy.py
	// C:\Users\Rob\\documents\\\projects\vgstation13\code\\defines\\\procs\command_alert.dm:7: command += "<br><span class='alert'>[html_encode(text)]</span><br>"
	command += {"<br><span class='alert'>[html_encode(text)]</span><br>
		<br>"}
	// END AUTOFIX
	for(var/mob/M in player_list)
		if(!istype(M,/mob/new_player) && M.client)
			to_chat(M, command)
