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
	ASSERT_GAS(gas_id, src)

///assert_gases(args) - shorthand for calling ASSERT_GAS() once for each gas type.
/datum/gas_mixture/proc/assert_gases(...)
	for(var/id in args)
		ASSERT_GAS(id, src)

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
	ASSERT_GAS(gas_id, src)
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

///Update archived versions of variables. Returns: 1 in all cases
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
		ASSERT_GAS(giver_id, src)
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

///Copies variables from sample, moles multiplicated by partial
///Returns: 1 if we are mutable, 0 otherwise
/datum/gas_mixture/proc/copy_from(datum/gas_mixture/sample, partial = 1)
	var/list/cached_gases = gases //accessing datum vars is slower than proc vars
	var/list/sample_gases = sample.gases

	//remove all gases not in the sample
	cached_gases &= sample_gases

	temperature = sample.temperature
	for(var/id in sample_gases)
		ASSERT_GAS(id,src)
		cached_gases[id][MOLES] = sample_gases[id][MOLES] * partial

	return 1

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

/// Performs air sharing calculations between two gas_mixtures
/// share() is communitive, which means A.share(B) needs to be the same as B.share(A)
/// If we don't retain this, we will get negative moles. Don't do it
/// Returns: amount of gas exchanged (+ if sharer received)
/datum/gas_mixture/proc/share(datum/gas_mixture/sharer, our_coeff, sharer_coeff)
	var/list/cached_gases = gases
	var/list/sharer_gases = sharer.gases

	var/list/only_in_sharer = sharer_gases - cached_gases
	var/list/only_in_cached = cached_gases - sharer_gases

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

	//GAS TRANSFER

	//Prep
	for(var/id in only_in_sharer) //create gases not in our cache
		ADD_GAS(id, cached_gases)
	for(var/id in only_in_cached) //create gases not in the sharing mix
		ADD_GAS(id, sharer_gases)

	for(var/id in cached_gases) //transfer gases
		var/gas = cached_gases[id]
		var/sharergas = sharer_gases[id]
		var/delta = QUANTIZE(gas[ARCHIVE] - sharergas[ARCHIVE]) //the amount of gas that gets moved between the mixtures

		if(!delta)
			continue

		// If we have more gas then they do, gas is moving from us to them
		// This means we want to scale it by our coeff. Vis versa for their case
		if(delta > 0)
			delta = delta * our_coeff
		else
			delta = delta * sharer_coeff

		if(abs_temperature_delta > MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER)
			var/gas_heat_capacity = delta * gas[GAS_META][META_GAS_SPECIFIC_HEAT]
			if(delta > 0)
				heat_capacity_self_to_sharer += gas_heat_capacity
			else
				heat_capacity_sharer_to_self -= gas_heat_capacity //subtract here instead of adding the absolute value because we know that delta is negative.

		gas[MOLES] -= delta
		sharergas[MOLES] += delta
		moved_moles += delta
		abs_moved_moles += abs(delta)

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

	if(length(only_in_sharer + only_in_cached)) //if all gases were present in both mixtures, we know that no gases are 0
		garbage_collect(only_in_cached) //any gases the sharer had, we are guaranteed to have. gases that it didn't have we are not.
		sharer.garbage_collect(only_in_sharer) //the reverse is equally true
	else if (initial(sharer.gc_share))
		sharer.garbage_collect()

	if(temperature_delta > MINIMUM_TEMPERATURE_TO_MOVE || abs(moved_moles) > MINIMUM_MOLES_DELTA_TO_MOVE)
		var/our_moles
		TOTAL_MOLES(cached_gases,our_moles)
		var/their_moles
		TOTAL_MOLES(sharer_gases,their_moles)
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

///Compares sample to self to see if within acceptable ranges that group processing may be enabled
///Returns: a string indicating what check failed, or "" if check passes
/datum/gas_mixture/proc/compare(datum/gas_mixture/sample)
	var/list/sample_gases = sample.gases //accessing datum vars is slower than proc vars
	var/list/cached_gases = gases

	for(var/id in cached_gases | sample_gases) // compare gases from either mixture
		var/gas_moles = cached_gases[id]
		gas_moles = gas_moles ? gas_moles[MOLES] : 0
		var/sample_moles = sample_gases[id]
		sample_moles = sample_moles ? sample_moles[MOLES] : 0
		var/delta = abs(gas_moles - sample_moles)
		if(delta > MINIMUM_MOLES_DELTA_TO_MOVE && \
			delta > gas_moles * MINIMUM_AIR_RATIO_TO_MOVE)
			return id

	var/our_moles
	TOTAL_MOLES(cached_gases, our_moles)
	if(our_moles > MINIMUM_MOLES_DELTA_TO_MOVE) //Don't consider temp if there's not enough mols
		var/temp = temperature
		var/sample_temp = sample.temperature

		var/temperature_delta = abs(temp - sample_temp)
		if(temperature_delta > MINIMUM_TEMPERATURE_DELTA_TO_SUSPEND)
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
	var/list/gas_reactions = SSair.gas_reactions
	for(var/gas_id in cached_gases)
		var/list/reaction_set = gas_reactions[gas_id]
		if(!reaction_set)
			continue
		pre_formation += reaction_set[1]
		mid_formation += reaction_set[2]
		post_formation += reaction_set[3]
		fires += reaction_set[4]

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

