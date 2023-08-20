GLOBAL_LIST_INIT(cardinals, list(
	NORTH,
	SOUTH,
	EAST,
	WEST,
))
GLOBAL_LIST_INIT(cardinals_multiz, list(
	NORTH,
	SOUTH,
	EAST,
	WEST,
	UP,
	DOWN,
))
GLOBAL_LIST_INIT(diagonals, list(
	NORTHEAST,
	NORTHWEST,
	SOUTHEAST,
	SOUTHWEST,
))
GLOBAL_LIST_INIT(corners_multiz, list(
	UP|NORTHEAST,
	UP|NORTHWEST,
	UP|SOUTHEAST,
	UP|SOUTHWEST,
	DOWN|NORTHEAST,
	DOWN|NORTHWEST,
	DOWN|SOUTHEAST,
	DOWN|SOUTHWEST,
))
GLOBAL_LIST_INIT(diagonals_multiz, list(
	NORTHEAST,
	NORTHWEST,
	SOUTHEAST,
	SOUTHWEST,

	UP|NORTH,
	UP|SOUTH,
	UP|EAST,
	UP|WEST,
	UP|NORTHEAST,
	UP|NORTHWEST,
	UP|SOUTHEAST,
	UP|SOUTHWEST,

	DOWN|NORTH,
	DOWN|SOUTH,
	DOWN|EAST,
	DOWN|WEST,
	DOWN|NORTHEAST,
	DOWN|NORTHWEST,
	DOWN|SOUTHEAST,
	DOWN|SOUTHWEST,
))
GLOBAL_LIST_INIT(alldirs_multiz, list(
	NORTH,
	SOUTH,
	EAST,
	WEST,
	NORTHEAST,
	NORTHWEST,
	SOUTHEAST,
	SOUTHWEST,

	UP,
	UP|NORTH,
	UP|SOUTH,
	UP|EAST,
	UP|WEST,
	UP|NORTHEAST,
	UP|NORTHWEST,
	UP|SOUTHEAST,
	UP|SOUTHWEST,

	DOWN,
	DOWN|NORTH,
	DOWN|SOUTH,
	DOWN|EAST,
	DOWN|WEST,
	DOWN|NORTHEAST,
	DOWN|NORTHWEST,
	DOWN|SOUTHEAST,
	DOWN|SOUTHWEST,
))
GLOBAL_LIST_INIT(alldirs, list(
	NORTH,
	SOUTH,
	EAST,
	WEST,
	NORTHEAST,
	NORTHWEST,
	SOUTHEAST,
	SOUTHWEST,
))

/// list of all landmarks created
GLOBAL_LIST_EMPTY(landmarks_list)
/// list of all job spawn points created
GLOBAL_LIST_EMPTY(start_landmarks_list)
/// list of all department security spawns
GLOBAL_LIST_EMPTY(department_security_spawns)
/// List of generic landmarks placed around the map where there are likely to be players and are identifiable at a glance -
/// Such as public hallways, department rooms, head of staff offices, and non-generic maintenance locations
GLOBAL_LIST_EMPTY(generic_event_spawns)
/// Assoc list of "job titles" to "job landmarks"
/// These will take precedence over normal job spawnpoints if created,
/// essentially allowing a user to override generic job spawnpoints with a specific one
GLOBAL_LIST_EMPTY(jobspawn_overrides)

GLOBAL_LIST_EMPTY(wizardstart)
GLOBAL_LIST_EMPTY(nukeop_start)
GLOBAL_LIST_EMPTY(nukeop_leader_start)
GLOBAL_LIST_EMPTY(newplayer_start)
GLOBAL_LIST_EMPTY(prisonwarp) //admin prisoners go to these
GLOBAL_LIST_EMPTY(holdingfacility) //captured people go here (ninja energy net)
GLOBAL_LIST_EMPTY(generic_maintenance_landmarks)//generic spawn areas in maintenance, used for some ghostroles
GLOBAL_LIST_EMPTY(tdome1)
GLOBAL_LIST_EMPTY(tdome2)
GLOBAL_LIST_EMPTY(tdomeobserve)
GLOBAL_LIST_EMPTY(tdomeadmin)
GLOBAL_LIST_EMPTY(prisonwarped) //list of players already warped
GLOBAL_LIST_EMPTY(blobstart) //stationloving objects, blobs, santa
GLOBAL_LIST_EMPTY(navigate_destinations) //list of all destinations used by the navigate verb
GLOBAL_LIST_EMPTY(secequipment) //sec equipment lockers that scale with the number of sec players
GLOBAL_LIST_EMPTY(deathsquadspawn)
GLOBAL_LIST_EMPTY(emergencyresponseteamspawn)
GLOBAL_LIST_EMPTY(ruin_landmarks)
GLOBAL_LIST_EMPTY(bar_areas)

/// List of all the maps that have been cached for /proc/load_map
GLOBAL_LIST_EMPTY(cached_maps)

/// Away missions
GLOBAL_LIST_EMPTY(vr_spawnpoints)

/// Just a list of all the area objects in the game
/// Note, areas can have duplicate types
GLOBAL_LIST_EMPTY(areas)
/// Used by jump-to-area etc. Updated by area/updateName()
/// If this is null, it needs to be recalculated. Use get_sorted_areas() as a getter please
GLOBAL_LIST_EMPTY(sortedAreas)
/// An association from typepath to area instance. Only includes areas with `unique` set.
GLOBAL_LIST_EMPTY_TYPED(areas_by_type, /area)

GLOBAL_LIST_EMPTY(all_abstract_markers)

/// Global list of megafauna spawns on cave gen
GLOBAL_LIST_INIT(megafauna_spawn_list, list(
	/mob/living/simple_animal/hostile/megafauna/bubblegum = 6,
	/mob/living/simple_animal/hostile/megafauna/colossus = 2,
	/mob/living/simple_animal/hostile/megafauna/dragon = 4,
))
