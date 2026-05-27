/**
 * Generic Instrument Subtree, For your pawn playing instruments
 *
 * Requires at least a living mob that can hold items.
 *
 * relevant blackboards:
 * * BB_SONG_INSTRUMENT - set by this subtree, is the song datum the pawn plays music from.
 * * BB_SONG_LINES - not set by this subtree, is the song loaded into the song datum.
 */
/datum/ai_planning_subtree/generic_play_instrument/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/obj/item/instrument/song_player = controller.blackboard[BB_SONG_INSTRUMENT]

	if(!song_player)
		controller.queue_behavior(/datum/ai_behavior/find_and_set/in_hands, BB_SONG_INSTRUMENT, /obj/item/instrument)
		return //we can't play a song since we do not have an instrument

	var/list/parsed_song_lines = splittext(controller.blackboard[BB_SONG_LINES], "\n")
	popleft(parsed_song_lines) //remove BPM as it is parsed out
	if(!compare_list(song_player.song.lines, parsed_song_lines) || !song_player.song.repeat)
		controller.queue_behavior(/datum/ai_behavior/setup_instrument, BB_SONG_INSTRUMENT, BB_SONG_LINES)

	if(!song_player.song.playing) //we may stop playing if we weren't playing before, were setting up dk theme, or ran out of repeats (also causing setup behavior)
		controller.queue_behavior(/datum/ai_behavior/play_instrument, BB_SONG_INSTRUMENT)

/datum/ai_planning_subtree/generic_play_instrument/end_planning

/datum/ai_planning_subtree/generic_play_instrument/end_planning/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	. = ..()
	if (controller.blackboard_key_exists(BB_SONG_INSTRUMENT))
		return SUBTREE_RETURN_FINISH_PLANNING // Don't plan anything else if we're playing an instrument

/datum/ai_behavior/setup_instrument

/datum/ai_behavior/play_instrument

/**
 * Generic Resist Subtree, resist if it makes sense to!
 *
 * Requires nothing beyond a living pawn, makes sense on a good amount of mobs since anything can get buckled.
 *
 * relevant blackboards:
 * * None!
 */
/datum/ai_planning_subtree/generic_resist/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/living_pawn = controller.pawn

	if(SHOULD_RESIST(living_pawn) && SPT_PROB(RESIST_SUBTREE_PROB, seconds_per_tick))
		controller.queue_behavior(/datum/ai_behavior/resist) //BRO IM ON FUCKING FIRE BRO
		return SUBTREE_RETURN_FINISH_PLANNING //IM NOT DOING ANYTHING ELSE BUT EXTINGUISH MYSELF, GOOD GOD HAVE MERCY.

/datum/bt_node/subtree/generic_hunger
	behavior_tree_json = "generic_hunger.bt.json"

/datum/bt_node/subtree/generic_play_instrument
	behavior_tree_json = "generic_play_instrument.bt.json"
