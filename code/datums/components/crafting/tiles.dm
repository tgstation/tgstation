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

/datum/crafting_recipe/fakewater
	name = "Fake Water Tile"
	time = 0 SECONDS
	reqs = list(
		/datum/reagent/water = 0.25,
		/obj/item/stack/tile/iron = 1
	)
	result = /obj/item/stack/tile/fakewater
	category = CAT_TILES

/datum/crafting_recipe/fakecoastline
	name = "Fake Coastline Tile"
	time = 0 SECONDS
	reqs = list(
		/datum/reagent/water = 0.125,
		/obj/item/stack/tile/fakesand = 1
	)
	result = /obj/item/stack/tile/fakecoastline
	category = CAT_TILES
