/datum/ai_controller/basic_controller/bot/honkbot
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/secbot,
		BB_UNREACHABLE_LIST_COOLDOWN = 1 MINUTES,
		BB_ALWAYS_IGNORE_FACTION = TRUE,
	)
	behavior_tree_json = "honkbot.bt.json"
	// @bt-generated begin
	behavior_nodes = list(\
		"__t" = /datum/bt_node/composite/parallel,\
		"failure_policy" = BT_PARALLEL_FAILURE_CHILD_ONE,\
		"success_policy" = BT_PARALLEL_SUCCESS_CHILD_ONE,\
		"repeat_secondary" = TRUE,\
		"finish_on_primary" = TRUE,\
		"__c" = list(\
			list(\
				"__t" = /datum/bt_node/composite/selector,\
				"__c" = list(\
					/datum/bt_node/subtree/escape_captivity/pacifist,\
					/datum/bt_node/subtree/bot_respond_to_summon,\
					list(\
						"__t" = /datum/bt_node/composite/selector,\
						"__c" = list(\
							list(\
								"__t" = /datum/bt_node/decorator/bb_key_set,\
								"__c" = list(\
									list(\
										"__t" = /datum/bt_node/decorator/secbot_target_valid,\
										"__c" = list(\
											list(\
												"__t" = /datum/bt_node/composite/sequence,\
												"__c" = list(\
													list("__t" = /datum/bt_node/ai_behavior/move_to_target, "default_behavior_args" = list(BB_BASIC_MOB_CURRENT_TARGET, 1, TRUE)),\
													list("__t" = /datum/bt_node/ai_behavior/basic_melee_attack/interact_once/bot, "default_behavior_args" = list(BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETING_STRATEGY, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION))\
												)\
											)\
										)\
									)\
								),\
								"observer_abort" = BT_ABORT_BOTH,\
								"key" = BB_BASIC_MOB_CURRENT_TARGET\
							),\
							list(\
								"__t" = /datum/bt_node/decorator/bb_key_set,\
								"__c" = list(\
									/datum/bt_node/subtree/honkbot_slip\
								),\
								"observer_abort" = BT_ABORT_BOTH,\
								"key" = BB_SLIPPERY_TARGET\
							),\
							list(\
								"__t" = /datum/bt_node/decorator/bb_key_set,\
								"__c" = list(\
									list(\
										"__t" = /datum/bt_node/composite/sequence,\
										"__c" = list(\
											list("__t" = /datum/bt_node/ai_behavior/move_to_target, "default_behavior_args" = list(BB_CLOWN_FRIEND, 1, TRUE)),\
											list("__t" = /datum/bt_node/ai_behavior/play_with_clown, "default_behavior_args" = list(BB_CLOWN_FRIEND))\
										)\
									)\
								),\
								"observer_abort" = BT_ABORT_BOTH,\
								"key" = BB_CLOWN_FRIEND\
							),\
							list(\
								"__t" = /datum/bt_node/composite/parallel,\
								"failure_policy" = BT_PARALLEL_FAILURE_CHILD_ONE,\
								"success_policy" = BT_PARALLEL_SUCCESS_CHILD_ONE,\
								"repeat_secondary" = TRUE,\
								"finish_on_primary" = TRUE,\
								"__c" = list(\
									/datum/bt_node/subtree/bot_patrol,\
									list(\
										"__t" = /datum/bt_node/composite/selector,\
										"__c" = list(\
											list("__t" = /datum/bt_node/ai_behavior/find_potential_targets, "default_behavior_args" = list(BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETING_STRATEGY, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION)),\
											list(\
												"__t" = /datum/bt_node/composite/sequence,\
												"__c" = list(\
													list("__t" = /datum/bt_node/ai_behavior/find_slippery_item, "default_behavior_args" = list(BB_SLIPPERY_TARGET)),\
													list("__t" = /datum/bt_node/ai_behavior/bot_search/find_slip_victim, "default_behavior_args" = list(BB_SLIP_TARGET))\
												)\
											),\
											list("__t" = /datum/bt_node/ai_behavior/find_clown_friend, "default_behavior_args" = list(BB_CLOWN_FRIEND))\
										)\
									)\
								)\
							)\
						)\
					)\
				)\
			)\
		)\
	)
	// @bt-generated end
	reset_keys = list(
		BB_BEACON_TARGET,
		BB_PREVIOUS_BEACON_TARGET,
		BB_BOT_SUMMON_TARGET,
	)

