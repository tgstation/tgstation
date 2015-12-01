/client/proc/ticklag()
	set category = "Debug"
	set name = "Set Ticklag"
	set desc = "Sets a new tick lag. Recommend you don't mess with this too much! The standard value has been .55 for some time"

	if(!check_rights(R_DEBUG))	return

	var/newtick = input("Sets a new tick lag. Please don't mess with this too much! The standard value has been .55 for some time","Lag of Tick", world.tick_lag) as num|null
	if(!newtick)
		return
	//I've used ticks of 2 before to help with serious singulo lags
	if(newtick <= 2 && newtick > 0)
		log_admin("[key_name(src)] has modified world.tick_lag to [newtick]", 0)
		message_admins("[key_name(src)] has modified world.tick_lag to [newtick]", 0)
		world.tick_lag = newtick
		feedback_add_details("admin_verb","TICKLAG") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	else
		to_chat(src, "<span class='warning'>Error: ticklag(): Invalid world.ticklag value. No changes made.</span>")
