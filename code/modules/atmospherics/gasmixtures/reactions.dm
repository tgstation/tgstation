//Most other defines used in reactions are located in ..\__DEFINES\reactions.dm
#define SET_REACTION_RESULTS(amount) air.reaction_results[type] = amount

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
	/// Whether the presence of our reaction should make fires bigger or not.
	var/expands_hotspot = FALSE
	/// A short string describing this reaction.
	var/desc
	/** REACTION FACTORS
	 *
	 * Describe (to a human) factors influencing this reaction in an assoc list format.
	 * Also include gases formed by the reaction
	 * Implement various interaction for different keys under subsystem/air/proc/atmos_handbook_init()
	 *
	 * E.G.
	 * factor["Temperature"] = "Minimum temperature of 20 kelvins, maximum temperature of 100 kelvins"
	 * factor[GAS_O2] = "Minimum oxygen amount of 20 moles, more oxygen increases reaction rate up to 150 moles"
	 */
	var/list/factor

/datum/gas_reaction/New()
	init_reqs()
	init_factors()

/datum/gas_reaction/proc/init_reqs() // Override this
	CRASH("Reaction [type] made without specifying requirements.")

/datum/gas_reaction/proc/init_factors()

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
	name = "Water Vapor Condensation"
	id = "vapor"
	desc = "Water vapor condensation that can make things slippery."

/datum/gas_reaction/water_vapor/init_reqs()
	requirements = list(
		/datum/gas/water_vapor = MOLES_GAS_VISIBLE,
		"MAX_TEMP" = WATER_VAPOR_CONDENSATION_POINT,
	)

/datum/gas_reaction/water_vapor/react(datum/gas_mixture/air, datum/holder)
	. = NO_REACTION
	if(!isturf(holder))
		return

	var/turf/open/location = holder
	var/consumed = 0
	switch(air.temperature)
		if(-INFINITY to WATER_VAPOR_DEPOSITION_POINT)
			if(location?.freeze_turf())
				consumed = MOLES_GAS_VISIBLE
		if(WATER_VAPOR_DEPOSITION_POINT to WATER_VAPOR_CONDENSATION_POINT)
			location.water_vapor_gas_act()
			consumed = MOLES_GAS_VISIBLE

	if(consumed)
		var/list/water_vapour = air.gases[/datum/gas/water_vapor]
		water_vapour[MOLES] -= consumed
		air.heat_capacity -= consumed * water_vapour[GAS_META][META_GAS_SPECIFIC_HEAT]
		SET_REACTION_RESULTS(consumed)
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
	desc = "Pathogens cannot survive in a hot environment. Miasma decomposes on high temperature."

/datum/gas_reaction/miaster/init_reqs()
	requirements = list(
		/datum/gas/miasma = MINIMUM_MOLE_COUNT,
		"MIN_TEMP" = MIASTER_STERILIZATION_TEMP,
	)

/datum/gas_reaction/miaster/react(datum/gas_mixture/air, datum/holder)
	var/list/cached_gases = air.gases
	var/temperature = air.temperature
	// As the name says it, it needs to be dry
	if(cached_gases[/datum/gas/water_vapor] && cached_gases[/datum/gas/water_vapor][MOLES] / air.total_moles() > MIASTER_STERILIZATION_MAX_HUMIDITY)
		return NO_REACTION

	var/list/miasma = cached_gases[/datum/gas/miasma]
	//Replace miasma with oxygen
	var/cleaned_air = min(miasma[MOLES], MIASTER_STERILIZATION_RATE_BASE + (temperature - MIASTER_STERILIZATION_TEMP) / MIASTER_STERILIZATION_RATE_SCALE)
	miasma[MOLES] -= cleaned_air
	ASSERT_GAS(/datum/gas/oxygen, air)
	var/list/oxygen = cached_gases[/datum/gas/oxygen]
	oxygen[MOLES] += cleaned_air

	air.heat_capacity += (oxygen[GAS_META][META_GAS_SPECIFIC_HEAT] - miasma[GAS_META][META_GAS_SPECIFIC_HEAT]) * cleaned_air

	//Possibly burning a bit of organic matter through maillard reaction, so a *tiny* bit more heat would be understandable
	air.temperature += cleaned_air * MIASTER_STERILIZATION_ENERGY
	SET_REACTION_RESULTS(cleaned_air)

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
	expands_hotspot = TRUE
	desc = "Combustion of oxygen and plasma. Able to produce tritium or carbon dioxade and water vapor."

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
	var/list/plasma = cached_gases[/datum/gas/plasma]
	var/list/oxygen = cached_gases[/datum/gas/oxygen]
	switch(oxygen[MOLES] / plasma[MOLES])
		if(SUPER_SATURATION_THRESHOLD to INFINITY)
			plasma_burn_rate = (plasma[MOLES] / PLASMA_BURN_RATE_DELTA) * temperature_scale
			super_saturation = TRUE // Begin to form tritium
		if(PLASMA_OXYGEN_FULLBURN to SUPER_SATURATION_THRESHOLD)
			plasma_burn_rate = (plasma[MOLES] / PLASMA_BURN_RATE_DELTA) * temperature_scale
		else
			plasma_burn_rate = ((oxygen[MOLES] / PLASMA_OXYGEN_FULLBURN) / PLASMA_BURN_RATE_DELTA) * temperature_scale

	if(plasma_burn_rate < MINIMUM_HEAT_CAPACITY)
		return NO_REACTION

	var/old_heat_capacity = air.heat_capacity
	plasma_burn_rate = min(plasma_burn_rate, plasma[MOLES], oxygen[MOLES] * INVERSE(oxygen_burn_ratio)) //Ensures matter is conserved properly
	plasma[MOLES] = QUANTIZE(plasma[MOLES] - plasma_burn_rate)
	oxygen[MOLES] = QUANTIZE(oxygen[MOLES] - (plasma_burn_rate * oxygen_burn_ratio))
	if (super_saturation)
		ASSERT_GAS(/datum/gas/tritium, air)
		var/list/tritium = cached_gases[/datum/gas/tritium]
		tritium[MOLES] += plasma_burn_rate
		air.heat_capacity += plasma_burn_rate * (tritium[GAS_META][META_GAS_SPECIFIC_HEAT] - plasma[GAS_META][META_GAS_SPECIFIC_HEAT] - oxygen[GAS_META][META_GAS_SPECIFIC_HEAT] * oxygen_burn_ratio)
	else
		ASSERT_GAS(/datum/gas/carbon_dioxide, air)
		ASSERT_GAS(/datum/gas/water_vapor, air)
		var/list/carbon_dioxide = cached_gases[/datum/gas/carbon_dioxide]
		var/list/water_vapor = cached_gases[/datum/gas/water_vapor]
		carbon_dioxide[MOLES] += plasma_burn_rate * 0.75
		water_vapor[MOLES] += plasma_burn_rate * 0.25
		air.heat_capacity += plasma_burn_rate * (carbon_dioxide[GAS_META][META_GAS_SPECIFIC_HEAT] * 0.75 + water_vapor[GAS_META][META_GAS_SPECIFIC_HEAT] * 0.25 - plasma[GAS_META][META_GAS_SPECIFIC_HEAT] - oxygen[GAS_META][META_GAS_SPECIFIC_HEAT] * oxygen_burn_ratio)

	SET_REACTION_RESULTS((plasma_burn_rate) * (1 + oxygen_burn_ratio))
	var/energy_released = FIRE_PLASMA_ENERGY_RELEASED * plasma_burn_rate
	var/new_heat_capacity = air.heat_capacity
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
	expands_hotspot = TRUE
	desc = "Combustion of hydrogen with oxygen. Can be extremely fast and energetic if a few conditions are fulfilled."

