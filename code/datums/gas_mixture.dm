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

var/list/gas_heats = list( //this is actually the list that decides what gases exist and in what order
	20, //GAS_O2
	20, //GAS_N2
	30, //GAS_C02
	200,//GAS_PLASMA
	40, //GAS_N20
	300,//GAS_AGENT_B
	30, //GAS_V_FUEL
)

/proc/gaseslist()
	. = new /list
	for(var/specific_heat in gas_heats)
		. += gaslist(specific_heat)

/proc/gaslist(specific_heat)
	. = new /list
	. += 0				//MOLES
	. += 0				//ARCHIVE
	. += specific_heat	//SPECIFIC_HEAT


/datum/gas_mixture
	/*
	var/oxygen = 0
	var/carbon_dioxide = 0
	var/nitrogen = 0
	var/toxins = 0
	*/
	var/volume = CELL_VOLUME

	var/temperature = 0 //in Kelvin

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

	var/tmp/fuel_burnt = 0

/datum/gas_mixture/New(volume = CELL_VOLUME)
	src.volume = volume
	gases = gaseslist()

	//PV=nRT - related procedures
/datum/gas_mixture/proc/heat_capacity()
	for(var/gas in gases)
		. += gas[MOLES]*gas[SPECIFIC_HEAT]
	/*
	var/heat_capacity = HEAT_CAPACITY_CALCULATION(oxygen,carbon_dioxide,nitrogen,toxins)

	for(var/gas in trace_gases)
		var/datum/gas/trace_gas = gas
		heat_capacity += trace_gas.moles*trace_gas.specific_heat
	return heat_capacity
	*/

/datum/gas_mixture/proc/heat_capacity_archived()
	for(var/gas in gases)
		. += gas[ARCHIVE]*gas[SPECIFIC_HEAT]
	/*
	var/heat_capacity_archived = HEAT_CAPACITY_CALCULATION(oxygen_archived,carbon_dioxide_archived,nitrogen_archived,toxins_archived)

	for(var/gas in trace_gases)
		var/datum/gas/trace_gas = gas
		heat_capacity_archived += trace_gas.moles_archived*trace_gas.specific_heat
	return heat_capacity_archived
	*/

