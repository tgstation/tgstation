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
	requirements = list(
		/datum/gas/water_vapor = MINIMUM_MOLE_COUNT
	)

/datum/electrolyzer_reaction/h2o_conversion/react(turf/location, datum/gas_mixture/air_mixture, working_power)

	air_mixture.assert_gases(/datum/gas/water_vapor, /datum/gas/oxygen, /datum/gas/hydrogen)
	var/proportion = min(air_mixture.gases[/datum/gas/water_vapor][MOLES], (2.5 * (working_power ** 2)))
	air_mixture.gases[/datum/gas/water_vapor][MOLES] -= proportion * 2
	air_mixture.gases[/datum/gas/oxygen][MOLES] += proportion
	air_mixture.gases[/datum/gas/hydrogen][MOLES] += proportion * 2

/datum/electrolyzer_reaction/nob_conversion
	name = "Hypernob conversion"
	id = "nob_conversion"
	requirements = list(
		/datum/gas/hypernoblium = MINIMUM_MOLE_COUNT,
		"MAX_TEMP" = 150
	)

/datum/electrolyzer_reaction/nob_conversion/react(turf/location, datum/gas_mixture/air_mixture, working_power)

	air_mixture.assert_gases(/datum/gas/hypernoblium, /datum/gas/antinoblium)
	var/proportion = min(air_mixture.gases[/datum/gas/hypernoblium][MOLES], (1.5 * (working_power ** 2)))
	air_mixture.gases[/datum/gas/hypernoblium][MOLES] -= proportion
	air_mixture.gases[/datum/gas/antinoblium][MOLES] += proportion * 0.5