/datum/gas_reaction/h2fire/init_reqs()
	requirements = list(
		/datum/gas/hydrogen = MINIMUM_MOLE_COUNT,
		/datum/gas/oxygen = MINIMUM_MOLE_COUNT,
		"MIN_TEMP" = HYDROGEN_MINIMUM_BURN_TEMPERATURE,
	)

/datum/gas_reaction/h2fire/react(datum/gas_mixture/air, datum/holder)
	var/list/cached_gases = air.gases //this speeds things up because accessing datum vars is slow
	var/old_heat_capacity = air.heat_capacity
	var/temperature = air.temperature
	var/list/hydrogen = cached_gases[/datum/gas/hydrogen]
	var/list/oxygen = cached_gases[/datum/gas/oxygen]

	var/burned_fuel = min(hydrogen[MOLES] / FIRE_HYDROGEN_BURN_RATE_DELTA, oxygen[MOLES] / (FIRE_HYDROGEN_BURN_RATE_DELTA * HYDROGEN_OXYGEN_FULLBURN), hydrogen[MOLES], oxygen[MOLES] * INVERSE(0.5))
	if(burned_fuel <= 0 || hydrogen[MOLES] - burned_fuel < 0 || oxygen[MOLES] - burned_fuel * 0.5 < 0) //Shouldn't produce gas from nothing.
		return NO_REACTION

	hydrogen[MOLES] -= burned_fuel
	oxygen[MOLES] -= burned_fuel * 0.5
	ASSERT_GAS(/datum/gas/water_vapor, air)
	var/list/water_vapor = cached_gases[/datum/gas/water_vapor]
	water_vapor[MOLES] += burned_fuel

	air.heat_capacity += burned_fuel * (water_vapor[GAS_META][META_GAS_SPECIFIC_HEAT] - oxygen[GAS_META][META_GAS_SPECIFIC_HEAT] * 0.5 - hydrogen[GAS_META][META_GAS_SPECIFIC_HEAT])

	SET_REACTION_RESULTS(burned_fuel)

	var/energy_released = FIRE_HYDROGEN_ENERGY_RELEASED * burned_fuel
	if(energy_released > 0)
		var/new_heat_capacity = air.heat_capacity
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
	expands_hotspot = TRUE
	desc = "Combustion of tritium with oxygen. Can be extremely fast and energetic if a few conditions are fulfilled."

/datum/gas_reaction/tritfire/init_reqs()
	requirements = list(
		/datum/gas/tritium = MINIMUM_MOLE_COUNT,
		/datum/gas/oxygen = MINIMUM_MOLE_COUNT,
		"MIN_TEMP" = TRITIUM_MINIMUM_BURN_TEMPERATURE,
	)

/datum/gas_reaction/tritfire/react(datum/gas_mixture/air, datum/holder)
	var/list/cached_gases = air.gases //this speeds things up because accessing datum vars is slow
	var/list/tritium = cached_gases[/datum/gas/tritium]
	var/list/oxygen = cached_gases[/datum/gas/oxygen]
	var/old_heat_capacity = air.heat_capacity
	var/temperature = air.temperature

	var/burned_fuel = min(tritium[MOLES] / FIRE_TRITIUM_BURN_RATE_DELTA, oxygen[MOLES] / (FIRE_TRITIUM_BURN_RATE_DELTA * TRITIUM_OXYGEN_FULLBURN), tritium[MOLES], oxygen[MOLES] * INVERSE(0.5))
	if(burned_fuel <= 0 || tritium[MOLES] - burned_fuel < 0 || oxygen[MOLES] - burned_fuel * 0.5 < 0) //Shouldn't produce gas from nothing.
		return NO_REACTION

	tritium[MOLES] -= burned_fuel
	oxygen[MOLES] -= burned_fuel * 0.5
	ASSERT_GAS(/datum/gas/water_vapor, air)
	var/list/water_vapor = cached_gases[/datum/gas/water_vapor]
	water_vapor[MOLES] += burned_fuel

	air.heat_capacity += burned_fuel * (water_vapor[GAS_META][META_GAS_SPECIFIC_HEAT] - oxygen[GAS_META][META_GAS_SPECIFIC_HEAT] * 0.5 - tritium[GAS_META][META_GAS_SPECIFIC_HEAT])

	SET_REACTION_RESULTS(burned_fuel)

	var/turf/open/location
	if(istype(holder, /datum/pipeline)) //Find the tile the reaction is occuring on, or a random part of the network if it's a pipenet.
		var/datum/pipeline/pipenet = holder
		location = pick(pipenet.members)
	else if(isatom(holder))
		location = holder

	var/energy_released = FIRE_TRITIUM_ENERGY_RELEASED * burned_fuel
	if(location && burned_fuel > TRITIUM_RADIATION_MINIMUM_MOLES && energy_released > TRITIUM_RADIATION_RELEASE_THRESHOLD * (air.volume / CELL_VOLUME) ** ATMOS_RADIATION_VOLUME_EXP && prob(10))
		radiation_pulse(location, max_range = min(sqrt(burned_fuel) / TRITIUM_RADIATION_RANGE_DIVISOR, GAS_REACTION_MAXIMUM_RADIATION_PULSE_RANGE), threshold = TRITIUM_RADIATION_THRESHOLD)

	if(energy_released > 0)
		var/new_heat_capacity = air.heat_capacity
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
	name = "Freon Combustion"
	id = "freonfire"
	expands_hotspot = TRUE
	desc = "Reaction between oxygen and freon that consumes a huge amount of energy and can cool things significantly. Also able to produce hot ice."

/datum/gas_reaction/freonfire/init_reqs()
	requirements = list(
		/datum/gas/oxygen = MINIMUM_MOLE_COUNT,
		/datum/gas/freon = MINIMUM_MOLE_COUNT,
		"MIN_TEMP" = FREON_TERMINAL_TEMPERATURE,
		"MAX_TEMP" = FREON_MAXIMUM_BURN_TEMPERATURE,
	)

