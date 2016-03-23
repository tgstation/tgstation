/obj/item/weapon/vending_refill
	name = "resupply canister"
	var/machine_name = "Generic"

	icon = 'icons/obj/vending_restock.dmi'
	icon_state = "refill_snack"
	item_state = "restock_unit"
	flags = CONDUCT
	force = 7
	throwforce = 10
	throw_speed = 1
	throw_range = 7
	w_class = 4

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
		user << "It can restock [charges[1]] item(s)."
	else
		user << "It's empty!"

//NOTE I decided to go for about 1/3 of a machine's capacity

/obj/item/weapon/vending_refill/boozeomat
	machine_name = "Booze-O-Mat"
	icon_state = "refill_booze"
	charges = list(52, 4, 0)//of 156 standard, 12 contraband
	init_charges = list(52, 4, 0)

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
	charges = list(20, 2, 0)//of 60 standard, 6 contraband
	init_charges = list(20, 2, 0)

/obj/item/weapon/vending_refill/cigarette
	machine_name = "ShadyCigs Deluxe"
	icon_state = "refill_smoke"
	charges = list(12, 1, 2)// of 36 standard, 3 contraband, 6 premium
	init_charges = list(12, 1, 2)

/obj/item/weapon/vending_refill/autodrobe
	machine_name = "AutoDrobe"
	icon_state = "refill_costume"
	charges = list(27, 2, 3)// of 75 standard, 6 contraband, 9 premium
	init_charges = list(27, 2, 3)

/obj/item/weapon/vending_refill/clothing
	machine_name = "ClothesMate"
	icon_state = "refill_clothes"
	charges = list(30, 2, 3)// of 86 standard, 6 contraband, 9 premium
	init_charges = list(30, 2, 3)