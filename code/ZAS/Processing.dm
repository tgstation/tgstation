#define QUANTIZE(variable)		(round(variable,0.0001))
var/explosion_halt = 0
zone
	proc/process()
		if(rebuild)
			if(!contents) del src
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

		var/total_space = 0
		var/turf/space/space

		if(length(connected_zones))
			for(var/zone/Z in connected_zones)
				total_space += length(Z.space_tiles)
				if(length(Z.space_tiles))
					space = Z.space_tiles[1]

		if(space_tiles)
			for(var/T in space_tiles)
				if(!istype(T,/turf/space)) space_tiles -= T
			total_space += length(space_tiles)
			if(length(space_tiles))
				space = space_tiles[1]

		if(total_space && space)
			var/old_pressure = air.return_pressure()
			air.temperature_mimic(space,OPEN_HEAT_TRANSFER_COEFFICIENT,total_space)
			air.remove(MOLES_CELLSTANDARD * (air.group_multiplier/40) * total_space)
			if(dbg_output) world << "Space removed [MOLES_CELLSTANDARD*(air.group_multiplier/40)*total_space] moles of air."
			var/p_diff = old_pressure - air.return_pressure()
			if(p_diff > vsc.AF_TINY_MOVEMENT_THRESHOLD) AirflowSpace(src,p_diff)

		air.react(null,0)
		var/check = air.check_tile_graphic()
		for(var/turf/T in contents)
			if(T.zone && T.zone != src)
				RemoveTurf(T)
				if(dbg_output) world << "Removed invalid turf."
				if(air.group_multiplier <= 0) // No more turfs belong to this zone, so we can get rid of it
					del(src)
			else							  // Turf was valid, so we can handle it
				if(!T.zone)
					T.zone = src

				if(istype(T,/turf/simulated))
					var/turf/simulated/S = T
					if(S.fire_protection) S.fire_protection--
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
				if(C && !C.indirect)
					if(C.A.zone.air.compare(C.B.zone.air))
						ZMerge(C.A.zone,C.B.zone)
			for(var/zone/Z in connected_zones)
				var/p_diff = (air.return_pressure()-Z.air.return_pressure())*connected_zones[Z]*(vsc.zone_share_percent/100)
				if(p_diff > vsc.AF_TINY_MOVEMENT_THRESHOLD) Airflow(src,Z,p_diff)
				air.share_ratio(Z.air,connected_zones[Z]*(vsc.zone_share_percent/100))


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