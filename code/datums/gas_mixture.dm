 /*
What are the archived variables for?
	Calculations are done using the archived variables with the results merged into the regular variables.
	This prevents race conditions that arise based on the order of tile processing.
*/

#define SPECIFIC_HEAT_TOXIN		200
#define SPECIFIC_HEAT_AIR		20
#define SPECIFIC_HEAT_CDO		30
#define HEAT_CAPACITY_CALCULATION(oxygen,carbon_dioxide,nitrogen,toxins) \
	(carbon_dioxide*SPECIFIC_HEAT_CDO + (oxygen+nitrogen)*SPECIFIC_HEAT_AIR + toxins*SPECIFIC_HEAT_TOXIN)

#define MINIMUM_HEAT_CAPACITY	0.0003
#define QUANTIZE(variable)		(round(variable,0.0000001))/*I feel the need to document what happens here. Basically this is used to catch most rounding errors, however it's previous value made it so that
															once gases got hot enough, most procedures wouldnt occur due to the fact that the mole counts would get rounded away. Thus, we lowered it a few orders of magnititude */
/*
/datum/gas
	var/moles = 0
	var/specific_heat = 0

	var/moles_archived = 0

/datum/gas/sleeping_agent
		specific_heat = 40

/datum/gas/oxygen_agent_b
		specific_heat = 300

/datum/gas/volatile_fuel
		specific_heat = 30
*/
var/list/meta_gas_info = list( //this is also the list that decides what gases exist and in what order
	list(20, "Oxygen"), 			//GAS_O2
	list(20, "Nitrogen"), 			//GAS_N2
	list(30, "Carbon Dioxide"),		//GAS_C02
	list(200, "Plasma"),			//GAS_PLASMA
	list(40, "Nitrous Oxide"),		//GAS_N20
	list(300, "Oxygen Agent B"),	//GAS_AGENT_B
	list(30, "Volatile Fuel")		//GAS_V_FUEL
)

var/list/cached_gases_list = null


/proc/gaseslist()
	var/gascount = meta_gas_info.len
	. = new /list(gascount)
	for (var/i in 1 to gascount)
		.[i] = gaslist(i)


/proc/gaslist(gasid)
	if (!cached_gases_list)
		cached_gases_list = new /list(meta_gas_info.len)
	if (!cached_gases_list[gasid])
		cached_gases_list[gasid] = list (
			0,					//MOLES
			0,					//ARCHIVE
			gasid,				//GAS_INDEX
		)
		cached_gases_list[gasid] += meta_gas_info[gasid]	//All the rest
	var/list/gas = cached_gases_list[gasid]
	. = gas.Copy()

/datum/gas_mixture
	/*
	var/oxygen = 0
	var/carbon_dioxide = 0
	var/nitrogen = 0
	var/toxins = 0
	*/
	var/volume = CELL_VOLUME

	var/temperature //in Kelvin

	var/last_share

	//var/list/datum/gas/trace_gases = list()
	var/list/gases

	/*
	var/tmp/oxygen_archived
	var/tmp/carbon_dioxide_archived
	var/tmp/nitrogen_archived
	var/tmp/toxins_archived
	*/
	var/tmp/temperature_archived

	var/tmp/fuel_burnt

/datum/gas_mixture/New(Volume = CELL_VOLUME)
	. = ..()
	gases = gaseslist()
	temperature = 0
	temperature_archived = 0
	volume = Volume
	last_share = 0
	fuel_burnt = 0
	//PV=nRT - related procedures
/datum/gas_mixture/proc/heat_capacity()
	for(var/gas in gases)
		. += gas[MOLES]*gas[SPECIFIC_HEAT]

/datum/gas_mixture/proc/heat_capacity_archived()
	for(var/gas in gases)
		. += gas[ARCHIVE]*gas[SPECIFIC_HEAT]

/datum/gas_mixture/proc/total_moles()
	for(var/gas in gases)
		. += gas[MOLES]

