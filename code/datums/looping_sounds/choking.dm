/datum/looping_sound/choking
	mid_sounds = list('sound/mobs/humanoids/human/gag_vomit/gag1.ogg' = 1, 'sound/mobs/humanoids/human/gag_vomit/gag2.ogg' = 1, 'sound/mobs/humanoids/human/gag_vomit/gag3.ogg' = 1, 'sound/mobs/humanoids/human/gag_vomit/gag4.ogg' = 1, 'sound/mobs/humanoids/human/gag_vomit/gag5.ogg' = 1)
	mid_length = 1.6 SECONDS
	mid_length_vary = 0.3 SECONDS
	each_once = TRUE
	volume = 90
	// We want you to be hard to hear far away
	falloff_exponent = 12
	pressure_affected = TRUE
	vary = TRUE
	// Same as above
	ignore_walls = FALSE
