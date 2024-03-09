#define BOT_TROLL_PATH_LIMIT 10

/datum/ai_controller/basic_controller/bot/honkbot
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/bot,
		BB_UNREACHABLE_LIST_COOLDOWN = 1 MINUTES,
	)
	planning_subtrees = list(
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/respond_to_summon,
		/datum/ai_planning_subtree/manage_unreachable_list,
		/datum/ai_planning_subtree/simple_find_target/honkbot,
		/datum/ai_planning_subtree/troll_target,
		/datum/ai_planning_subtree/slip_victims,
		/datum/ai_planning_subtree/play_with_clowns,
		/datum/ai_planning_subtree/find_patrol_beacon,
	)
	reset_keys = list(
		BB_BEACON_TARGET,
		BB_PREVIOUS_BEACON_TARGET,
		BB_BOT_SUMMON_TARGET,
	)
	ai_traits = PAUSE_DURING_DO_AFTER

/datum/ai_controller/basic_controller/bot/honkbot/TryPossessPawn(atom/new_pawn)
	. = ..()
	if(. & AI_CONTROLLER_INCOMPATIBLE)
		return
	RegisterSignal(new_pawn, COMSIG_AI_BLACKBOARD_KEY_CLEARED(BB_SLIP_TARGET), PROC_REF(on_clear_target))
	RegisterSignal(new_pawn, COMSIG_ATOM_NO_LONGER_PULLING, PROC_REF(on_stop_pulling))

/datum/ai_controller/basic_controller/bot/honkbot/proc/on_clear_target(datum/source)
	SIGNAL_HANDLER

	var/mob/living/living_pawn = pawn
	living_pawn.stop_pulling()

/datum/ai_controller/basic_controller/bot/honkbot/proc/on_stop_pulling(datum/source)
	SIGNAL_HANDLER

	if(!blackboard_key_exists(BB_SLIP_TARGET))
		return

	var/atom/slip_target = blackboard[BB_SLIP_TARGET]
	set_blackboard_key_assoc_lazylist(BB_TEMPORARY_IGNORE_LIST, REF(slip_target), TRUE)
	clear_blackboard_key(BB_SLIP_TARGET)

//only seek out targets to troll if we are emagged
/datum/ai_planning_subtree/simple_find_target/honkbot

/datum/ai_planning_subtree/simple_find_target/honkbot/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/basic/bot/bot_pawn = controller.pawn
	if(!(bot_pawn.bot_access_flags & BOT_COVER_EMAGGED))
		return
	return ..()

/datum/ai_planning_subtree/troll_target

/datum/ai_planning_subtree/troll_target/SelectBehaviors(datum/ai_controller/basic_controller/bot/controller, seconds_per_tick)
	var/mob/living/carbon/my_target = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	if(!istype(my_target) || my_target.handcuffed) //theyre already trolled
		controller.set_blackboard_key_assoc_lazylist(BB_TEMPORARY_IGNORE_LIST, REF(my_target), TRUE)
		controller.clear_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET)
		return
	if(my_target.IsParalyzed())
		var/datum/action/cuff_ability = controller.blackboard[BB_HONK_CUFF]
		if(cuff_ability?.IsAvailable())
			controller.queue_behavior(/datum/ai_behavior/targeted_mob_ability/and_clear_target/honkbot, BB_HONK_CUFF, BB_BASIC_MOB_CURRENT_TARGET)
			return SUBTREE_RETURN_FINISH_PLANNING
		return
	var/datum/action/honk_ability = controller.blackboard[BB_HONK_STUN]
	if(honk_ability?.IsAvailable())
		controller.queue_behavior(/datum/ai_behavior/targeted_mob_ability/and_clear_target/honkbot, BB_HONK_STUN, BB_BASIC_MOB_CURRENT_TARGET)
		return SUBTREE_RETURN_FINISH_PLANNING

/datum/ai_behavior/targeted_mob_ability/and_clear_target/honkbot
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION | AI_BEHAVIOR_REQUIRE_REACH

/datum/ai_behavior/targeted_mob_ability/and_clear_target/honkbot/setup(datum/ai_controller/controller, ability_key, target_key)
	. = ..()
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE
	set_movement_target(controller, target)

/datum/ai_behavior/targeted_mob_ability/and_clear_target/honkbot

/datum/ai_behavior/targeted_mob_ability/and_clear_target/honkbot/finish_action(datum/ai_controller/controller, succeeded, ability_key, target_key)
	var/mob/living/carbon/human/human_target = controller.blackboard[target_key]
	if(human_target?.handcuffed)
		controller.set_blackboard_key_assoc_lazylist(BB_TEMPORARY_IGNORE_LIST, REF(human_target), TRUE)
	return ..()

/datum/ai_planning_subtree/play_with_clowns/SelectBehaviors(datum/ai_controller/basic_controller/bot/controller, seconds_per_tick)
	var/mob/living/clown_target = controller.blackboard[BB_CLOWN_FRIEND]
	if(QDELETED(clown_target))
		var/list/my_list = controller.blackboard[BB_CLOWNS_LIST]
		controller.queue_behavior(/datum/ai_behavior/bot_search/clown_friends, BB_CLOWN_FRIEND, my_list)
		return
	controller.queue_behavior(/datum/ai_behavior/play_with_clown, BB_CLOWN_FRIEND)
	return SUBTREE_RETURN_FINISH_PLANNING

/datum/ai_behavior/bot_search/clown_friends

