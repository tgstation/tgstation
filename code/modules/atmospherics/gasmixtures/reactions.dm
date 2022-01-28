//All defines used in reactions are located in ..\__DEFINES\reactions.dm

/proc/init_gas_reactions()
	var/list/priority_reactions = list()

	//Builds a list of gas id to reaction group
	for(var/gas_id in GLOB.meta_gas_info)
		priority_reactions[gas_id] = list(
			PRIORITY_PRE_FORMATION = list(),
			PRIORITY_FORMATION = list(),
			PRIORITY_POST_FORMATION = list(),
			PRIORITY_FIRE = list()
		)

	for(var/datum/gas_reaction/reaction as anything in subtypesof(/datum/gas_reaction))
		if(initial(reaction.exclude))
			continue
		reaction = new reaction
		var/datum/gas/reaction_key
		for (var/req in reaction.requirements)
			if (ispath(req))
				var/datum/gas/req_gas = req
				if (!reaction_key || initial(reaction_key.rarity) > initial(req_gas.rarity))
					reaction_key = req_gas
		reaction.major_gas = reaction_key
		priority_reactions[reaction_key][reaction.priority_group] += reaction

	//Culls empty gases
	for(var/gas_id in GLOB.meta_gas_info)
		var/passed = FALSE
		for(var/list/priority_grouping in priority_reactions[gas_id])
			if(length(priority_grouping))
				passed = TRUE
				break
		if(passed)
			continue
		priority_reactions[gas_id] = null

	return priority_reactions

/datum/gas_reaction
	/**
	 * Regarding the requirements list: the minimum or maximum requirements must be non-zero.
	 * When in doubt, use MINIMUM_MOLE_COUNT.
	 * Another thing to note is that reactions will not fire if we have any requirements outside of gas id path or MIN_TEMP or MAX_TEMP.
	 * More complex implementations will require modifications to gas_mixture.react()
	 */
	var/list/requirements
	var/major_gas //the highest rarity gas used in the reaction.
	var/exclude = FALSE //do it this way to allow for addition/removal of reactions midmatch in the future
	///The priority group this reaction is a part of. You can think of these as processing in batches, put your reaction into the one that's most fitting
	var/priority_group
	var/name = "reaction"
	var/id = "r"

/datum/gas_reaction/New()
	init_reqs()

/datum/gas_reaction/proc/init_reqs()

/datum/gas_reaction/proc/react(datum/gas_mixture/air, atom/location)
	return NO_REACTION

//water vapor: puts out fires?
/datum/gas_reaction/water_vapor
	priority_group = PRIORITY_POST_FORMATION
	name = "Water Vapor"
	id = "vapor"

/datum/gas_reaction/water_vapor/init_reqs()
	requirements = list(/datum/gas/water_vapor = MOLES_GAS_VISIBLE)

/datum/gas_reaction/water_vapor/react(datum/gas_mixture/air, datum/holder)
	var/turf/open/location = isturf(holder) ? holder : null
	. = NO_REACTION
	if (air.temperature <= WATER_VAPOR_FREEZE)
		if(location?.freeze_turf())
			. = REACTING
	else if(air.temperature <= T20C + 10)
		if(location?.water_vapor_gas_act())
			air.gases[/datum/gas/water_vapor][MOLES] -= MOLES_GAS_VISIBLE
			. = REACTING

//tritium combustion: combustion of oxygen and tritium (treated as hydrocarbons). creates hotspots. exothermic
/datum/gas_reaction/nitrous_decomp
	priority_group = PRIORITY_POST_FORMATION
	name = "Nitrous Oxide Decomposition"
	id = "nitrous_decomp"

/datum/gas_reaction/nitrous_decomp/init_reqs()
	requirements = list(
		/datum/gas/nitrous_oxide = MINIMUM_MOLE_COUNT,
		"MIN_TEMP" = N2O_DECOMPOSITION_MIN_ENERGY
	)

/datum/gas_reaction/nitrous_decomp/react(datum/gas_mixture/air, datum/holder)
	var/energy_released = 0
	var/old_heat_capacity = air.heat_capacity()
	var/list/cached_gases = air.gases //this speeds things up because accessing datum vars is slow
	var/temperature = air.temperature
	var/burned_fuel = 0


	burned_fuel = max(0,0.00002 * (temperature - (0.00001 * (temperature**2)))) * cached_gases[/datum/gas/nitrous_oxide][MOLES]
	if(cached_gases[/datum/gas/nitrous_oxide][MOLES] - burned_fuel < 0)
		return NO_REACTION
	cached_gases[/datum/gas/nitrous_oxide][MOLES] -= burned_fuel

	if(burned_fuel)
		energy_released += (N2O_DECOMPOSITION_ENERGY_RELEASED * burned_fuel)

		ASSERT_GAS(/datum/gas/oxygen, air)
		cached_gases[/datum/gas/oxygen][MOLES] += burned_fuel * 0.5
		ASSERT_GAS(/datum/gas/nitrogen, air)
		cached_gases[/datum/gas/nitrogen][MOLES] += burned_fuel

		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.temperature = (temperature * old_heat_capacity + energy_released) / new_heat_capacity
		return REACTING
	return NO_REACTION

//tritium combustion: combustion of oxygen and tritium (treated as hydrocarbons). creates hotspots. exothermic
/datum/gas_reaction/tritfire
	priority_group = PRIORITY_FIRE
	name = "Tritium Combustion"
	id = "tritfire"

/datum/gas_reaction/tritfire/init_reqs()
	requirements = list(
		/datum/gas/tritium = MINIMUM_MOLE_COUNT,
		/datum/gas/oxygen = MINIMUM_MOLE_COUNT,
		"MIN_TEMP" = FIRE_MINIMUM_TEMPERATURE_TO_EXIST
	)

