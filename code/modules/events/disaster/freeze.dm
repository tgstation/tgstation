/datum/round_event_control/disaster/freeze
	name = "Frozen Vapors"
	weight = 2
	typepath = /datum/round_event/disaster/freeze
	max_occurrences = -1
	earliest_start = 5 MINUTES
	gamemode_whitelist = list("disaster")

/datum/round_event/disaster/freeze
	endWhen = 0
	var/started = FALSE

/datum/round_event/disaster/freeze/start()
	if(!started)
		started = TRUE
		SSweather.run_weather(/datum/weather/snow_storm/freeze)
