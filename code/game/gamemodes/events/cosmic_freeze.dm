/proc/cosmic_freeze_event()

	spawn() //to stop the secrets panel hanging
		var/list/turf/simulated/floor/turfs = list()
		for(var/areapath in typesof(/area/hallway,/area/crew_quarters,/area/maintenance))
			var/area/A = locate(areapath)
			for(var/area/B in A.related)
				for(var/turf/simulated/floor/F in B.contents)
					if(!F.contents.len)
						turfs += F

		if(turfs.len) //Pick a turf to spawn at if we can
			var/turf/simulated/floor/T = pick(turfs)
			new/obj/structure/snow/cosmic(T)
			message_admins("\blue Event: Cosmic snow spawned at [T.loc] ([T.x],[T.y],[T.z])")
