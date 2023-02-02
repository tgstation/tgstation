/obj/item/storage/basket
	name = "basket"
	desc = "Handwoven basket."
	icon = 'icons/obj/storage/basket.dmi'
	icon_state = "basket"
	w_class = WEIGHT_CLASS_BULKY
	resistance_flags = FLAMMABLE

/obj/item/storage/basket/Initialize(mapload)
	. = ..()
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL
	atom_storage.max_total_storage = 21
