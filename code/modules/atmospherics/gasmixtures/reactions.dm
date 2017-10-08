#define NO_REACTION	0
#define REACTING	1

/datum/controller/subsystem/air/var/list/gas_reactions //this is our singleton of all reactions

/proc/init_gas_reactions()
	var/list/reaction_types = list()
	for(var/r in subtypesof(/datum/gas_reaction))
		var/datum/gas_reaction/reaction = r
		if(!initial(reaction.exclude))
			reaction_types += reaction
	reaction_types = sortList(reaction_types, /proc/cmp_gas_reactions)

	. = list()
	for(var/path in reaction_types)
		. += new path

/proc/cmp_gas_reactions(datum/gas_reaction/a, datum/gas_reaction/b) //sorts in descending order of priority
	return initial(b.priority) - initial(a.priority)

/datum/gas_reaction
	//regarding the requirements lists: the minimum or maximum requirements must be non-zero.
	//when in doubt, use MINIMUM_HEAT_CAPACITY.
	var/list/min_requirements
	var/list/max_requirements
	var/exclude = FALSE //do it this way to allow for addition/removal of reactions midmatch in the future
	var/priority = 100 //lower numbers are checked/react later than higher numbers. if two reactions have the same priority they may happen in either order
	var/name = "reaction"
	var/id = "r"

/datum/gas_reaction/New()
	init_reqs()

/datum/gas_reaction/proc/init_reqs()
/datum/gas_reaction/proc/react(datum/gas_mixture/air, atom/location)
	return NO_REACTION



//water vapor: puts out fires?
/datum/gas_reaction/water_vapor
	priority = 1
	name = "Water Vapor"
	id = "vapor"

/datum/gas_reaction/water_vapor/init_reqs()
	min_requirements = list("water_vapor" = MOLES_PLASMA_VISIBLE)

/datum/gas_reaction/water_vapor/react(datum/gas_mixture/air, turf/open/location)
	. = NO_REACTION
	if (air.temperature <= 200)
		if(location && location.freon_gas_act())
			. = REACTING
	else if(location && location.water_vapor_gas_act())
		air.gases["water_vapor"][MOLES] -= MOLES_PLASMA_VISIBLE
		. = REACTING

//fire: combustion of plasma and volatile fuel (treated as hydrocarbons). creates hotspots. exothermic
/datum/gas_reaction/fire
	priority = -1 //fire should ALWAYS be last
	name = "Hydrocarbon Combustion"
	id = "fire"

/datum/gas_reaction/fire/init_reqs()
	min_requirements = list("TEMP" = FIRE_MINIMUM_TEMPERATURE_TO_EXIST) //doesn't include plasma reqs b/c of other, rarer, burning gases.

