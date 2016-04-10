

/turf
	var/pressure_difference = 0
	var/pressure_direction = 0
	var/list/atmos_adjacent_turfs = list()
	var/atmos_supeconductivity = 0

/turf/assume_air(datum/gas_mixture/giver) //use this for machines to adjust air
	qdel(giver)
	return 0

/turf/return_air()
	//Create gas mixture to hold data for passing
	var/datum/gas_mixture/GM = new

	GM.copy_from_turf(src)

	return GM

/turf/remove_air(amount)
	var/datum/gas_mixture/GM = return_air()

	GM.remove(amount)

	return GM


/turf/simulated
	var/datum/excited_group/excited_group
	var/excited = 0
	var/recently_active = 0
	var/datum/gas_mixture/air
	var/archived_cycle = 0
	var/current_cycle = 0

	var/obj/effect/hotspot/active_hotspot

	var/temperature_archived //USED ONLY FOR SOLIDS

	var/atmos_overlay_types = list() //gas IDs of current active overlays

/turf/simulated/New()
	..()
	levelupdate()
	if(smooth)
		queue_smooth(src)
	visibilityChanged()
	if(!blocks_air)
		air = new
		air.copy_from_turf(src)

/turf/simulated/Destroy()
	visibilityChanged()
	if(active_hotspot)
		qdel(active_hotspot)
	return ..()

/turf/simulated/assume_air(datum/gas_mixture/giver)
	if(!giver)
		return 0
	var/datum/gas_mixture/receiver = air
	if(istype(receiver))

		air.merge(giver)

		update_visuals()

		return 1

	else return ..()

/turf/simulated/proc/copy_air_with_tile(turf/simulated/T)
	if(istype(T) && T.air && air)
		air.copy_from(T.air)

/turf/simulated/proc/copy_air(datum/gas_mixture/copy)
	if(air && copy)
		air.copy_from(copy)

/turf/simulated/return_air()
	if(air)
		return air

	else
		return ..()

/turf/simulated/remove_air(amount as num)
	if(air)
		var/datum/gas_mixture/removed = null

		removed = air.remove(amount)

		update_visuals()

		return removed

	else
		return ..()

/turf/simulated/proc/mimic_temperature_solid(turf/model, conduction_coefficient)
	var/delta_temperature = (temperature_archived - model.temperature)
	if((heat_capacity > 0) && (abs(delta_temperature) > MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER))

		var/heat = conduction_coefficient*delta_temperature* \
			(heat_capacity*model.heat_capacity/(heat_capacity+model.heat_capacity))
		temperature -= heat/heat_capacity

/turf/simulated/proc/share_temperature_mutual_solid(turf/simulated/sharer, conduction_coefficient)
	var/delta_temperature = (temperature_archived - sharer.temperature_archived)
	if(abs(delta_temperature) > MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER && heat_capacity && sharer.heat_capacity)

		var/heat = conduction_coefficient*delta_temperature* \
			(heat_capacity*sharer.heat_capacity/(heat_capacity+sharer.heat_capacity))

		temperature -= heat/heat_capacity
		sharer.temperature += heat/sharer.heat_capacity


/turf/proc/process_cell(fire_count)
	SSair.remove_from_active(src)


