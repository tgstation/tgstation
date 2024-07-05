/*
What are the archived variables for?
Calculations are done using the archived variables with the results merged into the regular variables.
This prevents race conditions that arise based on the order of tile processing.
*/

GLOBAL_LIST_INIT(meta_gas_info, meta_gas_list()) //see ATMOSPHERICS/gas_types.dm
GLOBAL_LIST_INIT(gaslist_cache, init_gaslist_cache())

/proc/init_gaslist_cache()
	var/list/gases = list()
	for(var/id in GLOB.meta_gas_info)
		var/list/cached_gas = new(3)

		gases[id] = cached_gas

		cached_gas[MOLES] = 0
		cached_gas[ARCHIVE] = 0
		cached_gas[GAS_META] = GLOB.meta_gas_info[id]
	return gases

/datum/gas_mixture
	var/list/gases
	/// The temperature of the gas mix in kelvin. Should never be lower then TCMB
	var/temperature = TCMB
	/// Used, like all archived variables, to ensure turf sharing is consistent inside a tick, no matter
	/// The order of operations
	var/tmp/temperature_archived = TCMB
	/// Volume in liters (duh)
	var/volume = CELL_VOLUME
	/// The last tick this gas mixture shared on. A counter that turfs use to manage activity
	var/last_share = 0
	/// Tells us what reactions have happened in our gasmix. Assoc list of reaction - moles reacted pair.
	var/list/reaction_results
	/// Whether to call garbage_collect() on the sharer during shares, used for immutable mixtures
	var/gc_share = FALSE
	/// When this gas mixture was last touched by pipeline processing
	/// I am sorry
	var/pipeline_cycle = -1

/datum/gas_mixture/New(volume)
	gases = new
	if(!isnull(volume))
		src.volume = volume
	if(src.volume <= 0)
		stack_trace("Created a gas mixture with zero volume!")
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
		return . * R_IDEAL_GAS_EQUATION * temperature / volume
	return 0

/// Calculate temperature in kelvins
/datum/gas_mixture/proc/return_temperature()
	return temperature

/// Calculate volume in liters
/datum/gas_mixture/proc/return_volume()
	return max(0, volume)

/// Gets the gas visuals for everything in this mixture
/datum/gas_mixture/proc/return_visuals(turf/z_context)
	var/list/output
	GAS_OVERLAYS(gases, output, z_context)
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
		ASSERT_GAS_IN_LIST(giver_id, cached_gases)
		cached_gases[giver_id][MOLES] += giver_gases[giver_id][MOLES]

	SEND_SIGNAL(src, COMSIG_GASMIX_MERGED)
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
	var/datum/gas_mixture/removed = new type(volume)
	var/list/removed_gases = removed.gases //accessing datum vars is slower than proc vars

	removed.temperature = temperature
	for(var/id in cached_gases)
		ADD_GAS(id, removed.gases)
		removed_gases[id][MOLES] = QUANTIZE(cached_gases[id][MOLES] * ratio)
		cached_gases[id][MOLES] -= removed_gases[id][MOLES]
	garbage_collect()

	SEND_SIGNAL(src, COMSIG_GASMIX_REMOVED)
	return removed

///Proportionally removes amount of gas from the gas_mixture.
///Returns: gas_mixture with the gases removed
/datum/gas_mixture/proc/remove_ratio(ratio)
	if(ratio <= 0)
		var/datum/gas_mixture/removed = new(volume)
		return removed
	ratio = min(ratio, 1)

	var/list/cached_gases = gases
	var/datum/gas_mixture/removed = new type(volume)
	var/list/removed_gases = removed.gases //accessing datum vars is slower than proc vars

	removed.temperature = temperature
	for(var/id in cached_gases)
		ADD_GAS(id, removed.gases)
		removed_gases[id][MOLES] = QUANTIZE(cached_gases[id][MOLES] * ratio)
		cached_gases[id][MOLES] -= removed_gases[id][MOLES]

	garbage_collect()

	SEND_SIGNAL(src, COMSIG_GASMIX_REMOVED)
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
	// Type as /list/list to make spacemandmm happy with the inlined access we do down there
	var/list/list/cached_gases = gases
	var/datum/gas_mixture/copy = new type
	var/list/copy_gases = copy.gases

	copy.temperature = temperature
	for(var/id in cached_gases)
		// Sort of a sideways way of doing ADD_GAS()
		// Faster tho, gotta save those cpu cycles
		copy_gases[id] = cached_gases[id].Copy()
		copy_gases[id][ARCHIVE] = 0

	return copy