/datum/gas_reaction/fire/react(datum/gas_mixture/air, turf/open/location)
	var/energy_released = 0
	var/old_heat_capacity = air.heat_capacity()
	var/list/cached_gases = air.gases //this speeds things up because accessing datum vars is slow
	var/temperature = air.temperature
	var/list/cached_results = air.reaction_results
	cached_results[id] = 0

	//General volatile gas burn
	if(cached_gases["tritium"] && cached_gases["tritium"][MOLES])
		var/burned_fuel
		if(!cached_gases["o2"])
			burned_fuel = 0
		else if(cached_gases["o2"][MOLES] < cached_gases["tritium"][MOLES])
			burned_fuel = cached_gases["o2"][MOLES]/2
			cached_gases["tritium"][MOLES] -= burned_fuel
			cached_gases["o2"][MOLES] = 0
		else
			burned_fuel = cached_gases["tritium"][MOLES]*2
			cached_gases["o2"][MOLES] -= cached_gases["tritium"][MOLES]

		if(burned_fuel)
			energy_released += FIRE_CARBON_ENERGY_RELEASED * burned_fuel

			ASSERT_GAS("water_vapor", air)
			cached_gases["water_vapor"][MOLES] += burned_fuel

			cached_results[id] += burned_fuel

	//Handle plasma burning
	if(cached_gases["plasma"] && cached_gases["plasma"][MOLES] > MINIMUM_HEAT_CAPACITY)
		var/plasma_burn_rate = 0
		var/oxygen_burn_rate = 0
		//more plasma released at higher temperatures
		var/temperature_scale
		var/super_saturation
		if(temperature > PLASMA_UPPER_TEMPERATURE)
			temperature_scale = 1
		else
			temperature_scale = (temperature-PLASMA_MINIMUM_BURN_TEMPERATURE)/(PLASMA_UPPER_TEMPERATURE-PLASMA_MINIMUM_BURN_TEMPERATURE)
		if(temperature_scale > 0)
			ASSERT_GAS("o2", air)
			oxygen_burn_rate = OXYGEN_BURN_RATE_BASE - temperature_scale
			if(cached_gases["o2"][MOLES] / cached_gases["plasma"][MOLES] > 90) //supersaturation. Form Tritium.
				super_saturation = TRUE
			else if(cached_gases["o2"][MOLES] > cached_gases["plasma"][MOLES]*PLASMA_OXYGEN_FULLBURN)
				plasma_burn_rate = (cached_gases["plasma"][MOLES]*temperature_scale)/PLASMA_BURN_RATE_DELTA
			else
				plasma_burn_rate = (temperature_scale*(cached_gases["o2"][MOLES]/PLASMA_OXYGEN_FULLBURN))/PLASMA_BURN_RATE_DELTA

			if(plasma_burn_rate > MINIMUM_HEAT_CAPACITY)
				ASSERT_GAS("co2", air)
				cached_gases["plasma"][MOLES] = QUANTIZE(cached_gases["plasma"][MOLES] - plasma_burn_rate)
				cached_gases["o2"][MOLES] = QUANTIZE(cached_gases["o2"][MOLES] - (plasma_burn_rate * oxygen_burn_rate))
				if (super_saturation)
					air.assert_gas("tritium")
					cached_gases["tritium"][MOLES] += plasma_burn_rate
				else
					air.assert_gas("co2")
					cached_gases["co2"][MOLES] += plasma_burn_rate

				energy_released += FIRE_PLASMA_ENERGY_RELEASED * (plasma_burn_rate)

				cached_results[id] += (plasma_burn_rate)*(1+oxygen_burn_rate)

	if(energy_released > 0)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.temperature = (temperature*old_heat_capacity + energy_released)/new_heat_capacity

	//let the floor know a fire is happening
	if(istype(location))
		temperature = air.temperature
		if(temperature > FIRE_MINIMUM_TEMPERATURE_TO_EXIST)
			location.hotspot_expose(temperature, CELL_VOLUME)
			for(var/I in location)
				var/atom/movable/item = I
				item.temperature_expose(air, temperature, CELL_VOLUME)
			location.temperature_expose(air, temperature, CELL_VOLUME)

	return cached_results[id] ? REACTING : NO_REACTION

//fusion: a terrible idea that was fun but broken. Now reworked to be less broken and more interesting.
/datum/gas_reaction/fusion
	exclude = FALSE
	priority = 2
	name = "Plasmic Fusion"
	id = "fusion"

/datum/gas_reaction/fusion/init_reqs()
	min_requirements = list(
		"ENER" = PLASMA_BINDING_ENERGY * 10,
		"plasma" = MINIMUM_HEAT_CAPACITY,
		"tritium" = MINIMUM_HEAT_CAPACITY
	)

/datum/gas_reaction/fusion/react(datum/gas_mixture/air)
	var/list/cached_gases = air.gases
	var/temperature = air.temperature

	if(((cached_gases["plasma"][MOLES]+cached_gases["tritium"][MOLES])/air.total_moles() < FUSION_PURITY_THRESHOLD) || air.return_pressure() < 10*ONE_ATMOSPHERE)
		//Fusion wont occur if the level of impurities is too high or if there is too little pressure.
		return NO_REACTION

	var/old_heat_capacity = air.heat_capacity()
	var/catalyst_efficency = max(min(cached_gases["plasma"][MOLES]/cached_gases["tritium"][MOLES],MAX_CARBON_EFFICENCY)-(temperature/FUSION_HEAT_DROPOFF),0)
	var/reaction_energy = THERMAL_ENERGY(air)
	var/moles_impurities = air.total_moles()-(cached_gases["plasma"][MOLES]+cached_gases["tritium"][MOLES])

	var/plasma_fused = (PLASMA_FUSED_COEFFICENT*catalyst_efficency)*(temperature/PLASMA_BINDING_ENERGY)*4
	var/tritium_catalyzed = (CARBON_CATALYST_COEFFICENT*catalyst_efficency)*(temperature/PLASMA_BINDING_ENERGY)
	var/oxygen_added = tritium_catalyzed
	var/waste_added = (plasma_fused-oxygen_added)-(air.thermal_energy()/PLASMA_BINDING_ENERGY)
	reaction_energy = max(reaction_energy+((catalyst_efficency*cached_gases["plasma"][MOLES])/((moles_impurities/catalyst_efficency)+2)*10)+((plasma_fused/(moles_impurities/catalyst_efficency))*PLASMA_BINDING_ENERGY),0)

	air.assert_gases("o2", "n2","water_vapor","n2o","browns")
	//Fusion produces an absurd amount of waste products now, requiring active filtration.
	cached_gases["plasma"][MOLES] -= plasma_fused
	cached_gases["tritium"][MOLES] -= tritium_catalyzed
	cached_gases["o2"][MOLES] += oxygen_added
	cached_gases["n2"][MOLES] += waste_added
	cached_gases["water_vapor"][MOLES] += waste_added
	cached_gases["n2o"][MOLES] += waste_added
	cached_gases["browns"][MOLES] += waste_added

	if(reaction_energy > 0)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.temperature = max(((temperature*old_heat_capacity + reaction_energy)/new_heat_capacity),TCMB)
			//Prevents whatever mechanism is causing it to hit negative temperatures.
		return REACTING

