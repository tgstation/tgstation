/*
The /tg/ codebase currently requires you to have 7 z-levels of the same size dimensions.
z-level order is important, the order you put them in inside this file will determine what z level number they are assigned ingame.
Names of z-level do not matter, but order does greatly, for instances such as checking alive status of revheads on z1
*/

#if !defined(MAP_FILE)

        #include "map_files\AsteroidStation\AsteroidStation.dmm"
        #include "map_files\AsteroidStation\z2.dmm"
        #include "map_files\generic\z3.dmm"
        #include "map_files\generic\z4.dmm"
        #include "map_files\AsteroidStation\z5.dmm"
        #include "map_files\generic\z6.dmm"
        #include "map_files\generic\z7.dmm"

        #define MAP_FILE "AsteroidStation.dmm"
        #define MAP_NAME "AsteroidStation"

#elif !defined(MAP_OVERRIDE)

	#warn a map has already been included, ignoring AsteroidStation.

#endif
