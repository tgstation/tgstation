/// Soundloop for the fire (bonfires, fireplaces, etc.)
/datum/looping_sound/burning
	start_sound = 'sound/items/match_strike.ogg'
	start_length = 3 SECONDS
	mid_sounds = 'sound/effects/comfyfire.ogg'
	mid_length = 5 SECONDS
	volume = 50
	vary = TRUE
	extra_range = MEDIUM_RANGE_SOUND_EXTRARANGE
	use_sound_tokens = TRUE

// soundloop used for jet boots flight.
/datum/looping_sound/burning_jet
	start_sound = 'sound/items/jet_ignite.ogg'
	start_length = 1.2 SECONDS
	mid_sounds = 'sound/items/jet_active.ogg'
	mid_length = 2.4 SECONDS
	end_sound = 'sound/items/jet_off.ogg'
	volume = 15
