/datum/round_event_control/radiation_storm
	name = "Radiation Storm"
	typepath = /datum/round_event/radiation_storm
	max_occurrences = 1

/datum/round_event/radiation_storm


/datum/round_event/radiation_storm/setup()
	startWhen = 3
	endWhen = startWhen + 1
	announceWhen = 1

/datum/round_event/radiation_storm/announce(fake)
	priority_announce("High levels of radiation detected near the station, you have 60 seconds to take shelter at the Bar and Kitchen, and enjoy the wonderful food and drink the staff have made!", "Anomaly Alert", ANNOUNCER_RADIATION)
	//sound not longer matches the text, but an audible warning is probably good

/datum/round_event/radiation_storm/start()
	SSweather.run_weather(/datum/weather/rad_storm)
