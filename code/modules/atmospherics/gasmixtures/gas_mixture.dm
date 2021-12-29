/*
What are the archived variables for?
Calculations are done using the archived variables with the results merged into the regular variables.
This prevents race conditions that arise based on the order of tile processing.
*/

#define QUANTIZE(variable) (round((variable), (MOLAR_ACCURACY)))
GLOBAL_LIST_INIT(meta_gas_info, meta_gas_list()) //see ATMOSPHERICS/gas_types.dm
GLOBAL_LIST_INIT(gaslist_cache, init_gaslist_cache())

/proc/init_gaslist_cache()
	. = list()
	for(var/id in GLOB.meta_gas_info)
		var/list/cached_gas = new(3)

		.[id] = cached_gas

		cached_gas[MOLES] = 0
		cached_gas[ARCHIVE] = 0
		cached_gas[GAS_META] = GLOB.meta_gas_info[id]

/datum/gas_mixture
	var/list/gases
	var/temperature = 0 //kelvins
	var/tmp/temperature_archived = 0
	var/volume = CELL_VOLUME //liters
	var/last_share = 0
	/// The fire key contains information that might determine the volume of hotspots.
	var/list/reaction_results
	/// Used for analyzer feedback - not initialized until its used
	var/list/analyzer_results
	/// Whether to call garbage_collect() on the sharer during shares, used for immutable mixtures
	var/gc_share = FALSE

/datum/gas_mixture/New(volume)
	gases = new
	if (!isnull(volume))
		src.volume = volume
	reaction_results = new

//listmos procs
//use the macros in performance intensive areas. for their definitions, refer to code/__DEFINES/atmospherics.dm

///assert_gas(gas_id) - used to guarantee that the gas list for this id exists in gas_mixture.gases.
///Must be used before adding to a gas. May be used before reading from a gas.
/datum/gas_mixture/proc/assert_gas(gas_id)
	ASSERT_GAS(gas_id, gases)

///assert_gases(args) - shorthand for calling ASSERT_GAS() once for each gas type.
/datum/gas_mixture/proc/assert_gases(...)
	for(var/id in args)
		ASSERT_GAS(id, gases)

///add_gas(gas_id) - similar to assert_gas(), but does not check for an existing gas list for this id. This can clobber existing gases.
///Used instead of assert_gas() when you know the gas does not exist. Faster than assert_gas().
/datum/gas_mixture/proc/add_gas(gas_id)
	ADD_GAS(gas_id, gases)

///add_gases(args) - shorthand for calling add_gas() once for each gas_type.
/datum/gas_mixture/proc/add_gases(...)
	var/cached_gases = gases
	for(var/id in args)
		ADD_GAS(id, cached_gases)

///garbage_collect() - removes any gas list which is empty.
///If called with a list as an argument, only removes gas lists with IDs from that list.
///Must be used after subtracting from a gas. Must be used after assert_gas()
///if assert_gas() was called only to read from the gas.
///By removing empty gases, processing speed is increased.
/datum/gas_mixture/proc/garbage_collect(list/tocheck)
	var/list/cached_gases = gases
	for(var/id in (tocheck || cached_gases))
		if(QUANTIZE(cached_gases[id][MOLES]) <= 0)
			cached_gases -= id

//PV = nRT

///joules per kelvin
/datum/gas_mixture/proc/heat_capacity(data = MOLES)
	var/list/cached_gases = gases
	. = 0
	for(var/id in cached_gases)
		var/gas_data = cached_gases[id]
		. += gas_data[data] * gas_data[GAS_META][META_GAS_SPECIFIC_HEAT]

/// Same as above except vacuums return HEAT_CAPACITY_VACUUM
/datum/gas_mixture/turf/heat_capacity(data = MOLES)
	var/list/cached_gases = gases
	. = 0
	for(var/id in cached_gases)
		var/gas_data = cached_gases[id]
		. += gas_data[data] * gas_data[GAS_META][META_GAS_SPECIFIC_HEAT]
	if(!.)
		. += HEAT_CAPACITY_VACUUM //we want vacuums in turfs to have the same heat capacity as space

