/// We won't use tentacles unless we have had the same target for this long
#define MIN_TIME_TO_TENTACLE 3 SECONDS

/datum/ai_controller/basic_controller/goliath
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_PRIORITY_STRATEGY = /datum/target_priority_strategy/mining,
		BB_TARGET_MINIMUM_STAT = HARD_CRIT,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	behavior_tree_json = "goliath.bt.json"

/// Use tentacles on the current target — only after tracking them for MIN_TIME_TO_TENTACLE, and only if not already leg-grappled
/datum/bt_node/ai_behavior/targeted_mob_ability/goliath_tentacles
	var/min_target_time = MIN_TIME_TO_TENTACLE

/datum/bt_node/ai_behavior/targeted_mob_ability/goliath_tentacles/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/target = controller.blackboard[target_key]
	if(!(isliving(target) || ismecha(target)))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	if(isliving(target) && target.get_item_by_slot(ITEM_SLOT_LEGCUFFED))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	var/time_on_target = controller.blackboard[BB_BASIC_MOB_HAS_TARGET_TIME] || 0
	if(time_on_target < min_target_time)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	return ..()

/// Randomly picks a nearby undig asteroid turf to dig and stores it in target_key
/datum/bt_node/ai_behavior/goliath_find_diggable_turf
	time_between_perform = 2 SECONDS
	var/target_key = BB_GOLIATH_HOLE_TARGET
	var/scan_range = 3

/datum/bt_node/ai_behavior/goliath_find_diggable_turf/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/pawn = controller.pawn
	var/list/nearby_turfs = RANGE_TURFS(scan_range, pawn)
	var/turf/open/misc/asteroid/check_turf = pick(nearby_turfs)
	if(!istype(check_turf) || check_turf.dug)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	controller.set_blackboard_key(target_key, check_turf)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/// Melee-attacks the stored hole target turf and clears the key when done
/datum/bt_node/ai_behavior/goliath_dig
	time_between_perform = 3 MINUTES
	var/target_key = BB_GOLIATH_HOLE_TARGET

/datum/bt_node/ai_behavior/goliath_dig/perform(seconds_per_tick, datum/ai_controller/controller)
	var/turf/target_turf = controller.blackboard[target_key]
	var/mob/living/basic/basic_mob = controller.pawn
	if(isnull(target_turf) || !target_turf.IsReachableBy(basic_mob))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	basic_mob.melee_attack(target_turf)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/bt_node/ai_behavior/goliath_dig/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	controller.clear_blackboard_key(target_key)

#undef MIN_TIME_TO_TENTACLE
