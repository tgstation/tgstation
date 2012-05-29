/obj/machinery/particle_accelerator/control_box
	name = "Particle Accelerator Control Computer"
	desc = "This controls the density of the particles."
	icon = 'particle_accelerator.dmi'
	icon_state = "control_box"
	reference = "control_box"
	anchored = 0
	density = 1
	use_power = 0
	idle_power_usage = 500
	active_power_usage = 10000
	construction_state = 0
	active = 0
	var/list/obj/structure/particle_accelerator/connected_parts
	var/assembled = 0
	var/parts = null


	New()
		connected_parts = list()
		..()


	attack_hand(mob/user as mob)
		if(construction_state >= 3)
			interact(user)


	update_state()
		if(construction_state < 3)
			use_power = 0
			assembled = 0
			active = 0
			connected_parts = list()
			return
		if(!part_scan())
			use_power = 1
			active = 0
			connected_parts = list()

		return

	update_icon()
		if(active)
			icon_state = "[reference]p1"
		else
			if(use_power)
				icon_state = "[reference]p"
			else
				switch(construction_state)
					if(0)
						icon_state = "[reference]"
					if(1)
						icon_state = "[reference]"
					if(2)
						icon_state = "[reference]w"
					else
						icon_state = "[reference]c"
		return

	update_icon()
		..()
		return

	Topic(href, href_list)
		..()
		//Ignore input if we are broken, !silicon guy cant touch us, or nonai controlling from super far away
		if(stat & (BROKEN|NOPOWER) || (get_dist(src, usr) > 1 && !istype(usr, /mob/living/silicon)) || (get_dist(src, usr) > 8 && !istype(usr, /mob/living/silicon/ai)))
			usr.machine = null
			usr << browse(null, "window=pacontrol")
			return

		if( href_list["close"] )
			usr << browse(null, "window=pacontrol")
			usr.machine = null
			return
		if(href_list["togglep"])
			src.toggle_power()
			investigate_log("turned [active?"<font color='red'>ON</font>":"<font color='green'>OFF</font>"] by [usr.key]","singulo")
			message_admins("[usr] toggled particle accelerator power to [active ? "on" : "off"].")
			log_admin("[usr] toggled particle accelerator power to [active ? "on" : "off"].")
		else if(href_list["scan"])
			src.part_scan()
		else if(href_list["strengthup"])
			strength++
			if(strength > 2)
				strength = 2
			else
				investigate_log("increased to <font color='red'>[strength]</font> by [usr.key]","singulo")
				message_admins("[usr] increased particle accelerator power to [strength].")
				log_admin("[usr] increased particle accelerator power to [strength].")
			for(var/obj/structure/particle_accelerator/part in connected_parts)
				part.strength = strength
				part.update_icon()

		else if(href_list["strengthdown"])
			strength--
			if(strength < 0)
				strength = 0
			else
				message_admins("[usr] decreased particle accelerator power to [strength].")
				log_admin("[usr] decreased particle accelerator power to [strength].")
				investigate_log("decreased to <font color='green'>[strength]</font> by [usr.key]","singulo")
			for(var/obj/structure/particle_accelerator/part in connected_parts)
				part.strength = strength
				part.update_icon()
		src.updateDialog()
		src.update_icon()
		return


	power_change()
		..()
		if(stat & NOPOWER)
			active = 0
			use_power = 0
		else if(!stat && construction_state == 3)
			use_power = 1
		return


	process()
		if(src.active)
			//a part is missing!
			if( length(connected_parts) < 6 )
				investigate_log("lost a connected part; It <font color='red'>powered down</font>.","singulo")
				src.toggle_power()
				return
			//emit some particles
			for(var/obj/structure/particle_accelerator/particle_emitter/PE in connected_parts)
				if(PE)
					PE.emit_particle(src.strength)
		return


	proc
		part_scan()
			connected_parts = list()
			var/tally = 0
			var/ldir = turn(dir,-90)
			var/rdir = turn(dir,90)
			var/odir = turn(dir,180)
			var/turf/T = src.loc
			T = get_step(T,rdir)
			if(check_part(T,/obj/structure/particle_accelerator/fuel_chamber))
				tally++
			T = get_step(T,odir)
			if(check_part(T,/obj/structure/particle_accelerator/end_cap))
				tally++
			T = get_step(T,dir)
			T = get_step(T,dir)
			if(check_part(T,/obj/structure/particle_accelerator/power_box))
				tally++
			T = get_step(T,dir)
			if(check_part(T,/obj/structure/particle_accelerator/particle_emitter/center))
				tally++
			T = get_step(T,ldir)
			if(check_part(T,/obj/structure/particle_accelerator/particle_emitter/left))
				tally++
			T = get_step(T,rdir)
			T = get_step(T,rdir)
			if(check_part(T,/obj/structure/particle_accelerator/particle_emitter/right))
				tally++
			if(tally >= 6)
				assembled = 1
				return 1
			else
				assembled = 0
				return 0


		check_part(var/turf/T, var/type)
			if(!(T)||!(type))
				return 0
			var/obj/structure/particle_accelerator/PA = locate(/obj/structure/particle_accelerator) in T
			if(istype(PA, type))
				if(PA.connect_master(src))
					if(PA.report_ready(src))
						src.connected_parts.Add(PA)
						return 1
			return 0


		toggle_power()
			src.active = !src.active
			if(src.active)
				src.use_power = 2
				for(var/obj/structure/particle_accelerator/part in connected_parts)
					part.strength = src.strength
					part.powered = 1
					part.update_icon()
			else
				src.use_power = 1
				for(var/obj/structure/particle_accelerator/part in connected_parts)
					part.strength = null
					part.powered = 0
					part.update_icon()
			return 1


		interact(mob/user)
			if((get_dist(src, user) > 1) || (stat & (BROKEN|NOPOWER)))
				if(!istype(user, /mob/living/silicon))
					user.machine = null
					user << browse(null, "window=pacontrol")
					return
			user.machine = src

			var/dat = ""
			dat += "Particle Accelerator Control Panel<BR>"
			dat += "<A href='?src=\ref[src];close=1'>Close</A><BR><BR>"
			dat += "Status:<BR>"
			if(!assembled)
				dat += "Unable to detect all parts!<BR>"
				dat += "<A href='?src=\ref[src];scan=1'>Run Scan</A><BR><BR>"
			else
				dat += "All parts in place.<BR><BR>"
				dat += "Power:"
				if(active)
					dat += "On<BR>"
				else
					dat += "Off <BR>"
				dat += "<A href='?src=\ref[src];togglep=1'>Toggle Power</A><BR><BR>"
				dat += "Particle Strength: [src.strength] "
				dat += "<A href='?src=\ref[src];strengthdown=1'>--</A>|<A href='?src=\ref[src];strengthup=1'>++</A><BR><BR>"

			user << browse(dat, "window=pacontrol;size=420x500")
			onclose(user, "pacontrol")
			return
