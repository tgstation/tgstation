/*
What are the archived variables for?
	Calculations are done using the archived variables with the results merged into the regular variables.
	This prevents race conditions that arise based on the order of tile processing.
*/

#define STANDARD_GAS_ROUNDING	0.0001

#define MINIMUM_HEAT_CAPACITY	0.0003
#define QUANTIZE(variable)		(round(variable,STANDARD_GAS_ROUNDING))
#define TRANSFER_FRACTION 5 //What fraction (1/#) of the air difference to try and transfer

// /vg/ SHIT
#define TEMPERATURE_ICE_FORMATION 273.15 // 273 kelvin is the freezing point of water.
#define MIN_PRESSURE_ICE_FORMATION 10    // 10kPa should be okay

#define GRAPHICS_PLASMA   1
#define GRAPHICS_N2O      2
#define GRAPHICS_REAGENTS 4  // Not used.  Yet.
#define GRAPHICS_COLD     8
// END VGSHIT

/hook/startup/proc/createGasOverlays()
	plmaster = new /obj/effect/overlay()
	plmaster.icon = 'icons/effects/tile_effects.dmi'
	plmaster.icon_state = "plasma"
	plmaster.layer = FLY_LAYER
	plmaster.mouse_opacity = 0

	slmaster = new /obj/effect/overlay()
	slmaster.icon = 'icons/effects/tile_effects.dmi'
	slmaster.icon_state = "sleeping_agent"
	slmaster.layer = FLY_LAYER
	slmaster.mouse_opacity = 0
	return 1

/datum/gas_mixture
	var/volume = CELL_VOLUME

	var/temperature = 0 //in Kelvin, use calculate_temperature() to modify

	var/group_multiplier = 1
				//Size of the group this gas_mixture is representing.
				//=1 for singletons

	var/total_moles = 0

	var/graphics=0

	var/pressure=0

	var/heat_capacity = 0

	var/list/gases //stores all the gas numbers for this mixture
	var/list/archived_gases //archiving!

	var/tmp/temperature_archived

	var/tmp/graphics_archived = 0
	var/tmp/fuel_burnt = 0

	//var/datum/reagents/aerosols

/datum/gas_mixture/New()
	gases = list()
	if(!gas_datum_list)
		for(var/newgas in (typesof(/datum/gas) - /datum/gas))
			var/datum/gas/new_datum_gas = new newgas()
			gas_datum_list += list(new_datum_gas.gas_id = new_datum_gas) //associates the gas with its id
			gas_specific_heat = list(new_datum_gas.gas_id = new_datum_gas.specific_heat)

	for(var/gasid in gas_datum_list) //initialise the gases themselves
		gases += list("[gasid]" = 0)

	archived_gases = gases.Copy()

//gets a gas in the gas list
/datum/gas_mixture/proc/get_gas_by_id(gasid)
	if(gasid in gas_datum_list)
		return gas_datum_list[gasid]
	else
		return null


//FOR THE LOVE OF GOD PLEASE USE THIS PROC
//Call it with negative numbers to remove gases.

/datum/gas_mixture/proc/adjust(list/datum/gas/adjusts = list())
	//Purpose: Adjusting the gases within a airmix
	//Called by: Nothing, yet!
	//Inputs: The values of the gases to adjust done as a list(id = moles)
	//Outputs: null

	for(var/a_gas in adjusts)
		adjust_gas(a_gas, adjusts[a_gas], 0)
	return

//Takes a gas string, and the amount of moles to adjust by.
//if use_group is 0, the group_multiplier isn't considered
//supports negative values
/datum/gas_mixture/proc/adjust_gas(gasid, moles, use_group = 1)
	if(moles == 0)
		return

	if(group_multiplier != 1 && use_group)
		set_gas(gasid, gases[gasid] + moles/group_multiplier)
	else
		set_gas(gasid, gases[gasid] + moles)

//Sets the value of a gas using a gas string and a mole number
//Note: this should be the only way in which gas numbers should ever be edited
//The gas system must be airtight - never bypass this
/datum/gas_mixture/proc/set_gas(gasid, moles)
	ASSERT(gasid in gases)

	if(moles < 0)
		return

	var/old_moles = gases[gasid]

	gases[gasid] = max(0, moles)

	pressure += ((moles - old_moles) * R_IDEAL_GAS_EQUATION * temperature) / volume //add the maths of the new gas
	heat_capacity += (moles - old_moles) * gas_specific_heat[gasid]
	total_moles += (moles - old_moles)

