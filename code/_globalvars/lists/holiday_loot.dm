//* APRIL FOOLS

/// List of Common Cubes
/// I could have made only_root_path = FALSE but I realized that would include EVERY box.
GLOBAL_LIST_INIT(common_cubes, typecacheof(list(
	// Vanilla
	/obj/item/dice/d6,
	/obj/item/dice/d6/ebony,
	/obj/item/dice/d6/space,
	/obj/item/food/monkeycube,
	/obj/item/storage/box,
	/obj/item/storage/box/gloves,
	/obj/item/storage/box/masks,
	/obj/item/storage/box/shipping,
	/obj/item/storage/box/donkpockets,
	/obj/item/storage/box/ingredients/wildcard,
	/obj/item/storage/box/zipties,
	// Custom
	/obj/item/cube/random = 3,
), only_root_path = TRUE))

/// List of Uncommon Cubes
GLOBAL_LIST_INIT(uncommon_cubes, typecacheof(list(
	// Vanilla
	/obj/item/bounty_cube,
	/obj/item/food/monkeycube/chicken,
	/obj/item/food/monkeycube/bee,
	/obj/item/crusher_trophy/ice_demon_cube,
	/obj/item/barriercube,
	/obj/item/mmi/posibrain,
	// Custom
	/obj/item/cube/random/uncommon = 3,
	/obj/item/cube/colorful,
	/obj/item/cube/colorful/plane,
	/obj/item/cube/colorful/isometric,
	/obj/item/reagent_containers/applicator/pill/cube/ice,
	/obj/item/reagent_containers/applicator/pill/cube/sugar,
	/obj/item/reagent_containers/applicator/pill/cube/salt,
)))

/// List of Rare Cubes
GLOBAL_LIST_INIT(rare_cubes, typecacheof(list(
	// Vanilla
	/obj/item/food/monkeycube/gorilla,
	/obj/item/warp_cube,
	// Custom
	/obj/item/cube/random/rare = 3,
	/obj/item/cube/colorful/huge,
	/obj/item/cube/colorful/voxel,
	/obj/item/cube/reference/puzzle/rubiks,
	/obj/item/cube/material,
)))

/// List of Epic Cubes
GLOBAL_LIST_INIT(epic_cubes, typecacheof(list(
	// Vanilla
	/obj/item/freeze_cube,
	/obj/item/prisoncube,
	// Custom
	/obj/item/cube/random/epic = 3,
	/obj/item/cube/colorful/pixel,
	/obj/item/cube/reference/puzzle,
	/obj/item/cube/colorful/meta,
	// t5 parts?
	// Oxygen cube, generates oxygen
	//Holocrons (Star Wars) Probably just a tech disk
	//Energon Cubes (Transformers) t5 battery?
	//Nitrous boxes (Crash bandicoot) grenade
), only_root_path = TRUE))

/// List of Legendary Cubes
GLOBAL_LIST_INIT(legendary_cubes, typecacheof(list(
	// Vanilla
	/obj/item/blackbox,
	// Custom
	/obj/item/cube/random/legendary = 3,
	/obj/item/cube/colorful/sphere,
	//Spessman cube (skin cube) monkey cube but human
	//Dehydration cube(megamind) monkey cube but random!
	//Tesseract(marvel) t6 battery fuck it
	//Pain Box(Dune) maxes out your pain
)))

/// List of Mythical Cubes
GLOBAL_LIST_INIT(mythical_cubes, typecacheof(list(
	/obj/item/cube/random/mythical = 3,
	/obj/item/cube/reference/craft,
	/obj/item/cube/reference/generic,
	//Blender default cube (maybe with gizmo)
	//Spessman cube (ancient spessman)
	//Companion cube (portal) mood buff & crushing weight
	//Time Cube (time cube) wizard time-stop spell w/ longer cooldown
	//Escafil Device (Animorphs) morph belt/spell w/ cooldown
	//Question mark block(Basically a reskinned christmas gift)
)))


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
