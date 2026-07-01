/datum/ai_controller/basic_controller/goldgrub
	ai_traits = parent_type::ai_traits | CANNOT_GO_IDLE
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_PET_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
		BB_ORE_IGNORE_TYPES = list(/obj/item/stack/ore/iron, /obj/item/stack/ore/glass),
		BB_STORM_APPROACHING = FALSE,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	behavior_tree_json = "code/modules/mob/living/basic/lavaland/goldgrub/goldgrub.bt.json"

/datum/ai_controller/basic_controller/babygrub
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_ORE_IGNORE_TYPES = list(/obj/item/stack/ore/glass),
		BB_FIND_MOM_TYPES = list(/mob/living/basic/mining/goldgrub),
		BB_IGNORE_MOM_TYPES = list(/mob/living/basic/mining/goldgrub/baby),
		BB_STORM_APPROACHING = FALSE,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	behavior_tree_json = "code/modules/mob/living/basic/lavaland/goldgrub/babygrub.bt.json"

/datum/pet_command/grub_spit
	command_name = "Spit"
	radial_icon = 'icons/obj/ore.dmi'
	radial_icon_state = "uranium"
	command_desc = "Ask your grub pet to spit out its ores."
	speech_commands = list("spit", "ores")

/datum/pet_command/grub_spit/execute_action(datum/ai_controller/controller)
	var/datum/action/cooldown/spit_ability = controller.blackboard[BB_SPIT_ABILITY]
	if(!spit_ability?.IsAvailable())
		return
	controller.set_blackboard_key(BB_PET_ACTIVE_ABILITY, spit_ability)
	controller.set_behavior_tree_override(SUBPLAN_ID_PET_COMMAND, /datum/bt_node/subtree/pet_command/untargeted_ability)
	controller.clear_blackboard_key(BB_ACTIVE_PET_COMMAND)

/datum/pet_command/grub_spit/retrieve_command_text(atom/living_pet, atom/target)
	return "signals [living_pet] to spit its ores!"


#define BURROW_RANGE 5


/**
 * Burrows underground (or stays underground) when danger is present or a storm is approaching.
 * Returns RUNNING while underground+storm (blocks everything).
 * Returns FAILURE when no action needed so the selector passes through.
 */
/datum/bt_node/ai_behavior/dig_away_from_danger

/datum/bt_node/ai_behavior/dig_away_from_danger/perform(seconds_per_tick, datum/ai_controller/controller)
	var/currently_underground = is_jaunting(controller.pawn)
	var/storm_approaching = controller.blackboard[BB_STORM_APPROACHING]
	var/datum/action/cooldown/dig_ability = controller.blackboard[BB_BURROW_ABILITY]

	if(currently_underground && storm_approaching)
		return AI_BEHAVIOR_DELAY // Stay underground while storm approaches  RUNNING blocks everything

	if(!dig_ability?.IsAvailable())
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/has_target = controller.blackboard_key_exists(BB_CURRENT_TARGET)

	if(currently_underground && !has_target)
		// No target/danger while underground  emerge
		INVOKE_ASYNC(dig_ability, TYPE_PROC_REF(/datum/action, Trigger))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

	if(storm_approaching || has_target)
		// Go underground to escape
		INVOKE_ASYNC(dig_ability, TYPE_PROC_REF(/datum/action, Trigger))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED


/**
 * While jaunting (underground) with a target, moves the grub's phased form further away.
 * Returns FAILURE when not jaunting so the selector passes through.
 */
/datum/bt_node/ai_behavior/burrow_through_ground
	time_between_perform = 10 SECONDS