/turf/simulated/process_cell(fire_count)

	if(archived_cycle < fire_count) //archive self if not already done
		archive()

	current_cycle = fire_count
	var/remove = 1 //set by non simulated turfs who are sharing with this turf

	//cache for sanic speed
	var/list/adjacent_turfs = atmos_adjacent_turfs
	var/datum/excited_group/our_excited_group = excited_group
	var/adjacent_turfs_length = adjacent_turfs.len

	for(var/t in adjacent_turfs)
		var/turf/enemy_tile = t

		if(istype(enemy_tile,/turf/simulated))
			var/turf/simulated/enemy_simulated = enemy_tile

			if(fire_count > enemy_simulated.current_cycle)
				enemy_simulated.archive()

		/******************* GROUP HANDLING START *****************************************************************/

			if(enemy_simulated.excited)
				//cache for sanic speed
				var/datum/excited_group/enemy_excited_group = enemy_simulated.excited_group
				if(our_excited_group)
					if(enemy_excited_group)
						if(our_excited_group != enemy_excited_group)
							//combine groups (this also handles updating the excited_group var of all involved turfs)
							our_excited_group.merge_groups(enemy_excited_group)
							our_excited_group = excited_group //update our cache
						share_air(enemy_simulated, fire_count, adjacent_turfs_length) //share
					else
						if((recently_active == 1 && enemy_simulated.recently_active == 1) || air.compare(enemy_simulated.air))
							our_excited_group.add_turf(enemy_simulated) //add enemy to our group
							share_air(enemy_simulated, fire_count, adjacent_turfs_length) //share
				else
					if(enemy_excited_group)
						if((recently_active == 1 && enemy_simulated.recently_active == 1) || air.compare(enemy_simulated.air))
							enemy_excited_group.add_turf(src) //join self to enemy group
							our_excited_group = excited_group //update our cache
							share_air(enemy_simulated, fire_count, adjacent_turfs_length) //share
					else
						if((recently_active == 1 && enemy_simulated.recently_active == 1) || air.compare(enemy_simulated.air))
							var/datum/excited_group/EG = new //generate new group
							EG.add_turf(src)
							EG.add_turf(enemy_simulated)
							our_excited_group = excited_group //update our cache
							share_air(enemy_simulated, fire_count, adjacent_turfs_length) //share
			else
				if(air.compare(enemy_simulated.air)) //compare if
					SSair.add_to_active(enemy_simulated) //excite enemy
					if(our_excited_group)
						excited_group.add_turf(enemy_simulated) //add enemy to group
					else
						var/datum/excited_group/EG = new //generate new group
						EG.add_turf(src)
						EG.add_turf(enemy_simulated)
						our_excited_group = excited_group //update our cache
					share_air(enemy_simulated, fire_count, adjacent_turfs_length) //share

		/******************* GROUP HANDLING FINISH *********************************************************************/

		else

			if(air.check_turf(enemy_tile, adjacent_turfs_length))
				var/difference = air.mimic(enemy_tile, adjacent_turfs_length)
				if(difference)
					if(difference > 0)
						consider_pressure_difference(enemy_tile, difference)
					else
						enemy_tile.consider_pressure_difference(src, -difference)
				remove = 0
				if(our_excited_group)
					last_share_check()

	air.react()

	update_visuals()

	if(air.temperature > FIRE_MINIMUM_TEMPERATURE_TO_EXIST)
		hotspot_expose(air.temperature, CELL_VOLUME)
		for(var/atom/movable/item in src)
			item.temperature_expose(air, air.temperature, CELL_VOLUME)
		temperature_expose(air, air.temperature, CELL_VOLUME)

		if(air.temperature > MINIMUM_TEMPERATURE_START_SUPERCONDUCTION)
			if(consider_superconductivity(starting = 1))
				remove = 0

	if(!our_excited_group && remove == 1)
		SSair.remove_from_active(src)

/turf/simulated/temperature_expose()
	if(temperature > heat_capacity)
		to_be_destroyed = 1

/turf/simulated/proc/archive()
	if(air) //For open space like floors
		air.archive()
	temperature_archived = temperature
	archived_cycle = SSair.times_fired

/turf/simulated/proc/update_visuals()
	var/list/new_overlay_types = tile_graphic()

	for(var/overlay in atmos_overlay_types-new_overlay_types) //doesn't remove overlays that would only be added
		overlays -= overlay
		atmos_overlay_types -= overlay

	for(var/overlay in new_overlay_types-atmos_overlay_types) //doesn't add overlays that already exist
		overlays += overlay

	atmos_overlay_types = new_overlay_types

/turf/simulated/proc/tile_graphic()
	. = new /list
	var/list/gases = air.gases
	for(var/id in gases)
		var/gas = gases[id]
		if(gas[GAS_META][META_GAS_OVERLAY] && gas[MOLES] > gas[GAS_META][META_GAS_MOLES_VISIBLE])
			. += gas[GAS_META][META_GAS_OVERLAY]

/turf/simulated/proc/share_air(turf/simulated/T, fire_count, adjacent_turfs_length)
	if(T.current_cycle < fire_count)
		var/difference
		difference = air.share(T.air, adjacent_turfs_length)
		if(difference)
			if(difference > 0)
				consider_pressure_difference(T, difference)
			else
				T.consider_pressure_difference(src, -difference)
		last_share_check()

/turf/proc/consider_pressure_difference(turf/simulated/T, difference)
	SSair.high_pressure_delta |= src
	if(difference > pressure_difference)
		pressure_direction = get_dir(src, T)
		pressure_difference = difference

/turf/simulated/proc/last_share_check()
	if(air.last_share > MINIMUM_AIR_TO_SUSPEND)
		excited_group.reset_cooldowns()

/turf/proc/high_pressure_movements()
	for(var/atom/movable/M in src)
		M.experience_pressure_difference(pressure_difference, pressure_direction)



/atom/movable/var/pressure_resistance = 5
/atom/movable/var/last_high_pressure_movement_air_cycle = 0
/atom/movable/proc/experience_pressure_difference(pressure_difference, direction)
	set waitfor = 0
	. = 0
	if(!anchored && !pulledby)
		. = 1
		if(pressure_difference > pressure_resistance && last_high_pressure_movement_air_cycle < SSair.times_fired)
			last_high_pressure_movement_air_cycle = SSair.times_fired
			step(src, direction)




/datum/excited_group
	var/list/turf_list = list()
	var/breakdown_cooldown = 0

/datum/excited_group/New()
	SSair.excited_groups += src

/datum/excited_group/proc/add_turf(turf/simulated/T)
	turf_list += T
	T.excited_group = src
	T.recently_active = 1
	reset_cooldowns()

