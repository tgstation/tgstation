//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

/obj/machinery/mass_driver
	name = "mass driver"
	desc = "Shoots things into space."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "mass_driver"
	anchored = 1.0
	use_power = 1
	idle_power_usage = 2
	active_power_usage = 50

	var/power = 1.0
	var/code = 1.0
	var/id = 1.0
	var/drive_range = 50 //this is mostly irrelevant since current mass drivers throw into space, but you could make a lower-range mass driver for interstation transport or something I guess.


	proc/drive(amount)
		if(stat & (BROKEN|NOPOWER))
			return
		use_power(500)
		var/O_limit
		var/atom/target = get_edge_target_turf(src, dir)
		for(var/atom/movable/O in loc)
			if(!O.anchored||istype(O, /obj/mecha))//Mechs need their launch platforms.
				O_limit++
				if(O_limit >= 20)
					for(var/mob/M in hearers(src, null))
						M << "\blue The mass driver lets out a screech, it mustn't be able to handle any more items."
					break
				use_power(500)
				spawn( 0 )
					O.throw_at(target, drive_range * power, power)
		flick("mass_driver1", src)
		return
