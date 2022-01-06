/*
	Vending machine refills can be found at /code/modules/vending/ within each vending machine's respective file
*/
/obj/item/vending_refill
	name = "resupply canister"
	var/machine_name = "Generic"

	icon = 'icons/obj/vending_restock.dmi'
	icon_state = "refill_snack"
	inhand_icon_state = "restock_unit"
	desc = "A vending machine restock cart."
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	flags_1 = CONDUCT_1
	force = 7
	throwforce = 10
	throw_speed = 1
	throw_range = 7
	w_class = WEIGHT_CLASS_BULKY
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 70, ACID = 30)

	// Built automatically from the corresponding vending machine.
	// If null, considered to be full. Otherwise, is list(/typepath = amount).
	var/list/products
	var/list/contraband
	var/list/premium

/obj/item/vending_refill/Initialize(mapload)
	. = ..()
	name = "\improper [machine_name] restocking unit"

/obj/item/vending_refill/examine(mob/user)
	. = ..()
	var/num = get_part_rating()
	if (num == INFINITY)
		. += "It's sealed tight, completely full of supplies."
	else if (num == 0)
		. += "It's empty!"
	else
		. += "It can restock [num] item\s."

/obj/item/vending_refill/get_part_rating()
	if (!products || !contraband || !premium)
		return INFINITY
	. = 0
	for(var/key in products)
		. += products[key]
	for(var/key in contraband)
		. += contraband[key]
	for(var/key in premium)
		. += premium[key]
