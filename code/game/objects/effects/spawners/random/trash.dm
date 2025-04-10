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
		/obj/effect/spawner/random/trash/bacteria = 5,
		/obj/effect/spawner/random/trash/botanical_waste = 5,
		/obj/item/reagent_containers/cup/glass/drinkingglass = 5,
		/obj/item/broken_bottle = 5,
		/obj/item/light/tube/broken = 5,
		/obj/item/light/bulb/broken = 5,
		/obj/item/assembly/mousetrap/armed = 5,
		/obj/item/stack/cable_coil = 5,
		/obj/item/food/deadmouse = 1,
		/obj/item/trash/candle = 1,
		/obj/item/reagent_containers/cup/rag = 1,
		/obj/item/trash/flare = 1,
		/obj/item/popsicle_stick = 1,
		/obj/item/reagent_containers/syringe = 1,
		/obj/item/reagent_containers/cup/glass/sillycup = 1,
		/obj/item/shard/plasma = 1,
	)

/obj/effect/spawner/random/trash/deluxe_garbage
	name = "fancy deluxe garbage spawner"
	loot = list(
		/obj/effect/spawner/random/trash/garbage = 25,
		/obj/effect/spawner/random/trash/food_packaging = 10,
		/obj/effect/spawner/random/entertainment/money = 10,
		/obj/effect/spawner/random/trash/crushed_can = 10,
		/obj/item/shard/plasma = 5,
		/obj/item/reagent_containers/applicator/pill/maintenance = 5,
		/obj/item/mail/junkmail = 5,
		/obj/effect/spawner/random/food_or_drink/snack = 5,
		/obj/effect/spawner/random/trash/soap = 3,
		/obj/item/reagent_containers/cup/glass/sillycup = 3,
		/obj/item/broken_bottle = 3,
		/obj/item/reagent_containers/cup/soda_cans/grey_bull = 1,
		/obj/effect/spawner/random/engineering/tool = 1,
		/mob/living/basic/mouse = 1,
		/obj/item/food/grown/cannabis = 1,
		/obj/item/reagent_containers/cup/rag = 1,
		/obj/effect/spawner/random/entertainment/drugs= 1,
		/obj/item/modular_computer/pda = 1,
		/obj/item/reagent_containers/syringe = 1,
		/obj/effect/spawner/random/entertainment/cigar = 1,
		/obj/item/stack/ore/gold = 1,
	)
/obj/effect/spawner/random/trash/deluxe_garbage/Initialize(mapload)
	if(mapload)
		var/turf/location = get_turf(loc)
		if(location.initial_gas_mix != OPENTURF_DEFAULT_ATMOS && location.initial_gas_mix != OPENTURF_DIRTY_ATMOS)
			loot -= /mob/living/basic/mouse
	return ..()