/datum/gas_reaction/brownsformation //The formation of brown gas. Endothermic.
	priority = 3
	name = "Brown Gas formation"
	id = "brownsformation"

/datum/gas_reaction/brownsformation/init_reqs()
	min_requirements = list(
		"oxygen" = 20,
		"nitrogen" = 20,
		"temp" = FIRE_MINIMUM_TEMPERATURE_TO_EXIST*200
	)

/datum/gas_reaction/brownsformation/react(datum/gas_mixture/air)
	var/list/cached_gases = air.gases
	var/temperature = air.temperature

	var/old_heat_capacity = air.heat_capacity()
	var/heat_efficency = temperature/FIRE_MINIMUM_TEMPERATURE_TO_EXIST*100
	var/energy_used = heat_efficency*BROWNS_FORMATION_ENERGY
	air.assert_gases("oxygen","nitrogen","browns")

	cached_gases["oxygen"][MOLES] -= heat_efficency
	cached_gases["nitrogen"][MOLES] -= heat_efficency
	cached_gases["browns"][MOLES] += heat_efficency*2

	if(energy_used > 0)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.temperature = max(((temperature*old_heat_capacity - energy_used)/new_heat_capacity),TCMB)
		return REACTING

/datum/gas_reaction/bzformation //Formation of BZ by combining plasma and tritium at low pressures. Exothermic.
	priority = 3
	name = "BZ Gas formation"
	id = "bzformation"

/datum/gas_reaction/bzformation/init_reqs()
	min_requirements = list(
		"tritium" = 10,
		"plasma" = 10
	)


/datum/gas_reaction/bzformation/react(datum/gas_mixture/air)
	var/list/cached_gases = air.gases
	var/temperature = air.temperature
	var/pressure = air.return_pressure()

	var/old_heat_capacity = air.heat_capacity()
	var/reaction_efficency = pressure/0.1*ONE_ATMOSPHERE
	var/energy_released = 2*reaction_efficency*FIRE_CARBON_ENERGY_RELEASED


	air.assert_gases("tritium","plasma","BZ")
	cached_gases["bz"][MOLES]+= reaction_efficency
	cached_gases["tritium"][MOLES]-= 2*reaction_efficency
	cached_gases["plasma"][MOLES]-= reaction_efficency


	if(energy_released > 0)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.temperature = max(((temperature*old_heat_capacity + energy_released)/new_heat_capacity),TCMB)
		return REACTING

/datum/gas_reaction/stimformation
	priority = 3
	name = "Stimulum formation"
	id = "stimformation"
/datum/gas_reaction/stimformation/init_reqs()
	min_requirements = list(
		"tritium" = 30,
		"plasma" = 10,
		"bz" = 20,
		"browns" = 30,
		"temp" =50000)

/datum/gas_reaction/stimformation/react(datum/gas_mixture/air)
	var/list/cached_gases = air.gases

	var/old_heat_capacity = air.heat_capacity()
	var/heat_scale = air.temperature/100000
	var/stim_energy_change
	stim_energy_change = (0.75(heat_scale**2)) - (0.05(heat_scale**3)) + (0.001(heat_scale**4)) - (0.0000062(heat_scale**5))

	air.assert_gases("tritium","plasma","bz","browns","stim")
	cached_gases["stim"][MOLES]+= heat_scale/10
	cached_gases["tritium"][MOLES]-= heat_scale
	cached_gases["plasma"][MOLES]-= heat_scale
	cached_gases["browns"][MOLES]-= heat_scale

	if(stim_energy_change)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.temperature = max(((air.temperature*old_heat_capacity + stim_energy_change)/new_heat_capacity),TCMB)
		return REACTING

#undef REACTING
#undef NO_REACTION
