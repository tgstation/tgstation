/datum/round_event_control/disaster/molten
	name = "Molten Heat"
	weight = 40
	typepath = /datum/round_event/disaster/molten
	max_occurrences = 1000
	earliest_start = 10 MINUTES
	gamemode_whitelist = list("disaster")

/datum/round_event/disaster/molten
	endWhen = 0
	var/started = FALSE

/datum/round_event/disaster/molten/start()
	if(!started)
		started = TRUE
		SSweather.run_weather(/datum/weather/floor_is_lava/molten)
