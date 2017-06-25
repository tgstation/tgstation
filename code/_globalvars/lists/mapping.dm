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

GLOBAL_LIST_EMPTY(landmarks_list)				//list of all landmarks created
GLOBAL_LIST_EMPTY(start_landmarks_list)			//list of all spawn points created
GLOBAL_LIST_EMPTY(department_security_spawns)	//list of all department security spawns
GLOBAL_LIST_EMPTY(generic_event_spawns)			//list of all spawns for events

GLOBAL_LIST_EMPTY(wizardstart)
GLOBAL_LIST_EMPTY(newplayer_start)
GLOBAL_LIST_EMPTY(prisonwarp)	//prisoners go to these
GLOBAL_LIST_EMPTY(holdingfacility)	//captured people go here
GLOBAL_LIST_EMPTY(xeno_spawn)//Aliens spawn at these.
GLOBAL_LIST_EMPTY(tdome1)
GLOBAL_LIST_EMPTY(tdome2)
GLOBAL_LIST_EMPTY(tdomeobserve)
GLOBAL_LIST_EMPTY(tdomeadmin)
GLOBAL_LIST_EMPTY(prisonwarped)	//list of players already warped
GLOBAL_LIST_EMPTY(blobstart)
GLOBAL_LIST_EMPTY(secequipment)
GLOBAL_LIST_EMPTY(deathsquadspawn)
GLOBAL_LIST_EMPTY(emergencyresponseteamspawn)
GLOBAL_LIST_EMPTY(ruin_landmarks)

	//away missions
GLOBAL_LIST_EMPTY(awaydestinations)	//a list of landmarks that the warpgate can take you to

	//used by jump-to-area etc. Updated by area/updateName()
GLOBAL_LIST_EMPTY(sortedAreas)

GLOBAL_LIST_EMPTY(all_abstract_markers)