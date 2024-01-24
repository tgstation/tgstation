/**
 * Sets of global lists breaking down the base spawning distributions for various maps and stations.
 *
 * Currently used for ore vents on roundstart when the map is generated. (See ore_vent.dm, seedRuins() and ore_generation.dm)
 * Ore vent lists here are copied to ore_vent_minerals on ruin seeding,
 * in order to dynamically adjust the spawn rates as materials are picked and set a global ore distribution from vents.
 *
 * By default vents pull 4 unique materials each, but this can vary with subtypes.
 */

GLOBAL_LIST_INIT(ore_vent_minerals_lavaland, list(
		/datum/material/iron = 13,
		/datum/material/glass = 12,
		/datum/material/plasma = 9,
		/datum/material/titanium = 6,
		/datum/material/silver = 5,
		/datum/material/gold = 5,
		/datum/material/diamond = 3,
		/datum/material/uranium = 3,
		/datum/material/bluespace = 3,
		/datum/material/plastic = 1,
	))

GLOBAL_LIST_INIT(ore_vent_minerals_icebox_upper, list(
		/datum/material/iron = 4,
		/datum/material/glass = 4,
		/datum/material/plasma = 2,
		/datum/material/titanium = 2,
		/datum/material/silver = 1,
		/datum/material/gold = 1,
		/datum/material/diamond = 1,
		/datum/material/uranium = 1,
	))

GLOBAL_LIST_INIT(ore_vent_minerals_icebox_lower, list(
		/datum/material/iron = 20,
		/datum/material/glass = 19,
		/datum/material/plasma = 14,
		/datum/material/titanium = 8,
		/datum/material/silver = 7,
		/datum/material/gold = 6,
		/datum/material/diamond = 3,
		/datum/material/uranium = 3,
		/datum/material/bluespace = 3,
		/datum/material/plastic = 1,
	))
