/// Parses and loads a song into a blackboard-keyed instrument, preparing it for playback.
/datum/bt_node/ai_behavior/setup_instrument
	/// Blackboard key holding the instrument to load the song into.
	var/song_instrument_key
	/// Blackboard key holding the song lines to parse.
	var/song_lines_key

/datum/bt_node/ai_behavior/setup_instrument/perform(seconds_per_tick, datum/ai_controller/controller)
	var/obj/item/instrument/song_instrument = controller.blackboard[song_instrument_key]
	var/datum/song/song = song_instrument.song
	var/song_lines = controller.blackboard[song_lines_key]

	//just in case- it won't do anything if the instrument isn't playing
	song.stop_playing()
	song.ParseSong(new_song = song_lines)
	song.repeat = 10
	song.volume = song.max_volume - 10
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
