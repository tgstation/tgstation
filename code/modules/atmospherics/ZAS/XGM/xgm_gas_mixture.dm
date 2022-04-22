/datum/gas_mixture
	//Associative list of gas moles.
	//Gases with 0 moles are not tracked and are pruned by update_values()
	var/list/gas = list()
	//Temperature in Kelvin of this gas mix.
	var/temperature = 0

	//Sum of all the gas moles in this mix.  Updated by update_values()
	var/total_moles = 0
	//Volume of this mix.
	var/volume = CELL_VOLUME
	//Size of the group this gas_mixture is representing.  1 for singletons.
	var/group_multiplier = 1

	//List of active tile overlays for this gas_mixture.  Updated by check_tile_graphic()
	var/list/graphic = list()
	//Cache of gas overlay objects
	var/list/tile_overlay_cache

/datum/gas_mixture/New(_volume = CELL_VOLUME, _temperature = 0, _group_multiplier = 1)
	volume = _volume
	temperature = _temperature
	group_multiplier = _group_multiplier

/datum/gas_mixture/proc/get_gas(gasid)
	if(!gas.len)
		return 0 //if the list is empty BYOND treats it as a non-associative list, which runtimes
	return gas[gasid] * group_multiplier

/datum/gas_mixture/proc/get_total_moles()
	return total_moles * group_multiplier

//Takes a gas string and the amount of moles to adjust by.  Calls update_values() if update isn't 0.
/datum/gas_mixture/proc/adjust_gas(gasid, moles, update = 1)
	if(moles == 0)
		return

	if (group_multiplier != 1)
		gas[gasid] += moles/group_multiplier
	else
		gas[gasid] += moles

	if(update)
		update_values()


//Same as adjust_gas(), but takes a temperature which is mixed in with the gas.
/datum/gas_mixture/proc/adjust_gas_temp(gasid, moles, temp, update = 1)
	if(moles == 0)
		return

	if(moles > 0 && abs(temperature - temp) > MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER)
		var/self_heat_capacity = heat_capacity()
		var/giver_heat_capacity = xgm_gas_data.specific_heat[gasid] * moles
		var/combined_heat_capacity = giver_heat_capacity + self_heat_capacity
		if(combined_heat_capacity != 0)
			temperature = (temp * giver_heat_capacity + temperature * self_heat_capacity) / combined_heat_capacity

	if (group_multiplier != 1)
		gas[gasid] += moles/group_multiplier
	else
		gas[gasid] += moles

	if(update)
		update_values()


//Variadic version of adjust_gas().  Takes any number of gas and mole pairs and applies them.
/datum/gas_mixture/proc/adjust_multi()
	ASSERT(!(args.len % 2))

	for(var/i = 1; i < args.len; i += 2)
		adjust_gas(args[i], args[i+1], update = 0)

	update_values()


//Variadic version of adjust_gas_temp().  Takes any number of gas, mole and temperature associations and applies them.
/datum/gas_mixture/proc/adjust_multi_temp()
	ASSERT(!(args.len % 3))

	for(var/i = 1; i < args.len; i += 3)
		adjust_gas_temp(args[i], args[i + 1], args[i + 2], update = 0)

	update_values()


//Merges all the gas from another mixture into this one.  Respects group_multipliers and adjusts temperature correctly.
//Does not modify giver in any way.
/datum/gas_mixture/proc/merge(const/datum/gas_mixture/giver)
	if(!giver)
		return

	if(abs(temperature-giver.temperature)>MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER)
		var/self_heat_capacity = heat_capacity()
		var/giver_heat_capacity = giver.heat_capacity()
		var/combined_heat_capacity = giver_heat_capacity + self_heat_capacity
		if(combined_heat_capacity != 0)
			temperature = (giver.temperature*giver_heat_capacity + temperature*self_heat_capacity)/combined_heat_capacity

	if((group_multiplier != 1)||(giver.group_multiplier != 1))
		for(var/g in giver.gas)
			gas[g] += giver.gas[g] * giver.group_multiplier / group_multiplier
	else
		for(var/g in giver.gas)
			gas[g] += giver.gas[g]

	update_values()

