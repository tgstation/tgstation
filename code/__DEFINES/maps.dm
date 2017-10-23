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
#define ZLEVEL_CITYOFCOGS 6
#define ZLEVEL_EMPTY_SPACE 12
//Unless you modify it in map config should be equal to ZLEVEL_SPACEMAX
#define ZLEVEL_RESERVED 13
#define ZLEVEL_TRANSIT 13		//Transit is currently as the reserve level.

#define ZLEVEL_SPACEMIN 3
#define ZLEVEL_SPACEMAX 13

#define SPACERUIN_MAP_EDGE_PAD 15

#define RESERVED_TURF_TYPE /turf/open/space

#define SET_RESERVATION_TURF(T){\
	var/turf/_turf_being_reserved = T;\
	_turf_being_reserved.empty(RESERVED_TURF_TYPE, RESERVED_TURF_TYPE, null, TRUE);\
	LAZYINITLIST(SSmapping.unused_turfs["[_turf_being_reserved.z]"]);\
	SSmapping.unused_turfs["[_turf_being_reserved.z]"] |= _turf_being_reserved;\
	_turf_being_reserved.flags_1 |= UNUSED_RESERVATION_TURF_1;}

#define RESERVE_TURF(T, reservation){\
	var/turf/_turf_to_be_busy = T;\
	var/datum/turf_reservation/_turf_reservation_recieving = reservation;\
	_turf_reservation_recieving[reserved_turfs] |= T;\
	_turf_to_be_busy.flags_1 &= ~UNUSED_RESERVATION_TURF_1;\
	SSmapping.unused_turfs["[_turf_to_be_busy.z]"] -= _turf_to_be_busy;\
	SSmapping.used_turfs[T] = _turf_reservation_recieving}

#define UNRESERVE_TURF(T){\
	SSmapping.used_turfs -= T;\
	SET_RESERVATION_TURF(T);}