/datum/ai_behavior/bot_search/clown_friends/valid_target(datum/ai_controller/basic_controller/bot/controller, mob/living/my_target)
	if(HAS_TRAIT(my_target, TRAIT_PERCIEVED_AS_CLOWN))
		return TRUE
	if(!istype(my_target, /mob/living/silicon/robot))
		return FALSE
	var/mob/living/silicon/robot/robot_target = my_target
	return istype(robot_target.model, /obj/item/robot_model/clown)

/datum/ai_behavior/play_with_clown
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_REQUIRE_REACH | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/ai_behavior/play_with_clown/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE
	set_movement_target(controller, target)

/datum/ai_behavior/play_with_clown/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	. = ..()
	var/mob/living/living_target = controller.blackboard[target_key]
	if(QDELETED(living_target))
		finish_action(controller, FALSE, target_key)
		return
	var/mob/living/living_pawn = controller.pawn
	living_pawn.UnarmedAttack(living_target, proximity_flag = TRUE)
	living_pawn.manual_emote("celebrates with [living_target]!")
	living_pawn.emote("flip")
	living_pawn.emote("beep")
	finish_action(controller, TRUE, target_key)

/datum/ai_behavior/play_with_clown/finish_action(datum/ai_controller/controller, succeeded, target_key, targeting_strategy_key, hiding_location_key)
	. = ..()
	var/mob/living/living_target = controller.blackboard[target_key]
	if(QDELETED(living_target))
		return
	controller.set_blackboard_key_assoc_lazylist(BB_TEMPORARY_IGNORE_LIST, REF(living_target), TRUE)
	controller.clear_blackboard_key(target_key)

/datum/ai_planning_subtree/slip_victims/SelectBehaviors(datum/ai_controller/basic_controller/bot/controller, seconds_per_tick)
	var/mob/living/living_pawn = controller.pawn
	if(!living_pawn.has_gravity())
		return

	var/atom/slippery_item = controller.blackboard[BB_SLIPPERY_TARGET]
	if(QDELETED(slippery_item) || !can_see(controller.pawn, slippery_item, 5))
		controller.clear_blackboard_key(BB_SLIP_TARGET)
		controller.clear_blackboard_key(BB_SLIPPERY_TARGET)
		controller.queue_behavior(/datum/ai_behavior/bot_search, BB_SLIPPERY_TARGET, controller.blackboard[BB_SLIPPERY_ITEMS])
		return

	var/mob/living/living_target = controller.blackboard[BB_SLIP_TARGET]

	if(QDELETED(living_target))
		var/static/list/to_slip = typecacheof(list(/mob/living/carbon/human))
		controller.queue_behavior(/datum/ai_behavior/bot_search/slip_target, BB_SLIP_TARGET, to_slip)
		return

	if(living_pawn.pulling == living_target)
		controller.queue_behavior(/datum/ai_behavior/drag_to_slip, BB_SLIP_TARGET, BB_SLIPPERY_TARGET)
		return SUBTREE_RETURN_FINISH_PLANNING

	controller.queue_behavior(/datum/ai_behavior/drag_target, BB_SLIP_TARGET)
	return SUBTREE_RETURN_FINISH_PLANNING

/datum/ai_behavior/bot_search/slip_target

/datum/ai_behavior/bot_search/slip_target/valid_target(datum/ai_controller/basic_controller/bot/controller, mob/living/my_target)
	return (!my_target.buckled && my_target.has_gravity())

/datum/ai_behavior/drag_to_slip
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION
	required_distance = 0

/datum/ai_behavior/drag_to_slip/setup(datum/ai_controller/controller, slip_target, slippery_target)
	. = ..()
	var/atom/target = controller.blackboard[slippery_target]
	if(QDELETED(target))
		return FALSE
	set_movement_target(controller, target)

/datum/ai_behavior/drag_to_slip/perform(seconds_per_tick, datum/ai_controller/controller, slip_target, slippery_target)
	. = ..()
	var/mob/living/our_pawn = controller.pawn
	var/atom/living_target = controller.blackboard[slip_target]
	if(QDELETED(living_target))
		finish_action(controller, FALSE, slip_target, slippery_target)
		return
	var/list/possible_dirs = GLOB.alldirs.Copy()
	possible_dirs -= get_dir(our_pawn, living_target)
	for(var/direction in possible_dirs)
		var/turf/possible_turf = get_step(our_pawn, direction)
		if(possible_turf.is_blocked_turf(source_atom = our_pawn))
			possible_dirs -= direction
	step(our_pawn, pick(possible_dirs))
	our_pawn.stop_pulling()
	finish_action(controller, TRUE, slip_target, slippery_target)

/datum/ai_behavior/drag_to_slip/finish_action(datum/ai_controller/controller, success, slip_target, slippery_target)
	. = ..()
	var/atom/slipped_victim = controller.blackboard[slip_target]
	if(!isnull(slipped_victim))
		controller.set_blackboard_key_assoc_lazylist(BB_TEMPORARY_IGNORE_LIST, REF(slipped_victim), TRUE)
	controller.clear_blackboard_key(slip_target)
	controller.clear_blackboard_key(slippery_target)

/datum/ai_behavior/drag_target
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION | AI_BEHAVIOR_REQUIRE_REACH

/datum/ai_behavior/drag_target/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE
	set_movement_target(controller, target)

/datum/ai_behavior/drag_target/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	. = ..()

	var/atom/movable/target = controller.blackboard[target_key]
	if(QDELETED(target) || target.anchored || target.pulledby)
		finish_action(controller, FALSE, target_key)
		return
	var/mob/living/our_mob = controller.pawn
	our_mob.start_pulling(target)
	finish_action(controller, TRUE, target_key)

/datum/ai_behavior/drag_target/finish_action(datum/ai_controller/controller, succeeded, target_key)
	. = ..()
	if(!succeeded)
		controller.clear_blackboard_key(target_key)
