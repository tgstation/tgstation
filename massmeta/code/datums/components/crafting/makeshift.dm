/datum/crafting_recipe/makeshiftcrowbar
	name = "Makeshift Crowbar"
	reqs = list(/obj/item/stack/rods = 3) //just bang them together
	result = /obj/item/crowbar/makeshift
	time = 12 SECONDS
	category = CAT_TOOLS

/datum/crafting_recipe/makeshiftwrench
	name = "Makeshift Wrench"
	reqs = list(/obj/item/stack/sheet/iron = 2)
	result = /obj/item/wrench/makeshift
	time = 12 SECONDS
	category = CAT_TOOLS

/datum/crafting_recipe/makeshiftwirecutters
	name = "Makeshift Wirecutters"
	reqs = list(/obj/item/stack/sheet/iron = 2,
				/obj/item/stack/cable_coil = 5,
				/obj/item/stack/rods = 2)
	result = /obj/item/wirecutters/makeshift
	time = 15 SECONDS
	category = CAT_TOOLS

/datum/crafting_recipe/makeshiftweldingtool
	name = "Makeshift Welding Tool"
	reqs = list(/obj/item/tank/internals/emergency_oxygen = 1,
				/obj/item/assembly/igniter = 1)
	tool_behaviors = list(TOOL_SCREWDRIVER)
	result = /obj/item/weldingtool/makeshift
	time = 16 SECONDS
	category = CAT_TOOLS

/datum/crafting_recipe/makeshiftmultitool
	name = "Makeshift Multitool"
	reqs = list(/obj/item/assembly/igniter = 1,
				/obj/item/assembly/signaler = 1,
				/obj/item/stack/sheet/iron = 2,
				/obj/item/stack/cable_coil = 10)
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	result = /obj/item/multitool/makeshift
	time = 16 SECONDS
	category = CAT_TOOLS

/datum/crafting_recipe/makeshiftscrewdriver
	name = "Makeshift Screwdriver"
	reqs = list(/obj/item/stack/rods = 3)
	result = /obj/item/screwdriver/makeshift
	time = 12 SECONDS
	category = CAT_TOOLS

/datum/crafting_recipe/makeshifttoolbelt
	name = "Makeshift Toolbelt"
	reqs = list(/obj/item/stack/rods = 5,
				/obj/item/stack/sheet/iron = 2,
				/obj/item/stack/cable_coil = 15,
				/obj/item/stack/sheet/cloth = 2)
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	result = /obj/item/storage/belt/utility/makeshift
	time = 20 SECONDS
	category = CAT_TOOLS

/datum/crafting_recipe/makeshiftknife
	name = "Makeshift Knife"
	reqs = list(/obj/item/stack/rods = 3,
				/obj/item/stack/sheet/iron = 1,
				/obj/item/stack/cable_coil = 10)
	result = /obj/item/knife/kitchen/makeshift
	time = 12 SECONDS
	category = CAT_TOOLS

/datum/crafting_recipe/makeshiftradio
	name = "Makeshift Radio"
	reqs = list(/obj/item/assembly/signaler = 1,
        		/obj/item/radio/headset = 1,
				/obj/item/stack/cable_coil = 5)
	tool_behaviors = list(TOOL_SCREWDRIVER)
	result = /obj/item/radio/off/makeshift
	time = 12 SECONDS
	category = CAT_TOOLS
