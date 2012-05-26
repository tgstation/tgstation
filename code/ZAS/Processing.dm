#define QUANTIZE(variable)		(round(variable,0.0001))
var/explosion_halt = 0
zone
	proc/process()
		if(rebuild)
			if(!contents.len)
				del src
				return 0
			var
				turf/sample = pick(contents)
				list/new_contents = FloodFill(sample)
				problem = 0
			for(var/turf/T in contents)
				if(!(T in new_contents))
					problem = 1

			if(problem)
				var/list/rebuild_turfs = list()
				for(var/turf/T in contents - new_contents)
					contents -= T
					rebuild_turfs += T
					T.zone = null
				for(var/turf/T in rebuild_turfs)
					if(!T.zone)
						var/zone/Z = new/zone(T)
						Z.air.copy_from(air)
			rebuild = 0

		if(!air)
			air = new()
			air.adjustGases(MOLES_O2STANDARD, 0, MOLES_N2STANDARD, 0, list())
			world.log << "Air object lost in zone. Regenerating."

		var/total_space = 0

		if(space_tiles)
			for(var/T in space_tiles)
				if(!istype(T,/turf/space)) space_tiles -= T
			total_space = length(space_tiles)

		if(total_space) // SPAAAAAAAAAACE
			//var/old_pressure = air.pressure
			ShareSpace(air,total_space*(vsc.zone_share_percent/100))
			//var/p_diff = old_pressure - air.pressure
			//if(p_diff > vsc.AF_TINY_MOVEMENT_THRESHOLD) AirflowSpace(src,p_diff)

		air.react(null,0)
		var/check = air.check_tile_graphic()

		if(check || air.temperature > FIRE_MINIMUM_TEMPERATURE_TO_EXIST)
			for(var/turf/simulated/S in contents)
				if(check)
					if(S.HasDoor(1))
						S.update_visuals()
					else
						S.update_visuals(air)

				if(air.temperature > FIRE_MINIMUM_TEMPERATURE_TO_EXIST)
					for(var/atom/movable/item in S)
						item.temperature_expose(air, air.temperature, CELL_VOLUME)
					S.temperature_expose(air, air.temperature, CELL_VOLUME)

		air.graphic_archived = air.graphic

		air.temperature = max(TCMB,air.temperature)

		if(length(connections))
			for(var/connection/C in connections)
				C.Cleanup()
				if(C && !C.indirect && C.A.zone && C.B.zone)
					if(C.A.zone.air.compare(C.B.zone.air) || total_space)
						ZMerge(C.A.zone,C.B.zone)
			for(var/zone/Z in connected_zones)
				//var/p_diff = (air.return_pressure()-Z.air.return_pressure())*connected_zones[Z]*(vsc.zone_share_percent/100)
				//if(p_diff > vsc.AF_TINY_MOVEMENT_THRESHOLD) Airflow(src,Z,p_diff)
				ShareRatio(air,Z.air,connected_zones[Z]*(vsc.zone_share_percent/100))

proc/ShareRatio(datum/gas_mixture/A, datum/gas_mixture/B, ratio)
	var
		size = max(1,A.group_multiplier)
		share_size = max(1,B.group_multiplier)

		full_oxy = A.oxygen * size
		full_nitro = A.nitrogen * size
		full_co2 = A.carbon_dioxide * size
		full_plasma = A.toxins * size

		full_thermal = A.temperature * A.heat_capacity() * size

		s_full_oxy = B.oxygen * share_size
		s_full_nitro = B.nitrogen * share_size
		s_full_co2 = B.carbon_dioxide * share_size
		s_full_plasma = B.toxins * share_size

		s_full_thermal = B.temperature * B.heat_capacity() * share_size

		oxy_avg = (full_oxy + s_full_oxy) / (size + share_size)
		nit_avg = (full_nitro + s_full_nitro) / (size + share_size)
		co2_avg = (full_co2 + s_full_co2) / (size + share_size)
		plasma_avg = (full_plasma + s_full_plasma) / (size + share_size)

		thermal_avg = (full_thermal + s_full_thermal) / (size+share_size)

	A.oxygen = (A.oxygen - oxy_avg) * (1-ratio) + oxy_avg
	A.nitrogen = (A.nitrogen - nit_avg) * (1-ratio) + nit_avg
	A.carbon_dioxide = (A.carbon_dioxide - co2_avg) * (1-ratio) + co2_avg
	A.toxins = (A.toxins - plasma_avg) * (1-ratio) + plasma_avg

	B.oxygen = (B.oxygen - oxy_avg) * (1-ratio) + oxy_avg
	B.nitrogen = (B.nitrogen - nit_avg) * (1-ratio) + nit_avg
	B.carbon_dioxide = (B.carbon_dioxide - co2_avg) * (1-ratio) + co2_avg
	B.toxins = (B.toxins - plasma_avg) * (1-ratio) + plasma_avg

	var
		thermal = (full_thermal/size - thermal_avg) * (1-ratio) + thermal_avg
		sharer_thermal = (s_full_thermal/share_size - thermal_avg) * (1-ratio) + thermal_avg

	A.temperature = thermal / (A.heat_capacity() == 0 ? MINIMUM_HEAT_CAPACITY : A.heat_capacity())

	B.temperature = sharer_thermal / (B.heat_capacity() == 0 ? MINIMUM_HEAT_CAPACITY : B.heat_capacity())

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

	/* See? Now that's how it's done. */

proc/ShareSpace(datum/gas_mixture/A, ratio)
	var
		size = max(1,A.group_multiplier)
		share_size = 2000 //A huge value because space is huge.

		full_oxy = A.oxygen * size
		full_nitro = A.nitrogen * size
		full_co2 = A.carbon_dioxide * size
		full_plasma = A.toxins * size

		full_thermal = A.temperature * A.heat_capacity() * size

		oxy_avg = (full_oxy + 0) / (size + share_size)
		nit_avg = (full_nitro + 0.2) / (size + share_size)
		co2_avg = (full_co2 + 0) / (size + share_size)
		plasma_avg = (full_plasma + 0) / (size + share_size)

		thermal_avg = (full_thermal + MINIMUM_HEAT_CAPACITY) / (size+share_size)

	A.oxygen = (A.oxygen - oxy_avg) * (1-ratio) + oxy_avg
	A.nitrogen = (A.nitrogen - nit_avg) * (1-ratio) + nit_avg
	A.carbon_dioxide = (A.carbon_dioxide - co2_avg) * (1-ratio) + co2_avg
	A.toxins = (A.toxins - plasma_avg) * (1-ratio) + plasma_avg

	var/thermal = (full_thermal/size - thermal_avg) * (1-ratio) + thermal_avg

	A.temperature = thermal / (A.heat_capacity() == 0 ? MINIMUM_HEAT_CAPACITY : A.heat_capacity())

	for(var/datum/gas/G in A.trace_gases)
		var/G_avg = (G.moles*size + 0) / (size+share_size)
		G.moles = (G.moles - G_avg) * (1-ratio) + G_avg

	A.update_values()

	return 1


zone/proc
	connected_zones()
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
				.[Z] = 1