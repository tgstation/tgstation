/// Starts playing the song loaded into a blackboard-keyed instrument.
/datum/ai_behavior/play_instrument

/datum/ai_behavior/play_instrument/perform(seconds_per_tick, datum/ai_controller/controller, song_instrument_key)
	var/obj/item/instrument/song_instrument = controller.blackboard[song_instrument_key]
	var/datum/song/song = song_instrument.song

	song.start_playing(controller.pawn)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