/datum/bt_node/ai_behavior/burrow_through_ground/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/living_pawn = controller.pawn
	var/atom/target = controller.blackboard[BB_CURRENT_TARGET]
	if(!is_jaunting(living_pawn) || QDELETED(target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/atom/movable/phased = living_pawn.loc
	var/list/turfs_list = RANGE_TURFS(BURROW_RANGE, phased)
	var/current_max_distance = 0
	var/turf/selected_turf

	for(var/turf/possible_turf as anything in turfs_list)
		if(!ismineralturf(possible_turf) && !isasteroidturf(possible_turf))
			continue
		var/distance_to_target = get_dist(possible_turf, target)
		if(distance_to_target > current_max_distance)
			current_max_distance = distance_to_target
			selected_turf = possible_turf
		if(distance_to_target == BURROW_RANGE)
			break

	if(isnull(selected_turf))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	phased.forceMove(selected_turf)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED


/// Finds an ore pile. Sets BB_ORE_TARGET. Skips forbidden types and fetch targets.
/datum/bt_node/ai_behavior/find_ore
	time_between_perform = 5 SECONDS
	var/range = 9

/datum/bt_node/ai_behavior/find_ore/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/grub_pawn = controller.pawn
	var/list/forbidden = controller.blackboard[BB_ORE_IGNORE_TYPES]
	var/pet_target = controller.blackboard[BB_CURRENT_PET_TARGET]
	for(var/obj/item/stack/ore/candidate in oview(range, grub_pawn))
		if(is_type_in_list(candidate, forbidden) || !isturf(candidate.loc))
			continue
		if(candidate == pet_target)
			continue
		if(!can_see(grub_pawn, candidate, range))
			continue
		controller.set_blackboard_key(BB_ORE_TARGET, candidate)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

/// Finds a boulder the goldgrub can break. Sets BB_BOULDER_TARGET.
/datum/bt_node/ai_behavior/find_boulder
	time_between_perform = 5 SECONDS

/datum/bt_node/ai_behavior/find_boulder/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/grub_pawn = controller.pawn
	var/pet_target = controller.blackboard[BB_CURRENT_PET_TARGET]
	for(var/obj/item/boulder/candidate in oview(9, grub_pawn))
		if(candidate == pet_target)
			continue
		if(!can_see(grub_pawn, candidate, 9))
			continue
		controller.set_blackboard_key(BB_BOULDER_TARGET, candidate)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

/// Finds an ore vent to harvest. Sets BB_VENT_TARGET.
/datum/bt_node/ai_behavior/find_ore_vent
	time_between_perform = 10 SECONDS

/datum/bt_node/ai_behavior/find_ore_vent/perform(seconds_per_tick, datum/ai_controller/controller)
	if(!SPT_PROB(25, seconds_per_tick))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	var/mob/living/grub_pawn = controller.pawn
	for(var/obj/structure/ore_vent/candidate in oview(15, grub_pawn))
		if(candidate in grub_pawn)
			continue
		var/turf/vent_turf = candidate.drop_location()
		var/counter = 0
		var/too_many = FALSE
		for(var/obj/item/boulder in vent_turf.contents)
			counter++
			if(counter > MAX_BOULDERS_PER_VENT)
				too_many = TRUE
				break
		if(too_many || !can_see(grub_pawn, candidate, 15))
			continue
		controller.set_blackboard_key(BB_VENT_TARGET, candidate)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

/// Finds a grub egg to protect/pull. Sets BB_LOW_PRIORITY_HUNTING_TARGET.
/datum/bt_node/ai_behavior/find_grub_egg
	time_between_perform = 10 SECONDS

/datum/bt_node/ai_behavior/find_grub_egg/perform(seconds_per_tick, datum/ai_controller/controller)
	if(!SPT_PROB(75, seconds_per_tick))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	var/mob/living/grub_pawn = controller.pawn
	if(grub_pawn.pulling)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	for(var/obj/item/food/egg/green/grub_egg/egg in oview(9, grub_pawn))
		if(!can_see(grub_pawn, egg, 9))
			continue
		controller.set_blackboard_key(BB_LOW_PRIORITY_HUNTING_TARGET, egg)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

/// Eats/interacts with a target at the given blackboard key. Must be adjacent.
/datum/bt_node/ai_behavior/grub_eat
	var/target_key
	time_between_perform = 3 SECONDS

/datum/bt_node/ai_behavior/grub_eat/perform(seconds_per_tick, datum/ai_controller/controller)
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	if(!controller.pawn.Adjacent(target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	INVOKE_ASYNC(controller, TYPE_PROC_REF(/datum/ai_controller, ai_interact), target, FALSE)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/bt_node/ai_behavior/grub_eat/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	controller.clear_blackboard_key(target_key)

/datum/bt_node/subtree/grub_eat_target
	behavior_tree_json = "code/modules/mob/living/basic/lavaland/goldgrub/grub_eat_target.bt.json"

#undef BURROW_RANGE
