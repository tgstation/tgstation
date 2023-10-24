/// Soundloop for the fire (bonfires, fireplaces, etc.)
/datum/looping_sound/burning
	start_sound = 'sound/items/match_strike.ogg'
	start_length = 3 SECONDS
	mid_sounds = 'sound/effects/comfyfire.ogg'
	mid_length = 5 SECONDS
	volume = 50
	vary = TRUE
	extra_range = MEDIUM_RANGE_SOUND_EXTRARANGE
