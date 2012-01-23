/proc/mini_blob_event()
	//command_alert("Confirmed outbreak of level 5 biohazard aboard [station_name()]. All personnel must contain the outbreak.", "Biohazard Alert")
	//world << sound('outbreak5.ogg')
	var/turf/T = pick(blobstart)
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
	spawn(rand(3000, 6000)) //Delayed announcements to keep the crew on their toes.
		command_alert("Confirmed outbreak of level 5 biohazard aboard [station_name()]. All personnel must contain the outbreak.", "Biohazard Alert")
		world << sound('outbreak5.ogg')

/proc/dotheblobbaby()
	if (blobevent)
		if(active_blobs.len)
			for(var/i = 1 to 10)
				sleep(-1)
				if(!active_blobs.len)	break
				var/obj/effect/blob/B = pick(active_blobs)
				if(B.z != 1)
					continue
				B.Life()
		spawn(150)
			dotheblobbaby()