/datum/gas_mixture/proc/thermal_energy()
	return temperature*heat_capacity

///////////////////////////////
//PV=nRT - related procedures//
///////////////////////////////

/datum/gas_mixture/proc/set_temperature(var/new_temperature)
	//Purpose: Changes the temperature of a gas_mixture
	//Called by: UNKNOWN
	//Inputs: New temperature to set to
	//Outputs: None
	new_temperature = max(0, new_temperature)

	var/old_temperature = temperature

	temperature = new_temperature

	if(old_temperature) //can't divide by 0 - and we only have pressure if T > 0
		pressure *= new_temperature/old_temperature //V is unchanging, T changes by a factor, P must change by the same factor
	else
		pressure = (total_moles * R_IDEAL_GAS_EQUATION * temperature) / volume //recalc

/datum/gas_mixture/proc/set_volume(var/new_volume)
	//Purpose: Changes the volume of a gas_mixture
	//Called by: UNKNOWN
	//Inputs: New volume to set to
	//Outputs: None
	new_volume = max(0, new_volume)

	var/old_volume = volume

	volume = new_volume

	if(old_volume) //can't divide by 0
		pressure /= new_volume/old_volume //since PV is a constant, the ratio change in V is inverse for P
	else
		pressure = (total_moles * R_IDEAL_GAS_EQUATION * temperature) / volume //recalc

/datum/gas_mixture/proc/heat_capacity_calc(var/list/hc_gases = gases)
	//Purpose: Returning the heat capacity of a gas mix
	//Called by: UNKNOWN
	//Inputs: List of gases (or none, so the gas list itself)
	//Outputs: Heat capacity

	var/hc_current

	for(var/gasid in hc_gases)
		hc_current += gases[gasid] * gas_specific_heat[gasid]

	return max(MINIMUM_HEAT_CAPACITY, hc_current)

/datum/gas_mixture/proc/round_values(var/rounding_error = STANDARD_GAS_ROUNDING)
	//Purpose: Trims the fat off values
	//Called by: Fire code that cleans up values after processing
	//Inputs: Rounding error
	//Outputs: None

	for(var/gasid in gases)
		adjust_gas(gasid, - (gases[gasid] - round(gases[gasid], rounding_error)))


////////////////////////////////////////////
//Procedures used for very specific events//
////////////////////////////////////////////

/datum/gas_mixture/proc/check_tile_graphic()
	//Purpose: Calculating the graphic for a tile
	//Called by: Turfs updating
	//Inputs: None
	//Outputs: 1 if graphic changed, 0 if unchanged

	graphics = 0

	// If configured and cold, maek ice
	if(zas_settings.Get(/datum/ZAS_Setting/ice_formation))
		if(temperature <= TEMPERATURE_ICE_FORMATION && pressure>MIN_PRESSURE_ICE_FORMATION)
			// If we're just forming, do a probability check.  Otherwise, KEEP IT ON~
			// This ordering will hopefully keep it from sampling random noise every damn tick.
			//if(was_icy || (!was_icy && prob(25)))
			graphics |= GRAPHICS_COLD

	if(gases[PLASMA] > MOLES_PLASMA_VISIBLE)
		graphics |= GRAPHICS_PLASMA

	if(gases[NITROUS_OXIDE] > MOLES_N2O_VISIBLE)
		graphics |= GRAPHICS_N2O
/*
	if(aerosols && aerosols.total_volume >= 1)
		graphics |= GRAPHICS_REAGENTS
*/

	return graphics != graphics_archived

/datum/gas_mixture/proc/react(atom/dump_location)
	//Purpose: Calculating if it is possible for a fire to occur in the airmix
	//Called by: Air mixes updating?
	//Inputs: None
	//Outputs: If a fire occured

	 //set to 1 if a notable reaction occured (used by pipe_network)

	return zburn(null) // ? (was: return reacting)

