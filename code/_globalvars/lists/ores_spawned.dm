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
		/datum/material/iron = 14,
		/datum/material/glass = 13,
		/datum/material/plasma = 10,
		/datum/material/silver = 7,
		/datum/material/titanium = 6,
		/datum/material/gold = 5,
		/datum/material/uranium = 4,
		/datum/material/plastic = 1,
	))

GLOBAL_LIST_INIT(ore_vent_minerals_triple_z, list(
		/datum/material/iron = 25,
		/datum/material/glass = 24,
		/datum/material/plasma = 17,
		/datum/material/titanium = 10,
		/datum/material/silver = 10,
		/datum/material/gold = 8,
		/datum/material/uranium = 5,
		/datum/material/plastic = 1,
	))
