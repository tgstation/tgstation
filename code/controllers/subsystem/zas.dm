/*

Overview:
	The air controller does everything. There are tons of procs in here.

Class Vars:
	zones - All zones currently holding one or more turfs.
	edges - All processing edges.

	tiles_to_update - Tiles scheduled to update next tick.
	zones_to_update - Zones which have had their air changed and need air archival.
	active_hotspots - All processing fire objects.

	active_zones - The number of zones which were archived last tick. Used in debug verbs.
	next_id - The next UID to be applied to a zone. Mostly useful for debugging purposes as zones do not need UIDs to function.

Class Procs:

	mark_for_update(turf/T)
		Adds the turf to the update list. When updated, update_air_properties() will be called.
		When stuff changes that might affect airflow, call this. It's basically the only thing you need.

	add_zone(zone/Z) and remove_zone(zone/Z)
		Adds zones to the zones list. Does not mark them for update.

	air_blocked(turf/A, turf/B)
		Returns a bitflag consisting of:
		AIR_BLOCKED - The connection between turfs is physically blocked. No air can pass.
		ZONE_BLOCKED - There is a door between the turfs, so zones cannot cross. Air may or may not be permeable.

	has_valid_zone(turf/T)
		Checks the presence and validity of T's zone.
		May be called on unsimulated turfs, returning 0.

	merge(zone/A, zone/B)
		Called when zones have a direct connection and equivalent pressure and temperature.
		Merges the zones to create a single zone.

	connect(turf/simulated/A, turf/B)
		Called by turf/update_air_properties(). The first argument must be simulated.
		Creates a connection between A and B.

	mark_zone_update(zone/Z)
		Adds zone to the update list. Unlike mark_for_update(), this one is called automatically whenever
		air is returned from a simulated turf.

	equivalent_pressure(zone/A, zone/B)
		Currently identical to A.air.compare(B.air). Returns 1 when directly connected zones are ready to be merged.

	get_edge(zone/A, zone/B)
	get_edge(zone/A, turf/B)
		Gets a valid connection_edge between A and B, creating a new one if necessary.

	has_same_air(turf/A, turf/B)
		Used to determine if an unsimulated edge represents a specific turf.
		Simulated edges use connection_edge/contains_zone() for the same purpose.
		Returns 1 if A has identical gases and temperature to B.

	remove_edge(connection_edge/edge)
		Called when an edge is erased. Removes it from processing.

*/

SUBSYSTEM_DEF(zas)
	name = "Air Core"
	priority = FIRE_PRIORITY_AIR
	init_order = INIT_ORDER_AIR
	flags = SS_POST_FIRE_TIMING
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	wait = 2 SECONDS

	var/cached_cost = 0
	var/cost_tiles = 0
	var/cost_deferred_tiles = 0
	var/cost_edges = 0
	var/cost_fires = 0
	var/cost_hotspots = 0
	var/cost_zones = 0

	//The variable setting controller
	var/datum/zas_controller/settings
	//A reference to the global var
	var/datum/xgm_gas_data/gas_data

	var/datum/gas_mixture/lavaland_atmos

	//Geometry lists
	var/list/zones = list()
	var/list/edges = list()


	//Geometry updates lists
	var/list/tiles_to_update = list()
	var/list/zones_to_update = list()
	var/list/active_fire_zones = list()
	var/list/active_hotspots = list()
	var/list/active_edges = list()

	var/tmp/list/deferred = list()
	var/tmp/list/processing_edges
	var/tmp/list/processing_fires
	var/tmp/list/processing_hotspots
	var/tmp/list/processing_zones

	var/active_zones = 0
	var/next_id = 1


/datum/controller/subsystem/zas/proc/Reboot()
	// Stop processing while we rebuild.
	can_fire = FALSE
	next_id = 0 //Reset atmos zone count.

	// Make sure we don't rebuild mid-tick.
	if (state != SS_IDLE)
		to_chat(world, span_boldannounce("ZAS Rebuild initiated. Waiting for current air tick to complete before continuing."))
		while (state != SS_IDLE)
			stoplag()

	while (zones.len)
		var/zone/zone = zones[zones.len]
		zones.len--

		zone.c_invalidate()

	edges.Cut()
	tiles_to_update.Cut()
	zones_to_update.Cut()
	active_fire_zones.Cut()
	active_hotspots.Cut()
	active_edges.Cut()

	// Re-run setup without air settling.
	Initialize(REALTIMEOFDAY, simulate = FALSE)

	// Update next_fire so the MC doesn't try to make up for missed ticks.
	next_fire = world.time + wait
	can_fire = TRUE

