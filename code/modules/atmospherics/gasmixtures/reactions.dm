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


/**
 * Steam Condensation/Deposition:
 *
 * Makes turfs slippery.
 * Can frost things if the gas is cold enough.
 */
/datum/gas_reaction/water_vapor
	priority_group = PRIORITY_POST_FORMATION
	name = "Water Vapor"
	id = "vapor"

/datum/gas_reaction/water_vapor/init_reqs()
	requirements = list(/datum/gas/water_vapor = MOLES_GAS_VISIBLE)

/datum/gas_reaction/water_vapor/react(datum/gas_mixture/air, datum/holder)
	. = NO_REACTION
	if(isturf(holder))
		return

	var/turf/open/location = holder
	switch(air.temperature)
		if(-INFINITY to WATER_VAPOR_DEPOSITION_POINT)
			location.freeze_turf()
			. = REACTING
		if(WATER_VAPOR_DEPOSITION_POINT to WATER_VAPOR_CONDENSATION_POINT)
			location.water_vapor_gas_act()
			air.gases[/datum/gas/water_vapor][MOLES] -= MOLES_GAS_VISIBLE
			. = REACTING


/**
 * Dry Heat Sterilization:
 *
 * Clears out pathogens in the air.
 */
/datum/gas_reaction/miaster
	priority_group = PRIORITY_POST_FORMATION
	name = "Dry Heat Sterilization"
	id = "sterilization"

/datum/gas_reaction/miaster/init_reqs()
	requirements = list(
		/datum/gas/miasma = MINIMUM_MOLE_COUNT,
		"MIN_TEMP" = MIASTER_STERILIZATION_TEMP
	)

/datum/gas_reaction/miaster/react(datum/gas_mixture/air, datum/holder)
	var/list/cached_gases = air.gases
	// As the name says it, it needs to be dry
	if(cached_gases[/datum/gas/water_vapor] && cached_gases[/datum/gas/water_vapor][MOLES] / air.total_moles() > MIASTER_STERILIZATION_MAX_HUMIDITY)
		return NO_REACTION

	//Replace miasma with oxygen
	var/cleaned_air = min(cached_gases[/datum/gas/miasma][MOLES], MIASTER_STERILIZATION_RATE_BASE + (air.temperature - MIASTER_STERILIZATION_TEMP) / MIASTER_STERILIZATION_RATE_SCALE)
	cached_gases[/datum/gas/miasma][MOLES] -= cleaned_air
	ASSERT_GAS(/datum/gas/oxygen, air)
	cached_gases[/datum/gas/oxygen][MOLES] += cleaned_air

	//Possibly burning a bit of organic matter through maillard reaction, so a *tiny* bit more heat would be understandable
	air.temperature += cleaned_air * MIASTER_STERILIZATION_ENERGY

	return REACTING


// Fire:

/**
 * Plasma combustion:
 *
 * Combustion of oxygen and plasma (mostly treated as hydrocarbons).
 * The reaction rate is dependent on the temperature of the gasmix.
 * May produce either tritium or carbon dioxide and water vapor depending on the fuel/oxydizer ratio of the gasmix.
 */
/datum/gas_reaction/plasmafire
	priority_group = PRIORITY_FIRE
	name = "Plasma Combustion"
	id = "plasmafire"

/datum/gas_reaction/plasmafire/init_reqs()
	requirements = list(
		/datum/gas/plasma = MINIMUM_MOLE_COUNT,
		/datum/gas/oxygen = MINIMUM_MOLE_COUNT,
		"MIN_TEMP" = PLASMA_MINIMUM_BURN_TEMPERATURE,
	)

/datum/gas_reaction/plasmafire/react(datum/gas_mixture/air, datum/holder)
	// This reaction should proceed faster at higher temperatures.
	var/temperature = air.temperature
	var/temperature_scale = 0
	if(temperature > PLASMA_UPPER_TEMPERATURE)
		temperature_scale = 1
	else
		temperature_scale = (temperature - PLASMA_MINIMUM_BURN_TEMPERATURE) / (PLASMA_UPPER_TEMPERATURE-PLASMA_MINIMUM_BURN_TEMPERATURE)
		if(temperature_scale <= 0)
			return NO_REACTION

	var/oxygen_burn_ratio = OXYGEN_BURN_RATIO_BASE - temperature_scale
	var/plasma_burn_rate = 0
	var/super_saturation = FALSE // Whether we should make tritium.
	var/list/cached_gases = air.gases //this speeds things up because accessing datum vars is slow
	switch(cached_gases[/datum/gas/oxygen][MOLES] / cached_gases[/datum/gas/plasma][MOLES])
		if(SUPER_SATURATION_THRESHOLD to INFINITY)
			plasma_burn_rate = (cached_gases[/datum/gas/plasma][MOLES] / PLASMA_BURN_RATE_DELTA) * temperature_scale
			super_saturation = TRUE // Begin to form tritium
		if(PLASMA_OXYGEN_FULLBURN to SUPER_SATURATION_THRESHOLD)
			plasma_burn_rate = (cached_gases[/datum/gas/plasma][MOLES] / PLASMA_BURN_RATE_DELTA) * temperature_scale
		else
			plasma_burn_rate = ((cached_gases[/datum/gas/oxygen][MOLES] / PLASMA_OXYGEN_FULLBURN) / PLASMA_BURN_RATE_DELTA) * temperature_scale

	if(plasma_burn_rate < MINIMUM_HEAT_CAPACITY)
		return NO_REACTION

	var/old_heat_capacity = air.heat_capacity()
	plasma_burn_rate = min(plasma_burn_rate, cached_gases[/datum/gas/plasma][MOLES], cached_gases[/datum/gas/oxygen][MOLES] *  INVERSE(oxygen_burn_ratio)) //Ensures matter is conserved properly
	cached_gases[/datum/gas/plasma][MOLES] = QUANTIZE(cached_gases[/datum/gas/plasma][MOLES] - plasma_burn_rate)
	cached_gases[/datum/gas/oxygen][MOLES] = QUANTIZE(cached_gases[/datum/gas/oxygen][MOLES] - (plasma_burn_rate * oxygen_burn_ratio))
	if (super_saturation)
		ASSERT_GAS(/datum/gas/tritium, air)
		cached_gases[/datum/gas/tritium][MOLES] += plasma_burn_rate
	else
		ASSERT_GAS(/datum/gas/carbon_dioxide, air)
		ASSERT_GAS(/datum/gas/water_vapor, air)
		cached_gases[/datum/gas/carbon_dioxide][MOLES] += plasma_burn_rate * 0.75
		cached_gases[/datum/gas/water_vapor][MOLES] += plasma_burn_rate * 0.25

	air.reaction_results["fire"] += plasma_burn_rate * (1 + oxygen_burn_ratio)
	var/energy_released = FIRE_PLASMA_ENERGY_RELEASED * plasma_burn_rate
	var/new_heat_capacity = air.heat_capacity()
	if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
		air.temperature = (temperature * old_heat_capacity + energy_released) / new_heat_capacity

	// Let the floor know a fire is happening
	var/turf/open/location = holder
	if(istype(location))
		temperature = air.temperature
		if(temperature > FIRE_MINIMUM_TEMPERATURE_TO_EXIST)
			location.hotspot_expose(temperature, CELL_VOLUME)

	return REACTING


