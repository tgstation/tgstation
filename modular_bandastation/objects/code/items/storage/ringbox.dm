/obj/item/storage/fancy/ringbox
	name = "ring box"
	desc = "Крошечная коробочка, обтянутая мягким красным фетром, предназначенная для хранения колец."
	icon = 'modular_bandastation/objects/icons/obj/storage/ringbox.dmi'
	icon_state = "gold ringbox"
	base_icon_state = "gold ringbox"
	w_class = WEIGHT_CLASS_TINY
	spawn_type = /obj/item/clothing/accessory/gloves_accessory/ring
	spawn_count = 1

/obj/item/storage/fancy/ringbox/Initialize(mapload)
	. = ..()
	atom_storage.max_slots = 1
	atom_storage.can_hold = typecacheof(list(/obj/item/clothing/accessory/gloves_accessory/ring))

/obj/item/storage/fancy/ringbox/diamond
	name = "diamond ring box"
	icon_state = "diamond ringbox"
	base_icon_state = "diamond ringbox"
	spawn_type = /obj/item/clothing/accessory/gloves_accessory/ring/diamond

/obj/item/storage/fancy/ringbox/silver
	name = "silver ring box"
	icon_state = "silver ringbox"
	base_icon_state = "silver ringbox"
	spawn_type = /obj/item/clothing/accessory/gloves_accessory/ring/silver
