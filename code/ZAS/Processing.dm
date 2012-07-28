#define QUANTIZE(variable)		(round(variable,0.0001))
zone/proc/process()
	. = 1

	//Deletes zone if empty.
	if(!contents.len)
		del src
	//Does rebuilding stuff.
	if(rebuild)
		rebuild = 0
		Rebuild() //Shoving this into a proc.

	//Sometimes explosions will cause the air to be deleted for some reason.
	if(!air)
		air = new()
		air.adjust(MOLES_O2STANDARD, 0, MOLES_N2STANDARD, 0, list())
		world.log << "Air object lost in zone. Regenerating."

	//Counting up space.
	var/total_space = 0

	if(space_tiles)
		for(var/T in space_tiles)
			if(!istype(T,/turf/space))
				RemoveSpace(T)
		if(space_tiles)
			total_space = space_tiles.len

	//Add checks to ensure that we're not sucking air out of an empty room.
	if(total_space && air.total_moles > 0.1 && air.temperature > TCMB+0.5)
		//If there is space, air should flow out of the zone.
		if(abs(air.return_pressure()) > vsc.airflow_lightest_pressure)
			AirflowSpace(src)
		ShareSpace(air,total_space*vsc.zone_share_percent/200)

	//React the air here.
	air.react(null,0)

	//Check the graphic.

	air.graphic = 0
	if(air.toxins > MOLES_PLASMA_VISIBLE)
		air.graphic = 1
	else if(air.trace_gases.len)
		var/datum/gas/sleeping_agent = locate(/datum/gas/sleeping_agent) in air.trace_gases
		if(sleeping_agent && (sleeping_agent.moles > 1))
			air.graphic = 2

	//Only run through the individual turfs if there's reason to.
	if(air.graphic != air.graphic_archived || air.temperature > FIRE_MINIMUM_TEMPERATURE_TO_EXIST)

		for(var/turf/simulated/S in contents)
			//Update overlays.
			if(air.graphic != air.graphic_archived)
				if(S.HasDoor(1))
					S.update_visuals()
				else
					S.update_visuals(air)

			//Expose stuff to extreme heat.
			if(air.temperature > FIRE_MINIMUM_TEMPERATURE_TO_EXIST)
				for(var/atom/movable/item in S)
					item.temperature_expose(air, air.temperature, CELL_VOLUME)
				S.temperature_expose(air, air.temperature, CELL_VOLUME)

	//Archive graphic so we can know if it's different.
	air.graphic_archived = air.graphic

	//Ensure temperature does not reach absolute zero.
	air.temperature = max(TCMB,air.temperature)

	//Handle connections to other zones.
	if(length(connections))
		for(var/connection/C in connections)
			//Check if the connection is valid first.
			if(!C.Cleanup())
				continue
			//Do merging if conditions are met. Specifically, if there's a non-door connection
			//to somewhere with space, the zones are merged regardless of equilibrium, to speed
			//up spacing in areas with double-plated windows.
			if(C && C.indirect == 2 && C.A.zone && C.B.zone) //indirect = 2 is a direct connection.
				if(C.A.zone.air.compare(C.B.zone.air) || total_space)
					ZMerge(C.A.zone,C.B.zone)

		//Share some
		for(var/zone/Z in connected_zones)
			//Ensure we're not doing pointless calculations on equilibrium zones.
			if(abs(air.total_moles - Z.air.total_moles) > 0.1 || abs(air.temperature - Z.air.temperature) > 0.1)
				if(abs(Z.air.return_pressure() - air.return_pressure()) > vsc.airflow_lightest_pressure)
					Airflow(src,Z)
				ShareRatio( air , Z.air , connected_zones[Z]*vsc.zone_share_percent/200 )
				//Divided by 200 since each zone is processed.  Each connection is considered twice
				//Space tiles force it to try and move twice as much air.