/datum/gas_mixture/proc/return_pressure()
	if(volume>0)
		return total_moles()*R_IDEAL_GAS_EQUATION*temperature/volume
	return 0

/datum/gas_mixture/proc/return_temperature()
	return temperature


/datum/gas_mixture/proc/return_volume()
	return max(0, volume)


/datum/gas_mixture/proc/thermal_energy()
	return temperature*heat_capacity()


//Procedures used for very specific events


/datum/gas_mixture/proc/react(atom/dump_location)
	var/list/procgases = gases //this speeds things up because >byond
	var/reacting = 0 //set to 1 if a notable reaction occured (used by pipe_network)
	if(temperature < TCMB)
		temperature = TCMB
	if(temperature > 900)
		if(procgases[GAS_PL][MOLES] > MINIMUM_HEAT_CAPACITY && procgases[GAS_CO2][MOLES] > MINIMUM_HEAT_CAPACITY)
			if(procgases[GAS_AGENT_B][MOLES])
				var/reaction_rate = min(procgases[GAS_CO2][MOLES]*0.75, procgases[GAS_PL][MOLES]*0.25, procgases[GAS_AGENT_B][MOLES]*0.05)
				procgases[GAS_CO2][MOLES] -= reaction_rate
				procgases[GAS_O2][MOLES] += reaction_rate

				procgases[GAS_AGENT_B][MOLES] -= reaction_rate*0.05

				temperature -= (reaction_rate*20000)/heat_capacity()

				reacting = 1
	if(thermal_energy() > (PLASMA_BINDING_ENERGY*10))
		if(procgases[GAS_PL][MOLES] > MINIMUM_HEAT_CAPACITY && procgases[GAS_CO2][MOLES] > MINIMUM_HEAT_CAPACITY && (procgases[GAS_PL][MOLES]+procgases[GAS_CO2][MOLES])/total_moles() >= FUSION_PURITY_THRESHOLD)//Fusion wont occur if the level of impurities is too high.
			//world << "pre [temperature, [toxins], [carbon_dioxide]
			var/old_heat_capacity = heat_capacity()
			var/carbon_efficency = min(procgases[GAS_PL][MOLES]/procgases[GAS_CO2][MOLES],MAX_CARBON_EFFICENCY)
			var/reaction_energy = thermal_energy()
			var/moles_impurities = total_moles()-(procgases[GAS_PL][MOLES]+procgases[GAS_CO2][MOLES])
			var/plasma_fused = (PLASMA_FUSED_COEFFICENT*carbon_efficency)*(temperature/PLASMA_BINDING_ENERGY)
			var/carbon_catalyzed = (CARBON_CATALYST_COEFFICENT*carbon_efficency)*(temperature/PLASMA_BINDING_ENERGY)
			var/oxygen_added = carbon_catalyzed
			var/nitrogen_added = (plasma_fused-oxygen_added)-(thermal_energy()/PLASMA_BINDING_ENERGY)

			reaction_energy = max(reaction_energy+((carbon_efficency*procgases[GAS_PL][MOLES])/((moles_impurities/carbon_efficency)+2)*10)+((plasma_fused/(moles_impurities/carbon_efficency))*PLASMA_BINDING_ENERGY),0)
			procgases[GAS_PL][MOLES] = max(procgases[GAS_PL][MOLES]-plasma_fused,0)
			procgases[GAS_CO2][MOLES] = max(procgases[GAS_CO2][MOLES]-carbon_catalyzed,0)
			procgases[GAS_O2][MOLES] = max(procgases[GAS_O2][MOLES]+oxygen_added,0)
			procgases[GAS_N2][MOLES] = max(procgases[GAS_N2][MOLES]+nitrogen_added,0)
			if(reaction_energy > 0)
				reacting = 1
				var/new_heat_capacity = heat_capacity()
				if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
					temperature = max(((temperature*old_heat_capacity + reaction_energy)/new_heat_capacity),TCMB)
					//Prevents whatever mechanism is causing it to hit negative temperatures.
				//world << "post [temperature], [toxins], [carbon_dioxide]



	fuel_burnt = 0
	if(temperature > FIRE_MINIMUM_TEMPERATURE_TO_EXIST)
		//world << "pre [temperature], [oxygen], [toxins]"
		if(fire())
			reacting = 1
		//world << "post [temperature], [oxygen], [toxins]"

	return reacting