/datum/gas_mixture/proc/total_moles()
	for(var/gas in gases)
		. += gas[MOLES]
	/*
	var/moles = oxygen + carbon_dioxide + nitrogen + toxins

	for(var/gas in trace_gases)
		var/datum/gas/trace_gas = gas
		moles += trace_gas.moles
	return moles
	*/


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
	var/reacting = 0 //set to 1 if a notable reaction occured (used by pipe_network)
	if(temperature < TCMB)
		temperature = TCMB
	if(temperature > 900)
		if(gases[GAS_PL][MOLES] > MINIMUM_HEAT_CAPACITY && gases[GAS_CO2][MOLES] > MINIMUM_HEAT_CAPACITY)
			if(gases[GAS_AGENT_B][MOLES])
				var/reaction_rate = min(gases[GAS_CO2][MOLES]*0.75, gases[GAS_PL][MOLES]*0.25, gases[GAS_AGENT_B][MOLES]*0.05)
				gases[GAS_CO2][MOLES] -= reaction_rate
				gases[GAS_O2][MOLES] += reaction_rate

				gases[GAS_AGENT_B][MOLES] -= reaction_rate*0.05

				temperature -= (reaction_rate*20000)/heat_capacity()

				reacting = 1
	if(thermal_energy() > (PLASMA_BINDING_ENERGY*10))
		if(gases[GAS_PL][MOLES] > MINIMUM_HEAT_CAPACITY && gases[GAS_CO2][MOLES] > MINIMUM_HEAT_CAPACITY && (gases[GAS_PL][MOLES]+gases[GAS_CO2][MOLES])/total_moles() >= FUSION_PURITY_THRESHOLD)//Fusion wont occur if the level of impurities is too high.
			//world << "pre [temperature, [toxins], [carbon_dioxide]
			var/old_heat_capacity = heat_capacity()
			var/carbon_efficency = min(gases[GAS_PL][MOLES]/gases[GAS_CO2][MOLES],MAX_CARBON_EFFICENCY)
			var/reaction_energy = thermal_energy()
			var/moles_impurities = total_moles()-(gases[GAS_PL][MOLES]+gases[GAS_CO2][MOLES])
			var/plasma_fused = (PLASMA_FUSED_COEFFICENT*carbon_efficency)*(temperature/PLASMA_BINDING_ENERGY)
			var/carbon_catalyzed = (CARBON_CATALYST_COEFFICENT*carbon_efficency)*(temperature/PLASMA_BINDING_ENERGY)
			var/oxygen_added = carbon_catalyzed
			var/nitrogen_added = (plasma_fused-oxygen_added)-(thermal_energy()/PLASMA_BINDING_ENERGY)

			reaction_energy = max(reaction_energy+((carbon_efficency*gases[GAS_PL][MOLES])/((moles_impurities/carbon_efficency)+2)*10)+((plasma_fused/(moles_impurities/carbon_efficency))*PLASMA_BINDING_ENERGY),0)
			gases[GAS_PL][MOLES] = max(gases[GAS_PL][MOLES]-plasma_fused,0)
			gases[GAS_CO2][MOLES] = max(gases[GAS_CO2][MOLES]-carbon_catalyzed,0)
			gases[GAS_O2][MOLES] = max(gases[GAS_O2][MOLES]+oxygen_added,0)
			gases[GAS_N2][MOLES] = max(gases[GAS_N2][MOLES]+nitrogen_added,0)
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

	if(gases[GAS_V_FUEL][MOLES]) //General volatile gas burn
		var/burned_fuel = 0

		if(gases[GAS_O2][MOLES] < gases[GAS_V_FUEL][MOLES])
			burned_fuel = gases[GAS_O2][MOLES]
			gases[GAS_V_FUEL][MOLES] -= burned_fuel
			gases[GAS_O2][MOLES] = 0
		else
			burned_fuel = gases[GAS_V_FUEL][MOLES]
			gases[GAS_O2][MOLES] -= gases[GAS_V_FUEL][MOLES]

		energy_released += FIRE_CARBON_ENERGY_RELEASED * burned_fuel
		gases[GAS_CO2][MOLES] += burned_fuel
		fuel_burnt += burned_fuel

	//Handle plasma burning
	if(gases[GAS_PL][MOLES] > MINIMUM_HEAT_CAPACITY)
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
			if(gases[GAS_O2][MOLES] > gases[GAS_PL][MOLES]*PLASMA_OXYGEN_FULLBURN)
				plasma_burn_rate = (gases[GAS_PL][MOLES]*temperature_scale)/PLASMA_BURN_RATE_DELTA
			else
				plasma_burn_rate = (temperature_scale*(gases[GAS_O2][MOLES]/PLASMA_OXYGEN_FULLBURN))/PLASMA_BURN_RATE_DELTA
			if(plasma_burn_rate > MINIMUM_HEAT_CAPACITY)
				gases[GAS_PL][MOLES] -= plasma_burn_rate
				gases[GAS_O2][MOLES] -= plasma_burn_rate*oxygen_burn_rate
				gases[GAS_CO2][MOLES] += plasma_burn_rate

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

//datum/gas_mixture/proc/temperature_mimic(turf/model, conduction_coefficient) //I want this proc to die a painful death

/datum/gas_mixture/proc/temperature_share(datum/gas_mixture/sharer, conduction_coefficient)

/datum/gas_mixture/proc/temperature_turf_share(turf/simulated/sharer, conduction_coefficient)

/datum/gas_mixture/proc/compare(datum/gas_mixture/sample)
	//Compares sample to self to see if within acceptable ranges that group processing may be enabled

/datum/gas_mixture/proc/copy_from_turf(turf/model)
	//Copies all gas info from the turf into the gas list along with copying temperature, then archives

