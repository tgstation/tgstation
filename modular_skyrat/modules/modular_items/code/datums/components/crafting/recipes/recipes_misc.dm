/datum/crafting_recipe/makeshift/crowbar
	name = "Makeshift Crowbar"
	tool_paths = list(/obj/item/hammer/makeshift)
	result = /obj/item/crowbar/makeshift
	reqs = list(/obj/item/stack/sheet/iron = 4,
				/obj/item/stack/sheet/cloth = 1,
				/obj/item/stack/cable_coil = 1)
	time = 120
	category = CAT_MISC

/datum/crafting_recipe/makeshift/hammer
	name = "Makeshift Hammer"
	result = /obj/item/hammer/makeshift
	reqs = list(/obj/item/stack/cable_coil = 1,
				/obj/item/stack/rods = 2,
				/obj/item/kitchen/rollingpin = 2)
	time = 80
	category = CAT_MISC

/datum/crafting_recipe/makeshift/screwdriver
	name = "Makeshift Screwdriver"
	tool_paths = list(/obj/item/hammer/makeshift)
	result = /obj/item/screwdriver/makeshift
	reqs = list(/obj/item/stack/cable_coil = 1,
				/obj/item/stack/sheet/cloth = 2,
				/obj/item/stack/rods = 2)
	time = 80
	category = CAT_MISC

/datum/crafting_recipe/makeshift/welder
	name = "Makeshift Welder"
	tool_paths = list(/obj/item/hammer/makeshift)
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	result = /obj/item/weldingtool/makeshift
	reqs = list(/obj/item/tank/internals/emergency_oxygen = 1,
				/obj/item/stack/sheet/iron = 6,
				/obj/item/stack/sheet/glass = 2,
				/obj/item/stack/cable_coil = 2)
	time = 160
	category = CAT_MISC

/datum/crafting_recipe/makeshift/wirecutters
	name = "Makeshift Wirecutters"
	tool_paths = list(/obj/item/hammer/makeshift)
	tool_behaviors = list(TOOL_SCREWDRIVER)
	result = /obj/item/wirecutters/makeshift
	reqs = list(/obj/item/stack/cable_coil = 2,
				/obj/item/stack/rods = 4)
	time = 80
	category = CAT_MISC

/datum/crafting_recipe/makeshift/wrench
	name = "Makeshift Wrench"
	tool_paths = list(/obj/item/hammer/makeshift)
	tool_behaviors = list(TOOL_SCREWDRIVER)
	result = /obj/item/wrench/makeshift
	reqs = list(/obj/item/stack/cable_coil = 1,
				/obj/item/stack/sheet/iron = 3,
				/obj/item/stack/rods = 1,
				/obj/item/stack/sheet/cloth = 2)
	time = 80
	category = CAT_MISC

//Ashwalker Necklace//
/datum/crafting_recipe/ashnecklace
	name = "Draconic Necklace"
	result = /obj/item/clothing/neck/necklace/ashwalker
	reqs = list(/obj/item/stack/sheet/bone = 1, /obj/item/stack/sheet/sinew = 2, /obj/item/organ/regenerative_core = 1)
	always_available = FALSE
	time = 30
	category = CAT_PRIMAL
