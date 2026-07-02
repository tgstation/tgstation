/datum/crafting_recipe/blackcarpet
	name = "Black Carpet"
	reqs = list(
		/obj/item/stack/tile/carpet = 50,
		/obj/item/toy/crayon/black = 1,
	)
	result = /obj/item/stack/tile/carpet/black
	result_amount = 50
	category = CAT_TILES

/datum/crafting_recipe/wired_glass
	name = "Wired Glass Tile"
	result = /obj/item/stack/tile/light
	reqs = list(
		/obj/item/stack/sheet/iron = 1,
		/obj/item/stack/sheet/glass = 1,
		/obj/item/stack/cable_coil = 5,
	)
	category = CAT_TILES

/datum/crafting_recipe/circuit
	name = "Circuit Tile"
	result = /obj/item/stack/tile/circuit
	reqs = list(
		/obj/item/stack/sheet/iron = 1,
		/obj/item/stack/sheet/glass = 1,
		/obj/item/stack/cable_coil = 5,
	)
	category = CAT_TILES

/datum/crafting_recipe/glassed_plasma
	name = "Glassed Plasma Tile"
	result = /obj/item/stack/tile/mineral/glassed/plasma
	reqs = list(
		/obj/item/stack/tile/mineral/plasma = 1,
		/obj/item/stack/tile/glass = 1,
	)
	tool_behaviors = list(TOOL_WELDER)
	category = CAT_TILES

/datum/crafting_recipe/glassed_uranium
	name = "Glassed Uranium Tile"
	result = /obj/item/stack/tile/mineral/glassed/uranium
	reqs = list(
		/obj/item/stack/tile/mineral/uranium = 1,
		/obj/item/stack/tile/glass = 1,
	)
	tool_behaviors = list(TOOL_WELDER)
	category = CAT_TILES

/datum/crafting_recipe/glassed_bananium
	name = "Glassed Bananium Tile"
	result = /obj/item/stack/tile/mineral/glassed/bananium
	reqs = list(
		/obj/item/stack/tile/mineral/bananium = 1,
		/obj/item/stack/tile/glass = 1,
	)
	tool_behaviors = list(TOOL_WELDER)
	category = CAT_TILES

/datum/crafting_recipe/glassed_bluespace
	name = "Glassed Bluespace Tile"
	result = /obj/item/stack/tile/mineral/glassed/bluespace
	reqs = list(
		/obj/item/stack/tile/mineral/bluespace = 1,
		/obj/item/stack/tile/glass = 1,
	)
	tool_behaviors = list(TOOL_WELDER)
	category = CAT_TILES

/datum/crafting_recipe/glassed_telecrystal
	name = "Glassed Telecrystal Tile"
	result = /obj/item/stack/tile/mineral/glassed/telecrystal
	reqs = list(
		/obj/item/stack/tile/mineral/telecrystal = 1,
		/obj/item/stack/tile/glass = 1,
	)
	tool_behaviors = list(TOOL_WELDER)
	category = CAT_TILES

/datum/crafting_recipe/neo_tile
	name = "Neo Tile"
	result = /obj/item/stack/tile/neo/red
	reqs = list(
		/obj/item/stack/tile/iron = 4,
		/datum/reagent/phosphorus = 20,
		/datum/reagent/uranium/radium = 20,
		/datum/reagent/fuel/oil = 10,
	)
	result_amount = 4
	category = CAT_TILES
