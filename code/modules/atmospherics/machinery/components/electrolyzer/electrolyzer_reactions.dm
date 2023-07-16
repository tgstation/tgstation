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

/datum/electrolyzer_reaction/proc/react(turf/location, datum/gas_mixture/air_mixture, working_power)
	return

/datum/electrolyzer_reaction/proc/reaction_check(datum/gas_mixture/air_mixture)
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

/datum/electrolyzer_reaction/h2o_conversion/react(turf/location, datum/gas_mixture/air_mixture, working_power)
	var/list/cached_gases = air_mixture.gases
	var/old_heat_capacity = air_mixture.heat_capacity
	air_mixture.assert_gases(/datum/gas/water_vapor, /datum/gas/oxygen, /datum/gas/hydrogen)
	var/list/water_vapor = cached_gases[/datum/gas/water_vapor]
	var/list/oxygen = cached_gases[/datum/gas/oxygen]
	var/list/hydrogen = cached_gases[/datum/gas/hydrogen]
	var/proportion = min(water_vapor[MOLES] * INVERSE(2), 2.5 * working_power ** 2)
	water_vapor[MOLES] -= proportion * 2
	oxygen[MOLES] += proportion
	hydrogen[MOLES] += proportion * 2

	air.heat_capacity += proportion * (hydrogen[GAS_META][META_GAS_SPECIFIC_HEAT] * 2 + oxygen[GAS_META][META_GAS_SPECIFIC_HEAT] - water_vapor[GAS_META][META_GAS_SPECIFIC_HEAT] * 2)

	var/new_heat_capacity = air_mixture.heat_capacity
	if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
		air_mixture.temperature = max(air_mixture.temperature * old_heat_capacity / new_heat_capacity, TCMB)

/datum/electrolyzer_reaction/nob_conversion
	name = "Hypernob conversion"
	id = "nob_conversion"
	desc = "Conversion of Hypernoblium into Antinoblium"
	requirements = list(
		/datum/gas/hypernoblium = MINIMUM_MOLE_COUNT,
		"MAX_TEMP" = 150
	)
	factor = list(
		/datum/gas/hypernoblium = "1 mole of Hypernoblium gets consumed",
		/datum/gas/antinoblium = "0.5 moles of Antinoblium get produced",
		"Temperature" = "Can only occur under 150 kelvin.",
		"Location" = "Can only happen on turfs with an active Electrolyzer.",
	)

/datum/electrolyzer_reaction/nob_conversion/react(turf/location, datum/gas_mixture/air_mixture, working_power)
	var/list/cached_gases = air_mixture.gases
	var/old_heat_capacity = air_mixture.heat_capacity
	air_mixture.assert_gases(/datum/gas/hypernoblium, /datum/gas/antinoblium)
	var/list/hypernoblium = cached_gases[/datum/gas/hypernoblium]
	var/list/antinoblium = cached_gases[/datum/gas/antinoblium]
	var/proportion = min(hypernoblium[MOLES], 1.5 * working_power ** 2)
	hypernoblium[MOLES] -= proportion
	antinoblium[MOLES] += proportion * 0.5

	air_mixture.heat_capacity += proportion * (antinoblium[GAS_META][META_GAS_SPECIFIC_HEAT] * 0.5 + hypernoblium[GAS_META][META_GAS_SPECIFIC_HEAT])

	var/new_heat_capacity = air_mixture.heat_capacity
	if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
		air_mixture.temperature = max(air_mixture.temperature * old_heat_capacity / new_heat_capacity, TCMB)

/datum/electrolyzer_reaction/halon_generation
	name = "Halon generation"
	id = "halon_generation"
	desc = "Production of halon from CO2 and N2O"
	requirements = list(
		/datum/gas/carbon_dioxide = MINIMUM_MOLE_COUNT,
		/datum/gas/nitrous_oxide = MINIMUM_MOLE_COUNT,
		"MAX_TEMP" = 230
	)
	factor = list(
		/datum/gas/carbon_dioxide = "2 moles of CO2 get consumed",
		/datum/gas/nitrous_oxide = "1 mole of N2O gets consumed",
		/datum/gas/halon = "1 mole of Halon gets produced",
		"Energy" = "300 joules of energy is released per mole",
		"Temperature" = "Can only occur under 230 kelvin.",
		"Location" = "Can only happen on turfs with an active Electrolyzer.",
	)

/datum/electrolyzer_reaction/halon_generation/react(turf/location, datum/gas_mixture/air_mixture, working_power)
	var/list/cached_gases = air_mixture.gases
	var/old_heat_capacity = air_mixture.heat_capacity
	air_mixture.assert_gases(/datum/gas/carbon_dioxide, /datum/gas/nitrous_oxide, /datum/gas/halon)
	var/list/carbon_dioxide = cached_gases[/datum/gas/carbon_dioxide]
	var/list/nitrous_oxide = cached_gases[/datum/gas/nitrous_oxide]
	var/list/halon = cached_gases[/datum/gas/halon]
	var/pressure = air_mixture.return_pressure()
	var/reaction_efficency = min(1 / ((pressure / (0.5 * ONE_ATMOSPHERE)) * (max(carbon_dioxide[MOLES] / nitrous_oxide[MOLES], 1))), nitrous_oxide[MOLES], carbon_dioxide[MOLES] * INVERSE(2))
	carbon_dioxide[MOLES] -= reaction_efficency * 2
	nitrous_oxide[MOLES] -= reaction_efficency
	halon[MOLES] += reaction_efficency

	air_mixture.heat_capacity += reaction_efficency * (halon[GAS_META][META_GAS_SPECIFIC_HEAT] - nitrous_oxide[GAS_META][META_GAS_SPECIFIC_HEAT] - carbon_dioxide[GAS_META][META_GAS_SPECIFIC_HEAT] * 2)

	var/energy_used = reaction_efficency * HALON_FORMATION_ENERGY
	var/new_heat_capacity = air_mixture.heat_capacity
	if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
		air_mixture.temperature = max(((air_mixture.temperature * old_heat_capacity + energy_used) / new_heat_capacity), TCMB)