/// Calculate moles
/datum/gas_mixture/proc/total_moles()
	var/cached_gases = gases
	TOTAL_MOLES(cached_gases, .)

/// Checks to see if gas amount exists in mixture.
/// Do NOT use this in code where performance matters!
/// It's better to batch calls to garbage_collect(), especially in places where you're checking many gastypes
/datum/gas_mixture/proc/has_gas(gas_id, amount=0)
	ASSERT_GAS(gas_id, gases)
	var/is_there_gas = amount < gases[gas_id][MOLES]
	garbage_collect()
	return is_there_gas

/// Calculate pressure in kilopascals
/datum/gas_mixture/proc/return_pressure()
	if(volume) // to prevent division by zero
		var/cached_gases = gases
		TOTAL_MOLES(cached_gases, .)
		. *= R_IDEAL_GAS_EQUATION * temperature / volume
		return
	return 0

/// Calculate temperature in kelvins
/datum/gas_mixture/proc/return_temperature()
	return temperature

/// Calculate volume in liters
/datum/gas_mixture/proc/return_volume()
	return max(0, volume)

/// Gets the gas visuals for everything in this mixture
/datum/gas_mixture/proc/return_visuals()
	var/list/output
	GAS_OVERLAYS(gases, output)
	return output

/// Calculate thermal energy in joules
/datum/gas_mixture/proc/thermal_energy()
	return THERMAL_ENERGY(src) //see code/__DEFINES/atmospherics.dm; use the define in performance critical areas

///Update archived versions of variables. Returns: TRUE in all cases
/datum/gas_mixture/proc/archive()
	var/list/cached_gases = gases

	temperature_archived = temperature
	for(var/id in cached_gases)
		cached_gases[id][ARCHIVE] = cached_gases[id][MOLES]

	return TRUE

///Merges all air from giver into self. Deletes giver. Returns: 1 if we are mutable, 0 otherwise
/datum/gas_mixture/proc/merge(datum/gas_mixture/giver)
	if(!giver)
		return FALSE

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
		ASSERT_GAS(giver_id, cached_gases)
		cached_gases[giver_id][MOLES] += giver_gases[giver_id][MOLES]

	return TRUE

///Proportionally removes amount of gas from the gas_mixture.
///Returns: gas_mixture with the gases removed
/datum/gas_mixture/proc/remove(amount)
	var/sum
	var/list/cached_gases = gases
	TOTAL_MOLES(cached_gases, sum)
	amount = min(amount, sum) //Can not take more air than tile has!
	if(amount <= 0)
		return null
	var/ratio = amount / sum
	var/datum/gas_mixture/removed = new type
	var/list/removed_gases = removed.gases //accessing datum vars is slower than proc vars

	removed.temperature = temperature
	for(var/id in cached_gases)
		ADD_GAS(id, removed.gases)
		removed_gases[id][MOLES] = QUANTIZE(cached_gases[id][MOLES] * ratio)
		cached_gases[id][MOLES] -= removed_gases[id][MOLES]
	garbage_collect()

	return removed

///Proportionally removes amount of gas from the gas_mixture.
///Returns: gas_mixture with the gases removed
/datum/gas_mixture/proc/remove_ratio(ratio)
	if(ratio <= 0)
		return null
	ratio = min(ratio, 1)

	var/list/cached_gases = gases
	var/datum/gas_mixture/removed = new type
	var/list/removed_gases = removed.gases //accessing datum vars is slower than proc vars

	removed.temperature = temperature
	for(var/id in cached_gases)
		ADD_GAS(id, removed.gases)
		removed_gases[id][MOLES] = QUANTIZE(cached_gases[id][MOLES] * ratio)
		cached_gases[id][MOLES] -= removed_gases[id][MOLES]

	garbage_collect()

	return removed

///Removes an amount of a specific gas from the gas_mixture.
///Returns: gas_mixture with the gas removed
/datum/gas_mixture/proc/remove_specific(gas_id, amount)
	var/list/cached_gases = gases
	amount = min(amount, cached_gases[gas_id][MOLES])
	if(amount <= 0)
		return null
	var/datum/gas_mixture/removed = new type
	var/list/removed_gases = removed.gases
	removed.temperature = temperature
	ADD_GAS(gas_id, removed.gases)
	removed_gases[gas_id][MOLES] = amount
	cached_gases[gas_id][MOLES] -= amount

	garbage_collect(list(gas_id))
	return removed

