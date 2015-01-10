/*
Asteroidstation uses a larger z-level size than normal, it is 340x340.

Asteroidstation uses unique code files that are included with the map.

To use Asteroidstation you need place the Asteroidstation folder into the /_maps/map_files/ directory.
Then tick this file, the maps and all additional files will be automatically defined when compiling

current as of 2014/11/24
z1 = Station
z2 = Centcomm
z3 = Clown Shuttle
z4 = Syndicate Listening Post
z5 = Ruskie DJ Station
z6 = Derelict Station
z7 = Empty Space
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
	#define MAP_NAME "AsteroidStation"

#elif !defined(MAP_OVERRIDE)

	#warn a map has already been included, ignoring AsteroidStation.

#endif
