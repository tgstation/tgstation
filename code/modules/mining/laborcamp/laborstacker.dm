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
		var/p = inserted_id:points
		var/g = inserted_id:goal
		dat += text("[p] / [g] collected. <A href='?src=\ref[src];choice=1'>Eject ID.</A><br>")
		dat += text("Unclaimed Collection Points: [machine:points].  <A href='?src=\ref[src];choice=2'>Claim points.</A><br>")
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
				var/p = inserted_id:points
				var/m = machine:points
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
	name = "stacking machine"
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "stacker"
	density = 1
	anchored = 1.0
	var/points = 0 //The unclaimed value of ore stacked.  Value for each ore loosely relative to its rarity.  Iron = 1; Diamond = 25.

/obj/machinery/mineral/stacking_machine/laborstacker/process()
	if (src.output && src.input)
		var/obj/item/O
		while (locate(/obj/item, input.loc))
			O = locate(/obj/item, input.loc)
			if (istype(O,/obj/item/stack/sheet/metal))
				ore_iron+= O:amount
				points += O:amount
				del(O)
				continue
			if (istype(O,/obj/item/stack/sheet/mineral/diamond))
				ore_diamond+= O:amount
				points += O:amount * 25
				del(O)
				continue
			if (istype(O,/obj/item/stack/sheet/mineral/plasma))
				ore_plasma+= O:amount
				points += O:amount * 2
				del(O)
				continue
			if (istype(O,/obj/item/stack/sheet/mineral/gold))
				ore_gold+= O:amount
				points += O:amount * 5
				del(O)
				continue
			if (istype(O,/obj/item/stack/sheet/mineral/silver))
				ore_silver+= O:amount
				points += O:amount * 5
				del(O)
				continue
			if (istype(O,/obj/item/stack/sheet/mineral/clown))
				ore_clown+= O:amount
				points += O:amount * 9999
				del(O)
				continue
			if (istype(O,/obj/item/stack/sheet/mineral/uranium))
				ore_uranium+= O:amount
				points += O:amount * 5
				del(O)
				continue
			if (istype(O,/obj/item/stack/sheet/glass))
				ore_glass+= O:amount
				points += O:amount
				del(O)
				continue
			if (istype(O,/obj/item/stack/sheet/rglass))
				ore_rglass+= O:amount
				points += O:amount * 2
				del(O)
				continue
			if (istype(O,/obj/item/stack/sheet/plasteel))
				ore_plasteel+= O:amount
				points += O:amount * 3
				del(O)
				continue
			if (istype(O,/obj/item/stack/sheet/mineral/adamantine))
				ore_adamantine+= O:amount
				points += O:amount * 9999
				del(O)
				continue
			if (istype(O,/obj/item/stack/sheet/mineral/mythril))
				ore_mythril+= O:amount
				points += O:amount * 9999
				del(O)
				continue
			if (istype(O,/obj/item/stack/sheet/cardboard))
				ore_cardboard+= O:amount
				del(O)
				continue
			if (istype(O,/obj/item/stack/sheet/wood))
				ore_wood+= O:amount
				del(O)
				continue
			if (istype(O,/obj/item/stack/sheet/cloth))
				ore_cloth+= O:amount
				del(O)
				continue
			if (istype(O,/obj/item/stack/sheet/leather))
				ore_leather+= O:amount
				del(O)
				continue
			if (istype(O,/obj/item/weapon/ore/slag))
				del(O)
				continue
			O.loc = src.output.loc
	if (ore_gold >= stack_amt)
		var/obj/item/stack/sheet/mineral/gold/G = new /obj/item/stack/sheet/mineral/gold
		G.amount = stack_amt
		G.loc = output.loc
		ore_gold -= stack_amt
		return
	if (ore_silver >= stack_amt)
		var/obj/item/stack/sheet/mineral/silver/G = new /obj/item/stack/sheet/mineral/silver
		G.amount = stack_amt
		G.loc = output.loc
		ore_silver -= stack_amt
		return
	if (ore_diamond >= stack_amt)
		var/obj/item/stack/sheet/mineral/diamond/G = new /obj/item/stack/sheet/mineral/diamond
		G.amount = stack_amt
		G.loc = output.loc
		ore_diamond -= stack_amt
		return
	if (ore_plasma >= stack_amt)
		var/obj/item/stack/sheet/mineral/plasma/G = new /obj/item/stack/sheet/mineral/plasma
		G.amount = stack_amt
		G.loc = output.loc
		ore_plasma -= stack_amt
		return
	if (ore_iron >= stack_amt)
		var/obj/item/stack/sheet/metal/G = new /obj/item/stack/sheet/metal
		G.amount = stack_amt
		G.loc = output.loc
		ore_iron -= stack_amt
		return
	if (ore_clown >= stack_amt)
		var/obj/item/stack/sheet/mineral/clown/G = new /obj/item/stack/sheet/mineral/clown
		G.amount = stack_amt
		G.loc = output.loc
		ore_clown -= stack_amt
		return
	if (ore_uranium >= stack_amt)
		var/obj/item/stack/sheet/mineral/uranium/G = new /obj/item/stack/sheet/mineral/uranium
		G.amount = stack_amt
		G.loc = output.loc
		ore_uranium -= stack_amt
		return
	if (ore_glass >= stack_amt)
		var/obj/item/stack/sheet/glass/G = new /obj/item/stack/sheet/glass
		G.amount = stack_amt
		G.loc = output.loc
		ore_glass -= stack_amt
		return
	if (ore_rglass >= stack_amt)
		var/obj/item/stack/sheet/rglass/G = new /obj/item/stack/sheet/rglass
		G.amount = stack_amt
		G.loc = output.loc
		ore_rglass -= stack_amt
		return
	if (ore_plasteel >= stack_amt)
		var/obj/item/stack/sheet/plasteel/G = new /obj/item/stack/sheet/plasteel
		G.amount = stack_amt
		G.loc = output.loc
		ore_plasteel -= stack_amt
		return
	if (ore_wood >= stack_amt)
		var/obj/item/stack/sheet/wood/G = new /obj/item/stack/sheet/wood
		G.amount = stack_amt
		G.loc = output.loc
		ore_wood -= stack_amt
		return
	if (ore_cardboard >= stack_amt)
		var/obj/item/stack/sheet/cardboard/G = new /obj/item/stack/sheet/cardboard
		G.amount = stack_amt
		G.loc = output.loc
		ore_cardboard -= stack_amt
		return
	if (ore_cloth >= stack_amt)
		var/obj/item/stack/sheet/cloth/G = new /obj/item/stack/sheet/cloth
		G.amount = stack_amt
		G.loc = output.loc
		ore_cloth -= stack_amt
		return
	if (ore_leather >= stack_amt)
		var/obj/item/stack/sheet/leather/G = new /obj/item/stack/sheet/leather
		G.amount = stack_amt
		G.loc = output.loc
		ore_leather -= stack_amt
		return
	if (ore_adamantine >= stack_amt)
		var/obj/item/stack/sheet/mineral/adamantine/G = new /obj/item/stack/sheet/mineral/adamantine
		G.amount = stack_amt
		G.loc = output.loc
		ore_adamantine -= stack_amt
		return
	if (ore_mythril >= stack_amt)
		var/obj/item/stack/sheet/mineral/mythril/G = new /obj/item/stack/sheet/mineral/mythril
		G.amount = stack_amt
		G.loc = output.loc
		ore_mythril -= stack_amt
		return
	return
