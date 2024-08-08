/datum/looping_sound/breathing
	mid_sounds = pick
	(
		'sound/voice/breathing/breath1.ogg',
		'sound/voice/breathing/breath2.ogg',
		'sound/voice/breathing/breath3.ogg',
		'sound/voice/breathing/breath4.ogg',
		'sound/voice/breathing/breath5.ogg',
		'sound/voice/breathing/breath6.ogg',
		'sound/voice/breathing/breath7.ogg',
	)
	//Calculated this by using the average breathing time of an adult (12 to 20 per minute, which on average is 16 per minute)
	mid_length = 3.75 SECONDS
	mid_length_vary = 0.7 SECONDS
	//spess station-
	volume = 13
	pressure_affected = FALSE