/datum/ai_controller/basic_controller/bot/honkbot/TryPossessPawn(atom/new_pawn)
	. = ..()
	if(. & AI_CONTROLLER_INCOMPATIBLE)
		return
	// on_clear_target intentionally removed — it caused grab-then-immediately-release bug
	// Cleanup is handled by on_stop_pulling instead
	RegisterSignal(new_pawn, COMSIG_ATOM_NO_LONGER_PULLING, PROC_REF(on_stop_pulling))

/datum/ai_controller/basic_controller/bot/honkbot/proc/on_stop_pulling(datum/source)
	SIGNAL_HANDLER

	if(!blackboard_key_exists(BB_SLIP_TARGET))
		return

	var/atom/slip_target = blackboard[BB_SLIP_TARGET]
	add_to_blacklist(slip_target)
	clear_blackboard_key(BB_SLIP_TARGET)

// =============================================================================
// Slip subtree
// =============================================================================

/datum/bt_node/subtree/honkbot_slip
	behavior_tree_json = "honkbot_slip.bt.json"
	// @bt-generated begin
	behavior_nodes = list(\
		"__t" = /datum/bt_node/decorator/can_see_target,\
		"__c" = list(\
			list(\
				"__t" = /datum/bt_node/decorator/can_see_target,\
				"__c" = list(\
					list(\
						"__t" = /datum/bt_node/decorator/pawn_has_gravity,\
						"__c" = list(\
							list(\
								"__t" = /datum/bt_node/composite/sequence,\
								"__c" = list(\
									list("__t" = /datum/bt_node/ai_behavior/move_to_target, "default_behavior_args" = list(BB_SLIP_TARGET, 0, TRUE)),\
									list("__t" = /datum/bt_node/ai_behavior/grab_target, "default_behavior_args" = list(BB_SLIP_TARGET)),\
									list("__t" = /datum/bt_node/ai_behavior/move_to_target, "default_behavior_args" = list(BB_SLIPPERY_TARGET, 0, TRUE)),\
									list("__t" = /datum/bt_node/ai_behavior/release_and_slip, "default_behavior_args" = list(BB_SLIP_TARGET)),\
									list("__t" = /datum/bt_node/ai_behavior/perform_emote, "default_behavior_args" = list("flip"))\
								)\
							)\
						)\
					)\
				),\
				"key" = BB_SLIP_TARGET,\
				"range" = 5\
			)\
		),\
		"key" = BB_SLIPPERY_TARGET,\
		"range" = 5\
	)
	// @bt-generated end

// =============================================================================
// Random honk (prob-gated use_mob_ability)
// =============================================================================

/datum/bt_node/ai_behavior/use_mob_ability/random_honk

/datum/bt_node/ai_behavior/use_mob_ability/random_honk/perform(seconds_per_tick, datum/ai_controller/controller, ability_key)
	if(!SPT_PROB(5, seconds_per_tick))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	return ..()

// =============================================================================
// Find slip victim
// =============================================================================

/datum/bt_node/ai_behavior/bot_search/find_slip_victim

/datum/bt_node/ai_behavior/bot_search/find_slip_victim/get_looking_for_typecache()
	return typecacheof(list(/mob/living/carbon/human))

/datum/bt_node/ai_behavior/bot_search/find_slip_victim/valid_target(datum/ai_controller/basic_controller/bot/controller, atom/my_target)
	var/mob/living/carbon/human/candidate = my_target
	return !candidate.buckled && candidate.has_gravity()

// =============================================================================
// Release and slip
// =============================================================================

// Positions the pulled victim onto the slippery item by stepping away, then releases.
/datum/bt_node/ai_behavior/release_and_slip

/datum/bt_node/ai_behavior/release_and_slip/perform(seconds_per_tick, datum/ai_controller/controller, victim_key)
	var/mob/living/victim = controller.blackboard[victim_key]
	var/mob/living/our_mob = controller.pawn
	if(QDELETED(victim) || our_mob.pulling != victim)
		EVLOG_TEXT(controller, EVLOG_CATEGORY_AI_BEHAVIORS, "[our_mob] release_and_slip: not pulling victim")
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	EVLOG_MAPTEXT(controller, EVLOG_CATEGORY_AI_BEHAVIORS, "[our_mob] releasing [victim]!", get_turf(our_mob), "HONK!")
	var/list/possible_dirs = GLOB.alldirs.Copy()
	possible_dirs -= get_dir(our_mob, victim)
	for(var/direction in possible_dirs)
		var/turf/possible_turf = get_step(our_mob, direction)
		if(possible_turf.is_blocked_turf(source_atom = our_mob))
			possible_dirs -= direction
	if(length(possible_dirs))
		step(our_mob, pick(possible_dirs))
	our_mob.stop_pulling()
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