/datum/gas_mixture/proc/fire()
	//Purpose: Calculating any fire reactions.
	//Called by: react() (See above)
	//Inputs: None
	//Outputs: How much fuel burned

	return zburn(null)

	/*var/energy_released = 0
	var/old_heat_capacity = heat_capacity

	var/datum/gas/volatile_fuel/fuel_store = locate(/datum/gas/volatile_fuel) in trace_gases
	if(fuel_store) //General volatile gas burn
		var/burned_fuel = 0

		if(oxygen < fuel_store.moles)
			burned_fuel = oxygen
			fuel_store.moles -= burned_fuel
			oxygen = 0
		else
			burned_fuel = fuel_store.moles
			oxygen -= fuel_store.moles
			del(fuel_store)

		energy_released += FIRE_CARBON_ENERGY_RELEASED * burned_fuel
		carbon_dioxide += burned_fuel
		fuel_burnt += burned_fuel

	//Handle plasma burning
	if(toxins > MINIMUM_HEAT_CAPACITY)
		var/plasma_burn_rate = 0
		var/oxygen_burn_rate = 0
		//more plasma released at higher temperatures
		var/temperature_scale
		if(temperature > PLASMA_UPPER_TEMPERATURE)
			temperature_scale = 1
		else
			temperature_scale = (temperature-PLASMA_MINIMUM_BURN_TEMPERATURE)/(PLASMA_UPPER_TEMPERATURE-PLASMA_MINIMUM_BURN_TEMPERATURE)
		if(temperature_scale > 0)
			oxygen_burn_rate = 1.4 - temperature_scale
			if(oxygen > toxins*PLASMA_OXYGEN_FULLBURN)
				plasma_burn_rate = (toxins*temperature_scale)/4
			else
				plasma_burn_rate = (temperature_scale*(oxygen/PLASMA_OXYGEN_FULLBURN))/4
			if(plasma_burn_rate > MINIMUM_HEAT_CAPACITY)
				toxins -= plasma_burn_rate
				oxygen -= plasma_burn_rate*oxygen_burn_rate
				carbon_dioxide += plasma_burn_rate

				energy_released += FIRE_PLASMA_ENERGY_RELEASED * (plasma_burn_rate)

				fuel_burnt += (plasma_burn_rate)*(1+oxygen_burn_rate)

	if(energy_released > 0)
		var/new_heat_capacity = heat_capacity
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			temperature = (temperature*old_heat_capacity + energy_released)/new_heat_capacity
	update_values()

	return fuel_burnt*/

//////////////////////////////////////////////
//Procs for general gas spread calculations.//
//////////////////////////////////////////////

/datum/gas_mixture/proc/archive()
	//Purpose: Archives the current gas values
	//Called by: UNKNOWN
	//Inputs: None
	//Outputs: 1

	for(var/gasid in gases)
		archived_gases[gasid] = gases[gasid]

	temperature_archived = temperature

	graphics_archived = graphics

	return 1

/datum/gas_mixture/proc/check_then_merge(datum/gas_mixture/giver)
	//Purpose: Similar to merge(...) but first checks to see if the amount of air assumed is small enough
	//	that group processing is still accurate for source (aborts if not)
	//Called by: airgroups/machinery expelling air, ?
	//Inputs: The gas to try and merge
	//Outputs: 1 on successful merge.  0 otherwise.

	if(!giver)
		return 0

	if(abs(giver.temperature - temperature) > MINIMUM_TEMPERATURE_DELTA_TO_SUSPEND)
		return 0

	for(var/gasid in gases)
		if((giver.gases[gasid] > MINIMUM_AIR_TO_SUSPEND) && (giver.gases[gasid] >= gases[gasid]*MINIMUM_AIR_RATIO_TO_SUSPEND))
			return 0

	return merge(giver)

/datum/gas_mixture/proc/merge(datum/gas_mixture/giver)
	//Purpose: Merges all air from giver into self. Deletes giver.
	//Called by: Machinery expelling air, check_then_merge, ?
	//Inputs: The gas to merge.
	//Outputs: 1

	if(!giver)
		return 0

	if(abs(temperature-giver.temperature)>MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER)
		var/self_heat_capacity = heat_capacity*group_multiplier
		var/giver_heat_capacity = giver.heat_capacity*giver.group_multiplier
		var/combined_heat_capacity = giver_heat_capacity + self_heat_capacity
		if(combined_heat_capacity != 0)
			set_temperature((giver.temperature*giver_heat_capacity + temperature*self_heat_capacity)/combined_heat_capacity)

	if(giver.group_multiplier>1)
		for(var/gasid in gases)
			adjust_gas(gasid, giver.gases[gasid] * giver.group_multiplier)
	else
		for(var/gasid in gases)
			adjust_gas(gasid, giver.gases[gasid])

	// Let the garbage collector handle it, faster according to /tg/ testers
	//del(giver)
	return 1

