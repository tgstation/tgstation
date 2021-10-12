/**
 * Generic Instrument Subtree, For your pawn playing instruments
 *
 * Requires at least a living mob that can hold items.
 *
 * relevant blackboards:
 * * BB_SONG_INSTRUMENT - set by this subtree, is the song datum the pawn plays music from.
 * * BB_SONG_LINES - not set by this subtree, is the song loaded into the song datum.
 */
/datum/ai_planning_subtree/generic_play_instrument/SelectBehaviors(datum/ai_controller/controller, delta_time)
	if(!controller.blackboard[BB_SONG_INSTRUMENT])
		controller.queue_behavior(/datum/ai_behavior/find_and_set/in_hands, BB_SONG_INSTRUMENT, /obj/item/instrument)
		return //we can't play a song since we do not have an instrument

	var/obj/item/instrument/song_player = controller.blackboard[BB_SONG_INSTRUMENT]

	var/list/parsed_song_lines = splittext(controller.blackboard[BB_SONG_LINES], "\n")
	popleft(parsed_song_lines) //remove BPM as it is parsed out
	if(!compare_list(song_player.song.lines, parsed_song_lines) || !song_player.song.repeat)
		controller.queue_behavior(/datum/ai_behavior/setup_instrument, BB_SONG_INSTRUMENT, BB_SONG_LINES)

	if(!song_player.song.playing) //we may stop playing if we weren't playing before, were setting up dk theme, or ran out of repeats (also causing setup behavior)
		controller.queue_behavior(/datum/ai_behavior/play_instrument, BB_SONG_INSTRUMENT)

/**
 * Generic Resist Subtree, resist if it makes sense to!
 *
 * Requires nothing beyond a living pawn, makes sense on a good amount of mobs since anything can get buckled.
 *
 * relevant blackboards:
 * * None!
 */
/datum/ai_planning_subtree/generic_resist/SelectBehaviors(datum/ai_controller/controller, delta_time)
	var/mob/living/living_pawn = controller.pawn

	if(SHOULD_RESIST(living_pawn) && DT_PROB(RESIST_SUBTREE_PROB, delta_time))
		controller.queue_behavior(/datum/ai_behavior/resist) //BRO IM ON FUCKING FIRE BRO
		return SUBTREE_RETURN_FINISH_PLANNING //IM NOT DOING ANYTHING ELSE BUT EXTUINGISH MYSELF, GOOD GOD HAVE MERCY.

/**
 * Generic Hunger Subtree,
 *
 * Requires at least a living mob that can hold items.
 *
 * relevant blackboards:
 * * BB_NEXT_HUNGRY - set by this subtree, is when the controller is next hungry
 */
/datum/ai_planning_subtree/generic_hunger/SelectBehaviors(datum/ai_controller/controller, delta_time)
	//inits the blackboard timer
	if(!controller.blackboard[BB_NEXT_HUNGRY])
		controller.blackboard[BB_NEXT_HUNGRY] = world.time + rand(0, 30 SECONDS)

	if(world.time < controller.blackboard[BB_NEXT_HUNGRY])
		return

	if(!controller.blackboard[BB_FOOD_TARGET])
		controller.queue_behavior(/datum/ai_behavior/find_and_set/edible, BB_FOOD_TARGET, /obj/item, 2)
		return

	controller.queue_behavior(/datum/ai_behavior/drop_item)
	controller.queue_behavior(/datum/ai_behavior/consume, BB_FOOD_TARGET, BB_NEXT_HUNGRY)
	return SUBTREE_RETURN_FINISH_PLANNING
