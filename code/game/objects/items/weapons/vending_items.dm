/obj/item/weapon/vending_refill
	name = "Resupply canister"
	var/machine_name = "Generic"

	icon = 'icons/obj/venging_restock.dmi'
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
	name = "\improper [machine_name] restocking unit"

/obj/item/weapon/vending_refill/examine()
	set src in usr
	var/description = "[name] \icon[src],"
	if(charges)
		usr << "[description] it can restock [charges] item(s)."
	else
		usr << "[description] it is empty!"

//NOTE I decided to go for about 1/3 of a machine's capacity

/obj/item/weapon/vending_refill/boozeomat
	machine_name = "Booze-O-Mat"
	icon_state = "refill_booze"
	//machine contains max 138 items
	charges = 50

/obj/item/weapon/vending_refill/coffee
	machine_name = "hot drinks"
	icon_state = "refill_joe"
	//machine contains max 85 items
	charges = 30

/obj/item/weapon/vending_refill/snack
	machine_name = "Getmore Chocolate Corp"
	//machine contains max 48 items
	charges = 15

/obj/item/weapon/vending_refill/cola
	machine_name = "Robust Softdrinks"
	icon_state = "refill_cola"
	//machine contains max 65 items
	charges = 20

/obj/item/weapon/vending_refill/cigarette
	machine_name = "cigarette"
	icon_state = "refill_smoke"
	//machine contains max 30 items
	charges = 10

