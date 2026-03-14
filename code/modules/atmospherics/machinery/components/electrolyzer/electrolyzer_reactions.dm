GLOBAL_LIST_INIT(electrolyzer_reactions, electrolyzer_reactions_list())

/*
 * Global proc to build the electrolyzer reactions list
 */
/proc/electrolyzer_reactions_list()
	var/list/built_reaction_list = list()
	for(var/reaction_path in subtypesof(/datum/electrolyzer_reaction))
		var/datum/electrolyzer_reaction/reaction = new reaction_path()

		built_reaction_list[reaction.id] = reaction

	return built_reaction_list

/datum/electrolyzer_reaction
	var/list/requirements
	var/name = "reaction"
	var/id = "r"
	var/desc = ""
	var/list/factor

/**
 * Electrolyzer reaction.
 * Args:
 * * air_mixture: The gas_mixture receiving the electrolysis.
 * * working_power: How much energy to put into the electrolysis, in electrolyzer units. A value of 1 is what a tier 1 electrolyzer would put in.
 * * electrolyzer_args: Additional arguments for alternative methods of electrolysis.
 */
/datum/electrolyzer_reaction/proc/react(datum/gas_mixture/air_mixture, working_power, list/electrolyzer_args = list())
	return

/**
 * Checks whether the requirements are met for a reaction.
 * Args:
 * * air_mixture: The air mixture to check the requirements for.
 * * electrolyzer_args: Additional arguments for alternative methods of electrolysis.
 */
/datum/electrolyzer_reaction/proc/reaction_check(datum/gas_mixture/air_mixture, list/electrolyzer_args = list())
	var/temp = air_mixture.temperature
	var/list/cached_gases = air_mixture.gases
	if((requirements["MIN_TEMP"] && temp < requirements["MIN_TEMP"]) || (requirements["MAX_TEMP"] && temp > requirements["MAX_TEMP"]))
		return FALSE
	for(var/id in requirements)
		if (id == "MIN_TEMP" || id == "MAX_TEMP")
			continue
		if(!cached_gases[id] || cached_gases[id][MOLES] < requirements[id])
			return FALSE
	return TRUE

/datum/electrolyzer_reaction/h2o_conversion
	name = "H2O Conversion"
	id = "h2o_conversion"
	desc = "Conversion of H2o into O2 and H2"
	requirements = list(
		/datum/gas/water_vapor = MINIMUM_MOLE_COUNT
	)
	factor = list(
		/datum/gas/water_vapor = "2 moles of H2O get consumed",
		/datum/gas/oxygen = "1 mole of O2 gets produced",
		/datum/gas/hydrogen = "2 moles of H2 get produced",
		"Location" = "Can only happen on turfs with an active Electrolyzer.",
	)

/datum/electrolyzer_reaction/h2o_conversion/react(datum/gas_mixture/air_mixture, working_power, list/electrolyzer_args = list())

	var/old_heat_capacity = air_mixture.heat_capacity()
	air_mixture.assert_gases(/datum/gas/water_vapor, /datum/gas/oxygen, /datum/gas/hydrogen)
	var/proportion = min(air_mixture.gases[/datum/gas/water_vapor][MOLES] * INVERSE(2), (2.5 * (working_power ** 2)))
	air_mixture.gases[/datum/gas/water_vapor][MOLES] -= proportion * 2
	air_mixture.gases[/datum/gas/oxygen][MOLES] += proportion
	air_mixture.gases[/datum/gas/hydrogen][MOLES] += proportion * 2
	var/new_heat_capacity = air_mixture.heat_capacity()
	if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
		air_mixture.temperature = max(air_mixture.temperature * old_heat_capacity / new_heat_capacity, TCMB)

/datum/electrolyzer_reaction/nob_conversion
	name = "Hypernob conversion"
	id = "nob_conversion"
	desc = "Conversion of Hypernoblium into Antinoblium"
	requirements = list(
		/datum/gas/hypernoblium = MINIMUM_MOLE_COUNT,
	)
	factor = list(
		/datum/gas/hypernoblium = "1 mole of Hypernoblium gets consumed",
		/datum/gas/antinoblium = "1 mole of Antinoblium get produced",
		"Location" = "Can only happen on turfs that are being struck by supermatter zaps with a power level above 5 GeV.",
	)

