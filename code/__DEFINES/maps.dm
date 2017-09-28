/*
The /tg/ codebase currently requires you to have 11 z-levels of the same size dimensions.
z-level order is important, the order you put them in inside the map config.dm will determine what z level number they are assigned ingame.
Names of z-level do not matter, but order does greatly, for instances such as checking alive status of revheads on z1

current as of 2016/6/2
z1 = station
z2 = centcom
z5 = mining
Everything else = randomized space
Last space-z level = empty
*/

#define CROSSLINKED 2
#define SELFLOOPING 1
#define UNAFFECTED 0

#define MAIN_STATION "Main Station"
#define CENTCOM "CentCom"
#define EMPTY_AREA_1 "Empty Area 1"
#define EMPTY_AREA_2 "Empty Area 2"
#define MINING "Mining Asteroid"
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
#define ZLEVEL_CENTCOM 1
#define ZLEVEL_STATION_PRIMARY 2
#define ZLEVEL_MINING 5
#define ZLEVEL_LAVALAND 5
#define ZLEVEL_EMPTY_SPACE 12
#define ZLEVEL_TRANSIT 11

#define ZLEVEL_SPACEMIN 3
#define ZLEVEL_SPACEMAX 12

#define SPACERUIN_MAP_EDGE_PAD 15