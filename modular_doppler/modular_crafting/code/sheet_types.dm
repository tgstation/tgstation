// Add modular crafting recipes here, NOT IN BASE /tg/ CRAFTING LISTS

/**
 * Add a list of recipes to an existing recipe sublist.
 *
 * Arguments:
 * * stack_recipes - the existing list of stack recipes.
 * * recipe_list_title - the title for the recipe list we're adding to
 * * appent_recipes - Add these recipes to the given recipe list.
 */
/proc/add_recipes_to_sublist(list/stack_recipes, recipe_list_title, list/append_recipes)
	for(var/datum/stack_recipe_list/sublist in stack_recipes)
		if(sublist.title != recipe_list_title)
			continue

		sublist.recipes += append_recipes
		return

	CRASH("Could not find recipe sublist [recipe_list_title] to add more recipes!")

// Iron

GLOBAL_LIST_INIT(doppler_metal_recipes, list(
	new/datum/stack_recipe("anvil", /obj/structure/reagent_anvil, 10, time = 2 SECONDS, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, category = CAT_TOOLS),
	new/datum/stack_recipe("forge", /obj/structure/reagent_forge, 10, time = 2 SECONDS, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, category = CAT_TOOLS),
	new/datum/stack_recipe("throwing wheel", /obj/structure/throwing_wheel, 10, time = 2 SECONDS, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, category = CAT_TOOLS),
))

GLOBAL_LIST_INIT(doppler_metal_airlock_recipes, list(
))

/obj/item/stack/sheet/iron/get_main_recipes()
	. = ..()
	. += GLOB.doppler_metal_recipes
	add_recipes_to_sublist(., "airlock assemblies", GLOB.doppler_metal_airlock_recipes)

// Plasteel

GLOBAL_LIST_INIT(doppler_plasteel_recipes, list(
))

/obj/item/stack/sheet/plasteel/get_main_recipes()
	. = ..()
	. += GLOB.doppler_plasteel_recipes

// Rods

GLOBAL_LIST_INIT(doppler_rod_recipes, list(
	new/datum/stack_recipe("crutch", /obj/item/cane/crutch, 3, time = 1 SECONDS, category = CAT_TOOLS),
	new/datum/stack_recipe("torch mount", /obj/item/wallframe/torch_mount, 2, category = CAT_MISC),
	new/datum/stack_recipe("towel bin", /obj/structure/towel_bin/empty, 2, time = 0.5 SECONDS, crafting_flags = CRAFT_CHECK_DENSITY, category = CAT_CONTAINERS),
))

/obj/item/stack/rods/get_main_recipes()
	. = ..()
	. += GLOB.doppler_rod_recipes

// Wood

GLOBAL_LIST_INIT(doppler_wood_recipes, list(
	new/datum/stack_recipe("water basin", /obj/structure/reagent_water_basin, 5, time = 2 SECONDS, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, category = CAT_TOOLS),
	new/datum/stack_recipe("forging work bench", /obj/structure/reagent_crafting_bench, 5, time = 2 SECONDS, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, category = CAT_TOOLS),
	new/datum/stack_recipe("sauna oven", /obj/structure/sauna_oven, 30, time = 1.5 SECONDS, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, category = CAT_ENTERTAINMENT),
	new/datum/stack_recipe("large wooden mortar", /obj/structure/large_mortar, 10, time = 3 SECONDS, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, category = CAT_TOOLS),
	new/datum/stack_recipe("wooden cutting board", /obj/item/cutting_board, 5, time = 2 SECONDS, category = CAT_TOOLS),
	new/datum/stack_recipe("wooden shelf", /obj/structure/rack/wooden, 2, time = 2 SECONDS, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, category = CAT_STRUCTURE),
	new/datum/stack_recipe("seed shelf", /obj/machinery/smartfridge/wooden/seed_shelf, 10, time = 2 SECONDS, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, category = CAT_STRUCTURE),
	new/datum/stack_recipe("produce bin", /obj/machinery/smartfridge/wooden/produce_bin, 10, time = 2 SECONDS, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, category = CAT_STRUCTURE),
	new/datum/stack_recipe("produce display", /obj/machinery/smartfridge/wooden/produce_display, 10, time = 2 SECONDS, crafting_flags = CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, category = CAT_STRUCTURE),
	new/datum/stack_recipe("ration shelf", /obj/machinery/smartfridge/wooden/ration_shelf, 10, time = 2 SECONDS, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, category = CAT_STRUCTURE),
	new/datum/stack_recipe("storage barrel", /obj/structure/closet/crate/wooden/storage_barrel, 4, time = 2 SECONDS, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, category = CAT_STRUCTURE),
	new/datum/stack_recipe("worm barrel", /obj/structure/wormfarm, 5, time = 2 SECONDS, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, category = CAT_TOOLS),
	new/datum/stack_recipe("gutlunch trough", /obj/structure/ore_container/food_trough/gutlunch_trough, 5, time = 2 SECONDS, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, category = CAT_STRUCTURE),
	new/datum/stack_recipe("sturdy wooden fence", /obj/structure/railing/wooden_fencing, 5, time = 2 SECONDS, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, category = CAT_STRUCTURE),
	new/datum/stack_recipe("sturdy wooden fence gate", /obj/structure/railing/wooden_fencing/gate, 5, time = 2 SECONDS, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, category = CAT_STRUCTURE),
	new/datum/stack_recipe("large wooden gate", /obj/structure/mineral_door/wood/large_gate, 10, time = 5 SECONDS, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, category = CAT_STRUCTURE),
	new/datum/stack_recipe("wooden bowl", /obj/item/reagent_containers/cup/bowl/wood_bowl, 3, time = 2 SECONDS, category = CAT_TOOLS),
))