// =============================================================================
// Find slippery item
// =============================================================================

/datum/bt_node/ai_behavior/find_slippery_item
	action_cooldown = 5 SECONDS

/datum/bt_node/ai_behavior/find_slippery_item/perform(seconds_per_tick, datum/ai_controller/basic_controller/bot/controller, target_key)
	var/mob/living/living_pawn = controller.pawn
	if(!living_pawn.has_gravity())
		EVLOG_TEXT(controller, EVLOG_CATEGORY_AI_BEHAVIORS, "[living_pawn] find_slippery_item: no gravity")
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	var/list/ignore_list = controller.blackboard[BB_TEMPORARY_IGNORE_LIST]
	var/list/slippery_items = controller.blackboard[BB_SLIPPERY_ITEMS]
	if(!length(slippery_items))
		EVLOG_TEXT(controller, EVLOG_CATEGORY_AI_BEHAVIORS, "[living_pawn] find_slippery_item: BB_SLIPPERY_ITEMS is empty")
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	var/list/type_cache = typecacheof(slippery_items)
	for(var/atom/potential in oview(5, living_pawn))
		if(!is_type_in_typecache(potential, type_cache))
			continue
		if(LAZYACCESS(ignore_list, potential))
			continue
		if(!can_see(living_pawn, potential, 5))
			continue
		EVLOG_MAPTEXT(controller, EVLOG_CATEGORY_AI_BEHAVIORS, "[living_pawn] found slippery item: [potential]", get_turf(potential), "Slippery!")
		controller.set_blackboard_key(target_key, potential)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	EVLOG_TEXT(controller, EVLOG_CATEGORY_AI_BEHAVIORS, "[living_pawn] find_slippery_item: no slippery item in range")
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

// =============================================================================
// Clown friend search and play
// =============================================================================

/datum/bt_node/ai_behavior/find_clown_friend
	action_cooldown = 5 SECONDS

/datum/bt_node/ai_behavior/find_clown_friend/perform(seconds_per_tick, datum/ai_controller/basic_controller/bot/controller, target_key)
	var/list/ignore_list = controller.blackboard[BB_TEMPORARY_IGNORE_LIST]
	for(var/mob/living/nearby_mob in oview(5, controller.pawn))
		if(LAZYACCESS(ignore_list, nearby_mob))
			continue
		if(nearby_mob.stat != CONSCIOUS)
			continue
		var/is_clown = HAS_TRAIT(nearby_mob, TRAIT_PERCEIVED_AS_CLOWN)
		if(!is_clown && istype(nearby_mob, /mob/living/silicon/robot))
			var/mob/living/silicon/robot/robot_target = nearby_mob
			is_clown = istype(robot_target.model, /obj/item/robot_model/clown)
		if(!is_clown)
			continue
		if(controller.set_if_can_reach(key = target_key, target = nearby_mob))
			return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	EVLOG_TEXT(controller, EVLOG_CATEGORY_AI_BEHAVIORS, "[controller.pawn] find_clown_friend: no clown in range")
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

/datum/bt_node/ai_behavior/play_with_clown

/datum/bt_node/ai_behavior/play_with_clown/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	var/mob/living/living_target = controller.blackboard[target_key]
	if(QDELETED(living_target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	if(get_dist(controller.pawn, living_target) > 1)
		return AI_BEHAVIOR_INSTANT
	var/mob/living/living_pawn = controller.pawn
	var/datum/action/honk_ability = controller.blackboard[BB_HONK_ABILITY]
	honk_ability?.Trigger()
	living_pawn.manual_emote("celebrates with [living_target]!")
	living_pawn.emote("flip")
	living_pawn.emote("beep")
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/bt_node/ai_behavior/play_with_clown/finish_action(datum/ai_controller/basic_controller/bot/controller, succeeded, target_key)
	. = ..()
	var/mob/living/living_target = controller.blackboard[target_key]
	if(!isnull(living_target))
		controller.add_to_blacklist(living_target)
	controller.clear_blackboard_key(target_key)