proc/ShareRatio(datum/gas_mixture/A, datum/gas_mixture/B, ratio)
	//Shares a specific ratio of gas between mixtures using simple weighted averages.
	var
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

	A.oxygen = (A.oxygen - oxy_avg) * (1-ratio) + oxy_avg
	A.nitrogen = (A.nitrogen - nit_avg) * (1-ratio) + nit_avg
	A.carbon_dioxide = (A.carbon_dioxide - co2_avg) * (1-ratio) + co2_avg
	A.toxins = (A.toxins - plasma_avg) * (1-ratio) + plasma_avg

	A.temperature = (A.temperature - temp_avg) * (1-ratio) + temp_avg

	B.oxygen = (B.oxygen - oxy_avg) * (1-ratio) + oxy_avg
	B.nitrogen = (B.nitrogen - nit_avg) * (1-ratio) + nit_avg
	B.carbon_dioxide = (B.carbon_dioxide - co2_avg) * (1-ratio) + co2_avg
	B.toxins = (B.toxins - plasma_avg) * (1-ratio) + plasma_avg

	B.temperature = (B.temperature - temp_avg) * (1-ratio) + temp_avg

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

proc/ShareSpace(datum/gas_mixture/A, ratio)
	//A modified version of ShareRatio for spacing gas at the same rate as if it were going into a large airless room.
	var
		size = max(1,A.group_multiplier)
		share_size = max(1,A.group_multiplier)

		full_oxy = A.oxygen * size
		full_nitro = A.nitrogen * size
		full_co2 = A.carbon_dioxide * size
		full_plasma = A.toxins * size

		full_heat_capacity = A.heat_capacity() * size

		space_heat_capacity = MINIMUM_HEAT_CAPACITY * share_size

		oxy_avg = (full_oxy) / (size + share_size)
		nit_avg = (full_nitro) / (size + share_size)
		co2_avg = (full_co2) / (size + share_size)
		plasma_avg = (full_plasma) / (size + share_size)

		temp_avg = (A.temperature * full_heat_capacity + TCMB * space_heat_capacity) / (full_heat_capacity + space_heat_capacity)

	A.oxygen = (A.oxygen - oxy_avg) * (1-ratio) + oxy_avg
	A.nitrogen = (A.nitrogen - nit_avg) * (1-ratio) + nit_avg
	A.carbon_dioxide = (A.carbon_dioxide - co2_avg) * (1-ratio) + co2_avg
	A.toxins = (A.toxins - plasma_avg) * (1-ratio) + plasma_avg

	A.temperature = (A.temperature - temp_avg) * (1-ratio) + temp_avg

	//833 * 0.9 + 833 =
	//(5000/3) = 1666
	//(5000/6) = 833

	for(var/datum/gas/G in A.trace_gases)
		var/G_avg = (G.moles*size + 0) / (size+share_size)
		G.moles = (G.moles - G_avg) * (1-ratio) + G_avg

	A.update_values()

	return 1

zone/proc/Rebuild()
	//Choose a random turf and regenerate the zone from it.
	var
		turf/simulated/sample = pick(contents)
		list/new_contents
		problem = 0

	var/list/turfs_to_consider = contents.Copy()
	do
		if(sample)
			turfs_to_consider.Remove(sample)
		if(!turfs_to_consider.len)
			break
		sample = pick(turfs_to_consider)  //Nor this.
	while(!istype(sample) || !sample.CanPass(null, sample, 1.5, 1))

	if(!istype(sample) || !sample.CanPass(null, sample, 1.5, 1)) //Not a single valid turf.
		for(var/turf/simulated/T in contents)
			air_master.tiles_to_update |= T
		del src

	new_contents = FloodFill(sample)

	for(var/turf/space/S in new_contents)
		AddSpace(S)
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

	if(space_tiles)
		var/list/new_space_tiles = space_tiles.Copy()
		space_tiles = null
		for(var/turf/space/S in new_space_tiles)
			for(var/direction in cardinal)
				var/turf/simulated/T = get_step(S,direction)
				if(istype(T) && T.zone)
					T.zone.AddSpace(S)
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