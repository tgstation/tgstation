/datum/round_event_control/disaster/molten
	name = "Molten Heat"
	weight = 2
	typepath = /datum/round_event/disaster/molten
	max_occurrences = 999
	earliest_start = 0 MINUTES
	gamemode_blacklist = list()
	gamemode_whitelist = list("disaster")

/datum/round_event/disaster/molten
	endWhen = 0
	var/started = FALSE

/datum/round_event/disaster/molten/start()
	if(!started)
		started = TRUE
		SSweather.run_weather(/datum/weather/floor_is_lava/molten)