// Used to equalize the mixture between two zones before sleeping an edge.
/datum/gas_mixture/proc/equalize(datum/gas_mixture/sharer)
	var/our_heatcap = heat_capacity()
	var/share_heatcap = sharer.heat_capacity()

	// Special exception: there isn't enough air around to be worth processing this edge next tick, zap both to zero.
	if(total_moles + sharer.total_moles <= MINIMUM_AIR_TO_SUSPEND)
		gas.Cut()
		sharer.gas.Cut()

	for(var/g in gas|sharer.gas)
		var/comb = gas[g] + sharer.gas[g]
		comb /= volume + sharer.volume
		gas[g] = comb * volume
		sharer.gas[g] = comb * sharer.volume

	if(our_heatcap + share_heatcap)
		temperature = ((temperature * our_heatcap) + (sharer.temperature * share_heatcap)) / (our_heatcap + share_heatcap)
	sharer.temperature = temperature

	update_values()
	sharer.update_values()

	return 1


//Returns the heat capacity of the gas mix based on the specific heat of the gases.
/datum/gas_mixture/proc/heat_capacity()
	. = 0
	for(var/g in gas)
		. += xgm_gas_data.specific_heat[g] * gas[g]
	. *= group_multiplier


//Adds or removes thermal energy. Returns the actual thermal energy change, as in the case of removing energy we can't go below TCMB.
/datum/gas_mixture/proc/add_thermal_energy(var/thermal_energy)

	if (total_moles == 0)
		return 0

	var/heat_capacity = heat_capacity()
	if (thermal_energy < 0)
		if (temperature < TCMB)
			return 0
		var/thermal_energy_limit = -(temperature - TCMB)*heat_capacity	//ensure temperature does not go below TCMB
		thermal_energy = max( thermal_energy, thermal_energy_limit )	//thermal_energy and thermal_energy_limit are negative here.
	temperature += thermal_energy/heat_capacity
	return thermal_energy

//Returns the thermal energy change required to get to a new temperature
/datum/gas_mixture/proc/get_thermal_energy_change(var/new_temperature)
	return heat_capacity()*(max(new_temperature, 0) - temperature)


//Technically vacuum doesn't have a specific entropy. Just use a really big number (infinity would be ideal) here so that it's easy to add gas to vacuum and hard to take gas out.
#define SPECIFIC_ENTROPY_VACUUM		150000


//Returns the ideal gas specific entropy of the whole mix. This is the entropy per mole of /mixed/ gas.
/datum/gas_mixture/proc/specific_entropy()
	if (!gas.len || total_moles == 0)
		return SPECIFIC_ENTROPY_VACUUM

	. = 0
	for(var/g in gas)
		. += gas[g] * specific_entropy_gas(g)
	. /= total_moles


/*
	It's arguable whether this should even be called entropy anymore. It's more "based on" entropy than actually entropy now.

	Returns the ideal gas specific entropy of a specific gas in the mix. This is the entropy due to that gas per mole of /that/ gas in the mixture, not the entropy due to that gas per mole of gas mixture.

	For the purposes of SS13, the specific entropy is just a number that tells you how hard it is to move gas. You can replace this with whatever you want.
	Just remember that returning a SMALL number == adding gas to this gas mix is HARD, taking gas away is EASY, and that returning a LARGE number means the opposite (so a vacuum should approach infinity).

	So returning a constant/(partial pressure) would probably do what most players expect. Although the version I have implemented below is a bit more nuanced than simply 1/P in that it scales in a way
	which is bit more realistic (natural log), and returns a fairly accurate entropy around room temperatures and pressures.
*/
/datum/gas_mixture/proc/specific_entropy_gas(var/gasid)
	if (!(gasid in gas) || gas[gasid] == 0)
		return SPECIFIC_ENTROPY_VACUUM	//that gas isn't here

	//group_multiplier gets divided out in volume/gas[gasid] - also, V/(m*T) = R/(partial pressure)
	var/molar_mass = xgm_gas_data.molar_mass[gasid]
	var/specific_heat = xgm_gas_data.specific_heat[gasid]
	var/safe_temp = max(temperature, TCMB) // We're about to divide by this.
	return R_IDEAL_GAS_EQUATION * ( log( (IDEAL_GAS_ENTROPY_CONSTANT*volume/(gas[gasid] * safe_temp)) * (molar_mass*specific_heat*safe_temp)**(2/3) + 1 ) +  15 )

	//alternative, simpler equation
	//var/partial_pressure = gas[gasid] * R_IDEAL_GAS_EQUATION * temperature / volume
	//return R_IDEAL_GAS_EQUATION * ( log (1 + IDEAL_GAS_ENTROPY_CONSTANT/partial_pressure) + 20 )


