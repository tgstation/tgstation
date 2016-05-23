/datum/round_event_control/wizard/lava //THE LEGEND NEVER DIES
	name = "The Floor Is LAVA!"
	weight = 2
	typepath = /datum/round_event/wizard/lava/
	max_occurrences = 3
	earliest_start = 0

/datum/round_event/wizard/lava/
	endWhen = 0
	var/started = FALSE

/datum/round_event/wizard/lava/start()
	if(!started)
		started = TRUE
		var/datum/weather/floor_is_lava/LAVA = new /datum/weather/floor_is_lava
		LAVA.weather_start_up()
