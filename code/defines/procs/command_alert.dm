/proc/command_alert(var/text, var/title = "",var/force_report = 0)
	var/command
	command += "<h1 class='alert'>[command_name()] Update</h1>"
	if (title && length(title) > 0)
		command += "<br><h2 class='alert'>[html_encode(title)]</h2>"


	command += {"<br><span class='alert'>[html_encode(text)]</span><br>
		<br>"}
	if(map.linked_to_centcomm || force_report)
		for(var/mob/M in player_list)
			if(!istype(M,/mob/new_player) && M.client)
				to_chat(M, command)