/datum/gas_mixture/archive()
	/*
	oxygen_archived = gases[GAS_02][MOLES]
	carbon_dioxide_archived = carbon_dioxide
	nitrogen_archived =  nitrogen
	toxins_archived = toxins

	for(var/gas in trace_gases)
		var/datum/gas/trace_gas = gas
		trace_gas.moles_archived = trace_gas.moles
	*/
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
	/*
	gases[GAS_02][MOLES] += giver.gases[GAS_02][MOLES]
	carbon_dioxide += giver.carbon_dioxide
	nitrogen += giver.nitrogen
	toxins += giver.toxins

	for(var/gas in giver.trace_gases)
		var/datum/gas/trace_gas = gas
		var/datum/gas/corresponding = locate(trace_gas.type) in trace_gases
		if(!corresponding)
			corresponding = new trace_gas.type()
			trace_gases += corresponding
		corresponding.moles += trace_gas.moles
	*/
	for(var/i in 1 to gases.len)
		gases[i][MOLES] += giver.gases[i][MOLES]

	. = 1

/datum/gas_mixture/remove(amount)

	var/sum = total_moles()
	amount = min(amount,sum) //Can not take more air than tile has!
	if(amount <= 0)
		return null

	var/datum/gas_mixture/removed = new
	/*
	removed.gases[GAS_02][MOLES] = QUANTIZE((gases[GAS_02][MOLES]/sum)*amount)
	removed.nitrogen = QUANTIZE((nitrogen/sum)*amount)
	removed.carbon_dioxide = QUANTIZE((carbon_dioxide/sum)*amount)
	removed.toxins = QUANTIZE((toxins/sum)*amount)

	gases[GAS_02][MOLES] -= removed.gases[GAS_02][MOLES]
	nitrogen -= removed.nitrogen
	carbon_dioxide -= removed.carbon_dioxide
	toxins -= removed.toxins

	for(var/gas in trace_gases)
		var/datum/gas/trace_gas = gas
		var/datum/gas/corresponding = new trace_gas.type()
		removed.trace_gases += corresponding

		corresponding.moles = (trace_gas.moles/sum)*amount
		trace_gas.moles -= corresponding.moles
	*/

	for(var/i in 1 to gases.len)
		removed.gases[i][MOLES] = QUANTIZE((gases[i][MOLES]/sum)*amount)
		gases[i][MOLES] -= removed.gases[i][MOLES]

	removed.temperature = temperature

	. = removed

/datum/gas_mixture/remove_ratio(ratio)

	if(ratio <= 0)
		return null

	ratio = min(ratio, 1)

	var/datum/gas_mixture/removed = new
	/*
	removed.gases[GAS_02][MOLES] = QUANTIZE(gases[GAS_02][MOLES]*ratio)
	removed.nitrogen = QUANTIZE(nitrogen*ratio)
	removed.carbon_dioxide = QUANTIZE(carbon_dioxide*ratio)
	removed.toxins = QUANTIZE(toxins*ratio)

	gases[GAS_02][MOLES] -= removed.gases[GAS_02][MOLES]
	nitrogen -= removed.nitrogen
	carbon_dioxide -= removed.carbon_dioxide
	toxins -= removed.toxins

	for(var/gas in trace_gases)
		var/datum/gas/trace_gas = gas
		var/datum/gas/corresponding = new trace_gas.type()
		removed.trace_gases += corresponding

		corresponding.moles = trace_gas.moles*ratio
		trace_gas.moles -= corresponding.moles
	*/
	for(var/i in 1 to gases.len)
		removed.gases[i][MOLES] = QUANTIZE(gases[i][MOLES]*ratio)
		gases[i][MOLES] -= removed.gases[i][MOLES]

	removed.temperature = temperature

	. = removed

/datum/gas_mixture/copy_from(datum/gas_mixture/sample)
	/*
	gases[GAS_02][MOLES] = sample.gases[GAS_02][MOLES]
	carbon_dioxide = sample.carbon_dioxide
	nitrogen = sample.nitrogen
	toxins = sample.toxins

	trace_gases.len=null
	for(var/gas in sample.trace_gases)
		var/datum/gas/trace_gas = gas
		var/datum/gas/corresponding = new trace_gas.type()
		trace_gases += corresponding

		corresponding.moles = trace_gas.moles
	*/
	for(var/i in 1 to gases.len)
		gases[i][MOLES] = sample.gases[i][MOLES]
	temperature = sample.temperature

	return 1

