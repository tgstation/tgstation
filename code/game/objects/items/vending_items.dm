/*
	Vending machine refills can be found at /code/modules/vending/ within each vending machine's respective file
*/
/obj/item/vending_refill
	name = "resupply canister"
	icon = 'icons/obj/vending_restock.dmi'
	icon_state = "refill_snack"
	inhand_icon_state = "restock_unit"
	desc = "A vending machine restock cart."
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	obj_flags = CONDUCTS_ELECTRICITY
	force = 7
	throwforce = 10
	throw_speed = 1
	throw_range = 7
	w_class = WEIGHT_CLASS_BULKY
	armor_type = /datum/armor/item_vending_refill

	///Name of the vending machine this canister is associated with
	var/machine_name = "Generic"

	///corresponds to /obj/machinery/vending::list/products
	var/list/products
	///corresponds to /obj/machinery/vending::list/contraband
	var/list/contraband
	///corresponds to /obj/machinery/vending::list/premium
	var/list/premium

/datum/armor/item_vending_refill
	fire = 70
	acid = 30

/obj/item/vending_refill/Initialize(mapload)
	. = ..()
	name = "\improper [machine_name] restocking unit"

/obj/item/vending_refill/examine(mob/user)
	. = ..()

	var/num = get_part_rating()
	if (!num)
		. += span_notice("It's empty!")
	else if(num == INFINITY)
		. += span_notice("It's full of supplies!")
	else
		. += span_notice("It can restock [num] item\s.")

/obj/item/vending_refill/get_part_rating()
	. = 0
	//first time needs to be filled by the vending machine
	if(!products)
		return INFINITY

	for(var/key in products)
		. += products[key]
	for(var/key in contraband)
		. += contraband[key]
	for(var/key in premium)
		. += premium[key]

