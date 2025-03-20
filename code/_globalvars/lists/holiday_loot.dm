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
	/obj/item/stock_parts/power_store/cell,
	/obj/item/stock_parts/power_store/cell/upgraded,
	// Custom
	/obj/item/cube/random,
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
	/obj/item/cube/random/uncommon,
	/obj/item/cube/colorful,
	/obj/item/cube/colorful/plane,
	/obj/item/cube/colorful/isometric,
	/obj/item/reagent_containers/pill/cube/ice,
	/obj/item/reagent_containers/pill/cube/sugar,
	/obj/item/reagent_containers/pill/cube/salt,
)))

/// List of Rare Cubes
GLOBAL_LIST_INIT(rare_cubes, typecacheof(list(
	// Vanilla
	/obj/item/food/monkeycube/gorilla,
	/obj/item/warp_cube,
	// Custom
	/obj/item/cube/random/rare,
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
	/obj/item/cube/random/epic,
	/obj/item/cube/colorful/pixel,
	/obj/item/cube/reference/puzzle,
	/obj/item/cube/colorful/meta,
	// Oxygen cube, generates oxygen
	//Holocrons (Star Wars)
	//Energon Cubes (Transformers)
	//Nitrous boxes (Crash bandicoot)
), only_root_path = TRUE))

/// List of Legendary Cubes
GLOBAL_LIST_INIT(legendary_cubes, typecacheof(list(
	// Vanilla
	/obj/item/blackbox,
	// Custom
	/obj/item/cube/random/legendary,
	/obj/item/cube/sphere,
	//Spessman cube (skin cube)
	//Dehydration cube(megamind)
	//Tesseract(marvel)
	//Pain Box(Dune)
)))

/// List of Mythical Cubes
GLOBAL_LIST_INIT(mythical_cubes, typecacheof(list(
	/obj/item/cube/random/mythical,
	/obj/item/cube/reference/craft,
	/obj/item/cube/reference/generic,
	//Blender default cube (maybe with gizmo)
	//Spessman cube (ancient spessman)
	//Companion cube
	//Time Cube
	//Escafil Device (Animorphs)
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
