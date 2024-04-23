/**find and set
 * Finds an item near themselves, sets a blackboard key as it. Very useful for ais that need to use machines or something.
 * if you want to do something more complicated than find a single atom, change the search_tactic() proc
 * cool tip: search_tactic() can set lists
 */
/datum/ai_behavior/find_and_set
	action_cooldown = 2 SECONDS

/datum/ai_behavior/find_and_set/perform(seconds_per_tick, datum/ai_controller/controller, set_key, locate_path, search_range)
	if (controller.blackboard_key_exists(set_key))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	if(QDELETED(controller.pawn))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	var/find_this_thing = search_tactic(controller, locate_path, search_range)
	if(isnull(find_this_thing))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	controller.set_blackboard_key(set_key, find_this_thing)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/find_and_set/proc/search_tactic(datum/ai_controller/controller, locate_path, search_range)
	return locate(locate_path) in oview(search_range, controller.pawn)

/**
 * Variant of find and set that fails if the living pawn doesn't hold something
 */
/datum/ai_behavior/find_and_set/pawn_must_hold_item

/datum/ai_behavior/find_and_set/pawn_must_hold_item/search_tactic(datum/ai_controller/controller)
	var/mob/living/living_pawn = controller.pawn
	if(!living_pawn.get_num_held_items())
		return //we want to fail the search if we don't have something held
	return ..()

/**
 * Variant of find and set that also requires the item to be edible. checks hands too
 */
/datum/ai_behavior/find_and_set/edible

/datum/ai_behavior/find_and_set/edible/search_tactic(datum/ai_controller/controller, locate_path, search_range)
	var/mob/living/living_pawn = controller.pawn
	var/list/food_candidates = list()
	for(var/held_candidate as anything in living_pawn.held_items)
		if(!held_candidate || !IsEdible(held_candidate))
			continue
		food_candidates += held_candidate

	var/list/local_results = locate(locate_path) in oview(search_range, controller.pawn)
	for(var/local_candidate in local_results)
		if(!IsEdible(local_candidate))
			continue
		food_candidates += local_candidate
	if(food_candidates.len)
		return pick(food_candidates)

/**
 * Variant of find and set that only checks in hands, search range should be excluded for this
 */
/datum/ai_behavior/find_and_set/in_hands

/datum/ai_behavior/find_and_set/in_hands/search_tactic(datum/ai_controller/controller, locate_path)
	var/mob/living/living_pawn = controller.pawn
	return locate(locate_path) in living_pawn.held_items

/datum/ai_behavior/find_and_set/in_hands/given_list

/datum/ai_behavior/find_and_set/in_hands/given_list/search_tactic(datum/ai_controller/controller, locate_paths)
	var/list/found = typecache_filter_list(controller.pawn, locate_paths)
	if(length(found))
		return pick(found)

/**
 * Variant of find and set that takes a list of things to find.
 */
/datum/ai_behavior/find_and_set/in_list

/datum/ai_behavior/find_and_set/in_list/search_tactic(datum/ai_controller/controller, locate_paths, search_range)
	var/list/found = typecache_filter_list(oview(search_range, controller.pawn), locate_paths)
	if(length(found))
		return pick(found)

/// Like find_and_set/in_list, but we return the turf location of the item instead of the item itself.
/datum/ai_behavior/find_and_set/in_list/turf_location

/datum/ai_behavior/find_and_set/in_list/turf_location/search_tactic(datum/ai_controller/controller, locate_paths, search_range)
	. = ..()
	if(isnull(.))
		return null

	return get_turf(.)

/**
 * Variant of find and set which returns an object which can be animated with a staff of change
 */
/datum/ai_behavior/find_and_set/animatable

/datum/ai_behavior/find_and_set/animatable/search_tactic(datum/ai_controller/controller, locate_path, search_range)
	var/mob/living/living_pawn = controller.pawn

	var/list/nearby_items = list()
	for (var/obj/new_friend as anything in oview(search_range, controller.pawn))
		if (!isitem(new_friend) && !isstructure(new_friend))
			continue
		if (is_type_in_list(new_friend, GLOB.animatable_blacklist))
			continue
		if (living_pawn.see_invisible < new_friend.invisibility)
			continue
		nearby_items += new_friend

	if(nearby_items.len)
		return pick(nearby_items)

/**
 * Variant of find and set which returns the nearest wall which isn't invulnerable
 */
/datum/ai_behavior/find_and_set/nearest_wall

/datum/ai_behavior/find_and_set/nearest_wall/search_tactic(datum/ai_controller/controller, locate_path, search_range)
	var/mob/living/living_pawn = controller.pawn

	var/list/nearby_walls = list()
	for (var/turf/closed/new_wall in oview(search_range, controller.pawn))
		if (isindestructiblewall(new_wall))
			continue
		nearby_walls += new_wall

	if(nearby_walls.len)
		return get_closest_atom(/turf/closed/, nearby_walls, living_pawn)

/**
 * Variant of find and set which returns corpses who share your faction
 */
/datum/ai_behavior/find_and_set/friendly_corpses

/datum/ai_behavior/find_and_set/friendly_corpses/search_tactic(datum/ai_controller/controller, locate_path, search_range)
	var/mob/living/living_pawn = controller.pawn
	var/list/nearby_bodies = list()
	for (var/mob/living/dead_pal in oview(search_range, controller.pawn))
		if (!isturf(dead_pal.loc))
			continue
		if (!dead_pal.stat || dead_pal.health > 0)
			continue
		if (living_pawn.see_invisible < dead_pal.invisibility)
			continue
		if (!living_pawn.faction_check_atom(dead_pal))
			continue
		nearby_bodies += dead_pal

	if (nearby_bodies.len)
		return pick(nearby_bodies)

/**
 * A variant that looks for a human who is not dead or incapacitated, and has a mind
 */
/datum/ai_behavior/find_and_set/conscious_person

/datum/ai_behavior/find_and_set/conscious_person/search_tactic(datum/ai_controller/controller, locate_path, search_range)
	var/list/customers = list()
	for(var/mob/living/carbon/human/target in oview(search_range, controller.pawn))
		if(IS_DEAD_OR_INCAP(target) || !target.mind)
			continue
		customers += target

	if(customers.len)
		return pick(customers)

	return null

/datum/ai_behavior/find_and_set/nearby_friends
	action_cooldown = 2 SECONDS

/datum/ai_behavior/find_and_set/nearby_friends/search_tactic(datum/ai_controller/controller, locate_path, search_range)
	var/atom/friend = locate(/mob/living/carbon/human) in oview(search_range, controller.pawn)

	if(isnull(friend))
		return null

	var/mob/living/living_pawn = controller.pawn
	var/potential_friend = living_pawn.faction.Find(REF(friend)) ? friend : null
	return potential_friend
