/**
 * # Virtual Domains
 * This loads a base level, then users can select the preset upon it.
 * You can find the map template to build your own in the '_maps/virtual_domains' folder.
 * When you are finished, add its traits to the domains.dm file here.
 */
/datum/map_template/virtual_domain
	/// Cost of this map to load
	var/cost = 0
	/// The description of the map
	var/desc = "A map."
	/// The map file to load
	var/filename = "virtual_domain.dmm"
	/// For blacklisting purposes
	var/id

/datum/map_template/virtual_domain/New()
	if(!name && id)
		name = id

	mappath = "_maps/virtual_domains/" + filename
	..(path = mappath)

/turf/closed/indestructible/binary
	name = "tear in the fabric of reality"
	icon = 'icons/turf/floors.dmi'
	icon_state = "binary"