/datum/gas_mixture/check_turf(turf/model, atmos_adjacent_turfs = 4)
	var/datum/gas_mixture/copied = new
	copied.copy_from_turf(model)
	. = compare(copied, datatype = ARCHIVE, adjacents = atmos_adjacent_turfs)
	/*
	var/delta_oxygen = (oxygen_archived - model.oxygen)/(atmos_adjacent_turfs+1)
	var/delta_carbon_dioxide = (carbon_dioxide_archived - model.carbon_dioxide)/(atmos_adjacent_turfs+1)
	var/delta_nitrogen = (nitrogen_archived - model.nitrogen)/(atmos_adjacent_turfs+1)
	var/delta_toxins = (toxins_archived - model.toxins)/(atmos_adjacent_turfs+1)

	var/delta_temperature = (temperature_archived - model.temperature)

	if(((abs(delta_oxygen) > MINIMUM_AIR_TO_SUSPEND) && (abs(delta_oxygen) >= oxygen_archived*MINIMUM_AIR_RATIO_TO_SUSPEND)) \
		|| ((abs(delta_carbon_dioxide) > MINIMUM_AIR_TO_SUSPEND) && (abs(delta_carbon_dioxide) >= carbon_dioxide_archived*MINIMUM_AIR_RATIO_TO_SUSPEND)) \
		|| ((abs(delta_nitrogen) > MINIMUM_AIR_TO_SUSPEND) && (abs(delta_nitrogen) >= nitrogen_archived*MINIMUM_AIR_RATIO_TO_SUSPEND)) \
		|| ((abs(delta_toxins) > MINIMUM_AIR_TO_SUSPEND) && (abs(delta_toxins) >= toxins_archived*MINIMUM_AIR_RATIO_TO_SUSPEND)))
		return 0
	if(abs(delta_temperature) > MINIMUM_TEMPERATURE_DELTA_TO_SUSPEND)
		return 0

	for(var/gas in trace_gases)
		var/datum/gas/trace_gas = gas
		if(trace_gas.moles_archived > MINIMUM_AIR_TO_SUSPEND*4)
			return 0

	return 1
	*/

