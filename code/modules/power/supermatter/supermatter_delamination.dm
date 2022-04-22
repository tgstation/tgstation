/datum/supermatter_delamination
	var/supermatter_power = 0
	var/anomalies_to_spawn = 10

/datum/supermatter_delamination/New(power)
	. = ..()
	if(power)
		supermatter_power = power
	setup_anomalies()

/datum/supermatter_delamination/proc/setup_anomalies()
	anomalies_to_spawn = max(round(0.005 * supermatter_power, 1) + rand(-2, 5), 1)
	spawn_anomalies()

/datum/supermatter_delamination/proc/spawn_anomalies()
	var/list/anomaly_types = list(FLUX_ANOMALY = 75, GRAVITATIONAL_ANOMALY = 55, PYRO_ANOMALY = 5, VORTEX_ANOMALY = 1)
	var/list/anomaly_places = GLOB.generic_event_spawns
	var/currently_spawning_anomalies = round(anomalies_to_spawn * 0.5, 1)
	anomalies_to_spawn -= currently_spawning_anomalies
	for(var/i in 1 to currently_spawning_anomalies)
		var/anomaly_to_spawn = pick_weight(anomaly_types)
		var/anomaly_location = pick_n_take(anomaly_places)
		supermatter_anomaly_gen(anomaly_location, anomaly_to_spawn, has_changed_lifespan = FALSE)

	spawn_overtime()

/datum/supermatter_delamination/proc/spawn_overtime()

	var/list/anomaly_types = list(FLUX_ANOMALY = 75, GRAVITATIONAL_ANOMALY = 55, PYRO_ANOMALY = 5, VORTEX_ANOMALY = 1)
	var/list/anomaly_places = GLOB.generic_event_spawns

	var/current_spawn = rand(5 SECONDS, 10 SECONDS)
	for(var/i in 1 to anomalies_to_spawn)
		var/anomaly_to_spawn = pick_weight(anomaly_types)
		var/anomaly_location = pick_n_take(anomaly_places)
		var/next_spawn = rand(5 SECONDS, 10 SECONDS)
		var/extended_spawn = 0
		if(DT_PROB(1, next_spawn))
			extended_spawn = rand(5 MINUTES, 15 MINUTES)
		addtimer(CALLBACK(src, .proc/spawn_anomaly, anomaly_location, anomaly_to_spawn), current_spawn + extended_spawn)
		current_spawn += next_spawn

/datum/supermatter_delamination/proc/spawn_anomaly(location, type)
	supermatter_anomaly_gen(location, type, has_changed_lifespan = FALSE)