///Copies variables from sample
///Returns: TRUE if we are mutable, FALSE otherwise
/datum/gas_mixture/proc/copy_from(datum/gas_mixture/sample)
	var/list/cached_gases = gases //accessing datum vars is slower than proc vars
	// Type as /list/list to make spacemandmm happy with the inlined access we do down there
	var/list/list/sample_gases = sample.gases

	//remove all gases
	cached_gases.Cut()

	temperature = sample.temperature
	for(var/id in sample_gases)
		cached_gases[id] = sample_gases[id].Copy()
		cached_gases[id][ARCHIVE] = 0

	return TRUE

///Copies variables from sample, moles multiplicated by partial
///Returns: TRUE if we are mutable, FALSE otherwise
/datum/gas_mixture/proc/copy_from_ratio(datum/gas_mixture/sample, partial = 1)
	var/list/cached_gases = gases //accessing datum vars is slower than proc vars
	var/list/sample_gases = sample.gases

	//remove all gases not in the sample
	cached_gases &= sample_gases

	temperature = sample.temperature
	for(var/id in sample_gases)
		ASSERT_GAS_IN_LIST(id, cached_gases)
		cached_gases[id][MOLES] = sample_gases[id][MOLES] * partial

	return TRUE

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
			// coefficient applied first because some turfs have very big heat caps.
			var/heat = CALCULATE_CONDUCTION_ENERGY(conduction_coefficient * temperature_delta, sharer_heat_capacity, self_heat_capacity)

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
	var/moles_sum = 0

	for(var/id in cached_gases | sample_gases) // compare gases from either mixture
		// Yes this is actually fast. I too hate it here
		var/gas_moles = cached_gases[id]?[MOLES] || 0
		var/sample_moles = sample_gases[id]?[MOLES] || 0
		// Brief explanation. We are much more likely to not pass this first check then pass the first and fail the second
		// Because of this, double calculating the delta is FASTER then inserting it into a var
		if(abs(gas_moles - sample_moles) > MINIMUM_MOLES_DELTA_TO_MOVE)
			if(abs(gas_moles - sample_moles) > gas_moles * MINIMUM_AIR_RATIO_TO_MOVE)
				return id
		// similarly, we will rarely get cut off, so this is cheaper then doing it later
		moles_sum += gas_moles

	if(moles_sum > MINIMUM_MOLES_DELTA_TO_MOVE) //Don't consider temp if there's not enough mols
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
		SEND_SIGNAL(src, COMSIG_GASMIX_REACTED)


/**
 * Returns the partial pressure of the gas in the breath based on BREATH_VOLUME
 * eg:
 * Plas_PP = get_breath_partial_pressure(gas_mixture.gases[/datum/gas/plasma][MOLES])
 * O2_PP = get_breath_partial_pressure(gas_mixture.gases[/datum/gas/oxygen][MOLES])
 * get_breath_partial_pressure(gas_mole_count) --> PV = nRT, P = nRT/V
 *
 * 10/20*5 = 2.5
 * 10 = 2.5/5*20
 */

/datum/gas_mixture/proc/get_breath_partial_pressure(gas_mole_count)
	return (gas_mole_count * R_IDEAL_GAS_EQUATION * temperature) / BREATH_VOLUME

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
	// So we dont need to iterate the gaslist multiple times.
	var/our_moles = total_moles()
	var/output_moles = output_air.total_moles()
	var/output_pressure = output_air.return_pressure()

	if(our_moles <= 0 || temperature <= 0)
		return FALSE

	var/pressure_delta = 0
	if(output_air.temperature <= 0 || output_moles <= 0)
		ignore_temperature = TRUE
		pressure_delta = target_pressure
	else
		pressure_delta = target_pressure - output_pressure

	if(pressure_delta < 0.01 || gas_pressure_minimum_transfer(output_air) > target_pressure)
		return FALSE

	if(ignore_temperature)
		return (pressure_delta*output_air.volume)/(temperature * R_IDEAL_GAS_EQUATION)

	// Lower and upper bound for the moles we must transfer to reach the pressure. The answer is bound to be here somewhere.
	var/pv = target_pressure * output_air.volume
	/// The PV/R part in the equation we will use later. Counted early because pv/(r*t) might not be equal to pv/r/t, messing our lower and upper limit.
	var/pvr = pv / R_IDEAL_GAS_EQUATION
	// These works by assuming our gas has extremely high heat capacity
	// and the resultant gasmix will hit either the highest or lowest temperature possible.

	/// This is the true lower limit, but numbers still can get lower than this due to floats.
	var/lower_limit = max((pvr / max(temperature, output_air.temperature)) - output_moles, 0)
	var/upper_limit = (pvr / min(temperature, output_air.temperature)) - output_moles // In theory this should never go below zero, the pressure_delta check above should account for this.

	lower_limit = max(lower_limit - ATMOS_PRESSURE_ERROR_TOLERANCE, 0)
	upper_limit += ATMOS_PRESSURE_ERROR_TOLERANCE

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
	var/n2 = our_moles
	var/c2 = heat_capacity()

	// Target thermal energy and moles
	var/w1 = output_air.thermal_energy()
	var/n1 = output_moles
	var/c1 = output_air.heat_capacity()

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
	var/solution
	if(IS_FINITE(a) && IS_FINITE(b) && IS_FINITE(c))
		solution = max(SolveQuadratic(a, b, c))
		if(solution > lower_limit && solution < upper_limit) //SolveQuadratic can return empty lists so be careful here
			return solution
	stack_trace("Failed to solve pressure quadratic equation. A: [a]. B: [b]. C:[c]. Current value = [solution]. Expected lower limit: [lower_limit]. Expected upper limit: [upper_limit].")
	return FALSE

