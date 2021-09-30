/datum/ai_planning_subtree/play_instrument/SelectBehaviors(datum/ai_controller/monkey/controller, delta_time)
	var/mob/living/living_pawn = controller.pawn
	var/obj/item/instrument/song_player = locate(/obj/item/instrument) in living_pawn.held_items
	if(!song_player)
		controller.blackboard[BB_SONG_DATUM] = null
		return //we can't play a song since we do not have an instrument

	controller.blackboard[BB_SONG_DATUM] = song_player.song

	var/list/donkey_kong_lines = splittext(MONKEY_SONG, "\n")
	popleft(donkey_kong_lines) //remove BPM as it is parsed out
	if(!compare_list(song_player.song.lines, donkey_kong_lines) || !song_player.song.repeat)
		controller.queue_behavior(/datum/ai_behavior/setup_instrument, BB_SONG_DATUM, BB_SONG_LINES)

	if(!song_player.song.playing) //we may stop playing if we weren't playing before, were setting up dk theme, or ran out of repeats (also causing setup behavior)
		controller.queue_behavior(/datum/ai_behavior/play_instrument, BB_SONG_DATUM)
