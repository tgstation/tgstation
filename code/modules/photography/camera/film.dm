/*
 * Film
 */
/obj/item/camera_film
	name = "film cartridge"
	icon = 'icons/obj/art/camera.dmi'
	desc = "A camera film cartridge. Insert it into a camera to reload it."
	icon_state = "film"
	inhand_icon_state = "electropack"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_TINY
	resistance_flags = FLAMMABLE
	custom_materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT*0.1, /datum/material/glass = SMALL_MATERIAL_AMOUNT*0.1)
