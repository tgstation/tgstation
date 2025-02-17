/datum/looping_sound/active_outside_ashstorm
	mid_sounds = list(
		'sound/ambience/weather/ashstorm/outside/active_mid1.ogg'=1,
		'sound/ambience/weather/ashstorm/outside/active_mid1.ogg'=1,
		'sound/ambience/weather/ashstorm/outside/active_mid1.ogg'=1
		)
	mid_length = 8 SECONDS
	start_sound = 'sound/ambience/weather/ashstorm/outside/active_start.ogg'
	start_length = 13 SECONDS
	end_sound = 'sound/ambience/weather/ashstorm/outside/active_end.ogg'
	volume = 80

/datum/looping_sound/active_inside_ashstorm
	mid_sounds = list(
		'sound/ambience/weather/ashstorm/inside/active_mid1.ogg'=1,
		'sound/ambience/weather/ashstorm/inside/active_mid2.ogg'=1,
		'sound/ambience/weather/ashstorm/inside/active_mid3.ogg'=1
		)
	mid_length = 8 SECONDS
	start_sound = 'sound/ambience/weather/ashstorm/inside/active_start.ogg'
	start_length = 13 SECONDS
	end_sound = 'sound/ambience/weather/ashstorm/inside/active_end.ogg'
	volume = 60

/datum/looping_sound/weak_outside_ashstorm
	mid_sounds = list(
		'sound/ambience/weather/ashstorm/outside/weak_mid1.ogg'=1,
		'sound/ambience/weather/ashstorm/outside/weak_mid2.ogg'=1,
		'sound/ambience/weather/ashstorm/outside/weak_mid3.ogg'=1
		)
	mid_length = 8 SECONDS
	start_sound = 'sound/ambience/weather/ashstorm/outside/weak_start.ogg'
	start_length = 13 SECONDS
	end_sound = 'sound/ambience/weather/ashstorm/outside/weak_end.ogg'
	volume = 50

/datum/looping_sound/weak_inside_ashstorm
	mid_sounds = list(
		'sound/ambience/weather/ashstorm/inside/weak_mid1.ogg'=1,
		'sound/ambience/weather/ashstorm/inside/weak_mid2.ogg'=1,
		'sound/ambience/weather/ashstorm/inside/weak_mid3.ogg'=1
		)
	mid_length = 8 SECONDS
	start_sound = 'sound/ambience/weather/ashstorm/inside/weak_start.ogg'
	start_length = 13 SECONDS
	end_sound = 'sound/ambience/weather/ashstorm/inside/weak_end.ogg'
	volume = 30

/datum/looping_sound/void_loop
	mid_sounds = list('sound/music/antag/heretic/VoidsEmbrace.ogg'=1)
	mid_length = 166.9 SECONDS // exact length of the music in ticks
	volume = 100
	extra_range = 30

/datum/looping_sound/rain
	start_sound = 'sound/ambience/weather/rain/rain_start.ogg'
	start_length = 12.5 SECONDS
	mid_sounds = 'sound/ambience/weather/rain/rain_mid.ogg'
	mid_length = 15 SECONDS
	end_sound = 'sound/ambience/weather/rain/rain_end.ogg'
	volume = 70
	//sound_channel = CHANNEL_WEATHER (add this after Melbert's snow sound PR is finished)

/datum/looping_sound/rain/start
	mid_sounds = 'sound/ambience/weather/rain/rain_start.ogg'
	mid_length = 12.5 SECONDS

/datum/looping_sound/rain/middle
	mid_sounds = 'sound/ambience/weather/rain/rain_mid.ogg'
	mid_length = 15 SECONDS

/datum/looping_sound/rain/end
	mid_sounds = 'sound/ambience/weather/rain/rain_end.ogg'
	mid_length = 17 SECONDS
