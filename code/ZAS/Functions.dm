//Global Functions
//Contents: FloodFill, ZMerge, ZConnect

proc/FloodFill(turf/start)
	if(!istype(start))
		return list()
	var
		list
			open_directions = list(EAST, WEST)
			defer_directions = list(NORTH, SOUTH)
			open = list(start)
			defer = list()
			closed = list()
			doors = list()

	while(open.len || defer.len)
		if(open.len)
			for(var/turf/T in open)
				//Stop if there's a door, even if it's open. These are handled by indirect connection.
				if(!T.HasDoor())

					for(var/d in open_directions)
						var/turf/O = get_step(T,d)
						//Simple pass check.
						if(istype(O) && !(O in open || O in closed) && O.ZCanPass(T))
							defer -= O
							open += O
					for(var/d in defer_directions)
						var/turf/O = get_step(T,d)
						//Simple pass check.
						if(istype(O) && !(O in open || O in closed || O in defer) && O.ZCanPass(T))
							defer += O
				else
					doors |= T
					open -= T
					continue

				open -= T
				closed += T
		else
			open += locate(/turf) in defer

	for(var/turf/T in doors)
		var/force_connection = 1
		var/turf/simulated/O = get_step(T,NORTH)
		if(O in closed)
			closed += T
			continue
		else if(T.ZCanPass(O) && istype(O))
			force_connection = 0

		O = get_step(T,WEST)
		if(O in closed)
			closed += T
			continue
		else if(force_connection && T.ZCanPass(O) && istype(O))
			force_connection = 0

		if(force_connection)
			O = get_step(T,SOUTH)
			if(O in closed)
				closed += T
			else if((!T.ZCanPass(O) || !istype(O)) && get_step(T,EAST) in closed)
				closed += T

	return closed


proc/ZMerge(zone/A,zone/B)
	//Merges two zones so that they are one.
	var
		a_size = A.air.group_multiplier
		b_size = B.air.group_multiplier
		c_size = a_size + b_size
		new_contents = A.contents + B.contents

	//Set air multipliers to one so air represents gas per tile.
	A.air.group_multiplier = 1
	B.air.group_multiplier = 1

	//Remove some air proportional to the size of this zone.
	A.air.remove_ratio(a_size/c_size)
	B.air.remove_ratio(b_size/c_size)

	//Merge the gases and set the multiplier to the sum of the old ones.
	A.air.merge(B.air)
	A.air.group_multiplier = c_size

	//Check for connections to merge into the new zone.
	for(var/connection/C in B.connections)
		if((C.A in new_contents) && (C.B in new_contents))
			del C
			continue
		if(!A.connections) A.connections = list()
		A.connections += C

	//Add space tiles.
	A.unsimulated_tiles += B.unsimulated_tiles

	//Add contents.
	A.contents = new_contents

	//Set all the zone vars.
	for(var/turf/simulated/T in B.contents)
		T.zone = A

	for(var/connection/C in A.connections)
		C.Cleanup()

	B.SoftDelete()


proc/ZConnect(turf/simulated/A,turf/simulated/B)
	//Connects two zones by forming a connection object representing turfs A and B.

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
	if(!A.CanPass(null,B,0,0)) return
	if(A.CanPass(null,B,1.5,1))
		return ZMerge(A.zone,B.zone)

	//Ensure the connection isn't already made.
	if("\ref[A]" in air_master.turfs_with_connections)
		for(var/connection/C in air_master.turfs_with_connections["\ref[A]"])
			C.Cleanup()
			if(C && (C.B == B || C.A == B))
				return

	new /connection(A,B)

/*
proc/ZDisconnect(turf/A,turf/B)
	//Removes a zone connection. Can split zones in the case of a permanent barrier.

	//If one of them doesn't have a zone, it might be space, so check for that.
	if(A.zone && B.zone)
		//If the two zones are different, just remove a connection.
		if(A.zone != B.zone)
			for(var/connection/C in A.zone.connections)
				if((C.A == A && C.B == B) || (C.A == B && C.B == A))
					del C
				if(C)
					C.Cleanup()
		//If they're the same, split the zone at this line.
		else
			//Preliminary checks to prevent stupidity.
			if(A == B) return
			if(A.CanPass(0,B,0,0)) return
			if(A.HasDoor(B) || B.HasDoor(A)) return

			//Do a test fill. If turf B is still in the floodfill, then the zone isn't really split.
			var/zone/oldzone = A.zone
			var/list/test = FloodFill(A)
			if(B in test) return

			else
				var/zone/Z = new(test,oldzone.air) //Create a new zone based on the old air and the test fill.

				//Add connections from the old zone.
				for(var/connection/C in oldzone.connections)
					if((C.A in Z.contents) || (C.B in Z.contents))
						if(!Z.connections) Z.connections = list()
						Z.connections += C
						C.Cleanup()

				//Check for space.
				for(var/turf/T in test)
					T.check_for_space()

				//Make a new, identical air mixture for the other zone.
				var/datum/gas_mixture/Y_Air = new
				Y_Air.copy_from(oldzone.air)

				var/zone/Y = new(B,Y_Air) //Make a new zone starting at B and using Y_Air.

				//Add relevant connections from old zone.
				for(var/connection/C in oldzone.connections)
					if((C.A in Y.contents) || (C.B in Y.contents))
						if(!Y.connections) Y.connections = list()
						Y.connections += C
						C.Cleanup()

				//Add the remaining space tiles to this zone.
				for(var/turf/space/T in oldzone.unsimulated_tiles)
					if(!(T in Z.unsimulated_tiles))
						Y.AddSpace(T)

				oldzone.air = null
				del oldzone
	else
		if(B.zone)
			if(istype(A,/turf/space))
				B.zone.RemoveSpace(A)
			else
				for(var/connection/C in B.zone.connections)
					if((C.A == A && C.B == B) || (C.A == B && C.B == A))
						del C
					if(C)
						C.Cleanup()
		if(A.zone)
			if(istype(B,/turf/space))
				A.zone.RemoveSpace(B)
			else
				for(var/connection/C in A.zone.connections)
					if((C.A == A && C.B == B) || (C.A == B && C.B == A))
						del C
					if(C)
						C.Cleanup()*/