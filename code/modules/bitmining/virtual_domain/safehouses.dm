
/**
 * # Safe Houses
 * The starting point for virtual domains.
 * Create your own: Read the readme file in the '_maps/safehouses' folder.
 */
/datum/map_template/safehouse
	name = "virtual domain: safehouse"
	/// The map file to load
	var/filename = "wood.dmm"

/datum/map_template/safehouse/New()
	mappath = "_maps/safehouses/" + filename
	..(path = mappath)

/// The default safehouse map template.
/datum/map_template/safehouse/wood

/**
 * Your safehouse here
 * /datum/map_template/safehouse/your_type
 *  filename = "your_map.dmm"
 */