/datum/gas_mixture/share(datum/gas_mixture/sharer, atmos_adjacent_turfs = 4)
	. = 0
	if(!sharer)
		return
	var/list/deltas = new
	for(var/i in 1 to gases.len)
		deltas += QUANTIZE(gases[i][ARCHIVE] - sharer.gases[i][ARCHIVE])/(atmos_adjacent_turfs+1)
	/*
	var/delta_oxygen = QUANTIZE(oxygen_archived - sharer.oxygen_archived)/(atmos_adjacent_turfs+1)
	var/delta_carbon_dioxide = QUANTIZE(carbon_dioxide_archived - sharer.carbon_dioxide_archived)/(atmos_adjacent_turfs+1)
	var/delta_nitrogen = QUANTIZE(nitrogen_archived - sharer.nitrogen_archived)/(atmos_adjacent_turfs+1)
	var/delta_toxins = QUANTIZE(toxins_archived - sharer.toxins_archived)/(atmos_adjacent_turfs+1)
	*/
	var/delta_temperature = (temperature_archived - sharer.temperature_archived)

	var/old_self_heat_capacity = 0
	var/old_sharer_heat_capacity = 0

	var/heat_capacity_self_to_sharer = 0
	var/heat_capacity_sharer_to_self = 0

	if(abs(delta_temperature) > MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER)
		for(var/i in 1 to gases.len)
			if(deltas[i])
				var/gas_heat_capacity = abs(gases[i][SPECIFIC_HEAT] * deltas[i])
				if(deltas[i] > 0)
					heat_capacity_self_to_sharer += gas_heat_capacity
				else
					heat_capacity_sharer_to_self += gas_heat_capacity
		/*
		var/delta_air = delta_oxygen+delta_nitrogen
		if(delta_air)
			var/air_heat_capacity = SPECIFIC_HEAT_AIR*delta_air
			if(delta_air > 0)
				heat_capacity_self_to_sharer += air_heat_capacity
			else
				heat_capacity_sharer_to_self -= air_heat_capacity

		if(delta_carbon_dioxide)
			var/carbon_dioxide_heat_capacity = SPECIFIC_HEAT_CDO*delta_carbon_dioxide
			if(delta_carbon_dioxide > 0)
				heat_capacity_self_to_sharer += carbon_dioxide_heat_capacity
			else
				heat_capacity_sharer_to_self -= carbon_dioxide_heat_capacity

		if(delta_toxins)
			var/toxins_heat_capacity = SPECIFIC_HEAT_TOXIN*delta_toxins
			if(delta_toxins > 0)
				heat_capacity_self_to_sharer += toxins_heat_capacity
			else
				heat_capacity_sharer_to_self -= toxins_heat_capacity
		*/
		old_self_heat_capacity = heat_capacity()
		old_sharer_heat_capacity = sharer.heat_capacity()

	for(var/i in 1 to gases.len)
		gases[i][MOLES] -= deltas[i]
		sharer.gases[i][MOLES] += deltas[i]
	/*
	oxygen -= delta_oxygen
	sharer.oxygen += delta_oxygen

	carbon_dioxide -= delta_carbon_dioxide
	sharer.carbon_dioxide += delta_carbon_dioxide

	nitrogen -= delta_nitrogen
	sharer.nitrogen += delta_nitrogen

	toxins -= delta_toxins
	sharer.toxins += delta_toxins
	*/
	var/moved_moles = 0
	for(var/delta in deltas)
		moved_moles += delta
		last_share += abs(delta)
	/*
	var/list/trace_types_considered = list()

	for(var/gas in trace_gases)
		var/datum/gas/trace_gas = gas
		var/datum/gas/corresponding = locate(trace_gas.type) in sharer.trace_gases
		var/delta = 0

		if(corresponding)
			delta = QUANTIZE(trace_gas.moles_archived - corresponding.moles_archived)/(atmos_adjacent_turfs+1)
		else
			corresponding = new trace_gas.type()
			sharer.trace_gases += corresponding

			delta = trace_gas.moles_archived/(atmos_adjacent_turfs+1)

		trace_gas.moles -= delta
		corresponding.moles += delta

		if(delta)
			var/individual_heat_capacity = trace_gas.specific_heat*delta
			if(delta > 0)
				heat_capacity_self_to_sharer += individual_heat_capacity
			else
				heat_capacity_sharer_to_self -= individual_heat_capacity

		moved_moles += delta
		last_share += abs(delta)

		trace_types_considered += trace_gas.type

	for(var/datum/gas/trace_gas in sharer.trace_gases)
		if(trace_gas.type in trace_types_considered)
			continue
		var/datum/gas/corresponding
		var/delta = 0
		corresponding = new trace_gas.type()
		trace_gases += corresponding

		delta = trace_gas.moles_archived/5

		trace_gas.moles -= delta
		corresponding.moles += delta

		//Guaranteed transfer from sharer to self
		var/individual_heat_capacity = trace_gas.specific_heat*delta
		heat_capacity_sharer_to_self += individual_heat_capacity

		moved_moles += -delta
		last_share += abs(delta)
	*/
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
		return delta_pressure*R_IDEAL_GAS_EQUATION/volume

