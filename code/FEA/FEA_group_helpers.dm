/turf/simulated/proc/find_group()
	//Basically, join any nearby valid groups
	//	If more than one, pick one with most members at my borders
	// If can not find any but there was an ungrouped at border with me, call for group assembly

	var/turf/simulated/floor/north = get_step(src,NORTH)
	var/turf/simulated/floor/south = get_step(src,SOUTH)
	var/turf/simulated/floor/east = get_step(src,EAST)
	var/turf/simulated/floor/west = get_step(src,WEST)

	//Clear those we do not have access to
	if(!CanPass(null, north, null, 1) || !istype(north))
		north = null
	if(!CanPass(null, south, null, 1) || !istype(south))
		south = null
	if(!CanPass(null, east, null, 1) || !istype(east))
		east = null
	if(!CanPass(null, west, null, 1) || !istype(west))
		west = null

	var/new_group_possible = 0

	var/north_votes = 0
	var/south_votes = 0
	var/east_votes = 0

	if(north)
		if(north.parent)
			north_votes = 1

			if(south && (south.parent == north.parent))
				north_votes++
				south = null

			if(east && (east.parent == north.parent))
				north_votes++
				east = null

			if(west && (west.parent == north.parent))
				north_votes++
				west = null
		else
			new_group_possible = 1

	if(south)
		if(south.parent)
			south_votes = 1

			if(east && (east.parent == south.parent))
				south_votes++
				east = null

			if(west && (west.parent == south.parent))
				south_votes++
				west = null
		else
			new_group_possible = 1

	if(east)
		if(east.parent)
			east_votes = 1

			if(west && (west.parent == east.parent))
				east_votes++
				west = null
		else
			new_group_possible = 1

//	world << "[north_votes], [south_votes], [east_votes]"

	var/datum/air_group/group_joined = null

	if(west)
		if(west.parent)
			group_joined = west.parent
		else
			new_group_possible = 1

	if(north_votes && (north_votes >= south_votes) && (north_votes >= east_votes))
		group_joined = north.parent
	else if(south_votes  && (south_votes >= east_votes))
		group_joined = south.parent
	else if(east_votes)
		group_joined = east.parent

	if (istype(group_joined))
		if (group_joined.group_processing)
			group_joined.suspend_group_processing()
		group_joined.members += src
		parent=group_joined

		air_master.tiles_to_update += group_joined.members
		return 1

	else if(new_group_possible)
		air_master.assemble_group_turf(src)
		return 1

	else
		air_master.active_singletons += src
		return 1