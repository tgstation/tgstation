/obj/item/storage/belt/utility/makeshift
	name = "makeshift toolbelt"
	desc = "A shoddy holder of tools."
	icon = 'massmeta/icons/obj/clothing/belts.dmi'
	worn_icon = 'massmeta/icons/mob/clothing/belt.dmi'
	lefthand_file = 'massmeta/icons/mob/inhands/equipment/belt_lefthand.dmi'
	righthand_file = 'massmeta/icons/mob/inhands/equipment/belt_righthand.dmi'
	inhand_icon_state = "makeshiftbelt"
	worn_icon_state = "makeshiftbelt"
	icon_state = "makeshiftbelt"
	w_class = WEIGHT_CLASS_BULKY

/obj/item/storage/belt/utility/makeshift/Initialize(mapload)
	. = ..()
	atom_storage.max_slots = 6 //It's a very crappy belt
	atom_storage.max_total_storage = 16
