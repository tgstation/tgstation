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

/**
 * Generic Hunger Subtree,
 *
 * Requires at least a living mob that can hold items.
 *
 * relevant blackboards:
 * * BB_NEXT_HUNGRY - set by this subtree, is when the controller is next hungry
 */
/datum/ai_planning_subtree/generic_hunger

/datum/ai_planning_subtree/generic_hunger/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/living_pawn = controller.pawn
	if(living_pawn.nutrition > NUTRITION_LEVEL_HUNGRY)
		return

	var/next_eat = controller.blackboard[BB_NEXT_HUNGRY]
	if(!next_eat)
		//inits the blackboard timer
		next_eat = world.time + rand(0, 30 SECONDS)
		controller.set_blackboard_key(BB_NEXT_HUNGRY, next_eat)

	if(world.time < next_eat)
		return

	// find food
	var/atom/food_target = controller.blackboard[BB_FOOD_TARGET]
	if(isnull(food_target))
		controller.queue_behavior(/datum/ai_behavior/find_and_set/food_or_drink/to_eat, BB_FOOD_TARGET, /obj/item, 2)
		return SUBTREE_RETURN_FINISH_PLANNING

	if(living_pawn.is_holding(food_target))
		controller.queue_behavior(/datum/ai_behavior/consume, BB_FOOD_TARGET, BB_NEXT_HUNGRY)
	// it's been moved since we found it
	else if(!isturf(food_target.loc))
		// someone took it. we will fight over it!
		if(isliving(food_target.loc) && will_fight_for_food(food_target.loc, living_pawn, controller))
			controller.add_blackboard_key_assoc(BB_MONKEY_ENEMIES, food_target.loc, MONKEY_FOOD_HATRED_AMOUNT)
		// eh, find something else
		else
			controller.clear_blackboard_key(BB_FOOD_TARGET)
		return SUBTREE_RETURN_FINISH_PLANNING
	else
		controller.queue_behavior(/datum/ai_behavior/navigate_to_and_pick_up, BB_FOOD_TARGET, TRUE)
	return SUBTREE_RETURN_FINISH_PLANNING

/datum/ai_planning_subtree/generic_hunger/proc/will_fight_for_food(mob/living/thief, mob/living/monkey, datum/ai_controller/controller)
	if(controller.blackboard[BB_MONKEY_AGGRESSIVE])
		return TRUE
	if(controller.blackboard[BB_MONKEY_TAMED])
		return FALSE
	return prob(100 * ((NUTRITION_LEVEL_HUNGRY - monkey.nutrition) / NUTRITION_LEVEL_HUNGRY))