/datum/gas_reaction/freonfire/react(datum/gas_mixture/air, datum/holder)
	var/temperature = air.temperature
	var/temperature_scale
	if(temperature < FREON_TERMINAL_TEMPERATURE) //stop the reaction when too cold
		temperature_scale = 0
	else if(temperature < FREON_LOWER_TEMPERATURE)
		temperature_scale = 0.5
	else
		temperature_scale = (FREON_MAXIMUM_BURN_TEMPERATURE - temperature) / (FREON_MAXIMUM_BURN_TEMPERATURE - FREON_TERMINAL_TEMPERATURE) //calculate the scale based on the temperature
	if (temperature_scale <= 0)
		return NO_REACTION

	var/oxygen_burn_ratio = OXYGEN_BURN_RATIO_BASE - temperature_scale
	var/freon_burn_rate
	var/list/cached_gases = air.gases
	var/list/oxygen = cached_gases[/datum/gas/oxygen]
	var/list/freon = cached_gases[/datum/gas/freon]
	if(oxygen[MOLES] < freon[MOLES] * FREON_OXYGEN_FULLBURN)
		freon_burn_rate = ((oxygen[MOLES] / FREON_OXYGEN_FULLBURN) / FREON_BURN_RATE_DELTA) * temperature_scale
	else
		freon_burn_rate = (freon[MOLES] / FREON_BURN_RATE_DELTA) * temperature_scale

	if (freon_burn_rate < MINIMUM_HEAT_CAPACITY)
		return NO_REACTION

	var/old_heat_capacity = air.heat_capacity
	freon_burn_rate = min(freon_burn_rate, freon[MOLES], oxygen[MOLES] * INVERSE(oxygen_burn_ratio)) //Ensures matter is conserved properly
	freon[MOLES] = QUANTIZE(freon[MOLES] - freon_burn_rate)
	oxygen[MOLES] = QUANTIZE(oxygen[MOLES] - (freon_burn_rate * oxygen_burn_ratio))
	ASSERT_GAS(/datum/gas/carbon_dioxide, air)
	var/list/carbon_dioxide = cached_gases[/datum/gas/carbon_dioxide]
	carbon_dioxide[MOLES] += freon_burn_rate

	air.heat_capacity += freon_burn_rate * (carbon_dioxide[GAS_META][META_GAS_SPECIFIC_HEAT] - oxygen[GAS_META][META_GAS_SPECIFIC_HEAT] * oxygen_burn_ratio - freon[GAS_META][META_GAS_SPECIFIC_HEAT])

	if(temperature < HOT_ICE_FORMATION_MAXIMUM_TEMPERATURE && temperature > HOT_ICE_FORMATION_MINIMUM_TEMPERATURE && prob(HOT_ICE_FORMATION_PROB) && isturf(holder))
		new /obj/item/stack/sheet/hot_ice(holder)

	SET_REACTION_RESULTS(freon_burn_rate * (1 + oxygen_burn_ratio))
	var/energy_consumed = FIRE_FREON_ENERGY_CONSUMED * freon_burn_rate
	var/new_heat_capacity = air.heat_capacity
	if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
		air.temperature = max((temperature * old_heat_capacity - energy_consumed) / new_heat_capacity, TCMB)

	var/turf/open/location = holder
	if(istype(location))
		temperature = air.temperature
		if(temperature < FREON_MAXIMUM_BURN_TEMPERATURE)
			location.hotspot_expose(temperature, CELL_VOLUME)

	return REACTING


// N2O

/**
 * Nitrous oxide Formation:
 *
 * Formation of N2O.
 * Endothermic.
 * Requires BZ as a catalyst.
 */
/datum/gas_reaction/nitrousformation //formation of n2o, exothermic, requires bz as catalyst
	priority_group = PRIORITY_FORMATION
	name = "Nitrous Oxide Formation"
	id = "nitrousformation"
	desc = "Production of nitrous oxide with BZ as a catalyst."

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
	var/list/oxygen = cached_gases[/datum/gas/oxygen]
	var/list/nitrogen = cached_gases[/datum/gas/nitrogen]
	var/heat_efficency = min(oxygen[MOLES] * INVERSE(0.5), nitrogen[MOLES])
	if ((oxygen[MOLES] - heat_efficency * 0.5 < 0 ) || (nitrogen[MOLES] - heat_efficency < 0))
		return NO_REACTION // Shouldn't produce gas from nothing.

	var/old_heat_capacity = air.heat_capacity
	oxygen[MOLES] -= heat_efficency * 0.5
	nitrogen[MOLES] -= heat_efficency
	ASSERT_GAS(/datum/gas/nitrous_oxide, air)
	var/list/nitrous_oxide = cached_gases[/datum/gas/nitrous_oxide]
	nitrous_oxide[MOLES] += heat_efficency

	air.heat_capacity += heat_efficency * (nitrous_oxide[GAS_META][META_GAS_SPECIFIC_HEAT] - nitrogen[GAS_META][META_GAS_SPECIFIC_HEAT] - oxygen[GAS_META][META_GAS_SPECIFIC_HEAT] * 0.5)

	SET_REACTION_RESULTS(heat_efficency)
	var/energy_released = heat_efficency * N2O_FORMATION_ENERGY
	var/new_heat_capacity = air.heat_capacity
	if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
		air.temperature = max(((air.temperature * old_heat_capacity + energy_released) / new_heat_capacity), TCMB) // The air cools down when reacting.
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
	desc = "Decomposition of nitrous oxide under high temperature."

/datum/gas_reaction/nitrous_decomp/init_reqs()
	requirements = list(
		/datum/gas/nitrous_oxide = MINIMUM_MOLE_COUNT * 2,
		"MIN_TEMP" = N2O_DECOMPOSITION_MIN_TEMPERATURE,
		"MAX_TEMP" = N2O_DECOMPOSITION_MAX_TEMPERATURE,
	)

/datum/gas_reaction/nitrous_decomp/react(datum/gas_mixture/air, datum/holder)
	var/list/cached_gases = air.gases //this speeds things up because accessing datum vars is slow
	var/list/nitrous_oxide = cached_gases[/datum/gas/nitrous_oxide]
	var/temperature = air.temperature
	var/burned_fuel = (nitrous_oxide[MOLES] / N2O_DECOMPOSITION_RATE_DIVISOR) * ((temperature - N2O_DECOMPOSITION_MIN_SCALE_TEMP) * (temperature - N2O_DECOMPOSITION_MAX_SCALE_TEMP) / (N2O_DECOMPOSITION_SCALE_DIVISOR))
	if(burned_fuel <= 0)
		return NO_REACTION
	if(nitrous_oxide[MOLES] - burned_fuel < 0)
		return NO_REACTION

	var/old_heat_capacity = air.heat_capacity
	nitrous_oxide[MOLES] -= burned_fuel
	ASSERT_GAS(/datum/gas/nitrogen, air)
	var/list/nitrogen = cached_gases[/datum/gas/nitrogen]
	nitrogen[MOLES] += burned_fuel
	ASSERT_GAS(/datum/gas/oxygen, air)
	var/list/oxygen = cached_gases[/datum/gas/oxygen]
	oxygen[MOLES] += burned_fuel * 0.5

	air.heat_capacity += burned_fuel * (oxygen[GAS_META][META_GAS_SPECIFIC_HEAT] * 0.5 + nitrogen[GAS_META][META_GAS_SPECIFIC_HEAT] - nitrous_oxide[GAS_META][META_GAS_SPECIFIC_HEAT])

	SET_REACTION_RESULTS(burned_fuel)
	var/energy_released = N2O_DECOMPOSITION_ENERGY * burned_fuel
	var/new_heat_capacity = air.heat_capacity
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
	name = "BZ Gas Formation"
	id = "bzformation"
	desc = "Production of BZ using plasma and nitrous oxide."

/datum/gas_reaction/bzformation/init_reqs()
	requirements = list(
		/datum/gas/nitrous_oxide = 10,
		/datum/gas/plasma = 10,
		"MAX_TEMP" = BZ_FORMATION_MAX_TEMPERATURE,
	)