//Updates the total_moles count and trims any empty gases.
/datum/gas_mixture/proc/update_values()
	total_moles = 0
	for(var/g in gas)
		if(gas[g] <= 0)
			gas -= g
		else
			total_moles += gas[g]


//Returns the pressure of the gas mix.  Only accurate if there have been no gas modifications since update_values() has been called.
/datum/gas_mixture/proc/return_pressure()
	if(volume)
		return total_moles * R_IDEAL_GAS_EQUATION * temperature / volume
	return 0


//Removes moles from the gas mixture and returns a gas_mixture containing the removed air.
/datum/gas_mixture/proc/remove(amount)
	RETURN_TYPE(/datum/gas_mixture)

	amount = min(amount, total_moles * group_multiplier) //Can not take more air than the gas mixture has!
	if(amount <= 0)
		return null

	var/datum/gas_mixture/removed = new

	for(var/g in gas)
		removed.gas[g] = QUANTIZE((gas[g] / total_moles) * amount)
		gas[g] -= removed.gas[g] / group_multiplier

	removed.temperature = temperature
	update_values()
	removed.update_values()

	return removed


//Removes a ratio of gas from the mixture and returns a gas_mixture containing the removed air.
/datum/gas_mixture/proc/remove_ratio(ratio, out_group_multiplier = 1)
	if(ratio <= 0)
		return null
	out_group_multiplier = clamp(out_group_multiplier, 1, group_multiplier)

	ratio = min(ratio, 1)

	var/datum/gas_mixture/removed = new
	removed.group_multiplier = out_group_multiplier

	for(var/g in gas)
		removed.gas[g] = (gas[g] * ratio * group_multiplier / out_group_multiplier)
		gas[g] = gas[g] * (1 - ratio)

	removed.temperature = temperature
	removed.volume = volume * group_multiplier / out_group_multiplier
	update_values()
	removed.update_values()

	return removed

//Removes a volume of gas from the mixture and returns a gas_mixture containing the removed air with the given volume
/datum/gas_mixture/proc/remove_volume(removed_volume)
	var/datum/gas_mixture/removed = remove_ratio(removed_volume/(volume*group_multiplier), 1)
	removed.volume = removed_volume
	return removed

//Removes moles from the gas mixture, limited by a given flag.  Returns a gax_mixture containing the removed air.
/datum/gas_mixture/proc/remove_by_flag(flag, amount)
	var/datum/gas_mixture/removed = new

	if(!flag || amount <= 0)
		return removed

	var/sum = 0
	for(var/g in gas)
		if(xgm_gas_data.flags[g] & flag)
			sum += gas[g]

	for(var/g in gas)
		if(xgm_gas_data.flags[g] & flag)
			removed.gas[g] = QUANTIZE((gas[g] / sum) * amount)
			gas[g] -= removed.gas[g] / group_multiplier

	removed.temperature = temperature
	update_values()
	removed.update_values()

	return removed

//Returns the amount of gas that has the given flag, in moles
/datum/gas_mixture/proc/get_by_flag(flag)
	. = 0
	for(var/g in gas)
		if(xgm_gas_data.flags[g] & flag)
			. += gas[g]

//Copies gas and temperature from another gas_mixture.
/datum/gas_mixture/proc/copy_from(const/datum/gas_mixture/sample)
	gas = sample.gas.Copy()
	temperature = sample.temperature

	update_values()
	return 1


//Checks if we are within acceptable range of another gas_mixture to suspend processing or merge.
/datum/gas_mixture/proc/compare(const/datum/gas_mixture/sample, var/vacuum_exception = 0)
	if(!sample) return 0

	if(vacuum_exception)
		// Special case - If one of the two is zero pressure, the other must also be zero.
		// This prevents suspending processing when an air-filled room is next to a vacuum,
		// an edge case which is particually obviously wrong to players
		if(total_moles == 0 && sample.total_moles != 0 || sample.total_moles == 0 && total_moles != 0)
			return 0

	var/list/marked = list()
	for(var/g in gas)
		if((abs(gas[g] - sample.gas[g]) > MINIMUM_AIR_TO_SUSPEND) && \
		((gas[g] < (1 - MINIMUM_AIR_RATIO_TO_SUSPEND) * sample.gas[g]) || \
		(gas[g] > (1 + MINIMUM_AIR_RATIO_TO_SUSPEND) * sample.gas[g])))
			return 0
		marked[g] = 1

	if(abs(return_pressure() - sample.return_pressure()) > MINIMUM_PRESSURE_DIFFERENCE_TO_SUSPEND)
		return 0

	for(var/g in sample.gas)
		if(!marked[g])
			if((abs(gas[g] - sample.gas[g]) > MINIMUM_AIR_TO_SUSPEND) && \
			((gas[g] < (1 - MINIMUM_AIR_RATIO_TO_SUSPEND) * sample.gas[g]) || \
			(gas[g] > (1 + MINIMUM_AIR_RATIO_TO_SUSPEND) * sample.gas[g])))
				return 0

	if(total_moles > MINIMUM_AIR_TO_SUSPEND)
		if((abs(temperature - sample.temperature) > MINIMUM_TEMPERATURE_DELTA_TO_SUSPEND) && \
		((temperature < (1 - MINIMUM_TEMPERATURE_RATIO_TO_SUSPEND)*sample.temperature) || \
		(temperature > (1 + MINIMUM_TEMPERATURE_RATIO_TO_SUSPEND)*sample.temperature)))
			return 0

	return 1