/datum/gas_reaction/tritfire/react(datum/gas_mixture/air, datum/holder)
	var/energy_released = 0
	var/old_heat_capacity = air.heat_capacity()
	var/list/cached_gases = air.gases //this speeds things up because accessing datum vars is slow
	var/temperature = air.temperature
	var/list/cached_results = air.reaction_results
	cached_results["fire"] = 0
	var/turf/open/location
	if(istype(holder,/datum/pipeline)) //Find the tile the reaction is occuring on, or a random part of the network if it's a pipenet.
		var/datum/pipeline/pipenet = holder
		location = get_turf(pick(pipenet.members))
	else
		location = get_turf(holder)
	var/burned_fuel = 0

	if(cached_gases[/datum/gas/oxygen][MOLES] < cached_gases[/datum/gas/tritium][MOLES] || MINIMUM_TRIT_OXYBURN_ENERGY > air.thermal_energy())
		burned_fuel = cached_gases[/datum/gas/oxygen][MOLES] / TRITIUM_BURN_OXY_FACTOR
		cached_gases[/datum/gas/tritium][MOLES] -= burned_fuel

		ASSERT_GAS(/datum/gas/water_vapor, air) //oxygen+more-or-less hydrogen=H2O
		cached_gases[/datum/gas/water_vapor][MOLES] += burned_fuel / TRITIUM_BURN_OXY_FACTOR

		energy_released += (FIRE_HYDROGEN_ENERGY_WEAK * burned_fuel)
		cached_results["fire"] += burned_fuel

	else
		burned_fuel = cached_gases[/datum/gas/tritium][MOLES]

		cached_gases[/datum/gas/tritium][MOLES] -= burned_fuel / TRITIUM_BURN_TRIT_FACTOR
		cached_gases[/datum/gas/oxygen][MOLES] -= burned_fuel

		ASSERT_GAS(/datum/gas/water_vapor, air) //oxygen+more-or-less hydrogen=H2O
		cached_gases[/datum/gas/water_vapor][MOLES] += burned_fuel / TRITIUM_BURN_TRIT_FACTOR

		energy_released += (FIRE_HYDROGEN_ENERGY_RELEASED * burned_fuel)
		cached_results["fire"] += burned_fuel * 10

	if(location && prob(10) && burned_fuel > TRITIUM_MINIMUM_RADIATION_ENERGY)
		radiation_pulse(location, max_range = min(sqrt(energy_released / FIRE_HYDROGEN_ENERGY_RELEASED) / 1.5, 20), threshold = 15 * INVERSE(15 + energy_released / FIRE_HYDROGEN_ENERGY_RELEASED), chance = 50)
	if(energy_released > 0)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.temperature = (temperature * old_heat_capacity + energy_released) / new_heat_capacity

	//let the floor know a fire is happening
	if(istype(location))
		temperature = air.temperature
		if(temperature > FIRE_MINIMUM_TEMPERATURE_TO_EXIST)
			location.hotspot_expose(temperature, CELL_VOLUME)

	return cached_results["fire"] ? REACTING : NO_REACTION

//plasma combustion: combustion of oxygen and plasma (treated as hydrocarbons). creates hotspots. exothermic
/datum/gas_reaction/plasmafire
	priority_group = PRIORITY_FIRE
	name = "Plasma Combustion"
	id = "plasmafire"

/datum/gas_reaction/plasmafire/init_reqs()
	requirements = list(
		/datum/gas/plasma = MINIMUM_MOLE_COUNT,
		/datum/gas/oxygen = MINIMUM_MOLE_COUNT,
		"MIN_TEMP" = FIRE_MINIMUM_TEMPERATURE_TO_EXIST
	)

/datum/gas_reaction/plasmafire/react(datum/gas_mixture/air, datum/holder)
	var/energy_released = 0
	var/old_heat_capacity = air.heat_capacity()
	var/list/cached_gases = air.gases //this speeds things up because accessing datum vars is slow
	var/temperature = air.temperature
	var/list/cached_results = air.reaction_results
	cached_results["fire"] = 0
	var/turf/open/location = isturf(holder) ? holder : null

	//Handle plasma burning
	var/plasma_burn_rate = 0
	var/oxygen_burn_rate = 0
	//more plasma released at higher temperatures
	var/temperature_scale = 0
	//to make tritium
	var/super_saturation = FALSE

	if(temperature > PLASMA_UPPER_TEMPERATURE)
		temperature_scale = 1
	else
		temperature_scale = (temperature - PLASMA_MINIMUM_BURN_TEMPERATURE) / (PLASMA_UPPER_TEMPERATURE-PLASMA_MINIMUM_BURN_TEMPERATURE)
	if(temperature_scale > 0)
		oxygen_burn_rate = OXYGEN_BURN_RATE_BASE - temperature_scale
		if(cached_gases[/datum/gas/oxygen][MOLES] / cached_gases[/datum/gas/plasma][MOLES] > SUPER_SATURATION_THRESHOLD) //supersaturation. Form Tritium.
			super_saturation = TRUE
		if(cached_gases[/datum/gas/oxygen][MOLES] > cached_gases[/datum/gas/plasma][MOLES] * PLASMA_OXYGEN_FULLBURN)
			plasma_burn_rate = (cached_gases[/datum/gas/plasma][MOLES] * temperature_scale) / PLASMA_BURN_RATE_DELTA
		else
			plasma_burn_rate = (temperature_scale * (cached_gases[/datum/gas/oxygen][MOLES] / PLASMA_OXYGEN_FULLBURN)) / PLASMA_BURN_RATE_DELTA

		if(plasma_burn_rate > MINIMUM_HEAT_CAPACITY)
			plasma_burn_rate = min(plasma_burn_rate, cached_gases[/datum/gas/plasma][MOLES], cached_gases[/datum/gas/oxygen][MOLES] *  INVERSE(oxygen_burn_rate)) //Ensures matter is conserved properly
			cached_gases[/datum/gas/plasma][MOLES] = QUANTIZE(cached_gases[/datum/gas/plasma][MOLES] - plasma_burn_rate)
			cached_gases[/datum/gas/oxygen][MOLES] = QUANTIZE(cached_gases[/datum/gas/oxygen][MOLES] - (plasma_burn_rate * oxygen_burn_rate))
			if (super_saturation)
				ASSERT_GAS(/datum/gas/tritium, air)
				cached_gases[/datum/gas/tritium][MOLES] += plasma_burn_rate
			else
				ASSERT_GAS(/datum/gas/carbon_dioxide,air)
				ASSERT_GAS(/datum/gas/water_vapor,air)
				cached_gases[/datum/gas/carbon_dioxide][MOLES] += plasma_burn_rate * 0.75
				cached_gases[/datum/gas/water_vapor][MOLES] += plasma_burn_rate * 0.25

			energy_released += FIRE_PLASMA_ENERGY_RELEASED * (plasma_burn_rate)

			cached_results["fire"] += (plasma_burn_rate) * (1 + oxygen_burn_rate)

	if(energy_released > 0)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.temperature = (temperature * old_heat_capacity + energy_released) / new_heat_capacity

	//let the floor know a fire is happening
	if(istype(location))
		temperature = air.temperature
		if(temperature > FIRE_MINIMUM_TEMPERATURE_TO_EXIST)
			location.hotspot_expose(temperature, CELL_VOLUME)

	return cached_results["fire"] ? REACTING : NO_REACTION

//freon reaction (is not a fire yet)
/datum/gas_reaction/freonfire
	priority_group = PRIORITY_FIRE
	name = "Freon combustion"
	id = "freonfire"

/datum/gas_reaction/freonfire/init_reqs()
	requirements = list(
		/datum/gas/oxygen = MINIMUM_MOLE_COUNT,
		/datum/gas/freon = MINIMUM_MOLE_COUNT,
		"MIN_TEMP" = FREON_LOWER_TEMPERATURE,
		"MAX_TEMP" = FREON_MAXIMUM_BURN_TEMPERATURE
		)

