/*
Birdstation by Tokiko1

A small map intended for lowpop(40 players and less).

How to compile:
Make sure this is the only ticked file in the .dm folder, then compile as usual.
*/


#if !defined(MAP_FILE)

        #include "map_files\BirdStation\BirdStation.dmm"
        #include "map_files\BirdStation\z2.dmm"
        #include "map_files\BirdStation\z3.dmm"
        #include "map_files\generic\z4.dmm"
        #include "map_files\BirdStation\z5.dmm"
        #include "map_files\generic\z6.dmm"
        #include "map_files\generic\z7.dmm"

        #define MAP_FILE "BirdStation.dmm"
        #define MAP_NAME "BirdboatStation"

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