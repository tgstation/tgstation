/proc/station_name()
	if (station_name)
		return station_name

	var/name = "NSS Exodus"

	station_name = name

	if (config && config.server_name)
		world.name = "[config.server_name]: [name]"
	else
		world.name = "Baystation12"

	return name

/proc/world_name(var/name)

	if (config && config.server_name)
		world.name = "[config.server_name]: [name]"
	else
		world.name = name

	return name
