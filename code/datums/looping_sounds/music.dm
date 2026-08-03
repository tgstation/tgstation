/** Boombox music */
/datum/looping_sound/boombox
	mid_sounds = list(
		'sound/music/boombox/industrial-crush.ogg' = 1,
	)
	mid_length = 31.9 SECONDS
	volume = 30
	vary = FALSE
	use_reverb = FALSE
	sound_channel = CHANNEL_JUKEBOX
	extra_range = MEDIUM_RANGE_SOUND_EXTRARANGE
	falloff_exponent = 6
	use_sound_tokens = TRUE

/datum/looping_sound/boombox/rock
	mid_sounds = list(
		'sound/music/boombox/bainmack-rock.ogg' = 1,
	)
	mid_length = 40.3 SECONDS
	volume = 30

/datum/looping_sound/boombox/hiphop
	mid_sounds = list(
		'sound/music/boombox/groovepad-hiphop.ogg' = 1,
	)
	mid_length = 73.0 SECONDS
	volume = 30

/datum/looping_sound/boombox/jazz
	mid_sounds = list(
		'sound/music/boombox/frankyboomer-jazz.ogg' = 1,
	)
	mid_length = 58.3 SECONDS
	volume = 30

/** Elevator music */
/datum/looping_sound/local_forecast
	mid_sounds = list(
		'sound/music/elevator/robocop-short.ogg' = 1,
	)
	mid_length = 61 SECONDS
	volume = 20
	vary = FALSE
	use_reverb = FALSE
	direct = TRUE
	sound_channel = CHANNEL_ELEVATOR
