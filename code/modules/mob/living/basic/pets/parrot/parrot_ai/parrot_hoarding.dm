///subtree to steal items
/datum/ai_planning_subtree/hoard_items
	var/theft_chance = 5

/datum/ai_planning_subtree/hoard_items/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/living_pawn = controller.pawn

	var/turf/myspace = controller.blackboard[BB_HOARD_LOCATION]

	if(isnull(myspace) || myspace.is_blocked_turf(source_atom = controller.pawn) || get_dist(myspace, controller.pawn) > controller.blackboard[BB_HOARD_LOCATION_RANGE])
		controller.queue_behavior(/datum/ai_behavior/find_and_set/hoard_location, BB_HOARD_LOCATION, /turf/open)
		return

	//we have an item, go drop!
	var/list/our_contents = living_pawn.contents - typecache_filter_list(living_pawn.contents, controller.blackboard[BB_IGNORE_ITEMS])
	if(length(our_contents))
		controller.queue_behavior(/datum/ai_behavior/travel_towards/and_drop, BB_HOARD_LOCATION)
		return SUBTREE_RETURN_FINISH_PLANNING

	if(controller.blackboard_key_exists(BB_HOARD_ITEM_TARGET))
		controller.queue_behavior(/datum/ai_behavior/basic_melee_attack/interact_once, BB_HOARD_ITEM_TARGET, BB_TARGETING_STRATEGY)
		return SUBTREE_RETURN_FINISH_PLANNING

	if(!SPT_PROB(theft_chance, seconds_per_tick))
		return
	controller.queue_behavior(/datum/ai_behavior/find_and_set/hoard_item, BB_HOARD_ITEM_TARGET)

/datum/ai_behavior/find_and_set/hoard_location

/datum/ai_behavior/find_and_set/hoard_location/search_tactic(datum/ai_controller/controller, locate_path, search_range)
	for(var/turf/open/candidate in oview(search_range, controller.pawn))
		if(is_space_or_openspace(candidate))
			continue
		if(candidate.is_blocked_turf(source_atom = controller.pawn))
			continue
		return candidate

	return null

/datum/ai_behavior/find_and_set/hoard_item
	action_cooldown = 5 SECONDS
	behavior_flags = AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/ai_behavior/find_and_set/hoard_item/search_tactic(datum/ai_controller/controller, locate_path, search_range)
	if(!controller.blackboard_key_exists(BB_HOARD_LOCATION))
		return null
	var/turf/nest_turf = controller.blackboard[BB_HOARD_LOCATION]
	var/mob/living/living_pawn = controller.pawn
	for(var/atom/potential_victim in oview(search_range, controller.pawn))
		if(is_type_in_typecache(potential_victim, controller.blackboard[BB_IGNORE_ITEMS]))
			continue
		if(potential_victim.loc == nest_turf)
			continue
		if(isitem(potential_victim))
			var/obj/item/item_steal = potential_victim
			if(item_steal.w_class <= WEIGHT_CLASS_SMALL)
				return potential_victim
		if(!ishuman(potential_victim))
			continue
		if(living_pawn.faction.Find(REF(potential_victim)))
			continue //dont steal from friends
		if(holding_valuable(controller, potential_victim))
			controller.set_blackboard_key(BB_ALWAYS_IGNORE_FACTION, TRUE)
			return potential_victim

	return null

/datum/ai_behavior/find_and_set/hoard_item/proc/holding_valuable(datum/ai_controller/controller, mob/living/human_target)
	for(var/obj/item/potential_item in human_target.held_items)
		if(is_type_in_typecache(potential_item, controller.blackboard[BB_IGNORE_ITEMS]))
			continue
		if(potential_item.w_class <= WEIGHT_CLASS_SMALL)
			return TRUE
	return FALSE