/datum/gas_mixture/proc/remove(amount)
	//Purpose: Removes a certain number of moles from the air.
	//Called by: ?
	//Inputs: How many moles to remove.
	//Outputs: Removed air.

	// Fix a singuloth problem
	if(group_multiplier==0)
		return null

	var/sum = total_moles
	amount = min(amount,sum) //Can not take more air than tile has!
	if(amount <= 0)
		return new/datum/gas_mixture

	var/datum/gas_mixture/removed = new

	removed.set_temperature(temperature)

	for(var/gasid in gases)
		var/taken_gas = QUANTIZE(gases[gasid] / sum) * amount //the gas we lose - not yet subtracted
		adjust_gas(gasid, -taken_gas) //don't update just yet - negative subtracts
		removed.adjust_gas(gasid, taken_gas) //slap the copied gas in

	return removed

/datum/gas_mixture/proc/remove_ratio(ratio)
	//Purpose: Removes a certain ratio of the air.
	//Called by: ?
	//Inputs: Percentage to remove.
	//Outputs: Removed air.

	if(ratio <= 0)
		return null

	ratio = min(ratio, 1)

	return remove(total_moles * ratio) //use the sum removal

/datum/gas_mixture/proc/check_then_remove(amount)
	//Purpose: Similar to remove(...) but first checks to see if the amount of air removed is small enough
	//	that group processing is still accurate for source (aborts if not)
	//Called by: ?
	//Inputs: Number of moles to remove
	//Outputs: Removed air or 0 if it can remove air or not.

	amount = Clamp(amount, 0, total_moles) //Can not take more air than tile has!

	if((amount > MINIMUM_AIR_RATIO_TO_SUSPEND) && (amount > total_moles*MINIMUM_AIR_RATIO_TO_SUSPEND))
		return 0

	return remove(amount)

/datum/gas_mixture/proc/copy_from(datum/gas_mixture/sample)
	//Purpose: Duplicates the sample air mixture.
	//Called by: airgroups splitting, ?
	//Inputs: Gas to copy
	//Outputs: 1

	set_temperature(sample.temperature)

	for(var/gasid in sample.gases)
		set_gas(gasid, sample.gases[gasid], 0)

	return 1

/datum/gas_mixture/proc/check_gas_mixture(datum/gas_mixture/sharer)
	//Purpose: Telling if one or both airgroups needs to disable group processing.
	//Called by: Airgroups sharing air, checking if group processing needs disabled.
	//Inputs: Gas to compare from other airgroup
	//Outputs: 0 if the self-check failed (local airgroup breaks?)
	//   then -1 if sharer-check failed (sharing airgroup breaks?)
	//   then 1 if both checks pass (share succesful?)
	if(!istype(sharer))
		return

	if(abs(temperature_archived - sharer.temperature_archived) > MINIMUM_TEMPERATURE_DELTA_TO_SUSPEND)
		return 0

	for(var/gasid in gases)
		var/archived_own_gas = archived_gases[gasid]
		var/archived_sharer_gas = sharer.archived_gases[gasid]
		var/gas_delta = abs(QUANTIZE(archived_own_gas - archived_sharer_gas)/TRANSFER_FRACTION) //the difference in gas moles

		if((gas_delta > MINIMUM_AIR_TO_SUSPEND) && (gas_delta >= archived_own_gas*MINIMUM_AIR_RATIO_TO_SUSPEND))
			return 0

		if((gas_delta > MINIMUM_AIR_TO_SUSPEND) && (gas_delta >= archived_sharer_gas*MINIMUM_AIR_RATIO_TO_SUSPEND))
			return -1

	return 1

