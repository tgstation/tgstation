/datum/round_event_control/wizard/darkness
	name = "Advanced Darkness"
	weight = 2
	typepath = /datum/round_event/wizard/darkness
	max_occurrences = 2
	earliest_start = 0

/datum/round_event/wizard/darkness
	endWhen = 0

/datum/round_event/wizard/darkness/start()
	var/datum/weather/advanced_darkness/darkness = new
	darkness.weather_start_up()
	return