/datum/gas_reaction/bzformation/react(datum/gas_mixture/air)
	var/list/cached_gases = air.gases
	var/list/nitrous_oxide = cached_gases[/datum/gas/nitrous_oxide]
	var/list/plasma = cached_gases[/datum/gas/plasma]
	var/pressure = air.return_pressure()
	var/volume = air.return_volume()
	var/environment_effciency = volume / pressure		//More volume and less pressure gives better rates
	var/ratio_efficency = min(nitrous_oxide[MOLES] / plasma[MOLES], 1)  //Less n2o than plasma give lower rates
	var/nitrous_oxide_decomposed_factor = max(4 * (plasma[MOLES] / (nitrous_oxide[MOLES] + plasma[MOLES]) - 0.75), 0)
	var/bz_formed = min(0.01 * ratio_efficency * environment_effciency, nitrous_oxide[MOLES] * INVERSE(0.4), plasma[MOLES] * INVERSE(0.8 * (1 - nitrous_oxide_decomposed_factor)))

	if (nitrous_oxide[MOLES] - bz_formed * 0.4 < 0  || plasma[MOLES] - 0.8 * bz_formed * (1 - nitrous_oxide_decomposed_factor) < 0 || bz_formed <= 0)
		return NO_REACTION

	var/old_heat_capacity = air.heat_capacity

	/**
	*If n2o-plasma ratio is less than 1:3 start decomposing n2o.
	*Rate of decomposition vs BZ production increases as n2o concentration gets lower
	*Plasma acts as a catalyst on decomposition, so it doesn't get consumed in the process.
	*N2O decomposes with its normal decomposition energy
	*/
	if (nitrous_oxide_decomposed_factor>0)
		ASSERT_GAS(/datum/gas/nitrogen, air)
		ASSERT_GAS(/datum/gas/oxygen, air)
		var/list/nitrogen = cached_gases[/datum/gas/nitrogen]
		var/list/oxygen = cached_gases[/datum/gas/oxygen]
		var/amount_decomposed = 0.4 * bz_formed * nitrous_oxide_decomposed_factor
		nitrogen[MOLES] += amount_decomposed
		oxygen[MOLES] += 0.5 * amount_decomposed
		air.heat_capacity += amount_decomposed * (nitrogen[GAS_META][META_GAS_SPECIFIC_HEAT] + oxygen[GAS_META][META_GAS_SPECIFIC_HEAT] * 0.5)

	ASSERT_GAS(/datum/gas/bz, air)
	var/list/bz = cached_gases[/datum/gas/bz]
	bz[MOLES] += bz_formed * (1 - nitrous_oxide_decomposed_factor)
	nitrous_oxide[MOLES] -= 0.4 * bz_formed
	plasma[MOLES] -= 0.8 * bz_formed * (1 - nitrous_oxide_decomposed_factor)

	air.heat_capacity += bz_formed * (bz[GAS_META][META_GAS_SPECIFIC_HEAT] - nitrous_oxide[GAS_META][META_GAS_SPECIFIC_HEAT] * 0.4 - plasma[GAS_META][META_GAS_SPECIFIC_HEAT] * (1 - nitrous_oxide_decomposed_factor))

	SET_REACTION_RESULTS(bz_formed)
	var/energy_released = bz_formed * (BZ_FORMATION_ENERGY + nitrous_oxide_decomposed_factor * (N2O_DECOMPOSITION_ENERGY - BZ_FORMATION_ENERGY))
	var/new_heat_capacity = air.heat_capacity
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
	name = "Pluoxium Formation"
	id = "pluox_formation"
	desc = "Alternate production for pluoxium which uses tritium."

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
	var/list/carbon_dioxide = cached_gases[/datum/gas/carbon_dioxide]
	var/list/oxygen = cached_gases[/datum/gas/oxygen]
	var/list/tritium = cached_gases[/datum/gas/tritium]
	var/produced_amount = min(PLUOXIUM_FORMATION_MAX_RATE, carbon_dioxide[MOLES], oxygen[MOLES] * INVERSE(0.5), tritium[MOLES] * INVERSE(0.01))
	if (produced_amount <= 0 || carbon_dioxide[MOLES] - produced_amount < 0 || oxygen[MOLES] - produced_amount * 0.5 < 0 || tritium[MOLES] - produced_amount * 0.01 < 0)
		return NO_REACTION

	var/old_heat_capacity = air.heat_capacity()
	carbon_dioxide[MOLES] -= produced_amount
	oxygen[MOLES] -= produced_amount * 0.5
	tritium[MOLES] -= produced_amount * 0.01
	ASSERT_GAS(/datum/gas/pluoxium, air)
	var/list/pluoxium = cached_gases[/datum/gas/pluoxium]
	pluoxium[MOLES] += produced_amount
	ASSERT_GAS(/datum/gas/hydrogen, air)
	var/list/hydrogen = cached_gases[/datum/gas/hydrogen]
	hydrogen[MOLES] += produced_amount * 0.01

	air.heat_capacity += produced_amount * (hydrogen[GAS_META][META_GAS_SPECIFIC_HEAT] * 0.01 + pluoxium[GAS_META][META_GAS_SPECIFIC_HEAT] - tritium[GAS_META][META_GAS_SPECIFIC_HEAT] * 0.01 - oxygen[GAS_META][META_GAS_SPECIFIC_HEAT] * 0.5 - carbon_dioxide[GAS_META][META_GAS_SPECIFIC_HEAT])

	SET_REACTION_RESULTS(produced_amount)
	var/energy_released = produced_amount * PLUOXIUM_FORMATION_ENERGY
	var/new_heat_capacity = air.heat_capacity
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
	name = "Nitrium Formation"
	id = "nitrium_formation"
	desc = "Production of nitrium from BZ, tritium, and nitrogen."

/datum/gas_reaction/nitrium_formation/init_reqs()
	requirements = list(
		/datum/gas/tritium = 20,
		/datum/gas/nitrogen = 10,
		/datum/gas/bz = 5,
		"MIN_TEMP" = NITRIUM_FORMATION_MIN_TEMP,
	)

/datum/gas_reaction/nitrium_formation/react(datum/gas_mixture/air)
	var/list/cached_gases = air.gases
	var/list/tritium = cached_gases[/datum/gas/tritium]
	var/list/nitrogen = cached_gases[/datum/gas/nitrogen]
	var/list/bz = cached_gases[/datum/gas/bz]
	var/temperature = air.temperature
	var/heat_efficency = min(temperature / NITRIUM_FORMATION_TEMP_DIVISOR, tritium[MOLES], nitrogen[MOLES], bz[MOLES] * INVERSE(0.05))

	if(heat_efficency <= 0 || (tritium[MOLES] - heat_efficency < 0 ) || (nitrogen[MOLES] - heat_efficency < 0) || (bz[MOLES] - heat_efficency * 0.05 < 0)) //Shouldn't produce gas from nothing.
		return NO_REACTION

	var/old_heat_capacity = air.heat_capacity()
	ASSERT_GAS(/datum/gas/nitrium, air)
	var/list/nitrium = cached_gases[/datum/gas/nitrium]
	tritium[MOLES] -= heat_efficency
	nitrogen[MOLES] -= heat_efficency
	bz[MOLES] -= heat_efficency * 0.05 //bz gets consumed to balance the nitrium production and not make it too common and/or easy
	nitrium[MOLES] += heat_efficency

	air.heat_capacity += heat_efficency * (nitrium[GAS_META][META_GAS_SPECIFIC_HEAT] - bz[GAS_META][META_GAS_SPECIFIC_HEAT] * 0.05 - nitrogen[GAS_META][META_GAS_SPECIFIC_HEAT] - tritium[GAS_META][META_GAS_SPECIFIC_HEAT])

	SET_REACTION_RESULTS(heat_efficency)
	var/energy_used = heat_efficency * NITRIUM_FORMATION_ENERGY
	var/new_heat_capacity = air.heat_capacity
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
	desc = "Decomposition of nitrium when exposed to oxygen under normal temperatures."

