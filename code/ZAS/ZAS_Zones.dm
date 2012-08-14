var/list/zones = list()
var/list/DoorDirections = list(NORTH,WEST) //Which directions doors turfs can connect to zones
var/list/CounterDoorDirections = list(SOUTH,EAST) //Which directions doors turfs can connect to zones

zone

	var
		dbg_output = 0 //Enables debug output.
		rebuild = 0 //If 1, zone will be rebuilt on next process. Not sure if used.
		datum/gas_mixture/air //The air contents of the zone.
		list/contents //All the tiles that are contained in this zone.
		list/connections // /connection objects which refer to connections with other zones, e.g. through a door.
		list/connected_zones //Parallels connections, but lists zones to which this one is connected and the number
							//of points they're connected at.
		list/unsimulated_tiles // Any space tiles in this list will cause air to flow out.
		last_update = 0
		progress = "nothing"

//CREATION AND DELETION
	New(turf/start)
		. = ..()
		//Get the turfs that are part of the zone using a floodfill method
		if(istype(start,/list))
			contents = start
		else
			contents = FloodFill(start)

		//Change all the zone vars of the turfs, check for space to be added to unsimulated_tiles.
		for(var/turf/T in contents)
			if(T.zone && T.zone != src)
				T.zone.RemoveTurf(T)
			T.zone = src
			if(!istype(T,/turf/simulated))
				AddTurf(T)

		//Generate the gas_mixture for use in this zone by using the average of the gases
		//defined at startup.
		air = new
		var/members = contents.len
		for(var/turf/simulated/T in contents)
			air.oxygen += T.oxygen / members
			air.nitrogen += T.nitrogen / members
			air.carbon_dioxide += T.carbon_dioxide / members
			air.toxins += T.toxins / members
			air.temperature += T.temperature / members
		air.group_multiplier = contents.len
		air.update_values()

		//Add this zone to the global list.
		zones.Add(src)

	//LEGACY, DO NOT USE.  Use the SoftDelete proc.
	Del()
		//Ensuring the zone list doesn't get clogged with null values.
		for(var/turf/simulated/T in contents)
			RemoveTurf(T)
			air_master.tiles_to_reconsider_zones += T
		for(var/zone/Z in connected_zones)
			if(src in Z.connected_zones)
				Z.connected_zones.Remove(src)
		for(var/connection/C in connections)
			air_master.connections_to_check += C
		zones.Remove(src)
		air = null
		. = ..()

	//Handles deletion via garbage collection.
	proc/SoftDelete()
		zones.Remove(src)
		air = null
		//Ensuring the zone list doesn't get clogged with null values.
		for(var/turf/simulated/T in contents)
			RemoveTurf(T)
			air_master.tiles_to_reconsider_zones += T
		for(var/zone/Z in connected_zones)
			if(src in Z.connected_zones)
				Z.connected_zones.Remove(src)
		for(var/connection/C in connections)
			if(C.zone_A == src)
				C.zone_A = null
			if(C.zone_B == src)
				C.zone_B = null
			air_master.connections_to_check += C
		return 1

//ZONE MANAGEMENT FUNCTIONS
	proc/AddTurf(turf/T)
		//Adds the turf to contents, increases the size of the zone, and sets the zone var.
		if(istype(T, /turf/simulated))
			if(T in contents)
				return
			if(T.zone)
				T.zone.RemoveTurf(T)
			contents += T
			if(air)
				air.group_multiplier++
			T.zone = src
		else
			if(!unsimulated_tiles)
				unsimulated_tiles = list()
			else if(T in unsimulated_tiles)
				return
			unsimulated_tiles += T
			contents -= T

	proc/RemoveTurf(turf/T)
		//Same, but in reverse.
		if(istype(T, /turf/simulated))
			if(!(T in contents))
				return
			contents -= T
			if(air)
				air.group_multiplier--
			if(T.zone == src)
				T.zone = null
		else if(unsimulated_tiles)
			unsimulated_tiles -= T
			if(!unsimulated_tiles.len)
				unsimulated_tiles = null

  //////////////
 //PROCESSING//
//////////////

#define QUANTIZE(variable)		(round(variable,0.0001))

