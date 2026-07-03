/datum/crafting_recipe/nt_cane_gun
	name = "fancy cane gun"
	result = /obj/item/melee/baton/nt_cane/gun
	time = 10 SECONDS
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_MULTITOOL)
	reqs = list(
		/obj/item/melee/baton/nt_cane = 1,
		/obj/item/stock_parts/matter_bin/bluespace = 1,
		/obj/item/stock_parts/capacitor/quadratic = 2,
		/obj/item/stock_parts/micro_laser/quadultra = 4,
		/obj/item/stack/cable_coil = 5,
	)
	crafting_flags = CRAFT_NO_MATERIALS
	blacklist = list(/obj/item/melee/baton/nt_cane/gun)
	category = CAT_EQUIPMENT
