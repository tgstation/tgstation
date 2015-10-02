/*
The /tg/ codebase currently requires you to have 7 z-levels of the same size dimensions.
z-level order is important, the order you put them in inside this file will determine what z level number they are assigned ingame.
Names of z-level do not matter, but order does greatly, for instances such as checking alive status of revheads on z1
*/

#if !defined(MAP_FILE)

        #include "map_files\Discstation\Discstation.0.8.0.dmm"
        #include "map_files\DiscStation\z2.dmm"
        #include "map_files\generic\z3.dmm"
        #include "map_files\DiscStation\z4.dmm"
        #include "map_files\generic\z5.dmm"
        #include "map_files\generic\z6.dmm"
        #include "map_files\generic\z7.dmm"

        #define MAP_FILE "DiscStation.dmm"
        #define MAP_NAME "DiscStation"

#elif !defined(MAP_OVERRIDE)

	#warn a map has already been included, ignoring Discstation.

#endif