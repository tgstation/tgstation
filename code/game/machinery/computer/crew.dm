/obj/machinery/computer/crew/attackby(I as obj, user as mob)
	if(istype(I, /obj/item/weapon/screwdriver))
		playsound(src.loc, 'Screwdriver.ogg', 50, 1)
		if(do_after(user, 20))
			if (src.stat & BROKEN)
				user << "\blue The broken glass falls out."
				var/obj/computerframe/A = new /obj/computerframe( src.loc )
				new /obj/item/weapon/shard( src.loc )
				var/obj/item/weapon/circuitboard/crew/M = new /obj/item/weapon/circuitboard/crew( A )
				for (var/obj/C in src)
					C.loc = src.loc
				A.circuit = M
				A.state = 3
				A.icon_state = "3"
				A.anchored = 1
				del(src)
			else
				user << "\blue You disconnect the monitor."
				var/obj/computerframe/A = new /obj/computerframe( src.loc )
				var/obj/item/weapon/circuitboard/crew/M = new /obj/item/weapon/circuitboard/crew( A )
				for (var/obj/C in src)
					C.loc = src.loc
				A.circuit = M
				A.state = 4
				A.icon_state = "4"
				A.anchored = 1
				del(src)
	else
		src.attack_hand(user)
	return

/obj/machinery/computer/crew
	New()
		tracked = list()
		..()


	attack_ai(mob/user)
		attack_hand(user)
		interact(user)


	attack_hand(mob/user)
		add_fingerprint(user)
		if(stat & (BROKEN|NOPOWER))
			return
		interact(user)


	process()
		return


	power_change()
		if(stat & BROKEN)
			icon_state = "broken"
		else
			if( powered() )
				icon_state = initial(icon_state)
				stat &= ~NOPOWER
			else
				spawn(rand(0, 15))
					src.icon_state = "c_unpowered"
					stat |= NOPOWER


	Topic(href, href_list)
		..()
		if( href_list["close"] )
			usr << browse(null, "window=crewcomp")
			usr.machine = null
			return
		if(href_list["update"])
			src.updateDialog()
			return


	proc
		interact(mob/user)
			if ( (get_dist(src, user) > 1 ) || (stat & (BROKEN|NOPOWER)) )
				if (!istype(user, /mob/living/silicon))
					user.machine = null
					user << browse(null, "window=powcomp")
					return
			user.machine = src
			src.scan()
			var/t = "<TT><B>Crew Monitoring</B><HR>"
			t += "<BR><A href='?src=\ref[src];update=1'>Refresh</A>"
			t += "<BR><A href='?src=\ref[src];close=1'>Close</A>"
			t += "<table><tr><td>Name</td><td>Vitals</td><td>Position</td></tr>"
			for(var/obj/item/clothing/under/C in src.tracked)
				if((C) && (C.has_sensor) && (C.loc) && (C.loc.z == 1))
					if(istype(C.loc, /mob/living/carbon/human))
						var/mob/living/carbon/human/H = C.loc
						var/dam1 = round(H.oxyloss,1)
						var/dam2 = round(H.toxloss,1)
						var/dam3 = round(H.fireloss,1)
						var/dam4 = round(H.bruteloss,1)
						switch(C.sensor_mode)
							if(1)
								if(H.wear_id)
									t += "<tr><td>[H.wear_id.name]</td><td>"
								else
									t += "<tr><td>Unknown:</td><td>"
								t+= "[H.stat > 1 ? "<font color=red>Deceased</font>" : "Living"]</td><td>Not Available</td></tr>"
							if(2)
								if(H.wear_id)
									t += "<tr><td>[H.wear_id.name]</td><td>"
								else
									t += "<tr><td>Unknown:</td><td>"
								t += "[H.stat > 1 ? "<font color=red>Deceased</font>" : "Living"], [dam1] - [dam2] - [dam3] - [dam4]</td><td>Not Available</td></tr>"
							if(3)
								t += "<tr><td>[H.name]</td><td>[H.stat > 1 ? "<font color=red>Deceased</font>" : "Living"], [dam2] - [dam2] - [dam3] - [dam4]</td><td>[get_area(H)] ([H.x], [H.y])</td></tr>"
			t += "</table>"
			t += "</FONT></PRE></TT>"
			user << browse(t, "window=crewcomp;size=500x800")
			onclose(user, "crewcomp")

		scan()
			for(var/obj/item/clothing/under/C in world)
				if((C.has_sensor) && (istype(C.loc, /mob/living/carbon/human)))
					var/check = 0
					for(var/O in src.tracked)
						if(O == C)
							check = 1
							break
					if(!check)
						src.tracked.Add(C)
			return 1