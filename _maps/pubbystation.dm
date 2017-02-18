#if !defined(MAP_FILE)

		#define TITLESCREEN "title" //Add an image in misc/fullscreen.dmi, and set this define to the icon_state, to set a custom titlescreen for your map

		#define MINETYPE "lavaland"

		#include "map_files\PubbyStation\PubbyStation.dmm"
#ifndef TRAVIS_MASS_MAP_BUILD
		#include "map_files\generic\z2.dmm"
		#include "map_files\generic\z3.dmm"
		#include "map_files\generic\z4.dmm"
		#include "map_files\generic\lavaland.dmm"
		#include "map_files\generic\z6.dmm"
		#include "map_files\generic\z7.dmm"
		#include "map_files\generic\z8.dmm"
		#include "map_files\generic\z9.dmm"
		#include "map_files\generic\z10.dmm"
		#include "map_files\generic\z11.dmm"

		#define MAP_PATH "map_files/PubbyStation"
		#define MAP_FILE "PubbyStation.dmm"
		#define MAP_NAME "PubbyStation"

		#define MAP_TRANSITION_CONFIG DEFAULT_MAP_TRANSITION_CONFIG
#endif
		#if !defined(MAP_OVERRIDE_FILES)
			#define MAP_OVERRIDE_FILES
			#include "map_files\PubbyStation\job\job_changes.dm"
			#include "map_files\PubbyStation\job\removed_jobs.dm"
			#include "map_files\PubbyStation\monastery_shuttle.dm"
			#include "map_files\PubbyStation\areas.dm"
		#endif

#elif !defined(MAP_OVERRIDE)

	#warn a map has already been included, ignoring PubbyStation.

#endif
