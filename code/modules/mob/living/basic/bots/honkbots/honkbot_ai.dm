/datum/ai_controller/basic_controller/bot/honkbot
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/secbot,
		BB_UNREACHABLE_LIST_COOLDOWN = 1 MINUTES,
		BB_ALWAYS_IGNORE_FACTION = TRUE,
	)
	behavior_tree_json = "code/modules/mob/living/basic/bots/honkbots/honkbot.bt.json"
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



/datum/bt_node/subtree/honkbot_slip
	behavior_tree_json = "code/modules/mob/living/basic/bots/honkbots/honkbot_slip.bt.json"



/datum/bt_node/ai_behavior/use_mob_ability/random_honk

/datum/bt_node/ai_behavior/use_mob_ability/random_honk/perform(seconds_per_tick, datum/ai_controller/controller)
	if(!SPT_PROB(5, seconds_per_tick))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	return ..()



/// Valid if the target is a visible human who isn't buckled and has gravity — someone a slip can actually knock over.
/datum/targeting_strategy/can_see/slip_victim/is_valid_target(mob/living/living_mob, atom/target, vision_range, datum/ai_controller/controller = null)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/carbon/human/candidate = target
	if(!istype(candidate))
		return FALSE
	return !candidate.buckled && candidate.has_gravity()


// Positions the pulled victim onto the slippery item by stepping away, then releases.
/datum/bt_node/ai_behavior/release_and_slip
	var/victim_key

/datum/bt_node/ai_behavior/release_and_slip/perform(seconds_per_tick, datum/ai_controller/controller)
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


/// Gathers nearby atoms matching the slippery-item typepaths stored in BB_SLIPPERY_ITEMS.
/datum/target_source/honkbot_slippery

/datum/target_source/honkbot_slippery/collect_candidates(mob/living/pawn, datum/ai_controller/controller, range)
	var/list/slippery_items = controller.blackboard[BB_SLIPPERY_ITEMS]
	if(!length(slippery_items))
		return list()
	return typecache_filter_list(oview(range, pawn), typecacheof(slippery_items))

/// Valid only if the target is within line of sight (not just within range).
/datum/targeting_strategy/can_see/is_valid_target(mob/living/living_mob, atom/target, vision_range, datum/ai_controller/controller = null)
	. = ..()
	if(!.)
		return FALSE
	return can_see(living_mob, target, vision_range)

/// Valid if the target is a conscious clown (by trait, or a borg running the clown model).
/datum/targeting_strategy/clown_friend/is_valid_target(mob/living/living_mob, atom/target, vision_range, datum/ai_controller/controller = null)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/target_mob = target
	if(!isliving(target_mob) || target_mob.stat != CONSCIOUS)
		return FALSE
	if(HAS_TRAIT(target_mob, TRAIT_PERCEIVED_AS_CLOWN))
		return TRUE
	if(istype(target_mob, /mob/living/silicon/robot))
		var/mob/living/silicon/robot/robot_target = target_mob
		return istype(robot_target.model, /obj/item/robot_model/clown)
	return FALSE

/datum/bt_node/ai_behavior/play_with_clown
	var/target_key

/datum/bt_node/ai_behavior/play_with_clown/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/living_target = controller.blackboard[target_key]
	if(QDELETED(living_target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	if(get_dist(controller.pawn, living_target) > 1)
		return AI_BEHAVIOR_INSTANT
	var/mob/living/living_pawn = controller.pawn
	var/datum/action/honk_ability = controller.blackboard[BB_HONK_ABILITY]
	honk_ability?.Trigger()
	living_pawn.manual_emote("celebrates with [living_target]!")
	INVOKE_ASYNC(living_pawn, TYPE_PROC_REF(/mob, emote), "flip")
	INVOKE_ASYNC(living_pawn, TYPE_PROC_REF(/mob, emote), "beep")
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/bt_node/ai_behavior/play_with_clown/finish_action(datum/ai_controller/basic_controller/bot/controller, succeeded)
	. = ..()
	var/mob/living/living_target = controller.blackboard[target_key]
	if(!isnull(living_target))
		controller.add_to_blacklist(living_target)
	controller.clear_blackboard_key(target_key)