/datum/excited_group/proc/merge_groups(datum/excited_group/E)
	if(turf_list.len > E.turf_list.len)
		SSair.excited_groups -= E
		for(var/turf/simulated/T in E.turf_list)
			T.excited_group = src
			turf_list += T
			reset_cooldowns()
	else
		SSair.excited_groups -= src
		for(var/turf/simulated/T in turf_list)
			T.excited_group = E
			E.turf_list += T
			E.reset_cooldowns()

/datum/excited_group/proc/reset_cooldowns()
	breakdown_cooldown = 0

/datum/excited_group/proc/self_breakdown()
	var/datum/gas_mixture/A = new
	var/list/A_gases = A.gases
	for(var/turf/simulated/T in turf_list)
		A.merge(T.air)

	for(var/turf/simulated/T in turf_list)
		var/T_gases = T.air.gases
		for(var/id in A_gases)
			T.air.assert_gas(id)
			T_gases[id][MOLES] = A_gases[id][MOLES]/turf_list.len

		T.update_visuals()

/datum/excited_group/proc/dismantle()
	for(var/turf/simulated/T in turf_list)
		T.excited = 0
		T.recently_active = 0
		T.excited_group = null
		SSair.active_turfs -= T
	garbage_collect()

/datum/excited_group/proc/garbage_collect()
	for(var/turf/simulated/T in turf_list)
		T.excited_group = null
	turf_list.Cut()
	SSair.excited_groups -= src










/turf/simulated/proc/super_conduct()
	var/conductivity_directions = 0
	if(blocks_air)
		//Does not participate in air exchange, so will conduct heat across all four borders at this time
		conductivity_directions = NORTH|SOUTH|EAST|WEST

		if(archived_cycle < SSair.times_fired)
			archive()
	else
		//Does particate in air exchange so only consider directions not considered during process_cell()
		for(var/direction in cardinal)
			var/turf/T = get_step(src, direction)
			if(!(T in atmos_adjacent_turfs) && !(atmos_supeconductivity & direction))
				conductivity_directions += direction

	if(conductivity_directions>0)
		//Conduct with tiles around me
		for(var/direction in cardinal)
			if(conductivity_directions & direction)
				var/turf/neighbor = get_step(src,direction)

				if(!neighbor.thermal_conductivity)
					continue

				if(istype(neighbor, /turf/simulated)) //anything under this subtype will share in the exchange
					var/turf/simulated/T = neighbor

					if(T.archived_cycle < SSair.times_fired)
						T.archive()

					if(T.air)
						if(air) //Both tiles are open
							air.temperature_share(T.air, WINDOW_HEAT_TRANSFER_COEFFICIENT)
						else //Solid but neighbor is open
							T.air.temperature_turf_share(src, T.thermal_conductivity)
						SSair.add_to_active(T, 0)
					else
						if(air) //Open but neighbor is solid
							air.temperature_turf_share(T, T.thermal_conductivity)
						else //Both tiles are solid
							share_temperature_mutual_solid(T, T.thermal_conductivity)
						T.temperature_expose(null, T.temperature, null)

					T.consider_superconductivity()

				else
					if(air) //Open
						air.temperature_mimic(neighbor, neighbor.thermal_conductivity)
					else
						mimic_temperature_solid(neighbor, neighbor.thermal_conductivity)

	radiate_to_spess()

	//Conduct with air on my tile if I have it
	if(air)
		air.temperature_turf_share(src, thermal_conductivity)

		//Make sure still hot enough to continue conducting heat
		if(air.temperature < MINIMUM_TEMPERATURE_FOR_SUPERCONDUCTION)
			SSair.active_super_conductivity -= src
			return 0

	else
		if(temperature < MINIMUM_TEMPERATURE_FOR_SUPERCONDUCTION)
			SSair.active_super_conductivity -= src
			return 0

/turf/simulated/proc/consider_superconductivity(starting)
	if(!thermal_conductivity)
		return 0

	if(air)
		if(air.temperature < (starting?MINIMUM_TEMPERATURE_START_SUPERCONDUCTION:MINIMUM_TEMPERATURE_FOR_SUPERCONDUCTION))
			return 0
		if(air.heat_capacity() < M_CELL_WITH_RATIO) // Was: MOLES_CELLSTANDARD*0.1*0.05 Since there are no variables here we can make this a constant.
			return 0
	else
		if(temperature < (starting?MINIMUM_TEMPERATURE_START_SUPERCONDUCTION:MINIMUM_TEMPERATURE_FOR_SUPERCONDUCTION))
			return 0

	SSair.active_super_conductivity |= src
	return 1

/turf/simulated/proc/radiate_to_spess() //Radiate excess tile heat to space
	if(temperature > T0C) //Considering 0 degC as te break even point for radiation in and out
		var/delta_temperature = (temperature_archived - 2.7) //hardcoded space temperature
		if((heat_capacity > 0) && (abs(delta_temperature) > MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER))

			var/heat = thermal_conductivity*delta_temperature* \
				(heat_capacity*700000/(heat_capacity+700000)) //700000 is the heat_capacity from a space turf, hardcoded here
			temperature -= heat/heat_capacity
