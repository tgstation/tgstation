/**
 * # Virtual Domains
 * This loads a base level, then users can select the preset upon it.
 * Create your own: Read the readme file in the '_maps/virtual_domains' folder.
 */
/datum/map_template/virtual_domain
	name = "virtual domain"
	/// Cost of this map to load
	var/cost = BITMINING_COST_NONE
	/// The description of the map
	var/desc = "A map."
	/// The 'difficulty' of the map, which affects the ui and the types of ores that spawn in the rewards crate.
	var/difficulty = BITMINING_DIFFICULTY_NONE
	/// Any additional loot to add after completion
	var/extra_loot
	/// The map file to load
	var/filename = "virtual_domain.dmm"
	/// Information given to connected clients via ability
	var/help_text
	/// For blacklisting purposes
	var/id
	/// Points to reward for completion. These are used to purchase new domains, but also calculate ore rewards.
	var/reward_points = BITMINING_REWARD_LOW
	/// The safehouse to load into the map
	var/datum/map_template/safehouse/safehouse_path = /datum/map_template/safehouse/wood

/datum/map_template/virtual_domain/New()
	if(!name && id)
		name = id

	mappath = "_maps/virtual_domains/" + filename
	..(path = mappath)

/turf/closed/indestructible/binary
	name = "tear in the fabric of reality"
	icon = 'icons/turf/floors.dmi'
	icon_state = "binary"
