/*
 * Ring Box
 */

/obj/item/storage/fancy/ringbox
	name = "ring box"
	desc = "A tiny box covered in soft red felt made for holding rings."
	icon = 'modular_doppler/modular_cosmetics/icons/obj/storage/rings.dmi'
	icon_state = "gold ringbox"
	base_icon_state = "gold ringbox"
	w_class = WEIGHT_CLASS_TINY
	spawn_type = /obj/item/clothing/gloves/ring
	spawn_count = 1

/obj/item/storage/fancy/ringbox/Initialize(mapload)
	. = ..()
	atom_storage.max_slots = 1
	atom_storage.can_hold = typecacheof(list(/obj/item/clothing/gloves/ring))

/obj/item/storage/fancy/ringbox/diamond
	icon_state = "diamond ringbox"
	base_icon_state = "diamond ringbox"
	spawn_type = /obj/item/clothing/gloves/ring/diamond

/obj/item/storage/fancy/ringbox/silver
	icon_state = "silver ringbox"
	base_icon_state = "silver ringbox"
	spawn_type = /obj/item/clothing/gloves/ring/silver
