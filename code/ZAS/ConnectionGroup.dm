/*

Overview:
	These are what handle gas transfers between zones and into space.
	They are found in a zone's edges list and in air_master.edges.
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

/connection_edge/var/coefficient = 0

/connection_edge/New()
	CRASH("Cannot make connection edge without specifications.")

/connection_edge/proc/add_connection(connection/c)
	coefficient++
	//world << "Connection added: [type] Coefficient: [coefficient]"

/connection_edge/proc/remove_connection(connection/c)
	//world << "Connection removed: [type] Coefficient: [coefficient-1]"
	coefficient--
	if(coefficient <= 0)
		erase()

/connection_edge/proc/contains_zone(zone/Z)

/connection_edge/proc/erase()
	air_master.remove_edge(src)
	//world << "[type] Erased."

/connection_edge/proc/tick()

/connection_edge/proc/flow(list/movable, differential, repelled)
	if(!zas_settings.Get(/datum/ZAS_Setting/airflow_push))
		return
	for(var/atom/movable/M in movable)
		if(!M.AirflowCanPush())
			continue
		//If they're already being tossed, don't do it again.
		if(M.last_airflow > world.time - zas_settings.Get(/datum/ZAS_Setting/airflow_delay))
			continue
		if(M.airflow_speed)
			continue

		//Check for knocking people over
		if(ismob(M) && differential > zas_settings.Get(/datum/ZAS_Setting/airflow_stun_pressure))
			if(M:status_flags & GODMODE) continue
			M:airflow_stun()

		if(M.check_airflow_movable(differential))
			//Check for things that are in range of the midpoint turfs.
			var/list/close_turfs = list()
			for(var/turf/U in connecting_turfs)
				if(get_dist(M,U) < world.view)
					close_turfs += U
			if(!close_turfs.len)
				continue

			M.airflow_dest = pick(close_turfs) //Pick a random midpoint to fly towards.

			if(M)
				if(repelled)
					M.RepelAirflowDest(differential/5)
				else
					M.GotoAirflowDest(differential/10)




/connection_edge/zone/var/zone/B
/connection_edge/zone/var/direct = 0

/connection_edge/zone/New(zone/A, zone/B)

	src.A = A
	src.B = B
	A.edges.Add(src)
	B.edges.Add(src)
	//id = edge_id(A,B)
	//world << "New edge between [A] and [B]"

/connection_edge/zone/add_connection(connection/c)
	. = ..()
	connecting_turfs.Add(c.A)
	if(c.direct()) direct++

/connection_edge/zone/remove_connection(connection/c)
	connecting_turfs.Remove(c.A)
	if(c.direct()) direct--
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
	//world << "[id]: Tick [air_master.current_cycle]: \..."
	if(direct)
		if(air_master.equivalent_pressure(A, B))
			//world << "merged."
			erase()
			air_master.merge(A, B)
			//world << "zones merged."
			return

	//air_master.equalize(A, B)
	ShareRatio(A.air,B.air,coefficient)
	air_master.mark_zone_update(A)
	air_master.mark_zone_update(B)
	//world << "equalized."

	var/differential = A.air.return_pressure() - B.air.return_pressure()
	if(abs(differential) < zas_settings.Get(/datum/ZAS_Setting/airflow_lightest_pressure)) return

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
	//world << "New edge from [A] to [B]."

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
	//world << "[id]: Tick [air_master.current_cycle]: To [B]!"
	//A.air.mimic(B, coefficient)
	ShareSpace(A.air,air,dbg_out)
	air_master.mark_zone_update(A)

	var/differential = A.air.return_pressure() - air.return_pressure()
	if(abs(differential) < zas_settings.Get(/datum/ZAS_Setting/airflow_lightest_pressure)) return

	var/list/attracted = A.movables()
	flow(attracted, abs(differential), differential < 0)

var/list/sharing_lookup_table = list(0.30, 0.40, 0.48, 0.54, 0.60, 0.66)

proc/ShareRatio(datum/gas_mixture/A, datum/gas_mixture/B, connecting_tiles)
	//Shares a specific ratio of gas between mixtures using simple weighted averages.
	var
		//WOOT WOOT TOUCH THIS AND YOU ARE A RETARD
		ratio = sharing_lookup_table[6]
		//WOOT WOOT TOUCH THIS AND YOU ARE A RETARD

		size = max(1,A.group_multiplier)
		share_size = max(1,B.group_multiplier)

		full_oxy = A.oxygen * size
		full_nitro = A.nitrogen * size
		full_co2 = A.carbon_dioxide * size
		full_plasma = A.toxins * size

		full_heat_capacity = A.heat_capacity() * size

		s_full_oxy = B.oxygen * share_size
		s_full_nitro = B.nitrogen * share_size
		s_full_co2 = B.carbon_dioxide * share_size
		s_full_plasma = B.toxins * share_size

		s_full_heat_capacity = B.heat_capacity() * share_size

		oxy_avg = (full_oxy + s_full_oxy) / (size + share_size)
		nit_avg = (full_nitro + s_full_nitro) / (size + share_size)
		co2_avg = (full_co2 + s_full_co2) / (size + share_size)
		plasma_avg = (full_plasma + s_full_plasma) / (size + share_size)

		temp_avg = (A.temperature * full_heat_capacity + B.temperature * s_full_heat_capacity) / (full_heat_capacity + s_full_heat_capacity)

	//WOOT WOOT TOUCH THIS AND YOU ARE A RETARD
	if(sharing_lookup_table.len >= connecting_tiles) //6 or more interconnecting tiles will max at 42% of air moved per tick.
		ratio = sharing_lookup_table[connecting_tiles]
	//WOOT WOOT TOUCH THIS AND YOU ARE A RETARD

	A.oxygen = max(0, (A.oxygen - oxy_avg) * (1-ratio) + oxy_avg )
	A.nitrogen = max(0, (A.nitrogen - nit_avg) * (1-ratio) + nit_avg )
	A.carbon_dioxide = max(0, (A.carbon_dioxide - co2_avg) * (1-ratio) + co2_avg )
	A.toxins = max(0, (A.toxins - plasma_avg) * (1-ratio) + plasma_avg )

	A.temperature = max(0, (A.temperature - temp_avg) * (1-ratio) + temp_avg )

	B.oxygen = max(0, (B.oxygen - oxy_avg) * (1-ratio) + oxy_avg )
	B.nitrogen = max(0, (B.nitrogen - nit_avg) * (1-ratio) + nit_avg )
	B.carbon_dioxide = max(0, (B.carbon_dioxide - co2_avg) * (1-ratio) + co2_avg )
	B.toxins = max(0, (B.toxins - plasma_avg) * (1-ratio) + plasma_avg )

	B.temperature = max(0, (B.temperature - temp_avg) * (1-ratio) + temp_avg )

	for(var/datum/gas/G in A.trace_gases)
		var/datum/gas/H = locate(G.type) in B.trace_gases
		if(H)
			var/G_avg = (G.moles*size + H.moles*share_size) / (size+share_size)
			G.moles = (G.moles - G_avg) * (1-ratio) + G_avg

			H.moles = (H.moles - G_avg) * (1-ratio) + G_avg
		else
			H = new G.type
			B.trace_gases += H
			var/G_avg = (G.moles*size) / (size+share_size)
			G.moles = (G.moles - G_avg) * (1-ratio) + G_avg
			H.moles = (H.moles - G_avg) * (1-ratio) + G_avg

	for(var/datum/gas/G in B.trace_gases)
		var/datum/gas/H = locate(G.type) in A.trace_gases
		if(!H)
			H = new G.type
			A.trace_gases += H
			var/G_avg = (G.moles*size) / (size+share_size)
			G.moles = (G.moles - G_avg) * (1-ratio) + G_avg
			H.moles = (H.moles - G_avg) * (1-ratio) + G_avg

	A.update_values()
	B.update_values()

	if(A.compare(B)) return 1
	else return 0

proc/ShareSpace(datum/gas_mixture/A, list/unsimulated_tiles, dbg_output)
	//A modified version of ShareRatio for spacing gas at the same rate as if it were going into a large airless room.
	if(!unsimulated_tiles)
		return 0

	var
		unsim_oxygen = 0
		unsim_nitrogen = 0
		unsim_co2 = 0
		unsim_plasma = 0
		unsim_heat_capacity = 0
		unsim_temperature = 0

		size = max(1,A.group_multiplier)

	var/tileslen
	var/share_size

	if(istype(unsimulated_tiles, /datum/gas_mixture))
		var/datum/gas_mixture/avg_unsim = unsimulated_tiles
		unsim_oxygen = avg_unsim.oxygen
		unsim_co2 = avg_unsim.carbon_dioxide
		unsim_nitrogen = avg_unsim.nitrogen
		unsim_plasma = avg_unsim.toxins
		unsim_temperature = avg_unsim.temperature
		share_size = max(1, max(size + 3, 1) + avg_unsim.group_multiplier)
		tileslen = avg_unsim.group_multiplier

		if(dbg_output)
			world << "O2: [unsim_oxygen] N2: [unsim_nitrogen] Size: [share_size] Tiles: [tileslen]"

	else if(istype(unsimulated_tiles, /list))
		if(!unsimulated_tiles.len)
			return 0
		// We use the same size for the potentially single space tile
		// as we use for the entire room. Why is this?
		// Short answer: We do not want larger rooms to depressurize more
		// slowly than small rooms, preserving our good old "hollywood-style"
		// oh-shit effect when large rooms get breached, but still having small
		// rooms remain pressurized for long enough to make escape possible.
		share_size = max(1, max(size + 3, 1) + unsimulated_tiles.len)
		var/correction_ratio = share_size / unsimulated_tiles.len

		for(var/turf/T in unsimulated_tiles)
			unsim_oxygen += T.oxygen
			unsim_co2 += T.carbon_dioxide
			unsim_nitrogen += T.nitrogen
			unsim_plasma += T.toxins
			unsim_temperature += T.temperature/unsimulated_tiles.len

		//These values require adjustment in order to properly represent a room of the specified size.
		unsim_oxygen *= correction_ratio
		unsim_co2 *= correction_ratio
		unsim_nitrogen *= correction_ratio
		unsim_plasma *= correction_ratio
		tileslen = unsimulated_tiles.len

	else //invalid input type
		return 0

	unsim_heat_capacity = HEAT_CAPACITY_CALCULATION(unsim_oxygen, unsim_co2, unsim_nitrogen, unsim_plasma)

	var
		ratio = sharing_lookup_table[6]

		old_pressure = A.return_pressure()

		full_oxy = A.oxygen * size
		full_nitro = A.nitrogen * size
		full_co2 = A.carbon_dioxide * size
		full_plasma = A.toxins * size

		full_heat_capacity = A.heat_capacity() * size

		oxy_avg = (full_oxy + unsim_oxygen*share_size) / (size + share_size)
		nit_avg = (full_nitro + unsim_nitrogen*share_size) / (size + share_size)
		co2_avg = (full_co2 + unsim_co2*share_size) / (size + share_size)
		plasma_avg = (full_plasma + unsim_plasma*share_size) / (size + share_size)

		temp_avg = 0

	if((full_heat_capacity + unsim_heat_capacity) > 0)
		temp_avg = (A.temperature * full_heat_capacity + unsim_temperature * unsim_heat_capacity) / (full_heat_capacity + unsim_heat_capacity)

	if(sharing_lookup_table.len >= tileslen) //6 or more interconnecting tiles will max at 42% of air moved per tick.
		ratio = sharing_lookup_table[tileslen]

	if(dbg_output)
		world << "Ratio: [ratio]"
		world << "Avg O2: [oxy_avg] N2: [nit_avg]"

	A.oxygen = max(0, (A.oxygen - oxy_avg) * (1 - ratio) + oxy_avg )
	A.nitrogen = max(0, (A.nitrogen - nit_avg) * (1 - ratio) + nit_avg )
	A.carbon_dioxide = max(0, (A.carbon_dioxide - co2_avg) * (1 - ratio) + co2_avg )
	A.toxins = max(0, (A.toxins - plasma_avg) * (1 - ratio) + plasma_avg )

	A.temperature = max(TCMB, (A.temperature - temp_avg) * (1 - ratio) + temp_avg )

	for(var/datum/gas/G in A.trace_gases)
		var/G_avg = (G.moles * size) / (size + share_size)
		G.moles = (G.moles - G_avg) * (1 - ratio) + G_avg

	A.update_values()

	if(dbg_output) world << "Result: [abs(old_pressure - A.return_pressure())] kPa"

	return abs(old_pressure - A.return_pressure())


proc/ShareHeat(datum/gas_mixture/A, datum/gas_mixture/B, connecting_tiles)
	//This implements a simplistic version of the Stefan-Boltzmann law.
	var/energy_delta = ((A.temperature - B.temperature) ** 4) * 5.6704e-8 * connecting_tiles * 2.5
	var/maximum_energy_delta = max(0, min(A.temperature * A.heat_capacity() * A.group_multiplier, B.temperature * B.heat_capacity() * B.group_multiplier))
	if(maximum_energy_delta > abs(energy_delta))
		if(energy_delta < 0)
			maximum_energy_delta *= -1
		energy_delta = maximum_energy_delta

	A.temperature -= energy_delta / (A.heat_capacity() * A.group_multiplier)
	B.temperature += energy_delta / (B.heat_capacity() * B.group_multiplier)