/datum/round_event_control/disaster/radiation_cloud
	name = "Radiation Vortex"
	weight = 40
	typepath = /datum/round_event/disaster/radiation_cloud
	max_occurrences = 1000
	earliest_start = 10 MINUTES
	gamemode_whitelist = list("disaster")

/datum/round_event/disaster/radiation_cloud
	endWhen = 0
	var/started = FALSE

/datum/round_event/disaster/radiation_cloud/start()
	if(!started)
		started = TRUE
		SSweather.run_weather(/datum/weather/rad_storm/cloud)
