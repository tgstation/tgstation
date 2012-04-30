//new supermatter lasers

/obj/machinery/emitter/zero_point_laser
	name = "Zero-point laser"
	desc = "A super-powerful laser"
	icon = 'engine.dmi'
	icon_state = "laser"
	mega_energy = 0.0001

	var/freq = 50000
	var/id

	Topic(href, href_list)
		..()
		if( href_list["input"] )
			var/i = text2num(href_list["input"])
			var/d = i
			var/new_power = mega_energy + d
			new_power = max(new_power,0.0001)	//lowest possible value
			new_power = min(new_power,0.01)		//highest possible value
			mega_energy = new_power
			//
			for(var/obj/machinery/computer/lasercon/comp in world)
				if(comp.id == src.id)
					comp.updateDialog()
		else if( href_list["online"] )
			active = !active
			//
			for(var/obj/machinery/computer/lasercon/comp in world)
				if(comp.id == src.id)
					comp.updateDialog()
		else if( href_list["freq"] )
			var/amt = text2num(href_list["freq"])
			var/new_freq = frequency + amt
			new_freq = max(new_freq,1)		//lowest possible value
			new_freq = min(new_freq,20000)	//highest possible value
			frequency = new_freq
			//
			for(var/obj/machinery/computer/lasercon/comp in world)
				if(comp.id == src.id)
					comp.updateDialog()

	update_icon()
		if (active && !(stat & (NOPOWER|BROKEN)))
			icon_state = "laser"//"emitter_+a"
		else
			icon_state = "laser"//"emitter"

	process()
		var/curstate = active
		..()
		if(active != curstate)
			for(var/obj/machinery/computer/lasercon/comp in world)
				if(comp.id == src.id)
					comp.updateDialog()
