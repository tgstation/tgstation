//SKYRAT MODULE IC-SPAWNING https://github.com/Skyrat-SS13/Skyrat-tg/pull/104
/obj/item/gun/energy/taser/debug
	ammo_type = list(/obj/item/ammo_casing/energy/electrode/debug)
	w_class = WEIGHT_CLASS_TINY

/obj/item/ammo_casing/energy/electrode/debug
	e_cost = 1

/obj/item/clothing/suit/armor/vest/debug
	name = "Bluespace Tech vest"
	desc = "A sleek piece of armour designed for Bluespace agents."
	armor = list("melee" = 95, "bullet" = 95, "laser" = 95, "energy" = 95, "bomb" = 95, "bio" = 95, "rad" = 100, "fire" = 98, "acid" = 98)
	w_class = WEIGHT_CLASS_TINY

/obj/item/clothing/suit/space/hardsuit/ert/debug
	name = "Bluespace Tech hardsuit"
	desc = "A specialised hardsuit for Bluespace agents."
	icon_state = "flightsuit"
	inhand_icon_state = "flightsuit"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ert/debug
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	armor = list("melee" = 98, "bullet" = 98, "laser" = 98, "energy" = 98, "bomb" = 98, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 100)
	w_class = WEIGHT_CLASS_TINY

/obj/item/clothing/head/helmet/space/hardsuit/ert/debug
	name = "Bluespace Tech helmet"
	desc = "The integrated helmet of a bluespace tech hardsuit, this one has blue highlights."
	icon_state = "hardsuit0-flight"
	inhand_icon_state = "hardsuit0-flight"
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	hardsuit_type = "flight"
	armor = list("melee" = 98, "bullet" = 98, "laser" = 98, "energy" = 98, "bomb" = 98, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 100)

/obj/item/clothing/shoes/combat/debug
	clothing_flags = NOSLIP
	w_class = WEIGHT_CLASS_TINY

/obj/item/storage/belt/utility/chief/full/debug
	name = "\improper Bluespace Tech's belt"
	w_class = WEIGHT_CLASS_TINY

/datum/outfit/debug/bst //Debug objs
	name = "Bluespace Tech"
	uniform = /obj/item/clothing/under/syndicate/combat
	suit = /obj/item/clothing/suit/armor/vest/debug
	glasses = /obj/item/clothing/glasses/debug
	ears = /obj/item/radio/headset/headset_cent
	mask = null
	gloves = /obj/item/clothing/gloves/tackler/combat/insulated
	belt = /obj/item/storage/belt/utility/chief/full/debug
	shoes = /obj/item/clothing/shoes/combat/debug
	id = /obj/item/card/id/debug/bst
	back = /obj/item/storage/backpack/holding
	box = /obj/item/storage/box/debugtools
	suit_store = /obj/item/gun/energy/pulse
	backpack_contents = list(
		/obj/item/melee/transforming/energy/axe=1,\
		/obj/item/storage/part_replacer/bluespace/tier4=1,\
		/obj/item/debug/human_spawner=1,\
		/obj/item/gun/energy/taser/debug=1,\
		/obj/item/clothing/glasses/debug,\
		/obj/item/clothing/mask/gas/welding/up,\
		/obj/item/tank/internals/oxygen,\
		)

/datum/outfit/debug/bsthardsuit //Debug objs plus hardsuit
	name = "Bluespace Tech (Hardsuit)"
	uniform = /obj/item/clothing/under/syndicate/combat
	suit = /obj/item/clothing/suit/space/hardsuit/ert/debug
	glasses = /obj/item/clothing/glasses/debug
	ears = /obj/item/radio/headset/headset_cent
	mask = /obj/item/clothing/mask/gas/welding/up
	gloves = /obj/item/clothing/gloves/tackler/combat/insulated
	belt = /obj/item/storage/belt/utility/chief/full/debug
	shoes = /obj/item/clothing/shoes/combat/debug
	id = /obj/item/card/id/debug/bst
	back = /obj/item/storage/backpack/holding
	box = /obj/item/storage/box/debugtools
	suit_store = /obj/item/tank/internals/oxygen
	internals_slot = ITEM_SLOT_SUITSTORE
	backpack_contents = list(
		/obj/item/melee/transforming/energy/axe=1,\
		/obj/item/storage/part_replacer/bluespace/tier4=1,\
		/obj/item/debug/human_spawner=1,\
		/obj/item/gun/energy/pulse=1,\
		/obj/item/gun/energy/taser/debug,\
		)
