/*
	Atmos processes

	These procs generalize various processes used by atmos machinery, such as pumping, filtering, or scrubbing gas, allowing them to be reused elsewhere.
	If no gas was moved/pumped/filtered/whatever, they return a negative number.
	Otherwise they return the amount of energy needed to do whatever it is they do (equivalently power if done over 1 second).
	In the case of free-flowing gas you can do things with gas and still use 0 power, hence the distinction between negative and non-negative return values.
*/

/*
/obj/machinery/atmospherics/var/last_flow_rate = 0
/obj/machinery/atmospherics/var/last_power_draw = 0
/obj/machinery/portable_atmospherics/var/last_flow_rate = 0

*/

// These balance how easy or hard it is to create huge pressure gradients with pumps and filters.
// Lower values means it takes longer to create large pressures differences.
// Has no effect on pumping gasses from high pressure to low, only from low to high.
#define ATMOS_PUMP_EFFICIENCY   2.5
#define ATMOS_FILTER_EFFICIENCY 2.5

// Will not bother pumping or filtering if the gas source as fewer than this amount of moles, to help with performance.
#define MINIMUM_MOLES_TO_PUMP   0.01
#define MINIMUM_MOLES_TO_FILTER 0.04


/obj/machinery/atmospherics/var/debug = 0

/client/proc/atmos_toggle_debug(obj/machinery/atmospherics/M in world)
	set name = "Toggle Debug Messages"
	set category = "Debug"
	M.debug = !M.debug
	to_chat(usr, "[M]: Debug messages toggled [M.debug? "on" : "off"].")

//Generalized gas pumping proc.
//Moves gas from one gas_mixture to another and returns the amount of power needed (assuming 1 second), or -1 if no gas was pumped.
//transfer_moles - Limits the amount of moles to transfer. The actual amount of gas moved may also be limited by available_power, if given.
//available_power - the maximum amount of power that may be used when moving gas. If null then the transfer is not limited by power.
/proc/pump_gas(datum/gas_mixture/source, datum/gas_mixture/sink, transfer_moles = null, available_power = null)
	if (source.total_moles < MINIMUM_MOLES_TO_PUMP) //if we can't transfer enough gas just stop to avoid further processing
		return -1

	if (isnull(transfer_moles))
		transfer_moles = source.total_moles
	else
		transfer_moles = min(source.total_moles, transfer_moles)

	//Calculate the amount of energy required and limit transfer_moles based on available power
	var/specific_power = calculate_specific_power(source, sink)/ATMOS_PUMP_EFFICIENCY //this has to be calculated before we modify any gas mixtures
	if (!isnull(available_power) && specific_power > 0)
		transfer_moles = min(transfer_moles, available_power / specific_power)

	if (transfer_moles < MINIMUM_MOLES_TO_PUMP) //if we can't transfer enough gas just stop to avoid further processing
		return -1

	/*
	//Update flow rate meter
	if (istype(M, /obj/machinery/atmospherics))
		var/obj/machinery/atmospherics/A = M
		A.last_flow_rate = (transfer_moles/source.total_moles)*source.volume //group_multiplier gets divided out here

		if (A.debug)
			A.visible_message("[A]: source entropy: [round(source.specific_entropy(), 0.01)] J/Kmol --> sink entropy: [round(sink.specific_entropy(), 0.01)] J/Kmol")
			A.visible_message("[A]: specific entropy change = [round(sink.specific_entropy() - source.specific_entropy(), 0.01)] J/Kmol")
			A.visible_message("[A]: specific power = [round(specific_power, 0.1)] W/mol")
			A.visible_message("[A]: moles transferred = [transfer_moles] mol")

	if (istype(M, /obj/machinery/portable_atmospherics))
		var/obj/machinery/portable_atmospherics/P = M
		P.last_flow_rate = (transfer_moles/source.total_moles)*source.volume //group_multiplier gets divided out here
	*/

	var/datum/gas_mixture/removed = source.remove(transfer_moles)
	if (!removed) //Just in case
		return -1

	var/power_draw = specific_power*transfer_moles

	sink.merge(removed)

	return power_draw