/**
 * Hydrogen combustion:
 *
 * Combustion of oxygen and hydrogen.
 * Highly exothermic.
 * Creates hotspots.
 */
/datum/gas_reaction/h2fire
	priority_group = PRIORITY_FIRE
	name = "Hydrogen Combustion"
	id = "h2fire"

/datum/gas_reaction/h2fire/init_reqs()
	requirements = list(
		/datum/gas/hydrogen = MINIMUM_MOLE_COUNT,
		/datum/gas/oxygen = MINIMUM_MOLE_COUNT,
		"MIN_TEMP" = HYDROGEN_MINIMUM_BURN_TEMPERATURE
	)

/datum/gas_reaction/h2fire/react(datum/gas_mixture/air, datum/holder)
	var/list/cached_gases = air.gases //this speeds things up because accessing datum vars is slow
	var/old_heat_capacity = air.heat_capacity()
	var/temperature = air.temperature

	var/burned_fuel
	var/fire_scale
	if(cached_gases[/datum/gas/oxygen][MOLES] < cached_gases[/datum/gas/hydrogen][MOLES] || MINIMUM_HYDROGEN_OXYBURN_ENERGY > (temperature * old_heat_capacity))
		burned_fuel = cached_gases[/datum/gas/oxygen][MOLES] / HYDROGEN_BURN_OXY_FACTOR // const must be at least one
		fire_scale = 1

		cached_gases[/datum/gas/hydrogen][MOLES] -= burned_fuel
		ASSERT_GAS(/datum/gas/water_vapor, air)
		cached_gases[/datum/gas/water_vapor][MOLES] += burned_fuel / HYDROGEN_BURN_OXY_FACTOR
	else
		burned_fuel = cached_gases[/datum/gas/hydrogen][MOLES]
		fire_scale = HYDROGEN_OXYBURN_MULTIPLIER

		cached_gases[/datum/gas/hydrogen][MOLES] -= burned_fuel / HYDROGEN_BURN_H2_FACTOR
		cached_gases[/datum/gas/oxygen][MOLES] -= burned_fuel
		ASSERT_GAS(/datum/gas/water_vapor, air)
		cached_gases[/datum/gas/water_vapor][MOLES] += burned_fuel / HYDROGEN_BURN_H2_FACTOR

	air.reaction_results["fire"] += burned_fuel * fire_scale

	var/energy_released = FIRE_HYDROGEN_ENERGY_RELEASED * burned_fuel * fire_scale
	if(energy_released > 0)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.temperature = (temperature * old_heat_capacity + energy_released) / new_heat_capacity

	//let the floor know a fire is happening
	var/turf/open/location = holder
	if(istype(location))
		temperature = air.temperature
		if(temperature > FIRE_MINIMUM_TEMPERATURE_TO_EXIST)
			location.hotspot_expose(temperature, CELL_VOLUME)

	return burned_fuel ? REACTING : NO_REACTION


/**
 * Tritium combustion:
 *
 * Combustion of oxygen and tritium (treated as hydrogen).
 * Highly exothermic.
 * Creates hotspots.
 * Creates radiation.
 */
/datum/gas_reaction/tritfire
	priority_group = PRIORITY_FIRE
	name = "Tritium Combustion"
	id = "tritfire"

/datum/gas_reaction/tritfire/init_reqs()
	requirements = list(
		/datum/gas/tritium = MINIMUM_MOLE_COUNT,
		/datum/gas/oxygen = MINIMUM_MOLE_COUNT,
		"MIN_TEMP" = FIRE_MINIMUM_TEMPERATURE_TO_EXIST,
	)

/datum/gas_reaction/tritfire/react(datum/gas_mixture/air, datum/holder)
	var/list/cached_gases = air.gases //this speeds things up because accessing datum vars is slow
	var/old_heat_capacity = air.heat_capacity()
	var/temperature = air.temperature

	var/burned_fuel
	var/effect_scale
	if(cached_gases[/datum/gas/oxygen][MOLES] < cached_gases[/datum/gas/tritium][MOLES] || MINIMUM_TRITIUM_OXYBURN_ENERGY > (temperature * old_heat_capacity))
		burned_fuel = cached_gases[/datum/gas/oxygen][MOLES] / TRITIUM_BURN_OXY_FACTOR // const must be at least one
		effect_scale = 1

		cached_gases[/datum/gas/tritium][MOLES] -= burned_fuel
		ASSERT_GAS(/datum/gas/water_vapor, air)
		cached_gases[/datum/gas/water_vapor][MOLES] += burned_fuel / TRITIUM_BURN_OXY_FACTOR
	else
		burned_fuel = cached_gases[/datum/gas/tritium][MOLES]
		effect_scale = TRITIUM_OXYBURN_MULTIPLIER

		cached_gases[/datum/gas/tritium][MOLES] -= burned_fuel / TRITIUM_BURN_TRIT_FACTOR
		cached_gases[/datum/gas/oxygen][MOLES] -= burned_fuel
		ASSERT_GAS(/datum/gas/water_vapor, air)
		cached_gases[/datum/gas/water_vapor][MOLES] += burned_fuel / TRITIUM_BURN_TRIT_FACTOR


	air.reaction_results["fire"] += burned_fuel * effect_scale

	var/turf/open/location
	if(istype(holder, /datum/pipeline)) //Find the tile the reaction is occuring on, or a random part of the network if it's a pipenet.
		var/datum/pipeline/pipenet = holder
		location = pick(pipenet.members)
	else if(isatom(holder))
		location = holder

	if(location && burned_fuel > TRITIUM_RADIATION_MINIMUM_MOLES && prob(10))
		radiation_pulse(location, max_range = min(sqrt(burned_fuel * effect_scale) / TRITIUM_RADIATION_RANGE_DIVISOR, 20), threshold = TRITIUM_RADIATION_THRESHOLD_BASE * INVERSE(TRITIUM_RADIATION_THRESHOLD_BASE + (burned_fuel * effect_scale)), chance = 50)

	var/energy_released = FIRE_TRITIUM_ENERGY_RELEASED * burned_fuel * effect_scale
	if(energy_released > 0)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.temperature = (temperature * old_heat_capacity + energy_released) / new_heat_capacity

	//let the floor know a fire is happening
	if(istype(location))
		temperature = air.temperature
		if(temperature > FIRE_MINIMUM_TEMPERATURE_TO_EXIST)
			location.hotspot_expose(temperature, CELL_VOLUME)

	return burned_fuel ? REACTING : NO_REACTION