/** 
 * Counts how much pressure will there be if we impart MOLAR_ACCURACY amounts of our gas to the output gasmix. 
 * We do all of this without actually transferring it so dont worry about it changing the gasmix.
 * Returns: Resulting pressure (number).
 * Args: 
 * - output_air (gasmix).
 */ 
/datum/gas_mixture/proc/gas_pressure_minimum_transfer(datum/gas_mixture/output_air)
	var/resulting_energy = output_air.thermal_energy() + (MOLAR_ACCURACY / total_moles() * thermal_energy())
	var/resulting_capacity = output_air.heat_capacity() + (MOLAR_ACCURACY / total_moles() * heat_capacity())
	return (output_air.total_moles() + MOLAR_ACCURACY) * R_IDEAL_GAS_EQUATION * (resulting_energy / resulting_capacity) / output_air.volume


/** Returns the amount of gas to be pumped to a specific container.
 * Args:
 * - output_air. The gas mix we want to pump to.
 * - target_pressure. The target pressure we want.
 * - ignore_temperature. Returns a cheaper form of gas calculation, useful if the temperature difference between the two gasmixes is low or nonexistant.
 */
/datum/gas_mixture/proc/gas_pressure_calculate(datum/gas_mixture/output_air, target_pressure, ignore_temperature = FALSE)
	if((total_moles() <= 0) || (temperature <= 0))
		return FALSE

	var/pressure_delta = 0
	if((output_air.temperature <= 0) || (output_air.total_moles() <= 0))
		ignore_temperature = TRUE
		pressure_delta = target_pressure
	else
		pressure_delta = target_pressure - output_air.return_pressure()

	if(pressure_delta < 0.01 || gas_pressure_minimum_transfer(output_air) > target_pressure)
		return FALSE

	if(ignore_temperature)
		return (pressure_delta*output_air.volume)/(temperature * R_IDEAL_GAS_EQUATION)

	// Lower and upper bound for the moles we must transfer to reach the pressure. The answer is bound to be here somewhere.
	var/pv = target_pressure * output_air.volume
	var/rt_low = R_IDEAL_GAS_EQUATION * max(temperature, output_air.temperature) // Low refers to the resulting mole, this number is actually higher.
	var/rt_high = R_IDEAL_GAS_EQUATION * min(temperature, output_air.temperature)
	// These works by assuming our gas has extremely high heat capacity
	// and the resultant gasmix will hit either the highest or lowest temperature possible.
	var/lower_limit = max((pv / rt_low) - output_air.total_moles(), 0)
	var/upper_limit = (pv / rt_high) - output_air.total_moles() // In theory this should never go below zero, the pressure_delta check above should account for this.

	/*
	 * We have PV=nRT as a nice formula, we can rearrange it into nT = PV/R
	 * But now both n and T can change, since any incoming moles also change our temperature.
	 * So we need to unify both our n and T, somehow.
	 * 
	 * We can rewrite T as (our old thermal energy + incoming thermal energy) divided by (our old heat capacity + incoming heat capacity)
	 * T = (W1 + n/N2 * W2) / (C1 + n/N2 * C2). C being heat capacity, W being work, N being total moles.
	 * 
	 * In total we now have our equation be: (N1 + n) * (W1 + n/N2 * W2) / (C1 + n/N2 * C2) = PV/R
	 * Now you can rearrange this and find out that it's a quadratic equation and pretty much solvable with the formula. Will be a bit messy though.
	 * 
	 * W2/N2n^2 + 
	 * (N1*W2/N2)n + W1n - ((PV/R)*C2/N2)n + 
	 * (-(PV/R)*C1) + N1W1 = 0
	 * 
	 * We will represent each of these terms with A, B, and C. A for the n^2 part, B for the n^1 part, and C for the n^0 part.
	 * We then put this into the famous (-b +/- sqrt(b^2-4ac)) / 2a formula.
	 * 
	 * Oh, and one more thing. By "our" we mean the gasmix in the argument. We are the incoming one here. We are number 2, target is number 1.
	 * If all this counting fucks up, we revert first to Newton's approximation, then the old simple formula.
	 */

	// Our thermal energy and moles
	var/w2 = thermal_energy()
	var/n2 = total_moles()
	var/c2 = heat_capacity()
	
	// Target thermal energy and moles
	var/w1 = output_air.thermal_energy()
	var/n1 = output_air.total_moles()
	var/c1 = output_air.heat_capacity()

	/// The PV/R part in our equation.
	var/pvr = pv / R_IDEAL_GAS_EQUATION
	
	/// x^2 in the quadratic
	var/a_value = w2/n2
	/// x^1 in the quadratic
	var/b_value = ((n1*w2)/n2) + w1 - (pvr*c2/n2)
	/// x^0 in the quadratic
	var/c_value = (-1*pvr*c1) + n1 * w1
	
	. = gas_pressure_quadratic(a_value, b_value, c_value, lower_limit, upper_limit)
	if(.)
		return
	. = gas_pressure_approximate(a_value, b_value, c_value, lower_limit, upper_limit)
	if(.)
		return
	// Inaccurate and will probably explode but whatever.
	return (pressure_delta*output_air.volume)/(temperature * R_IDEAL_GAS_EQUATION)

