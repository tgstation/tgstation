/*

Overview:
	Each zone is a self-contained area where gas values would be the same if tile-based equalization were run indefinitely.
	If you're unfamiliar with ZAS, FEA's air groups would have similar functionality if they didn't break in a stiff breeze.

Class Vars:
	name - A name of the format "Zone [#]", used for debugging.
	invalid - True if the zone has been erased and is no longer eligible for processing.
	needs_update - True if the zone has been added to the update list.
	edges - A list of edges that connect to this zone.
	air - The gas mixture that any turfs in this zone will return. Values are per-tile with a group multiplier.

Class Procs:
	add(turf/simulated/T)
		Adds a turf to the contents, sets its zone and merges its air.

	remove(turf/simulated/T)
		Removes a turf, sets its zone to null and erases any gas graphics.
		Invalidates the zone if it has no more tiles.

	c_merge(zone/into)
		Invalidates this zone and adds all its former contents to into.

	c_invalidate()
		Marks this zone as invalid and removes it from processing.

	rebuild()
		Invalidates the zone and marks all its former tiles for updates.

	add_tile_air(turf/simulated/T)
		Adds the air contained in T.air to the zone's air supply. Called when adding a turf.

	tick()
		Called only when the gas content is changed. Archives values and changes gas graphics.

	dbg_data(mob/M)
		Sends M a printout of important figures for the zone.

*/


/zone
	var/name
	var/invalid = 0
	var/list/contents = list()
	var/needs_update = 0
	var/list/edges = list()
	var/datum/gas_mixture/air = new

/zone/New()
	air_master.add_zone(src)
	air.temperature = TCMB
	air.group_multiplier = 1
	air.volume = CELL_VOLUME

/zone/proc/add(turf/simulated/T)
#ifdef ZASDBG
	ASSERT(!invalid)
	ASSERT(istype(T))
	ASSERT(!air_master.has_valid_zone(T))
#endif

	var/datum/gas_mixture/turf_air = T.return_air()
	add_tile_air(turf_air)
	T.zone = src
	contents.Add(T)
	T.set_graphic(air.graphics)

/zone/proc/remove(turf/simulated/T)
#ifdef ZASDBG
	ASSERT(!invalid)
	ASSERT(istype(T))
	ASSERT(T.zone == src)
	soft_assert(T in contents, "Lists are weird broseph")
#endif
	contents.Remove(T)
	T.zone = null
	T.set_graphic(0)
	if(contents.len)
		air.group_multiplier = contents.len
	else
		c_invalidate()

/zone/proc/c_merge(zone/into)
#ifdef ZASDBG
	ASSERT(!invalid)
	ASSERT(istype(into))
	ASSERT(into != src)
	ASSERT(!into.invalid)
#endif
	c_invalidate()
	for(var/turf/simulated/T in contents)
		into.add(T)
		#ifdef ZASDBG
		T.dbg(merged)
		#endif

/zone/proc/c_invalidate()
	invalid = 1
	air_master.remove_zone(src)
	#ifdef ZASDBG
	for(var/turf/simulated/T in contents)
		T.dbg(invalid_zone)
	#endif

/zone/proc/rebuild()
	if(invalid) return //Short circuit for explosions where rebuild is called many times over.
	c_invalidate()
	for(var/turf/simulated/T in contents)
		//T.dbg(invalid_zone)
		T.needs_air_update = 0 //Reset the marker so that it will be added to the list.
		air_master.mark_for_update(T)

/zone/proc/add_tile_air(datum/gas_mixture/tile_air)
	//air.volume += CELL_VOLUME
	air.group_multiplier = 1
	air.multiply(contents.len)
	air.merge(tile_air)
	air.divide(contents.len+1)
	air.group_multiplier = contents.len+1

/zone/proc/tick()
	air.archive()
	if(air.check_tile_graphic())
		for(var/turf/simulated/T in contents)
			T.set_graphic(air.graphics)

/zone/proc/dbg_data(mob/M)
	M << name
	M << "O2: [air.oxygen] N2: [air.nitrogen] CO2: [air.carbon_dioxide] P: [air.toxins]"
	M << "P: [air.return_pressure()] kPa V: [air.volume]L T: [air.temperature]°K ([air.temperature - T0C]°C)"
	M << "O2 per N2: [(air.nitrogen ? air.oxygen/air.nitrogen : "N/A")] Moles: [air.total_moles]"
	M << "Simulated: [contents.len] ([air.group_multiplier])"
	//M << "Unsimulated: [unsimulated_contents.len]"
	//M << "Edges: [edges.len]"
	if(invalid) M << "Invalid!"
	var/zone_edges = 0
	var/space_edges = 0
	var/space_coefficient = 0
	for(var/connection_edge/E in edges)
		if(E.type == /connection_edge/zone) zone_edges++
		else
			space_edges++
			space_coefficient += E.coefficient
			M << "[E:air:return_pressure()]kPa"

	M << "Zone Edges: [zone_edges]"
	M << "Space Edges: [space_edges] ([space_coefficient] connections)"

	//for(var/turf/T in unsimulated_contents)
	//	M << "[T] at ([T.x],[T.y])"