/datum/gas_mixture/proc/remove_specific_ratio(gas_id, ratio)
	if(ratio <= 0)
		return null
	ratio = min(ratio, 1)

	var/list/cached_gases = gases
	var/datum/gas_mixture/removed = new type
	var/list/removed_gases = removed.gases //accessing datum vars is slower than proc vars

	removed.temperature = temperature
	ADD_GAS(gas_id, removed.gases)
	removed_gases[gas_id][MOLES] = QUANTIZE(cached_gases[gas_id][MOLES] * ratio)
	cached_gases[gas_id][MOLES] -= removed_gases[gas_id][MOLES]

	garbage_collect(list(gas_id))

	return removed

///Distributes the contents of two mixes equally between themselves
//Returns: bool indicating whether gases moved between the two mixes
/datum/gas_mixture/proc/equalize(datum/gas_mixture/other)
	. = FALSE
	if(abs(return_temperature() - other.return_temperature()) > MINIMUM_TEMPERATURE_DELTA_TO_SUSPEND)
		. = TRUE
		var/self_heat_cap = heat_capacity()
		var/other_heat_cap = other.heat_capacity()
		var/new_temp = (temperature * self_heat_cap + other.temperature * other_heat_cap) / (self_heat_cap + other_heat_cap)
		temperature = new_temp
		other.temperature = new_temp

	var/min_p_delta = 0.1
	var/total_volume = volume + other.volume
	var/list/gas_list = gases | other.gases
	for(var/gas_id in gas_list)
		assert_gas(gas_id)
		other.assert_gas(gas_id)
		//math is under the assumption temperatures are equal
		if(abs(gases[gas_id][MOLES] / volume - other.gases[gas_id][MOLES] / other.volume) > min_p_delta / (R_IDEAL_GAS_EQUATION * temperature))
			. = TRUE
			var/total_moles = gases[gas_id][MOLES] + other.gases[gas_id][MOLES]
			gases[gas_id][MOLES] = total_moles * (volume/total_volume)
			other.gases[gas_id][MOLES] = total_moles * (other.volume/total_volume)
	garbage_collect()
	other.garbage_collect()

///Creates new, identical gas mixture
///Returns: duplicate gas mixture
/datum/gas_mixture/proc/copy()
	var/list/cached_gases = gases
	var/datum/gas_mixture/copy = new type
	var/list/copy_gases = copy.gases

	copy.temperature = temperature
	for(var/id in cached_gases)
		ADD_GAS(id, copy.gases)
		copy_gases[id][MOLES] = cached_gases[id][MOLES]

	return copy

///Copies variables from sample, moles multiplied by partial.
///Returns: TRUE if we are mutable, null otherwise
/datum/gas_mixture/proc/copy_from(datum/gas_mixture/sample, partial = 1)
	var/list/cached_gases = gases //accessing datum vars is slower than proc vars
	var/list/sample_gases = sample.gases

	//remove all gases not in the sample
	cached_gases &= sample_gases

	temperature = sample.temperature
	for(var/id in sample_gases)
		ASSERT_GAS(id, cached_gases)
		cached_gases[id][MOLES] = sample_gases[id][MOLES] * partial

	return TRUE

///Copies all gas info from the turf into the gas list along with temperature
///Returns: TRUE if we are mutable, FALSE otherwise
/datum/gas_mixture/proc/copy_from_turf(turf/model)
	parse_gas_string(model.initial_gas_mix)

	//acounts for changes in temperature
	var/turf/model_parent = model.parent_type
	if(model.temperature != initial(model.temperature) || model.temperature != initial(model_parent.temperature))
		temperature = model.temperature

	return TRUE

