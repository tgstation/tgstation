/proc/cosmic_freeze_event()

	var/list/turf/simulated/floor/turfs = list()

	var/area/A = locate(pick(typesof(/area/hallway,/area/crew_quarters,/area/maintenance)))
	var/area/B = pick(A.related)

	for(var/turf/simulated/floor/F in B.contents)
		if(F.z == map.zMainStation)
			var/blocked = 0

			for(var/atom/AT in F)
				if(AT.density)
					blocked = 1

			if(!blocked)
				turfs += F

	if(turfs.len)
		var/turf/simulated/floor/T = pick(turfs)
		new/obj/structure/snow/cosmic(T)
		message_admins("<span class='notice'>Event: Cosmic Snow Storm spawned at <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[T.x];Y=[T.y];Z=[T.z]'>[T.loc] ([T.x],[T.y],[T.z])</a></span>")
		return T
	else
		return .()