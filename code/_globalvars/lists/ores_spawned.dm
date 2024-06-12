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

GLOBAL_LIST_INIT(ore_vent_minerals_triple_z, list(
		/datum/material/iron = 24,
		/datum/material/glass = 23,
		/datum/material/plasma = 16,
		/datum/material/titanium = 10,
		/datum/material/silver = 8,
		/datum/material/gold = 7,
		/datum/material/diamond = 4,
		/datum/material/uranium = 4,
		/datum/material/bluespace = 3,
		/datum/material/plastic = 1,
	))
