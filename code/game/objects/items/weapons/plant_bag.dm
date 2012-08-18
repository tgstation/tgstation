
/**********************Plant Bag**************************/

/obj/item/weapon/plantbag
	icon = 'icons/obj/hydroponics.dmi'
	icon_state = "plantbag"
	name = "Plant Bag"
	var/mode = 1;  //0 = pick one at a time, 1 = pick all on tile
	var/capacity = 50; //the number of plant pieces it can carry.
	flags = FPRINT | TABLEPASS
	slot_flags = SLOT_BELT
	w_class = 1

/obj/item/weapon/plantbag/attack_self(mob/user as mob)
	for (var/obj/item/weapon/reagent_containers/food/snacks/grown/O in contents)
		contents -= O
		O.loc = user.loc
	user << "\blue You empty the plant bag."
	return

/obj/item/weapon/plantbag/verb/toggle_mode()
	set name = "Switch Bagging Method"
	set category = "Object"

	mode = !mode
	switch (mode)
		if(1)
			usr << "The bag now picks up all plants in a tile at once."
		if(0)
			usr << "The bag now picks up one plant at a time."


/obj/machinery/hydroponics/attackby(var/obj/item/O as obj, var/mob/user as mob)
	..()
	if (istype(O, /obj/item/weapon/plantbag))
		src.attack_hand(user)
		var/obj/item/weapon/plantbag/S = O
		for (var/obj/item/weapon/reagent_containers/food/snacks/grown/G in locate(user.x,user.y,user.z))
			if (S.contents.len < S.capacity)
				S.contents += G;
			else
				user << "\blue The plant bag is full."
				return


/* SmartFridge.  Much todo
*/
/obj/machinery/smartfridge
	name = "\improper SmartFridge"
	icon = 'icons/obj/vending.dmi'
	icon_state = "smartfridge"
	layer = 2.9
	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 5
	active_power_usage = 100
	flags = NOREACT
	var/global/max_n_of_items = 200
	var/item_quants = list()
	var/ispowered = 1 //starts powered
	var/isbroken = 0


/obj/machinery/smartfridge/power_change()
	if( powered() )
		src.ispowered = 1
		stat &= ~NOPOWER
		if(!isbroken)
			icon_state = "smartfridge"
	else
		spawn(rand(0, 15))
		src.ispowered = 0
		stat |= NOPOWER
		if(!isbroken)
			icon_state = "smartfridge-off"


/*******************
*   Item Adding
********************/

/obj/machinery/smartfridge/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(!src.ispowered)
		user << "<span class='notice'>\The [src] is unpowered and useless.</span>"
		return

	if(istype(O,/obj/item/weapon/reagent_containers/food/snacks/grown/))
		if(contents.len >= max_n_of_items)
			user << "<span class='notice'>\The [src] is full.</span>"
			return 1
		else
			user.before_take_item(O)
			O.loc = src
			if(item_quants[O.name])
				item_quants[O.name]++
			else
				item_quants[O.name] = 1
			user.visible_message("<span class='notice'>[user] has added \the [O] to \the [src].", \
								 "<span class='notice'>You add \the [O] to \the [src].")

	else if(istype(O, /obj/item/weapon/plantbag))
		user.visible_message("<span class='notice'>[user] loads \the [src] with \the [O].</span>", \
							 "<span class='notice'>You load \the [src] with \the [O].</span>")
		for(var/obj/item/weapon/reagent_containers/food/snacks/grown/G in O.contents)
			if(contents.len >= max_n_of_items)
				user << "<span class='notice'>\The [src] is full.</span>"
				return 1
			else
				O.contents -= G
				G.loc = src
				if(item_quants[G.name])
					item_quants[G.name]++
				else
					item_quants[G.name] = 1

	else
		user << "<span class='notice'>\The [src] smartly refuses [O].</span>"
		return 1

	updateUsrDialog()

/obj/machinery/smartfridge/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/smartfridge/attack_ai(mob/user as mob)
	return 0

/obj/machinery/smartfridge/attack_hand(mob/user as mob)
	user.machine = src
	interact(user)

/*******************
*   SmartFridge Menu
********************/

/obj/machinery/smartfridge/proc/interact(mob/user as mob)
	if(!src.ispowered)
		return

	var/dat = "<TT><b>Select an item:</b><br>"

	if (contents.len == 0)
		dat += "<font color = 'red'>No product loaded!</font>"
	else
		for (var/O in item_quants)
			if(item_quants[O] > 0)
				var/N = item_quants[O]
				dat += "<FONT color = 'blue'><B>[capitalize(O)]</B>:"
				dat += " [N] </font>"
				dat += "<a href='byond://?src=\ref[src];vend=[O]'>Vend</A>"
				dat += "<br>"

		dat += "</TT>"
	user << browse("<HEAD><TITLE>SmartFridge Supplies</TITLE></HEAD><TT>[dat]</TT>", "window=smartfridge")
	onclose(user, "smartfridge")
	return

/obj/machinery/smartfridge/Topic(href, href_list)
	if(..())
		return

	usr.machine = src

	var/N = href_list["vend"]

	if(item_quants[N] <= 0) // Sanity check, there are probably ways to press the button when it shouldn't be possible.
		return

	item_quants[N] -= 1
	for(var/obj/O in contents)
		if(O.name == N)
			O.loc = src.loc
			break
	src.updateUsrDialog()
	return
