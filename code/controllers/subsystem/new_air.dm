var/datum/subsystem/air/SSair

/datum/subsystem/air
	name = "Air"
	priority = 20
	wait = 10
	dynamic_wait = 1
	dwait_lower = 10
	dwait_upper = 50

	var/cost_turfs = 0
	var/cost_edges = 0
//	var/cost_highpressure = 0
	var/cost_hotspots = 0
	var/cost_zones = 0
	var/cost_pipenets = 0
	var/cost_atmos_machinery = 0

	var/obj/effect/overlay/plasma_overlay			//overlay for plasma
	var/obj/effect/overlay/sleeptoxin_overlay		//overlay for sleeptoxin

//	var/list/excited_groups = list()
//	var/list/active_turfs = list()
//	var/list/hotspots = list()
	var/list/networks = list()
	var/list/obj/machinery/atmos_machinery = list()


	//Special functions lists
//	var/list/turf/simulated/active_super_conductivity = list()
//	var/list/turf/simulated/high_pressure_delta = list()


//Geometry lists
	var/list/zones = list()
	var/list/edges = list()

//Geometry updates lists
	var/list/tiles_to_update = list()
	var/list/zones_to_update = list()
	var/list/active_hotspots = list()
	var/active_zones = 0
	var/next_id = 1 //Used to keep track of zone UIDs.
	var/tick_progress = 0


/datum/subsystem/air/New()
	NEW_SS_GLOBAL(SSair)

	plasma_overlay	= new /obj/effect/overlay{icon='icons/effects/tile_effects.dmi';mouse_opacity=0;layer=5;icon_state="plasma"}()
	sleeptoxin_overlay	= new /obj/effect/overlay{icon='icons/effects/tile_effects.dmi';mouse_opacity=0;layer=5;icon_state="sleeping_agent"}()


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


/datum/subsystem/air/stat_entry(msg)
	msg += "C:{"
	msg += "AT:[round(cost_turfs,0.01)]|"
	msg += "EG:[round(cost_edges,0.01)]|"
	msg += "HS:[round(cost_hotspots,0.01)]|"
	msg += "ZN:[round(cost_zones,0.01)]|"
	msg += "PN:[round(cost_pipenets,0.01)]|"
	msg += "AM:[round(cost_atmos_machinery,0.01)]"
	msg += "} "
	msg +=  "AT:[tiles_to_update.len]|"
	msg +=  "EG:[edges.len]|"
	msg +=  "HS:[active_hotspots.len]|"
	msg +=  "ZN:[zones.len]"
	..(msg)


/datum/subsystem/air/Initialize(timeofday, zlevel)
	setup_allturfs(zlevel)
	setup_atmos_machinery(zlevel)
	..()

/datum/subsystem/air/AfterInitialize(zlevel)

#define MC_AVERAGE(average, current) (0.8*(average) + 0.2*(current))
/datum/subsystem/air/fire()
	var/timer = world.timeofday
	process_pipenets()
	cost_pipenets = MC_AVERAGE(cost_pipenets, (world.timeofday - timer))

	timer = world.timeofday
	process_atmos_machinery()
	cost_atmos_machinery = MC_AVERAGE(cost_atmos_machinery, (world.timeofday - timer))

	timer = world.timeofday
	process_turfs()
	cost_turfs = MC_AVERAGE(cost_turfs, (world.timeofday - timer))

	timer = world.timeofday
	process_edges()
	cost_edges = MC_AVERAGE(cost_edges, (world.timeofday - timer))

//	timer = world.timeofday
//	process_high_pressure_delta()
//	cost_highpressure = MC_AVERAGE(cost_highpressure, (world.timeofday - timer))

	timer = world.timeofday
	process_hotspots()
	cost_hotspots = MC_AVERAGE(cost_hotspots, (world.timeofday - timer))

	timer = world.timeofday
	process_zones()
	cost_zones = MC_AVERAGE(cost_zones, (world.timeofday - timer))


#undef MC_AVERAGE



/datum/subsystem/air/proc/process_pipenets()
	var/i=1
	for(var/thing in networks)
		if(thing)
			thing:process()
			++i
			continue
		networks.Cut(i, i+1)


/datum/subsystem/air/proc/process_atmos_machinery()
	var/seconds = wait * 0.1
	for(var/obj/machinery/M in atmos_machinery)
		if(M && (M.process_atmos(seconds) != PROCESS_KILL))
			continue
		atmos_machinery.Remove(M)


/datum/subsystem/air/proc/process_edges()
	for(var/connection_edge/edge in edges)
		edge.tick()



/datum/subsystem/air/proc/process_hotspots()
	for(var/obj/fire/fire in active_hotspots)
		fire.process()

/*
/datum/subsystem/air/proc/process_high_pressure_delta()
	for(var/turf/T in high_pressure_delta)
		T.high_pressure_movements()
		T.pressure_difference = 0
	high_pressure_delta.len = 0
*/