/datum/gas_reaction/freonfire/react(datum/gas_mixture/air, datum/holder)
	var/energy_released = 0
	var/old_heat_capacity = air.heat_capacity()
	var/list/cached_gases = air.gases //this speeds things up because accessing datum vars is slow
	var/temperature = air.temperature
	if(!isturf(holder))
		return NO_REACTION
	var/turf/open/location = holder

	//Handle freon burning (only reaction now)
	var/freon_burn_rate = 0
	var/oxygen_burn_rate = 0
	//more freon released at lower temperatures
	var/temperature_scale = 1

	if(temperature < FREON_LOWER_TEMPERATURE) //stop the reaction when too cold
		temperature_scale = 0
	else
		temperature_scale = (FREON_MAXIMUM_BURN_TEMPERATURE - temperature) / (FREON_MAXIMUM_BURN_TEMPERATURE - FREON_LOWER_TEMPERATURE) //calculate the scale based on the temperature
	if(temperature_scale >= 0)
		oxygen_burn_rate = OXYGEN_BURN_RATE_BASE - temperature_scale
		if(cached_gases[/datum/gas/oxygen][MOLES] > cached_gases[/datum/gas/freon][MOLES] * FREON_OXYGEN_FULLBURN)
			freon_burn_rate = (cached_gases[/datum/gas/freon][MOLES] * temperature_scale) / FREON_BURN_RATE_DELTA
		else
			freon_burn_rate = (temperature_scale * (cached_gases[/datum/gas/oxygen][MOLES] / FREON_OXYGEN_FULLBURN)) / FREON_BURN_RATE_DELTA

		if(freon_burn_rate > MINIMUM_HEAT_CAPACITY)
			freon_burn_rate = min(freon_burn_rate, cached_gases[/datum/gas/freon][MOLES], cached_gases[/datum/gas/oxygen][MOLES] * INVERSE(oxygen_burn_rate)) //Ensures matter is conserved properly
			cached_gases[/datum/gas/freon][MOLES] = QUANTIZE(cached_gases[/datum/gas/freon][MOLES] - freon_burn_rate)
			cached_gases[/datum/gas/oxygen][MOLES] = QUANTIZE(cached_gases[/datum/gas/oxygen][MOLES] - (freon_burn_rate * oxygen_burn_rate))
			ASSERT_GAS(/datum/gas/carbon_dioxide, air)
			cached_gases[/datum/gas/carbon_dioxide][MOLES] += freon_burn_rate

			if(temperature < 160 && temperature > 120 && prob(2))
				new /obj/item/stack/sheet/hot_ice(location)

			energy_released += FIRE_FREON_ENERGY_RELEASED * (freon_burn_rate)
			. = REACTING

	if(energy_released < 0)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.temperature = (temperature * old_heat_capacity + energy_released) / new_heat_capacity
		. = REACTING

/datum/gas_reaction/h2fire
	priority_group = PRIORITY_FIRE
	name = "Hydrogen Combustion"
	id = "h2fire"

/datum/gas_reaction/h2fire/init_reqs()
	requirements = list(
		/datum/gas/hydrogen = MINIMUM_MOLE_COUNT,
		/datum/gas/oxygen = MINIMUM_MOLE_COUNT,
		"MIN_TEMP" = FIRE_MINIMUM_TEMPERATURE_TO_EXIST
	)

/datum/gas_reaction/h2fire/react(datum/gas_mixture/air, datum/holder)
	var/energy_released = 0
	var/old_heat_capacity = air.heat_capacity()
	var/list/cached_gases = air.gases //this speeds things up because accessing datum vars is slow
	var/temperature = air.temperature
	var/list/cached_results = air.reaction_results
	cached_results["fire"] = 0
	var/turf/open/location = isturf(holder) ? holder : null
	var/burned_fuel = 0
	if(cached_gases[/datum/gas/oxygen][MOLES] < cached_gases[/datum/gas/hydrogen][MOLES] || MINIMUM_H2_OXYBURN_ENERGY > air.thermal_energy())
		burned_fuel = cached_gases[/datum/gas/oxygen][MOLES] / HYDROGEN_BURN_OXY_FACTOR
		cached_gases[/datum/gas/hydrogen][MOLES] -= burned_fuel

		ASSERT_GAS(/datum/gas/water_vapor, air) //oxygen+more-or-less hydrogen=H2O
		cached_gases[/datum/gas/water_vapor][MOLES] += burned_fuel / HYDROGEN_BURN_OXY_FACTOR

		energy_released += (FIRE_HYDROGEN_ENERGY_WEAK * burned_fuel)
		cached_results["fire"] += burned_fuel

	else
		burned_fuel = cached_gases[/datum/gas/hydrogen][MOLES]

		cached_gases[/datum/gas/hydrogen][MOLES] -= burned_fuel / HYDROGEN_BURN_H2_FACTOR
		cached_gases[/datum/gas/oxygen][MOLES] -= burned_fuel

		ASSERT_GAS(/datum/gas/water_vapor, air) //oxygen+more-or-less hydrogen=H2O
		cached_gases[/datum/gas/water_vapor][MOLES] += burned_fuel / HYDROGEN_BURN_H2_FACTOR

		energy_released += (FIRE_HYDROGEN_ENERGY_RELEASED * burned_fuel)
		cached_results["fire"] += burned_fuel * 10

	if(energy_released > 0)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.temperature = (temperature*old_heat_capacity + energy_released) / new_heat_capacity

	//let the floor know a fire is happening
	if(istype(location))
		temperature = air.temperature
		if(temperature > FIRE_MINIMUM_TEMPERATURE_TO_EXIST)
			location.hotspot_expose(temperature, CELL_VOLUME)

	return cached_results["fire"] ? REACTING : NO_REACTION

/datum/gas_reaction/nitrousformation //formationn of n2o, exothermic, requires bz as catalyst
	priority_group = PRIORITY_FORMATION
	name = "Nitrous Oxide formation"
	id = "nitrousformation"

/datum/gas_reaction/nitrousformation/init_reqs()
	requirements = list(
		/datum/gas/oxygen = 10,
		/datum/gas/nitrogen = 20,
		/datum/gas/bz = 5,
		"MIN_TEMP" = 200,
		"MAX_TEMP" = 250
	)

/datum/gas_reaction/nitrousformation/react(datum/gas_mixture/air)
	var/list/cached_gases = air.gases
	var/temperature = air.temperature
	var/old_heat_capacity = air.heat_capacity()
	var/heat_efficency = min(cached_gases[/datum/gas/oxygen][MOLES], cached_gases[/datum/gas/nitrogen][MOLES] * INVERSE(2))
	var/energy_used = heat_efficency * NITROUS_FORMATION_ENERGY

	if ((cached_gases[/datum/gas/oxygen][MOLES] - heat_efficency < 0 ) || (cached_gases[/datum/gas/nitrogen][MOLES] - heat_efficency * 2 < 0)) //Shouldn't produce gas from nothing.
		return NO_REACTION

	ASSERT_GAS(/datum/gas/nitrous_oxide, air)
	cached_gases[/datum/gas/oxygen][MOLES] -= heat_efficency
	cached_gases[/datum/gas/nitrogen][MOLES] -= heat_efficency * 2
	cached_gases[/datum/gas/nitrous_oxide][MOLES] += heat_efficency

	if(energy_used > 0)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.temperature = max(((temperature * old_heat_capacity + energy_used) / new_heat_capacity), TCMB) //the air heats up when reacting
		return REACTING

