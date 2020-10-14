/client/proc/panicbunker()
	set category = "Server"
	set name = "Toggle Panic Bunker"
	if (!CONFIG_GET(flag/sql_enabled))
		to_chat(usr, "<span class='adminnotice'>The Database is not enabled!</span>", confidential = TRUE)
		return

	var/new_pb = !CONFIG_GET(flag/panic_bunker)
	var/time_rec = 0
	var/message = ""
	if(new_pb)
		time_rec = input(src, "How many living minutes should they need to play?", "Shit's fucked isn't it", CONFIG_GET(number/panic_bunker_living)) as num
		message = input(src, "What should they see when they log in?", "MMM", CONFIG_GET(string/panic_bunker_message)) as text
		message = replacetext(message, "%minutes%", time_rec)
		CONFIG_SET(number/panic_bunker_living, time_rec)
		CONFIG_SET(string/panic_bunker_message, message)
		
	CONFIG_SET(flag/panic_bunker, new_pb)
	log_admin("[key_name(usr)] has toggled the Panic Bunker, it is now [new_pb ? "on and set to [time_rec] with a message of [message]" : "off"]")
	message_admins("[key_name_admin(usr)] has toggled the Panic Bunker, it is now [new_pb ? "enabled with a living minutes requirement of [time_rec]" : "disabled"].")
	if (new_pb && !SSdbcore.Connect())
		message_admins("The Database is not connected! Panic bunker will not work until the connection is reestablished.")
	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Toggle Panic Bunker", "[new_pb ? "Enabled" : "Disabled"]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
