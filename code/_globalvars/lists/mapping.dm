#define Z_NORTH 1
#define Z_EAST 2
#define Z_SOUTH 3
#define Z_WEST 4

GLOBAL_LIST_INIT(cardinal, list( NORTH, SOUTH, EAST, WEST ))
GLOBAL_LIST_INIT(alldirs, list(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST))
GLOBAL_LIST_INIT(diagonals, list(NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST))

//This list contains the z-level numbers which can be accessed via space travel and the percentile chances to get there.
//(Exceptions: extended, sandbox and nuke) -Errorage
//Was list("3" = 30, "4" = 70).
//Spacing should be a reliable method of getting rid of a body -- Urist.
//Go away Urist, I'm restoring this to the longer list. ~Errorage
GLOBAL_LIST_INIT(accessable_z_levels, list(1,3,4,5,6,7)) //Keep this to six maps, repeating z-levels is ok if needed

GLOBAL_LIST(global_map)
	//list/global_map = list(list(1,5),list(4,3))//an array of map Z levels.
	//Resulting sector map looks like
	//|_1_|_4_|
	//|_5_|_3_|
	//
	//1 - SS13
	//4 - Derelict
	//3 - AI satellite
	//5 - empty space

GLOBAL_LIST_INIT(landmarks_list, list())				//list of all landmarks created
GLOBAL_LIST_INIT(start_landmarks_list, list())			//list of all spawn points created
GLOBAL_LIST_INIT(department_security_spawns, list())	//list of all department security spawns
GLOBAL_LIST_INIT(generic_event_spawns, list())			//list of all spawns for events

GLOBAL_LIST_INIT(monkeystart, list())
GLOBAL_LIST_INIT(wizardstart, list())
GLOBAL_LIST_INIT(newplayer_start, list())
GLOBAL_LIST_INIT(latejoin, list())
GLOBAL_LIST_INIT(prisonwarp, list())	//prisoners go to these
GLOBAL_LIST_INIT(holdingfacility, list())	//captured people go here
GLOBAL_LIST_INIT(xeno_spawn, list())//Aliens spawn at these.
GLOBAL_LIST_INIT(tdome1, list())
GLOBAL_LIST_INIT(tdome2, list())
GLOBAL_LIST_INIT(tdomeobserve, list())
GLOBAL_LIST_INIT(tdomeadmin, list())
GLOBAL_LIST_INIT(prisonsecuritywarp, list())	//prison security goes to these
GLOBAL_LIST_INIT(prisonwarped, list())	//list of players already warped
GLOBAL_LIST_INIT(blobstart, list())
GLOBAL_LIST_INIT(secequipment, list())
GLOBAL_LIST_INIT(deathsquadspawn, list())
GLOBAL_LIST_INIT(emergencyresponseteamspawn, list())
GLOBAL_LIST_INIT(ruin_landmarks, list())

	//away missions
GLOBAL_LIST_INIT(awaydestinations, list())	//a list of landmarks that the warpgate can take you to

	//used by jump-to-area etc. Updated by area/updateName()
GLOBAL_LIST_INIT(sortedAreas, list())

GLOBAL_LIST_INIT(transit_markers, list())