/datum/controller/subsystem/zas/stat_entry(msg)
	if(!can_fire)
		msg += "REBOOTING..."
	else
		msg += "TtU: [length(tiles_to_update)] "
		msg += "ZtU: [length(zones_to_update)] "
		msg += "AFZ: [length(active_fire_zones)] "
		msg += "AH: [length(active_hotspots)] "
		msg += "AE: [length(active_edges)]"
	return ..()

/datum/controller/subsystem/zas/Initialize(timeofday, simulate = TRUE)

	var/starttime = REALTIMEOFDAY
	settings = new
	gas_data = xgm_gas_data

	to_chat(world, span_boldannounce("ZAS: Processing Geometry..."))

	var/simulated_turf_count = 0
	//for(var/turf/simulated/S) ZASTURF
	for(var/turf/S)
		if(!S.simulated)
			continue
		simulated_turf_count++
		S.update_air_properties()

		CHECK_TICK

	///LAVALAND SETUP
	fuck_lavaland()

	to_chat(world, span_boldannounce("ZAS:\n - Total Simulated Turfs: [simulated_turf_count]\n - Total Zones: [zones.len]\n - Total Edges: [edges.len]\n - Total Active Edges: [active_edges.len ? "<span class='danger'>[active_edges.len]</span>" : "None"]\n - Total Unsimulated Turfs: [world.maxx*world.maxy*world.maxz - simulated_turf_count]"))

	to_chat(world, span_boldannounce("ZAS: Geometry processing completed in [(REALTIMEOFDAY - starttime)/10] seconds!"))

	if (simulate)
		to_chat(world, span_boldannounce("ZAS: Firing once..."))

		starttime = REALTIMEOFDAY
		fire(FALSE, TRUE)

		to_chat(world, span_boldannounce("ZAS: Air settling completed in [(REALTIMEOFDAY - starttime)/10] seconds!"))

	..(timeofday)

/datum/controller/subsystem/zas/fire(resumed = FALSE, no_mc_tick)
	var/timer = TICK_USAGE_REAL
	if (!resumed)
		processing_edges = active_edges.Copy()
		processing_fires = active_fire_zones.Copy()
		processing_hotspots = active_hotspots.Copy()

	var/list/curr_tiles = tiles_to_update
	var/list/curr_defer = deferred
	var/list/curr_edges = processing_edges
	var/list/curr_fire = processing_fires
	var/list/curr_hotspot = processing_hotspots
	var/list/curr_zones = zones_to_update


/////////TILES//////////
	cached_cost = 0
	while (curr_tiles.len)
		var/turf/T = curr_tiles[curr_tiles.len]
		curr_tiles.len--

		if (!T)
			if (no_mc_tick)
				CHECK_TICK
			else if (MC_TICK_CHECK)
				return

			continue

		//check if the turf is self-zone-blocked
		var/c_airblock
		ATMOS_CANPASS_TURF(c_airblock, T, T)
		if(c_airblock & ZONE_BLOCKED)
			deferred += T
			if (no_mc_tick)
				CHECK_TICK
			else if (MC_TICK_CHECK)
				return
			continue

		T.update_air_properties()
		T.post_update_air_properties()
		T.needs_air_update = 0
		#ifdef ZASDBG
		T.vis_contents -= zasdbgovl_mark
		//updated++
		#endif

		if (no_mc_tick)
			CHECK_TICK
		else if (MC_TICK_CHECK)
			return

	cached_cost += TICK_USAGE_REAL - timer
	cost_tiles = MC_AVERAGE(cost_tiles, TICK_DELTA_TO_MS(cached_cost))

//////////DEFERRED TILES//////////
	timer = TICK_USAGE_REAL
	cached_cost = 0
	while (curr_defer.len)
		var/turf/T = curr_defer[curr_defer.len]
		curr_defer.len--

		T.update_air_properties()
		T.post_update_air_properties()
		T.needs_air_update = 0
		#ifdef ZASDBG
		T.vis_contents -= zasdbgovl_mark
		//updated++
		#endif

		if (no_mc_tick)
			CHECK_TICK
		else if (MC_TICK_CHECK)
			return
	cached_cost += TICK_USAGE_REAL - timer
	cost_deferred_tiles = MC_AVERAGE(cost_deferred_tiles, TICK_DELTA_TO_MS(cached_cost))

//////////EDGES//////////

	timer = TICK_USAGE_REAL
	cached_cost = 0
	while (curr_edges.len)
		var/connection_edge/edge = curr_edges[curr_edges.len]
		curr_edges.len--

		if (!edge)
			if (no_mc_tick)
				CHECK_TICK
			else if (MC_TICK_CHECK)
				return
			continue

		edge.tick()

		if (no_mc_tick)
			CHECK_TICK
		else if (MC_TICK_CHECK)
			return

	cached_cost += TICK_USAGE_REAL - timer
	cost_edges = MC_AVERAGE(cost_edges, TICK_DELTA_TO_MS(cached_cost))

