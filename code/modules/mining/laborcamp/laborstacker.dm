/**********************Prisoners' Console**************************/

/obj/machinery/mineral/labor_claim_console
	name = "Point Claim Console"
	desc = "A stacking console with an electromagnetic writer, used to track ore mined by prisoners."
	name = "stacking machine console"
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "console"
	density = 0
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
			qdel(src)

/obj/machinery/mineral/labor_claim_console/proc/check_auth()
	if(emagged) return 1 //Shuttle is emagged, let any ol' person through
	return (istype(inserted_id) && inserted_id.points >= inserted_id.goal) //Otherwise, only let them out if the prisoner's reached his quota.


/obj/machinery/mineral/labor_claim_console/attack_hand(user as mob)
	name = "Point Claim Console"
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "console"
	desc = "A stacking console with an electromagnetic writer, used to track ore mined by prisoners."
	density = 0
	anchored = 1
	var/dat
	dat += text("<b>Point Claim Console</b><br><br>")
	if(emagged) //Shit's broken
		dat += text("<b>QU&#t0A In%aL*D</b><br>")
	else if(istype(inserted_id)) //There's an ID in there.
		dat += text("[inserted_id.points] / [inserted_id.goal] collected. <A href='?src=\ref[src];choice=eject'>Eject ID.</A><br>")
		dat += text("Unclaimed Collection Points: [machine.points].  <A href='?src=\ref[src];choice=claim'>Claim points.</A><br>")
	else	//No ID in sight.  Complain about it.
		dat += text("No ID inserted.  <A href='?src=\ref[src];choice=insert'>Insert ID.</A><br>")
	if(check_auth())
		dat += text("<A href='?src=\ref[src];choice=station'>Proceed to Station.</A><br>")
		dat += text("<A href='?src=\ref[src];choice=release'>Open release door.</A><br>")
	if(machine)
		dat += text("<HR><b>Mineral Value List:</b><BR>[machine.get_ore_values()]")


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
		if(istype(inserted_id)) //Sanity check against href spoofs
			if(href_list["choice"] == "eject")
				inserted_id.loc = loc
				inserted_id.verb_pickup()
				inserted_id = null
			if(href_list["choice"] == "claim")
				inserted_id.points += machine.points
				machine.points = 0
				src << "Points transferred."
		else if(href_list["choice"] == "insert")
			var/obj/item/weapon/card/id/prisoner/I = usr.get_active_hand()
			if(istype(I))
				usr.drop_item()
				I.loc = src
				inserted_id = I
			else usr << "\red No valid ID."
		if(check_auth()) //Sanity check against hef spoofs
			if(href_list["choice"] == "station")
				var/datum/shuttle_manager/s = shuttles["laborcamp"]
				if(s.location == /area/shuttle/laborcamp/outpost)
					if(alone_in_area(get_area(loc), usr))
						if (s.move_shuttle(0)) // No delay, to stop people from getting on while it is departing.
							usr << "\blue Shuttle recieved message and will be sent shortly."
						else
							usr << "\blue Shuttle is already moving."
					else
						usr << "\red Prisoners are only allowed to be released while alone."
				else
					usr << "\blue Shuttle is already on-station."
			if(href_list["choice"] == "release")
				if(alone_in_area(get_area(loc), usr))
					if(release_door.density)
						release_door.open()
				else
					usr << "\red Prisoners are only allowed to be released while alone."
		src.updateUsrDialog()
	return


/**********************Prisoner Collection Unit**************************/


/obj/machinery/mineral/stacking_machine/laborstacker
	var/points = 0 //The unclaimed value of ore stacked.  Value for each ore loosely relative to its rarity.
	var/list/ore_values = list(("glass" = 1), ("metal" = 2), ("solid plasma" = 20), ("plasteel" = 23), ("reinforced glass" = 4), ("gold" = 20), ("silver" = 20), ("uranium" = 20), ("diamond" = 25), ("bananium" = 50))

/obj/machinery/mineral/stacking_machine/laborstacker/proc/get_ore_values()
	var/dat = "<table border='0' width='200'>"
	for(var/ore in ore_values)
		var/value = ore_values[ore]
		dat += "<tr><td>[capitalize(ore)]</td><td>[value]</td></tr>"
	dat += "</table>"
	return dat

/obj/machinery/mineral/stacking_machine/laborstacker/process_sheet(obj/item/stack/sheet/inp)
	if(istype(inp))
		var/n = inp.name
		var/a = inp.amount
		if(n in ore_values)
			points += ore_values[n] * a
	..()