//Rechecks the gas_mixture and adjusts the graphic list if needed.
//Two lists can be passed by reference if you need know specifically which graphics were added and removed.
/datum/gas_mixture/proc/check_tile_graphic(list/graphic_add = null, list/graphic_remove = null)
	for(var/obj/effect/gas_overlay/O in graphic)
		if(gas[O.gas_id] <= xgm_gas_data.overlay_limit[O.gas_id])
			LAZYADD(graphic_remove, O)
	for(var/g in xgm_gas_data.overlay_limit)
		//Overlay isn't applied for this gas, check if it's valid and needs to be added.
		if(gas[g] > xgm_gas_data.overlay_limit[g])
			var/tile_overlay = get_tile_overlay(g)
			if(!(tile_overlay in graphic))
				LAZYADD(graphic_add, tile_overlay)
	. = 0
	//Apply changes
	if(graphic_add && graphic_add.len)
		graphic |= graphic_add
		. = 1
	if(graphic_remove && graphic_remove.len)
		graphic -= graphic_remove
		. = 1
	if(graphic.len)
		var/pressure_mod = clamp(return_pressure() / ONE_ATMOSPHERE, 0, 2)
		for(var/obj/effect/gas_overlay/O in graphic)
			var/concentration_mod = clamp(gas[O.gas_id] / total_moles, 0.1, 1)
			var/new_alpha = min(240, round(pressure_mod * concentration_mod * 180, 5))
			if(new_alpha != O.alpha)
				O.update_alpha_animation(new_alpha)

/datum/gas_mixture/proc/get_tile_overlay(gas_id)
	if(!LAZYACCESS(tile_overlay_cache, gas_id))
		LAZYSET(tile_overlay_cache, gas_id, new/obj/effect/gas_overlay(null, gas_id))
	return tile_overlay_cache[gas_id]

//Simpler version of merge(), adjusts gas amounts directly and doesn't account for temperature or group_multiplier.
/datum/gas_mixture/proc/add(datum/gas_mixture/right_side)
	for(var/g in right_side.gas)
		gas[g] += right_side.gas[g]

	update_values()
	return 1


//Simpler version of remove(), adjusts gas amounts directly and doesn't account for group_multiplier.
/datum/gas_mixture/proc/subtract(datum/gas_mixture/right_side)
	for(var/g in right_side.gas)
		gas[g] -= right_side.gas[g]

	update_values()
	return 1


//Multiply all gas amounts by a factor.
/datum/gas_mixture/proc/multiply(factor)
	for(var/g in gas)
		gas[g] *= factor

	update_values()
	return 1


//Divide all gas amounts by a factor.
/datum/gas_mixture/proc/divide(factor)
	for(var/g in gas)
		gas[g] /= factor

	update_values()
	return 1


