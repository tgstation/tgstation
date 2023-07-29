/**
 * # Virtual Domains
 * This loads a base level, then users can select the preset upon it.
 * Create your own: Read the readme file in the '_maps/virtual_domains' folder.
 */
/datum/map_template/virtual_domain
	name = "virtual domain"

	returns_created_atoms = TRUE
	/// Cost of this map to load
	var/cost = BITMINING_COST_NONE
	/// The description of the map
	var/desc = "A map."
	/// The 'difficulty' of the map, which affects the ui and ability to scan info.
	var/difficulty = BITMINING_DIFFICULTY_NONE
	/// Any additional loot to add after completion
	var/extra_loot
	/// The map file to load
	var/filename = "virtual_domain.dmm"
	/// Any outfit that you wish to force on avatars. Overrides preferences
	var/datum/outfit/forced_outfit
	/// Information given to connected clients via ability
	var/help_text
	/// For blacklisting purposes
	var/id
	/// Points to reward for completion. Used to purchase new domains and calculate ore rewards.
	var/reward_points = BITMINING_REWARD_LOW
	/// This map is specifically for unit tests. Shouldn't display in game
	var/test_only = FALSE
	/// The safehouse to load into the map
	var/datum/map_template/safehouse/safehouse_path = /datum/map_template/safehouse

/datum/map_template/virtual_domain/New()
	if(!name && id)
		name = id

	mappath = "_maps/virtual_domains/" + filename
	..(path = mappath)

/turf/closed/indestructible/binary
	name = "tear in the fabric of reality"
	icon = 'icons/turf/floors.dmi'
	icon_state = "binary"
