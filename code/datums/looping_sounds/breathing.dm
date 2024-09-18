/datum/looping_sound/breathing
	mid_sounds = list(
		'sound/voice/breathing/internals_breathing1.ogg' = 1,
		'sound/voice/breathing/internals_breathing2.ogg' = 1,
		'sound/voice/breathing/internals_breathing3.ogg' = 1,
		'sound/voice/breathing/internals_breathing4.ogg' = 1,
		'sound/voice/breathing/internals_breathing5.ogg' = 1,
		'sound/voice/breathing/internals_breathing6.ogg' = 1,
		'sound/voice/breathing/internals_breathing7.ogg' = 1,
		'sound/voice/breathing/internals_breathing8.ogg' = 1,
	)
	//Calculated this by using the average breathing time of an adult (12 to 20 per minute, which on average is 16 per minute)
	//  realism is overrated, make it longer to reduce ear fatigue
	mid_length = 7 SECONDS
	mid_length_vary = 0.7 SECONDS
	//spess station-
	volume = 7
	pressure_affected = FALSE
	vary = TRUE
