/*
 * Ring Box
 */

/obj/item/storage/fancy/ringbox
	name = "ring box"
	desc = "A tiny box covered in soft red felt made for holding rings."
	icon = 'modular_skyrat/modules/customization/icons/obj/ring.dmi'
	icon_state = "gold ringbox"
	icon_type = "gold ring"
	w_class = WEIGHT_CLASS_TINY
	spawn_type = /obj/item/clothing/gloves/ring

/obj/item/storage/fancy/ringbox/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 1
	STR.can_hold = typecacheof(list(/obj/item/clothing/gloves/ring))

/obj/item/storage/fancy/ringbox/diamond
	icon_state = "diamond ringbox"
	icon_type = "diamond ring"
	spawn_type = /obj/item/clothing/gloves/ring/diamond

/obj/item/storage/fancy/ringbox/silver
	icon_state = "silver ringbox"
	icon_type = "silver ring"
	spawn_type = /obj/item/clothing/gloves/ring/silver
