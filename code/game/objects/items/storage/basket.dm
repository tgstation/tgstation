/obj/item/storage/basket
	name = "basket"
	desc = "Handwoven basket."
	icon = 'icons/obj/storage/basket.dmi'
	icon_state = "basket"
	w_class = WEIGHT_CLASS_BULKY
	resistance_flags = FLAMMABLE
	storage_type = /datum/storage/basket

/obj/item/storage/basket/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/cuffable_item)
