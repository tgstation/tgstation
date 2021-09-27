/**
 * Generic Instrument Subtree, For your pawn playing instruments
 *
 * Requires at least a living mob that can hold items.
 *
 * relevant blackboards:
 * * BB_SONG_DATUM - set by this subtree, is the song datum the pawn plays music from.
 * * BB_SONG_LINES - not set by this subtree, is the song loaded into the song datum.
 */
/datum/ai_planning_subtree/generic_play_instrument/SelectBehaviors(datum/ai_controller/controller, delta_time)
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
 * * BB_SONG_LINES - not set by this subtree, is the song loaded into the song datum.
 */
/datum/ai_planning_subtree/generic_hunger/SelectBehaviors(datum/ai_controller/controller, delta_time)
	var/mob/living/living_pawn = controller.pawn

	//inits the blackboard timer
	if(!controller.blackboard[BB_NEXT_HUNGRY])
		controller.blackboard[BB_NEXT_HUNGRY] = world.time + rand(0, 300)

	if(world.time < controller.blackboard[BB_NEXT_HUNGRY])
		return

	var/list/food_candidates = list()
	for(var/obj/item as anything in living_pawn.held_items)
		if(!item || !IsEdible(item))
			continue
		food_candidates += item

	for(var/obj/item/candidate in oview(2, living_pawn))
		if(!IsEdible(candidate))
			continue
		food_candidates += candidate

	if(length(food_candidates))
		var/obj/item/best_held = GetBestWeapon(controller, null, living_pawn.held_items)
		for(var/obj/item/held as anything in living_pawn.held_items)
			if(!held || held == best_held)
				continue
			living_pawn.dropItemToGround(held)

		controller.queue_behavior(/datum/ai_behavior/consume, pick(food_candidates), BB_NEXT_HUNGRY)
