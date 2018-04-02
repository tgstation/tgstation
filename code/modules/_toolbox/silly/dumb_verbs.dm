/*/datum/admin/proc/guns_everywhere()
	set name = "America Fuck Yeah"
	set category = "Fun"
	var/list/turflist = list()
	for(var/turf/T in world)
		if(T.z != ZLEVEL_STATION)
			continue
		if(T.density)
			continue
		var/list/containers = list(
			/obj/structure/rack,
			/obj/structure/table,
			/obj/structure/closet)
		var/obj/container = null
		var/obj/Odensity = 0
		for(var/obj/O in T)
			for(var/type in O)
				if(istype(O,type))
					container = O
					break
			if(container)
				break
			if(O.density)
				Odensity = 1
				break
		if(Odensity && !container)
			continue
		if(container)
			turflist += container
		else
			turflist += T
	if(turflist.len)
		for(var/atom/A in turflist)
			if(prob(5))
				if(istype(A,/obj/structure/closet))
					var/obj/structure/closet/C = A
					if(C.density)*/