/datum/gas_mixture/proc/fire()
	var/energy_released = 0
	var/old_heat_capacity = heat_capacity()
	var/list/procgases = gases //this speeds things up because accessing datum vars is slow

	if(procgases[GAS_V_FUEL][MOLES]) //General volatile gas burn
		var/burned_fuel = 0

		if(procgases[GAS_O2][MOLES] < procgases[GAS_V_FUEL][MOLES])
			burned_fuel = procgases[GAS_O2][MOLES]
			procgases[GAS_V_FUEL][MOLES] -= burned_fuel
			procgases[GAS_O2][MOLES] = 0
		else
			burned_fuel = procgases[GAS_V_FUEL][MOLES]
			procgases[GAS_O2][MOLES] -= procgases[GAS_V_FUEL][MOLES]

		energy_released += FIRE_CARBON_ENERGY_RELEASED * burned_fuel
		procgases[GAS_CO2][MOLES] += burned_fuel
		fuel_burnt += burned_fuel

	//Handle plasma burning
	if(procgases[GAS_PL][MOLES] > MINIMUM_HEAT_CAPACITY)
		var/plasma_burn_rate = 0
		var/oxygen_burn_rate = 0
		//more plasma released at higher temperatures
		var/temperature_scale
		if(temperature > PLASMA_UPPER_TEMPERATURE)
			temperature_scale = 1
		else
			temperature_scale = (temperature-PLASMA_MINIMUM_BURN_TEMPERATURE)/(PLASMA_UPPER_TEMPERATURE-PLASMA_MINIMUM_BURN_TEMPERATURE)
		if(temperature_scale > 0)
			oxygen_burn_rate = OXYGEN_BURN_RATE_BASE - temperature_scale
			if(procgases[GAS_O2][MOLES] > procgases[GAS_PL][MOLES]*PLASMA_OXYGEN_FULLBURN)
				plasma_burn_rate = (procgases[GAS_PL][MOLES]*temperature_scale)/PLASMA_BURN_RATE_DELTA
			else
				plasma_burn_rate = (temperature_scale*(procgases[GAS_O2][MOLES]/PLASMA_OXYGEN_FULLBURN))/PLASMA_BURN_RATE_DELTA
			if(plasma_burn_rate > MINIMUM_HEAT_CAPACITY)
				procgases[GAS_PL][MOLES] -= plasma_burn_rate
				procgases[GAS_O2][MOLES] -= plasma_burn_rate*oxygen_burn_rate
				procgases[GAS_CO2][MOLES] += plasma_burn_rate

				energy_released += FIRE_PLASMA_ENERGY_RELEASED * (plasma_burn_rate)

				fuel_burnt += (plasma_burn_rate)*(1+oxygen_burn_rate)

	if(energy_released > 0)
		var/new_heat_capacity = heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			temperature = (temperature*old_heat_capacity + energy_released)/new_heat_capacity

	return fuel_burnt

/datum/gas_mixture/proc/archive()
	//Update archived versions of variables
	//Returns: 1 in all cases

/datum/gas_mixture/proc/merge(datum/gas_mixture/giver)
	//Merges all air from giver into self. Deletes giver.
	//Returns: 1 on success (no failure cases yet)

/datum/gas_mixture/proc/remove(amount)
	//Proportionally removes amount of gas from the gas_mixture
	//Returns: gas_mixture with the gases removed

/datum/gas_mixture/proc/remove_ratio(ratio)
	//Proportionally removes amount of gas from the gas_mixture
	//Returns: gas_mixture with the gases removed

/datum/gas_mixture/proc/copy_from(datum/gas_mixture/sample)
	//Copies variables from sample