//////////FIRES//////////
	timer = TICK_USAGE_REAL
	cached_cost = 0
	while (curr_fire.len)
		var/zone/Z = curr_fire[curr_fire.len]
		curr_fire.len--

		Z.process_fire()

		if (no_mc_tick)
			CHECK_TICK
		else if (MC_TICK_CHECK)
			return

	cached_cost += TICK_USAGE_REAL - timer
	cost_fires= MC_AVERAGE(cost_fires, TICK_DELTA_TO_MS(cached_cost))

//////////HOTSPOTS//////////
	timer = TICK_USAGE_REAL
	cached_cost = 0
	while (curr_hotspot.len)
		var/obj/effect/hotspot/F = curr_hotspot[curr_hotspot.len]
		curr_hotspot.len--

		F.process()

		if (no_mc_tick)
			CHECK_TICK
		else if (MC_TICK_CHECK)
			return
	cached_cost += TICK_USAGE_REAL - timer
	cost_hotspots = MC_AVERAGE(cost_hotspots, TICK_DELTA_TO_MS(cached_cost))

	timer = TICK_USAGE_REAL
	cached_cost = 0
	while (curr_zones.len)
		var/zone/Z = curr_zones[curr_zones.len]
		curr_zones.len--

		Z.tick()
		Z.needs_update = FALSE

		if (no_mc_tick)
			CHECK_TICK
		else if (MC_TICK_CHECK)
			return

	cached_cost += TICK_USAGE_REAL - timer
	cost_zones = MC_AVERAGE(cost_zones, TICK_DELTA_TO_MS(cached_cost))

/datum/controller/subsystem/zas/proc/add_zone(zone/z)
	zones += z
	z.name = "Zone [next_id++]"
	mark_zone_update(z)

/datum/controller/subsystem/zas/proc/remove_zone(zone/z)
	zones -= z
	zones_to_update -= z
	if (processing_zones)
		processing_zones -= z

/datum/controller/subsystem/zas/proc/air_blocked(turf/A, turf/B)
	#ifdef ZASDBG
	ASSERT(isturf(A))
	ASSERT(isturf(B))
	#endif
	var/ablock
	ATMOS_CANPASS_TURF(ablock, A, B)
	if(ablock == BLOCKED)
		return BLOCKED
	ATMOS_CANPASS_TURF(., B, A)
	return ablock | .

/datum/controller/subsystem/zas/proc/merge(zone/A, zone/B)
	#ifdef ZASDBG
	ASSERT(istype(A))
	ASSERT(istype(B))
	ASSERT(!A.invalid)
	ASSERT(!B.invalid)
	ASSERT(A != B)
	#endif
	if(A.contents.len < B.contents.len)
		A.c_merge(B)
		mark_zone_update(B)
	else
		B.c_merge(A)
		mark_zone_update(A)

//datum/controller/subsystem/zas/proc/connect(turf/simulated/A, turf/simulated/B) //ZASTURF
/datum/controller/subsystem/zas/proc/connect(turf/A, turf/B)
	#ifdef ZASDBG
	ASSERT(!istype(A, /turf/open/space))
	ASSERT(isturf(B))
	ASSERT(A.zone)
	ASSERT(!A.zone.invalid)
	//ASSERT(B.zone)
	ASSERT(A != B)
	#endif
	var/block = air_blocked(A,B)
	if(block & AIR_BLOCKED) return

	var/direct = !(block & ZONE_BLOCKED)
	//var/space = istype(B, /turf/open/space)
	var/space = !B.simulated

	if(!space)
		if(min(A.zone.contents.len, B.zone.contents.len) < ZONE_MIN_SIZE || (direct && (equivalent_pressure(A.zone,B.zone) || times_fired == 0)))
			merge(A.zone,B.zone)
			return

	var/a_to_b = get_dir(A,B)
	var/b_to_a = get_dir(B,A)

	if(!A.connections) A.connections = new
	if(!B.connections) B.connections = new

	if(A.connections.get(a_to_b))
		return
	if(B.connections.get(b_to_a))
		return
	if(!space)
		if(A.zone == B.zone) return


	var/connection/c = new /connection(A,B)

	A.connections.place(c, a_to_b)
	B.connections.place(c, b_to_a)

	if(direct) c.mark_direct()

/datum/controller/subsystem/zas/proc/mark_for_update(turf/T)
	#ifdef ZASDBG
	ASSERT(isturf(T))
	#endif
	if(T.needs_air_update)
		return
	tiles_to_update += T
	#ifdef ZASDBG
	T.vis_contents += zasdbgovl_mark
	#endif
	T.needs_air_update = 1

/datum/controller/subsystem/zas/proc/mark_zone_update(zone/Z)
	#ifdef ZASDBG
	ASSERT(istype(Z))
	#endif
	if(Z.needs_update)
		return
	zones_to_update += Z
	Z.needs_update = 1