//Shares gas with another gas_mixture based on the amount of connecting tiles and a fixed lookup table.
/datum/gas_mixture/proc/share_ratio(datum/gas_mixture/other, connecting_tiles, share_size = null, one_way = 0)
	var/static/list/sharing_lookup_table = list(0.30, 0.40, 0.48, 0.54, 0.60, 0.66)
	//Shares a specific ratio of gas between mixtures using simple weighted averages.
	var/ratio = sharing_lookup_table[6]

	var/size = max(1, group_multiplier)
	if(isnull(share_size)) share_size = max(1, other.group_multiplier)

	var/full_heat_capacity = heat_capacity()
	var/s_full_heat_capacity = other.heat_capacity()

	var/list/avg_gas = list()

	for(var/g in gas)
		avg_gas[g] += gas[g] * size

	for(var/g in other.gas)
		avg_gas[g] += other.gas[g] * share_size

	for(var/g in avg_gas)
		avg_gas[g] /= (size + share_size)

	var/temp_avg = 0
	if(full_heat_capacity + s_full_heat_capacity)
		temp_avg = (temperature * full_heat_capacity + other.temperature * s_full_heat_capacity) / (full_heat_capacity + s_full_heat_capacity)

	//WOOT WOOT TOUCH THIS AND YOU ARE A RETARD.
	if(sharing_lookup_table.len >= connecting_tiles) //6 or more interconnecting tiles will max at 42% of air moved per tick.
		ratio = sharing_lookup_table[connecting_tiles]
	//WOOT WOOT TOUCH THIS AND YOU ARE A RETARD

	for(var/g in avg_gas)
		gas[g] = max(0, (gas[g] - avg_gas[g]) * (1 - ratio) + avg_gas[g])
		if(!one_way)
			other.gas[g] = max(0, (other.gas[g] - avg_gas[g]) * (1 - ratio) + avg_gas[g])

	temperature = max(0, (temperature - temp_avg) * (1-ratio) + temp_avg)
	if(!one_way)
		other.temperature = max(0, (other.temperature - temp_avg) * (1-ratio) + temp_avg)

	update_values()
	other.update_values()

	return compare(other)


//A wrapper around share_ratio for spacing gas at the same rate as if it were going into a large airless room.
/datum/gas_mixture/proc/share_space(datum/gas_mixture/unsim_air)
	return share_ratio(unsim_air, unsim_air.group_multiplier, max(1, max(group_multiplier + 3, 1) + unsim_air.group_multiplier), one_way = 1)

/datum/gas_mixture/proc/get_mass()
	for(var/g in gas)
		. += gas[g] * xgm_gas_data.molar_mass[g] * group_multiplier

/datum/gas_mixture/proc/specific_mass()
	var/M = get_total_moles()
	if(M)
		return get_mass()/M

////LINDA COMPATABILITY PROCS////
/datum/gas_mixture/proc/return_volume()
	return max(0, volume)

/datum/gas_mixture/proc/return_temperature()
	return temperature

/datum/gas_mixture/proc/total_moles()
	update_values()
	return total_moles

/datum/gas_mixture/proc/has_gas(gas_id, required_amount)
	var/amt = get_gas(gas_id)
	return (amt >= required_amount)

/datum/gas_mixture/proc/get_gases()
	RETURN_TYPE(/list)
	update_values()
	return gas

/datum/gas_mixture/proc/return_visuals()
	update_values()
	check_tile_graphic()
	return graphic

/datum/gas_mixture/proc/copy()
	RETURN_TYPE(/datum/gas_mixture)
	var/datum/gas_mixture/new_gas = new
	update_values()
	new_gas.gas = src.gas
	new_gas.temperature = src.temperature
	new_gas.total_moles = src.total_moles
	return new_gas

/turf/open/proc/copy_air_with_tile(turf/open/target_turf)
	if(istype(target_turf))
		return_air().copy_from(target_turf.return_air())

/datum/gas_mixture/proc/leak_to_enviroment(datum/gas_mixture/environment)
	pump_gas_passive(src, environment, calculate_transfer_moles(src, environment, src.return_pressure() - environment.return_pressure()))

/**
 * Takes the amount of the gas you want to PP as an argument
 * So I don't have to do some hacky switches/defines/magic strings
 * eg:
 * Plas_PP = get_partial_pressure(gas_mixture.plasma)
 * O2_PP = get_partial_pressure(gas_mixture.oxygen)
 * get_breath_partial_pressure(gas_pp) --> gas_pp/total_moles()*breath_pp = pp
 * get_true_breath_pressure(pp) --> gas_pp = pp/breath_pp*total_moles()
 *
 * 10/20*5 = 2.5
 * 10 = 2.5/5*20
 */

/datum/gas_mixture/proc/get_breath_partial_pressure(gas_pressure)
	return (gas_pressure * R_IDEAL_GAS_EQUATION * temperature) / BREATH_VOLUME
///inverse
/datum/gas_mixture/proc/get_true_breath_pressure(partial_pressure)
	return (partial_pressure * BREATH_VOLUME) / (R_IDEAL_GAS_EQUATION * temperature)