//Gas 'pumping' proc for the case where the gas flow is passive and driven entirely by pressure differences (but still one-way).
/proc/pump_gas_passive(datum/gas_mixture/source, datum/gas_mixture/sink, transfer_moles = null)
	if (source.total_moles < MINIMUM_MOLES_TO_PUMP) //if we can't transfer enough gas just stop to avoid further processing
		return -1

	if (isnull(transfer_moles))
		transfer_moles = source.total_moles
	else
		transfer_moles = min(source.total_moles, transfer_moles)

	var/equalize_moles = calculate_equalize_moles(source, sink)
	transfer_moles = min(transfer_moles, equalize_moles)

	if (transfer_moles < MINIMUM_MOLES_TO_PUMP) //if we cant transfer enough gas just stop to avoid further processing
		return -1

	/*
	//Update flow rate meter
	if (istype(M, /obj/machinery/atmospherics))
		var/obj/machinery/atmospherics/A = M
		A.last_flow_rate = (transfer_moles/source.total_moles)*source.volume //group_multiplier gets divided out here
		if (A.debug)
			A.visible_message("[A]: moles transferred = [transfer_moles] mol")

	if (istype(M, /obj/machinery/portable_atmospherics))
		var/obj/machinery/portable_atmospherics/P = M
		P.last_flow_rate = (transfer_moles/source.total_moles)*source.volume //group_multiplier gets divided out here
	*/

	var/datum/gas_mixture/removed = source.remove(transfer_moles)
	if(!removed) //Just in case
		return -1
	sink.merge(removed)

	return 0

//Generalized gas scrubbing proc.
//Selectively moves specified gasses one gas_mixture to another and returns the amount of power needed (assuming 1 second), or -1 if no gas was filtered.
//filtering - A list of gasids to be scrubbed from source
//total_transfer_moles - Limits the amount of moles to scrub. The actual amount of gas scrubbed may also be limited by available_power, if given.
//available_power - the maximum amount of power that may be used when scrubbing gas. If null then the scrubbing is not limited by power.
/proc/scrub_gas(list/filtering, datum/gas_mixture/source, datum/gas_mixture/sink, total_transfer_moles = null, available_power = null)
	if (source.total_moles < MINIMUM_MOLES_TO_FILTER) //if we cant transfer enough gas just stop to avoid further processing
		return -1

	filtering = filtering & source.gas	//only filter gasses that are actually there. DO NOT USE &=

	//Determine the specific power of each filterable gas type, and the total amount of filterable gas (gasses selected to be scrubbed)
	var/total_filterable_moles = 0			//the total amount of filterable gas
	var/list/specific_power_gas = list()	//the power required to remove one mole of pure gas, for each gas type
	for (var/g in filtering)
		if (source.gas[g] < MINIMUM_MOLES_TO_FILTER)
			continue

		var/specific_power = calculate_specific_power_gas(g, source, sink)/ATMOS_FILTER_EFFICIENCY
		specific_power_gas[g] = specific_power
		total_filterable_moles += source.gas[g]

	if (total_filterable_moles < MINIMUM_MOLES_TO_FILTER) //if we cant transfer enough gas just stop to avoid further processing
		return -1

	//now that we know the total amount of filterable gas, we can calculate the amount of power needed to scrub one mole of gas
	var/total_specific_power = 0		//the power required to remove one mole of filterable gas
	for (var/g in filtering)
		var/ratio = source.gas[g]/total_filterable_moles //this converts the specific power per mole of pure gas to specific power per mole of scrubbed gas
		total_specific_power += specific_power_gas[g]*ratio

	//Figure out how much of each gas to filter
	if (isnull(total_transfer_moles))
		total_transfer_moles = total_filterable_moles
	else
		total_transfer_moles = min(total_transfer_moles, total_filterable_moles)

	//limit transfer_moles based on available power
	if (!isnull(available_power) && total_specific_power > 0)
		total_transfer_moles = min(total_transfer_moles, available_power/total_specific_power)

	if (total_transfer_moles < MINIMUM_MOLES_TO_FILTER) //if we cant transfer enough gas just stop to avoid further processing
		return -1

	/*
	//Update flow rate var
	if (istype(M, /obj/machinery/atmospherics))
		var/obj/machinery/atmospherics/A = M
		A.last_flow_rate = (total_transfer_moles/source.total_moles)*source.volume //group_multiplier gets divided out here
	if (istype(M, /obj/machinery/portable_atmospherics))
		var/obj/machinery/portable_atmospherics/P = M
		P.last_flow_rate = (total_transfer_moles/source.total_moles)*source.volume //group_multiplier gets divided out here
	*/

	var/power_draw = 0
	for (var/g in filtering)
		var/transfer_moles = source.gas[g]
		//filter gas in proportion to the mole ratio
		transfer_moles = min(transfer_moles, total_transfer_moles*(source.gas[g]/total_filterable_moles))

		//use update=0. All the filtered gasses are supposed to be added simultaneously, so we update after the for loop.
		source.adjust_gas(g, -transfer_moles, update=0)
		sink.adjust_gas_temp(g, transfer_moles, source.temperature, update=0)

		power_draw += specific_power_gas[g]*transfer_moles

	//Remix the resulting gases
	sink.update_values()
	source.update_values()

	return power_draw