/datum/electrolyzer_reaction/nob_conversion/reaction_check(datum/gas_mixture/air_mixture, list/electrolyzer_args = list())
	if(!electrolyzer_args[ELECTROLYSIS_ARGUMENT_SUPERMATTER_POWER] || electrolyzer_args[ELECTROLYSIS_ARGUMENT_SUPERMATTER_POWER] <= POWER_PENALTY_THRESHOLD)
		return FALSE
	. = ..()

/datum/electrolyzer_reaction/nob_conversion/react(datum/gas_mixture/air_mixture, working_power, list/electrolyzer_args = list())
	/// The supermatter zap power_level.
	var/supermatter_power = electrolyzer_args[ELECTROLYSIS_ARGUMENT_SUPERMATTER_POWER]
	var/list/cached_gases = air_mixture.gases
	var/old_heat_capacity = air_mixture.heat_capacity()
	air_mixture.assert_gases(/datum/gas/hypernoblium, /datum/gas/antinoblium)
	var/list/hypernoblium = cached_gases[/datum/gas/hypernoblium]
	var/list/antinoblium = cached_gases[/datum/gas/antinoblium]
	var/electrolysed = hypernoblium[MOLES] * clamp(supermatter_power - POWER_PENALTY_THRESHOLD, 0, CRITICAL_POWER_PENALTY_THRESHOLD - POWER_PENALTY_THRESHOLD) / (CRITICAL_POWER_PENALTY_THRESHOLD - POWER_PENALTY_THRESHOLD)
	hypernoblium[MOLES] -= electrolysed
	antinoblium[MOLES] += electrolysed
	var/new_heat_capacity = old_heat_capacity + electrolysed * (antinoblium[GAS_META][META_GAS_SPECIFIC_HEAT] - hypernoblium[GAS_META][META_GAS_SPECIFIC_HEAT])
	if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
		air_mixture.temperature = max(air_mixture.temperature * old_heat_capacity / new_heat_capacity, TCMB)

/datum/electrolyzer_reaction/halon_generation
	name = "Halon generation"
	id = "halon_generation"
	desc = "Production of halon from the electrolysis of BZ."
	requirements = list(
		/datum/gas/bz = MINIMUM_MOLE_COUNT,
	)
	factor = list(
		/datum/gas/bz = "Consumed during reaction.",
		/datum/gas/oxygen = "0.2 moles of oxygen gets produced per mole of BZ consumed.",
		/datum/gas/halon = "2 moles of Halon gets produced per mole of BZ consumed.",
		"Energy" = "91.2321 kJ of thermal energy is released per mole of BZ consumed.",
		"Temperature" = "Reaction efficiency is proportional to temperature.",
		"Location" = "Can only happen on turfs with an active Electrolyzer.",
	)

/datum/electrolyzer_reaction/halon_generation/react(datum/gas_mixture/air_mixture, working_power, list/electrolyzer_args = list())
	var/old_heat_capacity = air_mixture.heat_capacity()
	air_mixture.assert_gases(/datum/gas/bz, /datum/gas/oxygen, /datum/gas/halon)
	var/reaction_efficency = min(air_mixture.gases[/datum/gas/bz][MOLES] * (1 - NUM_E ** (-0.5 * air_mixture.temperature * working_power / FIRE_MINIMUM_TEMPERATURE_TO_EXIST)), air_mixture.gases[/datum/gas/bz][MOLES])
	air_mixture.gases[/datum/gas/bz][MOLES] -= reaction_efficency
	air_mixture.gases[/datum/gas/oxygen][MOLES] += reaction_efficency * 0.2
	air_mixture.gases[/datum/gas/halon][MOLES] += reaction_efficency * 2
	var/energy_used = reaction_efficency * HALON_FORMATION_ENERGY
	var/new_heat_capacity = air_mixture.heat_capacity()
	if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
		air_mixture.temperature = max(((air_mixture.temperature * old_heat_capacity + energy_used) / new_heat_capacity), TCMB)