/datum/gas_mixture/proc/check_turf(turf/model_turf)
	//Purpose: Used to compare the gases in an unsimulated turf with the gas in a simulated one.
	//Called by: Sharing air (mimicing) with adjacent unsimulated turfs
	//Inputs: Unsimulated turf
	//Outputs: 1 if safe to mimic, 0 if needs to break airgroup.

	var/datum/gas_mixture/model = model_turf.return_air()

	if(abs(temperature_archived - model.temperature) > MINIMUM_TEMPERATURE_DELTA_TO_SUSPEND)
		return 0

	for(var/gasid in gases)
		var/archived_gas = archived_gases[gasid]
		var/gas_delta = abs((archived_gas - model.gases[gasid])/TRANSFER_FRACTION)
		if((gas_delta > MINIMUM_AIR_TO_SUSPEND) && (gas_delta >= archived_gas*MINIMUM_AIR_RATIO_TO_SUSPEND))
			return 0
	return 1

/datum/gas_mixture/proc/share(datum/gas_mixture/sharer)
	//Purpose: Used to transfer gas from a more pressurised tile to a less presurised tile
	//    (Two directional, if the other tile is more pressurised, air travels to current tile)
	//Called by: Sharing air with adjacent simulated turfs
	//Inputs: Air datum to share with
	//Outputs: Amount of gas exchanged (Negative if lost air, positive if gained.)


	if(!istype(sharer))
		return

	var/delta_temperature = (temperature_archived - sharer.temperature_archived)

	var/old_self_heat_capacity = 0
	var/old_sharer_heat_capacity = 0

	var/heat_self_to_sharer = 0
	var/heat_capacity_self_to_sharer = 0
	var/heat_sharer_to_self = 0
	var/heat_capacity_sharer_to_self = 0

	var/moved_moles = 0

	for(var/gasid in gases)
		var/gas_delta = QUANTIZE(archived_gases[gasid] - sharer.archived_gases[gasid])/TRANSFER_FRACTION
		if(gas_delta && abs(delta_temperature) > MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER) //difference in gases and temperature
			var/datum/gas/current_gas = get_gas_by_id(gasid)
			var/gas_heat_capacity = current_gas.specific_heat
			if(gas_delta > 0)
				heat_self_to_sharer += gas_heat_capacity * temperature_archived
				heat_capacity_self_to_sharer += gas_heat_capacity
			else
				heat_sharer_to_self -= gas_heat_capacity * temperature_archived
				heat_capacity_sharer_to_self -= gas_heat_capacity

		adjust_gas(gasid, -gas_delta) //delay update - adjust_gas handles the group multiplier
		sharer.adjust_gas(gasid, gas_delta)

		moved_moles += gas_delta

	if(abs(delta_temperature) > MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER)
		old_self_heat_capacity = heat_capacity*group_multiplier
		old_sharer_heat_capacity = sharer.heat_capacity*sharer.group_multiplier


	if(abs(delta_temperature) > MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER)
		var/new_self_heat_capacity = old_self_heat_capacity + heat_capacity_sharer_to_self - heat_capacity_self_to_sharer
		var/new_sharer_heat_capacity = old_sharer_heat_capacity + heat_capacity_self_to_sharer - heat_capacity_sharer_to_self

		if(new_self_heat_capacity > MINIMUM_HEAT_CAPACITY)
			set_temperature((old_self_heat_capacity*temperature - heat_capacity_self_to_sharer*temperature_archived + heat_capacity_sharer_to_self*sharer.temperature_archived)/new_self_heat_capacity)

		if(new_sharer_heat_capacity > MINIMUM_HEAT_CAPACITY)
			sharer.set_temperature((old_sharer_heat_capacity*sharer.temperature-heat_capacity_sharer_to_self*sharer.temperature_archived + heat_capacity_self_to_sharer*temperature_archived)/new_sharer_heat_capacity)

			if(abs(old_sharer_heat_capacity) > MINIMUM_HEAT_CAPACITY)
				if(abs(new_sharer_heat_capacity/old_sharer_heat_capacity - 1) < 0.10) // <10% change in sharer heat capacity
					temperature_share(sharer, OPEN_HEAT_TRANSFER_COEFFICIENT)

	if((delta_temperature > MINIMUM_TEMPERATURE_TO_MOVE) || abs(moved_moles) > MINIMUM_MOLES_DELTA_TO_MOVE)
		var/delta_pressure = temperature_archived*(total_moles + moved_moles) - sharer.temperature_archived*(sharer.total_moles - moved_moles)
		return delta_pressure*R_IDEAL_GAS_EQUATION/volume

	else
		return 0

