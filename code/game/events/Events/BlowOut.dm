/area/var/radsafe = 0
/area/maintenance/radsafe = 1
/area/ai_monitored/maintenance/radsafe = 1
/area/centcom/radsafe = 1
/area/admin/radsafe = 1
/area/adminsafety/radsafe = 1
/area/shuttle/radsafe = 1
/area/syndicate_station/radsafe = 1
/area/asteroid/radsafe = 1
/area/crew_quarters/sleeping/radsafe = 1

/datum/event/blowout
	Lifetime = 150
	Announce()
		if(!forced && prob(90))
			ActiveEvent = null
			SpawnEvent()
			del src
			return
		command_alert("Warning: station approaching high-density radiation cloud. Seek cover immediately.")
	Tick()
		if(ActiveFor == 50)
			command_alert("Station has entered radiation cloud. Do not leave cover until it has passed.")
		if(ActiveFor == 100 || ActiveFor == 150)	//1/2 and 2/2 f the way after it start proper make peope be half dead mostly
			for(var/mob/living/carbon/M in world)
				var/area = get_area(M)
				if(area:radsafe)
					continue
				if(!M.stat)
					M.radiate(100)
	Die()
		command_alert("The station has cleared the radiation cloud. It is now safe to leave cover.")