/datum/controller/subsystem/zas/proc/mark_edge_sleeping(connection_edge/E)
	#ifdef ZASDBG
	ASSERT(istype(E))
	#endif
	if(E.sleeping)
		return
	active_edges -= E
	E.sleeping = 1

/datum/controller/subsystem/zas/proc/mark_edge_active(connection_edge/E)
	#ifdef ZASDBG
	ASSERT(istype(E))
	#endif
	if(!E.sleeping)
		return
	active_edges += E
	E.sleeping = 0

/datum/controller/subsystem/zas/proc/equivalent_pressure(zone/A, zone/B)
	return A.air.compare(B.air)

/datum/controller/subsystem/zas/proc/get_edge(zone/A, zone/B)
	if(istype(B))
		for(var/connection_edge/zone/edge in A.edges)
			if(edge.contains_zone(B))
				return edge
		var/connection_edge/edge = new/connection_edge/zone(A,B)
		edges += edge
		edge.recheck()
		return edge
	else
		for(var/connection_edge/unsimulated/edge in A.edges)
			if(has_same_air(edge.B,B))
				return edge
		var/connection_edge/edge = new/connection_edge/unsimulated(A,B)
		edges += edge
		edge.recheck()
		return edge

/datum/controller/subsystem/zas/proc/has_same_air(turf/A, turf/B)
	if(A.initial_gas)
		if(!B.initial_gas)
			return 0
		for(var/g in A.initial_gas)
			if(A.initial_gas[g] != B.initial_gas[g])
				return 0
	if(B.initial_gas)
		if(!A.initial_gas)
			return 0
		for(var/g in B.initial_gas)
			if(A.initial_gas[g] != B.initial_gas[g])
				return 0
	if(A.temperature != B.temperature)
		return 0
	return 1

/datum/controller/subsystem/zas/proc/remove_edge(connection_edge/E)
	edges -= E
	if(!E.sleeping)
		active_edges -= E
	if(processing_edges)
		processing_edges -= E

/datum/controller/subsystem/zas/proc/fuck_lavaland()
	var/list/restricted_gases = list()
	///No funny gasses allowed
	for(var/gas in xgm_gas_data.gases)
		if(xgm_gas_data.flags[gas] & (XGM_GAS_CONTAMINANT|XGM_GAS_FUEL|XGM_GAS_OXIDIZER))
			restricted_gases |= gas

	var/list/viable_gases = GLOB.all_gases - restricted_gases - GAS_XENON //TODO: add XGM_GAS_DANGEROUS
	var/datum/gas_mixture/mix_real = new
	var/list/mix_list = list()
	var/num_gases = rand(1, 3)
	var/list/chosen_gases = list()
	var/target_pressure = rand(HAZARD_LOW_PRESSURE + 10, LAVALAND_EQUIPMENT_EFFECT_PRESSURE - 1)
	var/temp = rand(BODYTEMP_COLD_DAMAGE_LIMIT + 1, 350)
	var/pressure_scalar = target_pressure / (LAVALAND_EQUIPMENT_EFFECT_PRESSURE - 1)

	///Choose our gases
	for(var/iter in 1 to num_gases)
		chosen_gases += pick_n_take(viable_gases)

	mix_real.gas = chosen_gases
	for(var/gas in mix_real.gas)
		mix_real.gas[gas] = 1 //So update values doesn't cull it

	mix_real.temperature = temp

	///This is where the fun begins...
	var/amount
	var/gastype
	while(mix_real.return_pressure() < target_pressure)
		gastype = pick(chosen_gases)

		amount = rand(5,10)
		amount *= rand(50, 200) / 100
		amount *= pressure_scalar
		amount = CEILING(amount, 0.1)

		mix_real.gas[gastype] += amount
		mix_real.update_values()

	while(mix_real.return_pressure() > target_pressure)
		mix_real.gas[gastype] -= mix_real.gas[gastype] * 0.1
		mix_real.update_values()

	mix_real.gas[gastype] = FLOOR(mix_real.gas[gastype], 0.1)

	for(var/gas_id in mix_real.gas)
		mix_list[gas_id] = mix_real.gas[gas_id]

	var/list/lavaland_z_levels = SSmapping.levels_by_trait(ZTRAIT_MINING) //God I hope this is never more than one
	for(var/zlev in lavaland_z_levels)
		for(var/turf/T in block(locate(1,1,zlev), locate(world.maxx, world.maxy, zlev)))
			if(!T.simulated)
				T.initial_gas = mix_list
				T.temperature = mix_real.temperature
			CHECK_TICK

	lavaland_atmos = mix_real
	to_chat(world, span_boldannounce("ZAS: Lavaland contains [num_gases] [num_gases > 1? "gases" : "gas"], with a pressure of [mix_real.return_pressure()] kpa."))
