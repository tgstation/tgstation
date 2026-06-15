#define BOT_FRUSTRATION_LIMIT 8
#define BOT_ANGER_THRESHOLD 5

/datum/ai_controller/basic_controller/bot/hygienebot
	behavior_tree_json = "code/modules/mob/living/basic/bots/hygienebot/hygienebot.bt.json"
	blackboard = list(
		BB_SALUTE_MESSAGES = list(
			"salutes",
			"nods in appreciation towards",
		),
		BB_WASH_FRUSTRATION = 0,
	)
	reset_keys = list(
		BB_WASH_TARGET,
		BB_BEACON_TARGET,
		BB_PREVIOUS_BEACON_TARGET,
		BB_BOT_SUMMON_TARGET,
	)



/datum/bt_node/ai_behavior/commence_trashtalk
	var/target_key
	behavior_flags = AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/bt_node/ai_behavior/commence_trashtalk/perform(seconds_per_tick, datum/ai_controller/controller)
	if(!controller.blackboard_key_exists(target_key))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/frustration_count = controller.blackboard[BB_WASH_FRUSTRATION]
	controller.set_blackboard_key(BB_WASH_FRUSTRATION, min(frustration_count + 1, BOT_FRUSTRATION_LIMIT))
	if(controller.blackboard[BB_WASH_FRUSTRATION] < BOT_ANGER_THRESHOLD)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	var/datum/action/cooldown/bot_announcement/announcement = controller.blackboard[BB_ANNOUNCE_ABILITY]
	announcement?.announce(pick(controller.blackboard[BB_WASH_THREATS]))
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED



/// Valid if the target is a conscious human with bloodied clothing (or anyone, while emagged).
/datum/targeting_strategy/conscious_human/washable_human/is_valid_target(mob/living/living_mob, atom/target, vision_range, datum/ai_controller/controller = null)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/basic/bot/bot_pawn = living_mob
	if(bot_pawn.bot_access_flags & BOT_COVER_EMAGGED)
		return TRUE
	var/mob/living/carbon/human/human_target = target
	for(var/atom/clothing in human_target.get_equipped_items(INCLUDE_HELD|INCLUDE_PROSTHETICS))
		if(GET_ATOM_BLOOD_DNA_LENGTH(clothing))
			return TRUE
	return FALSE

/// Finds someone to wash and announces it; while emagged the target is blacklisted so the bot washes each person only once.
/datum/bt_node/ai_behavior/acquire_target/update_interaction_target/hygiene_wash

/datum/bt_node/ai_behavior/acquire_target/update_interaction_target/hygiene_wash/on_target_found(datum/ai_controller/basic_controller/bot/controller, atom/target, datum/targeting_strategy/strategy)
	var/mob/living/basic/bot/bot_pawn = controller.pawn
	if(bot_pawn.bot_access_flags & BOT_COVER_EMAGGED)
		controller.add_to_blacklist(target)
	var/datum/action/cooldown/bot_announcement/announcement = controller.blackboard[BB_ANNOUNCE_ABILITY]
	announcement.announce(pick(controller.blackboard[BB_WASH_FOUND]))


/datum/bt_node/ai_behavior/wash_target
	var/target_key

/datum/bt_node/ai_behavior/wash_target/perform(seconds_per_tick, datum/ai_controller/basic_controller/bot/controller)
	var/mob/living/carbon/human/unclean_target = controller.blackboard[target_key]
	var/mob/living/basic/living_pawn = controller.pawn
	if(QDELETED(unclean_target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	if(get_dist(living_pawn, unclean_target) > 0)
		return AI_BEHAVIOR_INSTANT
	living_pawn.melee_attack(unclean_target)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/bt_node/ai_behavior/wash_target/finish_action(datum/ai_controller/controller, succeeded)
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
