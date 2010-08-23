/obj/machinery/computer/crew
	name = "crew monitoring computer"
	icon_state = "comm"


/obj/machinery/computer/crew/attack_ai(mob/user)
	add_fingerprint(user)

	if(stat & (BROKEN|NOPOWER))
		return
	interact(user)

/obj/machinery/computer/crew/attack_hand(mob/user)
	add_fingerprint(user)

	if(stat & (BROKEN|NOPOWER))
		return
	interact(user)


/obj/machinery/computer/crew/proc/interact(mob/user)

	if ( (get_dist(src, user) > 1 ) || (stat & (BROKEN|NOPOWER)) )
		if (!istype(user, /mob/living/silicon))
			user.machine = null
			user << browse(null, "window=powcomp")
			return


	user.machine = src
	var/t = "<TT><B>Crew Monitoring</B><HR>"
	t += "<table><tr><td>Name</td><td>Vitals</td><td>Position</td></tr>"
	var/list/tracked = list()

	for(var/obj/item/clothing/under/C in world)
		if(istype(C.loc, /mob/living/carbon/human))
			tracked.Add(C.loc)

	for(var/mob/living/carbon/human/H in tracked)
		for(var/obj/item/clothing/under/C in H)
			if(H.z != 1 || istype(H.loc, /turf/space))
				if(C.mode > 0)
					t += "<tr><td>[H.name]</td><td></td><td>Not Available</td></tr>"
				break
			switch(C.mode)
				//if(0)
					//t += "<tr><td>Not Available</td><td>Not Available</td><td>Not Available</td></tr>"
				if(1)
					t += "<tr><td>[H.name]</td><td>[H.stat > 1 ? "<font color=red>Deceased</font>" : "Living"]</td><td>Not Available</td></tr>"
				if(2)
					t += "<tr><td>[H.name]</td><td>[H.stat > 1 ? "<font color=red>Deceased</font>" : "Living"], [H.oxyloss] - [H.toxloss] - [H.fireloss] - [H.bruteloss]</td><td>Not Available</td></tr>"
				if(3)
					var/turf/mob_loc = get_turf_loc(H)
					t += "<tr><td>[H.name]</td><td>[H.stat > 1 ? "<font color=red>Deceased</font>" : "Living"], [H.oxyloss] - [H.toxloss] - [H.fireloss] - [H.bruteloss]</td><td>[mob_loc.loc] ([H.x], [H.y])</td></tr>"
			break

	t += "</table>"
	t += "</FONT></PRE>"

	t += "<BR><HR><A href='?src=\ref[src];close=1'>Close</A></TT>"

	user << browse(t, "window=crewcomp;size=420x700")
	onclose(user, "crewcomp")


/obj/machinery/computer/crew/Topic(href, href_list)
	..()
	if( href_list["close"] )
		usr << browse(null, "window=crewcomp")
		usr.machine = null
		return

/obj/machinery/computer/crew/process()
	if(!(stat & (NOPOWER|BROKEN)) )
		use_power(250)

	src.updateDialog()


/obj/machinery/computer/crew/power_change()

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

