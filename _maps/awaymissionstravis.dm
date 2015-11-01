/*
The /tg/ codebase currently requires you to have 7 z-levels of the same size dimensions.
z-level order is important, the order you put them in inside this file will determine what z level number they are assigned ingame.
Names of z-level do not matter, but order does greatly, for instances such as checking alive status of revheads on z1

current as of 2014/11/24
z1 = station
z2 = centcomm
z3 = derelict telecomms satellite
z4 = derelict station
z5 = mining
z6 = empty space
z7 = empty space


!!THIS IS FOR TRAVIS AND COMPILATION TESTING ONLY DO NOT TRY TO USE THIS FOR AN ACTUAL SERVER MAP IT WILL NOT WORK!!
*/

#if !defined(MAP_FILE)

		#include "RandomZLevels\Academy.dmm"
		#include "RandomZLevels\beach.dmm"
		#include "RandomZLevels\blackmarketpackers.dmm"
		#include "RandomZLevels\centcomAway.dmm"
		#include "RandomZLevels\challenge.dmm"
		#include "RandomZLevels\example.dmm"
		#include "RandomZLevels\listeningpost.dmm"
		#include "RandomZLevels\moonoutpost19.dmm"
		#include "RandomZLevels\spacebattle.dmm"
		#include "RandomZLevels\spacehotel.dmm"
		#include "RandomZLevels\stationCollision.dmm"
		#include "RandomZLevels\undergroundoutpost45.dmm"
		#include "RandomZLevels\wildwest.dmm"

        #define MAP_FILE "Academy.dmm"
        #define MAP_NAME "Away Missions Travis"

        #define MAP_TRANSITION_CONFIG	list(MAIN_STATION = CROSSLINKED, CENTCOMM = SELFLOOPING, ABANDONED_SATELLITE = CROSSLINKED, DERELICT = CROSSLINKED, MINING = CROSSLINKED, EMPTY_AREA_1 = CROSSLINKED, EMPTY_AREA_2 = CROSSLINKED)

#elif !defined(MAP_OVERRIDE)

	#warn a map has already been included, ignoring /tg/station 2.

#endif