/datum/gas_reaction/nitrium_decomposition //The decomposition of nitrium. Exothermic. Requires oxygen as catalyst.
	priority_group = PRIORITY_PRE_FORMATION
	name = "Nitrium Decomposition"
	id = "nitrium_decomp"

/datum/gas_reaction/nitrium_decomposition/init_reqs()
	requirements = list(
		/datum/gas/oxygen = MINIMUM_MOLE_COUNT,
		/datum/gas/nitrium = MINIMUM_MOLE_COUNT,
		"MAX_TEMP" = T0C + 70 //Pretty warm, explicitly not fire temps. Time bombs are cool, but not that cool. If it makes you feel any better it's close
	)

/datum/gas_reaction/nitrium_decomposition/react(datum/gas_mixture/air)
	var/list/cached_gases = air.gases
	var/temperature = air.temperature
	var/old_heat_capacity = air.heat_capacity()

	//This reaction is agressively slow. like, a tenth of a mole per fire slow. Keep that in mind
	var/heat_efficency = min(temperature / (FIRE_MINIMUM_TEMPERATURE_TO_EXIST * 8), cached_gases[/datum/gas/nitrium][MOLES])
	var/energy_produced = heat_efficency * NITRIUM_DECOMPOSITION_ENERGY

	if ((cached_gases[/datum/gas/nitrium][MOLES] - heat_efficency < 0)) //Shouldn't produce gas from nothing.
		return NO_REACTION

	air.assert_gases(/datum/gas/nitrogen, /datum/gas/hydrogen)
	cached_gases[/datum/gas/nitrium][MOLES] -= heat_efficency
	cached_gases[/datum/gas/hydrogen][MOLES] += heat_efficency
	cached_gases[/datum/gas/nitrogen][MOLES] += heat_efficency

	if(energy_produced> 0)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.temperature = max(((temperature * old_heat_capacity + energy_produced) / new_heat_capacity), TCMB) //the air heats up when reacting
		return REACTING

/datum/gas_reaction/nitrium_formation //The formation of nitrium. Endothermic. Requires bz.
	priority_group = PRIORITY_FORMATION
	name = "Nitrium formation"
	id = "nitrium_formation"

/datum/gas_reaction/nitrium_formation/init_reqs()
	requirements = list(
		/datum/gas/tritium = 20,
		/datum/gas/nitrogen = 10,
		/datum/gas/bz = 5,
		"MIN_TEMP" = 1500
	)

/datum/gas_reaction/nitrium_formation/react(datum/gas_mixture/air)
	var/list/cached_gases = air.gases
	var/temperature = air.temperature

	var/old_heat_capacity = air.heat_capacity()
	var/heat_efficency = min(temperature / (FIRE_MINIMUM_TEMPERATURE_TO_EXIST * 8), cached_gases[/datum/gas/tritium][MOLES], cached_gases[/datum/gas/nitrogen][MOLES], cached_gases[/datum/gas/bz][MOLES] * INVERSE(0.05))
	var/energy_used = heat_efficency * NITRIUM_FORMATION_ENERGY
	ASSERT_GAS(/datum/gas/nitrium, air)
	if ((cached_gases[/datum/gas/tritium][MOLES] - heat_efficency < 0 ) || (cached_gases[/datum/gas/nitrogen][MOLES] - heat_efficency < 0) || (cached_gases[/datum/gas/bz][MOLES] - heat_efficency * 0.05 < 0)) //Shouldn't produce gas from nothing.
		return NO_REACTION

	cached_gases[/datum/gas/tritium][MOLES] -= heat_efficency
	cached_gases[/datum/gas/nitrogen][MOLES] -= heat_efficency
	cached_gases[/datum/gas/bz][MOLES] -= heat_efficency * 0.05 //bz gets consumed to balance the nitrium production and not make it too common and/or easy
	cached_gases[/datum/gas/nitrium][MOLES] += heat_efficency

	if(energy_used > 0)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.temperature = max(((temperature * old_heat_capacity - energy_used) / new_heat_capacity), TCMB) //the air cools down when reacting
		return REACTING

/datum/gas_reaction/bzformation //Formation of BZ by combining plasma and tritium at low pressures. Exothermic.
	priority_group = PRIORITY_FORMATION
	name = "BZ Gas formation"
	id = "bzformation"

/datum/gas_reaction/bzformation/init_reqs()
	requirements = list(
		/datum/gas/nitrous_oxide = 10,
		/datum/gas/plasma = 10
	)

/datum/gas_reaction/bzformation/react(datum/gas_mixture/air)
	var/list/cached_gases = air.gases
	var/temperature = air.temperature
	var/pressure = air.return_pressure()
	var/old_heat_capacity = air.heat_capacity()
	var/reaction_efficency = min(1 / ((pressure / (0.1 * ONE_ATMOSPHERE)) * (max(cached_gases[/datum/gas/plasma][MOLES] / cached_gases[/datum/gas/nitrous_oxide][MOLES], 1))), cached_gases[/datum/gas/nitrous_oxide][MOLES], cached_gases[/datum/gas/plasma][MOLES] * INVERSE(2))
	var/energy_released = 2 * reaction_efficency * FIRE_CARBON_ENERGY_RELEASED
	if ((cached_gases[/datum/gas/nitrous_oxide][MOLES] - reaction_efficency < 0 )|| (cached_gases[/datum/gas/plasma][MOLES] - (2 * reaction_efficency) < 0) || energy_released <= 0) //Shouldn't produce gas from nothing.
		return NO_REACTION

	ASSERT_GAS(/datum/gas/bz, air)
	cached_gases[/datum/gas/bz][MOLES] += reaction_efficency * 2.5
	if(reaction_efficency == cached_gases[/datum/gas/nitrous_oxide][MOLES])
		ASSERT_GAS(/datum/gas/oxygen, air)
		cached_gases[/datum/gas/bz][MOLES] -= min(pressure, 0.5)
		cached_gases[/datum/gas/oxygen][MOLES] += min(pressure, 0.5)
	cached_gases[/datum/gas/nitrous_oxide][MOLES] -= reaction_efficency
	cached_gases[/datum/gas/plasma][MOLES]  -= 2 * reaction_efficency

	if(energy_released > 0)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.temperature = max(((temperature * old_heat_capacity + energy_released) / new_heat_capacity), TCMB)
		return REACTING

/datum/gas_reaction/freonformation
	priority_group = PRIORITY_FORMATION
	name = "Freon formation"
	id = "freonformation"

/datum/gas_reaction/freonformation/init_reqs() //minimum requirements for freon formation
	requirements = list(
		/datum/gas/plasma = 40,
		/datum/gas/carbon_dioxide = 20,
		/datum/gas/bz = 20,
		"MIN_TEMP" = FIRE_MINIMUM_TEMPERATURE_TO_EXIST + 100
		)