/datum/gas_reaction/nitrium_decomposition/init_reqs()
	requirements = list(
		/datum/gas/oxygen = MINIMUM_MOLE_COUNT,
		/datum/gas/nitrium = MINIMUM_MOLE_COUNT,
		"MAX_TEMP" = NITRIUM_DECOMPOSITION_MAX_TEMP,
	)

/datum/gas_reaction/nitrium_decomposition/react(datum/gas_mixture/air)
	var/list/cached_gases = air.gases
	var/list/nitrium = cached_gases[/datum/gas/nitrium]
	var/temperature = air.temperature

	//This reaction is agressively slow. like, a tenth of a mole per fire slow. Keep that in mind
	var/heat_efficency = min(temperature / NITRIUM_DECOMPOSITION_TEMP_DIVISOR, nitrium[MOLES])

	if (heat_efficency <= 0 || (nitrium[MOLES] - heat_efficency < 0)) //Shouldn't produce gas from nothing.
		return NO_REACTION

	var/old_heat_capacity = air.heat_capacity()
	air.assert_gases(/datum/gas/nitrogen, /datum/gas/hydrogen)
	var/list/nitrogen = cached_gases[/datum/gas/nitrogen]
	var/list/hydrogen = cached_gases[/datum/gas/hydrogen]
	nitrium[MOLES] -= heat_efficency
	hydrogen[MOLES] += heat_efficency
	nitrogen[MOLES] += heat_efficency

	air.heat_capacity += heat_efficency * (nitrogen[GAS_META][META_GAS_SPECIFIC_HEAT] + hydrogen[GAS_META][META_GAS_SPECIFIC_HEAT] - nitrium[GAS_META][META_GAS_SPECIFIC_HEAT])

	SET_REACTION_RESULTS(heat_efficency)
	var/energy_released = heat_efficency * NITRIUM_DECOMPOSITION_ENERGY
	var/new_heat_capacity = air.heat_capacity
	if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
		air.temperature = max(((temperature * old_heat_capacity + energy_released) / new_heat_capacity), TCMB) //the air heats up when reacting
	return REACTING


/**
 * Freon formation:
 *
 * The formation of freon.
 * Endothermic.
 */
/datum/gas_reaction/freonformation
	priority_group = PRIORITY_FORMATION
	name = "Freon Formation"
	id = "freonformation"
	desc = "Production of freon using plasma, carbon dioxide, and BZ under high temperature."

/datum/gas_reaction/freonformation/init_reqs() //minimum requirements for freon formation
	requirements = list(
		/datum/gas/plasma = MINIMUM_MOLE_COUNT * 6,
		/datum/gas/carbon_dioxide = MINIMUM_MOLE_COUNT * 3,
		/datum/gas/bz = MINIMUM_MOLE_COUNT,
		"MIN_TEMP" = FREON_FORMATION_MIN_TEMPERATURE,
	)

/datum/gas_reaction/freonformation/react(datum/gas_mixture/air)
	var/list/cached_gases = air.gases
	var/list/plasma = cached_gases[/datum/gas/plasma]
	var/list/carbon_dioxide = cached_gases[/datum/gas/carbon_dioxide]
	var/list/bz = cached_gases[/datum/gas/bz]
	var/temperature = air.temperature
	var/minimal_mole_factor = min(plasma[MOLES] * INVERSE(0.6), bz[MOLES] * INVERSE(0.1), carbon_dioxide[MOLES] * INVERSE(0.3))

	var/equation_first_part = NUM_E ** (-(((temperature - 800) / 200) ** 2))
	var/equation_second_part = 3 / (1 + NUM_E ** (-0.001 * (temperature - 6000)))
	var/heat_factor = equation_first_part + equation_second_part

	var/freon_formed = min(heat_factor * minimal_mole_factor * 0.05, plasma[MOLES] * INVERSE(0.6), carbon_dioxide[MOLES] * INVERSE(0.3), bz[MOLES] * INVERSE(0.1))
	if (freon_formed <= 0 || (plasma[MOLES] - freon_formed * 0.6 < 0 ) || (carbon_dioxide[MOLES] - freon_formed * 0.3 < 0) || (bz[MOLES] - freon_formed * 0.1 < 0)) //Shouldn't produce gas from nothing.
		return NO_REACTION

	var/old_heat_capacity = air.heat_capacity()
	ASSERT_GAS(/datum/gas/freon, air)
	var/list/freon = cached_gases[/datum/gas/freon]
	plasma[MOLES] -= freon_formed * 0.6
	carbon_dioxide[MOLES] -= freon_formed * 0.3
	bz[MOLES] -= freon_formed * 0.1
	freon[MOLES] += freon_formed

	air.heat_capacity += freon_formed * (freon[GAS_META][META_GAS_SPECIFIC_HEAT] - bz[GAS_META][META_GAS_SPECIFIC_HEAT] * 0.1 - carbon_dioxide[GAS_META][META_GAS_SPECIFIC_HEAT] * 0.3 - plasma[GAS_META][META_GAS_SPECIFIC_HEAT] * 0.6)

	SET_REACTION_RESULTS(freon_formed)

	var/energy_consumed = (7000 / (1 + NUM_E ** (-0.0015 * (temperature - 6000))) + 1000) * freon_formed * 0.1
	var/new_heat_capacity = air.heat_capacity
	if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
		air.temperature = max(((temperature * old_heat_capacity - energy_consumed) / new_heat_capacity), TCMB)
	return REACTING


/**
 * Hyper-Noblium Formation:
 *
 * Extremely exothermic.
 * Requires very low temperatures.
 * Due to its high mass, hyper-noblium uses large amounts of nitrogen and tritium.
 * BZ can be used as a catalyst to make it less exothermic.
 */
/datum/gas_reaction/nobliumformation
	priority_group = PRIORITY_FORMATION
	name = "Hyper-Noblium Condensation"
	id = "nobformation"
	desc = "Production of hyper-noblium from nitrogen and tritium under very low temperatures. Extremely energetic."

/datum/gas_reaction/nobliumformation/init_reqs()
	requirements = list(
		/datum/gas/nitrogen = 10,
		/datum/gas/tritium = 5,
		"MIN_TEMP" = NOBLIUM_FORMATION_MIN_TEMP,
		"MAX_TEMP" = NOBLIUM_FORMATION_MAX_TEMP,
	)

