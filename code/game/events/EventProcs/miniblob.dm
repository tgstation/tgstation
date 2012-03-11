/proc/mini_blob_event()

	var/turf/T = pick(blobstart)
	if(istype(T, /turf/simulated/wall))
		T.ReplaceWithPlating()
	for(var/atom/A in T)
		if(A.density)
			del(A)
	var/obj/effect/blob/bl = new /obj/effect/blob( T.loc, 30 )
	spawn(0)
		bl.Life()
		bl.Life()
		bl.Life()
		bl.Life()
		bl.blobdebug = 1
		bl.Life()
	blobevent = 1
	spawn(0)
		dotheblobbaby()
	spawn(15000)
		blobevent = 0
	spawn(rand(600, 1800)) //Delayed announcements to keep the crew on their toes.
		command_alert("Confirmed outbreak of level 5 biohazard aboard [station_name()].", "Biohazard Alert")
		world << sound('outbreak5.ogg')

/proc/dotheblobbaby()
	if (blobevent)
		if(blobs.len)
			for(var/i = 1 to 10)
				sleep(-1)
				if(!blobs.len)	break
				var/obj/effect/blob/B = pick(blobs)
				if(B.z != 1)
					continue
				B.Life()
		spawn(150)
			dotheblobbaby()