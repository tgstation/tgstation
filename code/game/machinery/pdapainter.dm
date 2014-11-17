/*
!!STOLED!! from TGstation.
Feel free to do whatever with this if you think it lacks.

-Heredth
*/

/obj/machinery/pdapainter
	name = "\improper PDA painter"
	desc = "A PDA painting machine. To use, simply insert a PDA and choose the desired preset paint scheme."
	icon = 'icons/obj/pda.dmi'
	icon_state = "pdapainter"
	density = 1
	anchored = 1
	var/obj/item/device/pda/storedpda = null
	var/list/colorlist = list()

	var/busy = 0

	var/last_print = 0 //No spamming PDA printing
	var/build_time = 200 //could change in the future
	var/blocked = list(/obj/item/device/pda/ai/pai,
						/obj/item/device/pda/ai,
						/obj/item/device/pda/heads,
						/obj/item/device/pda/clear,
						/obj/item/device/pda/syndicate)

	machine_flags = SCREWTOGGLE | CROWDESTROY | WRENCHMOVE

/obj/machinery/pdapainter/RefreshParts()
	var/i = 0
	var/total_rating = 0
	for(var/obj/item/weapon/stock_parts/micro_laser/ML in component_parts)
		total_rating += ML.rating
		i++
	if(!total_rating || !i)
		total_rating = 1
	total_rating = total_rating / i //takes the average

	build_time = 250 - (total_rating * 50) //faster is better
	return

/obj/machinery/pdapainter/update_icon()
	overlays.Cut()

	if(stat & BROKEN)
		icon_state = "[initial(icon_state)]-broken"
		return

	if(storedpda)
		overlays += "[initial(icon_state)]-closed"

	if(powered())
		icon_state = initial(icon_state)
	else
		icon_state = "[initial(icon_state)]-off"

	return

/obj/machinery/pdapainter/New()
	..()

	component_parts = newlist(
							/obj/item/weapon/circuitboard/pdapainter,
	 						/obj/item/weapon/stock_parts/manipulator,
							/obj/item/weapon/stock_parts/micro_laser,
							/obj/item/weapon/stock_parts/micro_laser,
							/obj/item/weapon/stock_parts/scanning_module,
							/obj/item/weapon/stock_parts/scanning_module,
							/obj/item/weapon/stock_parts/console_screen
			)

	for(var/P in typesof(/obj/item/device/pda) - blocked)
		var/obj/item/device/pda/D = P
		src.colorlist[initial(D.name)] = D

	RefreshParts()

/obj/machinery/pdapainter/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(busy)
		user << "\The [src] is currently busy, try again later."
		return

	if(..())
		return 1

	if(istype(O, /obj/item/device/pda))
		if(storedpda)
			user << "There is already a PDA inside."
			return
		else
			var/obj/item/device/pda/P = O
			if(istype(P))
				user.drop_item(P)
				storedpda = P
				P.loc = src
				//P.add_fingerprint(usr)
				update_icon()

/obj/machinery/pdapainter/attack_hand(mob/user as mob)
	..()

	src.add_fingerprint(user)
	if(storedpda)
		var/chosenPDA
		chosenPDA = input(user, "Select your color.", "PDA Painting") as null|anything in colorlist
		if(!chosenPDA)
			return
		if(!in_range(src, user))
			return

		busy = 1
		var/obj/item/device/pda/P = colorlist[chosenPDA]

		storedpda.icon_state = initial(P.icon_state)
		storedpda.desc = initial(P.desc)
		if(!storedpda.owner)
			storedpda.name = initial(P.name)

		sleep(10)
		src.visible_message("\icon [src] \The [src] beeps: \"Successfully recolored to \a [storedpda]\"")
		busy = 0 //do not forget this

	else
		user << "<span class='notice'>\The [src] is empty.</span>"


/obj/machinery/pdapainter/verb/ejectpda()
	set name = "Eject PDA"
	set category = "Object"
	set src in oview(1)

	if(storedpda)
		storedpda.loc = get_turf(src.loc)
		storedpda = null
		update_icon()
	else
		usr << "<span class='notice'>\The [src] is empty.</span>"

/obj/machinery/pdapainter/verb/printpda()
	set name = "Print PDA"
	set category = "Object"
	set src in oview(1)

	if(storedpda)
		usr << "You can't print a PDA while \the [storedpda] is loaded into \the [src]."
		return
	if(busy)
		usr << "\The [src] is busy, try again later."
		return
	if(last_print + 300 < world.timeofday)
		src.visible_message("<span class='notice'>\The [src] begins to hum lightly.</span>")
		busy = 1
		sleep(build_time)
		src.visible_message("<span class='notice'>\The [src] rattles and shakes, spitting out a new PDA.</span>")
		busy = 0
		new /obj/item/device/pda(get_turf(src))
		last_print = world.timeofday
	else
		usr << "\The [src] is not ready to print again."



/obj/machinery/pdapainter/power_change()
	..()
	update_icon()