/*
The /tg/ codebase currently requires you to have 7 z-levels of the same size dimensions.
z-level order is important, the order you put them in inside this file will determine what z level number they are assigned ingame.
Names of z-level do not matter, but order does greatly, for instances such as checking alive status of revheads on z1
*/

#if !defined(MAP_FILE)

        #include "map_files\DiscStation\DiscStation.dmm"
        #include "map_files\generic\z2.dmm"
        #include "map_files\generic\z3.dmm"
        #include "map_files\DiscStation\z4.dmm"
        #include "map_files\generic\z5.dmm"
        #include "map_files\generic\z6.dmm"
        #include "map_files\generic\z7.dmm"


        #define MAP_FILE "DiscStation.dmm"
        #define MAP_NAME "DiscStation"

        #define MAP_TRANSITION_CONFIG	list(MAIN_STATION = CROSSLINKED, CENTCOMM = SELFLOOPING, ABANDONED_SATELLITE = CROSSLINKED, DERELICT = CROSSLINKED, MINING = CROSSLINKED, EMPTY_AREA_1 = CROSSLINKED, EMPTY_AREA_2 = CROSSLINKED)


#elif !defined(MAP_OVERRIDE)

	#warn a map has already been included, ignoring Discstation.

#endif