zone/proc/process()
	. = 1

	progress = "problem with: SoftDelete()"

	//Deletes zone if empty.
	if(!contents.len)
		return SoftDelete()

	progress = "problem with: Rebuild()"

	//Does rebuilding stuff.
	if(rebuild)
		rebuild = 0
		Rebuild() //Shoving this into a proc.

	if(!contents.len) //If we got soft deleted.
		return

	progress = "problem with: air.adjust()"

	//Sometimes explosions will cause the air to be deleted for some reason.
	if(!air)
		air = new()
		air.adjust(MOLES_O2STANDARD, 0, MOLES_N2STANDARD, 0, list())
		air.temperature = T0C
		world.log << "Air object lost in zone. Regenerating."

	progress = "problem with: ShareSpace()"


	if(unsimulated_tiles)
		if(locate(/turf/simulated) in unsimulated_tiles)
			for(var/turf/simulated/T in unsimulated_tiles)
				RemoveTurf(T)
		if(unsimulated_tiles)
			var/moved_air = ShareSpace(air,unsimulated_tiles)
			if(moved_air > vsc.airflow_lightest_pressure)
				AirflowSpace(src)

	progress = "problem with: air.react()"

	//React the air here.
	air.react(null,0)

	//Check the graphic.

	progress = "problem with: modifying turf graphics"

	air.graphic = 0
	if(air.toxins > MOLES_PLASMA_VISIBLE)
		air.graphic = 1
	else if(air.trace_gases.len)
		var/datum/gas/sleeping_agent = locate(/datum/gas/sleeping_agent) in air.trace_gases
		if(sleeping_agent && (sleeping_agent.moles > 1))
			air.graphic = 2

	progress = "problem with an inbuilt byond function: some conditional checks"

	//Only run through the individual turfs if there's reason to.
	if(air.graphic != air.graphic_archived || air.temperature > FIRE_MINIMUM_TEMPERATURE_TO_EXIST)

		progress = "problem with: turf/simulated/update_visuals()"

		for(var/turf/simulated/S in contents)
			//Update overlays.
			if(air.graphic != air.graphic_archived)
				if(S.HasDoor(1))
					S.update_visuals()
				else
					S.update_visuals(air)

			progress = "problem with: item or turf temperature_expose()"

			//Expose stuff to extreme heat.
			if(air.temperature > FIRE_MINIMUM_TEMPERATURE_TO_EXIST)
				for(var/atom/movable/item in S)
					item.temperature_expose(air, air.temperature, CELL_VOLUME)
				S.temperature_expose(air, air.temperature, CELL_VOLUME)

	progress = "problem with: calculating air graphic"

	//Archive graphic so we can know if it's different.
	air.graphic_archived = air.graphic

	progress = "problem with: calculating air temp"

	//Ensure temperature does not reach absolute zero.
	air.temperature = max(TCMB,air.temperature)

	progress = "problem with an inbuilt byond function: length(connections)"

	//Handle connections to other zones.
	if(length(connections))

		progress = "problem with: ZMerge(), a couple of misc procs"

		for(var/connection/C in connections)
			//Check if the connection is valid first.
			if(!C.Cleanup())
				continue
			//Do merging if conditions are met. Specifically, if there's a non-door connection
			//to somewhere with space, the zones are merged regardless of equilibrium, to speed
			//up spacing in areas with double-plated windows.
			if(C && C.indirect == 2 && C.A.zone && C.B.zone) //indirect = 2 is a direct connection.
				if(C.A.zone.air.compare(C.B.zone.air) || unsimulated_tiles)
					ZMerge(C.A.zone,C.B.zone)

		progress = "problem with: ShareRatio(), Airflow(), a couple of misc procs"

		//Share some
		for(var/zone/Z in connected_zones)
			if(air && Z.air)
				//Ensure we're not doing pointless calculations on equilibrium zones.
				if(abs(air.total_moles - Z.air.total_moles) > 0.1 || abs(air.temperature - Z.air.temperature) > 0.1)
					if(abs(Z.air.return_pressure() - air.return_pressure()) > vsc.airflow_lightest_pressure)
						Airflow(src,Z)
					ShareRatio( air , Z.air , connected_zones[Z] )

	progress = "all components completed successfully, the problem is not here"

  ////////////////
 //Air Movement//
////////////////

var/list/sharing_lookup_table = list(0.06, 0.11, 0.15, 0.18, 0.20, 0.21)

proc/ShareRatio(datum/gas_mixture/A, datum/gas_mixture/B, connecting_tiles)
	//Shares a specific ratio of gas between mixtures using simple weighted averages.
	var
		ratio = 0.21

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

	if(sharing_lookup_table.len >= connecting_tiles) //6 or more interconnecting tiles will max at 42% of air moved per tick.
		ratio = sharing_lookup_table[connecting_tiles]

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

	A.update_values()
	B.update_values()

	if(A.compare(B)) return 1
	else return 0