/datum/gas_reaction/nobliumformation/react(datum/gas_mixture/air)
	var/list/cached_gases = air.gases
	var/list/asserted_gases = list(/datum/gas/hypernoblium, /datum/gas/bz)
	air.assert_gases(arglist(asserted_gases))
	var/list/nitrogen = cached_gases[/datum/gas/nitrogen]
	var/list/tritium = cached_gases[/datum/gas/tritium]
	var/list/hypernoblium = cached_gases[/datum/gas/hypernoblium]
	var/list/bz = cached_gases[/datum/gas/bz]
	var/reduction_factor = clamp(tritium[MOLES] / (tritium[MOLES] + bz[MOLES]), 0.001 , 1) //reduces trit consumption in presence of bz upward to 0.1% reduction

	var/nob_formed = min((nitrogen[MOLES] + tritium[MOLES]) * 0.01, tritium[MOLES] * INVERSE(5 * reduction_factor), nitrogen[MOLES] * INVERSE(10))

	if (nob_formed <= 0 || (cached_gases[/datum/gas/tritium][MOLES] - 5 * nob_formed < 0) || (cached_gases[/datum/gas/nitrogen][MOLES] - 10 * nob_formed < 0))
		air.garbage_collect(arglist(asserted_gases))
		return NO_REACTION

	var/old_heat_capacity = air.heat_capacity
	tritium[MOLES] -= 5 * nob_formed * reduction_factor
	nitrogen[MOLES] -= 10 * nob_formed
	hypernoblium[MOLES] += nob_formed // I'm not going to nitpick, but N20H10 feels like it should be an explosive more than anything.

	air.heat_capacity += nob_formed * (hypernoblium[GAS_META][META_GAS_SPECIFIC_HEAT] - nitrogen[GAS_META][META_GAS_SPECIFIC_HEAT] * 10 - tritium[GAS_META][META_GAS_SPECIFIC_HEAT] * 5)

	SET_REACTION_RESULTS(nob_formed)
	var/energy_released = nob_formed * (NOBLIUM_FORMATION_ENERGY / (max(bz[MOLES], 1)))
	var/new_heat_capacity = air.heat_capacity
	if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
		air.temperature = max(((air.temperature * old_heat_capacity + energy_released) / new_heat_capacity), TCMB)
	return REACTING


// Halon

/**
 * Halon Combustion:
 *
 * Consumes a large amount of oxygen relative to the amount of halon consumed.
 * Produces carbon dioxide.
 * Endothermic.
 */
/datum/gas_reaction/halon_o2removal
	priority_group = PRIORITY_PRE_FORMATION
	name = "Halon Oxygen Absorption"
	id = "halon_o2removal"
	desc = "Halon interaction with oxygen that can be used to snuff fires out."

/datum/gas_reaction/halon_o2removal/init_reqs()
	requirements = list(
		/datum/gas/halon = MINIMUM_MOLE_COUNT,
		/datum/gas/oxygen = MINIMUM_MOLE_COUNT,
		"MIN_TEMP" = FIRE_MINIMUM_TEMPERATURE_TO_EXIST,
	)

/datum/gas_reaction/halon_o2removal/react(datum/gas_mixture/air, datum/holder)
	var/list/cached_gases = air.gases
	var/list/halon = cached_gases[/datum/gas/halon]
	var/list/oxygen = cached_gases[/datum/gas/oxygen]
	var/temperature = air.temperature

	var/heat_efficency = min(temperature / (FIRE_MINIMUM_TEMPERATURE_TO_EXIST * 10), halon[MOLES], oxygen[MOLES] * INVERSE(20))
	if (heat_efficency <= 0 || (halon[MOLES] - heat_efficency < 0 ) || (oxygen[MOLES] - heat_efficency * 20 < 0)) //Shouldn't produce gas from nothing.
		return NO_REACTION

	var/old_heat_capacity = air.heat_capacity
	ASSERT_GAS(/datum/gas/carbon_dioxide, air)
	var/list/carbon_dioxide = cached_gases[/datum/gas/carbon_dioxide]
	halon[MOLES] -= heat_efficency
	oxygen[MOLES] -= heat_efficency * 20
	carbon_dioxide[MOLES] += heat_efficency * 5

	air.heat_capacity += heat_efficency * (carbon_dioxide[GAS_META][META_GAS_SPECIFIC_HEAT] * 5 - oxygen[GAS_META][META_GAS_SPECIFIC_HEAT] * 20 - halon[GAS_META][META_GAS_SPECIFIC_HEAT])

	SET_REACTION_RESULTS(heat_efficency * 5)
	var/energy_used = heat_efficency * HALON_COMBUSTION_ENERGY
	var/new_heat_capacity = air.heat_capacity
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
	name = "Healium Formation"
	id = "healium_formation"
	desc = "Production of healium using BZ and freon."

/datum/gas_reaction/healium_formation/init_reqs()
	requirements = list(
		/datum/gas/bz = MINIMUM_MOLE_COUNT,
		/datum/gas/freon = MINIMUM_MOLE_COUNT,
		"MIN_TEMP" = HEALIUM_FORMATION_MIN_TEMP,
		"MAX_TEMP" = HEALIUM_FORMATION_MAX_TEMP,
	)

/datum/gas_reaction/healium_formation/react(datum/gas_mixture/air, datum/holder)
	var/list/cached_gases = air.gases
	var/list/bz = cached_gases[/datum/gas/bz]
	var/list/freon = cached_gases[/datum/gas/freon]
	var/temperature = air.temperature
	var/heat_efficency = min(temperature * 0.3, freon[MOLES] * INVERSE(2.75), bz[MOLES] * INVERSE(0.25))
	if (heat_efficency <= 0 || (freon[MOLES] - heat_efficency * 2.75 < 0 ) || (bz[MOLES] - heat_efficency * 0.25 < 0)) //Shouldn't produce gas from nothing.
		return NO_REACTION

	var/old_heat_capacity = air.heat_capacity
	ASSERT_GAS(/datum/gas/healium, air)
	var/list/healium = cached_gases[/datum/gas/healium]
	freon[MOLES] -= heat_efficency * 2.75
	bz[MOLES] -= heat_efficency * 0.25
	healium[MOLES] += heat_efficency * 3

	air.heat_capacity += heat_efficency * (healium[GAS_META][META_GAS_SPECIFIC_HEAT] * 3 - bz[GAS_META][META_GAS_SPECIFIC_HEAT] * 0.25 - freon[GAS_META][META_GAS_SPECIFIC_HEAT] * 2.75)

	SET_REACTION_RESULTS(heat_efficency * 3)
	var/energy_released = heat_efficency * HEALIUM_FORMATION_ENERGY
	var/new_heat_capacity = air.heat_capacity
	if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
		air.temperature = max(((temperature * old_heat_capacity + energy_released) / new_heat_capacity), TCMB)
	return REACTING

/**
 * Zauker Formation:
 *
 * Exothermic.
 * Requires Hypernoblium.
 */
/datum/gas_reaction/zauker_formation
	priority_group = PRIORITY_FORMATION
	name = "Zauker Formation"
	id = "zauker_formation"
	desc = "Production of zauker using hyper-noblium and nitrium under very high temperatures."

/datum/gas_reaction/zauker_formation/init_reqs()
	requirements = list(
		/datum/gas/hypernoblium = MINIMUM_MOLE_COUNT,
		/datum/gas/nitrium = MINIMUM_MOLE_COUNT,
		"MIN_TEMP" = ZAUKER_FORMATION_MIN_TEMPERATURE,
		"MAX_TEMP" = ZAUKER_FORMATION_MAX_TEMPERATURE,
	)

