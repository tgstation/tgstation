/*
 * Photo album
 */
/obj/item/storage/photo_album
	name = "photo album"
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "album"
	item_state = "briefcase"
	lefthand_file = 'icons/mob/inhands/equipment/briefcase_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/briefcase_righthand.dmi'
	resistance_flags = FLAMMABLE

/obj/item/storage/photo_album/Initialize()
	. = ..()
	GET_COMPONENT(STR, /datum/component/storage)
	STR.can_hold = typecacheof(list(/obj/item/photo))
