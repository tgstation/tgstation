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

/datum/crafting_recipe/goliath
	name = "Goliath Carpet"
	result = /obj/item/stack/tile/carpet/goliath
	reqs = list(
		/obj/item/stack/sheet/animalhide/goliath_hide = 1,
		/obj/item/stack/sheet/sinew = 1,
	)
	result_amount = 4

/datum/crafting_recipe/stained_glass_red
	name = "Red Stained Glass"
	reqs = list(
		/obj/item/stack/tile/glass = 40,
		/obj/item/stack/rods = 20,
		/obj/item/toy/crayon/red = 1,
	)
	result = /turf/open/floor/glass/stained_red
	result_amount = 40
	category = CAT_TILES

/datum/crafting_recipe/stained_glass_orange
	name = "Orange Stained Glass"
	reqs = list(
		/obj/item/stack/tile/glass = 40,
		/obj/item/stack/rods = 20,
		/obj/item/toy/crayon/orange = 1,
	)
	result = /turf/open/floor/glass/stained_orange
	result_amount = 40
	category = CAT_TILES

/datum/crafting_recipe/stained_glass_yellow
	name = "Yellow Stained Glass"
	reqs = list(
		/obj/item/stack/tile/glass = 40,
		/obj/item/stack/rods = 20,
		/obj/item/toy/crayon/yellow = 1,
	)
	result = /turf/open/floor/glass/stained_yellow
	result_amount = 40
	category = CAT_TILES

/datum/crafting_recipe/stained_glass_green
	name = "Green Stained Glass"
	reqs = list(
		/obj/item/stack/tile/glass = 40,
		/obj/item/stack/rods = 20,
		/obj/item/toy/crayon/green = 1,
	)
	result = /turf/open/floor/glass/stained_green
	result_amount = 40
	category = CAT_TILES

/datum/crafting_recipe/stained_glass_blue
	name = "Blue Stained Glass"
	reqs = list(
		/obj/item/stack/tile/glass = 40,
		/obj/item/stack/rods = 20,
		/obj/item/toy/crayon/blue = 1,
	)
	result = /turf/open/floor/glass/stained_blue
	result_amount = 40
	category = CAT_TILES

/datum/crafting_recipe/stained_glass_purple
	name = "Purple Stained Glass"
	reqs = list(
		/obj/item/stack/tile/glass = 40,
		/obj/item/stack/rods = 20,
		/obj/item/toy/crayon/purple = 1,
	)
	result = /turf/open/floor/glass/stained_purple
	result_amount = 40
	category = CAT_TILES

/datum/crafting_recipe/stained_glass_white
	name = "White Stained Glass"
	reqs = list(
		/obj/item/stack/tile/glass = 40,
		/obj/item/stack/rods = 20,
		/obj/item/toy/crayon/white = 1,
	)
	result = /turf/open/floor/glass/stained_white
	result_amount = 40
	category = CAT_TILES

/datum/crafting_recipe/stained_glass_black
	name = "Black Stained Glass"
	reqs = list(
		/obj/item/stack/tile/glass = 40,
		/obj/item/stack/rods = 20,
		/obj/item/toy/crayon/black = 1,
	)
	result = /turf/open/floor/glass/stained_black
	result_amount = 40
	category = CAT_TILES
