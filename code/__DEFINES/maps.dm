/*
The /tg/ codebase allows mixing of hardcoded and dynamically-loaded Z-levels.
Z-levels can be reordered as desired and their properties are set by "traits".
See code/datums/map_config.dm for how a particular station's traits may be chosen.
The list DEFAULT_MAP_TRAITS at the bottom of this file should correspond to
the maps that are hardcoded, as set in _maps/_basemap.dm. SSmapping is
responsible for loading every non-hardcoded Z-level.

As of April 26th, 2022, the typical Z-levels for a single-level station are:
1: CentCom
2: Station
3-4: Randomized Space (Ruins)
5: Mining
6-11: Randomized Space (Ruins)
12: Transit/Reserved Space

However, if away missions are enabled:
12: Away Mission
13: Transit/Reserved Space

Multi-Z stations are supported and Multi-Z mining and away missions would
require only minor tweaks. They also handle their Z-Levels differently on their
own case by case basis.

This information will absolutely date quickly with how we handle Z-Levels, and will
continue to handle them in the future. Currently, you can go into the Debug tab
of your stat-panel (in game) and hit "Mapping verbs - Enable". You will then get a new tab
called "Mapping", as well as access to the verb "Debug-Z-Levels". Although the information
presented in this comment is factual for the time it was written for, it's ill-advised
to trust the words presented within.

We also provide this information to you so that you can have an at-a-glance look at how
Z-Levels are arranged. It is extremely ill-advised to ever use the location of a Z-Level
to assign traits to it or use it in coding. Use Z-Traits (ZTRAITs) for these.

If you want to start toying around with Z-Levels, do not take these words for fact.
Always compile, always use that verb, and always make sure that it works for what you want to do.
*/

// helpers for modifying jobs, used in various job_changes.dm files

#define MAP_CURRENT_VERSION 1

#define SPACERUIN_MAP_EDGE_PAD 15

/// Distance from edge to move to another z-level
#define TRANSITIONEDGE 7

// Maploader bounds indices
/// The maploader index for the maps minimum x
#define MAP_MINX 1
/// The maploader index for the maps minimum y
#define MAP_MINY 2
/// The maploader index for the maps minimum z
#define MAP_MINZ 3
/// The maploader index for the maps maximum x
#define MAP_MAXX 4
/// The maploader index for the maps maximum y
#define MAP_MAXY 5
/// The maploader index for the maps maximum z
#define MAP_MAXZ 6

/// Path for the next_map.json file, if someone, for some messed up reason, wants to change it.
#define PATH_TO_NEXT_MAP_JSON "data/next_map.json"

/// List of directories we can load map .json files from
#define MAP_DIRECTORY_MAPS "_maps"
#define MAP_DIRECTORY_DATA "data"
#define MAP_DIRECTORY_WHITELIST list(MAP_DIRECTORY_MAPS,MAP_DIRECTORY_DATA)

/// Special map path value for custom adminloaded stations.
#define CUSTOM_MAP_PATH "custom"

// traits
// boolean - marks a level as having that property if present
#define ZTRAIT_CENTCOM "CentCom"
#define ZTRAIT_STATION "Station"
#define ZTRAIT_MINING "Mining"
#define ZTRAIT_RESERVED "Transit/Reserved"
#define ZTRAIT_AWAY "Away Mission"
#define ZTRAIT_SPACE_RUINS "Space Ruins"
#define ZTRAIT_LAVA_RUINS "Lava Ruins"
#define ZTRAIT_ICE_RUINS "Ice Ruins"
#define ZTRAIT_ICE_RUINS_UNDERGROUND "Ice Ruins Underground"
#define ZTRAIT_ISOLATED_RUINS "Isolated Ruins" //Placing ruins on z levels with this trait will use turf reservation instead of usual placement.

// boolean - weather types that occur on the level
#define ZTRAIT_SNOWSTORM "Weather_Snowstorm"
#define ZTRAIT_ASHSTORM "Weather_Ashstorm"
#define ZTRAIT_VOIDSTORM "Weather_Voidstorm"
#define ZTRAIT_RAINSTORM "Weather_Rainstorm"
#define ZTRAIT_SANDSTORM "Weather_Sandstorm"

