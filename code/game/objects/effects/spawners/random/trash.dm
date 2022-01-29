/obj/effect/spawner/random/trash
	name = "trash spawner"
	desc = "Ewwwwwww gross."
	icon_state = "trash"

/obj/effect/spawner/random/trash/garbage
	name = "garbage spawner"
	loot = list(
		/obj/effect/spawner/random/trash/food_packaging = 20,
		/obj/item/trash/can = 15,
		/obj/item/shard = 10,
		/obj/effect/spawner/random/trash/cigbutt = 10,
		/obj/effect/spawner/random/trash/botanical_waste = 5,
		/obj/item/reagent_containers/glass = 5,
		/obj/item/broken_bottle = 5,
		/obj/item/reagent_containers/glass/bowl = 5,
		/obj/item/light/tube/broken = 5,
		/obj/item/light/bulb/broken = 5,
		/obj/item/assembly/mousetrap/armed = 5,
		/obj/item/stack/cable_coil = 5,
		/obj/item/food/deadmouse = 1,
		/obj/item/trash/candle = 1,
		/obj/item/popsicle_stick = 1,
		/obj/item/reagent_containers/syringe = 1,
		/obj/item/reagent_containers/food/drinks/sillycup = 1,
	)

/obj/effect/spawner/random/trash/cigbutt
	name = "cigarette butt spawner"
	loot = list(
		/obj/item/cigbutt = 50,
		/obj/item/cigbutt/roach = 30,
		/obj/item/food/candy_trash = 10,
		/obj/item/cigbutt/cigarbutt = 10,
	)

/obj/effect/spawner/random/trash/food_packaging
	name = "empty food packaging spawner"
	loot = list(
		/obj/item/trash/raisins = 2,
		/obj/item/trash/cheesie = 2,
		/obj/item/trash/candy = 2,
		/obj/item/trash/chips = 2,
		/obj/item/trash/sosjerky = 2,
		/obj/item/trash/pistachios = 2,
		/obj/item/trash/peanuts = 2,
		/obj/item/trash/boritos = 1,
		/obj/item/trash/boritos/green = 1,
		/obj/item/trash/boritos/purple = 1,
		/obj/item/trash/boritos/red = 1,
		/obj/item/trash/can/food/beans = 1,
		/obj/item/trash/can/food/peaches = 1,
		/obj/item/trash/can/food/envirochow = 1,
		/obj/item/trash/popcorn = 1,
		/obj/item/trash/energybar = 1,
		/obj/item/trash/can/food/peaches/maint = 1,
		/obj/item/trash/semki = 1,
		/obj/item/trash/cnds = 1,
		/obj/item/trash/syndi_cakes = 1,
		/obj/item/trash/shrimp_chips = 1,
		/obj/item/trash/waffles = 1,
		/obj/item/trash/tray = 1,
	)

/obj/effect/spawner/random/trash/botanical_waste
	name = "botanical waste spawner"
	icon_state = "peel"
	loot = list(
		/obj/item/grown/bananapeel = 6,
		/obj/item/grown/corncob = 3,
		/obj/item/food/grown/bungopit = 1,
	)

/obj/effect/spawner/random/trash/grille_or_waste
	name = "grille or waste spawner"
	icon_state = "grille"
	loot = list(
		/obj/structure/grille = 5,
		/obj/effect/spawner/random/trash/food_packaging = 3,
		/obj/effect/spawner/random/trash/cigbutt = 1,
		/obj/item/food/deadmouse = 1,
	)

/obj/effect/spawner/random/trash/hobo_squat
	name = "hobo squat spawner"
	icon_state = "dirty_mattress"
	spawn_all_loot = TRUE
	loot = list(
		/obj/structure/bed/maint,
		/obj/effect/spawner/random/trash/grime,
		/obj/effect/spawner/random/entertainment/drugs,
	)

/obj/effect/spawner/random/trash/moisture_trap
	name = "moisture trap spawner"
	icon_state = "moisture_trap"
	spawn_all_loot = TRUE
	loot = list(
		/obj/effect/spawner/random/trash/moisture,
		/obj/structure/moisture_trap,
	)

/obj/effect/spawner/random/trash/mess
	name = "gross decal spawner"
	icon_state = "vomit"
	loot = list(
		/obj/effect/decal/cleanable/dirt = 6,
		/obj/effect/decal/cleanable/garbage = 3,
		/obj/effect/decal/cleanable/vomit/old = 3,
		/obj/effect/decal/cleanable/blood/gibs/old = 3,
		/obj/effect/decal/cleanable/insectguts = 1,
		/obj/effect/decal/cleanable/greenglow/ecto = 1,
		/obj/effect/decal/cleanable/wrapping = 1,
		/obj/effect/decal/cleanable/plastic = 1,
		/obj/effect/decal/cleanable/glass = 1,
		/obj/effect/decal/cleanable/ants = 1,
	)

/obj/effect/spawner/random/trash/grime
	name = "trash and grime spawner"
	spawn_loot_count = 5
	spawn_scatter_radius = 2
	loot = list( // This spawner will scatter garbage around a dirty site.
		/obj/effect/spawner/random/trash/garbage = 6,
		/mob/living/basic/cockroach = 5,
		/obj/effect/decal/cleanable/garbage = 4,
		/obj/effect/decal/cleanable/vomit/old = 3,
		/obj/effect/spawner/random/trash/cigbutt = 2,
	)