/obj/effect/spawner/random/trash/cigbutt
	name = "cigarette butt spawner"
	loot = list(
		/obj/item/cigbutt = 25,
		/obj/item/cigbutt/roach = 25,
		/obj/effect/decal/cleanable/ash = 25,
		/obj/item/cigbutt/cigarbutt = 15,
		/obj/item/food/candy_trash = 5,
		/obj/item/food/candy_trash/nicotine = 5,
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
		/obj/effect/spawner/random/trash/bacteria = 1,
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

/obj/effect/spawner/random/trash/grime/Initialize(mapload)
	if(mapload)
		var/turf/location = get_turf(loc)
		if(location.initial_gas_mix != OPENTURF_DEFAULT_ATMOS && location.initial_gas_mix != OPENTURF_DIRTY_ATMOS)
			loot -= /mob/living/basic/cockroach
	return ..()

/obj/effect/spawner/random/trash/moisture
	name = "water hazard spawner"
	icon_state = "caution"
	spawn_loot_count = 2
	spawn_scatter_radius = 1
	loot = list( // This spawner will scatter water related items around a moist site.
		/obj/item/clothing/head/cone = 7,
		/obj/item/clothing/suit/caution = 3,
		/mob/living/basic/frog = 2,
		/obj/item/reagent_containers/cup/rag = 2,
		/obj/item/reagent_containers/cup/bucket = 2,
		/obj/effect/decal/cleanable/blood/old = 2,
		/obj/structure/mop_bucket = 2,
		/mob/living/basic/axolotl = 1,
	)

/obj/effect/spawner/random/trash/moisture/Initialize(mapload)
	if(mapload)
		var/turf/location = get_turf(loc)
		if(location.initial_gas_mix != OPENTURF_DEFAULT_ATMOS && location.initial_gas_mix != OPENTURF_DIRTY_ATMOS)
			loot -= list(/mob/living/basic/frog, /mob/living/basic/axolotl)
	return ..()

/obj/effect/spawner/random/trash/graffiti
	name = "random graffiti spawner"
	icon_state = "rune"
	loot = list(/obj/effect/decal/cleanable/crayon)
	var/graffiti_icons = list(
		"rune1", "rune2", "rune3", "rune4", "rune5", "rune6",
		"amyjon", "face", "matt", "revolution", "engie", "guy",
		"end", "dwarf", "uboa", "body", "cyka", "star",
		"prolizard", "antilizard", "danger", "firedanger", "electricdanger",
		"biohazard", "radiation", "safe", "evac", "space", "med", "trade", "shop",
		"food", "peace", "like", "skull", "nay", "heart", "credit",
		"smallbrush", "brush", "largebrush", "splatter", "snake", "stickman",
		"carp", "ghost", "clown", "taser", "disk", "fireaxe", "toolbox",
		"corgi", "cat", "toilet", "blueprint", "beepsky", "scroll", "bottle",
		"shotgun", "arrow", "line", "thinline", "shortline", "body", "chevron",
		"footprint", "clawprint", "pawprint",
	)
	// This sets the color of the graffiti (used for mapedits)
	color = COLOR_WHITE
	/// Whether the graffiti will spawn with a random color (used for mapedits)
	var/random_color = TRUE
	/// Whether the graffiti will spawn with this spawner's icon_state instead of a random one (used for mapedits)
	var/random_icon = TRUE

/obj/effect/spawner/random/trash/graffiti/make_item(spawn_loc, type_path_to_make)
	var/obj/effect/decal/cleanable/crayon/graffiti_decal = ..()
	if(istype(graffiti_decal))
		color = random_color && "#[random_short_color()]" || color
		icon_state = random_icon && pick(graffiti_icons) || icon_state

		graffiti_decal.add_atom_colour(color, FIXED_COLOUR_PRIORITY)
		graffiti_decal.icon_state = icon_state

	return graffiti_decal

/obj/effect/spawner/random/trash/mopbucket
	name = "mop bucket spawner"
	icon_state = "mopbucket"
	spawn_loot_count = 2
	spawn_loot_double = FALSE
	loot = list(
		/obj/structure/mop_bucket = 10,
		/obj/item/mop = 5,
		/obj/item/clothing/suit/caution = 3,
		/obj/item/reagent_containers/cup/bucket = 1,
		/obj/item/reagent_containers/cup/bucket/wooden = 1,
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
		/obj/item/reagent_containers/cup/bucket,
		/obj/item/reagent_containers/cup/bucket/wooden,
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

/obj/effect/spawner/random/trash/bacteria
	name = "moldy food spawner"
	loot = list(
		/obj/item/food/breadslice/moldy/bacteria,
		/obj/item/food/pizzaslice/moldy/bacteria,
	)

/obj/effect/spawner/random/trash/crushed_can
	name = "crushed can spawner"
	icon_state = "crushed_can"
	loot = list(/obj/item/trash/can)
	/// Whether the can will spawn with this spawner's icon_state instead of a random one (used for mapedits)
	var/soda_icons = list(
		"energy_drink", "monkey_energy", "thirteen_loko", "space_mountain_wind", "dr_gibb", "starkist",
		"sodawater", "tonic", "cola", "purple_can", "ice_tea_can",
		"sol_dry", "wellcheers", "space beer", "ebisu", "shimauma", "moonlabor",
		"space_up", "lemon_lime", "shamblers", "shamblerseldritch", "air", "laughter",
		"volt_energy", "melon_soda",
	)

/obj/effect/spawner/random/trash/crushed_can/make_item(spawn_loc, type_path_to_make)
	var/obj/item/trash/can/crushed_can = .. ()
	if(istype(crushed_can))
		crushed_can.icon_state = pick(soda_icons)
	return crushed_can

/obj/effect/spawner/random/trash/ghetto_containers
	name = "ghetto container spawner"
	loot = list(
		/obj/item/reagent_containers/cup/bucket = 5,
		/obj/item/reagent_containers/cup/glass/bottle = 5,
		/obj/item/reagent_containers/cup/glass/bottle/small = 5,
		/obj/item/reagent_containers/cup/glass/mug = 5,
		/obj/item/reagent_containers/cup/glass/shaker = 5,
		/obj/item/reagent_containers/cup/watering_can/wood = 5,
		/obj/item/reagent_containers/cup/mortar = 2,
		/obj/item/reagent_containers/cup/soup_pot = 2,
		/obj/item/reagent_containers/cup/blastoff_ampoule = 1,
		/obj/item/reagent_containers/cup/maunamug = 1,
	)