/**
 * Freon combustion:
 *
 * Combustion of oxygen and freon.
 * Endothermic.
 */
/datum/gas_reaction/freonfire
	priority_group = PRIORITY_FIRE
	name = "Freon combustion"
	id = "freonfire"

/datum/gas_reaction/freonfire/init_reqs()
	requirements = list(
		/datum/gas/oxygen = MINIMUM_MOLE_COUNT,
		/datum/gas/freon = MINIMUM_MOLE_COUNT,
		"MIN_TEMP" = FREON_LOWER_TEMPERATURE,
		"MAX_TEMP" = FREON_MAXIMUM_BURN_TEMPERATURE,
	)

/datum/gas_reaction/freonfire/react(datum/gas_mixture/air, datum/holder)
	if(!isturf(holder))
		return NO_REACTION

	var/temperature = air.temperature
	var/temperature_scale
	if(temperature < FREON_LOWER_TEMPERATURE) //stop the reaction when too cold
		temperature_scale = 0
	else
		temperature_scale = (FREON_MAXIMUM_BURN_TEMPERATURE - temperature) / (FREON_MAXIMUM_BURN_TEMPERATURE - FREON_LOWER_TEMPERATURE) //calculate the scale based on the temperature
	if (temperature_scale <= 0)
		return NO_REACTION

	var/oxygen_burn_ratio = OXYGEN_BURN_RATIO_BASE - temperature_scale
	var/freon_burn_rate
	var/list/cached_gases = air.gases
	if(cached_gases[/datum/gas/oxygen][MOLES] < cached_gases[/datum/gas/freon][MOLES] * FREON_OXYGEN_FULLBURN)
		freon_burn_rate = (cached_gases[/datum/gas/freon][MOLES] / FREON_BURN_RATE_DELTA) * temperature_scale
	else
		freon_burn_rate = ((cached_gases[/datum/gas/oxygen][MOLES] / FREON_OXYGEN_FULLBURN) / FREON_BURN_RATE_DELTA) * temperature_scale

	if (freon_burn_rate < MINIMUM_HEAT_CAPACITY)
		return NO_REACTION

	var/old_heat_capacity = air.heat_capacity()
	freon_burn_rate = min(freon_burn_rate, cached_gases[/datum/gas/freon][MOLES], cached_gases[/datum/gas/oxygen][MOLES] * INVERSE(oxygen_burn_ratio)) //Ensures matter is conserved properly
	cached_gases[/datum/gas/freon][MOLES] = QUANTIZE(cached_gases[/datum/gas/freon][MOLES] - freon_burn_rate)
	cached_gases[/datum/gas/oxygen][MOLES] = QUANTIZE(cached_gases[/datum/gas/oxygen][MOLES] - (freon_burn_rate * oxygen_burn_ratio))
	ASSERT_GAS(/datum/gas/carbon_dioxide, air)
	cached_gases[/datum/gas/carbon_dioxide][MOLES] += freon_burn_rate

	if(temperature < HOT_ICE_FORMATION_MAXIMUM_TEMPERATURE && temperature > HOT_ICE_FORMATION_MINIMUM_TEMPERATURE && prob(HOT_ICE_FORMATION_PROB))
		new /obj/item/stack/sheet/hot_ice(holder)

	var/energy_consumed = FIRE_FREON_ENERGY_CONSUMED * freon_burn_rate
	var/new_heat_capacity = air.heat_capacity()
	if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
		air.temperature = (temperature * old_heat_capacity - energy_consumed) / new_heat_capacity

	return REACTING


// N2O

/**
 * Nitrous oxide Formation:
 *
 * Formation of N2O.
 * Endothermic.
 * Requires BZ as a catalyst.
 */
/datum/gas_reaction/nitrousformation //formationn of n2o, exothermic, requires bz as catalyst
	priority_group = PRIORITY_FORMATION
	name = "Nitrous Oxide formation"
	id = "nitrousformation"

/datum/gas_reaction/nitrousformation/init_reqs()
	requirements = list(
		/datum/gas/oxygen = 10,
		/datum/gas/nitrogen = 20,
		/datum/gas/bz = 5,
		"MIN_TEMP" = N2O_FORMATION_MIN_TEMPERATURE,
		"MAX_TEMP" = N2O_FORMATION_MAX_TEMPERATURE,
	)

/datum/gas_reaction/nitrousformation/react(datum/gas_mixture/air)
	var/list/cached_gases = air.gases
	var/heat_efficency = min(cached_gases[/datum/gas/oxygen][MOLES], cached_gases[/datum/gas/nitrogen][MOLES] * INVERSE(2))
	if ((cached_gases[/datum/gas/oxygen][MOLES] - heat_efficency < 0 ) || (cached_gases[/datum/gas/nitrogen][MOLES] - heat_efficency * 2 < 0))
		return NO_REACTION // Shouldn't produce gas from nothing.

	var/old_heat_capacity = air.heat_capacity()
	cached_gases[/datum/gas/oxygen][MOLES] -= heat_efficency
	cached_gases[/datum/gas/nitrogen][MOLES] -= heat_efficency * 2
	ASSERT_GAS(/datum/gas/nitrous_oxide, air)
	cached_gases[/datum/gas/nitrous_oxide][MOLES] += heat_efficency

	var/energy_used = heat_efficency * N2O_FORMATION_ENERGY
	var/new_heat_capacity = air.heat_capacity()
	if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
		air.temperature = max(((air.temperature * old_heat_capacity + energy_used) / new_heat_capacity), TCMB) // The air cools down when reacting.
	return REACTING


/**
 * Nitrous Oxide Decomposition
 *
 * Decomposition of N2O.
 * Exothermic.
 */
/datum/gas_reaction/nitrous_decomp
	priority_group = PRIORITY_POST_FORMATION
	name = "Nitrous Oxide Decomposition"
	id = "nitrous_decomp"

/datum/gas_reaction/nitrous_decomp/init_reqs()
	requirements = list(
		/datum/gas/nitrous_oxide = MINIMUM_MOLE_COUNT * 2,
		"MIN_TEMP" = N2O_DECOMPOSITION_MIN_TEMPERATURE,
		"MAX_TEMP" = N2O_DECOMPOSITION_MAX_TEMPERATURE,
	)