/datum/gas_reaction/zauker_formation/react(datum/gas_mixture/air, datum/holder)
	var/list/cached_gases = air.gases
	var/list/hypernoblium = cached_gases[/datum/gas/hypernoblium][MOLES]
	var/list/nitrium = cached_gases[/datum/gas/nitrium][MOLES]
	var/temperature = air.temperature

	var/heat_efficency = min(temperature * ZAUKER_FORMATION_TEMPERATURE_SCALE, hypernoblium[MOLES] * INVERSE(0.01), nitrium[MOLES] * INVERSE(0.5))
	if (heat_efficency <= 0 || (hypernoblium[MOLES] - heat_efficency * 0.01 < 0) || (nitrium[MOLES] - heat_efficency * 0.5 < 0)) //Shouldn't produce gas from nothing.
		return NO_REACTION

	var/old_heat_capacity = air.heat_capacity
	ASSERT_GAS(/datum/gas/zauker, air)
	var/list/zauker = cached_gases[/datum/gas/zauker]
	hypernoblium[MOLES] -= heat_efficency * 0.01
	nitrium[MOLES] -= heat_efficency * 0.5
	zauker[MOLES] += heat_efficency * 0.5

	air.heat_capacity += heat_efficency * (zauker[GAS_META][META_GAS_SPECIFIC_HEAT] * 0.5 - nitrium[GAS_META][META_GAS_SPECIFIC_HEAT] * 0.5 - hypernoblium[GAS_META][META_GAS_SPECIFIC_HEAT] * 0.01)

	SET_REACTION_RESULTS(heat_efficency * 0.5)
	var/energy_used = heat_efficency * ZAUKER_FORMATION_ENERGY
	var/new_heat_capacity = air.heat_capacity
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
	name = "Zauker Decomposition"
	id = "zauker_decomp"
	desc = "Decomposition of zauker when exposed to nitrogen."

/datum/gas_reaction/zauker_decomp/init_reqs()
	requirements = list(
		/datum/gas/nitrogen = MINIMUM_MOLE_COUNT,
		/datum/gas/zauker = MINIMUM_MOLE_COUNT,
	)

/datum/gas_reaction/zauker_decomp/react(datum/gas_mixture/air, datum/holder)
	var/list/cached_gases = air.gases //this speeds things up because accessing datum vars is slow
	var/list/nitrogen = cached_gases[/datum/gas/nitrogen]
	var/list/zauker = cached_gases[/datum/gas/zauker]
	var/burned_fuel = min(ZAUKER_DECOMPOSITION_MAX_RATE, nitrogen[MOLES], zauker[MOLES])
	if (burned_fuel <= 0 || zauker[MOLES] - burned_fuel < 0)
		return NO_REACTION

	var/old_heat_capacity = air.heat_capacity
	zauker[MOLES] -= burned_fuel
	ASSERT_GAS(/datum/gas/oxygen, air)
	var/list/oxygen = cached_gases[/datum/gas/oxygen]
	oxygen[MOLES] += burned_fuel * 0.3
	nitrogen[MOLES] += burned_fuel * 0.7

	air.heat_capacity += burned_fuel * (nitrogen[GAS_META][META_GAS_SPECIFIC_HEAT] * 0.7 + oxygen[GAS_META][META_GAS_SPECIFIC_HEAT] * 0.3 - zauker[GAS_META][META_GAS_SPECIFIC_HEAT])

	SET_REACTION_RESULTS(burned_fuel)
	var/energy_released = ZAUKER_DECOMPOSITION_ENERGY * burned_fuel
	var/new_heat_capacity = air.heat_capacity
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
	name = "Proto Nitrate Formation"
	id = "proto_nitrate_formation"
	desc = "Production of proto-nitrate from pluoxium and hydrogen under high temperatures."

/datum/gas_reaction/proto_nitrate_formation/init_reqs()
	requirements = list(
		/datum/gas/pluoxium = MINIMUM_MOLE_COUNT,
		/datum/gas/hydrogen = MINIMUM_MOLE_COUNT,
		"MIN_TEMP" = PN_FORMATION_MIN_TEMPERATURE,
		"MAX_TEMP" = PN_FORMATION_MAX_TEMPERATURE,
	)

/datum/gas_reaction/proto_nitrate_formation/react(datum/gas_mixture/air, datum/holder)
	var/list/cached_gases = air.gases
	var/list/pluoxium = cached_gases[/datum/gas/pluoxium]
	var/list/hydrogen = cached_gases[/datum/gas/hydrogen]
	var/temperature = air.temperature

	var/heat_efficency = min(temperature * 0.005, pluoxium[MOLES] * INVERSE(0.2), hydrogen[MOLES] * INVERSE(2))
	if (heat_efficency <= 0 || (pluoxium[MOLES] - heat_efficency * 0.2 < 0 ) || (hydrogen[MOLES] - heat_efficency * 2 < 0)) //Shouldn't produce gas from nothing.
		return NO_REACTION

	var/old_heat_capacity = air.heat_capacity
	ASSERT_GAS(/datum/gas/proto_nitrate, air)
	var/list/proto_nitrate = cached_gases[/datum/gas/proto_nitrate]
	hydrogen[MOLES] -= heat_efficency * 2
	pluoxium[MOLES] -= heat_efficency * 0.2
	proto_nitrate[MOLES] += heat_efficency * 2.2

	air.heat_capacity += heat_efficency * (proto_nitrate[GAS_META][META_GAS_SPECIFIC_HEAT] * 2.2 - pluoxium[GAS_META][META_GAS_SPECIFIC_HEAT] * 0.2 - hydrogen[GAS_META][META_GAS_SPECIFIC_HEAT] * 2)

	SET_REACTION_RESULTS(heat_efficency * 2.2)
	var/energy_released = heat_efficency * PN_FORMATION_ENERGY
	var/new_heat_capacity = air.heat_capacity
	if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
		air.temperature = max(((temperature * old_heat_capacity + energy_released) / new_heat_capacity), TCMB)
	return REACTING

/**
 * Proto-Nitrate Hydrogen Conversion
 *
 * Converts hydrogen into proto-nitrate.
 * Endothermic.
 */
/datum/gas_reaction/proto_nitrate_hydrogen_response
	priority_group = PRIORITY_PRE_FORMATION
	name = "Proto Nitrate Hydrogen Response"
	id = "proto_nitrate_hydrogen_response"
	desc = "Conversion of hydrogen into proto nitrate."

/datum/gas_reaction/proto_nitrate_hydrogen_response/init_reqs()
	requirements = list(
		/datum/gas/proto_nitrate = MINIMUM_MOLE_COUNT,
		/datum/gas/hydrogen = PN_HYDROGEN_CONVERSION_THRESHOLD,
	)

/datum/gas_reaction/proto_nitrate_hydrogen_response/react(datum/gas_mixture/air, datum/holder)
	var/list/cached_gases = air.gases
	var/list/proto_nitrate = cached_gases[/datum/gas/proto_nitrate]
	var/list/hydrogen = cached_gases[/datum/gas/hydrogen]
	var/consumed_amount = min(PN_HYDROGEN_CONVERSION_MAX_RATE, hydrogen[MOLES], proto_nitrate[MOLES])
	if (consumed_amount <= 0 || hydrogen[MOLES] - consumed_amount < 0)
		return NO_REACTION

	var/old_heat_capacity = air.heat_capacity
	hydrogen[MOLES] -= consumed_amount
	proto_nitrate[MOLES] += consumed_amount * 0.5

	air.heat_capacity += consumed_amount * (proto_nitrate[GAS_META][META_GAS_SPECIFIC_HEAT] * 0.5 - hydrogen[GAS_META][META_GAS_SPECIFIC_HEAT])

	SET_REACTION_RESULTS(consumed_amount * 0.5)
	var/energy_used = consumed_amount * PN_HYDROGEN_CONVERSION_ENERGY
	var/new_heat_capacity = air.heat_capacity
	if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
		air.temperature = max((air.temperature * old_heat_capacity - energy_used) / new_heat_capacity, TCMB)
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
	name = "Proto Nitrate Tritium Response"
	id = "proto_nitrate_tritium_response"
	desc = "Conversion of tritium into hydrogen that consumes a small amount of proto-nitrate."