//Generalized gas filtering proc.
//Filtering is a bit different from scrubbing. Instead of selectively moving the targeted gas types from one gas mix to another, filtering splits
//the input gas into two outputs: one that contains /only/ the targeted gas types, and another that completely clean of the targeted gas types.
//filtering - A list of gasids to be filtered. These gasses get moved to sink_filtered, while the other gasses get moved to sink_clean.
//total_transfer_moles - Limits the amount of moles to input. The actual amount of gas filtered may also be limited by available_power, if given.
//available_power - the maximum amount of power that may be used when filtering gas. If null then the filtering is not limited by power.
/proc/filter_gas(list/filtering, datum/gas_mixture/source, datum/gas_mixture/sink_filtered, datum/gas_mixture/sink_clean, total_transfer_moles = null, available_power = null)
	if (source.total_moles < MINIMUM_MOLES_TO_FILTER) //if we cant transfer enough gas just stop to avoid further processing
		return -1

	filtering = filtering & source.gas	//only filter gasses that are actually there. DO NOT USE &=

	var/total_specific_power = 0		//the power required to remove one mole of input gas
	var/total_filterable_moles = 0		//the total amount of filterable gas
	var/total_unfilterable_moles = 0	//the total amount of non-filterable gas
	var/list/specific_power_gas = list()	//the power required to remove one mole of pure gas, for each gas type
	for (var/g in source.get_gases())
		if (source.gas[g] < MINIMUM_MOLES_TO_FILTER)
			continue

		if (g in filtering)
			specific_power_gas[g] = calculate_specific_power_gas(g, source, sink_filtered)/ATMOS_FILTER_EFFICIENCY
			total_filterable_moles += source.gas[g]
		else
			specific_power_gas[g] = calculate_specific_power_gas(g, source, sink_clean)/ATMOS_FILTER_EFFICIENCY
			total_unfilterable_moles += source.gas[g]

		var/ratio = source.gas[g]/source.total_moles //converts the specific power per mole of pure gas to specific power per mole of input gas mix
		total_specific_power += specific_power_gas[g]*ratio

	//Figure out how much of each gas to filter
	if (isnull(total_transfer_moles))
		total_transfer_moles = source.total_moles
	else
		total_transfer_moles = min(total_transfer_moles, source.total_moles)

	//limit transfer_moles based on available power
	if (!isnull(available_power) && total_specific_power > 0)
		total_transfer_moles = min(total_transfer_moles, available_power/total_specific_power)

	if (total_transfer_moles < MINIMUM_MOLES_TO_FILTER) //if we cant transfer enough gas just stop to avoid further processing
		return -1

	//Update flow rate var
	/*
	if (istype(M, /obj/machinery/atmospherics))
		var/obj/machinery/atmospherics/A = M
		A.last_flow_rate = (total_transfer_moles/source.total_moles)*source.volume //group_multiplier gets divided out here
	*/

	var/datum/gas_mixture/removed = source.remove(total_transfer_moles)
	if (!removed) //Just in case
		return -1

	var/filtered_power_used = 0		//power used to move filterable gas to sink_filtered
	var/unfiltered_power_used = 0	//power used to move unfilterable gas to sink_clean
	for (var/g in removed.gas)
		var/power_used = specific_power_gas[g]*removed.gas[g]

		if (g in filtering)
			//use update=0. All the filtered gasses are supposed to be added simultaneously, so we update after the for loop.
			sink_filtered.adjust_gas_temp(g, removed.gas[g], removed.temperature, update=0)
			removed.adjust_gas(g, -removed.gas[g], update=0)
			filtered_power_used += power_used
		else
			unfiltered_power_used += power_used

	sink_filtered.update_values()
	removed.update_values()

	sink_clean.merge(removed)

	return filtered_power_used + unfiltered_power_used

