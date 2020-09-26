#ifdef EXTOOLS_BROKE

/datum/gas_mixture
	var/list/gases = list()
	var/temperature = 0 //kelvins
	var/tmp/temperature_archived = 0
	var/volume = CELL_VOLUME //liters
	var/last_share = 0

/datum/gas_mixture/heat_capacity() //joules per kelvin
	var/list/cached_gases = gases
	var/list/cached_gasheats = GLOB.meta_gas_specific_heats
	. = 0
	for(var/id in cached_gases)
		. += cached_gases[id] * cached_gasheats[id]

/datum/gas_mixture/turf/heat_capacity() // Same as above except vacuums return HEAT_CAPACITY_VACUUM
	var/list/cached_gases = gases
	var/list/cached_gasheats = GLOB.meta_gas_specific_heats
	for(var/id in cached_gases)
		. += cached_gases[id] * cached_gasheats[id]
	if(!.)
		. += HEAT_CAPACITY_VACUUM //we want vacuums in turfs to have the same heat capacity as space

//prefer this to gas_mixture/total_moles in performance critical areas
#define TOTAL_MOLES(cached_gases, out_var)\
	out_var = 0;\
	for(var/total_moles_id in cached_gases){\
		out_var += cached_gases[total_moles_id];\
	}

#define THERMAL_ENERGY(gas) (gas.temperature * gas.heat_capacity())

/datum/gas_mixture/total_moles()
	var/cached_gases = gases
	TOTAL_MOLES(cached_gases, .)

/datum/gas_mixture/return_pressure() //kilopascals
	if(volume > 0) // to prevent division by zero
		var/cached_gases = gases
		TOTAL_MOLES(cached_gases, .)
		. *= R_IDEAL_GAS_EQUATION * temperature / volume
		return
	return 0

/datum/gas_mixture/return_temperature() //kelvins
	return temperature

/datum/gas_mixture/set_min_heat_capacity(n)
	return
/datum/gas_mixture/set_temperature(new_temp)
	temperature = new_temp
/datum/gas_mixture/set_volume(new_volume)
	volume = new_volume
/datum/gas_mixture/get_moles(gas_type)
	return gases[gas_type]
/datum/gas_mixture/set_moles(gas_type, moles)
	gases[gas_type] = moles
/datum/gas_mixture/scrub_into(datum/gas_mixture/target, list/gases)
	if(isnull(target))
		return FALSE

	var/list/removed_gases = target.gases

	//Filter it
	var/datum/gas_mixture/filtered_out = new
	var/list/filtered_gases = filtered_out.gases
	filtered_out.temperature = removed.temperature
	for(var/gas in filter_types & removed_gases)
		filtered_gases[gas] = removed_gases[gas]
		removed_gases[gas] = 0
	merge(filtered_out)
/datum/gas_mixture/mark_immutable()
	return
/datum/gas_mixture/get_gases()
	return gases
/datum/gas_mixture/multiply(factor)
	for(var/id in gases)
		gases[id] *= factor
/datum/gas_mixture/get_last_share()
	return last_share
/datum/gas_mixture/clear()
	gases.Cut()

/datum/gas_mixture/return_volume()
	return volume // wow!

/datum/gas_mixture/thermal_energy()
	return THERMAL_ENERGY(src)

/datum/gas_mixture/archive()
	temperature_archived = temperature
	gas_archive = gases.Copy()
	return 1

/datum/gas_mixture/merge(datum/gas_mixture/giver)
	if(!giver)
		return 0

	//heat transfer
	if(abs(temperature - giver.temperature) > MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER)
		var/self_heat_capacity = heat_capacity()
		var/giver_heat_capacity = giver.heat_capacity()
		var/combined_heat_capacity = giver_heat_capacity + self_heat_capacity
		if(combined_heat_capacity)
			temperature = (giver.temperature * giver_heat_capacity + temperature * self_heat_capacity) / combined_heat_capacity

	var/list/cached_gases = gases //accessing datum vars is slower than proc vars
	var/list/giver_gases = giver.gases
	//gas transfer
	for(var/giver_id in giver_gases)
		cached_gases[giver_id] += giver_gases[giver_id]

	return 1