///Copies variables from a particularly formatted string.
///Returns: 1 if we are mutable, 0 otherwise
/datum/gas_mixture/proc/parse_gas_string(gas_string)
	gas_string = SSair.preprocess_gas_string(gas_string)

	var/list/gases = src.gases
	var/list/gas = params2list(gas_string)
	if(gas["TEMP"])
		temperature = text2num(gas["TEMP"])
		temperature_archived = temperature
		gas -= "TEMP"
	else // if we do not have a temp in the new gas mix lets assume room temp.
		temperature = T20C
	gases.Cut()
	for(var/id in gas)
		var/path = id
		if(!ispath(path))
			path = gas_id2path(path) //a lot of these strings can't have embedded expressions (especially for mappers), so support for IDs needs to stick around
		ADD_GAS(path, gases)
		gases[path][MOLES] = text2num(gas[id])
	return 1

///Performs air sharing calculations between two gas_mixtures assuming only 1 boundary length.
///Returns: amount of gas exchanged (+ if sharer received).
///sharer - the other gas mixture we are moving part of our gas into
/datum/gas_mixture/proc/share(datum/gas_mixture/sharer, atmos_adjacent_turfs = 4)
	var/list/cached_gases = gases
	var/list/sharer_gases = sharer.gases

	var/temperature_delta = abs(temperature_archived - sharer.temperature_archived)

	var/heat_capacity_self_to_sharer = 0 //heat capacity of the moles transferred from us to the sharer
	var/heat_capacity_sharer_to_self = 0 //heat capacity of the moles transferred from the sharer to us

	var/moved_moles = 0
	var/abs_moved_moles = 0

	//GAS TRANSFER
	for(var/new_gas_id in sharer_gases - cached_gases) // create gases not in our cache
		ADD_GAS(new_gas_id, cached_gases)
	for(var/id in cached_gases) // transfer gases
		ASSERT_GAS(id, sharer_gases)

		var/gas = cached_gases[id]
		var/sharergas = sharer_gases[id]

		///the amount of gas that gets moved between the mixtures.
		var/gas_delta = QUANTIZE(gas[ARCHIVE] - sharergas[ARCHIVE]) / (atmos_adjacent_turfs + 1)

		if(gas_delta && temperature_delta > MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER)
			var/gas_heat_capacity = gas_delta * gas[GAS_META][META_GAS_SPECIFIC_HEAT]
			if(gas_delta > 0)
				heat_capacity_self_to_sharer += gas_heat_capacity
			else
				heat_capacity_sharer_to_self -= gas_heat_capacity //subtract here instead of adding the absolute value because we know that delta is negative.

		gas[MOLES] -= gas_delta
		sharergas[MOLES] += gas_delta
		moved_moles += gas_delta
		abs_moved_moles += abs(gas_delta)

	last_share = abs_moved_moles

	//THERMAL ENERGY TRANSFER
	if(temperature_delta > MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER)
		var/old_self_heat_capacity = heat_capacity(ARCHIVE)
		var/old_sharer_heat_capacity = sharer.heat_capacity(ARCHIVE)

		var/new_self_heat_capacity = old_self_heat_capacity + heat_capacity_sharer_to_self - heat_capacity_self_to_sharer
		var/new_sharer_heat_capacity = old_sharer_heat_capacity + heat_capacity_self_to_sharer - heat_capacity_sharer_to_self

		//transfer of thermal energy (via changed heat capacity) between self and sharer
		if(new_self_heat_capacity > MINIMUM_HEAT_CAPACITY)
			temperature = (old_self_heat_capacity*temperature - heat_capacity_self_to_sharer*temperature_archived + heat_capacity_sharer_to_self*sharer.temperature_archived)/new_self_heat_capacity

		if(new_sharer_heat_capacity > MINIMUM_HEAT_CAPACITY)
			sharer.temperature = (old_sharer_heat_capacity*sharer.temperature-heat_capacity_sharer_to_self*sharer.temperature_archived + heat_capacity_self_to_sharer*temperature_archived)/new_sharer_heat_capacity
		//thermal energy of the system (self and sharer) is unchanged

			if(abs(old_sharer_heat_capacity) > MINIMUM_HEAT_CAPACITY)
				if(abs(new_sharer_heat_capacity / old_sharer_heat_capacity - 1) < 0.1) // <10% change in sharer heat capacity
					temperature_share(sharer, OPEN_HEAT_TRANSFER_COEFFICIENT)

	garbage_collect()
	sharer.garbage_collect()
	if(temperature_delta > MINIMUM_TEMPERATURE_TO_MOVE || abs(moved_moles) > MINIMUM_MOLES_DELTA_TO_MOVE)
		var/our_moles
		TOTAL_MOLES(cached_gases, our_moles)
		var/their_moles
		TOTAL_MOLES(sharer_gases, their_moles)
		return (temperature_archived*(our_moles + moved_moles) - sharer.temperature_archived*(their_moles - moved_moles)) * R_IDEAL_GAS_EQUATION / volume

