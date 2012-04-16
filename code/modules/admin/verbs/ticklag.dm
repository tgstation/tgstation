//Merged Doohl's and the existing ticklag as they both had good elements about them ~Carn

/client/proc/ticklag()
	set category = "Debug"
	set name = "Set Ticklag"
	set desc = "Sets a new tick lag. Recommend you don't mess with this too much! Stable, time-tested ticklag value is 0.9"
	if(Debug2)
		if(src.holder)
			if(!src.mob)	return

			if(src.holder.rank in list("Game Admin", "Game Master"))
				var/newtick = input("Sets a new tick lag. Please don't mess with this too much! The stable, time-tested ticklag value is 0.9",, 0.9) as num|null
				//I've used ticks of 2 before to help with serious singulo lags
				if(newtick && newtick <= 2 && newtick > 0)
					log_admin("[key_name(src)] has modified world.tick_lag to [newtick]", 0)
					message_admins("[key_name(src)] has modified world.tick_lag to [newtick]", 0)
					world.tick_lag = newtick
					feedback_add_details("admin_verb","TICKLAG") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
					return
				src << "\red Error: ticklag(): Invalid world.ticklag value. No changes made."
				return

			src << "\red Error: ticklag(): You are not authorised to use this. Game Admins and higher only."
			return
	else
		src << "\red Error: ticklag(): You must first enable Debugging mode."
		return