//For omni devices. Instead filtering is an associative list mapping gasids to gas mixtures.
//I don't like the copypasta, but I decided to keep both versions of gas filtering as filter_gas is slightly faster (doesn't create as many temporary lists, doesn't call update_values() as much)
//filter_gas can be removed and replaced with this proc if need be.
/proc/filter_gas_multi(obj/machinery/M, list/filtering, datum/gas_mixture/source, datum/gas_mixture/sink_clean, total_transfer_moles = null, available_power = null)
	if (source.total_moles < MINIMUM_MOLES_TO_FILTER) //if we cant transfer enough gas just stop to avoid further processing
		return -1

	filtering = filtering & source.gas	//only filter gasses that are actually there. DO NOT USE &=

	var/total_specific_power = 0		//the power required to remove one mole of input gas
	var/total_filterable_moles = 0		//the total amount of filterable gas
	var/total_unfilterable_moles = 0	//the total amount of non-filterable gas
	var/list/specific_power_gas = list()	//the power required to remove one mole of pure gas, for each gas type
	for (var/g in source.gas)
		if (source.gas[g] < MINIMUM_MOLES_TO_FILTER)
			continue

		if (g in filtering)
			var/datum/gas_mixture/sink_filtered = filtering[g]
			specific_power_gas[g] = calculate_specific_power_gas(g, source, sink_filtered)/ATMOS_FILTER_EFFICIENCY
			total_filterable_moles += source.gas[g]
		else
			specific_power_gas[g] = calculate_specific_power_gas(g, source, sink_clean)/ATMOS_FILTER_EFFICIENCY
			total_unfilterable_moles += source.gas[g]

		var/ratio = source.gas[g]/source.total_moles //converts the specific power per mole of pure gas to specific power per mole of input gas mix
		total_specific_power += specific_power_gas[g]*ratio

	//Figure out how much of each gas to filter
	if (isnull(total_transfer_moles))
		total_transfer_moles = source.total_moles
	else
		total_transfer_moles = min(total_transfer_moles, source.total_moles)

	//limit transfer_moles based on available power
	if (!isnull(available_power) && total_specific_power > 0)
		total_transfer_moles = min(total_transfer_moles, available_power/total_specific_power)

	if (total_transfer_moles < MINIMUM_MOLES_TO_FILTER) //if we cant transfer enough gas just stop to avoid further processing
		return -1

	/*
	//Update Flow Rate var
	if (istype(M, /obj/machinery/atmospherics))
		var/obj/machinery/atmospherics/A = M
		A.last_flow_rate = (total_transfer_moles/source.total_moles)*source.volume //group_multiplier gets divided out here
	if (istype(M, /obj/machinery/portable_atmospherics))
		var/obj/machinery/portable_atmospherics/P = M
		P.last_flow_rate = (total_transfer_moles/source.total_moles)*source.volume //group_multiplier gets divided out here
	*/

	var/datum/gas_mixture/removed = source.remove(total_transfer_moles)
	if (!removed) //Just in case
		return -1

	var/list/filtered_power_used = list()		//power used to move filterable gas to the filtered gas mixes
	var/unfiltered_power_used = 0	//power used to move unfilterable gas to sink_clean
	for (var/g in removed.gas)
		var/power_used = specific_power_gas[g]*removed.gas[g]

		if (g in filtering)
			var/datum/gas_mixture/sink_filtered = filtering[g]
			//use update=0. All the filtered gasses are supposed to be added simultaneously, so we update after the for loop.
			sink_filtered.adjust_gas_temp(g, removed.gas[g], removed.temperature, update=1)
			removed.adjust_gas(g, -removed.gas[g], update=0)
			if (power_used)
				filtered_power_used[sink_filtered] = power_used
		else
			unfiltered_power_used += power_used

	removed.update_values()

	var/power_draw = unfiltered_power_used
	for (var/datum/gas_mixture/sink_filtered in filtered_power_used)
		power_draw += filtered_power_used[sink_filtered]

	sink_clean.merge(removed)

	return power_draw

