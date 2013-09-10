//Global Functions
//Contents: FloodFill, ZMerge, ZConnect

//Floods outward from an initial turf to fill everywhere it's zone would reach.
proc/FloodFill(turf/simulated/start)

	if(!istype(start))
		return list()

	//The list of tiles waiting to be evaulated.
	var/list/open = list(start)
	//The list of tiles which have been evaulated.
	var/list/closed = list()

	//Loop through the turfs in the open list in order to find which adjacent turfs should be added to the zone.
	while(open.len)
		var/turf/simulated/T = pick(open)

		//sanity!
		if(!istype(T))
			open -= T
			continue

		//Check all cardinal directions
		for(var/d in cardinal)
			var/turf/simulated/O = get_step(T,d)

			//Ensure the turf is of proper type, that it is not in either list, and that air can reach it.
			if(istype(O) && !(O in open) && !(O in closed) && O.ZCanPass(T))

				//Handle connections from a tile with a door.
				if(T.HasDoor())
					//If they both have doors, then they are not able to connect period.
					if(O.HasDoor())
						continue

					//Connect first to north and west
					if(d == NORTH || d == WEST)
						open += O

					//If that fails, and north/west cannot be connected to, see if west or south can be connected instead.
					else
						var/turf/simulated/W = get_step(O, WEST)
						var/turf/simulated/N = get_step(O, NORTH)

						if( !O.ZCanPass(N) && !O.ZCanPass(W) )
							//If it cannot connect either to the north or west, connect it!
							open += O

				//If no doors are involved, add it immediately.
				else if(!O.HasDoor())
					open += O

				//Handle connecting to a tile with a door.
				else
					if(d == SOUTH || d == EAST)
						//doors prefer connecting to zones to the north  or west
						closed += O

					else
						//see if we need to force an attempted connection
						//(there are no potentially viable zones to the north/west of the door)
						var/turf/simulated/W = get_step(O, WEST)
						var/turf/simulated/N = get_step(O, NORTH)

						if( !O.ZCanPass(N) && !O.ZCanPass(W) )
							//If it cannot connect either to the north or west, connect it!
							closed += O

		//This tile is now evaluated, and can be moved to the list of evaluated tiles.
		open -= T
		closed += T

	return closed


//Procedure to merge two zones together.
proc/ZMerge(zone/A,zone/B)

	//Sanity~
	if(!istype(A) || !istype(B))
		return

	var/new_contents = A.contents + B.contents

	//Set all the zone vars.
	for(var/turf/simulated/T in B.contents)
		T.zone = A

	if(istype(A.air) && istype(B.air))
		//Merges two zones so that they are one.
		var/a_size = A.air.group_multiplier
		var/b_size = B.air.group_multiplier
		var/c_size = a_size + b_size

		//Set air multipliers to one so air represents gas per tile.
		A.air.group_multiplier = 1
		B.air.group_multiplier = 1

		//Remove some air proportional to the size of this zone.
		A.air.remove_ratio(a_size/c_size)
		B.air.remove_ratio(b_size/c_size)

		//Merge the gases and set the multiplier to the sum of the old ones.
		A.air.merge(B.air)
		A.air.group_multiplier = c_size

	//I hate when the air datum somehow disappears.
	//  Try to make it sorta work anyways.  Fakit
	else if(istype(B.air))
		A.air = B.air
		A.air.group_multiplier = A.contents.len

	else if(istype(A.air))
		A.air.group_multiplier = A.contents.len

	//Doublefakit.
	else
		A.air = new

	//Check for connections to merge into the new zone.
	for(var/connection/C in B.connections)
		//The Cleanup proc will delete the connection if the zones are the same.
		//	It will also set the zone variables correctly.
		C.Cleanup()

	//Add space tiles.
	if(A.unsimulated_tiles && B.unsimulated_tiles)
		A.unsimulated_tiles |= B.unsimulated_tiles
	else if (B.unsimulated_tiles)
		A.unsimulated_tiles = B.unsimulated_tiles

	//Add contents.
	A.contents = new_contents

	//Remove the "B" zone, finally.
	B.SoftDelete()


//Connects two zones by forming a connection object representing turfs A and B.
proc/ZConnect(turf/simulated/A,turf/simulated/B)

	//Make sure that if it's space, it gets added to unsimulated_tiles instead.
	if(!istype(B))
		if(A.zone)
			A.zone.AddTurf(B)
		return
	if(!istype(A))
		if(B.zone)
			B.zone.AddTurf(A)
		return

	if(!istype(A) || !istype(B))
		return

	//Make some preliminary checks to see if the connection is valid.
	if(!A.zone || !B.zone) return
	if(A.zone == B.zone) return

	if(A.CanPass(null,B,0,1))
		return ZMerge(A.zone,B.zone)

	//Ensure the connection isn't already made.
	if("\ref[A]" in air_master.turfs_with_connections)
		for(var/connection/C in air_master.turfs_with_connections["\ref[A]"])
			C.Cleanup()
			if(C && (C.B == B || C.A == B))
				return

	//Make the connection.
	new /connection(A,B)
