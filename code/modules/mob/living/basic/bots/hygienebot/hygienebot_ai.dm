#define BOT_FRUSTRATION_LIMIT 8
#define BOT_ANGER_THRESHOLD 5

/datum/ai_controller/basic_controller/bot/hygienebot
	blackboard = list(
		BB_SALUTE_MESSAGES = list(
			"salutes",
			"nods in appreciation towards",
		),
		BB_WASH_FRUSTRATION = 0,
	)
	behavior_nodes = BT_SELECTOR(\
		BT_SUBTREE(/datum/bt_node/subtree/escape_captivity/pacifist),\
		BT_SUBTREE(/datum/bt_node/subtree/bot_respond_to_summon),\
		BT_SELECTOR(\
			BT_DECORATOR(/datum/bt_node/decorator/bb_key_set,\
				BT_SELECTOR(\
					BT_LEAF(/datum/bt_node/ai_behavior/commence_trashtalk, BB_WASH_TARGET),\
					BT_PARALLEL(BT_PARALLEL_FAILURE_ONE,\
						BT_LEAF(/datum/bt_node/ai_behavior/wash_target, BB_WASH_TARGET),\
						BT_LEAF(/datum/bt_node/ai_behavior/move_to_target,\
							BB_WASH_TARGET, 0\
						)\
					)\
				),\
				"key" = BB_WASH_TARGET\
			),\
			BT_LEAF(/datum/bt_node/ai_behavior/find_valid_wash_targets, BB_WASH_TARGET)\
		),\
		BT_SUBTREE(/datum/bt_node/subtree/bot_salute_authority),\
		BT_SUBTREE(/datum/bt_node/subtree/bot_patrol),\
	)
	reset_keys = list(
		BB_WASH_TARGET,
		BB_BEACON_TARGET,
		BB_PREVIOUS_BEACON_TARGET,
		BB_BOT_SUMMON_TARGET,
	)

// =============================================================================
// Handle trash talk (runs alongside wash — says threatening lines when frustrated)
// =============================================================================

/datum/bt_node/ai_behavior/commence_trashtalk
	action_cooldown = 4 SECONDS
	behavior_flags = AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/bt_node/ai_behavior/commence_trashtalk/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	if(!controller.blackboard_key_exists(target_key))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/frustration_count = controller.blackboard[BB_WASH_FRUSTRATION]
	controller.set_blackboard_key(BB_WASH_FRUSTRATION, min(frustration_count + 1, BOT_FRUSTRATION_LIMIT))
	if(controller.blackboard[BB_WASH_FRUSTRATION] < BOT_ANGER_THRESHOLD)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	var/datum/action/cooldown/bot_announcement/announcement = controller.blackboard[BB_ANNOUNCE_ABILITY]
	announcement?.announce(pick(controller.blackboard[BB_WASH_THREATS]))
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

// =============================================================================
// Find wash target
// =============================================================================

/datum/bt_node/ai_behavior/find_valid_wash_targets
	action_cooldown = 5 SECONDS

/datum/bt_node/ai_behavior/find_valid_wash_targets/perform(seconds_per_tick, datum/ai_controller/basic_controller/bot/controller, target_key)
	var/mob/living/basic/bot/bot_pawn = controller.pawn
	var/list/ignore_list = controller.blackboard[BB_TEMPORARY_IGNORE_LIST]
	var/atom/found_target
	for(var/mob/living/carbon/human/wash_potential in oview(5, bot_pawn))
		if(found_target)
			break
		if(isnull(wash_potential.mind) || wash_potential.stat != CONSCIOUS)
			continue
		if(LAZYACCESS(ignore_list, wash_potential))
			continue
		if(bot_pawn.bot_access_flags & BOT_COVER_EMAGGED)
			controller.add_to_blacklist(wash_potential)
			found_target = wash_potential
			break
		for(var/atom/clothing in wash_potential.get_equipped_items(INCLUDE_HELD|INCLUDE_PROSTHETICS))
			if(GET_ATOM_BLOOD_DNA_LENGTH(clothing))
				found_target = wash_potential
				break

	if(isnull(found_target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	controller.set_blackboard_key(target_key, found_target)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/bt_node/ai_behavior/find_valid_wash_targets/finish_action(datum/ai_controller/controller, succeeded, target_key)
	. = ..()
	if(!succeeded)
		return
	var/datum/action/cooldown/bot_announcement/announcement = controller.blackboard[BB_ANNOUNCE_ABILITY]
	announcement.announce(pick(controller.blackboard[BB_WASH_FOUND]))

// =============================================================================
// Wash target
// =============================================================================

/datum/bt_node/ai_behavior/wash_target

/datum/bt_node/ai_behavior/wash_target/perform(seconds_per_tick, datum/ai_controller/basic_controller/bot/controller, target_key)
	var/mob/living/carbon/human/unclean_target = controller.blackboard[target_key]
	var/mob/living/basic/living_pawn = controller.pawn
	if(QDELETED(unclean_target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	if(get_dist(living_pawn, unclean_target) > 0)
		return AI_BEHAVIOR_INSTANT
	living_pawn.melee_attack(unclean_target)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/bt_node/ai_behavior/wash_target/finish_action(datum/ai_controller/controller, succeeded, target_key)
	. = ..()
	controller.clear_blackboard_key(target_key)
	var/wash_frustration = controller.blackboard[BB_WASH_FRUSTRATION]
	controller.set_blackboard_key(BB_WASH_FRUSTRATION, 0)
	if(!succeeded || wash_frustration <= BOT_ANGER_THRESHOLD)
		return
	var/datum/action/cooldown/bot_announcement/announcement = controller.blackboard[BB_ANNOUNCE_ABILITY]
	announcement.announce(pick(controller.blackboard[BB_WASH_DONE]))

#undef BOT_ANGER_THRESHOLD
#undef BOT_FRUSTRATION_LIMIT
