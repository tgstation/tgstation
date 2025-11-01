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
	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity/pacifist,
		/datum/ai_planning_subtree/respond_to_summon,
		/datum/ai_planning_subtree/handle_trash_talk,
		/datum/ai_planning_subtree/wash_people,
		/datum/ai_planning_subtree/salute_authority,
		/datum/ai_planning_subtree/find_patrol_beacon,
	)
	reset_keys = list(
		BB_WASH_TARGET,
		BB_BEACON_TARGET,
		BB_PREVIOUS_BEACON_TARGET,
		BB_BOT_SUMMON_TARGET,
	)

/datum/ai_planning_subtree/handle_trash_talk

/datum/ai_planning_subtree/handle_trash_talk/SelectBehaviors(datum/ai_controller/basic_controller/bot/controller, seconds_per_tick)
	if(!controller.blackboard_key_exists(BB_WASH_TARGET))
		return
	controller.queue_behavior(/datum/ai_behavior/commence_trashtalk, BB_WASH_TARGET)

/datum/ai_behavior/commence_trashtalk
	action_cooldown = 4 SECONDS

/datum/ai_behavior/commence_trashtalk/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	if(!controller.blackboard_key_exists(target_key))
		return AI_BEHAVIOR_FAILED | AI_BEHAVIOR_DELAY

	var/frustration_count = controller.blackboard[BB_WASH_FRUSTRATION]
	controller.set_blackboard_key(BB_WASH_FRUSTRATION, min(frustration_count + 1, BOT_FRUSTRATION_LIMIT))
	if(controller.blackboard[BB_WASH_FRUSTRATION] < BOT_ANGER_THRESHOLD)
		return AI_BEHAVIOR_FAILED | AI_BEHAVIOR_DELAY
	var/datum/action/cooldown/bot_announcement/announcement = controller.blackboard[BB_ANNOUNCE_ABILITY]
	announcement?.announce(pick(controller.blackboard[BB_WASH_THREATS]))
	return AI_BEHAVIOR_SUCCEEDED | AI_BEHAVIOR_DELAY


/datum/ai_planning_subtree/wash_people

/datum/ai_planning_subtree/wash_people/SelectBehaviors(datum/ai_controller/basic_controller/bot/controller, seconds_per_tick)
	var/mob/living/basic/bot/bot_pawn = controller.pawn

	var/atom/wash_target = controller.blackboard[BB_WASH_TARGET]
	if(QDELETED(wash_target))
		controller.queue_behavior(/datum/ai_behavior/find_valid_wash_targets, BB_WASH_TARGET, bot_pawn.bot_access_flags)
		return

	if(get_dist(bot_pawn, wash_target) < 9)
		controller.queue_behavior(/datum/ai_behavior/wash_target, BB_WASH_TARGET)
		return SUBTREE_RETURN_FINISH_PLANNING

	controller.clear_blackboard_key(BB_WASH_TARGET) //delete if too far

/datum/ai_behavior/find_valid_wash_targets
	action_cooldown = 5 SECONDS

/datum/ai_behavior/find_valid_wash_targets/perform(seconds_per_tick, datum/ai_controller/basic_controller/bot/controller, target_key, our_access_flags)
	. = ..()
	var/list/ignore_list = controller.blackboard[BB_TEMPORARY_IGNORE_LIST]
	var/atom/found_target
	for(var/mob/living/carbon/human/wash_potential in oview(5, controller.pawn))

		if(found_target)
			break

		if(isnull(wash_potential.mind) || wash_potential.stat != CONSCIOUS)
			continue

		if(LAZYACCESS(ignore_list, wash_potential))
			continue

		if(our_access_flags & BOT_COVER_EMAGGED)
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

/datum/ai_behavior/find_valid_wash_targets/finish_action(datum/ai_controller/controller, succeeded, target_key)
	. = ..()
	if(!succeeded)
		return
	var/datum/action/cooldown/bot_announcement/announcement = controller.blackboard[BB_ANNOUNCE_ABILITY]
	announcement.announce(pick(controller.blackboard[BB_WASH_FOUND]))

/datum/ai_behavior/wash_target
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION
	required_distance = 0

/datum/ai_behavior/wash_target/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE
	set_movement_target(controller, target)

/datum/ai_behavior/wash_target/perform(seconds_per_tick, datum/ai_controller/basic_controller/bot/controller, target_key)
	. = ..()
	var/mob/living/carbon/human/unclean_target = controller.blackboard[target_key]
	var/mob/living/basic/living_pawn = controller.pawn
	if(QDELETED(unclean_target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	if(living_pawn.loc == get_turf(unclean_target))
		living_pawn.melee_attack(unclean_target)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

/datum/ai_behavior/wash_target/finish_action(datum/ai_controller/controller, succeeded, target_key)
	. = ..()
	controller.clear_blackboard_key(target_key)
	var/wash_frustration = controller.blackboard[BB_WASH_FRUSTRATION]
	controller.clear_blackboard_key(BB_WASH_FRUSTRATION)
	if(!succeeded || wash_frustration <= BOT_ANGER_THRESHOLD)
		return
	var/datum/action/cooldown/bot_announcement/announcement = controller.blackboard[BB_ANNOUNCE_ABILITY]
	announcement.announce(pick(controller.blackboard[BB_WASH_DONE]))

#undef BOT_ANGER_THRESHOLD
#undef BOT_FRUSTRATION_LIMIT
