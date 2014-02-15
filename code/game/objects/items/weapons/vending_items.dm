/obj/item/weapon/vending_refill
	name = "empty resupply canister"
	var/machine_name = "empty"

	icon = 'icons/obj/vending_restock.dmi'
	icon_state = "refill_empty"
	item_state = "restock_unit"
	flags = CONDUCT
	force = 7.0
	throwforce = 15.0
	throw_speed = 1
	throw_range = 7
	w_class = 4.0
	m_amt = 10000 //It's kinda big

	var/charges = 0		//how many restocking "charges" the refill has

/obj/item/weapon/vending_refill/New()
	..()
	name = machine_name + " restocking unit" //BYOND's macros are making me cringe sometimes

/obj/item/weapon/vending_refill/examine()
	set src in usr
	..()
	if(charges)
		usr << "It can restock [charges] item(s)."
	else
		usr << "It's empty!"

/obj/item/weapon/vending_refill/proc/make_type(obj/machinery/vending/machine)
	if(machine)
		icon_state = machine.refill_canister
		machine_name = machine.name
		name = machine_name + " restocking unit"
	else
		icon_state = "refill_empty"
		machine_name = "empty"
		name = machine_name + " restocking unit"


//NOTE I decided to go for about 1/3 of a machine's capacity

/obj/item/weapon/vending_refill/boozeomat
	machine_name = "\improper Booze-O-Mat"
	icon_state = "refill_booze"
	charges = 50//of 138

/obj/item/weapon/vending_refill/coffee
	machine_name = "hot drinks machine"
	icon_state = "refill_joe"
	charges = 30//of 85

/obj/item/weapon/vending_refill/snack
	machine_name = "\improper Getmore Chocolate Corp"
	icon_state = "refill_snack"
	charges = 15//of 48

/obj/item/weapon/vending_refill/cola
	machine_name = "\improper Robust Softdrinks"
	icon_state = "refill_cola"
	charges = 20//of 65

/obj/item/weapon/vending_refill/cigarette
	machine_name = "cigarette machine"
	icon_state = "refill_smoke"
	charges = 10// of 30

/obj/item/weapon/vending_refill/autodrobe
	machine_name = "\improper AutoDrobe"
	icon_state = "refill_costume"
	charges = 28// of 58
