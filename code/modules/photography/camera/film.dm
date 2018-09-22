/*
 * Film
 */
/obj/item/camera_film
	name = "film cartridge"
	icon = 'icons/obj/items_and_weapons.dmi'
	desc = "A camera film cartridge. Insert it into a camera to reload it."
	icon_state = "film"
	item_state = "electropack"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_TINY
	resistance_flags = FLAMMABLE
	materials = list(MAT_METAL = 10, MAT_GLASS = 10)
