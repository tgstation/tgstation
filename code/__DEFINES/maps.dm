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

#define CROSSLINKED 2
#define SELFLOOPING 1
#define UNAFFECTED 0

#define MAIN_STATION "Main Station"
#define CENTCOM "CentCom"
#define CITY_OF_COGS "City of Cogs"
#define EMPTY_AREA_1 "Empty Area 1"
#define EMPTY_AREA_2 "Empty Area 2"
#define MINING_ASTEROID "Mining Asteroid"
#define EMPTY_AREA_3 "Empty Area 3"
#define EMPTY_AREA_4 "Empty Area 4"
#define EMPTY_AREA_5 "Empty Area 5"
#define EMPTY_AREA_6 "Empty Area 6"
#define EMPTY_AREA_7 "Empty Area 7"
#define EMPTY_AREA_8 "Empty Area 8"
#define AWAY_MISSION "Away Mission"

//for modifying jobs
#define MAP_JOB_CHECK if(SSmapping.config.map_name != JOB_MODIFICATION_MAP_NAME) { return; }
#define MAP_JOB_CHECK_BASE if(SSmapping.config.map_name != JOB_MODIFICATION_MAP_NAME) { return ..(); }
#define MAP_REMOVE_JOB(jobpath) /datum/job/##jobpath/map_check() { return (SSmapping.config.map_name != JOB_MODIFICATION_MAP_NAME) && ..() }

//zlevel defines, can be overridden for different maps in the appropriate _maps file.
#define ZLEVEL_STATION_PRIMARY 2
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

// trait definitions
#define DL_NAME "name"
#define DL_LINKAGE "linkage"
#define DL_TRAITS "traits"

#define DECLARE_LEVEL(NAME, LINKAGE, TRAITS) list(DL_NAME = NAME, DL_LINKAGE = LINKAGE, DL_TRAITS = TRAITS)
// corresponds to basemap.dm
#define DEFAULT_MAP_TRAITS list(\
    DECLARE_LEVEL("CentCom", SELFLOOPING, list(ZTRAIT_CENTCOM = TRUE)),\
    DECLARE_LEVEL("Main Station", CROSSLINKED, list(ZTRAIT_STATION = TRUE)),\
    DECLARE_LEVEL("Empty Area 1", CROSSLINKED, list(ZTRAIT_SPACE_RUINS = TRUE)),\
    DECLARE_LEVEL("Empty Area 2", CROSSLINKED, list(ZTRAIT_SPACE_RUINS = TRUE)),\
    DECLARE_LEVEL("Lavaland", UNAFFECTED, list(ZTRAIT_MINING = TRUE, ZTRAIT_LAVA_RUINS = TRUE, ZTRAIT_BOMBCAP_MULTIPLIER = 3)),\
    DECLARE_LEVEL("Reebe", UNAFFECTED, list(ZTRAIT_REEBE = TRUE, ZTRAIT_BOMBCAP_MULTIPLIER = 0.5)),\
)

//Camera lock flags
#define CAMERA_LOCK_STATION 1
#define CAMERA_LOCK_MINING 2
#define CAMERA_LOCK_CENTCOM 4
#define CAMERA_LOCK_REEBE 8
