/*
The /tg/ codebase currently requires you to have 10 z-levels of the same size dimensions.
z-level order is important, the order you put them in inside this file will determine what z level number they are assigned ingame.
Names of z-level do not matter, but order does greatly, for instances such as checking alive status of revheads on z1

current as of 2016/6/2
z1 = station
z2 = centcomm
z5 = mining
Everything else = randomized space
*/

#if !defined(MAP_FILE)

		#define TITLESCREEN "title" //Add an image in misc/fullscreen.dmi, and set this define to the icon_state, to set a custom titlescreen for your map

		#define MINETYPE "lavaland"

		#include "map_files\DreamStation\dreamstation04.dmm"
		#include "map_files\generic\z2.dmm"
		#include "map_files\generic\z3.dmm"
		#include "map_files\generic\z4.dmm"
		#include "map_files\generic\lavaland.dmm"
		#include "map_files\generic\z6.dmm"
		#include "map_files\generic\z7.dmm"
		#include "map_files\generic\z8.dmm"
		#include "map_files\generic\z9.dmm"
		#include "map_files\generic\z10.dmm"

		#define MAP_PATH "map_files/DreamStation"
		#define MAP_FILE "dreamstation04.dmm"
		#define MAP_NAME "DreamStation"

		#define MAP_TRANSITION_CONFIG	list(MAIN_STATION = CROSSLINKED, CENTCOMM = SELFLOOPING, MINING = SELFLOOPING, EMPTY_AREA_1 = CROSSLINKED, EMPTY_AREA_2 = CROSSLINKED, EMPTY_AREA_3 = CROSSLINKED, EMPTY_AREA_4 = CROSSLINKED, EMPTY_AREA_5 = CROSSLINKED, EMPTY_AREA_6 = CROSSLINKED, EMPTY_AREA_7 = CROSSLINKED, EMPTY_AREA_8 = CROSSLINKED)

#elif !defined(MAP_OVERRIDE)

	#warn a map has already been included, ignoring DreamStation.

#endif