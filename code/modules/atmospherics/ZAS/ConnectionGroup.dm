/*

Overview:
	These are what handle gas transfers between zones and into space.
	They are found in a zone's edges list and in SSair.edges.
	Each edge updates every air tick due to their role in gas transfer.
	They come in two flavors, /connection_edge/zone and /connection_edge/unsimulated.
	As the type names might suggest, they handle inter-zone and spacelike connections respectively.

Class Vars:

	A - This always holds a zone. In unsimulated edges, it holds the only zone.

	connecting_turfs - This holds a list of connected turfs, mainly for the sake of airflow.

	coefficent - This is a marker for how many connections are on this edge. Used to determine the ratio of flow.

	connection_edge/zone

		B - This holds the second zone with which the first zone equalizes.

		direct - This counts the number of direct (i.e. with no doors) connections on this edge.
		         Any value of this is sufficient to make the zones mergeable.

	connection_edge/unsimulated

		B - This holds an unsimulated turf which has the gas values this edge is mimicing.

		air - Retrieved from B on creation and used as an argument for the legacy ShareSpace() proc.

Class Procs:

	add_connection(connection/c)
		Adds a connection to this edge. Usually increments the coefficient and adds a turf to connecting_turfs.

	remove_connection(connection/c)
		Removes a connection from this edge. This works even if c is not in the edge, so be careful.
		If the coefficient reaches zero as a result, the edge is erased.

	contains_zone(zone/Z)
		Returns true if either A or B is equal to Z. Unsimulated connections return true only on A.

	erase()
		Removes this connection from processing and zone edge lists.

	tick()
		Called every air tick on edges in the processing list. Equalizes gas.

	flow(list/movable, differential, repelled)
		Airflow proc causing all objects in movable to be checked against a pressure differential.
		If repelled is true, the objects move away from any turf in connecting_turfs, otherwise they approach.
		A check against vsc.lightest_airflow_pressure should generally be performed before calling this.

	get_connected_zone(zone/from)
		Helper proc that allows getting the other zone of an edge given one of them.
		Only on /connection_edge/zone, otherwise use A.

*/


/connection_edge/var/zone/A

/connection_edge/var/list/connecting_turfs = list()
/connection_edge/var/direct = 0
/connection_edge/var/sleeping = 1

/connection_edge/var/coefficient = 0

/connection_edge/New()
	CRASH("Cannot make connection edge without specifications.")

/connection_edge/proc/add_connection(connection/c)
	coefficient++
	if(c.direct()) direct++
//	log_debug("Connection added: [type] Coefficient: [coefficient]")


/connection_edge/proc/remove_connection(connection/c)
//	log_debug("Connection removed: [type] Coefficient: [coefficient-1]")

	coefficient--
	if(coefficient <= 0)
		erase()
	if(c.direct()) direct--

/connection_edge/proc/contains_zone(zone/Z)

/connection_edge/proc/erase()
	SSair.remove_edge(src)
//	log_debug("[type] Erased.")


/connection_edge/proc/tick()

/connection_edge/proc/recheck()

/connection_edge/proc/flow(list/movable, differential, repelled)
	for(var/i = 1; i <= movable.len; i++)
		var/atom/movable/M = movable[i]

		//If they're already being tossed, don't do it again.
		if(M.last_airflow > world.time - vsc.airflow_delay) continue
		if(M.airflow_speed) continue

		//Check for knocking people over
		if(ismob(M) && differential > vsc.airflow_stun_pressure)
			if(M:status_flags & GODMODE) continue
			M:airflow_stun()

		if(M.check_airflow_movable(differential))
			//Check for things that are in range of the midpoint turfs.
			var/list/close_turfs = list()
			for(var/turf/U in connecting_turfs)
				if(get_dist(M,U) < world.view) close_turfs += U
			if(!close_turfs.len) continue

			M.airflow_dest = pick(close_turfs) //Pick a random midpoint to fly towards.

			if(repelled) spawn if(M) M.RepelAirflowDest(differential/5)
			else spawn if(M) M.GotoAirflowDest(differential/10)




/connection_edge/zone/var/zone/B

/connection_edge/zone/New(zone/A, zone/B)

	src.A = A
	src.B = B
	A.edges.Add(src)
	B.edges.Add(src)
	//id = edge_id(A,B)
