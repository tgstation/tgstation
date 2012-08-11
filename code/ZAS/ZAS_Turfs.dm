atom/var/pressure_resistance = ONE_ATMOSPHERE
turf

	var/zone/zone

	assume_air(datum/gas_mixture/giver) //use this for machines to adjust air
		del(giver)
		return 0

	return_air()
		//Create gas mixture to hold data for passing
		var/datum/gas_mixture/GM = new

		GM.oxygen = oxygen
		GM.carbon_dioxide = carbon_dioxide
		GM.nitrogen = nitrogen
		GM.toxins = toxins

		GM.temperature = temperature
		GM.update_values()

		return GM

	remove_air(amount as num)
		var/datum/gas_mixture/GM = new

		var/sum = oxygen + carbon_dioxide + nitrogen + toxins
		if(sum>0)
			GM.oxygen = (oxygen/sum)*amount
			GM.carbon_dioxide = (carbon_dioxide/sum)*amount
			GM.nitrogen = (nitrogen/sum)*amount
			GM.toxins = (toxins/sum)*amount

		GM.temperature = temperature
		GM.update_values()

		return GM

turf
	simulated

		var/current_graphic = null

		var/tmp
			datum/gas_mixture/air

			processing = 1
//			group_border = 0
//			length_space_border = 0

			air_check_directions = 0 //Do not modify this, just add turf to air_master.tiles_to_update

//			archived_cycle = 0
//			current_cycle = 0

			obj/fire/active_hotspot

//			temperature_archived //USED ONLY FOR SOLIDS
//			being_superconductive = 0


		proc
			process_cell()
			update_air_properties()
			archive()

			mimic_air_with_tile(turf/model)
			share_air_with_tile(turf/simulated/sharer)

			mimic_temperature_with_tile(turf/model)
			share_temperature_with_tile(turf/simulated/sharer)


			super_conduct()

			update_visuals()
				overlays = null

				var/siding_icon_state = return_siding_icon_state()
				if(siding_icon_state)
					overlays += image('floors.dmi',siding_icon_state)
				var/datum/gas_mixture/model = return_air()
				switch(model.graphic)
					if(1)
						overlays.Add(plmaster) //TODO: Make invisible plasma an option
					if(2)
						overlays.Add(slmaster)



		New()
			..()

			if(!blocks_air)
				air = new

				air.oxygen = oxygen
				air.carbon_dioxide = carbon_dioxide
				air.nitrogen = nitrogen
				air.toxins = toxins

				air.temperature = temperature
				air.update_values()

				if(air_master)
					air_master.tiles_to_update.Add(src)

//				air.parent = src //TODO DEBUG REMOVE

			else
				if(air_master)
					for(var/direction in cardinal)
						var/turf/simulated/floor/target = get_step(src,direction)
						if(istype(target))
							air_master.tiles_to_update.Add(target)

		Del()
			if(active_hotspot)
				del(active_hotspot)
			if(blocks_air)
				for(var/direction in list(NORTH, SOUTH, EAST, WEST))
					var/turf/simulated/tile = get_step(src,direction)
					if(istype(tile) && !tile.blocks_air)
						air_master.tiles_to_update.Add(tile)
			..()

		assume_air(datum/gas_mixture/giver)
			if(!giver)	return 0
			if(zone)
				zone.air.merge(giver)
				return 1
			else
				return ..()

//		archive()
//			if(air) //For open space like floors
//				air.archive()

