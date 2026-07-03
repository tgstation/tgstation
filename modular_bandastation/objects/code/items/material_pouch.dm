/obj/item/storage/bag/material_pouch
	name = "material pouch"
	desc = "Сумка для хранения листов материалов."
	icon = 'modular_bandastation/objects/icons/obj/items/material_pouch.dmi'
	icon_state = "materialpouch"
	w_class = WEIGHT_CLASS_BULKY
	resistance_flags = FLAMMABLE
	slot_flags = ITEM_SLOT_POCKETS | ITEM_SLOT_BELT
	var/static/list/matpouch_holdables = list(
		/obj/item/stack/sheet/iron,
		/obj/item/stack/sheet/plasteel,
		/obj/item/stack/sheet/plasmaglass,
		/obj/item/stack/sheet/bluespace_crystal,
		/obj/item/stack/sheet/bronze,
		/obj/item/stack/sheet/glass,
		/obj/item/stack/sheet/plasmarglass,
		/obj/item/stack/sheet/titaniumglass,
		/obj/item/stack/sheet/plastic,
		/obj/item/stack/sheet/rglass,
		/obj/item/stack/sheet/mineral/wood,
		/obj/item/stack/sheet/mineral/adamantine,
		/obj/item/stack/sheet/mineral/bamboo,
		/obj/item/stack/sheet/mineral/bananium,
		/obj/item/stack/sheet/mineral/diamond,
		/obj/item/stack/sheet/mineral/gold,
		/obj/item/stack/sheet/mineral/metal_hydrogen,
		/obj/item/stack/sheet/mineral/uranium,
		/obj/item/stack/sheet/mineral/silver,
		/obj/item/stack/sheet/mineral/titanium,
	)

/obj/item/storage/bag/material_pouch/Initialize(mapload)
	. = ..()
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL
	atom_storage.max_total_storage = INFINITY
	atom_storage.max_slots = 2
	atom_storage.numerical_stacking = TRUE
	atom_storage.set_holdable(matpouch_holdables)