/datum/gas_mixture/proc/share(datum/gas_mixture/sharer)
	//Performs air sharing calculations between two gas_mixtures assuming only 1 boundary length
	//Return: amount of gas exchanged (+ if sharer received)
/datum/gas_mixture/proc/mimic(turf/model)
	//Similar to share(...), except the model is not modified
	//Return: amount of gas exchanged

/datum/gas_mixture/proc/check_turf(turf/model)
	//Returns: 0 if self-check failed or 1 if check passes

/datum/gas_mixture/proc/temperature_mimic(turf/model, conduction_coefficient) //I want this proc to die a painful death

/datum/gas_mixture/proc/temperature_share(datum/gas_mixture/sharer, conduction_coefficient)

/datum/gas_mixture/proc/temperature_turf_share(turf/simulated/sharer, conduction_coefficient)

/datum/gas_mixture/proc/compare(datum/gas_mixture/sample)
	//Compares sample to self to see if within acceptable ranges that group processing may be enabled

/datum/gas_mixture/proc/copy_from_turf(turf/model)
	//Copies all gas info from the turf into the gas list along with copying temperature, then archives

/datum/gas_mixture/archive()
	for(var/gas in gases)
		gas[ARCHIVE] = gas[MOLES]
	temperature_archived = temperature
	. = 1

/datum/gas_mixture/merge(datum/gas_mixture/giver)
	if(!giver)
		return 0

	if(abs(temperature-giver.temperature)>MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER)
		var/self_heat_capacity = heat_capacity()
		var/giver_heat_capacity = giver.heat_capacity()
		var/combined_heat_capacity = giver_heat_capacity + self_heat_capacity
		if(combined_heat_capacity != 0)
			temperature = (giver.temperature*giver_heat_capacity + temperature*self_heat_capacity)/combined_heat_capacity
	var/list/giver_gases = giver.gases //accessing datum vars is slower than proc vars
	for(var/gas in gases)
		gas[MOLES] += giver_gases[gas[GAS_INDEX]][MOLES]

	. = 1

/datum/gas_mixture/remove(amount)

	var/sum = total_moles()
	amount = min(amount,sum) //Can not take more air than tile has!
	if(amount <= 0)
		return null

	var/datum/gas_mixture/removed = new
	var/list/removed_gases = removed.gases //accessing datum vars is slower than proc vars

	for(var/gas in gases)
		removed_gases[gas[GAS_INDEX]][MOLES] = QUANTIZE((gas[MOLES]/sum)*amount)
		gas[MOLES] -= removed_gases[gas[GAS_INDEX]][MOLES]

	removed.temperature = temperature

	. = removed

/datum/gas_mixture/remove_ratio(ratio)

	if(ratio <= 0)
		return null

	ratio = min(ratio, 1)

	var/datum/gas_mixture/removed = new
	var/list/removed_gases = removed.gases //accessing datum vars is slower than proc vars
	for(var/gas in gases)
		removed_gases[gas[GAS_INDEX]][MOLES] = QUANTIZE(gas[MOLES]*ratio)
		gas[MOLES] -= removed_gases[gas[GAS_INDEX]][MOLES]

	removed.temperature = temperature

	. = removed

/datum/gas_mixture/copy_from(datum/gas_mixture/sample)
	var/list/sample_gases = sample.gases //accessing datum vars is slower than proc vars
	for(var/gas in gases)
		gas[MOLES] = sample_gases[gas[GAS_INDEX]][MOLES]
	temperature = sample.temperature

	return 1

/datum/gas_mixture/check_turf(turf/model, atmos_adjacent_turfs = 4)
	var/datum/gas_mixture/copied = new
	copied.copy_from_turf(model)
	. = compare(copied, datatype = ARCHIVE, adjacents = atmos_adjacent_turfs)

