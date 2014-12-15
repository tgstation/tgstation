/proc/cosmic_freeze_event()

	var/turf/simulated/floor/turfs = list()

	var/area/A = locate(pick(typesof(/area/hallway,/area/crew_quarters,/area/maintenance)))
		for(var/turf/simulated/floor/F in A.contents)
			turfs += F

	if(turfs.len)
		var/turf/simulated/floor/T = pick(turfs)
		new/obj/structure/snow/cosmic(T)
		message_admins("<span class='notice'>Event: Cosmic Snow Storm spawned at [T.loc] ([T.x],[T.y],[T.z])</span>")
	else//uh oh, the chosen area had no turf/simulated/floors, how is that possible? whatever, time to reroll.
		.()