GLOBAL_LIST_INIT(electrolyzer_reactions, electrolyzer_reactions_list())

/*
 * Global proc to build the electrolyzer reactions list
 */
/proc/electrolyzer_reactions_list()
	. = list()
	for(var/reaction_path in subtypesof(/datum/electrolyzer_reaction))
		var/datum/electrolyzer_reaction/reaction = new reaction_path()

		.[reaction.id] = reaction

/datum/electrolyzer_reaction
	var/list/requirements
	var/name = "reaction"
	var/id = "r"

/datum/electrolyzer_reaction/proc/react(turf/location, working_power, delta_time)

/datum/electrolyzer_reaction/h2o_conversion
	name = "H2O Conversion"
	id = "h2o_conversion"
	requirements = list(
		/datum/gas/water_vapor = MINIMUM_MOLE_COUNT
	)

/datum/electrolyzer_reaction/h2o_conversion/react(turf/location, working_power, delta_time)

	var/datum/gas_mixture/air_mixture = location.return_air()

	air_mixture.assert_gases(/datum/gas/water_vapor, /datum/gas/oxygen, /datum/gas/hydrogen)
	var/proportion = min(air_mixture.gases[/datum/gas/water_vapor][MOLES], (1.5 * delta_time * working_power))//Works to max 12 moles at a time.
	air_mixture.gases[/datum/gas/water_vapor][MOLES] -= proportion * 2 * working_power
	air_mixture.gases[/datum/gas/oxygen][MOLES] += proportion * working_power
	air_mixture.gases[/datum/gas/hydrogen][MOLES] += proportion * 2 * working_power

/datum/electrolyzer_reaction/nob_conversion
	name = "Hypernob conversion"
	id = "nob_conversion"
	requirements = list(
		/datum/gas/hypernoblium = MINIMUM_MOLE_COUNT
	)

/datum/electrolyzer_reaction/nob_conversion/react(turf/location, working_power, delta_time)

	var/datum/gas_mixture/air_mixture = location.return_air()

	air_mixture.assert_gases(/datum/gas/hypernoblium, /datum/gas/antinoblium)
	var/proportion = min(air_mixture.gases[/datum/gas/hypernoblium][MOLES], (1.5 * delta_time * working_power))//Works to max 12 moles at a time.
	air_mixture.gases[/datum/gas/hypernoblium][MOLES] -= proportion * working_power
	air_mixture.gases[/datum/gas/antinoblium][MOLES] += proportion * working_power