/// boolean - does this z prevent ghosts from observing it
#define ZTRAIT_SECRET "Secret"

/// boolean - does this z prevent phasing
#define ZTRAIT_NOPHASE "No Phase"

/// boolean - does this z prevent xray/meson/thermal vision
#define ZTRAIT_NOXRAY "No X-Ray"

// number - bombcap is multiplied by this before being applied to bombs
#define ZTRAIT_BOMBCAP_MULTIPLIER "Bombcap Multiplier"

// number - default gravity if there's no gravity generators or area overrides present
#define ZTRAIT_GRAVITY "Gravity"

// Whether this z level is linked up/down. Bool.
#define ZTRAIT_UP "Up"
#define ZTRAIT_DOWN "Down"

// enum - how space transitions should affect this level
#define ZTRAIT_LINKAGE "Linkage"
	// UNAFFECTED if absent - no space transitions
	#define UNAFFECTED null
	// SELFLOOPING - space transitions always self-loop
	#define SELFLOOPING "Self"
	// CROSSLINKED - mixed in with the cross-linked space pool
	#define CROSSLINKED "Cross"

// string - type path of the z-level's baseturf (defaults to space)
#define ZTRAIT_BASETURF "Baseturf"

///boolean - does this z disable parallax?
#define ZTRAIT_NOPARALLAX "No Parallax"

// default trait definitions, used by SSmapping
///Z level traits for CentCom
#define ZTRAITS_CENTCOM list(ZTRAIT_CENTCOM = TRUE, ZTRAIT_NOPHASE = TRUE)
///Z level traits for Space Station 13
#define ZTRAITS_STATION list(ZTRAIT_LINKAGE = CROSSLINKED, ZTRAIT_STATION = TRUE)
///Z level traits for Deep Space
#define ZTRAITS_SPACE list(ZTRAIT_LINKAGE = CROSSLINKED, ZTRAIT_SPACE_RUINS = TRUE)
///Z level traits for Lavaland
#define ZTRAITS_LAVALAND list(\
	ZTRAIT_MINING = TRUE, \
	ZTRAIT_NOPARALLAX = TRUE, \
	ZTRAIT_ASHSTORM = TRUE, \
	ZTRAIT_LAVA_RUINS = TRUE, \
	ZTRAIT_BOMBCAP_MULTIPLIER = 2, \
	ZTRAIT_BASETURF = /turf/open/lava/smooth/lava_land_surface)
///Z level traits for Away Missions
#define ZTRAITS_AWAY list(ZTRAIT_AWAY = TRUE)
///Z level traits for Secret Away Missions
#define ZTRAITS_AWAY_SECRET list(ZTRAIT_AWAY = TRUE, ZTRAIT_SECRET = TRUE, ZTRAIT_NOPHASE = TRUE)

#define DL_NAME "name"
#define DL_TRAITS "traits"
#define DECLARE_LEVEL(NAME, TRAITS) list(DL_NAME = NAME, DL_TRAITS = TRAITS)

// must correspond to _basemap.dm for things to work correctly
#define DEFAULT_MAP_TRAITS list(\
	DECLARE_LEVEL("CentCom", ZTRAITS_CENTCOM),\
)

// Camera lock flags
#define CAMERA_LOCK_STATION 1
#define CAMERA_LOCK_MINING 2
#define CAMERA_LOCK_CENTCOM 4

//Reserved/Transit turf type
#define RESERVED_TURF_TYPE /turf/open/space/basic //What the turf is when not being used

//Ruin Generation
#define PLACEMENT_TRIES 100 //How many times we try to fit the ruin somewhere until giving up (really should just swap to some packing algo)

#define PLACE_DEFAULT "random"
#define PLACE_SAME_Z "same" //On same z level as original ruin
#define PLACE_SPACE_RUIN "space" //On space ruin z level(s)
#define PLACE_LAVA_RUIN "lavaland" //On lavaland ruin z levels(s)
#define PLACE_BELOW "below" //On z levl below - centered on same tile
#define PLACE_ISOLATED "isolated" //On isolated ruin z level

///Map generation defines
#define DEFAULT_SPACE_RUIN_LEVELS 7
#define DEFAULT_SPACE_EMPTY_LEVELS 1

