/*
This object is contained within zone/var/connections. It's generated whenever two turfs from different zones are linked.
Indirect connections will not merge the two zones after they reach equilibrium.
*/

connection
	var
		turf //The turfs involved in the connection.
			A
			B
		zone
			zone_A
			zone_B
		indirect = 0 //If the connection is purely indirect, the zones should not join.
		last_updated //The tick at which this was last updated.
		no_zone_count = 0
	New(turf/T,turf/O)
		A = T
		B = O
		if(A.zone && B.zone)
			if(!A.zone.connections) A.zone.connections = list()
			A.zone.connections += src
			zone_A = A.zone

			if(!B.zone.connections) B.zone.connections = list()
			B.zone.connections += src
			zone_B = B.zone

			if(!air_master.tiles_with_connections)
				air_master.tiles_with_connections = list()

			if(air_master.tiles_with_connections[A])
				var/list/A_connections = air_master.tiles_with_connections[A]
				A_connections |= src
			else
				var/list/A_connections = list(src)
				air_master.tiles_with_connections[A] = A_connections

			if(air_master.tiles_with_connections[B])
				var/list/B_connections = air_master.tiles_with_connections[B]
				B_connections |= src
			else
				var/list/B_connections = list(src)
				air_master.tiles_with_connections[B] = B_connections

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
			del(src)
	Del()
		if(A)
			if(A.zone && A.zone.connections)
				A.zone.connections.Remove(src)
				if(!A.zone.connections.len)
					del A.zone.connections
			if(A in air_master.tiles_with_connections)
				var/list/A_connections = air_master.tiles_with_connections[A]
				A_connections -= src
				if(A_connections && !A_connections.len)
					del A_connections
					air_master.tiles_with_connections.Remove(A)
		if(B)
			if(B.zone && B.zone.connections)
				B.zone.connections.Remove(src)
				if(!B.zone.connections.len)
					del B.zone.connections
			if(B in air_master.tiles_with_connections)
				var/list/B_connections = air_master.tiles_with_connections[B]
				B_connections -= src
				if(B_connections && !B_connections.len)
					del B_connections
					air_master.tiles_with_connections.Remove(B)
		if(zone_A)
			if(zone_A && zone_A.connections)
				zone_A.connections.Remove(src)
				if(!zone_A.connections.len)
					del zone_A.connections
		if(zone_B)
			if(zone_B && zone_B.connections)
				zone_B.connections.Remove(src)
				if(!zone_B.connections.len)
					del zone_B.connections

		if(A && A.zone)
			if(B && B.zone)
				if(B.zone in A.zone.connected_zones)
					if(A.zone.connected_zones[B.zone] > 1)
						A.zone.connected_zones[B.zone]--
					else
						A.zone.connected_zones -= B.zone
				if(A.zone.connected_zones && !A.zone.connected_zones.len)
					A.zone.connected_zones = null
			if( zone_B && (!B.zone && zone_B != B.zone) )
				if(zone_B in A.zone.connected_zones)
					if(A.zone.connected_zones[zone_B] > 1)
						A.zone.connected_zones[zone_B]--
					else
						A.zone.connected_zones -= zone_B
				if(A.zone.connected_zones && !A.zone.connected_zones.len)
					A.zone.connected_zones = null
		if(zone_A && (!A.zone || zone_A != A.zone))
			if(B && B.zone)
				if(B.zone in zone_A.connected_zones)
					if(zone_A.connected_zones[B.zone] > 1)
						zone_A.connected_zones[B.zone]--
					else
						zone_A.connected_zones -= B.zone
				if(zone_A.connected_zones && !zone_A.connected_zones.len)
					zone_A.connected_zones = null
			if( zone_B && (!B.zone && zone_B != B.zone) )
				if(zone_B in zone_A.connected_zones)
					if(zone_A.connected_zones[zone_B] > 1)
						zone_A.connected_zones[zone_B]--
					else
						zone_A.connected_zones -= zone_B
				if(zone_A.connected_zones && !zone_A.connected_zones.len)
					zone_A.connected_zones = null
		if(B && B.zone)
			if(A && A.zone)
				if(A.zone in B.zone.connected_zones)
					if(B.zone.connected_zones[A.zone] > 1)
						B.zone.connected_zones[A.zone]--
					else
						B.zone.connected_zones -= A.zone
				if(B.zone.connected_zones && !B.zone.connected_zones.len)
					B.zone.connected_zones = null
			if( zone_A && (!A.zone && zone_A != A.zone) )
				if(zone_A in B.zone.connected_zones)
					if(B.zone.connected_zones[zone_A] > 1)
						B.zone.connected_zones[zone_A]--
					else
						B.zone.connected_zones -= zone_A
				if(B.zone.connected_zones && !B.zone.connected_zones.len)
					B.zone.connected_zones = null
		if(zone_B && (!B.zone || zone_B != B.zone))
			if(A && A.zone)
				if(A.zone in zone_B.connected_zones)
					if(zone_B.connected_zones[A.zone] > 1)
						zone_B.connected_zones[A.zone]--
					else
						zone_B.connected_zones -= A.zone
				if(zone_B.connected_zones && !zone_B.connected_zones.len)
					zone_B.connected_zones = null
			if( zone_A && (!A.zone && zone_A != A.zone) )
				if(zone_A in zone_B.connected_zones)
					if(zone_B.connected_zones[zone_A] > 1)
						zone_B.connected_zones[zone_A]--
					else
						zone_B.connected_zones -= zone_A
				if(zone_B.connected_zones && !zone_B.connected_zones.len)
					zone_B.connected_zones = null
		. = ..()

	proc/Cleanup()
		if(!A || !B)
			//world.log << "Connection removed: [A] or [B] missing entirely."
			del src
		if(A.zone == B.zone)
			//world.log << "Connection removed: Zones now merged."
			del src
		if((A.zone && A.zone != zone_A) || (B.zone && B.zone != zone_B))
			Sanitize()
		if(!A.zone || !B.zone)
			no_zone_count++
			if(no_zone_count >= 5)
				//world.log << "Connection removed: [A] or [B] missing a zone."
				del src
			return 0
		return 1

	proc/Sanitize()
		//If the zones change on connected turfs, update it.
		if(A.zone && A.zone != zone_A && B.zone && B.zone != zone_B)
			if(!A.zone || !B.zone)
				del src

			if(zone_A)
				if(zone_A.connections)
					zone_A.connections.Remove(src)
					if(!zone_A.connections.len)
						del zone_A.connections

				if(zone_A.connected_zones)
					if(zone_A.connected_zones[zone_B] > 1)
						zone_A.connected_zones[zone_B]--
					else
						zone_A.connected_zones.Remove(zone_B)
				if(zone_A.connected_zones && !zone_A.connected_zones.len)
					zone_A.connected_zones = null

			if(zone_B)
				if(zone_B.connections)
					zone_B.connections.Remove(src)
					if(!zone_B.connections.len)
						del zone_B.connections

				if(zone_B.connected_zones)
					if(zone_B.connected_zones[zone_A] > 1)
						zone_B.connected_zones[zone_A]--
					else
						zone_B.connected_zones.Remove(zone_A)
				if(zone_B.connected_zones && !zone_B.connected_zones.len)
					zone_B.connected_zones = null

			if(!A.zone.connections)
				A.zone.connections = list()
			A.zone.connections |= src
			if(!B.zone.connections)
				B.zone.connections = list()
			B.zone.connections |= src

			if(!A.zone.connected_zones)
				A.zone.connected_zones = list()
			if(!(B.zone in A.zone.connected_zones))
				A.zone.connected_zones += B.zone
				A.zone.connected_zones[B.zone] = 1
			else
				A.zone.connected_zones[B.zone]++

			if(!B.zone.connected_zones)
				B.zone.connected_zones = list()
			if(!(A.zone in B.zone.connected_zones))
				B.zone.connected_zones += A.zone
				B.zone.connected_zones[A.zone] = 1
			else
				B.zone.connected_zones[A.zone]++

			zone_B = B.zone

			zone_A = A.zone

		else if(A.zone && A.zone != zone_A)
			if(zone_A)

				if(zone_A.connections)
					zone_A.connections.Remove(src)
					if(!zone_A.connections.len)
						del zone_A.connections
				if(!A.zone.connections)
					A.zone.connections = list()
				A.zone.connections |= src

				if(zone_A.connected_zones)
					if(zone_A.connected_zones[zone_B] > 1)
						zone_A.connected_zones[zone_B]--
					else
						zone_A.connected_zones.Remove(zone_B)
				if(zone_A.connected_zones && !zone_A.connected_zones.len)
					zone_A.connected_zones = null

				if(!A.zone.connected_zones)
					A.zone.connected_zones = list()
				if(!(zone_B in A.zone.connected_zones))
					A.zone.connected_zones += zone_B
					A.zone.connected_zones[zone_B] = 1
				else
					A.zone.connected_zones[zone_B]++

				zone_A = A.zone

			else
				del src

		else if(B.zone && B.zone != zone_B)
			if(zone_B)

				if(zone_B.connections)
					zone_B.connections.Remove(src)
					if(!zone_B.connections.len)
						del zone_B.connections
				if(!B.zone.connections)
					B.zone.connections = list()
				B.zone.connections |= src

				if(zone_B.connected_zones)
					if(zone_B.connected_zones[zone_A] > 1)
						zone_B.connected_zones[zone_A]--
					else
						zone_B.connected_zones.Remove(zone_A)
				if(zone_B.connected_zones && !zone_B.connected_zones.len)
					zone_B.connected_zones = null

				if(!B.zone.connected_zones)
					B.zone.connected_zones = list()
				if(!(zone_A in B.zone.connected_zones))
					B.zone.connected_zones += zone_A
					B.zone.connected_zones[zone_A] = 1
				else
					B.zone.connected_zones[zone_A]++

				zone_B = B.zone

			else
				del src