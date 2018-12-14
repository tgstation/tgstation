/datum/weather/snow_storm
	name = "snow storm"
	desc = "'Harsh' snowstorms roam the topside of this arctic planet, 'burying' any area unfortunate enough to be in its path."
	probability = 90

	telegraph_message = "<span class='notice'>Drifting particles of snow begin to dust the surrounding area..</span>"
	telegraph_duration = 300
	telegraph_overlay = "light_snow"

	weather_message = "<span class='notice'>Snow begins falling from above in intricate patterns.</span>"
	weather_overlay = "snow_storm"
	weather_duration_lower = 600
	weather_duration_upper = 1500

	end_duration = 100
	end_message = "<span class='boldannounce'>The snowfall dies down.</span>"

	area_type = /area/awaymission/snowdin/outside
	target_trait = ZTRAIT_STATION

	immunity_type = "snow"

	barometer_predictable = TRUE