#define BIOME_LOW_HEAT "low_heat"
#define BIOME_LOWMEDIUM_HEAT "lowmedium_heat"
#define BIOME_MEDIUM_HEAT "medium_heat"
#define BIOME_HIGHMEDIUM_HEAT "highmedium_heat"
#define BIOME_HIGH_HEAT "high_heat"

#define BIOME_LOW_HUMIDITY "low_humidity"
#define BIOME_LOWMEDIUM_HUMIDITY "lowmedium_humidity"
#define BIOME_MEDIUM_HUMIDITY "medium_humidity"
#define BIOME_HIGHMEDIUM_HUMIDITY "highmedium_humidity"
#define BIOME_HIGH_HUMIDITY "high_humidity"

// Bluespace shelter deploy checks for survival capsules
/// Shelter spot is allowed
#define SHELTER_DEPLOY_ALLOWED "allowed"
/// Shelter spot has turfs that restrict deployment
#define SHELTER_DEPLOY_BAD_TURFS "bad turfs"
/// Shelter spot has areas that restrict deployment
#define SHELTER_DEPLOY_BAD_AREA "bad area"
/// Shelter spot has anchored objects that restrict deployment
#define SHELTER_DEPLOY_ANCHORED_OBJECTS "anchored objects"
/// Sheter spot has banned objects that restrict deployment
#define SHELTER_DEPLOY_BANNED_OBJECTS "banned objects"
/// Shelter spot is out of bounds from the maps x/y coordinates
#define SHELTER_DEPLOY_OUTSIDE_MAP "outside map"

//Flags for survival capsules to ignore some deploy checks
///Ignore anchored, dense objects in the area
#define CAPSULE_IGNORE_ANCHORED_OBJECTS (1<<0)
///Ignore banned objects in the area
#define CAPSULE_IGNORE_BANNED_OBJECTS (1<<1)

/// A map key that corresponds to being one exclusively for Space.
#define SPACE_KEY "space"

//clusterCheckFlags defines
//All based on clusterMin and clusterMax as guides

//Individual defines
#define CLUSTER_CHECK_NONE 0 //!No checks are done, cluster as much as possible
#define CLUSTER_CHECK_DIFFERENT_TURFS (1<<1)  //!Don't let turfs of DIFFERENT types cluster
#define CLUSTER_CHECK_DIFFERENT_ATOMS (1<<2)  //!Don't let atoms of DIFFERENT types cluster
#define CLUSTER_CHECK_SAME_TURFS (1<<3)  //!Don't let turfs of the SAME type cluster
#define CLUSTER_CHECK_SAME_ATOMS (1<<4) //!Don't let atoms of the SAME type cluster

//Combined defines
#define CLUSTER_CHECK_SAMES 24 //!Don't let any of the same type cluster
#define CLUSTER_CHECK_DIFFERENTS 6  //!Don't let any of different types cluster
#define CLUSTER_CHECK_ALL_TURFS 10 //!Don't let ANY turfs cluster same and different types
#define CLUSTER_CHECK_ALL_ATOMS 20 //!Don't let ANY atoms cluster same and different types

//All
#define CLUSTER_CHECK_ALL 30 //!Don't let anything cluster, like, at all

/// Checks the job changes in the map config for the passed change key.
#define CHECK_MAP_JOB_CHANGE(job, change) SSmapping.current_map.job_changes?[job]?[change]

///Identifiers for away mission spawnpoints
#define AWAYSTART_BEACH "AWAYSTART_BEACH"
#define AWAYSTART_MUSEUM "AWAYSTART_MUSEUM"
#define AWAYSTART_RESEARCH "AWAYSTART_RESEARCH"
#define AWAYSTART_CAVES "AWAYSTART_CAVES"
#define AWAYSTART_MOONOUTPOST "AWAYSTART_MOONOUTPOST"
#define AWAYSTART_SNOWCABIN "AWAYSTART_SNOWCABIN"
#define AWAYSTART_SNOWDIN "AWAYSTART_SNOWDIN"
#define AWAYSTART_UNDERGROUND "AWAYSTART_UNDERGROUND"

// Minetypes for maps
#define MINETYPE_NONE "none"
#define MINETYPE_LAVALAND "lavaland"
#define MINETYPE_ICE "ice"
