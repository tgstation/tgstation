/**
 * # Safe Houses
 * The starting point for virtual domains.
 * Create your own: Read the readme file in the '_maps/safehouses' folder.
 */
/datum/map_template/safehouse
	name = "virtual domain: safehouse"

	/// The map file to load
	var/filename = "den"

/datum/map_template/safehouse/New()
	mappath = "_maps/safehouses/[filename].dmm"
	..(path = mappath)

/datum/map_template/safehouse/test_only
	filename = "test_only_safehouse.dmm"

/// The default safehouse map template.
/datum/map_template/safehouse/den
	filename = "den"

/datum/map_template/safehouse/wood
	filename = "wood"

/datum/map_template/safehouse/dig
	filename = "dig"

/datum/map_template/safehouse/shuttle
	filename = "shuttle"

// Has space tiles on the four corners.
/datum/map_template/safehouse/shuttle_space
	filename = "shuttle_space"

/datum/map_template/safehouse/mine
	filename = "mine"

// Comes preloaded with mining combat gear.
/datum/map_template/safehouse/lavaland_boss
	filename = "lavaland_boss"

// Chill out
/datum/map_template/safehouse/ice
	filename = "ice"

/datum/map_template/safehouse/bathroom
	filename = "bathroom"

/**
 * Your safehouse here
 * /datum/map_template/safehouse/your_type
 *  filename = "your_map"
 */
