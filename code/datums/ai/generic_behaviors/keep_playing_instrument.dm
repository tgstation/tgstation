/// Checks that a song instrument's song is still properly configured and playing.
/// Returns SUCCEEDED while the song is playing correctly, FAILED when it needs setup or restart.
/datum/bt_node/ai_behavior/keep_playing_instrument
	time_between_perform = 1 SECONDS
	/// Blackboard key holding the instrument being played.
	var/song_instrument_key

/datum/bt_node/ai_behavior/keep_playing_instrument/perform(seconds_per_tick, datum/ai_controller/controller)
	var/obj/item/instrument/song_player = controller.blackboard[song_instrument_key]
	if(QDELETED(song_player))
		controller.clear_blackboard_key(song_instrument_key)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	var/list/parsed_song_lines = splittext(controller.blackboard[BB_SONG_LINES], "\n")
	popleft(parsed_song_lines) // remove BPM as it is parsed out
	if(!compare_list(song_player.song.lines, parsed_song_lines) || !song_player.song.repeat)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	if(!song_player.song.playing)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
