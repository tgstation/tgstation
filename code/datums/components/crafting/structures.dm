/datum/crafting_recipe/paperframes
	name = "Paper Frames"
	time = 1 SECONDS
	reqs = list(
		/obj/item/stack/sheet/mineral/wood = 5,
		/obj/item/paper = 20,
	)
	result = /obj/item/stack/sheet/paperframes
	result_amount = 5
	category = CAT_STRUCTURE
	requirements_mats_blacklist = list(/obj/item/stack/sheet/mineral/wood)

/datum/crafting_recipe/rib
	name = "Colossal Rib"
	reqs = list(
		/obj/item/stack/sheet/bone = 10,
		/datum/reagent/fuel/oil = 5,
	)
	result = /obj/structure/statue/bone/rib
	category = CAT_STRUCTURE
	crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_MUST_BE_LEARNED

/datum/crafting_recipe/skull
	name = "Skull Carving"
	reqs = list(
		/obj/item/stack/sheet/bone = 6,
		/datum/reagent/fuel/oil = 5,
	)
	result = /obj/structure/statue/bone/skull
	category = CAT_STRUCTURE
	crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_MUST_BE_LEARNED

/datum/crafting_recipe/halfskull
	name = "Cracked Skull Carving"
	reqs = list(
		/obj/item/stack/sheet/bone = 3,
		/datum/reagent/fuel/oil = 5,
	)
	result = /obj/structure/statue/bone/skull/half
	category = CAT_STRUCTURE
	crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_MUST_BE_LEARNED

/datum/crafting_recipe/firecabinet
	name = "Fire Axe Cabinet"
	result = /obj/item/wallframe/fireaxecabinet
	time = 8 SECONDS
	reqs = list(
		/obj/item/stack/sheet/plasteel = 5,
		/obj/item/stack/sheet/glass = 5,
		/obj/item/stack/cable_coil = 10,
	)
	category = CAT_STRUCTURE

/datum/crafting_recipe/mechcabinet
	name = "Mech Removal Cabinet"
	result = /obj/item/wallframe/fireaxecabinet/mechremoval
	time = 8 SECONDS
	reqs = list(
		/obj/item/stack/sheet/plasteel = 5,
		/obj/item/stack/sheet/glass = 5,
		/obj/item/stack/cable_coil = 10,
	)
	category = CAT_STRUCTURE

/datum/crafting_recipe/manucrate
	name = "Manufacturing Storage Unit"
	result = /obj/machinery/power/manufacturing/storagebox
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_WELDER)
	time = 6 SECONDS
	reqs = list(
		/obj/item/stack/sheet/iron = 10,
	)
	category = CAT_STRUCTURE
	crafting_flags = CRAFT_CHECK_DENSITY

/datum/crafting_recipe/adam_pedestal
	name = "Adamantine Pedestal"
	result = /obj/item/adamantine_pedestal
	reqs = list(
		/obj/item/stack/sheet/mineral/adamantine = 20,
	)
	time = 120 SECONDS
	category = CAT_STRUCTURE


/datum/crafting_recipe/sm_small
	name = "Small Supermatter Crystal"
	result = /obj/machinery/power/supermatter_crystal/small
	reqs = list(
		/obj/item/gun/magic/wand/shrink = 1,
		/obj/item/adamantine_pedestal = 1,
	)
	machinery = list(
		/obj/machinery/power/supermatter_crystal = CRAFTING_MACHINERY_CONSUME,
	)
	time = 120 SECONDS
	category = CAT_STRUCTURE

/datum/crafting_recipe/elder_atmosian_statue
	name = "Elder Atmosian Statue"
	result = /obj/structure/statue/elder_atmosian
	time = 6 SECONDS
	reqs = list(
		/obj/item/stack/sheet/mineral/metal_hydrogen = 20,
		/obj/item/stack/sheet/mineral/zaukerite = 15,
		/obj/item/stack/sheet/iron = 30,
	)
	category = CAT_STRUCTURE

/datum/crafting_recipe/secure_safe
	name = "Secure safe"
	result = /obj/item/wallframe/secure_safe
	reqs = list(
		/obj/item/stack/sheet/plasteel = 10,
		/obj/item/stack/sheet/mineral/titanium = 5,
		/obj/item/stack/cable_coil = 5,
		/obj/item/stack/rods = 5,
		/obj/item/wallframe/button = 1,
	)
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_WELDER, TOOL_DRILL)
	time = 30 SECONDS
	removed_mats = list(
		/datum/material/alloy/plasteel = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 1.55,
		/datum/material/titanium = SHEET_MATERIAL_AMOUNT,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT,
	)
	category = CAT_STRUCTURE

/datum/crafting_recipe/vault
	name = "Vault"
	result = /obj/structure/safe/open
	reqs = list(
		/obj/item/stack/sheet/mineral/metal_hydrogen = 20,
		/obj/item/stack/sheet/mineral/plastitanium = 10,
		/obj/item/stack/cable_coil = 5,
		/obj/item/stack/rods = 5,
		/obj/item/wallframe/secure_safe = 1,
	)
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_WELDER, TOOL_DRILL)
	time = 90 SECONDS
	removed_mats = list(
		/datum/material/metalhydrogen = SHEET_MATERIAL_AMOUNT * 5,
		/datum/material/alloy/plastitanium = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/alloy/plasteel = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 1.5,
		/datum/material/titanium = SHEET_MATERIAL_AMOUNT,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT,
	)
	category = CAT_STRUCTURE
	crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ON_SOLID_GROUND

/datum/crafting_recipe/vault_floor
	name = "Floor Vault"
	result = /obj/structure/safe/floor/open
	reqs = list(
		/obj/item/stack/sheet/mineral/metal_hydrogen = 20,
		/obj/item/stack/sheet/mineral/plastitanium = 10,
		/obj/item/stack/cable_coil = 5,
		/obj/item/stack/rods = 5,
	)
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_WELDER, TOOL_DRILL)
	time = 90 SECONDS
	category = CAT_STRUCTURE
	removed_mats = list(
		/datum/material/metalhydrogen = SHEET_MATERIAL_AMOUNT * 5,
		/datum/material/alloy/plastitanium = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/iron = SHEET_MATERIAL_AMOUNT,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT,
	)
	crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ON_SOLID_GROUND