///Performs temperature sharing calculations (via conduction) between two gas_mixtures assuming only 1 boundary length
///Returns: new temperature of the sharer
/datum/gas_mixture/proc/temperature_share(datum/gas_mixture/sharer, conduction_coefficient, sharer_temperature, sharer_heat_capacity)
	//transfer of thermal energy (via conduction) between self and sharer
	if(sharer)
		sharer_temperature = sharer.temperature_archived
	var/temperature_delta = temperature_archived - sharer_temperature
	if(abs(temperature_delta) > MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER)
		var/self_heat_capacity = heat_capacity(ARCHIVE)
		sharer_heat_capacity = sharer_heat_capacity || sharer.heat_capacity(ARCHIVE)

		if((sharer_heat_capacity > MINIMUM_HEAT_CAPACITY) && (self_heat_capacity > MINIMUM_HEAT_CAPACITY))
			var/heat = conduction_coefficient*temperature_delta* \
				(self_heat_capacity*sharer_heat_capacity/(self_heat_capacity+sharer_heat_capacity))

			temperature = max(temperature - heat/self_heat_capacity, TCMB)
			sharer_temperature = max(sharer_temperature + heat/sharer_heat_capacity, TCMB)
			if(sharer)
				sharer.temperature = sharer_temperature
				if (initial(sharer.gc_share))
					sharer.garbage_collect()
	return sharer_temperature
	//thermal energy of the system (self and sharer) is unchanged

///Compares sample to self to see if within acceptable ranges that group processing may be enabled.
///Returns: a string indicating what check failed, or "" if check passes
/datum/gas_mixture/proc/compare(datum/gas_mixture/sample)
	var/list/sample_gases = sample.gases //accessing datum vars is slower than proc vars
	var/list/cached_gases = gases

	var/our_moles = 0
	for(var/id in cached_gases | sample_gases) // compare gases from either mixture
		var/gas_moles = cached_gases[id]?[MOLES]

		var/delta = abs(gas_moles - sample_gases[id]?[MOLES])
		if(delta > MINIMUM_MOLES_DELTA_TO_MOVE && delta > gas_moles * MINIMUM_AIR_RATIO_TO_MOVE)
			return id

		our_moles += gas_moles

	if(our_moles > MINIMUM_MOLES_DELTA_TO_MOVE) //Don't consider temp if there's not enough mols
		if(abs(temperature - sample.temperature) > MINIMUM_TEMPERATURE_DELTA_TO_SUSPEND)
			return "temp"

	return ""

///Performs various reactions such as combustion and fabrication
///Returns: 1 if any reaction took place; 0 otherwise
/datum/gas_mixture/proc/react(datum/holder)
	. = NO_REACTION
	var/list/cached_gases = gases
	if(!length(cached_gases))
		return

	var/list/pre_formation = list()
	var/list/mid_formation = list()
	var/list/post_formation = list()
	var/list/fires = list()
	var/static/list/gas_reactions = SSair.gas_reactions
	for(var/gas_id in cached_gases)
		var/list/reaction_set = gas_reactions[gas_id]
		if(!reaction_set)
			continue
		pre_formation += reaction_set[PRIORITY_PRE_FORMATION]
		mid_formation += reaction_set[PRIORITY_FORMATION]
		post_formation += reaction_set[PRIORITY_POST_FORMATION]
		fires += reaction_set[PRIORITY_FIRE]

	var/list/reactions = pre_formation + mid_formation + post_formation + fires

	if(!length(reactions))
		return

	//Fuck you
	if(cached_gases[/datum/gas/hypernoblium] && cached_gases[/datum/gas/hypernoblium][MOLES] >= REACTION_OPPRESSION_THRESHOLD && temperature > 20)
		return STOP_REACTIONS

	reaction_results = new
	//It might be worth looking into updating these after each reaction, but that makes us care more about order of operations, so be careful
	var/temp = temperature
	reaction_loop:
		for(var/datum/gas_reaction/reaction as anything in reactions)

			var/list/reqs = reaction.requirements
			if((reqs["MIN_TEMP"] && temp < reqs["MIN_TEMP"]) || (reqs["MAX_TEMP"] && temp > reqs["MAX_TEMP"]))
				continue

			for(var/id in reqs)
				if (id == "MIN_TEMP" || id == "MAX_TEMP")
					continue
				if(!cached_gases[id] || cached_gases[id][MOLES] < reqs[id])
					continue reaction_loop

			//at this point, all requirements for the reaction are satisfied. we can now react()
			. |= reaction.react(src, holder)


	if(.) //If we changed the mix to any degree
		garbage_collect()

