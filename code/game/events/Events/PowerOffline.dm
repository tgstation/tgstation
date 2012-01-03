/datum/event/power_offline
	Announce()
		command_alert("The ship is performing an automated power system grid check, please stand by.", "Maintenance alert")
		for(var/obj/machinery/power/apc/a in world)
			if(!a.crit)
				a.eventoff = 1
				spawn(200)
					a.eventoff = 0 /*Got a few bug reports about this, disabling for now --Mloc*/
