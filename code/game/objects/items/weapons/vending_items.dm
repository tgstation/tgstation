/obj/item/weapon/vending_refill
	name = "resupply canister"
	var/machine_name = "Generic"

	icon = 'icons/obj/vending_restock.dmi'
	icon_state = "refill_snack"
	item_state = "restock_unit"
	flags = CONDUCT
	force = 7.0
	throwforce = 10.0
	throw_speed = 1
	throw_range = 7
	w_class = 4.0

	var/charges = 0		//how many restocking "charges" the refill has

/obj/item/weapon/vending_refill/New(amt = -1)
	..()
	name = "\improper [machine_name] restocking unit"
	if(isnum(amt) && amt > -1)
		charges = amt

/obj/item/weapon/vending_refill/examine(mob/user)
	..()
	if(charges)
		user << "It can restock [charges] item(s)."
	else
		user << "It's empty!"

//NOTE I decided to go for about 1/3 of a machine's capacity

/obj/item/weapon/vending_refill/boozeomat
	machine_name = "Booze-O-Mat"
	icon_state = "refill_booze"
	charges = 54//of 162

/obj/item/weapon/vending_refill/coffee
	machine_name = "Solar's Best Hot Drinks"
	icon_state = "refill_joe"
	charges = 28//of 85

/obj/item/weapon/vending_refill/snack
	machine_name = "Getmore Chocolate Corp"
	charges = 14//of 42

/obj/item/weapon/vending_refill/cola
	machine_name = "Robust Softdrinks"
	icon_state = "refill_cola"
	charges = 22//of 66

/obj/item/weapon/vending_refill/cigarette
	machine_name = "ShadyCigs Deluxe"
	icon_state = "refill_smoke"
	charges = 14// of 42

/obj/item/weapon/vending_refill/autodrobe
	machine_name = "AutoDrobe"
	icon_state = "refill_costume"
	charges = 29// of 87

/obj/item/weapon/vending_refill/clothing
	machine_name = "ClothesMate"
	icon_state = "refill_clothes"
	charges = 30// of 90