//			temperature_archived = temperature
//			archived_cycle = air_master.current_cycle

		share_air_with_tile(turf/simulated/T)
			return air.share(T.air)

		mimic_air_with_tile(turf/T)
			return air.mimic(T)

		return_air()
			if(zone)
				return zone.air
			else if(air)
				return air

			else
				return ..()

		remove_air(amount as num)
			if(zone)
				var/datum/gas_mixture/removed = null
				removed = zone.air.remove(amount)
				return removed
			else if(air)
				var/datum/gas_mixture/removed = null
				removed = air.remove(amount)

				if(air.check_tile_graphic())
					update_visuals(air)
				return removed

			else
				return ..()

		update_air_properties()
			. = 1
			air_check_directions = 0

			for(var/direction in cardinal)
				if(ZAirPass(get_step(src,direction)))
					air_check_directions |= direction

			if(!zone && !blocks_air) //No zone, but not a wall.
				for(var/direction in DoorDirections) //Check door directions first.
					if(air_check_directions&direction)
						var/turf/simulated/T = get_step(src,direction)
						if(T.zone)
							T.zone.AddTurf(src)
							break
				if(!zone) //Still no zone
					for(var/direction in CounterDoorDirections) //Check the others second.
						if(air_check_directions&direction)
							var/turf/simulated/T = get_step(src,direction)
							if(T.zone)
								T.zone.AddTurf(src)
								break
				if(!zone) //No zone found, new zone!
					new/zone(src)
				if(!zone) //Still no zone, the floodfill determined it is not part of a larger zone.  Force a zone on it.
					new/zone(list(src))

			if("\ref[src]" in air_master.turfs_with_connections) //Check pass sanity of the connections.
				for(var/connection/C in air_master.turfs_with_connections["\ref[src]"])
					if(!(C in air_master.connections_to_check))
						air_master.connections_to_check += C

			for(var/direction in cardinal)
				var/turf/T = get_step(src,direction)
				var/list/zone/adjacent_zones = list()

				if(air_check_directions&direction) //I can connect air in this direction
					if(!CanPass(null, T, 0, 0)) //If either block air, we must look to see if the adjacent turfs need rebuilt.
						if(T.zone && !T.zone.rebuild)
							for(var/direction2 in cardinal - direction) //Check all other directions for air that might be connected.
								var/turf/simulated/NT = get_step(src, direction2)
								if(NT && NT.zone && NT.zone == T.zone && !NT.HasDoor())
									T.zone.rebuild = 1

					else
						ZConnect(src,T)

				//If I cannot connect to air or whatever, and there is a zone there, I am probably not able to pass air.  Consider zone rebuilding
				else if(T.zone && !T.zone.rebuild)
					if(T.zone in adjacent_zones) //Found it more than 1 direction, rebuild
						T.zone.rebuild = 1
					else //Add it for later checks.
						adjacent_zones += T.zone

			if(air_check_directions)
				processing = 1
			else
				processing = 0


/turf/proc/HasDoor(turf/O)
	//Checks for the presence of doors, used for zone spreading and connection.
	//A positive numerical argument checks only for closed doors.
	//Another turf as an argument checks for windoors between here and there.
	for(var/obj/machinery/door/D in src)
		if(isnum(O) && O)
			if(!D.density) continue
		if(istype(D,/obj/machinery/door/window))
			if(!O) continue
			if(D.dir == get_dir(D,O)) return 1
		else
			return 1

turf/proc/ZCanPass(turf/T, var/include_space = 0)
	//Fairly standard pass checks for turfs, objects and directional windows. Also stops at the edge of space.
	if(!istype(T))
		return 0

	if(istype(T,/turf/space) && !include_space)
		return 0
	else
		if(T.blocks_air||blocks_air)
			return 0

		for(var/obj/obstacle in src)
			if(istype(obstacle,/obj/machinery/door) && !istype(obstacle,/obj/machinery/door/window))
				continue
			if(!obstacle.CanPass(null, T, 1.5, 1))
				return 0

		for(var/obj/obstacle in T)
			if(istype(obstacle,/obj/machinery/door) && !istype(obstacle,/obj/machinery/door/window))
				continue
			if(!obstacle.CanPass(null, src, 1.5, 1))
				return 0

		return 1

turf/proc/ZAirPass(turf/T)
	//Fairly standard pass checks for turfs, objects and directional windows.
	if(!istype(T))
		return 0

	if(T.blocks_air||blocks_air)
		return 0

	for(var/obj/obstacle in src)
		if(istype(obstacle,/obj/machinery/door) && !istype(obstacle,/obj/machinery/door/window))
			continue
		if(!obstacle.CanPass(null, T, 0, 0))
			return 0

	for(var/obj/obstacle in T)
		if(istype(obstacle,/obj/machinery/door) && !istype(obstacle,/obj/machinery/door/window))
			continue
		if(!obstacle.CanPass(null, src, 0, 0))
			return 0

	return 1


/*UNUSED
/turf/proc/check_connections()
	//Checks for new connections that can be made.
	for(var/d in cardinal)
		var/turf/simulated/T = get_step(src,d)
		if(istype(T) && ( !T.zone || !T.CanPass(0,src,0,0) ) )
			continue
		if(T.zone != zone)
			ZConnect(src,T)

/turf/proc/check_for_space()
	//Checks for space around the turf.
	for(var/d in cardinal)
		var/turf/T = get_step(src,d)
		if(istype(T,/turf/space) && T.CanPass(0,src,0,0))
			zone.AddSpace(T)
			*/