/datum/gas_reaction/proto_nitrate_tritium_response/init_reqs()
	requirements = list(
		/datum/gas/proto_nitrate = MINIMUM_MOLE_COUNT,
		/datum/gas/tritium = MINIMUM_MOLE_COUNT,
		"MIN_TEMP" = PN_TRITIUM_CONVERSION_MIN_TEMP,
		"MAX_TEMP" = PN_TRITIUM_CONVERSION_MAX_TEMP,
	)

/datum/gas_reaction/proto_nitrate_tritium_response/react(datum/gas_mixture/air, datum/holder)
	var/list/cached_gases = air.gases
	var/list/proto_nitrate = cached_gases[/datum/gas/proto_nitrate]
	var/list/tritium = cached_gases[/datum/gas/tritium]
	var/temperature = air.temperature
	var/produced_amount = min(temperature / 34 * (tritium[MOLES] * proto_nitrate[MOLES]) / (tritium[MOLES] + 10 * proto_nitrate[MOLES]), tritium[MOLES], proto_nitrate[MOLES] * INVERSE(0.01))
	if(tritium[MOLES] - produced_amount < 0 || proto_nitrate[MOLES] - produced_amount * 0.01 < 0)
		return NO_REACTION

	var/old_heat_capacity = air.heat_capacity
	proto_nitrate[MOLES] -= produced_amount * 0.01
	tritium[MOLES] -= produced_amount
	ASSERT_GAS(/datum/gas/hydrogen, air)
	var/list/hydrogen = cached_gases[/datum/gas/hydrogen]
	hydrogen[MOLES] += produced_amount

	air.heat_capacity += produced_amount * (hydrogen[GAS_META][META_GAS_SPECIFIC_HEAT] - tritium[GAS_META][META_GAS_SPECIFIC_HEAT] - proto_nitrate[GAS_META][META_GAS_SPECIFIC_HEAT] * 0.01)

	SET_REACTION_RESULTS(produced_amount)
	var/turf/open/location
	var/energy_released = produced_amount * PN_TRITIUM_CONVERSION_ENERGY
	if(istype(holder,/datum/pipeline)) //Find the tile the reaction is occuring on, or a random part of the network if it's a pipenet.
		var/datum/pipeline/pipenet = holder
		location = pick(pipenet.members)
	else if(isatom(holder))
		location = holder
	if (location && energy_released > PN_TRITIUM_CONVERSION_RAD_RELEASE_THRESHOLD * (air.volume / CELL_VOLUME) ** ATMOS_RADIATION_VOLUME_EXP)
		radiation_pulse(location, max_range = min(sqrt(produced_amount) / PN_TRITIUM_RAD_RANGE_DIVISOR, GAS_REACTION_MAXIMUM_RADIATION_PULSE_RANGE), threshold = PN_TRITIUM_RAD_THRESHOLD)

	if(energy_released)
		var/new_heat_capacity = air.heat_capacity
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
	name = "Proto Nitrate BZ Response"
	id = "proto_nitrate_bz_response"
	desc = "Breakdown of BZ into nitrogen, helium, and plasma by proto-nitrate under low temperatures."

/datum/gas_reaction/proto_nitrate_bz_response/init_reqs()
	requirements = list(
		/datum/gas/proto_nitrate = MINIMUM_MOLE_COUNT,
		/datum/gas/bz = MINIMUM_MOLE_COUNT,
		"MIN_TEMP" = PN_BZASE_MIN_TEMP,
		"MAX_TEMP" = PN_BZASE_MAX_TEMP,
	)

/datum/gas_reaction/proto_nitrate_bz_response/react(datum/gas_mixture/air, datum/holder)
	var/list/cached_gases = air.gases
	var/list/proto_nitrate = cached_gases[/datum/gas/proto_nitrate]
	var/list/bz = cached_gases[/datum/gas/bz]
	var/temperature = air.temperature
	var/consumed_amount = min(temperature / 2240 * bz[MOLES] * proto_nitrate[MOLES] / (bz[MOLES] + proto_nitrate[MOLES]), bz[MOLES], proto_nitrate[MOLES])
	if (consumed_amount <= 0 || bz[MOLES] - consumed_amount < 0)
		return NO_REACTION

	var/old_heat_capacity = air.heat_capacity
	bz[MOLES] -= consumed_amount
	ASSERT_GAS(/datum/gas/nitrogen, air)
	var/list/nitrogen = cached_gases[/datum/gas/nitrogen]
	nitrogen[MOLES] += consumed_amount * 0.4
	ASSERT_GAS(/datum/gas/helium, air)
	var/list/helium = cached_gases[/datum/gas/helium]
	helium[MOLES] += consumed_amount * 1.6
	ASSERT_GAS(/datum/gas/plasma, air)
	var/list/plasma = cached_gases[/datum/gas/plasma]
	plasma[MOLES] += consumed_amount * 0.8

	air.heat_capacity += consumed_amount * (plasma[GAS_META][META_GAS_SPECIFIC_HEAT] * 0.8 + helium[GAS_META][META_GAS_SPECIFIC_HEAT] * 1.6 + nitrogen[GAS_META][META_GAS_SPECIFIC_HEAT] * 0.4 - bz[GAS_META][META_GAS_SPECIFIC_HEAT])

	SET_REACTION_RESULTS(consumed_amount)
	var/turf/open/location
	var/energy_released = consumed_amount * PN_BZASE_ENERGY
	if(istype(holder,/datum/pipeline)) //Find the tile the reaction is occuring on, or a random part of the network if it's a pipenet.
		var/datum/pipeline/pipenet = holder
		location = pick(pipenet.members)
	else if(isatom(holder))
		location = holder
	if (location && energy_released > PN_BZASE_RAD_RELEASE_THRESHOLD * (air.volume / CELL_VOLUME) ** ATMOS_RADIATION_VOLUME_EXP)
		///How many nuclear particles will fire in this reaction.
		var/nuclear_particle_amount = min(round(consumed_amount / PN_BZASE_NUCLEAR_PARTICLE_DIVISOR), PN_BZASE_NUCLEAR_PARTICLE_MAXIMUM)
		for(var/i in 1 to nuclear_particle_amount)
			location.fire_nuclear_particle()
		radiation_pulse(location, max_range = min(sqrt(consumed_amount - nuclear_particle_amount * PN_BZASE_NUCLEAR_PARTICLE_RADIATION_ENERGY_CONVERSION) / PN_BZASE_RAD_RANGE_DIVISOR, GAS_REACTION_MAXIMUM_RADIATION_PULSE_RANGE), threshold = PN_BZASE_RAD_THRESHOLD)
		visible_hallucination_pulse(location, 1, consumed_amount * 2 SECONDS)

	var/new_heat_capacity = air.heat_capacity
	if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
		air.temperature = max((temperature * old_heat_capacity + energy_released) / new_heat_capacity, TCMB)
	return REACTING

#undef SET_REACTION_RESULTS
