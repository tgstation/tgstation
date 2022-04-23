/datum/armament_entry/assault_operatives/primary
	category = ARMAMENT_CATEGORY_PRIMARY
	category_item_limit = ARMAMENT_CATEGORY_PRIMARY_LIMIT
	slot_to_equip = ITEM_SLOT_SUITSTORE
	cost = 10

/datum/armament_entry/assault_operatives/primary/submachinegun
	subcategory = ARMAMENT_SUBCATEGORY_SUBMACHINEGUN
	mags_to_spawn = 4

/datum/armament_entry/assault_operatives/primary/submachinegun/p90
	item_type = /obj/item/gun/ballistic/automatic/p90

/datum/armament_entry/assault_operatives/primary/submachinegun/wildcat
	item_type = /obj/item/gun/ballistic/automatic/cfa_wildcat
	cost = 5

/datum/armament_entry/assault_operatives/primary/submachinegun/lynx
	item_type = /obj/item/gun/ballistic/automatic/cfa_lynx

/datum/armament_entry/assault_operatives/primary/submachinegun/mp40
	item_type = /obj/item/gun/ballistic/automatic/mp40
	mags_to_spawn = 3

/datum/armament_entry/assault_operatives/primary/submachinegun/ppsh
	item_type = /obj/item/gun/ballistic/automatic/ppsh

/datum/armament_entry/assault_operatives/primary/submachinegun/c20r
	item_type = /obj/item/gun/ballistic/automatic/c20r

/datum/armament_entry/assault_operatives/primary/assaultrifle
	subcategory = ARMAMENT_SUBCATEGORY_ASSAULTRIFLE

/datum/armament_entry/assault_operatives/primary/assaultrifle/akm
	item_type = /obj/item/gun/ballistic/automatic/akm

/datum/armament_entry/assault_operatives/primary/assaultrifle/m16
	item_type = /obj/item/gun/ballistic/automatic/m16

/datum/armament_entry/assault_operatives/primary/assaultrifle/stg
	item_type = /obj/item/gun/ballistic/automatic/stg
	cost = 12

/datum/armament_entry/assault_operatives/primary/assaultrifle/fg42
	item_type = /obj/item/gun/ballistic/automatic/fg42

/datum/armament_entry/assault_operatives/primary/special
	subcategory = ARMAMENT_SUBCATEGORY_SPECIAL

/datum/armament_entry/assault_operatives/primary/special/l6saw
	item_type = /obj/item/gun/ballistic/automatic/l6_saw
	cost = 15
	mags_to_spawn = 2

/datum/armament_entry/assault_operatives/primary/special/mg9
	item_type = /obj/item/gun/ballistic/automatic/mg34/mg42
	cost = 15
	mags_to_spawn = 2

/datum/armament_entry/assault_operatives/primary/special/smartgun
	item_type = /obj/item/gun/ballistic/automatic/smartgun
	cost = 12

/datum/armament_entry/assault_operatives/primary/special/rocket_launcher
	item_type = /obj/item/gun/ballistic/rocketlauncher/unrestricted
	cost = 15

/datum/armament_entry/assault_operatives/primary/special/rocket_launcher/after_equip(turf/safe_drop_location, obj/item/item_to_equip)
	var/obj/item/storage/box/ammo_box/spawned_box = new(safe_drop_location)
	spawned_box.name = "ROCKETS - [item_to_equip.name]"
	for(var/i in 1 to 5)
		new /obj/item/ammo_casing/caseless/rocket(spawned_box)
