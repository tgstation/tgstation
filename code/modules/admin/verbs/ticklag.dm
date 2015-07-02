//Merged Doohl's and the existing ticklag as they both had good elements about them ~Carn

/client/proc/ticklag()
	set category = "Debug"
	set name = "Set Ticklag"
	set desc = "Sets a new tick lag. Recommend you don't mess with this too much! Stable, time-tested ticklag value is 0.9"

	if(!check_rights(R_DEBUG))	return

	var/newtick = input("Sets a new tick lag. Please don't mess with this too much! The stable, time-tested ticklag value is 0.9","Lag of Tick", world.tick_lag) as num|null
	//I've used ticks of 2 before to help with serious singulo lags
	if(newtick && newtick <= 2 && newtick > 0)
		log_admin("[key_name(src)] has modified world.tick_lag to [newtick]", 0)
		message_admins("[key_name(src)] has modified world.tick_lag to [newtick]", 0)
		world.tick_lag = newtick
		feedback_add_details("admin_verb","TICKLAG") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		var/origtick = 0.9
		if(processScheduler && processScheduler.processes && processScheduler.processes.len)
			for(var/datum/controller/process/P in processScheduler.processes)
				if(P.name == "inactivity") continue
				if(newtick == origtick) P.schedule_interval = initial(P.schedule_interval)
				else
					var/intv = P.schedule_interval
					P.schedule_interval = round(initial(P.schedule_interval) / (newtick /origtick), 1)
					testing("Set [P.name]'s schedule_interval to [P.schedule_interval] old: [intv], original: [initial(P.schedule_interval)] ratio applied: [newtick/origtick]")
	else
		src << "<span class='warning'>Error: ticklag(): Invalid world.ticklag value. No changes made.</span>"


