/datum/looping_sound/local_forecast
	start_sound = 'sound/ambience/music/local_forecast/local_forecast1.ogg'
	start_length = 5.83 SECONDS

	mid_sounds = list(
		'sound/ambience/music/local_forecast/local_forecast2.ogg' = 6,
		'sound/ambience/music/local_forecast/local_forecast3.ogg' = 5,
		'sound/ambience/music/local_forecast/local_forecast4.ogg' = 4,
		'sound/ambience/music/local_forecast/local_forecast5.ogg' = 3,
		'sound/ambience/music/local_forecast/local_forecast6.ogg' = 2,
		'sound/ambience/music/local_forecast/local_forecast7.ogg' = 1,
	)
	mid_length = 5.83 SECONDS

	end_sound = 'sound/ambience/music/local_forecast/local_forecast8.ogg'

	volume = 20
	falloff_exponent = 5
	falloff_distance = 3
	vary = FALSE
	ignore_walls = FALSE
	use_reverb = FALSE
	each_once = TRUE