/datum/gas_reaction/freonformation/react(datum/gas_mixture/air)
	var/list/cached_gases = air.gases
	var/temperature = air.temperature
	var/old_heat_capacity = air.heat_capacity()
	var/heat_efficency = min(temperature / (FIRE_MINIMUM_TEMPERATURE_TO_EXIST * 10), cached_gases[/datum/gas/plasma][MOLES] * INVERSE(1.5), cached_gases[/datum/gas/carbon_dioxide][MOLES] * INVERSE(0.75), cached_gases[/datum/gas/bz][MOLES] * INVERSE(0.25))
	var/energy_used = heat_efficency * 100
	if ((cached_gases[/datum/gas/plasma][MOLES] - heat_efficency * 1.5 < 0 ) || (cached_gases[/datum/gas/carbon_dioxide][MOLES] - heat_efficency * 0.75 < 0) || (cached_gases[/datum/gas/bz][MOLES] - heat_efficency * 0.25 < 0)) //Shouldn't produce gas from nothing.
		return NO_REACTION

	ASSERT_GAS(/datum/gas/freon, air)
	cached_gases[/datum/gas/plasma][MOLES] -= heat_efficency * 1.5
	cached_gases[/datum/gas/carbon_dioxide][MOLES] -= heat_efficency * 0.75
	cached_gases[/datum/gas/bz][MOLES] -= heat_efficency * 0.25
	cached_gases[/datum/gas/freon][MOLES] += heat_efficency * 2.5

	if(energy_used > 0)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.temperature = max(((temperature * old_heat_capacity - energy_used)/new_heat_capacity), TCMB)
		return REACTING

/datum/gas_reaction/nobliumformation //Hyper-Noblium formation is extrememly endothermic, but requires high temperatures to start. Due to its high mass, hyper-nobelium uses large amounts of nitrogen and tritium. BZ can be used as a catalyst to make it less endothermic.
	priority_group = PRIORITY_FORMATION
	name = "Hyper-Noblium condensation"
	id = "nobformation"

/datum/gas_reaction/nobliumformation/init_reqs()
	requirements = list(
		/datum/gas/nitrogen = 10,
		/datum/gas/tritium = 5,
		"MIN_TEMP" = TCMB,
		"MAX_TEMP" = 15
		)

/datum/gas_reaction/nobliumformation/react(datum/gas_mixture/air)
	var/list/cached_gases = air.gases
	air.assert_gases(/datum/gas/hypernoblium, /datum/gas/bz)
	var/old_heat_capacity = air.heat_capacity()
	var/nob_formed = min((cached_gases[/datum/gas/nitrogen][MOLES] + cached_gases[/datum/gas/tritium][MOLES]) * 0.01, cached_gases[/datum/gas/tritium][MOLES] * INVERSE(5), cached_gases[/datum/gas/nitrogen][MOLES] * INVERSE(10))
	var/energy_produced = nob_formed * (NOBLIUM_FORMATION_ENERGY / (max(cached_gases[/datum/gas/bz][MOLES], 1)))
	if ((cached_gases[/datum/gas/tritium][MOLES] - 5 * nob_formed < 0) || (cached_gases[/datum/gas/nitrogen][MOLES] - 10 * nob_formed < 0))
		return NO_REACTION

	cached_gases[/datum/gas/tritium][MOLES] -= 5 * nob_formed
	cached_gases[/datum/gas/nitrogen][MOLES] -= 10 * nob_formed
	cached_gases[/datum/gas/hypernoblium][MOLES] += nob_formed

	if (nob_formed)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.temperature = max(((air.temperature * old_heat_capacity + energy_produced) / new_heat_capacity), TCMB)
		return REACTING


/datum/gas_reaction/miaster //dry heat sterilization: clears out pathogens in the air
	priority_group = PRIORITY_POST_FORMATION
	name = "Dry Heat Sterilization"
	id = "sterilization"

/datum/gas_reaction/miaster/init_reqs()
	requirements = list(
		/datum/gas/miasma = MINIMUM_MOLE_COUNT,
		"MIN_TEMP" = FIRE_MINIMUM_TEMPERATURE_TO_EXIST+70
		)

/datum/gas_reaction/miaster/react(datum/gas_mixture/air, datum/holder)
	var/list/cached_gases = air.gases
	// As the name says it, it needs to be dry
	if(cached_gases[/datum/gas/water_vapor] && cached_gases[/datum/gas/water_vapor][MOLES] / air.total_moles() > 0.1)
		return NO_REACTION

	//Replace miasma with oxygen
	var/cleaned_air = min(cached_gases[/datum/gas/miasma][MOLES], 20 + (air.temperature - FIRE_MINIMUM_TEMPERATURE_TO_EXIST - 70) / 20)
	cached_gases[/datum/gas/miasma][MOLES] -= cleaned_air
	ASSERT_GAS(/datum/gas/oxygen, air)
	cached_gases[/datum/gas/oxygen][MOLES] += cleaned_air

	//Possibly burning a bit of organic matter through maillard reaction, so a *tiny* bit more heat would be understandable
	air.temperature += cleaned_air * 0.002

	return REACTING

/datum/gas_reaction/halon_formation
	priority_group = PRIORITY_FORMATION
	name = "Halon formation"
	id = "halon_formation"

/datum/gas_reaction/halon_formation/init_reqs()
	requirements = list(
		/datum/gas/bz = MINIMUM_MOLE_COUNT,
		/datum/gas/tritium = MINIMUM_MOLE_COUNT,
		"MIN_TEMP" = 30,
		"MAX_TEMP" = 55
	)

/datum/gas_reaction/halon_formation/react(datum/gas_mixture/air, datum/holder)
	var/list/cached_gases = air.gases
	var/temperature = air.temperature
	var/old_heat_capacity = air.heat_capacity()
	var/heat_efficency = min(temperature * 0.01, cached_gases[/datum/gas/tritium][MOLES] * INVERSE(4), cached_gases[/datum/gas/bz][MOLES] * INVERSE(0.25))
	var/energy_used = heat_efficency * 300
	ASSERT_GAS(/datum/gas/halon, air)
	if ((cached_gases[/datum/gas/tritium][MOLES] - heat_efficency * 4 < 0 ) || (cached_gases[/datum/gas/bz][MOLES] - heat_efficency * 0.25 < 0)) //Shouldn't produce gas from nothing.
		return NO_REACTION
	cached_gases[/datum/gas/tritium][MOLES] -= heat_efficency * 4
	cached_gases[/datum/gas/bz][MOLES] -= heat_efficency * 0.25
	cached_gases[/datum/gas/halon][MOLES] += heat_efficency * 4.25

	if(energy_used)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.temperature = max(((temperature * old_heat_capacity + energy_used) / new_heat_capacity), TCMB)
	return REACTING

/datum/gas_reaction/healium_formation
	priority_group = PRIORITY_FORMATION
	name = "Healium formation"
	id = "healium_formation"