/obj/item/stack/sheet/mineral/wood/get_main_recipes()
	. = ..()
	. += GLOB.doppler_wood_recipes

// Cardboard

GLOBAL_LIST_INIT(doppler_cardboard_recipes, list(
	new/datum/stack_recipe("coffee holder", /obj/item/storage/coffee, 2, category = CAT_CONTAINERS),
))

/obj/item/stack/sheet/cardboard/get_main_recipes()
	. = ..()
	. += GLOB.doppler_cardboard_recipes

// Cloth

GLOBAL_LIST_INIT(doppler_cloth_recipes, list(
	new/datum/stack_recipe("towel", /obj/item/towel, 2, category = CAT_CLOTHING),
	new/datum/stack_recipe("eyepatch wrap", /obj/item/clothing/glasses/eyepatch/wrap, 2, category = CAT_CLOTHING),
	new/datum/stack_recipe("eyepatch", /obj/item/clothing/glasses/eyepatch, 2, category = CAT_CLOTHING),
	new/datum/stack_recipe("xenoarch bag", /obj/item/storage/bag/xenoarch, 4, category = CAT_CONTAINERS),
))

/obj/item/stack/sheet/cloth/get_main_recipes()
	. = ..()
	. += GLOB.doppler_cloth_recipes

// Leather

GLOBAL_LIST_INIT(doppler_leather_recipes, list(
))

GLOBAL_LIST_INIT(doppler_leather_belt_recipes, list(
	new/datum/stack_recipe("medical bandolier", /obj/item/storage/belt/med_bandolier, 5, category = CAT_CONTAINERS),
	new/datum/stack_recipe("xenoarch belt", /obj/item/storage/belt/utility/xenoarch, 4, category = CAT_CONTAINERS),
))

/obj/item/stack/sheet/leather/get_main_recipes()
	. = ..()
	. += GLOB.doppler_leather_recipes
	add_recipes_to_sublist(., "belts", GLOB.doppler_leather_belt_recipes)

// Titanium

GLOBAL_LIST_INIT(doppler_titanium_recipes, list(
))

/obj/item/stack/sheet/mineral/titanium/get_main_recipes()
	. = ..()
	. += GLOB.doppler_titanium_recipes

// Snow

GLOBAL_LIST_INIT(doppler_snow_recipes, list(
))

/obj/item/stack/sheet/mineral/snow/get_main_recipes()
	. = ..()
	. += GLOB.doppler_snow_recipes

// Sand

GLOBAL_LIST_INIT(doppler_sand_recipes, list(
	new/datum/stack_recipe("ant farm", /obj/structure/antfarm, 20, time = 2 SECONDS, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, category = CAT_TOOLS),
))

/obj/item/stack/ore/glass/get_main_recipes()
	. = ..()
	. += GLOB.doppler_sand_recipes