///Takes the amount of the gas you want to PP as an argument
///So I don't have to do some hacky switches/defines/magic strings
///eg:
///Plas_PP = get_partial_pressure(gas_mixture.plasma)
///O2_PP = get_partial_pressure(gas_mixture.oxygen)

/datum/gas_mixture/proc/get_breath_partial_pressure(gas_pressure)
	return (gas_pressure * R_IDEAL_GAS_EQUATION * temperature) / BREATH_VOLUME
///inverse
/datum/gas_mixture/proc/get_true_breath_pressure(partial_pressure)
	return (partial_pressure * BREATH_VOLUME) / (R_IDEAL_GAS_EQUATION * temperature)

///Mathematical proofs:
/**
get_breath_partial_pressure(gas_pp) --> gas_pp/total_moles()*breath_pp = pp
get_true_breath_pressure(pp) --> gas_pp = pp/breath_pp*total_moles()

10/20*5 = 2.5
10 = 2.5/5*20
**/

/// Pumps gas from src to output_air. Amount depends on target_pressure
/datum/gas_mixture/proc/pump_gas_to(datum/gas_mixture/output_air, target_pressure, specific_gas = null)
	var/output_starting_pressure = output_air.return_pressure()

	if((target_pressure - output_starting_pressure) < 0.01)
		//No need to pump gas if target is already reached!
		return FALSE

	//Calculate necessary moles to transfer using PV=nRT
	if((total_moles() > 0) && (temperature>0))
		var/pressure_delta = target_pressure - output_starting_pressure
		var/transfer_moles = (pressure_delta*output_air.volume)/(temperature * R_IDEAL_GAS_EQUATION)

		//Actually transfer the gas
		if(specific_gas)
			var/datum/gas_mixture/removed = remove_specific(specific_gas, transfer_moles)
			output_air.merge(removed)
			return TRUE
		var/datum/gas_mixture/removed = remove(transfer_moles)
		output_air.merge(removed)
		return TRUE
	return FALSE

/// Releases gas from src to output air. This means that it can not transfer air to gas mixture with higher pressure.
/datum/gas_mixture/proc/release_gas_to(datum/gas_mixture/output_air, target_pressure, rate=1)
	var/output_starting_pressure = output_air.return_pressure()
	var/input_starting_pressure = return_pressure()

	if(output_starting_pressure >= min(target_pressure,input_starting_pressure-10))
		//No need to pump gas if target is already reached or input pressure is too low
		//Need at least 10 KPa difference to overcome friction in the mechanism
		return FALSE

	//Calculate necessary moles to transfer using PV = nRT
	if((total_moles() > 0) && (temperature>0))
		var/pressure_delta = min(target_pressure - output_starting_pressure, (input_starting_pressure - output_starting_pressure)/2)
		//Can not have a pressure delta that would cause output_pressure > input_pressure

		var/transfer_moles = (pressure_delta*output_air.volume)/(temperature * R_IDEAL_GAS_EQUATION)

		//Actually transfer the gas
		var/datum/gas_mixture/removed = remove(transfer_moles * rate)
		output_air.merge(removed)

		return TRUE
	return FALSE