/datum/gas_reaction/nitrous_decomp/react(datum/gas_mixture/air, datum/holder)
	var/list/cached_gases = air.gases //this speeds things up because accessing datum vars is slow
	var/temperature = air.temperature
	var/burned_fuel = (cached_gases[/datum/gas/nitrous_oxide][MOLES] / N2O_DECOMPOSITION_RATE_DIVISOR) * ((temperature - N2O_DECOMPOSITION_MIN_SCALE_TEMP) * (temperature - N2O_DECOMPOSITION_MAX_SCALE_TEMP) / (N2O_DECOMPOSITION_SCALE_DIVISOR))
	if(burned_fuel <= 0)
		return NO_REACTION
	if(cached_gases[/datum/gas/nitrous_oxide][MOLES] - burned_fuel < 0)
		return NO_REACTION

	var/old_heat_capacity = air.heat_capacity()
	cached_gases[/datum/gas/nitrous_oxide][MOLES] -= burned_fuel
	ASSERT_GAS(/datum/gas/nitrogen, air)
	cached_gases[/datum/gas/nitrogen][MOLES] += burned_fuel
	ASSERT_GAS(/datum/gas/oxygen, air)
	cached_gases[/datum/gas/oxygen][MOLES] += burned_fuel / 2

	var/energy_released = N2O_DECOMPOSITION_ENERGY * burned_fuel
	var/new_heat_capacity = air.heat_capacity()
	if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
		air.temperature = (temperature * old_heat_capacity + energy_released) / new_heat_capacity
	return REACTING


// BZ

/**
 * BZ Formation
 *
 * Formation of BZ by combining plasma and nitrous oxide at low pressures.
 * Exothermic.
 */
/datum/gas_reaction/bzformation
	priority_group = PRIORITY_FORMATION
	name = "BZ Gas formation"
	id = "bzformation"

/datum/gas_reaction/bzformation/init_reqs()
	requirements = list(
		/datum/gas/nitrous_oxide = 10,
		/datum/gas/plasma = 10,
	)

/datum/gas_reaction/bzformation/react(datum/gas_mixture/air)
	var/list/cached_gases = air.gases
	var/pressure = air.return_pressure()
	var/reaction_efficency = min(1 / ((pressure / (0.1 * ONE_ATMOSPHERE)) * (max(cached_gases[/datum/gas/plasma][MOLES] / cached_gases[/datum/gas/nitrous_oxide][MOLES], 1))), cached_gases[/datum/gas/nitrous_oxide][MOLES], cached_gases[/datum/gas/plasma][MOLES] * INVERSE(2))

	if ((cached_gases[/datum/gas/nitrous_oxide][MOLES] - reaction_efficency < 0 )|| (cached_gases[/datum/gas/plasma][MOLES] - (2 * reaction_efficency) < 0) || reaction_efficency <= 0) //Shouldn't produce gas from nothing.
		return NO_REACTION

	var/old_heat_capacity = air.heat_capacity()
	ASSERT_GAS(/datum/gas/bz, air)
	if (reaction_efficency == cached_gases[/datum/gas/nitrous_oxide][MOLES])
		ASSERT_GAS(/datum/gas/oxygen, air)
		cached_gases[/datum/gas/bz][MOLES] += (reaction_efficency * 2.5) - min(pressure, 0.5)
		cached_gases[/datum/gas/oxygen][MOLES] += min(pressure, 0.5)
	else
		cached_gases[/datum/gas/bz][MOLES] += reaction_efficency * 2.5

	cached_gases[/datum/gas/nitrous_oxide][MOLES] -= reaction_efficency
	cached_gases[/datum/gas/plasma][MOLES] -= 2 * reaction_efficency

	var/energy_released = 2 * reaction_efficency * FIRE_CARBON_ENERGY_RELEASED
	var/new_heat_capacity = air.heat_capacity()
	if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
		air.temperature = max(((air.temperature * old_heat_capacity + energy_released) / new_heat_capacity), TCMB)
	return REACTING


// Pluoxium

/**
 * Pluoxium Formation:
 *
 * Consumes a tiny amount of tritium to convert CO2 and oxygen to pluoxium.
 * Exothermic.
 */
/datum/gas_reaction/pluox_formation
	priority_group = PRIORITY_FORMATION
	name = "Pluoxium formation"
	id = "pluox_formation"

/datum/gas_reaction/pluox_formation/init_reqs()
	requirements = list(
		/datum/gas/carbon_dioxide = MINIMUM_MOLE_COUNT,
		/datum/gas/oxygen = MINIMUM_MOLE_COUNT,
		/datum/gas/tritium = MINIMUM_MOLE_COUNT,
		"MIN_TEMP" = PLUOXIUM_FORMATION_MIN_TEMP,
		"MAX_TEMP" = PLUOXIUM_FORMATION_MAX_TEMP,
	)

/datum/gas_reaction/pluox_formation/react(datum/gas_mixture/air, datum/holder)
	var/list/cached_gases = air.gases
	var/produced_amount = min(PLUOXIUM_FORMATION_MAX_RATE, cached_gases[/datum/gas/carbon_dioxide][MOLES], cached_gases[/datum/gas/oxygen][MOLES] * INVERSE(0.5), cached_gases[/datum/gas/tritium][MOLES] * INVERSE(0.01))
	if (produced_amount <= 0 || cached_gases[/datum/gas/carbon_dioxide][MOLES] - produced_amount < 0 || cached_gases[/datum/gas/oxygen][MOLES] - produced_amount * 0.5 < 0 || cached_gases[/datum/gas/tritium][MOLES] - produced_amount * 0.01 < 0)
		return NO_REACTION

	var/old_heat_capacity = air.heat_capacity()
	cached_gases[/datum/gas/carbon_dioxide][MOLES] -= produced_amount
	cached_gases[/datum/gas/oxygen][MOLES] -= produced_amount * 0.5
	cached_gases[/datum/gas/tritium][MOLES] -= produced_amount * 0.01
	ASSERT_GAS(/datum/gas/pluoxium, air)
	cached_gases[/datum/gas/pluoxium][MOLES] += produced_amount
	ASSERT_GAS(/datum/gas/hydrogen, air)
	cached_gases[/datum/gas/hydrogen][MOLES] += produced_amount * 0.01

	var/energy_released = produced_amount * PLUOXIUM_FORMATION_ENERGY
	var/new_heat_capacity = air.heat_capacity()
	if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
		air.temperature = max((air.temperature * old_heat_capacity + energy_released) / new_heat_capacity, TCMB)
	return REACTING


// Nitrium

/**
 * Nitrium Formation:
 *
 * The formation of nitrium.
 * Endothermic.
 * Requires BZ.
 */
/datum/gas_reaction/nitrium_formation
	priority_group = PRIORITY_FORMATION
	name = "Nitrium formation"
	id = "nitrium_formation"

/datum/gas_reaction/nitrium_formation/init_reqs()
	requirements = list(
		/datum/gas/tritium = 20,
		/datum/gas/nitrogen = 10,
		/datum/gas/bz = 5,
		"MIN_TEMP" = NITRIUM_FORMATION_MIN_TEMP,
	)

