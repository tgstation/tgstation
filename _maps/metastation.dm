/*
z-level order is important, the order you put them in inside this file will determine what z level number they are assigned ingame.
Names of z-level do not matter, but order does greatly, for instances such as checking alive status of revheads on z1
Don't remove any comments in this file, they are used to generate the space transition grid with bygex
Zlevel amount must be the same as the number of zlevels .dmms included or you'll get a bunch of runtimes
Linked and unlinked refers to if a z level can be reached via space transitions
MAP_NAME must be the same as the name of this file

current as of 2015-09-17
z1 = station
z2 = centcom
z3 = derelict telecomms satellite
z4 = derelict station
z5 = mining
z6 = empty space
z7 = empty space
*/

#if !defined(MAP_FILE)
		//zlevel amount:7
        #include "map_files\MetaStation\MetaStation.v41G.dmm"//1 linked
        #include "map_files\MetaStation\z2.dmm"//2 unlinked
        #include "map_files\MetaStation\z3.dmm"//3 linked
        #include "map_files\MetaStation\z4.dmm"//4 linked
        #include "map_files\MetaStation\z5.dmm"//5 linked
        #include "map_files\generic\z6.dmm"//6 linked
        #include "map_files\generic\z7.dmm"//7 linked

        #define MAP_FILE "MetaStation.v41F.dmm"
        #define MAP_NAME "MetaStation"

#elif !defined(MAP_OVERRIDE)

	#warn a map has already been included, ignoring MetaStation.

#endif
