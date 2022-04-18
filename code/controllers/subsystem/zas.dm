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
	name = "ZAS"
	priority = FIRE_PRIORITY_AIR
	init_order = INIT_ORDER_AIR
	flags = SS_POST_FIRE_TIMING

	//The variable setting controller
	var/datum/zas_controller/settings
	//A reference to the global var
	var/datum/xgm_gas_data/gas_data = xgm_gas_data

	//Geometry lists
	var/list/zones = list()
	var/list/edges = list()

	//Pipenets
	var/list/networks = list()
	var/list/rebuild_queue = list()
	var/list/expansion_queue = list()
	var/list/pipe_init_dirs_cache = list()

	//Atmos Machines
	var/list/atmos_machinery = list()
	//Atoms to be processed
	var/list/atom_process = list()

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

	//Currently processing
	var/list/curr_tiles
	var/list/curr_defer
	var/list/curr_edges
	var/list/curr_fire
	var/list/curr_hotspot
	var/list/curr_zones
	var/list/curr_machines
	var/list/curr_atoms


	var/current_process = SSZAS_TILES
	var/active_zones = 0
	var/next_id = 1

/datum/controller/subsystem/zas/proc/Reboot()
	// Stop processing while we rebuild.
	can_fire = FALSE

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
		msg += "TtU: [length(tiles_to_update)]"
		msg += "ZtU: [length(zones_to_update)]"
		msg += "AFZ: [length(active_fire_zones)]"
		msg += "AH: [length(active_hotspots)]"
		msg += "AE: [length(active_edges)]"
	return ..()

/datum/controller/subsystem/zas/Initialize(timeofday, simulate = TRUE)

	var/starttime = REALTIMEOFDAY
	settings = new
	gas_data = new

	to_chat(world, span_boldannounce("Processing Geometry..."))

	var/simulated_turf_count = 0
	//for(var/turf/simulated/S) ZASTURF
	for(var/turf/S)
		if(istype(S, /turf/open/space))
			continue
		simulated_turf_count++
		S.update_air_properties()

		CHECK_TICK

	to_chat(world, span_boldannounce("Total Simulated Turfs: [simulated_turf_count]\nTotal Zones: [zones.len]\nTotal Edges: [edges.len]\nTotal Active Edges: [active_edges.len ? "<span class='danger'>[active_edges.len]</span>" : "None"]\nTotal Unsimulated Turfs: [world.maxx*world.maxy*world.maxz - simulated_turf_count]"))

	to_chat(world, span_boldannounce("Geometry processing completed in [(REALTIMEOFDAY - starttime)/10] seconds!"))

	if (simulate)
		to_chat(world, span_boldannounce("Settling air..."))

		starttime = REALTIMEOFDAY
		fire(FALSE, TRUE)

		to_chat(world, span_boldannounce("Air settling completed in [(REALTIMEOFDAY - starttime)/10] seconds!"))

	..(timeofday)

/datum/controller/subsystem/zas/fire(resumed = FALSE)
	if (!resumed)
		processing_edges = active_edges.Copy()
		processing_fires = active_fire_zones.Copy()
		processing_hotspots = active_hotspots.Copy()


	curr_machines = atmos_machinery
	if(current_process == SSZAS_MACHINES)
		while (curr_machines.len)
			var/obj/machinery/atmospherics/current_machine = curr_machines[curr_machines.len]
			curr_machines.len--

			if(!current_machine)
				atmos_machinery -= current_machine
			if(current_machine.process_atmos() == PROCESS_KILL)
				stop_processing_machine(current_machine)

			if(MC_TICK_CHECK)
				return

	current_process = SSZAS_TILES
	curr_tiles = tiles_to_update
	if(current_process == SSZAS_TILES || !resumed)
		while (curr_tiles.len)
			var/turf/T = curr_tiles[curr_tiles.len]
			curr_tiles.len--

			if (!T)
				if (MC_TICK_CHECK)
					return
				continue

			//check if the turf is self-zone-blocked
			var/c_airblock
			ATMOS_CANPASS_TURF(c_airblock, T, T)
			if(c_airblock & ZONE_BLOCKED)
				deferred += T
				if (MC_TICK_CHECK)
					return
				continue

			T.update_air_properties()
			T.post_update_air_properties()
			T.needs_air_update = 0
			#ifdef ZASDBG
			T.overlays -= mark
			updated++
			#endif

			if (MC_TICK_CHECK)
				return

	current_process = SSZAS_DEFERED_TILES
	curr_defer = deferred
	if(current_process == SSZAS_DEFERED_TILES)
		while (curr_defer.len)
			var/turf/T = curr_defer[curr_defer.len]
			curr_defer.len--

			T.update_air_properties()
			T.post_update_air_properties()
			T.needs_air_update = 0
			#ifdef ZASDBG
			T.overlays -= mark
			updated++
			#endif

			if (MC_TICK_CHECK)
				return

	current_process = SSZAS_EDGES
	curr_edges = processing_edges
	if(current_process == SSZAS_EDGES)
		while (curr_edges.len)
			var/connection_edge/edge = curr_edges[curr_edges.len]
			curr_edges.len--

			if (!edge)
				if (MC_TICK_CHECK)
					return
				continue

			edge.tick()
			if (MC_TICK_CHECK)
				return

	current_process = SSZAS_FIRES
	curr_fire = processing_fires
	if(current_process == SSZAS_FIRES)
		while (curr_fire.len)
			var/zone/Z = curr_fire[curr_fire.len]
			curr_fire.len--

			Z.process_fire()

			if (MC_TICK_CHECK)
				return

	current_process = SSZAS_HOTSPOTS
	curr_hotspot = processing_hotspots
	if(current_process == SSZAS_HOTSPOTS)
		while (curr_hotspot.len)
			var/obj/effect/hotspot/F = curr_hotspot[curr_hotspot.len]
			curr_hotspot.len--

			F.Process()

			if (MC_TICK_CHECK)
				return

	current_process = SSZAS_ZONES
	curr_zones = processing_zones
	if(current_process == SSZAS_ZONES)
		while (curr_zones.len)
			var/zone/Z = curr_zones[curr_zones.len]
			curr_zones.len--

			Z.tick()
			Z.needs_update = FALSE

			if (MC_TICK_CHECK)
				return

	current_process = SSZAS_ATOMS
	curr_atoms = atom_process
	if(current_process == SSZAS_ATOMS)
		while(curr_atoms.len)
		var/atom/talk_to = curr_atoms[curr_atoms.len]
		curr_atoms.len--
		if(!talk_to)
			return
		talk_to.process_exposure()
		if(MC_TICK_CHECK)
			return

	current_process = SSZAS_MACHINES

