/proc/station_name()
	if (station_name)
		return station_name

	var/name = "Baystation 12"

	station_name = name

	if (config && config.server_name)
		world.name = "[config.server_name]: [name]"
	else
		world.name = name

	return name

/proc/world_name(var/name)

	station_name = name

	if (config && config.server_name)
		world.name = "[config.server_name]: [name]"
	else
		world.name = name

	return name
