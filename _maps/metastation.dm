/*
The /tg/ codebase currently requires you to have 7 z-levels of the same size dimensions.
z-level order is important, the order you put them in inside this file will determine what z level number they are assigned ingame.
Names of z-level do not matter, but order does greatly, for instances such as checking alive status of revheads on z1

current as of 2015/05/04
z1 = station
z2 = centcom
z3 = tcommsat/abandoned ship
z4 = derelict
z5 = mining asteroid
z6 = empty space
z7 = empty space
z8 = clown planet
z9 = away mission
*/

#if !defined(MAP_FILE)

        #include "map_files\MetaStation\MetaStation.v40D.dmm"
        #include "map_files\MetaStation\z2.dmm"
        #include "map_files\MetaStation\z3.dmm"
        #include "map_files\MetaStation\z4.dmm"
        #include "map_files\MetaStation\z5.dmm"
        #include "map_files\MetaStation\z6.dmm"
        #include "map_files\MetaStation\z7.dmm"
		#include "map_files\MetaStation\z8.dmm"

        #define MAP_FILE "MetaStation.v40D.dmm"
        #define MAP_NAME "MetaStation"

#elif !defined(MAP_OVERRIDE)

	#warn a map has already been included, ignoring MetaStation.

#endif
