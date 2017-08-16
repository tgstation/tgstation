/obj/item/weapon/vending_refill
	name = "resupply canister"
	var/machine_name = "Generic"

	icon = 'icons/obj/vending_restock.dmi'
	icon_state = "refill_snack"
	item_state = "restock_unit"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	flags = CONDUCT
	force = 7
	throwforce = 10
	throw_speed = 1
	throw_range = 7
	w_class = WEIGHT_CLASS_BULKY
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0, fire = 70, acid = 30)
	var/charges = list(0, 0, 0)	//how many restocking "charges" the refill has for standard/contraband/coin products
	var/init_charges = list(0, 0, 0)


/obj/item/weapon/vending_refill/New(amt = -1)
	..()
	name = "\improper [machine_name] restocking unit"
	if(isnum(amt) && amt > -1)
		charges[1] = amt

/obj/item/weapon/vending_refill/examine(mob/user)
	..()
	if(charges[1] > 0)
		to_chat(user, "It can restock [charges[1]+charges[2]+charges[3]] item(s).")
	else
		to_chat(user, "It's empty!")

//NOTE I decided to go for about 1/3 of a machine's capacity

/obj/item/weapon/vending_refill/boozeomat
	machine_name = "Booze-O-Mat"
	icon_state = "refill_booze"
	charges = list(54, 4, 0)//of 159 standard, 12 contraband
	init_charges = list(54, 4, 0)

/obj/item/weapon/vending_refill/coffee
	machine_name = "Solar's Best Hot Drinks"
	icon_state = "refill_joe"
	charges = list(25, 4, 0)//of 75 standard, 12 contraband
	init_charges = list(25, 4, 0)

/obj/item/weapon/vending_refill/snack
	machine_name = "Getmore Chocolate Corp"
	charges = list(12, 2, 0)//of 36 standard, 6 contraband
	init_charges = list(12, 2, 0)

/obj/item/weapon/vending_refill/cola
	machine_name = "Robust Softdrinks"
	icon_state = "refill_cola"
	charges = list(30, 4, 1)//of 90 standard, 12 contraband, 1 premium
	init_charges = list(30, 4, 1)

/obj/item/weapon/vending_refill/cigarette
	machine_name = "ShadyCigs Deluxe"
	icon_state = "refill_smoke"
	charges = list(12, 3, 2)// of 36 standard, 9 contraband, 6 premium
	init_charges = list(12, 3, 2)

/obj/item/weapon/vending_refill/autodrobe
	machine_name = "AutoDrobe"
	icon_state = "refill_costume"
	charges = list(32, 2, 3)// of 96 standard, 6 contraband, 9 premium
	init_charges = list(32, 2, 3)

/obj/item/weapon/vending_refill/clothing
	machine_name = "ClothesMate"
	icon_state = "refill_clothes"
	charges = list(37, 4, 4)// of 111 standard, 12 contraband, 10 premium(?)
	init_charges = list(37, 4, 4)

/obj/item/weapon/vending_refill/medical
	machine_name = "NanoMed"
	icon_state = "refill_medical"
	charges = list(26, 5, 3)// of 76 standard, 13 contraband, 8 premium
	init_charges = list(26, 5, 3)
