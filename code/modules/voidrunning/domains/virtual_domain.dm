/datum/map_template/virtual_domain
	/// Cost of this map to load
	var/cost = 0
	/// The description of the map
	var/desc = "A map."
	/// The map file to load
	var/filename
	/// For blacklisting purposes
	var/id

/datum/map_template/virtual_domain/New()
	if(!name && id)
		name = id

	mappath = "_maps/virtual_domains/" + filename
	..(path = mappath)

/datum/map_template/virtual_domain/gondola
	name = "Gondola Forest"
	desc = "A bountiful forest of gondolas. Peaceful."
	filename = "gondola_asteroid.dmm"
	id = "gondola"