/// Actually tries to solve the quadratic equation.
/// Do mind that the numbers can get very big and might hit BYOND's single point float limit.
/datum/gas_mixture/proc/gas_pressure_quadratic(a, b, c, lower_limit, upper_limit)
	if(!IS_INF_OR_NAN(a) && !IS_INF_OR_NAN(b) && !IS_INF_OR_NAN(c))
		. = max(SolveQuadratic(a, b, c)) 
		if((. > lower_limit) && (. < upper_limit)) //SolveQuadratic can return nulls so be careful here
			return
	stack_trace("Failed to solve pressure quadratic equation. A: [a]. B: [b]. C:[c]. Current value = [.]")
	return FALSE

/// Approximation of the quadratic equation using Newton-Raphson's Method.
/// We use the slope of an approximate value to get closer to the root of a given equation.
/datum/gas_mixture/proc/gas_pressure_approximate(a, b, c, lower_limit, upper_limit)
	if(!IS_INF_OR_NAN(a) && !IS_INF_OR_NAN(b) && !IS_INF_OR_NAN(c))
		// We need to start off at a reasonably good estimate. For very big numbers the amount of moles is most likely small so better start with lower_limit.
		. = lower_limit
		for (var/iteration in 1 to ATMOS_PRESSURE_APPROXIMATION_ITERATIONS)
			var/diff = (a*.**2 + b*. + c) / (2*a*. + b) // f(.) / f'(.)
			. -= diff // xn+1 = xn - f(.) / f'(.)
			if(abs(diff) < MOLAR_ACCURACY && (. > lower_limit) && (. < upper_limit))
				return
	stack_trace("Newton's Approximation for pressure failed after [ATMOS_PRESSURE_APPROXIMATION_ITERATIONS] iterations. Current value: [.]. Expected lower limit: [lower_limit]. Expected upper limit: [upper_limit]. A: [a]. B: [b]. C:[c].")
	return FALSE

/// Pumps gas from src to output_air. Amount depends on target_pressure
/datum/gas_mixture/proc/pump_gas_to(datum/gas_mixture/output_air, target_pressure, specific_gas = null)
	var/temperature_delta = abs(temperature - output_air.temperature)
	var/datum/gas_mixture/removed
	var/transfer_moles

	if(specific_gas)
		// This is necessary because the specific heat capacity of a gas might be different from our gasmix.
		var/datum/gas_mixture/temporary = remove_specific_ratio(specific_gas, 1)
		transfer_moles = temporary.gas_pressure_calculate(output_air, target_pressure, temperature_delta <= 5)
		removed = temporary.remove_specific(specific_gas, transfer_moles)
	else
		transfer_moles = gas_pressure_calculate(output_air, target_pressure, temperature_delta <= 5)
		removed = remove(transfer_moles)
	
	if(!removed)
		return FALSE

	output_air.merge(removed)
	return TRUE

/// Releases gas from src to output air. This means that it can not transfer air to gas mixture with higher pressure.
/datum/gas_mixture/proc/release_gas_to(datum/gas_mixture/output_air, target_pressure, rate=1)
	var/output_starting_pressure = output_air.return_pressure()
	var/input_starting_pressure = return_pressure()
	
	//Need at least 10 KPa difference to overcome friction in the mechanism
	if(output_starting_pressure >= min(target_pressure,input_starting_pressure-10))
		return FALSE
	//Can not have a pressure delta that would cause output_pressure > input_pressure
	target_pressure = output_starting_pressure + min(target_pressure - output_starting_pressure, (input_starting_pressure - output_starting_pressure)/2)
	var/temperature_delta = abs(temperature - output_air.temperature)
	
	var/transfer_moles = gas_pressure_calculate(output_air, target_pressure, temperature_delta <= 5)

	//Actually transfer the gas
	var/datum/gas_mixture/removed = remove(transfer_moles * rate)
	
	if(!removed)
		return FALSE

	output_air.merge(removed)
	return TRUE
