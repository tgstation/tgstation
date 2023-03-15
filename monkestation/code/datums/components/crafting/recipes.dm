/datum/crafting_recipe/iron_butt
	name = "Prosthetic Butt"
	result = /obj/item/organ/butt/iron
	reqs = list(	/obj/item/stack/sheet/iron = 6,
					/obj/item/stack/cable_coil = 1)
	tools = list(TOOL_WELDER, TOOL_SCREWDRIVER)
	time = 15
	category = CAT_MISC

/datum/crafting_recipe/elder_atmosian_statue
	name = "Elder Atmosian Statue"
	result = /obj/structure/statue/elder_atmosian
	time = 6 SECONDS
	reqs = list(/obj/item/stack/sheet/mineral/metal_hydrogen = 10,
				/obj/item/stack/sheet/mineral/zaukerite = 1,
				/obj/item/grenade/gas_crystal/healium_crystal = 1,
				/obj/item/grenade/gas_crystal/pluonium_crystal = 1,
				/obj/item/grenade/gas_crystal/healium_crystal = 1
				)
	category = CAT_MISC

/datum/crafting_recipe/yes_slip
	name = "Yes-Slip Shoes"
	result = /obj/item/clothing/shoes/yes_slip
	time = 20
	reqs = list(	/obj/item/food/grown/banana = 2,
					/datum/reagent/lube = 100,
					/obj/item/stack/cable_coil = 1)
	tools = list(/obj/item/food/grown/banana)
	category = CAT_CLOTHING

/datum/crafting_recipe/paper_mask
	name = "Monkey Mask"
	result = /obj/item/clothing/mask/ookmask
	time = 10
	reqs = list(/obj/item/paper = 5)
	category = CAT_CLOTHING
	tools = list(TOOL_WIRECUTTER)

/datum/crafting_recipe/lockermech
	name = "Locker Mech"
	result = /obj/mecha/makeshift
	reqs = list(/obj/item/stack/cable_coil = 20,
				/obj/item/stack/sheet/iron = 10,
				/obj/item/storage/toolbox = 2, // For feet
				/obj/item/tank/internals/oxygen = 1, // For air
				/obj/item/electronics/airlock = 1, //You are stealing the motors from airlocks
				/obj/item/extinguisher = 1, //For bastard pnumatics
				/obj/item/paper = 5, //Cause paper is the best for making a mech airtight obviously
				/obj/item/flashlight = 1, //For the mech light
				/obj/item/stack/rods = 4, //to mount the equipment
				/obj/item/chair = 2) //For legs
	tools = list(/obj/item/weldingtool, /obj/item/screwdriver, /obj/item/wirecutters)
	time = 20 SECONDS
	category = CAT_ROBOT

/datum/crafting_recipe/lockermechdrill
	name = "Makeshift exosuit drill"
	result = /obj/item/mecha_parts/mecha_equipment/drill/makeshift
	reqs = list(/obj/item/stack/cable_coil = 5,
				/obj/item/stack/sheet/iron = 2,
				/obj/item/surgicaldrill = 1)
	tools = list(/obj/item/screwdriver)
	time = 5 SECONDS
	category = CAT_ROBOT

/datum/crafting_recipe/lockermechclamp
	name = "Makeshift exosuit clamp"
	result = /obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/makeshift
	reqs = list(/obj/item/stack/cable_coil = 5,
				/obj/item/stack/sheet/iron = 2,
				/obj/item/wirecutters = 1) //Don't ask, its just for the grabby grabby thing
	tools = list(/obj/item/screwdriver)
	time = 5 SECONDS
	category = CAT_ROBOT
