/obj/item/weapon/vending_refill
	name = "Resupply canister"
	var/machine_name = "Generic"

	icon = 'icons/obj/vending_restock.dmi'
	icon_state = "refill_snack"
	item_state = "restock_unit"
	flags = FPRINT | TABLEPASS| CONDUCT
	force = 7.0
	throwforce = 15.0
	throw_speed = 1
	throw_range = 7
	w_class = 4.0

	var/charges = 0		//how many restocking "charges" the refill has

/obj/item/weapon/vending_refill/New()
	..()
	name = "\improper [machine_name] restocking unit"

/obj/item/weapon/vending_refill/examine()
	set src in usr
	..()
	if(charges)
		usr << "It can restock [charges] item(s)."
	else
		usr << "It's empty!"

//NOTE I decided to go for about 1/3 of a machine's capacity

/obj/item/weapon/vending_refill/boozeomat
	machine_name = "Booze-O-Mat"
	icon_state = "refill_booze"
	charges = 50//of 138

/obj/item/weapon/vending_refill/coffee
	machine_name = "hot drinks"
	icon_state = "refill_joe"
	charges = 30//of 85

/obj/item/weapon/vending_refill/snack
	machine_name = "Getmore Chocolate Corp"
	charges = 15//of 48

/obj/item/weapon/vending_refill/cola
	machine_name = "Robust Softdrinks"
	icon_state = "refill_cola"
	charges = 20//of 65

/obj/item/weapon/vending_refill/cigarette
	machine_name = "cigarette"
	icon_state = "refill_smoke"
	charges = 10// of 30

/obj/item/weapon/vending_refill/autodrobe
	machine_name = "AutoDrobe"
	icon_state = "refill_costume"
	charges = 28// of 58