/datum/gas_mixture/share(datum/gas_mixture/sharer, atmos_adjacent_turfs = 4)
	. = 0
	if(!sharer)
		return

	var/moved_moles = 0
	var/abs_moved_moles = 0
	//make this local to the proc for sanic speed
	var/list/sharercache = sharer.gases

	var/delta_temperature = (temperature_archived - sharer.temperature_archived)

	var/old_self_heat_capacity = 0
	var/old_sharer_heat_capacity = 0

	if(abs(delta_temperature) > MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER)
		old_self_heat_capacity = heat_capacity()
		old_sharer_heat_capacity = sharer.heat_capacity()

	var/heat_capacity_self_to_sharer = 0
	var/heat_capacity_sharer_to_self = 0
	for(var/gas in gases)
		var/sharergas = sharercache[gas[GAS_INDEX]]
		var/delta = QUANTIZE(gas[ARCHIVE] - sharergas[ARCHIVE])/(atmos_adjacent_turfs+1)

		if(delta && abs(delta_temperature) > MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER)
			var/gas_heat_capacity = abs(gas[MOLES] * gas[SPECIFIC_HEAT])
			if(delta > 0)
				heat_capacity_self_to_sharer += gas_heat_capacity
			else
				heat_capacity_sharer_to_self += gas_heat_capacity
		gas[MOLES] -= delta
		sharergas[MOLES] += delta
		moved_moles += delta
		abs_moved_moles += abs(delta)

	last_share = abs_moved_moles
	if(abs(delta_temperature) > MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER)
		var/new_self_heat_capacity = old_self_heat_capacity + heat_capacity_sharer_to_self - heat_capacity_self_to_sharer
		var/new_sharer_heat_capacity = old_sharer_heat_capacity + heat_capacity_self_to_sharer - heat_capacity_sharer_to_self

		if(new_self_heat_capacity > MINIMUM_HEAT_CAPACITY)
			temperature = (old_self_heat_capacity*temperature - heat_capacity_self_to_sharer*temperature_archived + heat_capacity_sharer_to_self*sharer.temperature_archived)/new_self_heat_capacity

		if(new_sharer_heat_capacity > MINIMUM_HEAT_CAPACITY)
			sharer.temperature = (old_sharer_heat_capacity*sharer.temperature-heat_capacity_sharer_to_self*sharer.temperature_archived + heat_capacity_self_to_sharer*temperature_archived)/new_sharer_heat_capacity

			if(abs(old_sharer_heat_capacity) > MINIMUM_HEAT_CAPACITY)
				if(abs(new_sharer_heat_capacity/old_sharer_heat_capacity - 1) < 0.10) // <10% change in sharer heat capacity
					temperature_share(sharer, OPEN_HEAT_TRANSFER_COEFFICIENT)

	if((delta_temperature > MINIMUM_TEMPERATURE_TO_MOVE) || abs(moved_moles) > MINIMUM_MOLES_DELTA_TO_MOVE)
		var/delta_pressure = temperature_archived*(total_moles() + moved_moles) - sharer.temperature_archived*(sharer.total_moles() - moved_moles)
		. = delta_pressure*R_IDEAL_GAS_EQUATION/volume

/datum/gas_mixture/mimic(turf/model, atmos_adjacent_turfs = 4)
	var/datum/gas_mixture/copied = new
	copied.copy_from_turf(model)
	. = share(copied, atmos_adjacent_turfs)

/datum/gas_mixture/temperature_share(datum/gas_mixture/sharer, conduction_coefficient)

	var/delta_temperature = (temperature_archived - sharer.temperature_archived)
	if(abs(delta_temperature) > MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER)
		var/self_heat_capacity = heat_capacity_archived()
		var/sharer_heat_capacity = sharer.heat_capacity_archived()

		if((sharer_heat_capacity > MINIMUM_HEAT_CAPACITY) && (self_heat_capacity > MINIMUM_HEAT_CAPACITY))
			var/heat = conduction_coefficient*delta_temperature* \
				(self_heat_capacity*sharer_heat_capacity/(self_heat_capacity+sharer_heat_capacity))

			temperature -= heat/self_heat_capacity
			sharer.temperature += heat/sharer_heat_capacity

