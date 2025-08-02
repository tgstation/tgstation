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

/datum/looping_sound/snowstorm
	mid_sounds = list(
		'sound/ambience/weather/snowstorm/snow1.ogg' = 1,
		'sound/ambience/weather/snowstorm/snow2.ogg' = 1,
		'sound/ambience/weather/snowstorm/snow3.ogg' = 1,
		'sound/ambience/weather/snowstorm/snow4.ogg' = 1,
		'sound/ambience/weather/snowstorm/snow5.ogg' = 1,
		'sound/ambience/weather/snowstorm/snow6.ogg' = 1,
		'sound/ambience/weather/snowstorm/snow7.ogg' = 1,
		'sound/ambience/weather/snowstorm/snow8.ogg' = 1,
		'sound/ambience/weather/snowstorm/snow9.ogg' = 1,
	)
	mid_length = 10 SECONDS
	volume = 30
	sound_channel = CHANNEL_WEATHER
	/// Dynamically adjust the length of the sound to appropriate values
	var/list/sound_to_length = list(
		'sound/ambience/weather/snowstorm/snow1.ogg' = 11.3 SECONDS,
		'sound/ambience/weather/snowstorm/snow2.ogg' = 9.7 SECONDS,
		'sound/ambience/weather/snowstorm/snow3.ogg' = 9.7 SECONDS,
		'sound/ambience/weather/snowstorm/snow4.ogg' = 7.3 SECONDS,
		'sound/ambience/weather/snowstorm/snow5.ogg' = 7.3 SECONDS,
		'sound/ambience/weather/snowstorm/snow6.ogg' = 8.8 SECONDS,
		'sound/ambience/weather/snowstorm/snow7.ogg' = 11.6 SECONDS,
		'sound/ambience/weather/snowstorm/snow8.ogg' = 11.6 SECONDS,
		'sound/ambience/weather/snowstorm/snow9.ogg' = 7.3 SECONDS,
	)

// hijacking sound loop code to run loops of varying length
// doing this because set_mid_length can't run DURING a soundloop, which means we can't variably adjust the length of the sound
/datum/looping_sound/snowstorm/start_sound_loop()
	loop_started = TRUE
	sound_loop()

/datum/looping_sound/snowstorm/sound_loop(start_time)
	if(!loop_started)
		return
	var/picked_sound = get_sound()
	play(picked_sound)
	if(sound_to_length[picked_sound])
		timer_id = addtimer(CALLBACK(src, PROC_REF(sound_loop)), sound_to_length[picked_sound], TIMER_CLIENT_TIME | TIMER_STOPPABLE | TIMER_DELETE_ME, SSsound_loops)

/datum/looping_sound/rain
	start_sound = 'sound/ambience/weather/rain/rain_start.ogg'
	start_length = 12.5 SECONDS
	mid_sounds = 'sound/ambience/weather/rain/rain_mid.ogg'
	mid_length = 15 SECONDS
	end_sound = 'sound/ambience/weather/rain/rain_end.ogg'
	volume = 70
	sound_channel = CHANNEL_WEATHER

/datum/looping_sound/rain/start
	mid_sounds = 'sound/ambience/weather/rain/rain_start.ogg'
	mid_length = 12.5 SECONDS

/datum/looping_sound/rain/middle
	mid_sounds = 'sound/ambience/weather/rain/rain_mid.ogg'
	mid_length = 15 SECONDS

/datum/looping_sound/rain/end
	mid_sounds = 'sound/ambience/weather/rain/rain_end.ogg'
	mid_length = 17 SECONDS
