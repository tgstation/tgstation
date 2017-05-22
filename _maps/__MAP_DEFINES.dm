/*
The /tg/ codebase currently requires you to have 11 z-levels of the same size dimensions.
z-level order is important, the order you put them in inside the map config.dm will determine what z level number they are assigned ingame.
Names of z-level do not matter, but order does greatly, for instances such as checking alive status of revheads on z1

current as of 2016/6/2
z1 = station
z2 = centcomm
z5 = mining
Everything else = randomized space
Last space-z level = empty
*/

#define CROSSLINKED 2
#define SELFLOOPING 1
#define UNAFFECTED 0

#define MAIN_STATION "Main Station"
#define CENTCOMM "CentComm"
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
#define AWAY_MISSION_LIST list(AWAY_MISSION = SELFLOOPING)
#define DEFAULT_MAP_TRANSITION_CONFIG list(MAIN_STATION = CROSSLINKED, CENTCOMM = SELFLOOPING, EMPTY_AREA_1 = CROSSLINKED, EMPTY_AREA_2 = CROSSLINKED, MINING = SELFLOOPING, EMPTY_AREA_3 = CROSSLINKED, EMPTY_AREA_4 = CROSSLINKED, EMPTY_AREA_5 = CROSSLINKED, EMPTY_AREA_6 = CROSSLINKED, EMPTY_AREA_7 = CROSSLINKED, EMPTY_AREA_8 = CROSSLINKED)
