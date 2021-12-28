/obj/item/storage/basket
	name = "basket"
	desc = "Handwoven basket."
	icon_state = "basket"
	atom_size = WEIGHT_CLASS_BULKY
	resistance_flags = FLAMMABLE

/obj/item/storage/basket/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_atom_size = WEIGHT_CLASS_NORMAL
	STR.max_total_atom_size = 21