/// Approximation of the quadratic equation using Newton-Raphson's Method.
/// We use the slope of an approximate value to get closer to the root of a given equation.
/datum/gas_mixture/proc/gas_pressure_approximate(a, b, c, lower_limit, upper_limit)
	var/solution
	if(IS_FINITE(a) && IS_FINITE(b) && IS_FINITE(c))
		// We start at the extrema of the equation, added by a number.
		// This way we will hopefully always converge on the positive root, while starting at a reasonable number.
		solution = (-b / (2 * a)) + 200
		for (var/iteration in 1 to ATMOS_PRESSURE_APPROXIMATION_ITERATIONS)
			var/diff = (a*solution**2 + b*solution + c) / (2*a*solution + b) // f(sol) / f'(sol)
			solution -= diff // xn+1 = xn - f(sol) / f'(sol)
			if(abs(diff) < MOLAR_ACCURACY && (solution > lower_limit) && (solution < upper_limit))
				return solution
	stack_trace("Newton's Approximation for pressure failed after [ATMOS_PRESSURE_APPROXIMATION_ITERATIONS] iterations. A: [a]. B: [b]. C:[c]. Current value: [solution]. Expected lower limit: [lower_limit]. Expected upper limit: [upper_limit].")
	return FALSE

/// Pumps gas from src to output_air. Amount depends on target_pressure
/datum/gas_mixture/proc/pump_gas_to(datum/gas_mixture/output_air, target_pressure, specific_gas = null, datum/gas_mixture/output_pipenet_air = null)
	var/datum/gas_mixture/input_air = specific_gas ? remove_specific_ratio(specific_gas, 1) : src
	var/temperature_delta = abs(input_air.temperature - output_air.temperature)
	var/datum/gas_mixture/removed

	var/transfer_moles_output = input_air.gas_pressure_calculate(output_air, target_pressure, temperature_delta <= 5)
	var/transfer_moles_pipenet = output_pipenet_air?.volume ? input_air.gas_pressure_calculate(output_pipenet_air, target_pressure, temperature_delta <= 5) : 0
	var/transfer_moles = max(transfer_moles_output, transfer_moles_pipenet)

	if(specific_gas)
		removed = input_air.remove_specific(specific_gas, transfer_moles)
		merge(input_air) // Merge the remaining gas back to the input node
	else
		removed = input_air.remove(transfer_moles)

	if(!removed)
		return FALSE

	output_air.merge(removed)
	return removed

/// Releases gas from src to output air. This means that it can not transfer air to gas mixture with higher pressure.
/datum/gas_mixture/proc/release_gas_to(datum/gas_mixture/output_air, target_pressure, rate=1, datum/gas_mixture/output_pipenet_air = null)
	var/output_starting_pressure = output_air.return_pressure()
	var/input_starting_pressure = return_pressure()

	//Need at least 10 KPa difference to overcome friction in the mechanism
	if(output_starting_pressure >= min(target_pressure, input_starting_pressure-10))
		return FALSE
	//Can not have a pressure delta that would cause output_pressure > input_pressure
	target_pressure = output_starting_pressure + min(target_pressure - output_starting_pressure, (input_starting_pressure - output_starting_pressure)/2)
	var/temperature_delta = abs(temperature - output_air.temperature)

	var/transfer_moles_output = gas_pressure_calculate(output_air, target_pressure, temperature_delta <= 5)
	var/transfer_moles_pipenet = output_pipenet_air?.volume ? gas_pressure_calculate(output_pipenet_air, target_pressure, temperature_delta <= 5) : 0
	var/transfer_moles = max(transfer_moles_output, transfer_moles_pipenet)

	//Actually transfer the gas
	var/datum/gas_mixture/removed = remove(transfer_moles * rate)

	if(!removed)
		return FALSE

	output_air.merge(removed)
	return TRUE