/datum/gas_reaction/healium_formation/init_reqs()
	requirements = list(
		/datum/gas/bz = MINIMUM_MOLE_COUNT,
		/datum/gas/freon = MINIMUM_MOLE_COUNT,
		"MIN_TEMP" = 25,
		"MAX_TEMP" = 300
	)

/datum/gas_reaction/healium_formation/react(datum/gas_mixture/air, datum/holder)
	var/list/cached_gases = air.gases
	var/temperature = air.temperature
	var/old_heat_capacity = air.heat_capacity()
	var/heat_efficency = min(temperature * 0.3, cached_gases[/datum/gas/freon][MOLES] * INVERSE(2.75), cached_gases[/datum/gas/bz][MOLES] * INVERSE(0.25))
	var/energy_used = heat_efficency * 9000
	ASSERT_GAS(/datum/gas/healium, air)
	if ((cached_gases[/datum/gas/freon][MOLES] - heat_efficency * 2.75 < 0 ) || (cached_gases[/datum/gas/bz][MOLES] - heat_efficency * 0.25 < 0)) //Shouldn't produce gas from nothing.
		return NO_REACTION
	cached_gases[/datum/gas/freon][MOLES] -= heat_efficency * 2.75
	cached_gases[/datum/gas/bz][MOLES] -= heat_efficency * 0.25
	cached_gases[/datum/gas/healium][MOLES] += heat_efficency * 3

	if(energy_used)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.temperature = max(((temperature * old_heat_capacity + energy_used) / new_heat_capacity), TCMB)
	return REACTING

/datum/gas_reaction/proto_nitrate_formation
	priority_group = PRIORITY_FORMATION
	name = "Proto Nitrate formation"
	id = "proto_nitrate_formation"

/datum/gas_reaction/proto_nitrate_formation/init_reqs()
	requirements = list(
		/datum/gas/pluoxium = MINIMUM_MOLE_COUNT,
		/datum/gas/hydrogen = MINIMUM_MOLE_COUNT,
		"MIN_TEMP" = 5000,
		"MAX_TEMP" = 10000
	)

/datum/gas_reaction/proto_nitrate_formation/react(datum/gas_mixture/air, datum/holder)
	var/list/cached_gases = air.gases
	var/temperature = air.temperature
	var/old_heat_capacity = air.heat_capacity()
	var/heat_efficency = min(temperature * 0.005, cached_gases[/datum/gas/pluoxium][MOLES] * INVERSE(0.2), cached_gases[/datum/gas/hydrogen][MOLES] * INVERSE(2))
	var/energy_used = heat_efficency * 650
	ASSERT_GAS(/datum/gas/proto_nitrate, air)
	if ((cached_gases[/datum/gas/pluoxium][MOLES] - heat_efficency * 0.2 < 0 ) || (cached_gases[/datum/gas/hydrogen][MOLES] - heat_efficency * 2 < 0)) //Shouldn't produce gas from nothing.
		return NO_REACTION
	cached_gases[/datum/gas/hydrogen][MOLES] -= heat_efficency * 2
	cached_gases[/datum/gas/pluoxium][MOLES] -= heat_efficency * 0.2
	cached_gases[/datum/gas/proto_nitrate][MOLES] += heat_efficency * 2.2

	if(energy_used > 0)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.temperature = max(((temperature * old_heat_capacity + energy_used) / new_heat_capacity), TCMB)
	return REACTING

/datum/gas_reaction/zauker_formation
	priority_group = PRIORITY_FORMATION
	name = "Zauker formation"
	id = "zauker_formation"

/datum/gas_reaction/zauker_formation/init_reqs()
	requirements = list(
		/datum/gas/hypernoblium = MINIMUM_MOLE_COUNT,
		/datum/gas/nitrium = MINIMUM_MOLE_COUNT,
		"MIN_TEMP" = 50000,
		"MAX_TEMP" = 75000
	)

/datum/gas_reaction/zauker_formation/react(datum/gas_mixture/air, datum/holder)
	var/list/cached_gases = air.gases
	var/temperature = air.temperature
	var/old_heat_capacity = air.heat_capacity()
	var/heat_efficency = min(temperature * 0.000005, cached_gases[/datum/gas/hypernoblium][MOLES] * INVERSE(0.01), cached_gases[/datum/gas/nitrium][MOLES] * INVERSE(0.5))
	var/energy_used = heat_efficency * 5000
	ASSERT_GAS(/datum/gas/zauker, air)
	if ((cached_gases[/datum/gas/hypernoblium][MOLES] - heat_efficency * 0.01 < 0 ) || (cached_gases[/datum/gas/nitrium][MOLES] - heat_efficency * 0.5 < 0)) //Shouldn't produce gas from nothing.
		return NO_REACTION
	cached_gases[/datum/gas/hypernoblium][MOLES] -= heat_efficency * 0.01
	cached_gases[/datum/gas/nitrium][MOLES] -= heat_efficency * 0.5
	cached_gases[/datum/gas/zauker][MOLES] += heat_efficency * 0.5

	if(energy_used)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.temperature = max(((temperature * old_heat_capacity - energy_used) / new_heat_capacity), TCMB)
	return REACTING

/datum/gas_reaction/halon_o2removal
	priority_group = PRIORITY_PRE_FORMATION
	name = "Halon o2 removal"
	id = "halon_o2removal"

/datum/gas_reaction/halon_o2removal/init_reqs()
	requirements = list(
		/datum/gas/halon = MINIMUM_MOLE_COUNT,
		/datum/gas/oxygen = MINIMUM_MOLE_COUNT,
		"MIN_TEMP" = FIRE_MINIMUM_TEMPERATURE_TO_EXIST
	)

/datum/gas_reaction/halon_o2removal/react(datum/gas_mixture/air, datum/holder)
	var/list/cached_gases = air.gases
	var/temperature = air.temperature
	var/old_heat_capacity = air.heat_capacity()
	var/heat_efficency = min(temperature / ( FIRE_MINIMUM_TEMPERATURE_TO_EXIST * 10), cached_gases[/datum/gas/halon][MOLES], cached_gases[/datum/gas/oxygen][MOLES] * INVERSE(20))
	var/energy_used = heat_efficency * 2500
	ASSERT_GAS(/datum/gas/carbon_dioxide, air)
	if ((cached_gases[/datum/gas/halon][MOLES] - heat_efficency < 0 ) || (cached_gases[/datum/gas/oxygen][MOLES] - heat_efficency * 20 < 0)) //Shouldn't produce gas from nothing.
		return NO_REACTION
	cached_gases[/datum/gas/halon][MOLES] -= heat_efficency
	cached_gases[/datum/gas/oxygen][MOLES] -= heat_efficency * 20
	cached_gases[/datum/gas/carbon_dioxide][MOLES] += heat_efficency * 5

	if(energy_used)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.temperature = max(((temperature * old_heat_capacity - energy_used) / new_heat_capacity), TCMB)
	return REACTING

/datum/gas_reaction/zauker_decomp
	priority_group = PRIORITY_POST_FORMATION
	name = "Zauker decomposition"
	id = "zauker_decomp"