/**
 * Adds a given machine to the processing system for SSAIR_ATMOSMACHINERY processing.
 *
 * Arguments:
 * * machine - The machine to start processing. Can be any /obj/machinery.
 */
/datum/controller/subsystem/zas/proc/start_processing_machine(obj/machinery/machine)
	if(machine.atmos_processing)
		return
	if(QDELETED(machine))
		stack_trace("We tried to add a garbage collecting machine to SSzas. Don't")
		return
	machine.atmos_processing = TRUE
	atmos_machinery += machine

/**
 * Removes a given machine to the processing system for SSZAS_MACHINES processing.
 *
 * Arguments:
 * * machine - The machine to stop processing.
 */
/datum/controller/subsystem/zas/proc/stop_processing_machine(obj/machinery/machine)
	if(!machine.atmos_processing)
		return
	machine.atmos_processing = FALSE
	atmos_machinery -= machine

	// If we're currently processing atmos machines, there's a chance this machine is in
	// the currentrun list, which is a cache of atmos_machinery. Remove it from that list
	// as well to prevent processing qdeleted objects in the cache.
	if(current_process == SSZAS_MACHINES)
		curr_machines -= machine

/datum/controller/subsystem/zas/proc/add_to_rebuild_queue(obj/machinery/atmospherics/atmos_machine)
	if(istype(atmos_machine, /obj/machinery/atmospherics) && !atmos_machine.rebuilding)
		rebuild_queue += atmos_machine
		atmos_machine.rebuilding = TRUE

/datum/controller/subsystem/zas/proc/add_to_expansion(datum/pipeline/line, starting_point)
	var/list/new_packet = new(SSAIR_REBUILD_QUEUE)
	new_packet[SSZAS_REBUILD_PIPELINE] = line
	new_packet[SSZAS_REBUILD_QUEUE] = list(starting_point)
	expansion_queue += list(new_packet)

/datum/controller/subsystem/zas/proc/remove_from_expansion(datum/pipeline/line)
	for(var/list/packet in expansion_queue)
		if(packet[SSZAS_REBUILD_PIPELINE] == line)
			expansion_queue -= packet
			return

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
	ASSERT(istype(A))
	ASSERT(isturf(B))
	ASSERT(A.zone)
	ASSERT(!A.zone.invalid)
	//ASSERT(B.zone)
	ASSERT(A != B)
	#endif

	var/block = air_blocked(A,B)
	if(block & AIR_BLOCKED) return

	var/direct = !(block & ZONE_BLOCKED)
	var/space = istype(B, /turf/open/space)

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
	T.overlays += mark
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

/datum/controller/subsystem/zas/proc/get_init_dirs(type, dir, init_dir)

	if(!pipe_init_dirs_cache[type])
		pipe_init_dirs_cache[type] = list()

	if(!pipe_init_dirs_cache[type]["[init_dir]"])
		pipe_init_dirs_cache[type]["[init_dir]"] = list()

	if(!pipe_init_dirs_cache[type]["[init_dir]"]["[dir]"])
		var/obj/machinery/atmospherics/temp = new type(null, FALSE, dir, init_dir)
		pipe_init_dirs_cache[type]["[init_dir]"]["[dir]"] = temp.get_init_directions()
		qdel(temp)

	return pipe_init_dirs_cache[type]["[init_dir]"]["[dir]"]

/datum/controller/subsystem/zas/proc/setup_template_machinery(list/atmos_machines)
	var/obj/machinery/atmospherics/AM
	for(var/A in 1 to atmos_machines.len)
		AM = atmos_machines[A]
		AM.atmos_init()
		CHECK_TICK

	for(var/A in 1 to atmos_machines.len)
		AM = atmos_machines[A]
		var/list/targets = AM.get_rebuild_targets()
		for(var/datum/pipeline/build_off as anything in targets)
			build_off.build_pipeline_blocking(AM)
		CHECK_TICK
