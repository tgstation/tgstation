/datum/crafting_recipe/lance
	name = "Explosive Lance (Grenade)"
	result = /obj/item/spear/explosive
	reqs = list(
		/obj/item/spear = 1,
		/obj/item/grenade = 1
	)
	blacklist = list(/obj/item/spear/bonespear, /obj/item/spear/bamboospear)
	parts = list(
		/obj/item/spear = 1,
		/obj/item/grenade = 1
	)
	time = 1.5 SECONDS
	category = CAT_WEAPON_MELEE

/datum/crafting_recipe/ph_sensor //Ghetto science goggles for the wanna-be Walter White's upon our grimey-ass station.
	name = "Chemical Sensor"
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_MULTITOOL)
	result = /obj/item/ph_meter
	reqs = list(
		/obj/item/stock_parts/scanning_module = 1,
		/obj/item/stock_parts/cell = 1,
		/obj/item/stack/sheet/glass = 1,
		/obj/item/stack/cable_coil = 5,
		/obj/item/pen = 1,
		/obj/item/stack/sheet/iron = 2
	)
	time = 4 SECONDS
	category = CAT_CHEMISTRY