/datum/gas_reaction/zauker_decomp/init_reqs()
	requirements = list(
		/datum/gas/nitrogen = MINIMUM_MOLE_COUNT,
		/datum/gas/zauker = MINIMUM_MOLE_COUNT
	)

/datum/gas_reaction/zauker_decomp/react(datum/gas_mixture/air, datum/holder)
	var/energy_released = 0
	var/old_heat_capacity = air.heat_capacity()
	var/list/cached_gases = air.gases //this speeds things up because accessing datum vars is slow
	var/temperature = air.temperature
	var/burned_fuel = 0
	burned_fuel = min(20, cached_gases[/datum/gas/nitrogen][MOLES], cached_gases[/datum/gas/zauker][MOLES])
	if(cached_gases[/datum/gas/zauker][MOLES] - burned_fuel < 0)
		return NO_REACTION
	cached_gases[/datum/gas/zauker][MOLES] -= burned_fuel

	if(burned_fuel)
		energy_released += (460 * burned_fuel)

		ASSERT_GAS(/datum/gas/oxygen, air)
		ASSERT_GAS(/datum/gas/nitrogen, air)
		cached_gases[/datum/gas/oxygen][MOLES] += burned_fuel * 0.3
		cached_gases[/datum/gas/nitrogen][MOLES] += burned_fuel * 0.7

		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.temperature = max((temperature * old_heat_capacity + energy_released) / new_heat_capacity, TCMB)
		return REACTING
	return NO_REACTION

/datum/gas_reaction/proto_nitrate_bz_response
	priority_group = PRIORITY_PRE_FORMATION
	name = "Proto Nitrate bz response"
	id = "proto_nitrate_bz_response"

/datum/gas_reaction/proto_nitrate_bz_response/init_reqs()
	requirements = list(
		/datum/gas/proto_nitrate = MINIMUM_MOLE_COUNT,
		/datum/gas/bz = MINIMUM_MOLE_COUNT,
		"MIN_TEMP" = 260,
		"MAX_TEMP" = 280
	)

/datum/gas_reaction/proto_nitrate_bz_response/react(datum/gas_mixture/air, datum/holder)
	var/energy_released = 0
	var/old_heat_capacity = air.heat_capacity()
	var/list/cached_gases = air.gases
	var/temperature = air.temperature
	var/turf/open/location
	if(istype(holder,/datum/pipeline)) //Find the tile the reaction is occuring on, or a random part of the network if it's a pipenet.
		var/datum/pipeline/pipenet = holder
		location = get_turf(pick(pipenet.members))
	else
		location = get_turf(holder)
	var consumed_amount = min(air.temperature / 2240 * cached_gases[/datum/gas/bz][MOLES] * cached_gases[/datum/gas/proto_nitrate][MOLES] / (cached_gases[/datum/gas/bz][MOLES] + cached_gases[/datum/gas/proto_nitrate][MOLES]), cached_gases[/datum/gas/bz][MOLES], cached_gases[/datum/gas/proto_nitrate][MOLES])
	if(cached_gases[/datum/gas/bz][MOLES] - consumed_amount < 0)
		return NO_REACTION

	ASSERT_GAS(/datum/gas/nitrogen, air)
	ASSERT_GAS(/datum/gas/helium, air)
	ASSERT_GAS(/datum/gas/plasma, air)
	cached_gases[/datum/gas/nitrogen][MOLES] += consumed_amount * 0.4
	cached_gases[/datum/gas/helium][MOLES] += consumed_amount * 1.6
	cached_gases[/datum/gas/plasma][MOLES] += consumed_amount * 0.8
	cached_gases[/datum/gas/bz][MOLES] -= consumed_amount
	energy_released += consumed_amount * 60000
	radiation_pulse(location, max_range = min(sqrt(consumed_amount) / 1.5, 20), threshold = 15 * INVERSE(15 + consumed_amount), chance = 50)
	for(var/mob/living/carbon/L in location)
		L.hallucination += consumed_amount
	if(energy_released)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.temperature = max((temperature * old_heat_capacity + energy_released) / new_heat_capacity, TCMB)
	return REACTING

/datum/gas_reaction/proto_nitrate_tritium_response
	priority_group = PRIORITY_PRE_FORMATION
	name = "Proto Nitrate tritium response"
	id = "proto_nitrate_tritium_response"

/datum/gas_reaction/proto_nitrate_tritium_response/init_reqs()
	requirements = list(
		/datum/gas/proto_nitrate = MINIMUM_MOLE_COUNT,
		/datum/gas/tritium = MINIMUM_MOLE_COUNT,
		"MIN_TEMP" = 150,
		"MAX_TEMP" = 340
	)

/datum/gas_reaction/proto_nitrate_tritium_response/react(datum/gas_mixture/air, datum/holder)
	var/energy_released = 0
	var/old_heat_capacity = air.heat_capacity()
	var/list/cached_gases = air.gases
	var/temperature = air.temperature
	var/turf/open/location
	if(istype(holder,/datum/pipeline)) //Find the tile the reaction is occuring on, or a random part of the network if it's a pipenet.
		var/datum/pipeline/pipenet = holder
		location = get_turf(pick(pipenet.members))
	else
		location = get_turf(holder)
	var produced_amount = min(air.temperature / 34 * (cached_gases[/datum/gas/tritium][MOLES] * cached_gases[/datum/gas/proto_nitrate][MOLES]) / (cached_gases[/datum/gas/tritium][MOLES] + 10 * cached_gases[/datum/gas/proto_nitrate][MOLES]), cached_gases[/datum/gas/tritium][MOLES], cached_gases[/datum/gas/proto_nitrate][MOLES] * INVERSE(0.01))
	if(cached_gases[/datum/gas/tritium][MOLES] - produced_amount < 0 || cached_gases[/datum/gas/proto_nitrate][MOLES] - produced_amount * 0.01 < 0)
		return NO_REACTION
	ASSERT_GAS(/datum/gas/hydrogen, air)
	cached_gases[/datum/gas/tritium][MOLES] -= produced_amount
	cached_gases[/datum/gas/proto_nitrate][MOLES] -= produced_amount * 0.01
	cached_gases[/datum/gas/hydrogen][MOLES] += produced_amount
	energy_released += produced_amount * 10000
	radiation_pulse(location, max_range = min(sqrt(produced_amount) / 1.5, 20), threshold = 15 * INVERSE(15 + produced_amount), chance = 50)
	if(energy_released)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.temperature = max((temperature * old_heat_capacity + energy_released) / new_heat_capacity, TCMB)
	return REACTING

/datum/gas_reaction/proto_nitrate_hydrogen_response
	priority_group = PRIORITY_PRE_FORMATION
	name = "Proto Nitrate hydrogen response"
	id = "proto_nitrate_hydrogen_response"

/datum/gas_reaction/proto_nitrate_hydrogen_response/init_reqs()
	requirements = list(
		/datum/gas/proto_nitrate = MINIMUM_MOLE_COUNT,
		/datum/gas/hydrogen = 150,
	)

