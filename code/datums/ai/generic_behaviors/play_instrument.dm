/// Starts playing the song loaded into a blackboard-keyed instrument.
/datum/bt_node/ai_behavior/play_instrument
	var/volume = 50
	/// Blackboard key holding the instrument to play.
	var/song_instrument_key

/datum/bt_node/ai_behavior/play_instrument/perform(seconds_per_tick, datum/ai_controller/controller)
	var/obj/item/instrument/song_instrument = controller.blackboard[song_instrument_key]
	var/datum/song/song = song_instrument.song
	song.volume = volume

	song.start_playing(controller.pawn)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
