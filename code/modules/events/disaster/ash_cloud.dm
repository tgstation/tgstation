/datum/round_event_control/disaster/ash_cloud
	name = "Pyroclastic Nebula"
	weight = 2
	typepath = /datum/round_event/disaster/ash_cloud
	max_occurrences = -1
	earliest_start = 5 MINUTES
	gamemode_whitelist = list("disaster")

/datum/round_event/disaster/ash_cloud
	endWhen = 0
	var/started = FALSE

/datum/round_event/disaster/ash_cloud/start()
	if(!started)
		started = TRUE
		SSweather.run_weather(/datum/weather/ash_storm/cloud)