/datum/subsystem/air/proc/process_turfs()
	if(tiles_to_update.len)
		for(var/turf/T in tiles_to_update)
			T.update_air()
			T.needs_air_update = 0
			#ifdef ZASDBG
			T.overlays -= mark
			#endif
			tiles_to_update.Remove(T)



/datum/subsystem/air/proc/process_zones()
	if(zones_to_update.len)
		for(var/zone/zone in zones_to_update)
			zone.tick()
			zone.needs_update = 0
			zones_to_update.Remove(zone)


/datum/subsystem/air/proc/setup_allturfs(z_level)
	tiles_to_update.Cut()
	var/z_start = 1
	var/z_finish = world.maxz
	if(1 <= z_level && z_level <= world.maxz)
		z_level = round(z_level)
		z_start = z_level
		z_finish = z_level

	var/list/turfs_to_init = block(locate(1, 1, z_start), locate(world.maxx, world.maxy, z_finish))


	for(var/turf/simulated/S in turfs_to_init)
		S.update_air_properties()

/datum/subsystem/air/proc/setup_atmos_machinery(z_level)
	for (var/obj/machinery/atmospherics/AM in atmos_machinery)
		if (z_level && AM.z != z_level)
			continue
		AM.atmosinit()



/datum/subsystem/air/proc/add_zone(zone/z)
	zones.Add(z)
	z.name = "Zone [next_id++]"
	mark_zone_update(z)

/datum/subsystem/air/proc/remove_zone(zone/z)
	zones.Remove(z)

/datum/subsystem/air/proc/air_blocked(turf/A, turf/B)
	#ifdef ZASDBG
	ASSERT(isturf(A))
	ASSERT(isturf(B))
	#endif
	var/ablock = A.c_airblock(B)
	if(ablock == BLOCKED) return BLOCKED
	return ablock | B.c_airblock(A)

/datum/subsystem/air/proc/has_valid_zone(turf/simulated/T)
	#ifdef ZASDBG
	ASSERT(istype(T))
	#endif
	return istype(T) && T.zone && !T.zone.invalid

/datum/subsystem/air/proc/merge(zone/A, zone/B)
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

/datum/subsystem/air/proc/connect(turf/simulated/A, turf/simulated/B)
	#ifdef ZASDBG
	ASSERT(istype(A))
	ASSERT(isturf(B))
	ASSERT(A.zone)
	ASSERT(!A.zone.invalid)
	//ASSERT(B.zone)
	ASSERT(A != B)
	#endif

	var/block = SSair.air_blocked(A,B)
	if(block & AIR_BLOCKED) return

	var/direct = !(block & ZONE_BLOCKED)
	var/space = (!istype(B))

	if(direct && !space)
		if(equivalent_pressure(A.zone,B.zone))
			merge(A.zone,B.zone)
			return

	var
		a_to_b = get_dir(A,B)
		b_to_a = get_dir(B,A)

	if(!A.connections) A.connections = new
	if(!B.connections) B.connections = new

	if(A.connections.get(a_to_b)) return
	if(B.connections.get(b_to_a)) return
	if(!space)
		if(A.zone == B.zone) return


	var/connection/c = new /connection(A,B)

	A.connections.place(c, a_to_b)
	B.connections.place(c, b_to_a)

	if(direct) c.mark_direct()

/datum/subsystem/air/proc/mark_for_update(turf/T)
	#ifdef ZASDBG
	ASSERT(isturf(T))
	#endif
//	if(T.needs_air_update) return
	tiles_to_update |= T
	#ifdef ZASDBG
	T.overlays += mark
	#endif
	T.needs_air_update = 1

/datum/subsystem/air/proc/mark_zone_update(zone/Z)
	#ifdef ZASDBG
	ASSERT(istype(Z))
	#endif
	if(Z.needs_update) return
	zones_to_update.Add(Z)
	Z.needs_update = 1

/datum/subsystem/air/proc/equivalent_pressure(zone/A, zone/B)
	return A.air.compare(B.air)

/datum/subsystem/air/proc/get_edge(zone/A, zone/B)

	if(istype(B))
		for(var/connection_edge/zone/edge in A.edges)
			if(edge.contains_zone(B)) return edge
		var/connection_edge/edge = new/connection_edge/zone(A,B)
		edges.Add(edge)
		return edge
	else
		for(var/connection_edge/unsimulated/edge in A.edges)
			if(has_same_air(edge.B,B)) return edge
		var/connection_edge/edge = new/connection_edge/unsimulated(A,B)
		edges.Add(edge)
		return edge

/datum/subsystem/air/proc/has_same_air(turf/A, turf/B)
	if(A.oxygen != B.oxygen) return 0
	if(A.nitrogen != B.nitrogen) return 0
	if(A.toxins != B.toxins) return 0
	if(A.carbon_dioxide != B.carbon_dioxide) return 0
	if(A.temperature != B.temperature) return 0
	return 1

/datum/subsystem/air/proc/remove_edge(connection/c)
	edges.Remove(c)