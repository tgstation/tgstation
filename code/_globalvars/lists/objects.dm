/// List of all cables, so that powernets don't have to look through the entire world all the time
GLOBAL_LIST_EMPTY(cable_list)

/// List of all portals
GLOBAL_LIST_EMPTY(portals)

/// List of all curtains for button tracking
GLOBAL_LIST_EMPTY(curtains)

/// List of all mechs for hostile mob target tracking
GLOBAL_LIST_EMPTY(mechas_list)

/// List of all atoms that can call the shuttle, for automatic shuttle calls when there are none.
GLOBAL_LIST_EMPTY(shuttle_caller_list)

/// List of all nukie shuttle boards, for forcing launch delay if they declare war
GLOBAL_LIST_EMPTY(syndicate_shuttle_boards)

/// List of all nav beacons indexed by stringified z level
GLOBAL_LIST_EMPTY(navbeacons)

/// List of all active teleport beacons
GLOBAL_LIST_EMPTY(teleportbeacons)

/// List of all active delivery beacons
GLOBAL_LIST_EMPTY(deliverybeacons)

/// List of all active delivery beacon locations
GLOBAL_LIST_EMPTY(deliverybeacontags)

/// List of all singularity components that exist
GLOBAL_LIST_EMPTY_TYPED(singularities, /datum/component/singularity)

GLOBAL_LIST_EMPTY(item_to_design_list)

/// list of all surgeries by name, associated with their path.
GLOBAL_LIST_INIT(surgeries_list, init_surgeries())

/// list of all surgery steps, associated by their path.
GLOBAL_LIST_INIT(surgery_steps, init_subtypes_w_path_keys(/datum/surgery_step, list()))

/// Global list of all non-cooking related crafting recipes.
GLOBAL_LIST_EMPTY(crafting_recipes)
/// This is a global list of typepaths, these typepaths are atoms or reagents that are associated with crafting recipes.
/// This includes stuff like recipe components and results.
GLOBAL_LIST_EMPTY(crafting_recipes_atoms)
/// Global list of all cooking related crafting recipes.
GLOBAL_LIST_EMPTY(cooking_recipes)
/// This is a global list of typepaths, these typepaths are atoms or reagents that are associated with cooking recipes.
/// This includes stuff like recipe components and results.
GLOBAL_LIST_EMPTY(cooking_recipes_atoms)
/// list of Rapid Construction Devices.
GLOBAL_LIST_EMPTY(rcd_list)
/// list of wallmounted intercom radios.
GLOBAL_LIST_EMPTY(intercoms_list)
/// list of all pinpointers. Used to change stuff they are pointing to all at once.
GLOBAL_LIST_EMPTY(pinpointer_list)
/// A list of all zombie_infection organs, for any mass "animation"
GLOBAL_LIST_EMPTY(zombie_infection_list)
/// List of all meteors.
GLOBAL_LIST_EMPTY(meteor_list)
/// List of active radio jammers
GLOBAL_LIST_EMPTY(active_jammers)
GLOBAL_LIST_EMPTY(ladders)
GLOBAL_LIST_EMPTY(stairs)
GLOBAL_LIST_EMPTY(janitor_devices)
GLOBAL_LIST_EMPTY(trophy_cases)
GLOBAL_LIST_EMPTY(experiment_handlers)

///This is a global list of all signs you can change an existing sign or new sign backing to, when using a pen on them.
GLOBAL_LIST_INIT(editable_sign_types, populate_editable_sign_types())

GLOBAL_LIST_EMPTY(wire_color_directory)
GLOBAL_LIST_EMPTY(wire_name_directory)

/// List of all instances of /obj/effect/mob_spawn/ghost_role in the game world
GLOBAL_LIST_EMPTY(mob_spawners)

/// List of all mobs with the "ghost_direct_control" component
GLOBAL_LIST_EMPTY(joinable_mobs)

/// List of area names of roundstart station cyborg rechargers, for the low charge/no charge cyborg screen alert tooltips.
GLOBAL_LIST_EMPTY(roundstart_station_borgcharger_areas)

/// List of area names of roundstart station mech rechargers, for the low charge/no charge mech screen alert tooltips.
GLOBAL_LIST_EMPTY(roundstart_station_mechcharger_areas)

// List of organ typepaths that are not unit test-able, and shouldn't be spawned by some things, such as certain class prototypes.
GLOBAL_LIST_INIT(prototype_organs, typecacheof(list(
	/obj/item/organ,
	/obj/item/organ/wings,
	/obj/item/organ/wings/functional,
	/obj/item/organ/wings/functional/moth,
	/obj/item/organ/cyberimp,
	/obj/item/organ/cyberimp/brain,
	/obj/item/organ/cyberimp/mouth,
	/obj/item/organ/cyberimp/arm,
	/obj/item/organ/cyberimp/chest,
	/obj/item/organ/cyberimp/eyes,
	/obj/item/organ/alien,
	/obj/item/organ/brain/dullahan,
	/obj/item/organ/ears/dullahan,
	/obj/item/organ/tongue/dullahan,
	/obj/item/organ/eyes/dullahan,
), only_root_path = TRUE))

/// List of Common Cubes
/// I could have made these not only_root_path but I realized that would include EVERY box.
GLOBAL_LIST_INIT(common_cubes, typecacheof(list(
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
), only_root_path = TRUE))

/// List of Uncommon Cubes
GLOBAL_LIST_INIT(uncommon_cubes, typecacheof(list(
	/obj/item/bounty_cube,
	/obj/item/food/monkeycube/chicken,
	/obj/item/food/monkeycube/bee,
	/obj/item/crusher_trophy/ice_demon_cube,
	/obj/item/barriercube,
	/obj/item/mmi/posibrain,
)))

/// List of Rare Cubes
GLOBAL_LIST_INIT(rare_cubes, typecacheof(list(
	/obj/item/food/monkeycube/gorilla,
	/obj/item/warp_cube,
)))

/// List of Epic Cubes
GLOBAL_LIST_INIT(epic_cubes, typecacheof(list(
	/obj/item/freeze_cube,
	/obj/item/prisoncube,
)))

/// List of Legendary Cubes
GLOBAL_LIST_INIT(legendary_cubes, typecacheof(list(
	/obj/item/blackbox,
)))

/// List of Mythical Cubes
GLOBAL_LIST_INIT(mythical_cubes, typecacheof(list(
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