/datum/gas_mixture/temperature_mimic(turf/model, conduction_coefficient)
	var/delta_temperature = (temperature - model.temperature)
	if(abs(delta_temperature) > MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER)
		var/self_heat_capacity = heat_capacity()

		if((model.heat_capacity > MINIMUM_HEAT_CAPACITY) && (self_heat_capacity > MINIMUM_HEAT_CAPACITY))
			var/heat = conduction_coefficient*delta_temperature* \
				(self_heat_capacity*model.heat_capacity/(self_heat_capacity+model.heat_capacity))

			temperature -= heat/self_heat_capacity

/datum/gas_mixture/temperature_turf_share(turf/simulated/sharer, conduction_coefficient)
	var/delta_temperature = (temperature_archived - sharer.temperature)
	if(abs(delta_temperature) > MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER)
		var/self_heat_capacity = heat_capacity()

		if((sharer.heat_capacity > MINIMUM_HEAT_CAPACITY) && (self_heat_capacity > MINIMUM_HEAT_CAPACITY))
			var/heat = conduction_coefficient*delta_temperature* \
				(self_heat_capacity*sharer.heat_capacity/(self_heat_capacity+sharer.heat_capacity))

			temperature -= heat/self_heat_capacity
			sharer.temperature += heat/sharer.heat_capacity

/datum/gas_mixture/compare(datum/gas_mixture/sample, datatype = MOLES, adjacents = 0)
	. = 0
	var/list/sample_gases = sample.gases //accessing datum vars is slower than proc vars
	for(var/gas in gases)
		var/delta = abs(gas[datatype] - sample_gases[gas[GAS_INDEX]][datatype])/(adjacents+1)
		if(delta > MINIMUM_AIR_TO_SUSPEND && \
			delta > gas[datatype]*MINIMUM_AIR_RATIO_TO_SUSPEND)
			return

	if(total_moles() > MINIMUM_AIR_TO_SUSPEND)
		var/temp
		var/sample_temp
		switch(datatype)
			if(MOLES)
				temp = temperature
				sample_temp = sample.temperature
			if(ARCHIVE)
				temp = temperature_archived
				sample_temp = sample.temperature_archived
		var/delta_temperature = abs(temp-sample_temp)
		if((delta_temperature > MINIMUM_TEMPERATURE_DELTA_TO_SUSPEND) && \
			delta_temperature > MINIMUM_TEMPERATURE_DELTA_TO_SUSPEND*temp)
			return
	. = 1


/datum/gas_mixture/copy_from_turf(turf/model)
	gases[GAS_O2][MOLES] = model.oxygen
	gases[GAS_N2][MOLES] = model.nitrogen
	gases[GAS_PL][MOLES] = model.toxins
	gases[GAS_CO2][MOLES] = model.carbon_dioxide
	for(var/i in 5 to gases.len)
		gases[i][MOLES] = 0 //turfs don't account for anything other than the four old hardcoded gases
	temperature = model.temperature

//Takes the amount of the gas you want to PP as an argument
//So I don't have to do some hacky switches/defines/magic strings

//eg:
//Tox_PP = get_partial_pressure(gas_mixture.toxins)
//O2_PP = get_partial_pressure(gas_mixture.oxygen)

//Does handle trace gases!

/datum/gas_mixture/proc/get_breath_partial_pressure(gas_pressure)
	return (gas_pressure*R_IDEAL_GAS_EQUATION*temperature)/BREATH_VOLUME


//Reverse of the above
/datum/gas_mixture/proc/get_true_breath_pressure(breath_pp)
	return (breath_pp*BREATH_VOLUME)/(R_IDEAL_GAS_EQUATION*temperature)

//Mathematical proofs:
/*

get_breath_partial_pressure(gas_pp) --> gas_pp/total_moles()*breath_pp = pp
get_true_breath_pressure(pp) --> gas_pp = pp/breath_pp*total_moles()

10/20*5 = 2.5
10 = 2.5/5*20

*/