//Similar deal as the other atmos process procs.
//mix_sources maps input gas mixtures to mix ratios. The mix ratios MUST add up to 1.
/proc/mix_gas(list/mix_sources, datum/gas_mixture/sink, total_transfer_moles = null, available_power = null)
	if (!mix_sources.len)
		return -1

	var/total_specific_power = 0	//the power needed to mix one mole of gas
	var/total_mixing_moles = null	//the total amount of gas that can be mixed, given our mix ratios
	var/total_input_volume = 0		//for flow rate calculation
	var/total_input_moles = 0		//for flow rate calculation
	var/list/source_specific_power = list()
	for (var/datum/gas_mixture/source in mix_sources)
		if (source.total_moles < MINIMUM_MOLES_TO_FILTER)
			return -1	//either mix at the set ratios or mix no gas at all

		var/mix_ratio = mix_sources[source]
		if (!mix_ratio)
			continue	//this gas is not being mixed in

		//mixing rate is limited by the source with the least amount of available gas
		var/this_mixing_moles = source.total_moles/mix_ratio
		if (isnull(total_mixing_moles) || total_mixing_moles > this_mixing_moles)
			total_mixing_moles = this_mixing_moles

		source_specific_power[source] = calculate_specific_power(source, sink)*mix_ratio/ATMOS_FILTER_EFFICIENCY
		total_specific_power += source_specific_power[source]
		total_input_volume += source.volume
		total_input_moles += source.total_moles

	if (total_mixing_moles < MINIMUM_MOLES_TO_FILTER) //if we cant transfer enough gas just stop to avoid further processing
		return -1

	if (isnull(total_transfer_moles))
		total_transfer_moles = total_mixing_moles
	else
		total_transfer_moles = min(total_mixing_moles, total_transfer_moles)

	//limit transfer_moles based on available power
	if (!isnull(available_power) && total_specific_power > 0)
		total_transfer_moles = min(total_transfer_moles, available_power / total_specific_power)

	if (total_transfer_moles < MINIMUM_MOLES_TO_FILTER) //if we cant transfer enough gas just stop to avoid further processing
		return -1

	/*
	//Update flow rate var
	if (istype(M, /obj/machinery/atmospherics))
		var/obj/machinery/atmospherics/A = M
		A.last_flow_rate = (total_transfer_moles/total_input_moles)*total_input_volume //group_multiplier gets divided out here
	if (istype(M, /obj/machinery/portable_atmospherics))
		var/obj/machinery/portable_atmospherics/P = M
		P.last_flow_rate = (total_transfer_moles/total_input_moles)*total_input_volume //group_multiplier gets divided out here
	*/

	var/total_power_draw = 0
	for (var/datum/gas_mixture/source in mix_sources)
		var/mix_ratio = mix_sources[source]
		if (!mix_ratio)
			continue

		var/transfer_moles = total_transfer_moles * mix_ratio

		var/datum/gas_mixture/removed = source.remove(transfer_moles)

		var/power_draw = transfer_moles * source_specific_power[source]
		total_power_draw += power_draw

		sink.merge(removed)

	return total_power_draw

/*
	Helper procs for various things.
*/

//Calculates the amount of power needed to move one mole from source to sink.
/proc/calculate_specific_power(datum/gas_mixture/source, datum/gas_mixture/sink)
	//Calculate the amount of energy required
	var/air_temperature = (sink.temperature > 0)? sink.temperature : source.temperature
	var/specific_entropy = sink.specific_entropy() - source.specific_entropy() //sink is gaining moles, source is loosing
	var/specific_power = 0	// W/mol

	//If specific_entropy is < 0 then power is required to move gas
	if (specific_entropy < 0)
		specific_power = -specific_entropy*air_temperature		//how much power we need per mole

	return specific_power

//Calculates the amount of power needed to move one mole of a certain gas from source to sink.
/proc/calculate_specific_power_gas(gasid, datum/gas_mixture/source, datum/gas_mixture/sink)
	//Calculate the amount of energy required
	var/air_temperature = (sink.temperature > 0)? sink.temperature : source.temperature
	var/specific_entropy = sink.specific_entropy_gas(gasid) - source.specific_entropy_gas(gasid) //sink is gaining moles, source is loosing
	var/specific_power = 0	// W/mol

	//If specific_entropy is < 0 then power is required to move gas
	if (specific_entropy < 0)
		specific_power = -specific_entropy*air_temperature		//how much power we need per mole

	return specific_power