/datum/gas_mixture/mimic(turf/model, atmos_adjacent_turfs = 4)
	var/datum/gas_mixture/copied = new
	copied.copy_from_turf(model)
	. = share(copied, atmos_adjacent_turfs)
	/*
	var/delta_oxygen = QUANTIZE(oxygen_archived - model.oxygen)/(atmos_adjacent_turfs+1)
	var/delta_carbon_dioxide = QUANTIZE(carbon_dioxide_archived - model.carbon_dioxide)/(atmos_adjacent_turfs+1)
	var/delta_nitrogen = QUANTIZE(nitrogen_archived - model.nitrogen)/(atmos_adjacent_turfs+1)
	var/delta_toxins = QUANTIZE(toxins_archived - model.toxins)/(atmos_adjacent_turfs+1)

	var/delta_temperature = (temperature_archived - model.temperature)

	var/heat_transferred = 0
	var/old_self_heat_capacity = 0
	var/heat_capacity_transferred = 0

	if(abs(delta_temperature) > MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER)

		var/delta_air = delta_oxygen+delta_nitrogen
		if(delta_air)
			var/air_heat_capacity = SPECIFIC_HEAT_AIR*delta_air
			heat_transferred -= air_heat_capacity*model.temperature
			heat_capacity_transferred -= air_heat_capacity

		if(delta_carbon_dioxide)
			var/carbon_dioxide_heat_capacity = SPECIFIC_HEAT_CDO*delta_carbon_dioxide
			heat_transferred -= carbon_dioxide_heat_capacity*model.temperature
			heat_capacity_transferred -= carbon_dioxide_heat_capacity

		if(delta_toxins)
			var/toxins_heat_capacity = SPECIFIC_HEAT_TOXIN*delta_toxins
			heat_transferred -= toxins_heat_capacity*model.temperature
			heat_capacity_transferred -= toxins_heat_capacity

		old_self_heat_capacity = heat_capacity()

	oxygen -= delta_oxygen
	carbon_dioxide -= delta_carbon_dioxide
	nitrogen -= delta_nitrogen
	toxins -= delta_toxins

	var/moved_moles = (delta_oxygen + delta_carbon_dioxide + delta_nitrogen + delta_toxins)
	last_share = abs(delta_oxygen) + abs(delta_carbon_dioxide) + abs(delta_nitrogen) + abs(delta_toxins)

	if(trace_gases.len)
		for(var/datum/gas/trace_gas in trace_gases)
			var/delta = 0

			delta = trace_gas.moles_archived/(atmos_adjacent_turfs+1)

			trace_gas.moles -= delta

			var/heat_cap_transferred = delta*trace_gas.specific_heat
			heat_transferred += heat_cap_transferred*temperature_archived
			heat_capacity_transferred += heat_cap_transferred
			moved_moles += delta
			moved_moles += abs(delta)

	if(abs(delta_temperature) > MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER)
		var/new_self_heat_capacity = old_self_heat_capacity - heat_capacity_transferred
		if(new_self_heat_capacity > MINIMUM_HEAT_CAPACITY)
			temperature = (old_self_heat_capacity*temperature - heat_capacity_transferred*temperature_archived)/new_self_heat_capacity

		temperature_mimic(model, model.thermal_conductivity)

	if((delta_temperature > MINIMUM_TEMPERATURE_TO_MOVE) || abs(moved_moles) > MINIMUM_MOLES_DELTA_TO_MOVE)
		var/delta_pressure = temperature_archived*(total_moles() + moved_moles) - model.temperature*(model.oxygen+model.carbon_dioxide+model.nitrogen+model.toxins)
		return delta_pressure*R_IDEAL_GAS_EQUATION/volume
	else
		return 0
	*/

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
/*
/datum/gas_mixture/temperature_mimic(turf/model, conduction_coefficient)
	var/delta_temperature = (temperature - model.temperature)
	if(abs(delta_temperature) > MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER)
		var/self_heat_capacity = heat_capacity()

		if((model.heat_capacity > MINIMUM_HEAT_CAPACITY) && (self_heat_capacity > MINIMUM_HEAT_CAPACITY))
			var/heat = conduction_coefficient*delta_temperature* \
				(self_heat_capacity*model.heat_capacity/(self_heat_capacity+model.heat_capacity))

			temperature -= heat/self_heat_capacity
*/
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
	for(var/i in 1 to gases.len)
		var/delta = abs(gases[i][datatype] - sample.gases[i][datatype])/(adjacents+1)
		if(delta > MINIMUM_AIR_TO_SUSPEND && \
			delta > gases[i][datatype]*MINIMUM_AIR_RATIO_TO_SUSPEND)
			/*
			(\
				(gases[i][datatype] < (1-MINIMUM_AIR_RATIO_TO_SUSPEND)*sample.gases[i][datatype]) || \
				(gases[i][datatype] > (1+MINIMUM_AIR_RATIO_TO_SUSPEND)*sample.gases[i][datatype])\
			)\
		))*/
			return

	/*
	if((abs(oxygen-sample.oxygen) > MINIMUM_AIR_TO_SUSPEND) && \
		((oxygen < (1-MINIMUM_AIR_RATIO_TO_SUSPEND)*sample.oxygen) || (oxygen > (1+MINIMUM_AIR_RATIO_TO_SUSPEND)*sample.oxygen)))
		return 0
	if((abs(nitrogen-sample.nitrogen) > MINIMUM_AIR_TO_SUSPEND) && \
		((nitrogen < (1-MINIMUM_AIR_RATIO_TO_SUSPEND)*sample.nitrogen) || (nitrogen > (1+MINIMUM_AIR_RATIO_TO_SUSPEND)*sample.nitrogen)))
		return 0
	if((abs(carbon_dioxide-sample.carbon_dioxide) > MINIMUM_AIR_TO_SUSPEND) && \
		((carbon_dioxide < (1-MINIMUM_AIR_RATIO_TO_SUSPEND)*sample.carbon_dioxide) || (oxygen > (1+MINIMUM_AIR_RATIO_TO_SUSPEND)*sample.carbon_dioxide)))
		return 0
	if((abs(toxins-sample.toxins) > MINIMUM_AIR_TO_SUSPEND) && \
		((toxins < (1-MINIMUM_AIR_RATIO_TO_SUSPEND)*sample.toxins) || (toxins > (1+MINIMUM_AIR_RATIO_TO_SUSPEND)*sample.toxins)))
		return 0
	*/

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
	/*
	for(var/gas in sample.trace_gases)
		var/datum/gas/trace_gas = gas
		if(trace_gas.moles_archived > MINIMUM_AIR_TO_SUSPEND)
			var/datum/gas/corresponding = locate(trace_gas.type) in trace_gases
			if(corresponding)
				if((abs(trace_gas.moles - corresponding.moles) > MINIMUM_AIR_TO_SUSPEND) && \
					((corresponding.moles < (1-MINIMUM_AIR_RATIO_TO_SUSPEND)*trace_gas.moles) || (corresponding.moles > (1+MINIMUM_AIR_RATIO_TO_SUSPEND)*trace_gas.moles)))
					return 0
			else
				return 0

	for(var/gas in trace_gases)
		var/datum/gas/trace_gas = gas
		if(trace_gas.moles > MINIMUM_AIR_TO_SUSPEND)
			var/datum/gas/corresponding = locate(trace_gas.type) in sample.trace_gases
			if(corresponding)
				if((abs(trace_gas.moles - corresponding.moles) > MINIMUM_AIR_TO_SUSPEND) && \
					((trace_gas.moles < (1-MINIMUM_AIR_RATIO_TO_SUSPEND)*corresponding.moles) || (trace_gas.moles > (1+MINIMUM_AIR_RATIO_TO_SUSPEND)*corresponding.moles)))
					return 0
			else
				return 0
	*/
	. = 1


/datum/gas_mixture/copy_from_turf(turf/model)
	gases[GAS_O2][MOLES] = model.oxygen
	gases[GAS_N2][MOLES] = model.nitrogen
	gases[GAS_PL][MOLES] = model.toxins
	gases[GAS_CO2][MOLES] = model.carbon_dioxide
	for(var/i in 5 to gases.len)
		gases[i][MOLES] = 0 //turfs don't account for anything other than the four old hardcoded gases
	temperature = model.temperature
/*
/turf/proc/copy_from_gas_mixture(datum/gas_mixture/model)
	oxygen = model.gases[GAS_O2][MOLES]
	nitrogen = model.gases[GAS_N2][MOLES]
	toxins = model.gases[GAS_PL][MOLES]
	carbon_dioxide = model.gases[GAS_CO2][MOLES]
	temperature = model.temperature
*/

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
