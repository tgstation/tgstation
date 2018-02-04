/*
The /tg/ codebase currently requires you to have 11 z-levels of the same size dimensions.
z-level order is important, the order you put them in inside the map config.dm will determine what z level number they are assigned ingame.
Names of z-level do not matter, but order does greatly, for instances such as checking alive status of revheads on z1

current as of september 17, 2017
z1 = station
z2 = centcom
z5 = mining
z6 = city of cogs
Everything else = randomized space
Last space-z level = empty
*/

//for modifying jobs
#define MAP_JOB_CHECK if(SSmapping.config.map_name != JOB_MODIFICATION_MAP_NAME) { return; }
#define MAP_JOB_CHECK_BASE if(SSmapping.config.map_name != JOB_MODIFICATION_MAP_NAME) { return ..(); }
#define MAP_REMOVE_JOB(jobpath) /datum/job/##jobpath/map_check() { return (SSmapping.config.map_name != JOB_MODIFICATION_MAP_NAME) && ..() }

//zlevel defines, can be overridden for different maps in the appropriate _maps file.
#define ZLEVEL_EMPTY_SPACE 12

#define SPACERUIN_MAP_EDGE_PAD 15
#define ZLEVEL_SPACE_RUIN_COUNT 5

// traits
// boolean - marks a level as having that property if present
#define ZTRAIT_CENTCOM "CentCom"
#define ZTRAIT_STATION "Station"
#define ZTRAIT_MINING "Mining"
#define ZTRAIT_REEBE "Reebe"
#define ZTRAIT_TRANSIT "Transit"
#define ZTRAIT_AWAY "Away Mission"
#define ZTRAIT_SPACE_RUINS "Space Ruins"
#define ZTRAIT_LAVA_RUINS "Lava Ruins"

// number - bombcap is multiplied by this before being applied to bombs
#define ZTRAIT_BOMBCAP_MULTIPLIER "Bombcap Multiplier"

// numbers - offset values
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

// trait definitions, used by SSmapping
#define DL_NAME "name"
#define DL_TRAITS "traits"

#define ZTRAITS_CENTCOM list(ZTRAIT_LINKAGE = SELFLOOPING, ZTRAIT_CENTCOM = TRUE)
#define ZTRAITS_STATION list(ZTRAIT_LINKAGE = CROSSLINKED, ZTRAIT_STATION = TRUE)
#define ZTRAITS_SPACE list(ZTRAIT_LINKAGE = CROSSLINKED, ZTRAIT_SPACE_RUINS = TRUE)
#define ZTRAITS_LAVALAND list(ZTRAIT_MINING = TRUE, ZTRAIT_LAVA_RUINS = TRUE, ZTRAIT_BOMBCAP_MULTIPLIER = 3)
#define ZTRAITS_REEBE list(ZTRAIT_REEBE = TRUE, ZTRAIT_BOMBCAP_MULTIPLIER = 0.5)

#define DECLARE_LEVEL(NAME, TRAITS) list(DL_NAME = NAME, DL_TRAITS = TRAITS)
// corresponds to basemap.dm
#define DEFAULT_MAP_TRAITS list(\
    DECLARE_LEVEL("CentCom", ZTRAITS_CENTCOM),\
    DECLARE_LEVEL("Main Station", ZTRAITS_STATION),\
    DECLARE_LEVEL("Empty Area 1", ZTRAITS_SPACE),\
    DECLARE_LEVEL("Empty Area 2", ZTRAITS_SPACE),\
    DECLARE_LEVEL("Lavaland", ZTRAITS_LAVALAND),\
    DECLARE_LEVEL("Reebe", ZTRAITS_REEBE),\
)

//Camera lock flags
#define CAMERA_LOCK_STATION 1
#define CAMERA_LOCK_MINING 2
#define CAMERA_LOCK_CENTCOM 4
#define CAMERA_LOCK_REEBE 8