/datum/gas_mixture/remove(amount)
	var/sum
	var/list/cached_gases = gases
	TOTAL_MOLES(cached_gases, sum)
	amount = min(amount, sum) //Can not take more air than tile has!
	if(amount <= 0)
		return null
	var/datum/gas_mixture/removed = new type
	var/list/removed_gases = removed.gases //accessing datum vars is slower than proc vars

	removed.temperature = temperature
	for(var/id in cached_gases)
		removed_gases[id] = QUANTIZE((cached_gases[id] / sum) * amount)
		cached_gases[id] -= removed_gases[id]
	GAS_GARBAGE_COLLECT(gases)

	return removed

/datum/gas_mixture/remove_ratio(ratio)
	if(ratio <= 0)
		return null
	ratio = min(ratio, 1)

	var/list/cached_gases = gases
	var/datum/gas_mixture/removed = new type
	var/list/removed_gases = removed.gases //accessing datum vars is slower than proc vars

	removed.temperature = temperature
	for(var/id in cached_gases)
		removed_gases[id] = QUANTIZE(cached_gases[id] * ratio)
		cached_gases[id] -= removed_gases[id]

	GAS_GARBAGE_COLLECT(gases)

	return removed

/datum/gas_mixture/copy()
	var/list/cached_gases = gases
	var/datum/gas_mixture/copy = new type
	var/list/copy_gases = copy.gases

	copy.temperature = temperature
	for(var/id in cached_gases)
		copy_gases[id] = cached_gases[id]

	return copy


/datum/gas_mixture/copy_from(datum/gas_mixture/sample)
	var/list/cached_gases = gases //accessing datum vars is slower than proc vars
	var/list/sample_gases = sample.gases

	temperature = sample.temperature
	for(var/id in sample_gases)
		cached_gases[id] = sample_gases[id]

	//remove all gases not in the sample
	cached_gases &= sample_gases

	return 1

/datum/gas_mixture/copy_from_turf(turf/model)
	parse_gas_string(model.initial_gas_mix)

	//acounts for changes in temperature
	var/turf/model_parent = model.parent_type
	if(model.temperature != initial(model.temperature) || model.temperature != initial(model_parent.temperature))
		temperature = model.temperature

	return 1

/datum/gas_mixture/share(datum/gas_mixture/sharer, atmos_adjacent_turfs = 4)

	var/list/cached_gases = gases
	var/list/sharer_gases = sharer.gases

	var/temperature_delta = temperature_archived - sharer.temperature_archived
	var/abs_temperature_delta = abs(temperature_delta)

	var/old_self_heat_capacity = 0
	var/old_sharer_heat_capacity = 0
	if(abs_temperature_delta > MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER)
		old_self_heat_capacity = heat_capacity()
		old_sharer_heat_capacity = sharer.heat_capacity()

	var/heat_capacity_self_to_sharer = 0 //heat capacity of the moles transferred from us to the sharer
	var/heat_capacity_sharer_to_self = 0 //heat capacity of the moles transferred from the sharer to us

	var/moved_moles = 0
	var/abs_moved_moles = 0

	//we're gonna define these vars outside of this for loop because as it turns out, var declaration is pricy
	var/delta
	var/gas_heat_capacity
	//and also cache this shit rq because that results in sanic speed for reasons byond explanation
	var/list/cached_gasheats = GLOB.meta_gas_specific_heats
	//GAS TRANSFER
	for(var/id in cached_gases | sharer_gases) // transfer gases

		delta = QUANTIZE(gas_archive[id] - sharer.gas_archive[id])/(atmos_adjacent_turfs+1) //the amount of gas that gets moved between the mixtures

		if(delta && abs_temperature_delta > MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER)
			gas_heat_capacity = delta * cached_gasheats[id]
			if(delta > 0)
				heat_capacity_self_to_sharer += gas_heat_capacity
			else
				heat_capacity_sharer_to_self -= gas_heat_capacity //subtract here instead of adding the absolute value because we know that delta is negative.

		cached_gases[id]					-= delta
		sharer_gases[id]			+= delta
		moved_moles			+= delta
		abs_moved_moles		+= abs(delta)

	last_share = abs_moved_moles

	//THERMAL ENERGY TRANSFER
	if(abs_temperature_delta > MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER)
		var/new_self_heat_capacity = old_self_heat_capacity + heat_capacity_sharer_to_self - heat_capacity_self_to_sharer
		var/new_sharer_heat_capacity = old_sharer_heat_capacity + heat_capacity_self_to_sharer - heat_capacity_sharer_to_self

		//transfer of thermal energy (via changed heat capacity) between self and sharer
		if(new_self_heat_capacity > MINIMUM_HEAT_CAPACITY)
			temperature = (old_self_heat_capacity*temperature - heat_capacity_self_to_sharer*temperature_archived + heat_capacity_sharer_to_self*sharer.temperature_archived)/new_self_heat_capacity

		if(new_sharer_heat_capacity > MINIMUM_HEAT_CAPACITY)
			sharer.temperature = (old_sharer_heat_capacity*sharer.temperature-heat_capacity_sharer_to_self*sharer.temperature_archived + heat_capacity_self_to_sharer*temperature_archived)/new_sharer_heat_capacity
		//thermal energy of the system (self and sharer) is unchanged

			if(abs(old_sharer_heat_capacity) > MINIMUM_HEAT_CAPACITY)
				if(abs(new_sharer_heat_capacity/old_sharer_heat_capacity - 1) < 0.1) // <10% change in sharer heat capacity
					temperature_share(sharer, OPEN_HEAT_TRANSFER_COEFFICIENT)

	if (initial(sharer.gc_share))
		GAS_GARBAGE_COLLECT(sharer.gases)
	if(temperature_delta > MINIMUM_TEMPERATURE_TO_MOVE || abs(moved_moles) > MINIMUM_MOLES_DELTA_TO_MOVE)
		var/our_moles
		TOTAL_MOLES(cached_gases,our_moles)
		var/their_moles
		TOTAL_MOLES(sharer_gases,their_moles)
		return (temperature_archived*(our_moles + moved_moles) - sharer.temperature_archived*(their_moles - moved_moles)) * R_IDEAL_GAS_EQUATION / volume

