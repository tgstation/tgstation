/obj/item/gun/energy/taser/debug
	ammo_type = list(/obj/item/ammo_casing/energy/electrode/debug)
	w_class = WEIGHT_CLASS_TINY

/obj/item/ammo_casing/energy/electrode/debug
	e_cost = 1

/obj/item/clothing/suit/armor/vest/debug
	name = "Bluespace Tech vest"
	desc = "A sleek piece of armour designed for Bluespace agents."
	armor = list("melee" = 95, "bullet" = 95, "laser" = 95, "energy" = 95, "bomb" = 95, "bio" = 95, "fire" = 98, "acid" = 98)
	w_class = WEIGHT_CLASS_TINY

/obj/item/clothing/shoes/combat/debug
	w_class = WEIGHT_CLASS_TINY

/obj/item/storage/belt/utility/chief/full/debug
	name = "\improper Bluespace Tech's belt"
	w_class = WEIGHT_CLASS_TINY

/datum/outfit/debug/bst //Debug objs
	name = "Bluespace Tech"
	uniform = /obj/item/clothing/under/syndicate/combat
	belt = /obj/item/storage/belt/utility/chief/full/debug
	shoes = /obj/item/clothing/shoes/combat/debug
	id = /obj/item/card/id/advanced/debug/bst
	box = /obj/item/storage/box/debugtools
	l_pocket = /obj/item/modular_computer/pda/heads/captain/bst
	backpack_contents = list(
		/obj/item/melee/energy/axe = 1,
		/obj/item/storage/part_replacer/bluespace/tier4_bst = 1,
		/obj/item/gun/magic/wand/resurrection/debug = 1,
		/obj/item/gun/magic/wand/death/debug = 1,
		/obj/item/debug/human_spawner = 1,
		/obj/item/debug/omnitool = 1,
)

/datum/outfit/admin/bst //Debug objs plus modsuit
	name = "Bluespace Tech (MODsuit)"
	uniform = /obj/item/clothing/under/syndicate/combat
	belt = /obj/item/storage/belt/utility/chief/full/debug
	shoes = /obj/item/clothing/shoes/combat/debug
	id = /obj/item/card/id/advanced/debug/bst
	box = /obj/item/storage/box/debugtools
	l_pocket = /obj/item/modular_computer/pda/heads/captain/bst
	backpack_contents = list(
		/obj/item/melee/energy/axe = 1,
		/obj/item/storage/part_replacer/bluespace/tier4_bst = 1,
		/obj/item/gun/magic/wand/resurrection/debug = 1,
		/obj/item/gun/magic/wand/death/debug = 1,
		/obj/item/debug/human_spawner = 1,
		/obj/item/debug/omnitool = 1,
		/obj/item/storage/box/stabilized = 1,
)

/obj/item/storage/part_replacer/bluespace/tier4_bst
	name = "BST's RPED"

/obj/item/storage/part_replacer/bluespace/tier4_bst/Initialize(mapload)
	. = ..()
	atom_storage.max_slots = 800
	atom_storage.max_total_storage = 16000

/obj/item/storage/part_replacer/bluespace/tier4_bst/PopulateContents()
	for(var/i in 1 to 10)
		new /obj/item/stock_parts/capacitor/quadratic(src)
		new /obj/item/stock_parts/scanning_module/triphasic(src)
		new /obj/item/stock_parts/servo/femto(src)
		new /obj/item/stock_parts/micro_laser/quadultra(src)
		new /obj/item/stock_parts/matter_bin/bluespace(src)
		new /obj/item/stock_parts/cell/bluespace(src)
	for(var/i in 1 to 140)
		new /obj/item/stock_parts/capacitor/quadratic(src)
		new /obj/item/stock_parts/servo/femto(src)
		new /obj/item/stock_parts/micro_laser/quadultra(src)
		new /obj/item/stock_parts/matter_bin/bluespace(src)
		new /obj/item/stock_parts/cell/bluespace(src)