//Calculates the APPROXIMATE amount of moles that would need to be transferred to change the pressure of sink by pressure_delta
//If set, sink_volume_mod adjusts the effective output volume used in the calculation. This is useful when the output gas_mixture is
//part of a pipenetwork, and so it's volume isn't representative of the actual volume since the gas will be shared across the pipenetwork when it processes.
/proc/calculate_transfer_moles(datum/gas_mixture/source, datum/gas_mixture/sink, pressure_delta, sink_volume_mod=0)
	if(source.temperature == 0 || source.total_moles == 0) return 0

	var/output_volume = (sink.volume * sink.group_multiplier) + sink_volume_mod
	var/source_total_moles = source.total_moles * source.group_multiplier

	var/air_temperature = source.temperature
	if(sink.total_moles > 0 && sink.temperature > 0)
		//estimate the final temperature of the sink after transfer
		var/estimate_moles = pressure_delta*output_volume/(sink.temperature * R_IDEAL_GAS_EQUATION)
		var/sink_heat_capacity = sink.heat_capacity()
		var/transfer_heat_capacity = source.heat_capacity()*estimate_moles/source_total_moles
		air_temperature = (sink.temperature*sink_heat_capacity  + source.temperature*transfer_heat_capacity) / (sink_heat_capacity + transfer_heat_capacity)

	//get the number of moles that would have to be transfered to bring sink to the target pressure
	return pressure_delta*output_volume/(air_temperature * R_IDEAL_GAS_EQUATION)

//Calculates the APPROXIMATE amount of moles that would need to be transferred to bring source and sink to the same pressure
/proc/calculate_equalize_moles(datum/gas_mixture/source, datum/gas_mixture/sink)
	if(source.temperature == 0) return 0

	//Make the approximation that the sink temperature is unchanged after transferring gas
	var/source_volume = source.volume * source.group_multiplier
	var/sink_volume = sink.volume * sink.group_multiplier

	var/source_pressure = source.return_pressure()
	var/sink_pressure = sink.return_pressure()

	return (source_pressure - sink_pressure)/(R_IDEAL_GAS_EQUATION * (source.temperature/source_volume + sink.temperature/sink_volume))

//Determines if the atmosphere is safe (for humans). Safe atmosphere:
// - Is between 80 and 120kPa
// - Has between 17% and 30% oxygen
// - Has temperature between -10C and 50C
// - Has no or only minimal phoron or N2O
/proc/get_atmosphere_issues(datum/gas_mixture/atmosphere, returntext = 0)
	var/list/status = list()
	if(!atmosphere)
		status.Add("No atmosphere present.")

	// Temperature check
	if((atmosphere.temperature > (T0C + 50)) || (atmosphere.temperature < (T0C - 10)))
		status.Add("Temperature too [atmosphere.temperature > (T0C + 50) ? "high" : "low"].")

	// Pressure check
	var/pressure = atmosphere.return_pressure()
	if((pressure > 120) || (pressure < 80))
		status.Add("Pressure too [pressure > 120 ? "high" : "low"].")

	// Gas concentration checks
	var/oxygen = 0
	var/phoron = 0
	var/carbondioxide = 0
	var/nitrousoxide = 0
	var/hydrogen = 0
	if(atmosphere.total_moles) // Division by zero prevention
		oxygen = (atmosphere.gas[GAS_OXYGEN] / atmosphere.total_moles) * 100 // Percentage of the gas
		phoron = (atmosphere.gas[GAS_PLASMA] / atmosphere.total_moles) * 100
		carbondioxide = (atmosphere.gas[GAS_CO2] / atmosphere.total_moles) * 100
		nitrousoxide = (atmosphere.gas[GAS_N2O] / atmosphere.total_moles) * 100
		hydrogen = (atmosphere.gas[GAS_HYDROGEN] / atmosphere.total_moles) * 100

	if(!oxygen)
		status.Add("No oxygen.")
	else if((oxygen > 30) || (oxygen < 17))
		status.Add("Oxygen too [oxygen > 30 ? "high" : "low"].")



	if(phoron > 0.1)		// Toxic even in small amounts.
		status.Add("Phoron contamination.")
	if(nitrousoxide > 0.1)	// Probably slightly less dangerous but still.
		status.Add("N2O contamination.")
	if(hydrogen > 2.5)	// Not too dangerous, but flammable.
		status.Add("Hydrogen contamination.")
	if(carbondioxide > 5)	// Not as dangerous until very large amount is present.
		status.Add("CO2 concentration high.")


	if(returntext)
		return jointext(status, " ")
	else
		return status.len

#undef MINIMUM_MOLES_TO_PUMP
#undef MINIMUM_MOLES_TO_FILTER
#undef ATMOS_PUMP_EFFICIENCY
#undef ATMOS_FILTER_EFFICIENCY
