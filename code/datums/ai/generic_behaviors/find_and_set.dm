/**find and set
 * Finds an item near themselves, sets a blackboard key as it. Very useful for ais that need to use machines or something.
 * if you want to do something more complicated than find a single atom, change the search_tactic() proc
 * cool tip: search_tactic() can set lists
 */
/datum/bt_node/ai_behavior/find_and_set
	time_between_perform = 2 SECONDS
	/// Blackboard key to store the found atom in.
	var/set_key = BB_CURRENT_TARGET
	/// Typepath (or blackboard key) describing what to look for.
	var/locate_path
	/// How far out to search; null re-defaults to SEARCH_TACTIC_DEFAULT_RANGE.
	var/search_range = SEARCH_TACTIC_DEFAULT_RANGE

/datum/bt_node/ai_behavior/find_and_set/perform(seconds_per_tick, datum/ai_controller/controller)
	if (controller.blackboard_key_exists(set_key))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	if(QDELETED(controller.pawn))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	// Trees may omit the range arg, which would pass an explicit null past search_tactic()'s own default
	if(isnull(search_range))
		search_range = SEARCH_TACTIC_DEFAULT_RANGE
	var/find_this_thing = search_tactic(controller, locate_path, search_range)
	if(isnull(find_this_thing))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	EVLOG_MAPTEXT(controller, EVLOG_CATEGORY_AI_TARGETING, "[controller.pawn] has selected [find_this_thing] as a target for blackboard key [set_key]! Behavior: [src]", get_turf(find_this_thing), "Target: [find_this_thing]")
	EVLOG_LINES(controller, EVLOG_CATEGORY_AI_TARGETING, "Line to target", get_turf(controller.pawn), get_turf(find_this_thing))
	controller.set_blackboard_key(set_key, find_this_thing)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/bt_node/ai_behavior/find_and_set/proc/search_tactic(datum/ai_controller/controller, locate_path, search_range = 3)
	return locate(locate_path) in oview(search_range, controller.pawn)

/// Variant that fails if the living pawn doesn't hold something
/datum/bt_node/ai_behavior/find_and_set/pawn_must_hold_item

/datum/bt_node/ai_behavior/find_and_set/pawn_must_hold_item/search_tactic(datum/ai_controller/controller)
	var/mob/living/living_pawn = controller.pawn
	if(!living_pawn.get_num_held_items())
		return
	return ..()

/// Variant that requires the item to be edible or a drink. Checks hands too.
/datum/bt_node/ai_behavior/find_and_set/food_or_drink
	var/force_find_drinks = FALSE

/datum/bt_node/ai_behavior/find_and_set/food_or_drink/search_tactic(datum/ai_controller/controller, locate_path, search_range = SEARCH_TACTIC_DEFAULT_RANGE)
	var/mob/living/living_pawn = controller.pawn
	var/find_drinks = force_find_drinks || controller.blackboard[BB_IGNORE_DRINKS] || FALSE

	for(var/atom/held_candidate in living_pawn.held_items)
		if(is_food_or_drink(controller, held_candidate, find_drinks))
			return held_candidate

	for(var/atom/local_candidate in oview(search_range, controller.pawn))
		if(is_food_or_drink(controller, local_candidate, find_drinks) && istype(local_candidate, locate_path))
			return local_candidate

	return null

/datum/bt_node/ai_behavior/find_and_set/food_or_drink/proc/is_food_or_drink(datum/ai_controller/controller, obj/item/thing, find_drinks = FALSE)
	return is_food(thing) || (find_drinks && is_drink(thing))

/datum/bt_node/ai_behavior/find_and_set/food_or_drink/proc/is_food(obj/item/thing)
	if(IS_EDIBLE(thing))
		return TRUE
	if(istype(thing, /obj/item/reagent_containers/cup/bowl))
		return thing.reagents.total_volume > 0
	return FALSE

/datum/bt_node/ai_behavior/find_and_set/food_or_drink/proc/is_drink(obj/item/thing)
	if(istype(thing, /obj/item/reagent_containers/cup/glass))
		return thing.reagents.total_volume > 0
	return FALSE

/datum/bt_node/ai_behavior/find_and_set/food_or_drink/to_eat

// Gates on hunger level and a random eat cooldown before searching for food
/datum/bt_node/ai_behavior/find_and_set/food_or_drink/to_eat/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/living_pawn = controller.pawn
	if(!isliving(living_pawn) || living_pawn.nutrition > NUTRITION_LEVEL_HUNGRY)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/next_eat = controller.blackboard[BB_NEXT_HUNGRY]
	if(!next_eat)
		next_eat = world.time + rand(0, 30 SECONDS)
		controller.set_blackboard_key(BB_NEXT_HUNGRY, next_eat)
	if(world.time < next_eat)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	return ..()

/datum/bt_node/ai_behavior/find_and_set/food_or_drink/to_serve
	force_find_drinks = TRUE

/// Variant that only checks held items
/datum/bt_node/ai_behavior/find_and_set/in_hands

/datum/bt_node/ai_behavior/find_and_set/in_hands/search_tactic(datum/ai_controller/controller, locate_path)
	var/mob/living/living_pawn = controller.pawn
	return locate(locate_path) in living_pawn.held_items
