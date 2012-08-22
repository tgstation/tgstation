/datum/event/power_offline
	Announce()
		for(var/obj/machinery/power/apc/a in world)
			if(!a.crit && a.z == 1)
				if(istype(a.area, /area/ai_monitored/storage/eva) || istype(a.area, /area/engine)\
				|| istype(a.area, /area/toxins/xenobiology) || istype(a.area, /area/turret_protected/ai))
					continue
				a.eventoff = 1
				a.update()

	Die()
		command_alert("The station has finished an automated power system grid check, thank you.", "Maintenance alert")
		for(var/obj/machinery/power/apc/a in world)
			if(!a.crit)
				a.eventoff = 0
				a.update()