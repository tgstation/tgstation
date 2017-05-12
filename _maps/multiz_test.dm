#if !defined(MAP_FILE)

		// MultiZ Station

		#define TITLESCREEN "title"

		#define MINETYPE "lavaland"

        #include "map_files\debug\multiz_test.dmm"

		#define MAP_PATH "map_files/debug"
        #define MAP_FILE "multiz_test.dmm"
        #define MAP_NAME "MultiZ Station"

		#define MAP_TRANSITION_CONFIG list(MAIN_STATION = UNAFFECTED)

#elif !defined(MAP_OVERRIDE)

	#warn a map has already been included, ignoring MultiZ Station.

#endif
