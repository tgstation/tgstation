#if !defined(MAP_FILE)

		// Runtime Station
		// This is a developer sandbox map that will compile and
		// load quickly. Not intended for production deployment.

		#define TITLESCREEN "title"

		#define MINETYPE "lavaland"

        #include "map_files\debug\runtimestation.dmm"

		#define MAP_PATH "map_files/debug"
        #define MAP_FILE "runtimestation.dmm"
        #define MAP_NAME "Runtime Station"

		#define MAP_TRANSITION_CONFIG list(MAIN_STATION = UNAFFECTED)

#elif !defined(MAP_OVERRIDE)

	#warn a map has already been included, ignoring Runtime Station.

#endif