/datum/gas_reaction/nitrium_formation/react(datum/gas_mixture/air)
	var/list/cached_gases = air.gases
	var/temperature = air.temperature
	var/heat_efficency = min(temperature / NITRIUM_FORMATION_TEMP_DIVISOR, cached_gases[/datum/gas/tritium][MOLES], cached_gases[/datum/gas/nitrogen][MOLES], cached_gases[/datum/gas/bz][MOLES] * INVERSE(0.05))

	if( heat_efficency <= 0 || (cached_gases[/datum/gas/tritium][MOLES] - heat_efficency < 0 ) || (cached_gases[/datum/gas/nitrogen][MOLES] - heat_efficency < 0) || (cached_gases[/datum/gas/bz][MOLES] - heat_efficency * 0.05 < 0)) //Shouldn't produce gas from nothing.
		return NO_REACTION

	var/old_heat_capacity = air.heat_capacity()
	ASSERT_GAS(/datum/gas/nitrium, air)
	cached_gases[/datum/gas/tritium][MOLES] -= heat_efficency
	cached_gases[/datum/gas/nitrogen][MOLES] -= heat_efficency
	cached_gases[/datum/gas/bz][MOLES] -= heat_efficency * 0.05 //bz gets consumed to balance the nitrium production and not make it too common and/or easy
	cached_gases[/datum/gas/nitrium][MOLES] += heat_efficency

	var/energy_used = heat_efficency * NITRIUM_FORMATION_ENERGY
	var/new_heat_capacity = air.heat_capacity()
	if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
		air.temperature = max(((temperature * old_heat_capacity - energy_used) / new_heat_capacity), TCMB) //the air cools down when reacting
	return REACTING


/**
 * Nitrium Decomposition:
 *
 * The decomposition of nitrium.
 * Exothermic.
 * Requires oxygen as catalyst.
 */
/datum/gas_reaction/nitrium_decomposition
	priority_group = PRIORITY_PRE_FORMATION
	name = "Nitrium Decomposition"
	id = "nitrium_decomp"

/datum/gas_reaction/nitrium_decomposition/init_reqs()
	requirements = list(
		/datum/gas/oxygen = MINIMUM_MOLE_COUNT,
		/datum/gas/nitrium = MINIMUM_MOLE_COUNT,
		"MAX_TEMP" = NITRIUM_DECOMPOSITION_MAX_TEMP
	)

/datum/gas_reaction/nitrium_decomposition/react(datum/gas_mixture/air)
	var/list/cached_gases = air.gases
	var/temperature = air.temperature

	//This reaction is agressively slow. like, a tenth of a mole per fire slow. Keep that in mind
	var/heat_efficency = min(temperature / NITRIUM_DECOMPOSITION_TEMP_DIVISOR, cached_gases[/datum/gas/nitrium][MOLES])

	if (heat_efficency <= 0 || (cached_gases[/datum/gas/nitrium][MOLES] - heat_efficency < 0)) //Shouldn't produce gas from nothing.
		return NO_REACTION

	var/old_heat_capacity = air.heat_capacity()
	air.assert_gases(/datum/gas/nitrogen, /datum/gas/hydrogen)
	cached_gases[/datum/gas/nitrium][MOLES] -= heat_efficency
	cached_gases[/datum/gas/hydrogen][MOLES] += heat_efficency
	cached_gases[/datum/gas/nitrogen][MOLES] += heat_efficency

	var/energy_produced = heat_efficency * NITRIUM_DECOMPOSITION_ENERGY
	var/new_heat_capacity = air.heat_capacity()
	if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
		air.temperature = max(((temperature * old_heat_capacity + energy_produced) / new_heat_capacity), TCMB) //the air heats up when reacting
	return REACTING


/**
 * Freon formation:
 *
 * The formation of freon.
 * Endothermic.
 */
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
	var/heat_efficency = min(temperature / FREON_FORMATION_TEMP_DIVISOR, cached_gases[/datum/gas/plasma][MOLES] * INVERSE(1.5), cached_gases[/datum/gas/carbon_dioxide][MOLES] * INVERSE(0.75), cached_gases[/datum/gas/bz][MOLES] * INVERSE(0.25))
	if (heat_efficency <= 0 || (cached_gases[/datum/gas/plasma][MOLES] - heat_efficency * 1.5 < 0 ) || (cached_gases[/datum/gas/carbon_dioxide][MOLES] - heat_efficency * 0.75 < 0) || (cached_gases[/datum/gas/bz][MOLES] - heat_efficency * 0.25 < 0)) //Shouldn't produce gas from nothing.
		return NO_REACTION

	var/old_heat_capacity = air.heat_capacity()
	ASSERT_GAS(/datum/gas/freon, air)
	cached_gases[/datum/gas/plasma][MOLES] -= heat_efficency * 1.5 // 6
	cached_gases[/datum/gas/carbon_dioxide][MOLES] -= heat_efficency * 0.75 //  3
	cached_gases[/datum/gas/bz][MOLES] -= heat_efficency * 0.25 // 1
	cached_gases[/datum/gas/freon][MOLES] += heat_efficency * 2.5 // 10

	var/energy_used = heat_efficency * FREON_FORMATION_ENERGY
	var/new_heat_capacity = air.heat_capacity()
	if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
		air.temperature = max(((temperature * old_heat_capacity - energy_used)/new_heat_capacity), TCMB)
	return REACTING


/**
 * Hyper-Noblium Formation:
 *
 * Extremely exothermic.
 * Requires very low temperatures.
 * Due to its high mass, hyper-nobelium uses large amounts of nitrogen and tritium.
 * BZ can be used as a catalyst to make it less exothermic.
 */
/datum/gas_reaction/nobliumformation
	priority_group = PRIORITY_FORMATION
	name = "Hyper-Noblium condensation"
	id = "nobformation"

/datum/gas_reaction/nobliumformation/init_reqs()
	requirements = list(
		/datum/gas/nitrogen = 10,
		/datum/gas/tritium = 5,
		"MIN_TEMP" = NOBLIUM_FORMATION_MIN_TEMP,
		"MAX_TEMP" = NOBLIUM_FORMATION_MAX_TEMP,
	)

