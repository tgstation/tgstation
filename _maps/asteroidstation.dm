/*
The /tg/ codebase currently requires you to have 9 z-levels of the same size dimensions.
z-level order is important, the order you put them in inside this file will determine what z level number they are assigned ingame.
Names of z-level do not matter, but order does greatly, for instances such as checking alive status of revheads on z1

current as of 4/21/2016
z1 = station
z2 = centcomm
z3 = derelict telecomms satellite
z4 = derelict station
z5 = mostly empty space
z6 = empty space
z7 = empty space
z8 = empty space
z9 = empty space
*/

#if !defined(MAP_FILE)

        #define TITLESCREEN "title" //Add an image in misc/fullscreen.dmi, and set this define to the icon_state, to set a custom titlescreen for your map

        #define MINETYPE "mining"

        #include "map_files\AsteroidStation\AsteroidStation.dmm"
        #include "map_files\generic\z2.dmm"
        #include "map_files\generic\z3.dmm"
        #include "map_files\generic\z4.dmm"
        #include "map_files\AsteroidStation\z5.dmm"
        #include "map_files\generic\z6.dmm"
        #include "map_files\generic\z7.dmm"
        #include "map_files\generic\z8.dmm"
        #include "map_files\generic\z9.dmm"

        #define MAP_PATH "map_files/AsteroidStation"
        #define MAP_FILE "AsteroidStation.dmm"
        #define MAP_NAME "AsteroidStation"

        #define MAP_TRANSITION_CONFIG	list(MAIN_STATION = CROSSLINKED, CENTCOMM = SELFLOOPING, ABANDONED_SATELLITE = CROSSLINKED, DERELICT = CROSSLINKED, MINING = CROSSLINKED, EMPTY_AREA_1 = CROSSLINKED, EMPTY_AREA_2 = CROSSLINKED, EMPTY_AREA_3 = CROSSLINKED, EMPTY_AREA_4 = CROSSLINKED)

#elif !defined(MAP_OVERRIDE)

	#warn a map has already been included, ignoring AsteroidStation.

#endif