/obj/effect/spawner/random/trash/moisture
	name = "water hazard spawner"
	icon_state = "caution"
	spawn_loot_count = 2
	spawn_scatter_radius = 1
	loot = list( // This spawner will scatter water related items around a moist site.
		/obj/item/clothing/head/cone = 7,
		/obj/item/clothing/suit/caution = 3,
		/mob/living/simple_animal/hostile/retaliate/frog = 2,
		/obj/item/reagent_containers/glass/rag = 2,
		/obj/item/reagent_containers/glass/bucket = 2,
		/obj/effect/decal/cleanable/blood/old = 2,
		/obj/structure/mopbucket = 2,
	)

/obj/effect/spawner/random/trash/graffiti
	name = "random graffiti spawner"
	icon_state = "rune"
	loot = list(/obj/effect/decal/cleanable/crayon)
	var/graffiti_icons = list(
		"rune1", "rune2", "rune3", "rune4", "rune5", "rune6",
		"amyjon", "face", "matt", "revolution", "engie", "guy",
		"end", "dwarf", "uboa", "body", "cyka", "star", "poseur tag",
		"prolizard", "antilizard", "danger", "firedanger", "electricdanger",
		"biohazard", "radiation", "safe", "evac", "space", "med", "trade", "shop",
		"food", "peace", "like", "skull", "nay", "heart", "credit",
		"smallbrush", "brush", "largebrush", "splatter", "snake", "stickman",
		"carp", "ghost", "clown", "taser", "disk", "fireaxe", "toolbox",
		"corgi", "cat", "toilet", "blueprint", "beepsky", "scroll", "bottle",
		"shotgun", "arrow", "line", "thinline", "shortline", "body", "chevron",
		"footprint", "clawprint", "pawprint",
	)
	color = COLOR_WHITE //sets the color of the graffiti (used for mapedits)
	var/random_color = TRUE //whether the graffiti will spawn with a random color (used for mapedits)
	var/random_icon = TRUE // whether the graffiti will spawn with the same icon

/obj/effect/spawner/random/trash/graffiti/proc/select_graffiti(graffiti_decal)
	var/obj/effect/decal/cleanable/crayon/decal = graffiti_decal
	color = random_color && "#[random_short_color()]" || color
	icon_state = random_icon && pick(graffiti_icons) || icon_state

	decal.add_atom_colour(color, FIXED_COLOUR_PRIORITY)
	decal.icon_state = icon_state

/obj/effect/spawner/random/trash/mopbucket
	name = "mop bucket spawner"
	icon_state = "mopbucket"
	spawn_loot_count = 2
	spawn_loot_double = FALSE
	loot = list(
		/obj/structure/mopbucket = 10,
		/obj/item/mop = 5,
		/obj/item/clothing/suit/caution = 3,
		/obj/item/reagent_containers/glass/bucket = 1,
		/obj/item/reagent_containers/glass/bucket/wooden = 1,
	)

/obj/effect/spawner/random/trash/caution_sign
	name = "caution sign spawner"
	icon_state = "caution"
	loot = list(
		/obj/item/clothing/suit/caution = 40,
		/obj/structure/holosign/wetsign = 5,
		/obj/structure/holosign/barrier = 3,
		/obj/structure/holosign/barrier/wetsign = 2,
	)


/obj/effect/spawner/random/trash/bucket
	name = "bucket spawner"
	icon_state = "caution"
	loot = list(
		/obj/item/reagent_containers/glass/bucket,
		/obj/item/reagent_containers/glass/bucket/wooden,
	)

/obj/effect/spawner/random/trash/soap
	name = "soap spawner"
	icon_state = "soap"
	loot = list(
		/obj/item/soap = 25,
		/obj/item/bikehorn/rubberducky = 20,
		/obj/item/soap/homemade = 20,
		/obj/item/soap/deluxe = 15,
		/obj/item/soap/nanotrasen = 10,
		/obj/item/food/urinalcake = 5,
		/obj/item/bikehorn/rubberducky/plasticducky = 5,
	)

/obj/effect/spawner/random/trash/box
	name = "box spawner"
	icon_state = "box"
	loot = list(
		/obj/structure/closet/cardboard = 9,
		/obj/structure/closet/cardboard/metal = 1,
	)

/obj/effect/spawner/random/trash/bin
	name = "trashbin spawner"
	icon_state = "trash_bin"
	loot = list(
		/obj/structure/closet/crate/bin = 10,
		/obj/structure/closet/crate/trashcart = 3,
		/obj/structure/closet/crate/trashcart/filled = 3,
		/obj/effect/spawner/random/trash/box = 3,
		/obj/structure/closet/crate/trashcart/laundry = 1,
	)


/obj/effect/spawner/random/trash/janitor_supplies
	name = "janitor supplies spawner"
	icon_state = "box_small"
	loot = list(
		/obj/item/storage/box/mousetraps,
		/obj/item/storage/box/lights/tubes,
		/obj/item/storage/box/lights/mixed,
		/obj/item/storage/box/lights/bulbs,
	)