/datum/gas_reaction/nobliumformation/react(datum/gas_mixture/air)
	var/list/cached_gases = air.gases
	var/nob_formed = min((cached_gases[/datum/gas/nitrogen][MOLES] + cached_gases[/datum/gas/tritium][MOLES]) * 0.01, cached_gases[/datum/gas/tritium][MOLES] * INVERSE(5), cached_gases[/datum/gas/nitrogen][MOLES] * INVERSE(10))

	if (nob_formed <= 0 || (cached_gases[/datum/gas/tritium][MOLES] - 5 * nob_formed < 0) || (cached_gases[/datum/gas/nitrogen][MOLES] - 10 * nob_formed < 0))
		return NO_REACTION

	var/old_heat_capacity = air.heat_capacity()
	air.assert_gases(/datum/gas/hypernoblium, /datum/gas/bz)
	cached_gases[/datum/gas/tritium][MOLES] -= 5 * nob_formed
	cached_gases[/datum/gas/nitrogen][MOLES] -= 10 * nob_formed
	cached_gases[/datum/gas/hypernoblium][MOLES] += nob_formed // I'm not going to nitpick, but N20H10 feels like it should be an explosive more than anything.

	var/energy_produced = nob_formed * (NOBLIUM_FORMATION_ENERGY / (max(cached_gases[/datum/gas/bz][MOLES], 1)))
	var/new_heat_capacity = air.heat_capacity()
	if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
		air.temperature = max(((air.temperature * old_heat_capacity + energy_produced) / new_heat_capacity), TCMB)
	return REACTING


// Halon

/**
 * Halon Formation:
 *
 * Exothermic
 */
/datum/gas_reaction/halon_formation
	priority_group = PRIORITY_FORMATION
	name = "Halon formation"
	id = "halon_formation"

/datum/gas_reaction/halon_formation/init_reqs()
	requirements = list(
		/datum/gas/bz = MINIMUM_MOLE_COUNT,
		/datum/gas/tritium = MINIMUM_MOLE_COUNT,
		"MIN_TEMP" = HALON_FORMATION_MIN_TEMPERATURE,
		"MAX_TEMP" = HALON_FORMATION_MAX_TEMPERATURE,
	)

/datum/gas_reaction/halon_formation/react(datum/gas_mixture/air, datum/holder)
	var/list/cached_gases = air.gases
	var/temperature = air.temperature
	var/heat_efficency = min(temperature * 0.01, cached_gases[/datum/gas/tritium][MOLES] * INVERSE(4), cached_gases[/datum/gas/bz][MOLES] * INVERSE(0.25))
	if (heat_efficency <= 0 || (cached_gases[/datum/gas/tritium][MOLES] - heat_efficency * 4 < 0 ) || (cached_gases[/datum/gas/bz][MOLES] - heat_efficency * 0.25 < 0)) //Shouldn't produce gas from nothing.
		return NO_REACTION

	var/old_heat_capacity = air.heat_capacity()
	ASSERT_GAS(/datum/gas/halon, air)
	cached_gases[/datum/gas/tritium][MOLES] -= heat_efficency * 4
	cached_gases[/datum/gas/bz][MOLES] -= heat_efficency * 0.25
	cached_gases[/datum/gas/halon][MOLES] += heat_efficency * 4.25

	var/energy_used = heat_efficency * HALON_FORMATION_ENERGY
	var/new_heat_capacity = air.heat_capacity()
	if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
		air.temperature = max(((temperature * old_heat_capacity + energy_used) / new_heat_capacity), TCMB)
	return REACTING


/**
 * Halon Combustion:
 *
 * Consumes a large amount of oxygen relative to the amount of halon consumed.
 * Produces carbon dioxide.
 * Endothermic.
 */
/datum/gas_reaction/halon_o2removal
	priority_group = PRIORITY_PRE_FORMATION
	name = "Halon o2 removal"
	id = "halon_o2removal"

/datum/gas_reaction/halon_o2removal/init_reqs()
	requirements = list(
		/datum/gas/halon = MINIMUM_MOLE_COUNT,
		/datum/gas/oxygen = MINIMUM_MOLE_COUNT,
		"MIN_TEMP" = FIRE_MINIMUM_TEMPERATURE_TO_EXIST,
	)

/datum/gas_reaction/halon_o2removal/react(datum/gas_mixture/air, datum/holder)
	var/list/cached_gases = air.gases
	var/temperature = air.temperature

	var/heat_efficency = min(temperature / ( FIRE_MINIMUM_TEMPERATURE_TO_EXIST * 10), cached_gases[/datum/gas/halon][MOLES], cached_gases[/datum/gas/oxygen][MOLES] * INVERSE(20))
	if (heat_efficency <= 0 || (cached_gases[/datum/gas/halon][MOLES] - heat_efficency < 0 ) || (cached_gases[/datum/gas/oxygen][MOLES] - heat_efficency * 20 < 0)) //Shouldn't produce gas from nothing.
		return NO_REACTION

	var/old_heat_capacity = air.heat_capacity()
	ASSERT_GAS(/datum/gas/carbon_dioxide, air)
	cached_gases[/datum/gas/halon][MOLES] -= heat_efficency
	cached_gases[/datum/gas/oxygen][MOLES] -= heat_efficency * 20
	cached_gases[/datum/gas/carbon_dioxide][MOLES] += heat_efficency * 5

	var/energy_used = heat_efficency * HALON_COMBUSTION_ENERGY
	var/new_heat_capacity = air.heat_capacity()
	if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
		air.temperature = max(((temperature * old_heat_capacity - energy_used) / new_heat_capacity), TCMB)
	return REACTING


// Healium

/**
 * Healium Formation:
 *
 * Exothermic
 */
/datum/gas_reaction/healium_formation
	priority_group = PRIORITY_FORMATION
	name = "Healium formation"
	id = "healium_formation"

/datum/gas_reaction/healium_formation/init_reqs()
	requirements = list(
		/datum/gas/bz = MINIMUM_MOLE_COUNT,
		/datum/gas/freon = MINIMUM_MOLE_COUNT,
		"MIN_TEMP" = HEALIUM_FORMATION_MIN_TEMP,
		"MAX_TEMP" = HEALIUM_FORMATION_MAX_TEMP,
	)

/datum/gas_reaction/healium_formation/react(datum/gas_mixture/air, datum/holder)
	var/list/cached_gases = air.gases
	var/temperature = air.temperature
	var/heat_efficency = min(temperature * 0.3, cached_gases[/datum/gas/freon][MOLES] * INVERSE(2.75), cached_gases[/datum/gas/bz][MOLES] * INVERSE(0.25))
	if (heat_efficency <= 0 || (cached_gases[/datum/gas/freon][MOLES] - heat_efficency * 2.75 < 0 ) || (cached_gases[/datum/gas/bz][MOLES] - heat_efficency * 0.25 < 0)) //Shouldn't produce gas from nothing.
		return NO_REACTION

	var/old_heat_capacity = air.heat_capacity()
	ASSERT_GAS(/datum/gas/healium, air)
	cached_gases[/datum/gas/freon][MOLES] -= heat_efficency * 2.75
	cached_gases[/datum/gas/bz][MOLES] -= heat_efficency * 0.25
	cached_gases[/datum/gas/healium][MOLES] += heat_efficency * 3

	var/energy_used = heat_efficency * HEALIUM_FORMATION_ENERGY
	var/new_heat_capacity = air.heat_capacity()
	if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
		air.temperature = max(((temperature * old_heat_capacity + energy_used) / new_heat_capacity), TCMB)
	return REACTING

