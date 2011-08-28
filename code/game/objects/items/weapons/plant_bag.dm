// Todo: Allow harvesting from crops, and emptying into the bioprocessor
// Eventually make the new refrigerator-vender, allow emptying into it.

/**********************Plant Bag**************************/

/obj/item/weapon/plantbag
	icon = 'hydroponics.dmi'
	icon_state = "plantbag"
	name = "Plant Bag"
	var/mode = 1;  //0 = pick one at a time, 1 = pick all on tile
	var/capacity = 50; //the number of plant pieces it can carry.
	flags = FPRINT | TABLEPASS | ONBELT
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

/obj/item/weapon/reagent_containers/food/snacks/grown/attackby(var/obj/item/O as obj, var/mob/user as mob)
	..()
	if (istype(O, /obj/item/weapon/plantbag))
		var/obj/item/weapon/plantbag/S = O
		if (S.mode == 1)
			for (var/obj/item/weapon/reagent_containers/food/snacks/grown/G in locate(src.x,src.y,src.z))
				if (S.contents.len < S.capacity)
					S.contents += G;
				else
					user << "\blue The plant bag is full."
					return
			user << "\blue You pick up all the plants."
		else
			if (S.contents.len < S.capacity)
				S.contents += src;
			else
				user << "\blue The plant bag is full."
	return

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
