/datum/looping_sound/wash
	mid_sounds = list('sound/creatures/cyborg/wash1.ogg' = 1, 'sound/creatures/cyborg/wash2.ogg' = 1)
	mid_length = 1.5 SECONDS // This makes them overlap slightly, which works out well for masking the fade in/out
	start_volume = 100
	start_sound = 'sound/creatures/cyborg/wash_start.ogg'
	start_length = 3.6 SECONDS // again, slightly shorter then the real time of 4 seconds, will make the transition to midsounds more seemless
	end_volume = 100
	end_sound = 'sound/creatures/cyborg/wash_end.ogg'
	vary = TRUE
	extra_range = 5
