/datum/ai_controller/basic_controller/bot/honkbot
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_UNREACHABLE_LIST_COOLDOWN = 1 MINUTES,
		BB_ALWAYS_IGNORE_FACTION = TRUE,
	)
	planning_subtrees = list(
		/datum/ai_planning_subtree/respond_to_summon,
		/datum/ai_planning_subtree/use_mob_ability/random_honk,
		/datum/ai_planning_subtree/find_wanted_targets,
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
	add_to_blacklist(slip_target)
	clear_blackboard_key(BB_SLIP_TARGET)

/datum/ai_planning_subtree/find_wanted_targets

/datum/ai_planning_subtree/find_wanted_targets/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/static/list/can_arrest = typecacheof(list(/mob/living/carbon/human))
	if(!controller.blackboard_key_exists(BB_BASIC_MOB_CURRENT_TARGET))
		controller.queue_behavior(/datum/ai_behavior/bot_search/wanted_targets, BB_BASIC_MOB_CURRENT_TARGET, can_arrest)

/datum/ai_behavior/bot_search/wanted_targets

/datum/ai_behavior/bot_search/wanted_targets/valid_target(datum/ai_controller/basic_controller/bot/controller, mob/living/my_target)
	if(!ishuman(my_target))
		return FALSE
	var/mob/living/carbon/human/human_target = my_target
	if(human_target.handcuffed || human_target.stat != CONSCIOUS)
		return FALSE
	if(locate(human_target) in controller.blackboard[BB_BASIC_MOB_RETALIATE_LIST])
		return TRUE
	var/mob/living/basic/bot/honkbot/my_bot = controller.pawn
	var/honkbot_flags = my_bot.honkbot_flags
	var/assess_flags = NONE
	if(human_target.IsParalyzed() && !(honkbot_flags & HONKBOT_HANDCUFF_TARGET))
		return FALSE
	if(my_bot.bot_access_flags & BOT_COVER_EMAGGED)
		assess_flags |= JUDGE_EMAGGED
	if(honkbot_flags & HONKBOT_CHECK_IDS)
		assess_flags |= JUDGE_IDCHECK
	if(honkbot_flags & HONKBOT_CHECK_RECORDS)
		assess_flags |= JUDGE_RECORDCHECK
	return (human_target.assess_threat(assess_flags) > 0)

/datum/ai_planning_subtree/troll_target

/datum/ai_planning_subtree/troll_target/SelectBehaviors(datum/ai_controller/basic_controller/bot/controller, seconds_per_tick)
	var/mob/living/carbon/my_target = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	if(QDELETED(my_target) || !istype(my_target) || my_target.handcuffed)
		controller.clear_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET)
		return

	var/mob/living/basic/bot/honkbot/my_bot = controller.pawn
	if(my_target.IsParalyzed() && !(my_bot.honkbot_flags & HONKBOT_HANDCUFF_TARGET))
		controller.clear_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET)
		return

	controller.queue_behavior(/datum/ai_behavior/basic_melee_attack/interact_once/honkbot, BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETING_STRATEGY)
	return SUBTREE_RETURN_FINISH_PLANNING

/datum/ai_behavior/basic_melee_attack/interact_once/honkbot

/datum/ai_behavior/basic_melee_attack/interact_once/honkbot/finish_action(datum/ai_controller/controller, succeeded, target_key, targeting_strategy_key, hiding_location_key)
	var/mob/living/carbon/human/human_target = controller.blackboard[target_key]
	if(!isnull(human_target))
		controller.remove_from_blackboard_lazylist_key(BB_BASIC_MOB_RETALIATE_LIST, human_target)
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
	if(HAS_TRAIT(my_target, TRAIT_PERCEIVED_AS_CLOWN))
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
	var/mob/living/living_target = controller.blackboard[target_key]
	if(QDELETED(living_target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	var/mob/living/living_pawn = controller.pawn
	var/datum/action/honk_ability = controller.blackboard[BB_HONK_ABILITY]
	honk_ability?.Trigger()
	living_pawn.manual_emote("celebrates with [living_target]!")
	living_pawn.emote("flip")
	living_pawn.emote("beep")
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/play_with_clown/finish_action(datum/ai_controller/basic_controller/bot/controller, succeeded, target_key, targeting_strategy_key, hiding_location_key)
	. = ..()
	var/mob/living/living_target = controller.blackboard[target_key]
	if(QDELETED(living_target))
		return
	controller.add_to_blacklist(living_target)
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
	var/mob/living/our_pawn = controller.pawn
	var/atom/living_target = controller.blackboard[slip_target]
	if(QDELETED(living_target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	var/list/possible_dirs = GLOB.alldirs.Copy()
	possible_dirs -= get_dir(our_pawn, living_target)
	for(var/direction in possible_dirs)
		var/turf/possible_turf = get_step(our_pawn, direction)
		if(possible_turf.is_blocked_turf(source_atom = our_pawn))
			possible_dirs -= direction
	step(our_pawn, pick(possible_dirs))
	our_pawn.stop_pulling()
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/drag_to_slip/finish_action(datum/ai_controller/basic_controller/bot/controller, success, slip_target, slippery_target)
	. = ..()
	if(success)
		var/mob/living/living_pawn = controller.pawn
		living_pawn.emote("flip")
	var/atom/slipped_victim = controller.blackboard[slip_target]
	if(!isnull(slipped_victim))
		controller.add_to_blacklist(slipped_victim)
	controller.clear_blackboard_key(slip_target)
	controller.clear_blackboard_key(slippery_target)

/datum/ai_planning_subtree/use_mob_ability/random_honk
	ability_key = BB_HONK_ABILITY

/datum/ai_planning_subtree/use_mob_ability/random_honk/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	if(!SPT_PROB(5, seconds_per_tick))
		return
	return ..()

