/*
Birdstation by Tokiko1

A small map intended for lowpop(40 players and less).

*/


#if !defined(MAP_FILE)

        #include "map_files\BirdStation\BirdStation.dmm"
        #include "map_files\generic\z2.dmm"
        #include "map_files\generic\z3.dmm"
        #include "map_files\generic\z4.dmm"
        #include "map_files\BirdStation\z5.dmm"
        #include "map_files\generic\z6.dmm"
        #include "map_files\generic\z7.dmm"

        #define MAP_FILE "BirdStation.dmm"
        #define MAP_NAME "BirdboatStation"

        #define MAP_TRANSITION_CONFIG	list(MAIN_STATION = CROSSLINKED, CENTCOMM = SELFLOOPING, ABANDONED_SATELLITE = CROSSLINKED, DERELICT = CROSSLINKED, MINING = CROSSLINKED, EMPTY_AREA_1 = CROSSLINKED, EMPTY_AREA_2 = CROSSLINKED)

		#if !defined(MAP_OVERRIDE_FILES)
				#define MAP_OVERRIDE_FILES
				#include "map_files\BirdStation\telecomms.dm"
				#include "map_files\BirdStation\teg.dm"
				#include "map_files\BirdStation\misc.dm"
				#include "map_files\BirdStation\job\job_changes.dm"
		        #include "map_files\BirdStation\job\removed_jobs.dm"
		#endif

#elif !defined(MAP_OVERRIDE)

	#warn a map has already been included, ignoring birdstation.

#endif