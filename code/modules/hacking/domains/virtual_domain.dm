/datum/map_template/virtual_domain
	/// For blacklisting purposes
	var/id
	/// The map file to load
	var/filename
	/// Weight that this map will be spawned
	var/cost = 0
	/// The description of the map
	var/description = "A map."

/datum/map_template/virtual_domain/New()
	if(!name && id)
		name = id

	mappath = "_maps/virtual_domains/" + filename
	..(path = mappath)

/datum/map_template/virtual_domain/gondola
	name = "Gondola Forest"
	id = "gondola"
	description = "A bountiful forest of gondolas. Peaceful."
	filename = "gondola_asteroid.dmm"