/datum/gas_mixture/proc/mimic(turf/model_turf, border_multiplier)
	//Purpose: Used transfer gas from a more pressurised tile to a less presurised unsimulated tile.
	//Called by: "sharing" from unsimulated to simulated turfs.
	//Inputs: Unsimulated turf, Multiplier for gas transfer (optional)
	//Outputs: Amount of gas exchanged

	var/datum/gas_mixture/model = model_turf.return_air()

	var/delta_temperature = (temperature_archived - model.temperature)

	var/heat_transferred = 0
	var/old_self_heat_capacity = 0
	var/heat_capacity_transferred = 0

	var/moved_moles

	for(var/gasid in gases)
		var/gas_delta = QUANTIZE(archived_gases[gasid] - model.gases[gasid])/TRANSFER_FRACTION

		if(abs(delta_temperature) > MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER)
			var/gas_heat_capacity = gas_specific_heat[gasid]
			heat_transferred -= gas_heat_capacity * model.temperature
			heat_capacity_transferred -= gas_heat_capacity

		if(border_multiplier)
			adjust_gas(gasid, -gas_delta*border_multiplier)
		else
			adjust_gas(gasid, -gas_delta)

		moved_moles += gas_delta


	if(abs(delta_temperature) > MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER)
		old_self_heat_capacity = heat_capacity*group_multiplier

	if(abs(delta_temperature) > MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER)
		var/new_self_heat_capacity = old_self_heat_capacity - heat_capacity_transferred
		if(new_self_heat_capacity > MINIMUM_HEAT_CAPACITY)
			if(border_multiplier)
				set_temperature((old_self_heat_capacity*temperature - heat_capacity_transferred*border_multiplier*temperature_archived)/new_self_heat_capacity)
			else
				set_temperature((old_self_heat_capacity*temperature - heat_capacity_transferred*border_multiplier*temperature_archived)/new_self_heat_capacity)

		temperature_mimic(model, model_turf.thermal_conductivity, border_multiplier)

	if((delta_temperature > MINIMUM_TEMPERATURE_TO_MOVE) || abs(moved_moles) > MINIMUM_MOLES_DELTA_TO_MOVE)
		var/delta_pressure = temperature_archived*(total_moles + moved_moles) - model.temperature*(model.total_moles)
		return delta_pressure*R_IDEAL_GAS_EQUATION/volume
	else
		return 0

/datum/gas_mixture/proc/check_both_then_temperature_share(datum/gas_mixture/sharer, conduction_coefficient)
	var/delta_temperature = (temperature_archived - sharer.temperature_archived)

	var/self_heat_capacity = heat_capacity_calc(archived_gases)
	var/sharer_heat_capacity = sharer.heat_capacity_calc(archived_gases)

	var/self_temperature_delta = 0
	var/sharer_temperature_delta = 0

	if((sharer_heat_capacity > MINIMUM_HEAT_CAPACITY) && (self_heat_capacity > MINIMUM_HEAT_CAPACITY))
		var/heat = conduction_coefficient*delta_temperature* \
			(self_heat_capacity*sharer_heat_capacity/(self_heat_capacity+sharer_heat_capacity))

		self_temperature_delta = -heat/(self_heat_capacity*group_multiplier)
		sharer_temperature_delta = heat/(sharer_heat_capacity*sharer.group_multiplier)
	else
		return 1

	if((abs(self_temperature_delta) > MINIMUM_TEMPERATURE_DELTA_TO_SUSPEND) \
		&& (abs(self_temperature_delta) > MINIMUM_TEMPERATURE_RATIO_TO_SUSPEND*temperature_archived))
		return 0

	if((abs(sharer_temperature_delta) > MINIMUM_TEMPERATURE_DELTA_TO_SUSPEND) \
		&& (abs(sharer_temperature_delta) > MINIMUM_TEMPERATURE_RATIO_TO_SUSPEND*sharer.temperature_archived))
		return -1

	temperature += self_temperature_delta
	sharer.temperature += sharer_temperature_delta

	return 1
	//Logic integrated from: temperature_share(sharer, conduction_coefficient) for efficiency