//	log_debug("New edge between [A] and [B]")


/connection_edge/zone/add_connection(connection/c)
	. = ..()
	connecting_turfs.Add(c.A)

/connection_edge/zone/remove_connection(connection/c)
	connecting_turfs.Remove(c.A)
	. = ..()

/connection_edge/zone/contains_zone(zone/Z)
	return A == Z || B == Z

/connection_edge/zone/erase()
	A.edges.Remove(src)
	B.edges.Remove(src)
	. = ..()

/connection_edge/zone/tick()
	if(A.invalid || B.invalid)
		erase()
		return

	var/equiv = A.air.share_ratio(B.air, coefficient)

	var/differential = A.air.return_pressure() - B.air.return_pressure()
	if(abs(differential) >= vsc.airflow_lightest_pressure)
		var/list/attracted
		var/list/repelled
		if(differential > 0)
			attracted = A.movables()
			repelled = B.movables()
		else
			attracted = B.movables()
			repelled = A.movables()

		flow(attracted, abs(differential), 0)
		flow(repelled, abs(differential), 1)

	if(equiv)
		if(direct)
			erase()
			SSair.merge(A, B)
			return
		else
			A.air.equalize(B.air)
			SSair.mark_edge_sleeping(src)

	SSair.mark_zone_update(A)
	SSair.mark_zone_update(B)

/connection_edge/zone/recheck()
	if(!A.air.compare(B.air, vacuum_exception = 1))
	// Edges with only one side being vacuum need processing no matter how close.
		SSair.mark_edge_active(src)

//Helper proc to get connections for a zone.
/connection_edge/zone/proc/get_connected_zone(zone/from)
	if(A == from) return B
	else return A

/connection_edge/unsimulated/var/turf/B
/connection_edge/unsimulated/var/datum/gas_mixture/air

/connection_edge/unsimulated/New(zone/A, turf/B)
	src.A = A
	src.B = B
	A.edges.Add(src)
	air = B.return_air()
	//id = 52*A.id
//	log_debug("New edge from [A] to [B].")


/connection_edge/unsimulated/add_connection(connection/c)
	. = ..()
	connecting_turfs.Add(c.B)
	air.group_multiplier = coefficient

/connection_edge/unsimulated/remove_connection(connection/c)
	connecting_turfs.Remove(c.B)
	air.group_multiplier = coefficient
	. = ..()

/connection_edge/unsimulated/erase()
	A.edges.Remove(src)
	. = ..()

/connection_edge/unsimulated/contains_zone(zone/Z)
	return A == Z

/connection_edge/unsimulated/tick()
	if(A.invalid)
		erase()
		return

	var/equiv = A.air.share_space(air)

	var/differential = A.air.return_pressure() - air.return_pressure()
	if(abs(differential) >= vsc.airflow_lightest_pressure)
		var/list/attracted = A.movables()
		flow(attracted, abs(differential), differential < 0)

	if(equiv)
		A.air.copy_from(air)
		SSair.mark_edge_sleeping(src)

	SSair.mark_zone_update(A)

/connection_edge/unsimulated/recheck()
	// Edges with only one side being vacuum need processing no matter how close.
	// Note: This handles the glaring flaw of a room holding pressure while exposed to space, but
	// does not specially handle the less common case of a simulated room exposed to an unsimulated pressurized turf.
	if(!A.air.compare(air, vacuum_exception = 1))
		SSair.mark_edge_active(src)

proc/ShareHeat(datum/gas_mixture/A, datum/gas_mixture/B, connecting_tiles)
	//This implements a simplistic version of the Stefan-Boltzmann law.
	var/energy_delta = ((A.temperature - B.temperature) ** 4) * STEFAN_BOLTZMANN_CONSTANT * connecting_tiles * 2.5
	var/maximum_energy_delta = max(0, min(A.temperature * A.heat_capacity() * A.group_multiplier, B.temperature * B.heat_capacity() * B.group_multiplier))
	if(maximum_energy_delta > abs(energy_delta))
		if(energy_delta < 0)
			maximum_energy_delta *= -1
		energy_delta = maximum_energy_delta

	A.temperature -= energy_delta / (A.heat_capacity() * A.group_multiplier)
	B.temperature += energy_delta / (B.heat_capacity() * B.group_multiplier)
