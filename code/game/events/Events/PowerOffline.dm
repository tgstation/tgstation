/datum/event/power_offline
	var/list/protected_areas = list(/area/ai_monitored/storage/eva, /area/engine, /area/toxins/xenobiology, /area/turret_protected/ai)

	Announce()
		for(var/obj/machinery/power/apc/a in world)
			if(!a.crit && a.z == 1)
				if(a.area in protected_areas)
					continue
				a.eventoff = 1
				a.update()

	Die()
		command_alert("The station has finished an automated power system grid check, thank you.", "Maintenance alert")
		for(var/obj/machinery/power/apc/a in world)
			if(!a.crit)
				a.eventoff = 0
				a.update()