/datum/gas_mixture/proc/check_me_then_temperature_share(datum/gas_mixture/sharer, conduction_coefficient)
	var/delta_temperature = (temperature_archived - sharer.temperature_archived)

	var/self_heat_capacity = heat_capacity_calc(archived_gases)
	var/sharer_heat_capacity = sharer.heat_capacity_calc(archived_gases)

	var/self_temperature_delta = 0
	var/sharer_temperature_delta = 0

	if((sharer_heat_capacity > MINIMUM_HEAT_CAPACITY) && (self_heat_capacity > MINIMUM_HEAT_CAPACITY))
		var/heat = conduction_coefficient*delta_temperature* \
			(self_heat_capacity*sharer_heat_capacity/(self_heat_capacity+sharer_heat_capacity))

		self_temperature_delta = -heat/(self_heat_capacity*group_multiplier)
		sharer_temperature_delta = heat/(sharer_heat_capacity*sharer.group_multiplier)
	else
		return 1

	if((abs(self_temperature_delta) > MINIMUM_TEMPERATURE_DELTA_TO_SUSPEND) \
		&& (abs(self_temperature_delta) > MINIMUM_TEMPERATURE_RATIO_TO_SUSPEND*temperature_archived))
		return 0

	temperature += self_temperature_delta
	sharer.temperature += sharer_temperature_delta

	return 1
	//Logic integrated from: temperature_share(sharer, conduction_coefficient) for efficiency

/datum/gas_mixture/proc/check_me_then_temperature_turf_share(turf/simulated/sharer, conduction_coefficient)
	var/delta_temperature = (temperature_archived - sharer.temperature)

	var/self_temperature_delta = 0
	var/sharer_temperature_delta = 0

	if(abs(delta_temperature) > MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER)
		var/self_heat_capacity = heat_capacity_calc(archived_gases)

		if((sharer.heat_capacity > MINIMUM_HEAT_CAPACITY) && (self_heat_capacity > MINIMUM_HEAT_CAPACITY))
			var/heat = conduction_coefficient*delta_temperature* \
				(self_heat_capacity*sharer.heat_capacity/(self_heat_capacity+sharer.heat_capacity))

			self_temperature_delta = -heat/(self_heat_capacity*group_multiplier)
			sharer_temperature_delta = heat/sharer.heat_capacity
	else
		return 1

	if((abs(self_temperature_delta) > MINIMUM_TEMPERATURE_DELTA_TO_SUSPEND) \
		&& (abs(self_temperature_delta) > MINIMUM_TEMPERATURE_RATIO_TO_SUSPEND*temperature_archived))
		return 0

	temperature += self_temperature_delta
	sharer.temperature += sharer_temperature_delta

	return 1
	//Logic integrated from: temperature_turf_share(sharer, conduction_coefficient) for efficiency

/datum/gas_mixture/proc/check_me_then_temperature_mimic(turf/model, conduction_coefficient)
	var/delta_temperature = (temperature_archived - model.temperature)
	var/self_temperature_delta = 0

	if(abs(delta_temperature) > MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER)
		var/self_heat_capacity = heat_capacity_calc(archived_gases)

		if((model.heat_capacity > MINIMUM_HEAT_CAPACITY) && (self_heat_capacity > MINIMUM_HEAT_CAPACITY))
			var/heat = conduction_coefficient*delta_temperature* \
				(self_heat_capacity*model.heat_capacity/(self_heat_capacity+model.heat_capacity))

			self_temperature_delta = -heat/(self_heat_capacity*group_multiplier)

	if((abs(self_temperature_delta) > MINIMUM_TEMPERATURE_DELTA_TO_SUSPEND) \
		&& (abs(self_temperature_delta) > MINIMUM_TEMPERATURE_RATIO_TO_SUSPEND*temperature_archived))
		return 0

	set_temperature(temperature + self_temperature_delta)

	return 1
	//Logic integrated from: temperature_mimic(model, conduction_coefficient) for efficiency

/datum/gas_mixture/proc/temperature_share(datum/gas_mixture/sharer, conduction_coefficient)
	var/delta_temperature = (temperature_archived - sharer.temperature_archived)
	if(abs(delta_temperature) > MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER)
		var/self_heat_capacity = heat_capacity_calc(archived_gases)
		var/sharer_heat_capacity = sharer.heat_capacity_calc(archived_gases)
		if(!group_multiplier)
			message_admins("Error!  The gas mixture (ref \ref[src]) has no group multiplier!")
			return

		if((sharer_heat_capacity > MINIMUM_HEAT_CAPACITY) && (self_heat_capacity > MINIMUM_HEAT_CAPACITY))
			var/heat = conduction_coefficient*delta_temperature* \
				(self_heat_capacity*sharer_heat_capacity/(self_heat_capacity+sharer_heat_capacity))

			temperature -= heat/(self_heat_capacity*group_multiplier)
			sharer.temperature += heat/(sharer_heat_capacity*sharer.group_multiplier)