/datum/gas_reaction/proto_nitrate_hydrogen_response/react(datum/gas_mixture/air, datum/holder)
	var/energy_released = 0
	var/old_heat_capacity = air.heat_capacity()
	var/list/cached_gases = air.gases
	var/temperature = air.temperature
	var produced_amount = min(5, cached_gases[/datum/gas/hydrogen][MOLES], cached_gases[/datum/gas/proto_nitrate][MOLES])
	if(cached_gases[/datum/gas/hydrogen][MOLES] - produced_amount < 0)
		return NO_REACTION
	cached_gases[/datum/gas/hydrogen][MOLES] -= produced_amount
	cached_gases[/datum/gas/proto_nitrate][MOLES] += produced_amount * 0.5
	energy_released = produced_amount * 2500
	if(energy_released)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.temperature = max((temperature * old_heat_capacity - energy_released) / new_heat_capacity, TCMB)
	return REACTING

/datum/gas_reaction/pluox_formation
	priority_group = PRIORITY_FORMATION
	name = "Pluoxium formation"
	id = "pluox_formation"

/datum/gas_reaction/pluox_formation/init_reqs()
	requirements = list(
		/datum/gas/carbon_dioxide = MINIMUM_MOLE_COUNT,
		/datum/gas/oxygen = MINIMUM_MOLE_COUNT,
		/datum/gas/tritium = MINIMUM_MOLE_COUNT,
		"MIN_TEMP" = 50,
		"MAX_TEMP" = T0C
	)

/datum/gas_reaction/pluox_formation/react(datum/gas_mixture/air, datum/holder)
	var/energy_released = 0
	var/old_heat_capacity = air.heat_capacity()
	var/list/cached_gases = air.gases
	var/temperature = air.temperature
	var produced_amount = min(5, cached_gases[/datum/gas/carbon_dioxide][MOLES], cached_gases[/datum/gas/oxygen][MOLES] * INVERSE(0.5), cached_gases[/datum/gas/tritium][MOLES] * INVERSE(0.01))
	if(cached_gases[/datum/gas/carbon_dioxide][MOLES] - produced_amount < 0 || cached_gases[/datum/gas/oxygen][MOLES] - produced_amount * 0.5 < 0 || cached_gases[/datum/gas/tritium][MOLES] - produced_amount * 0.01 < 0)
		return NO_REACTION
	cached_gases[/datum/gas/carbon_dioxide][MOLES] -= produced_amount
	cached_gases[/datum/gas/oxygen][MOLES] -= produced_amount * 0.5
	cached_gases[/datum/gas/tritium][MOLES] -= produced_amount * 0.01
	ASSERT_GAS(/datum/gas/pluoxium, air)
	cached_gases[/datum/gas/pluoxium][MOLES] += produced_amount
	ASSERT_GAS(/datum/gas/hydrogen, air)
	cached_gases[/datum/gas/hydrogen][MOLES] += produced_amount * 0.01
	energy_released += produced_amount * 250
	if(energy_released)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.temperature = max((temperature * old_heat_capacity + energy_released) / new_heat_capacity, TCMB)
	return REACTING

/datum/gas_reaction/nitrogen_combustion
	priority_group = PRIORITY_FIRE
	name = "Nitrogen combustion"
	id = "n2_combustion"

/datum/gas_reaction/nitrogen_combustion/init_reqs()
	requirements = list(
		/datum/gas/antinoblium = MINIMUM_MOLE_COUNT,
		/datum/gas/nitrogen = MINIMUM_MOLE_COUNT,
		/datum/gas/oxygen = MINIMUM_MOLE_COUNT,
		"MIN_TEMP" = FIRE_MINIMUM_TEMPERATURE_TO_EXIST
	)

/datum/gas_reaction/nitrogen_combustion/react(datum/gas_mixture/air, datum/holder)
	var/energy_released = 0
	var/old_heat_capacity = air.heat_capacity()
	var/list/cached_gases = air.gases
	var/temperature = air.temperature
	var/cached_results = air.reaction_results
	cached_results["fire"] = 0
	var/turf/open/location
	if(istype(holder,/datum/pipeline)) //Find the tile the reaction is occuring on, or a random part of the network if it's a pipenet.
		var/datum/pipeline/pipenet = holder
		location = get_turf(pick(pipenet.members))
	else
		location = get_turf(holder)
	var/antinoblium_efficiency = cached_gases[/datum/gas/antinoblium][MOLES] * 0.000002 * temperature
	var/consumed_amount = min(8 * antinoblium_efficiency * cached_gases[/datum/gas/nitrogen][MOLES] * cached_gases[/datum/gas/oxygen][MOLES] / (antinoblium_efficiency * (cached_gases[/datum/gas/nitrogen][MOLES] + cached_gases[/datum/gas/oxygen][MOLES] * 8) + cached_gases[/datum/gas/nitrogen][MOLES] * cached_gases[/datum/gas/oxygen][MOLES] * 8), cached_gases[/datum/gas/nitrogen][MOLES], cached_gases[/datum/gas/oxygen][MOLES] * INVERSE(0.125))
	ASSERT_GAS(/datum/gas/nitrium, air)
	cached_gases[/datum/gas/nitrogen][MOLES] -= consumed_amount
	cached_gases[/datum/gas/oxygen][MOLES] -= consumed_amount * 0.125
	cached_gases[/datum/gas/nitrium][MOLES] += consumed_amount
	energy_released += consumed_amount * 80000000
	cached_results["fire"] += consumed_amount
	radiation_pulse(location, max_range = min(sqrt(consumed_amount) / 1.5, 20), threshold = 15 * INVERSE(15 + consumed_amount), chance = 50)
	var/zap_type = DEFAULT_ZAP_ICON_STATE
	var/flags = (ZAP_SUPERMATTER_FLAGS | ZAP_MOB_DAMAGE)
	if(consumed_amount >= 64)
		zap_type = SLIGHTLY_CHARGED_ZAP_ICON_STATE
		flags |= (ZAP_MOB_STUN | ZAP_OBJ_DAMAGE)
		if(prob(2))
			empulse(location, min(sqrt(consumed_amount) / 3, 10), min(sqrt(consumed_amount) / 1.5, 20))
	if(consumed_amount >= 256)
		zap_type = OVER_9000_ZAP_ICON_STATE
		flags |= ZAP_MACHINE_EXPLOSIVE
	supermatter_zap(location, range = min(sqrt(consumed_amount) / 2, 8), zap_str = energy_released / 1000000, zap_cutoff = energy_released / 2000000, zap_icon = zap_type, zap_flags = flags, power_level = energy_released / 1000000)
	if(energy_released)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.temperature = max((temperature * old_heat_capacity + energy_released) / new_heat_capacity, TCMB)

	//let the floor know a fire is happening
	if(istype(location))
		temperature = air.temperature
		if(temperature > FIRE_MINIMUM_TEMPERATURE_TO_EXIST)
			location.hotspot_expose(temperature, CELL_VOLUME)

	return cached_results["fire"] ? REACTING : NO_REACTION
