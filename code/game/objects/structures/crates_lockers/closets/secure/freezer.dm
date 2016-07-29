<<<<<<< HEAD
/obj/structure/closet/secure_closet/freezer
	icon_state = "freezer"

/obj/structure/closet/secure_closet/freezer/kitchen
	name = "kitchen Cabinet"
	req_access = list(access_kitchen)

/obj/structure/closet/secure_closet/freezer/kitchen/New()
	..()
	for(var/i = 0, i < 3, i++)
		new /obj/item/weapon/reagent_containers/food/condiment/flour(src)
	new /obj/item/weapon/reagent_containers/food/condiment/rice(src)
	new /obj/item/weapon/reagent_containers/food/condiment/sugar(src)

/obj/structure/closet/secure_closet/freezer/kitchen/maintenance
	name = "maintenance refrigerator"
	desc = "This refrigerator looks quite dusty, is there anything edible still inside?"
	req_access = list()

/obj/structure/closet/secure_closet/freezer/kitchen/maintenance/New()
	..()
	for(var/i = 0, i < 5, i++)
		new /obj/item/weapon/reagent_containers/food/condiment/milk(src)
	for(var/i = 0, i < 5, i++)
		new /obj/item/weapon/reagent_containers/food/condiment/soymilk(src)
	for(var/i = 0, i < 2, i++)
		new /obj/item/weapon/storage/fancy/egg_box(src)

/obj/structure/closet/secure_closet/freezer/kitchen/mining
	req_access = list()

/obj/structure/closet/secure_closet/freezer/meat
	name = "meat fridge"

/obj/structure/closet/secure_closet/freezer/meat/New()
	..()
	for(var/i = 0, i < 4, i++)
		new /obj/item/weapon/reagent_containers/food/snacks/meat/slab/monkey(src)
/obj/structure/closet/secure_closet/freezer/fridge
	name = "refrigerator"

/obj/structure/closet/secure_closet/freezer/fridge/New()
	..()
	for(var/i = 0, i < 5, i++)
		new /obj/item/weapon/reagent_containers/food/condiment/milk(src)
	for(var/i = 0, i < 5, i++)
		new /obj/item/weapon/reagent_containers/food/condiment/soymilk(src)
	for(var/i = 0, i < 2, i++)
		new /obj/item/weapon/storage/fancy/egg_box(src)

/obj/structure/closet/secure_closet/freezer/money
	name = "freezer"
	desc = "This contains cold hard cash."
	req_access = list(access_heads_vault)

/obj/structure/closet/secure_closet/freezer/money/New()
	..()
	for(var/i = 0, i < 3, i++)
		new /obj/item/stack/spacecash/c1000(src)
	for(var/i = 0, i < 5, i++)
		new /obj/item/stack/spacecash/c500(src)
	for(var/i = 0, i < 6, i++)
		new /obj/item/stack/spacecash/c200(src)

/obj/structure/closet/secure_closet/freezer/cream_pie
	name = "cream pie closet"
	desc = "Contains pies filled with cream and/or custard, you sickos."
	req_access = list(access_theatre)

/obj/structure/closet/secure_closet/freezer/pie/New()
	..()
	new /obj/item/weapon/reagent_containers/food/snacks/pie/cream(src)
=======
/obj/structure/closet/secure_closet/freezer

	var/icon_exploded = "fridge_exploded"
	var/exploded = 0

/obj/structure/closet/secure_closet/freezer/update_icon()
	overlays.len = 0
	if(broken)
		icon_state = icon_broken
	else
		if(!opened)
			if(locked)
				icon_state = icon_locked
			else
				icon_state = icon_closed
			if(welded)
				overlays += image(icon = icon, icon_state = "welded")
		else
			if(exploded)
				icon_state = icon_exploded
				return
			icon_state = icon_opened

//Fridges cannot be destroyed by explosions (a reference to Indiana Jones if you don't know)
//However, the door will be blown off its hinges, permanently breaking the fridge
//And of course, if the bomb is IN the fridge, you're fucked
/obj/structure/closet/secure_closet/freezer/ex_act(var/severity)

	//Bomb in here? (using same search as space transits searching for nuke disk)
	var/list/bombs = search_contents_for(/obj/item/device/transfer_valve)
	if(!isemptylist(bombs)) // You're fucked.
		..(severity)

	if(severity == 1)
		//If it's not open, we need to override the normal open proc and set everything ourselves
		//Otherwise, you can cheese this by simply welding it shut, or if the lock is engaged
		if(!opened)
			opened = 1
			density = 0
			dump_contents()

		//Now, set our special variables
		exploded = 1
		update_icon()

	return

/obj/structure/closet/secure_closet/freezer/can_close()
	if(exploded) //Door blew off, can't close it anymore
		return 0
	for(var/obj/structure/closet/closet in get_turf(src))
		if(closet != src && !closet.wall_mounted)
			return 0
	return 1

/obj/structure/closet/secure_closet/freezer/kitchen
	name = "Kitchen Cabinet"
	req_access = list(access_kitchen)

	New()
		..()
		sleep(2)
		for(var/i = 0, i < 3, i++)
			new /obj/item/weapon/reagent_containers/food/drinks/flour(src)
		new /obj/item/weapon/reagent_containers/food/condiment/sugar(src)
		return


/obj/structure/closet/secure_closet/freezer/kitchen/mining
	req_access = list()



/obj/structure/closet/secure_closet/freezer/meat
	name = "Meat Fridge"
	icon_state = "fridge1"
	icon_closed = "fridge"
	icon_locked = "fridge1"
	icon_opened = "fridgeopen"
	icon_broken = "fridgebroken"
	icon_off = "fridge1"


	New()
		..()
		sleep(2)
		for(var/i = 0, i < 4, i++)
			new /obj/item/weapon/reagent_containers/food/snacks/meat/animal/monkey(src)
		return



/obj/structure/closet/secure_closet/freezer/fridge
	name = "Refrigerator"
	icon_state = "fridge1"
	icon_closed = "fridge"
	icon_locked = "fridge1"
	icon_opened = "fridgeopen"
	icon_broken = "fridgebroken"
	icon_off = "fridge1"


	New()
		..()
		sleep(2)
		for(var/i = 0, i < 5, i++)
			new /obj/item/weapon/reagent_containers/food/drinks/milk(src)
		for(var/i = 0, i < 5, i++)
			new /obj/item/weapon/reagent_containers/food/drinks/soymilk(src)
		for(var/i = 0, i < 2, i++)
			new /obj/item/weapon/storage/fancy/egg_box(src)
		return



/obj/structure/closet/secure_closet/freezer/money
	name = "Freezer"
	icon_state = "fridge1"
	icon_closed = "fridge"
	icon_locked = "fridge1"
	icon_opened = "fridgeopen"
	icon_broken = "fridgebroken"
	icon_off = "fridge1"
	req_access = list(access_heads_vault)


	New()
		..()
		sleep(2)
		dispense_cash(6700,src)
		return








>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
