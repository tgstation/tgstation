//* APRIL FOOLS

/// Random cubes have 30 weight, other cubes have 25 weight
/// Each list also has a chance to give 3 lower rarity cubes (5 weight) or give 1 cube of even higher rarity (1 weight)
/// List of Common Cubes
GLOBAL_LIST_INIT(common_cubes, list(
	// Vanilla
	/obj/item/dice/d6 = 25,
	/obj/item/dice/d6/ebony = 25,
	/obj/item/dice/d6/space = 25,
	/obj/item/food/monkeycube = 25,
	/obj/item/storage/box = 25,
	/obj/item/storage/box/gloves = 25,
	/obj/item/storage/box/masks = 25,
	/obj/item/storage/box/shipping = 25,
	/obj/item/storage/box/donkpockets = 25,
	/obj/item/storage/box/ingredients/wildcard = 25,
	/obj/item/storage/box/zipties = 25,
	// Custom
	/obj/item/cube/random = 30,
	/obj/effect/spawner/random/cube/uncommon = 1,
))

/// List of Uncommon Cubes
GLOBAL_LIST_INIT(uncommon_cubes, list(
	// Vanilla
	/obj/item/bounty_cube = 25,
	/obj/item/food/monkeycube/chicken = 25,
	/obj/item/food/monkeycube/bee = 25,
	/obj/item/crusher_trophy/ice_demon_cube = 25,
	/obj/item/barriercube = 25,
	/obj/item/mmi/posibrain = 25,
	// Custom
	/obj/effect/spawner/random/cube/three = 5,
	/obj/effect/spawner/random/cube/rare = 1,
	/obj/item/cube/random/uncommon = 30,
	/obj/item/cube/colorful = 25,
	/obj/item/cube/colorful/plane = 25,
	/obj/item/cube/colorful/isometric = 25,
	/obj/item/reagent_containers/applicator/pill/cube/ice = 25,
	/obj/item/reagent_containers/applicator/pill/cube/sugar = 25,
	/obj/item/reagent_containers/applicator/pill/cube/salt = 25,
	/obj/item/reagent_containers/applicator/pill/cube/pepper = 25,
	/obj/item/reagent_containers/applicator/pill/cube/chili = 25,
	/obj/item/reagent_containers/applicator/pill/cube/chilly = 25,
	/obj/item/reagent_containers/applicator/pill/cube/random = 25,
))

/// List of Rare Cubes
GLOBAL_LIST_INIT(rare_cubes, list(
	// Vanilla
	/obj/item/food/monkeycube/gorilla = 25,
	/obj/item/warp_cube/red = 25,
	// Custom
	/obj/effect/spawner/random/cube/uncommon/three = 5,
	/obj/effect/spawner/random/cube/epic = 1,
	/obj/item/cube/random/rare = 30,
	/obj/item/cube/colorful/huge = 25,
	/obj/item/cube/colorful/voxel = 25,
	/obj/item/cube/colorful/meta = 25,
	/obj/item/cube/puzzle/rubiks = 25,
	/obj/item/cube/material = 25,
))

/// List of Epic Cubes
GLOBAL_LIST_INIT(epic_cubes, list(
	// Vanilla
	/obj/item/freeze_cube = 25,
	// Custom
	/obj/effect/spawner/random/cube/rare/three = 5,
	/obj/effect/spawner/random/cube/legendary = 1,
	/obj/item/cube/random/epic = 30,
	/obj/item/cube/colorful/pixel = 25,
	/obj/item/cube/puzzle = 25,
	/obj/item/skub/cube = 25,
	//Oxygen cube, generates oxygen
	//Nitrous boxes (Crash bandicoot) impact grenade
	/obj/item/food/monkeycube/spaceman = 25,
	))

/// List of Legendary Cubes
GLOBAL_LIST_INIT(legendary_cubes, list(
	// Vanilla
	/obj/item/blackbox = 25,
	/obj/item/prisoncube = 25,
	// Custom
	/obj/effect/spawner/random/cube/epic/three = 5,
	/obj/effect/spawner/random/cube/mythical = 1,
	/obj/item/cube/random/legendary = 30,
	/obj/item/cube/colorful/sphere = 25,
	/obj/item/stock_parts/capacitor/energon = 25,
	/obj/item/stock_parts/scanning_module/holocron = 25,
	/obj/item/stock_parts/servo/piston = 25,
	/obj/item/stock_parts/matter_bin/moving = 25,
	/obj/item/food/monkeycube/spessman = 25,
	/obj/item/stock_parts/micro_laser/charged_blaster = 25,
	//Pain Box(Dune) maxes out your pain, immediately fills you with a lot of determination
))

/// List of Mythical Cubes
GLOBAL_LIST_INIT(mythical_cubes, list(
	/obj/effect/spawner/random/cube/legendary/three = 5,
	/obj/item/cube/random/mythical = 30,
	/obj/item/cube/craft = 25,
	/obj/item/cube/generic = 25,
	//Dehydration cube(megamind) monkey cube but random! Take from gold slime pool.
	/obj/item/cube/blender = 25,
	//Companion cube (portal) mood buff & crushing weight
	//Time Cube (time cube) wizard time-stop spell w/ longer cooldown
	//Escafil Device (Animorphs) morph belt/spell w/ cooldown
	/obj/item/stock_parts/power_store/cell/tesseract = 25,
	/obj/item/gift/anything/questionmark = 25,
))


/// Loot pool used by the All Rarities cube spawner
/// Total 916 weight
GLOBAL_LIST_INIT(all_cubes, list(
	GLOB.common_cubes = 500, // ~54%
	GLOB.uncommon_cubes = 250, // ~27%
	GLOB.rare_cubes = 100, // ~10%
	GLOB.epic_cubes = 50, // ~5%
	GLOB.legendary_cubes = 15, // ~1.5%
	GLOB.mythical_cubes = 1, // ~0.1%
))

/// Names of the rarities w/ spans
GLOBAL_LIST_INIT(all_cubenames, list(
	span_bold("Common"),
	span_boldnicegreen("Uncommon"),
	span_boldnotice("Rare"),
	span_hierophant("Epic"),
	span_bolddanger("Legendary"),
	span_clown("Mythical")
))

/// The colors associated with each rarity
GLOBAL_LIST_INIT(all_cubecolors, list(
	COLOR_WHITE = "white",
	COLOR_VIBRANT_LIME = "green",
	COLOR_DARK_CYAN = "blue",
	COLOR_VIOLET = "purple",
	COLOR_RED = "red",
	COLOR_PINK = "pink",
))
