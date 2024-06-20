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

/// Associative list of alcoholic container typepath to instances, currently used by the alcoholic quirk
GLOBAL_LIST_INIT(alcohol_containers, init_alcohol_containers())