proc/ShareSpace(datum/gas_mixture/A, list/unsimulated_tiles)
	//A modified version of ShareRatio for spacing gas at the same rate as if it were going into a large airless room.
	if(!unsimulated_tiles || !unsimulated_tiles.len)
		return 0

	var
		unsim_oxygen = 0
		unsim_nitrogen = 0
		unsim_co2 = 0
		unsim_plasma = 0
		unsim_heat_capacity = 0
		unsim_temperature = 0
	for(var/turf/T in unsimulated_tiles)
		unsim_oxygen += T.oxygen
		unsim_co2 += T.carbon_dioxide
		unsim_nitrogen += T.nitrogen
		unsim_plasma += T.toxins
		unsim_heat_capacity += T.heat_capacity
		unsim_temperature += T.temperature/unsimulated_tiles.len

	var
		ratio = 0.21

		old_pressure = A.return_pressure()

		size = max(1,A.group_multiplier)
		share_size = max(1,unsimulated_tiles.len)

		full_oxy = A.oxygen * size
		full_nitro = A.nitrogen * size
		full_co2 = A.carbon_dioxide * size
		full_plasma = A.toxins * size

		full_heat_capacity = A.heat_capacity() * size

		oxy_avg = (full_oxy + unsim_oxygen) / (size + share_size)
		nit_avg = (full_nitro + unsim_nitrogen) / (size + share_size)
		co2_avg = (full_co2 + unsim_co2) / (size + share_size)
		plasma_avg = (full_plasma + unsim_plasma) / (size + share_size)

		temp_avg = (A.temperature * full_heat_capacity + unsim_temperature * unsim_heat_capacity) / (full_heat_capacity + unsim_heat_capacity)

	if(sharing_lookup_table.len >= unsimulated_tiles.len) //6 or more interconnecting tiles will max at 42% of air moved per tick.
		ratio = sharing_lookup_table[unsimulated_tiles.len]
	ratio *= 2

	A.oxygen = max(0, (A.oxygen - oxy_avg) * (1-ratio) + oxy_avg )
	A.nitrogen = max(0, (A.nitrogen - nit_avg) * (1-ratio) + nit_avg )
	A.carbon_dioxide = max(0, (A.carbon_dioxide - co2_avg) * (1-ratio) + co2_avg )
	A.toxins = max(0, (A.toxins - plasma_avg) * (1-ratio) + plasma_avg )

	A.temperature = max(TCMB, (A.temperature - temp_avg) * (1-ratio) + temp_avg )

	for(var/datum/gas/G in A.trace_gases)
		var/G_avg = (G.moles*size + 0) / (size+share_size)
		G.moles = (G.moles - G_avg) * (1-ratio) + G_avg

	A.update_values()

	return abs(old_pressure - A.return_pressure())

  ///////////////////
 //Zone Rebuilding//
///////////////////

zone/proc/Rebuild()
	//Choose a random turf and regenerate the zone from it.
	var
		turf/simulated/sample = locate() in contents
		list/new_contents
		problem = 0

	//
	var/list/turfs_to_consider = contents.Copy()

	while(!sample.CanPass(null, sample, 1.5, 1))
		if(sample)
			turfs_to_consider.Remove(sample)
		sample = locate() in turfs_to_consider
		if(!sample)
			break

	if(!istype(sample) || !sample.CanPass(null, sample, 1.5, 1)) //Not a single valid turf.
		for(var/turf/simulated/T in contents)
			air_master.tiles_to_update |= T
		return SoftDelete()

	new_contents = FloodFill(sample)

	var/list/new_unsimulated = ( unsimulated_tiles ? unsimulated_tiles : list() )

	for(var/turf/S in new_contents)
		if(!istype(S, /turf/simulated))
			new_unsimulated |= S
			new_contents.Remove(S)

	if(contents.len != new_contents.len)
		problem = 1

	//If something isn't carried over, there was a complication.
	for(var/turf/T in contents)
		if(!(T in new_contents))
			T.zone = null
			problem = 1

	if(problem)
		//Build some new zones for stuff that wasn't included.
		var/list/turf/simulated/rebuild_turfs = contents - new_contents
		var/list/turf/simulated/reconsider_turfs = list()
		contents = new_contents
		for(var/turf/simulated/T in rebuild_turfs)
			if(!T.zone && T.CanPass(null, T, 1.5, 1))
				var/zone/Z = new /zone(T)
				Z.air.copy_from(air)
			else
				reconsider_turfs |= T
		for(var/turf/simulated/T in reconsider_turfs)
			if(!T.zone && T.CanPass(null, T, 1.5, 1))
				var/zone/Z = new /zone(T)
				Z.air.copy_from(air)
			else if(!T in air_master.tiles_to_update)
				air_master.tiles_to_update.Add(T)

	for(var/turf/simulated/T in contents)
		if(T.zone && T.zone != src)
			T.zone.RemoveTurf(T)
			T.zone = src
		else if(!T.zone)
			T.zone = src
	air.group_multiplier = contents.len
	unsimulated_tiles = null

	if(new_unsimulated.len)
		for(var/turf/S in new_unsimulated)
			if(istype(S, /turf/simulated))
				continue
			for(var/direction in cardinal)
				var/turf/simulated/T = get_step(S,direction)
				if(istype(T) && T.zone)
					T.zone.AddTurf(S)

//UNUSED
/*
zone/proc/connected_zones()
	//A legacy proc for getting connected zones.
	. = list()
	for(var/connection/C in connections)
		var/zone/Z
		if(C.A.zone == src)
			Z = C.B.zone
		else
			Z = C.A.zone

		if(Z in .)
			.[Z]++
		else
			. += Z
			.[Z] = 1*/