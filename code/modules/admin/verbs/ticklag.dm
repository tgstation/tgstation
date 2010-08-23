/client/proc/ticklag(number as num)
	set category = "Debug"
	set name = "Ticklag"
	set desc = "Ticklag"
	set hidden = 1
	if(Debug2)
		if(src.authenticated && src.holder)
			if(!src.mob)
				return
			if(src.holder.rank in list("Coder", "Host"))
				world.tick_lag = number
				log_admin("[key_name(src.mob)] set tick_lag to [number]")
				message_admins("[key_name_admin(usr)] modified world's tick_lag to [number]")
			else
				alert("Fuck off, no crashing dis server")
				return
	else
		alert("Debugging is disabled")
		return