/**
 * Zauker Formation:
 *
 * Exothermic.
 * Requires Hypernoblium.
 */
/datum/gas_reaction/zauker_formation
	priority_group = PRIORITY_FORMATION
	name = "Zauker formation"
	id = "zauker_formation"

/datum/gas_reaction/zauker_formation/init_reqs()
	requirements = list(
		/datum/gas/hypernoblium = MINIMUM_MOLE_COUNT,
		/datum/gas/nitrium = MINIMUM_MOLE_COUNT,
		"MIN_TEMP" = ZAUKER_FORMATION_MIN_TEMPERATURE,
		"MAX_TEMP" = ZAUKER_FORMATION_MAX_TEMPERATURE,
	)

/datum/gas_reaction/zauker_formation/react(datum/gas_mixture/air, datum/holder)
	var/list/cached_gases = air.gases
	var/temperature = air.temperature

	var/heat_efficency = min(temperature * ZAUKER_FORMATION_TEMPERATURE_SCALE, cached_gases[/datum/gas/hypernoblium][MOLES] * INVERSE(0.01), cached_gases[/datum/gas/nitrium][MOLES] * INVERSE(0.5))
	if (heat_efficency <= 0 || (cached_gases[/datum/gas/hypernoblium][MOLES] - heat_efficency * 0.01 < 0 ) || (cached_gases[/datum/gas/nitrium][MOLES] - heat_efficency * 0.5 < 0)) //Shouldn't produce gas from nothing.
		return NO_REACTION

	var/old_heat_capacity = air.heat_capacity()
	ASSERT_GAS(/datum/gas/zauker, air)
	cached_gases[/datum/gas/hypernoblium][MOLES] -= heat_efficency * 0.01
	cached_gases[/datum/gas/nitrium][MOLES] -= heat_efficency * 0.5
	cached_gases[/datum/gas/zauker][MOLES] += heat_efficency * 0.5

	var/energy_used = heat_efficency * ZAUKER_FORMATION_ENERGY
	var/new_heat_capacity = air.heat_capacity()
	if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
		air.temperature = max(((temperature * old_heat_capacity - energy_used) / new_heat_capacity), TCMB)
	return REACTING


/**
 * Zauker Decomposition:
 *
 * Occurs in the presence of nitrogen to prevent zauker floods.
 * Exothermic.
 */
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
	var/list/cached_gases = air.gases //this speeds things up because accessing datum vars is slow
	var/burned_fuel = min(ZAUKER_DECOMPOSITION_MAX_RATE, cached_gases[/datum/gas/nitrogen][MOLES], cached_gases[/datum/gas/zauker][MOLES])
	if (burned_fuel <= 0 || cached_gases[/datum/gas/zauker][MOLES] - burned_fuel < 0)
		return NO_REACTION

	var/old_heat_capacity = air.heat_capacity()
	cached_gases[/datum/gas/zauker][MOLES] -= burned_fuel
	ASSERT_GAS(/datum/gas/oxygen, air)
	cached_gases[/datum/gas/oxygen][MOLES] += burned_fuel * 0.3
	ASSERT_GAS(/datum/gas/nitrogen, air)
	cached_gases[/datum/gas/nitrogen][MOLES] += burned_fuel * 0.7

	var/energy_released = ZAUKER_DECOMPOSITION_ENERGY * burned_fuel
	var/new_heat_capacity = air.heat_capacity()
	if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
		air.temperature = max((air.temperature * old_heat_capacity + energy_released) / new_heat_capacity, TCMB)
	return REACTING


// Proto-Nitrate

/**
 * Proto-Nitrate formation:
 *
 * Exothermic.
 */
/datum/gas_reaction/proto_nitrate_formation
	priority_group = PRIORITY_FORMATION
	name = "Proto Nitrate formation"
	id = "proto_nitrate_formation"

/datum/gas_reaction/proto_nitrate_formation/init_reqs()
	requirements = list(
		/datum/gas/pluoxium = MINIMUM_MOLE_COUNT,
		/datum/gas/hydrogen = MINIMUM_MOLE_COUNT,
		"MIN_TEMP" = PN_FORMATION_MIN_TEMPERATURE,
		"MAX_TEMP" = PN_FORMATION_MAX_TEMPERATURE,
	)

/datum/gas_reaction/proto_nitrate_formation/react(datum/gas_mixture/air, datum/holder)
	var/list/cached_gases = air.gases
	var/temperature = air.temperature

	var/heat_efficency = min(temperature * 0.005, cached_gases[/datum/gas/pluoxium][MOLES] * INVERSE(0.2), cached_gases[/datum/gas/hydrogen][MOLES] * INVERSE(2))
	if (heat_efficency <= 0 || (cached_gases[/datum/gas/pluoxium][MOLES] - heat_efficency * 0.2 < 0 ) || (cached_gases[/datum/gas/hydrogen][MOLES] - heat_efficency * 2 < 0)) //Shouldn't produce gas from nothing.
		return NO_REACTION

	var/old_heat_capacity = air.heat_capacity()
	ASSERT_GAS(/datum/gas/proto_nitrate, air)
	cached_gases[/datum/gas/hydrogen][MOLES] -= heat_efficency * 2
	cached_gases[/datum/gas/pluoxium][MOLES] -= heat_efficency * 0.2
	cached_gases[/datum/gas/proto_nitrate][MOLES] += heat_efficency * 2.2

	var/energy_used = heat_efficency * PN_FORMATION_ENERGY
	var/new_heat_capacity = air.heat_capacity()
	if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
		air.temperature = max(((temperature * old_heat_capacity + energy_used) / new_heat_capacity), TCMB)
	return REACTING

/**
 * Proto-Nitrate Hydrogen Conversion
 *
 * Converts hydrogen into proto-nitrate.
 * Endothermic.
 */
/datum/gas_reaction/proto_nitrate_hydrogen_response
	priority_group = PRIORITY_PRE_FORMATION
	name = "Proto Nitrate hydrogen response"
	id = "proto_nitrate_hydrogen_response"

/datum/gas_reaction/proto_nitrate_hydrogen_response/init_reqs()
	requirements = list(
		/datum/gas/proto_nitrate = MINIMUM_MOLE_COUNT,
		/datum/gas/hydrogen = PN_HYDROGEN_CONVERSION_THRESHOLD,
	)

