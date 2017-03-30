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

GLOBAL_EMPTY_LIST(landmarks_list)				//list of all landmarks created
GLOBAL_EMPTY_LIST(start_landmarks_list)			//list of all spawn points created
GLOBAL_EMPTY_LIST(department_security_spawns)	//list of all department security spawns
GLOBAL_EMPTY_LIST(generic_event_spawns)			//list of all spawns for events

GLOBAL_EMPTY_LIST(monkeystart)
GLOBAL_EMPTY_LIST(wizardstart)
GLOBAL_EMPTY_LIST(newplayer_start)
GLOBAL_EMPTY_LIST(latejoin)
GLOBAL_EMPTY_LIST(prisonwarp)	//prisoners go to these
GLOBAL_EMPTY_LIST(holdingfacility)	//captured people go here
GLOBAL_EMPTY_LIST(xeno_spawn)//Aliens spawn at these.
GLOBAL_EMPTY_LIST(tdome1)
GLOBAL_EMPTY_LIST(tdome2)
GLOBAL_EMPTY_LIST(tdomeobserve)
GLOBAL_EMPTY_LIST(tdomeadmin)
GLOBAL_EMPTY_LIST(prisonsecuritywarp)	//prison security goes to these
GLOBAL_EMPTY_LIST(prisonwarped)	//list of players already warped
GLOBAL_EMPTY_LIST(blobstart)
GLOBAL_EMPTY_LIST(secequipment)
GLOBAL_EMPTY_LIST(deathsquadspawn)
GLOBAL_EMPTY_LIST(emergencyresponseteamspawn)
GLOBAL_EMPTY_LIST(ruin_landmarks)

	//away missions
GLOBAL_EMPTY_LIST(awaydestinations)	//a list of landmarks that the warpgate can take you to

	//used by jump-to-area etc. Updated by area/updateName()
GLOBAL_EMPTY_LIST(sortedAreas)

GLOBAL_EMPTY_LIST(transit_markers)