/datum/gas_mixture/proc/temperature_mimic(turf/model, conduction_coefficient, border_multiplier)
	var/delta_temperature = (temperature - model.temperature)
	if(abs(delta_temperature) > MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER)
		var/self_heat_capacity = heat_capacity//_archived()
		if(!group_multiplier)
			message_admins("Error!  The gas mixture (ref \ref[src]) has no group multiplier!")
			return

		if((model.heat_capacity > MINIMUM_HEAT_CAPACITY) && (self_heat_capacity > MINIMUM_HEAT_CAPACITY))
			var/heat = conduction_coefficient*delta_temperature* \
				(self_heat_capacity*model.heat_capacity/(self_heat_capacity+model.heat_capacity))

			if(border_multiplier)
				temperature -= heat*border_multiplier/(self_heat_capacity*group_multiplier)
			else
				temperature -= heat/(self_heat_capacity*group_multiplier)

/datum/gas_mixture/proc/temperature_turf_share(turf/simulated/sharer, conduction_coefficient)
	var/delta_temperature = (temperature_archived - sharer.temperature)
	if(abs(delta_temperature) > MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER)
		var/self_heat_capacity = heat_capacity

		if((sharer.heat_capacity > MINIMUM_HEAT_CAPACITY) && (self_heat_capacity > MINIMUM_HEAT_CAPACITY))
			var/heat = conduction_coefficient*delta_temperature* \
				(self_heat_capacity*sharer.heat_capacity/(self_heat_capacity+sharer.heat_capacity))

			temperature -= heat/(self_heat_capacity*group_multiplier)
			sharer.temperature += heat/sharer.heat_capacity

/datum/gas_mixture/proc/compare(datum/gas_mixture/sample)
	//Purpose: Compares sample to self to see if within acceptable ranges that group processing may be enabled
	//Called by: Airgroups trying to rebuild
	//Inputs: Gas mix to compare
	//Outputs: 1 if can rebuild, 0 if not.
	if(!sample) return 0

	for(var/gasid in gases)
		var/current_gas = gases[gasid]
		var/sample_gas = sample.gases[gasid]
		if((abs(current_gas - sample_gas) > MINIMUM_AIR_TO_SUSPEND) && \
		((current_gas < (1-MINIMUM_AIR_RATIO_TO_SUSPEND)*sample_gas) || (current_gas > (1+MINIMUM_AIR_RATIO_TO_SUSPEND)*sample_gas)))
			return 0

	if(total_moles > MINIMUM_AIR_TO_SUSPEND)
		if((abs(temperature-sample.temperature) > MINIMUM_TEMPERATURE_DELTA_TO_SUSPEND) && \
			((temperature < (1-MINIMUM_TEMPERATURE_RATIO_TO_SUSPEND)*sample.temperature) || (temperature > (1+MINIMUM_TEMPERATURE_RATIO_TO_SUSPEND)*sample.temperature)))
			//world << "temp fail [temperature] & [sample.temperature]"
			return 0
	return 1

/datum/gas_mixture/proc/add(datum/gas_mixture/right_side)
	if(!right_side)
		return 0

	for(var/gasid in right_side.gases)
		adjust_gas(gasid, right_side.gases[gasid], 0, 0)

	return 1

/datum/gas_mixture/proc/subtract(datum/gas_mixture/right_side)
	//Purpose: Subtracts right_side from air_mixture. Used to help turfs mingle
	//Called by: Pipelines ending in a break (or something)
	//Inputs: Gas mix to remove
	//Outputs: 1

	for(var/gasid in right_side.gases)
		adjust_gas(gasid, -right_side.gases[gasid], 0, 0)

	return 1

/datum/gas_mixture/proc/multiply(factor)

	for(var/gasid in gases)
		adjust_gas(gasid, (factor - 1) * gases[gasid], 0, 0)

	return 1

/datum/gas_mixture/proc/divide(factor)
	return multiply(1/factor)
