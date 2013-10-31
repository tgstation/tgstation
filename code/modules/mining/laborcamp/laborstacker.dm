/**********************Prisoners' Console**************************/

/obj/machinery/mineral/labor_claim_console
	name = "Point Claim Console"
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "console"
	desc = "A stacking console with an electromagnetic writer, used to track ore mined by prisoners."
	density = 1
	anchored = 1
	var/obj/machinery/mineral/stacking_machine/laborstacker/machine = null
	var/machinedir = SOUTH
	var/obj/item/weapon/card/id/prisoner/inserted_id
	var/obj/machinery/door/airlock/release_door
	var/door_tag = "prisonshuttle"

/obj/machinery/mineral/labor_claim_console/New()
	..()
	spawn(7)
		src.machine = locate(/obj/machinery/mineral/stacking_machine, get_step(src, machinedir))
		var/t
		for(var/obj/machinery/door/airlock/d in range(5,src))
			t = d.id_tag
			if(t == src.door_tag)
				src.release_door = d
		if (machine && release_door)
			machine.CONSOLE = src
		else
			del(src)

/obj/machinery/mineral/labor_claim_console/attack_hand(user as mob)
	var/dat
	dat += text("<b>Point Claim Console</b><br><br>")
	if(emagged)
		dat += text("<b>QU&#t0A In%aL*D</b><br>")
		dat += text("<A href='?src=\ref[src];choice=3'>Proceed to Station.</A><br>")
		dat += text("<A href='?src=\ref[src];choice=4'>Open release door.</A><br>")
	if(istype(inserted_id))
		var/p = inserted_id.points
		var/g = inserted_id.goal
		dat += text("[p] / [g] collected. <A href='?src=\ref[src];choice=1'>Eject ID.</A><br>")
		dat += text("Unclaimed Collection Points: [machine.points].  <A href='?src=\ref[src];choice=2'>Claim points.</A><br>")
		if(p >= g)
			dat += text("<b>Quota met.</b><br>")
			dat += text("<A href='?src=\ref[src];choice=3'>Proceed to Station.</A><br>")
			dat += text("<A href='?src=\ref[src];choice=4'>Open release door.</A><br>")
	else
		dat += text("No ID inserted.  <A href='?src=\ref[src];choice=0'>Insert ID.</A><br>")


	user << browse("[dat]", "window=console_stacking_machine")


/obj/machinery/mineral/labor_claim_console/attackby(obj/item/I as obj, mob/user as mob)
	if(istype(I, /obj/item/weapon/card/emag))
		emagged = 1
		user << "<span class='warning'>PZZTTPFFFT</span>"
		return
	else if(istype(I, /obj/item/weapon/card/id))
		return attack_hand(user)
	..()





/obj/machinery/mineral/labor_claim_console/Topic(href, href_list)
	usr.set_machine(src)
	src.add_fingerprint(usr)
	if(href_list["choice"])
		switch(href_list["choice"])
			if("0")
				var/obj/item/weapon/card/id/prisoner/I = usr.get_active_hand()
				if(istype(I))
					usr.drop_item()
					I.loc = src
					inserted_id = I
				else usr << "\red No valid ID."
			if("1")
				inserted_id.loc = get_step(src,get_turf(usr))
				inserted_id = null
			if("2")
				var/p = inserted_id.points
				var/m = machine.points
				p += m
				m = 0
				src << "Points transferred."
			if("3")
				if(labor_shuttle_location == 1)
					if (!labor_shuttle_moving)
						usr << "\blue Shuttle recieved message and will be sent shortly."
						move_labor_shuttle()
					else
						usr << "\blue Shuttle is already moving."
				else
					usr << "\blue Shuttle is already on-station."
			if("4")
				if(release_door.density)
					release_door.open()

	src.updateUsrDialog()
	return


/**********************Prisoner Collection Unit**************************/


/obj/machinery/mineral/stacking_machine/laborstacker
	var/points = 0 //The unclaimed value of ore stacked.  Value for each ore loosely relative to its rarity.  Iron = 1; Diamond = 25.
	var/list/ore_values = list(("metal" = 1), ("diamond" = 25), ("solid plasma" = 2), ("gold" = 5), ("silver" = 5), ("bananium" = 9999), ("uranium" = 5), ("glass" = 1), ("reinforced glass" = 2), ("plasteel" = 3))

/obj/machinery/mineral/stacking_machine/laborstacker/process_sheet(obj/item/stack/sheet/inp)
	if(istype(inp))
		var/n = inp.name
		var/a = inp.amount
		if(n in ore_values)
			points += ore_values[n] * a
	..()