connection
	var
		turf //The turfs involved in the connection.
			A
			B
		indirect = 0 //If the connection is purely indirect, the zones should not join.
		last_updated //The tick at which this was last updated.
		no_zone_count = 0
	New(turf/T,turf/O)
		A = T
		B = O
		if(A.zone)
			if(!A.zone.connections) A.zone.connections = new()
			A.zone.connections += src
		if(B.zone)
			if(!B.zone.connections) B.zone.connections = new()
			B.zone.connections += src
		if(A.zone && B.zone)
			if(!A.zone.connected_zones)
				A.zone.connected_zones = list()
			if(!B.zone.connected_zones)
				B.zone.connected_zones = list()

			if(!(B.zone in A.zone.connected_zones))
				A.zone.connected_zones += B.zone
				A.zone.connected_zones[B.zone] = 1
			else
				A.zone.connected_zones[B.zone]++

			if(!(A.zone in B.zone.connected_zones))
				B.zone.connected_zones += A.zone
				B.zone.connected_zones[A.zone] = 1
			else
				B.zone.connected_zones[A.zone]++
		else
			world.log << "Attempted to create connection object for non-zone tiles: [T] -> [O]"
	Del()
		if(A.zone && A.zone.connections)
			A.zone.connections -= src
		if(B.zone && B.zone.connections)
			B.zone.connections -= src

		if(A.zone && B.zone)

			if(B.zone in A.zone.connected_zones)
				if(A.zone.connected_zones[B.zone] > 1)
					A.zone.connected_zones[B.zone]--
				else
					A.zone.connected_zones -= B.zone

			if(A.zone in B.zone.connected_zones)
				if(B.zone.connected_zones[A.zone] > 1)
					B.zone.connected_zones[A.zone]--
				else
					B.zone.connected_zones -= A.zone
			if(A.zone.connected_zones && !A.zone.connected_zones.len)
				A.zone.connected_zones = null
			if(B.zone.connected_zones && !B.zone.connected_zones.len)
				B.zone.connected_zones = null
		. = ..()

	proc/Cleanup()
		if(!A || !B)
			world.log << "Connection removed: [A] or [B] missing entirely."
			del src
		if(A.zone == B.zone)
			world.log << "Connection removed: Zones now merged."
			del src
		if(!A.zone || !B.zone)
			no_zone_count++
		if(no_zone_count >= 5)
			world.log << "Connection removed: [A] or [B] missing a zone."
			del src