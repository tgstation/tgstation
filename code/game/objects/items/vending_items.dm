/*
	Vending machine refills can be found at /code/modules/vending/ within each vending machine's respective file
*/
/obj/item/vending_refill
	name = "resupply canister"
	var/machine_name = "Generic"

	icon = 'icons/obj/vending_restock.dmi'
	icon_state = "refill_snack"
	item_state = "restock_unit"
	desc = "A vending machine restock cart."
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	flags_1 = CONDUCT_1
	force = 7
	throwforce = 10
	throw_speed = 1
	throw_range = 7
	w_class = WEIGHT_CLASS_BULKY
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 70, "acid" = 30)
	var/charges = list(0, 0, 0)	//how many restocking "charges" the refill has for standard/contraband/coin products
	var/init_charges = list(0, 0, 0)


/obj/item/vending_refill/New(amt = -1)
	..()
	name = "\improper [machine_name] restocking unit"
	if(isnum(amt) && amt > -1)
		charges[1] = amt

/obj/item/vending_refill/examine(mob/user)
	..()
	if(charges[1] > 0)
		to_chat(user, "It can restock [charges[1]+charges[2]+charges[3]] item(s).")
	else
		to_chat(user, "It's empty!")