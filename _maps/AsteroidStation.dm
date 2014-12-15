/*
Asteroidstation uses a larger z-level size than normal, it is 340x340x7.

Asteroidstation uses unique code files that are included with the map.

To use Asteroidstation you need place the Asteroidstation folder into the /_maps/map_files/ directory.
Then tick this file, the maps and all additional files will be automatically defined when compiling
*/

#if !defined(MAP_FILE)

	#include "map_files\Asteroidstation\Asteroidstation.dmm"
	#include "map_files\Asteroidstation\z2.dmm"
	#include "map_files\Asteroidstation\z3.dmm"
	#include "map_files\Asteroidstation\z4.dmm"
	#include "map_files\Asteroidstation\z5.dmm"
	#include "map_files\Asteroidstation\z6.dmm"
	#include "map_files\Asteroidstation\z7.dmm"

	#define MAP_FILE "Asteroidstation.dmm"
	#define MAP_NAME "AsteroidStationv8"

	#if !defined(MAP_OVERRIDE_FILES)
		#define MAP_OVERRIDE_FILES
		#include "map_files\Asteroidstation\areas.dm"
	#endif

#elif !defined(MAP_OVERRIDE)

	#warn a map has already been included, ignoring AsteroidStation.

#endif