/datum/gas_reaction/proto_nitrate_hydrogen_response/react(datum/gas_mixture/air, datum/holder)
	var/list/cached_gases = air.gases
	var/produced_amount = min(PN_HYDROGEN_CONVERSION_MAX_RATE, cached_gases[/datum/gas/hydrogen][MOLES], cached_gases[/datum/gas/proto_nitrate][MOLES])
	if (produced_amount <= 0 || cached_gases[/datum/gas/hydrogen][MOLES] - produced_amount < 0)
		return NO_REACTION

	var/old_heat_capacity = air.heat_capacity()
	cached_gases[/datum/gas/hydrogen][MOLES] -= produced_amount
	cached_gases[/datum/gas/proto_nitrate][MOLES] += produced_amount * 0.5

	var/energy_released = produced_amount * PN_HYDROGEN_CONVERSION_ENERGY
	var/new_heat_capacity = air.heat_capacity()
	if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
		air.temperature = max((air.temperature * old_heat_capacity - energy_released) / new_heat_capacity, TCMB)
	return REACTING

/**
 * Proto-Nitrate Tritium De-irradiation
 *
 * Converts tritium to hydrogen.
 * Releases radiation.
 * Exothermic.
 */
/datum/gas_reaction/proto_nitrate_tritium_response
	priority_group = PRIORITY_PRE_FORMATION
	name = "Proto Nitrate tritium response"
	id = "proto_nitrate_tritium_response"

/datum/gas_reaction/proto_nitrate_tritium_response/init_reqs()
	requirements = list(
		/datum/gas/proto_nitrate = MINIMUM_MOLE_COUNT,
		/datum/gas/tritium = MINIMUM_MOLE_COUNT,
		"MIN_TEMP" = PN_TRITIUM_CONVERSION_MIN_TEMP,
		"MAX_TEMP" = PN_TRITIUM_CONVERSION_MAX_TEMP,
	)

/datum/gas_reaction/proto_nitrate_tritium_response/react(datum/gas_mixture/air, datum/holder)
	var/list/cached_gases = air.gases
	var/temperature = air.temperature
	var/produced_amount = min(air.temperature / 34 * (cached_gases[/datum/gas/tritium][MOLES] * cached_gases[/datum/gas/proto_nitrate][MOLES]) / (cached_gases[/datum/gas/tritium][MOLES] + 10 * cached_gases[/datum/gas/proto_nitrate][MOLES]), cached_gases[/datum/gas/tritium][MOLES], cached_gases[/datum/gas/proto_nitrate][MOLES] * INVERSE(0.01))
	if(cached_gases[/datum/gas/tritium][MOLES] - produced_amount < 0 || cached_gases[/datum/gas/proto_nitrate][MOLES] - produced_amount * 0.01 < 0)
		return NO_REACTION

	var/old_heat_capacity = air.heat_capacity()
	cached_gases[/datum/gas/proto_nitrate][MOLES] -= produced_amount * 0.01
	cached_gases[/datum/gas/tritium][MOLES] -= produced_amount
	ASSERT_GAS(/datum/gas/hydrogen, air)
	cached_gases[/datum/gas/hydrogen][MOLES] += produced_amount

	var/turf/open/location
	if(istype(holder,/datum/pipeline)) //Find the tile the reaction is occuring on, or a random part of the network if it's a pipenet.
		var/datum/pipeline/pipenet = holder
		location = pick(pipenet.members)
	else if(isatom(holder))
		location = holder
	if (location)
		radiation_pulse(location, max_range = min(sqrt(produced_amount) / PN_TRITIUM_RAD_RANGE_DIVISOR, 20), threshold = PN_TRITIUM_RAD_THRESHOLD_BASE * INVERSE(PN_TRITIUM_RAD_THRESHOLD_BASE + produced_amount), chance = 50)

	var/energy_released = produced_amount * PN_TRITIUM_CONVERSION_ENERGY
	if(energy_released)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.temperature = max((temperature * old_heat_capacity + energy_released) / new_heat_capacity, TCMB)
	return REACTING

/**
 * Proto-Nitrate BZase Action
 *
 * Breaks BZ down into nitrogen, helium, and plasma in the presence of proto-nitrate.
 */
/datum/gas_reaction/proto_nitrate_bz_response
	priority_group = PRIORITY_PRE_FORMATION
	name = "Proto Nitrate bz response"
	id = "proto_nitrate_bz_response"

/datum/gas_reaction/proto_nitrate_bz_response/init_reqs()
	requirements = list(
		/datum/gas/proto_nitrate = MINIMUM_MOLE_COUNT,
		/datum/gas/bz = MINIMUM_MOLE_COUNT,
		"MIN_TEMP" = PN_BZASE_MIN_TEMP,
		"MAX_TEMP" = PN_BZASE_MAX_TEMP,
	)

/datum/gas_reaction/proto_nitrate_bz_response/react(datum/gas_mixture/air, datum/holder)
	var/list/cached_gases = air.gases
	var/temperature = air.temperature
	var/consumed_amount = min(air.temperature / 2240 * cached_gases[/datum/gas/bz][MOLES] * cached_gases[/datum/gas/proto_nitrate][MOLES] / (cached_gases[/datum/gas/bz][MOLES] + cached_gases[/datum/gas/proto_nitrate][MOLES]), cached_gases[/datum/gas/bz][MOLES], cached_gases[/datum/gas/proto_nitrate][MOLES])
	if (consumed_amount <= 0 || cached_gases[/datum/gas/bz][MOLES] - consumed_amount < 0)
		return NO_REACTION

	var/old_heat_capacity = air.heat_capacity()
	cached_gases[/datum/gas/bz][MOLES] -= consumed_amount
	ASSERT_GAS(/datum/gas/nitrogen, air)
	cached_gases[/datum/gas/nitrogen][MOLES] += consumed_amount * 0.4
	ASSERT_GAS(/datum/gas/helium, air)
	cached_gases[/datum/gas/helium][MOLES] += consumed_amount * 1.6
	ASSERT_GAS(/datum/gas/plasma, air)
	cached_gases[/datum/gas/plasma][MOLES] += consumed_amount * 0.8

	var/turf/open/location
	if(istype(holder,/datum/pipeline)) //Find the tile the reaction is occuring on, or a random part of the network if it's a pipenet.
		var/datum/pipeline/pipenet = holder
		location = pick(pipenet.members)
	else if(isatom(holder))
		location = holder
	if (location)
		radiation_pulse(location, max_range = min(sqrt(consumed_amount) / PN_BZASE_RAD_RANGE_DIVISOR, 20), threshold = PN_BZASE_RAD_THRESHOLD_BASE * INVERSE(PN_BZASE_RAD_THRESHOLD_BASE + consumed_amount), chance = 50)
		for(var/mob/living/carbon/L in location)
			L.hallucination += consumed_amount

	var/energy_released = consumed_amount * PN_BZASE_ENERGY
	var/new_heat_capacity = air.heat_capacity()
	if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
		air.temperature = max((temperature * old_heat_capacity + energy_released) / new_heat_capacity, TCMB)
	return REACTING