/datum/gas_mixture/temperature_share(datum/gas_mixture/sharer, conduction_coefficient, sharer_temperature, sharer_heat_capacity)
	//transfer of thermal energy (via conduction) between self and sharer
	if(sharer)
		sharer_temperature = sharer.temperature_archived
	var/temperature_delta = temperature_archived - sharer_temperature
	if(abs(temperature_delta) > MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER)
		var/self_heat_capacity = archived_heat_capacity()
		sharer_heat_capacity = sharer_heat_capacity || sharer.archived_heat_capacity()

		if((sharer_heat_capacity > MINIMUM_HEAT_CAPACITY) && (self_heat_capacity > MINIMUM_HEAT_CAPACITY))
			var/heat = conduction_coefficient*temperature_delta* \
				(self_heat_capacity*sharer_heat_capacity/(self_heat_capacity+sharer_heat_capacity))

			temperature = max(temperature - heat/self_heat_capacity, TCMB)
			sharer_temperature = max(sharer_temperature + heat/sharer_heat_capacity, TCMB)
			if(sharer)
				sharer.temperature = sharer_temperature
	return sharer_temperature
	//thermal energy of the system (self and sharer) is unchanged

/datum/gas_mixture/compare(datum/gas_mixture/sample)
	var/list/sample_gases = sample.gases //accessing datum vars is slower than proc vars
	var/list/cached_gases = gases

	for(var/id in cached_gases | sample_gases) // compare gases from either mixture
		var/gas_moles = cached_gases[id]
		var/sample_moles = sample_gases[id]
		var/delta = abs(gas_moles - sample_moles)
		if(delta > MINIMUM_MOLES_DELTA_TO_MOVE && \
			delta > gas_moles * MINIMUM_AIR_RATIO_TO_MOVE)
			return id

	var/our_moles
	TOTAL_MOLES(cached_gases, our_moles)
	if(our_moles > MINIMUM_MOLES_DELTA_TO_MOVE)
		var/temp = temperature
		var/sample_temp = sample.temperature

		var/temperature_delta = abs(temp - sample_temp)
		if(temperature_delta > MINIMUM_TEMPERATURE_DELTA_TO_SUSPEND)
			return "temp"

	return ""

/datum/gas_mixture/transfer_to(datum/gas_mixture/target, amount)
	return merge(target.remove(amount))

#endif
