/datum/ai_controller/basic_controller/pet_cult
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/cultist,
		BB_RUNE_CONVERT_TRIES = 0,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/find_occupied_rune,
		/datum/ai_planning_subtree/find_sacrifice_target,
		/datum/ai_planning_subtree/drag_target_to_rune,
	)

/datum/ai_controller/basic_controller/pet_cult/proc/delete_pull_target(datum/source, atom/movable/was_pulling)
	SIGNAL_HANDLER

	UnregisterSignal(src, COMSIG_ATOM_NO_LONGER_PULLING)

	if(was_pulling == blackboard[BB_SACRIFICE_TARGET])
		clear_blackboard_key(BB_SACRIFICE_TARGET)

/datum/targeting_strategy/basic/cultist

/datum/targeting_strategy/basic/cultist/faction_check(datum/ai_controller/controller, mob/living/living_mob, mob/living/the_target)
	return IS_CULTIST_OR_CULTIST_MOB(the_target)


/datum/ai_planning_subtree/find_occupied_rune

/datum/ai_planning_subtree/find_occupied_rune/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	if(controller.blackboard_key_exists(BB_OCCUPIED_RUNE))
		controller.queue_behavior(/datum/ai_behavior/activate_rune, BB_OCCUPIED_RUNE)
		return SUBTREE_RETURN_FINISH_PLANNING

	controller.queue_behavior(/datum/ai_behavior/find_and_set/occupied_rune, BB_OCCUPIED_RUNE, /obj/effect/rune/convert)

/datum/ai_behavior/find_and_set/occupied_rune

/datum/ai_behavior/find_and_set/occupied_rune/search_tactic(datum/ai_controller/controller, locate_path, search_range)
	var/datum/team/cult/cult_team = controller.blackboard[BB_CULT_TEAM]
	if(isnull(cult_team))
		return null

	for(var/obj/effect/rune/convert/target_rune in oview(search_range, controller.pawn))
		controller.set_blackboard_key(BB_NEARBY_RUNE, target_rune)
		var/mob/living/occupant = locate(/mob/living/carbon/human) in get_turf(target_rune)
		if(isnull(occupant))
			continue
		if(occupant.stat < SOFT_CRIT || occupant.stat > HARD_CRIT)
			continue
		if(!is_convertable_to_cult(occupant, cult_team))
			continue
		return target_rune

	return null

/datum/ai_behavior/activate_rune
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION | AI_BEHAVIOR_REQUIRE_REACH
	action_cooldown = 3 SECONDS

/datum/ai_behavior/activate_rune/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/turf/target = controller.blackboard[target_key]
	if(isnull(target))
		return FALSE
	set_movement_target(controller, target)

/datum/ai_behavior/activate_rune/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	. = ..()
	var/atom/target = controller.blackboard[target_key]

	if(QDELETED(target))
		finish_action(controller, FALSE, target_key)
		return

	var/datum/team/cult/cult_team = controller.blackboard[BB_CULT_TEAM]
	var/mob/living/sac_human = locate(/mob/living/carbon/human) in get_turf(target)

	if(isnull(sac_human) || !is_convertable_to_cult(sac_human, cult_team))
		finish_action(controller, FALSE, target_key)
		return

	var/mob/living/basic/living_pawn = controller.pawn
	living_pawn.melee_attack(target)

	finish_action(controller, TRUE, target_key)
	return

/datum/ai_behavior/activate_rune/finish_action(datum/ai_controller/controller, success, target_key)
	. = ..()
	controller.clear_blackboard_key(target_key)


/datum/ai_planning_subtree/find_sacrifice_target

/datum/ai_planning_subtree/find_sacrifice_target/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/living_pawn = controller.pawn

	if(!isnull(living_pawn.pulling))
		return

	if(controller.blackboard_key_exists(BB_SACRIFICE_TARGET))
		controller.queue_behavior(/datum/ai_behavior/pull_target/cult_sacrifice, BB_SACRIFICE_TARGET)
		return SUBTREE_RETURN_FINISH_PLANNING

	controller.queue_behavior(/datum/ai_behavior/find_and_set/sacrificial_lamb, BB_SACRIFICE_TARGET, /mob/living/carbon/human)

/datum/ai_behavior/find_and_set/sacrificial_lamb

/datum/ai_behavior/find_and_set/sacrificial_lamb/search_tactic(datum/ai_controller/controller, locate_path, search_range)
	var/datum/team/cult/cult_team = controller.blackboard[BB_CULT_TEAM]
	if(isnull(cult_team))
		return null
	var/mob/living/living_pawn = controller.pawn
	for(var/mob/living/carbon/human/target in oview(search_range, controller.pawn))
		if(target.stat < SOFT_CRIT || target.stat > HARD_CRIT)
			continue
		if(!is_convertable_to_cult(target, cult_team))
			continue
		if(target.buckled || target.move_resist > living_pawn.move_force || target.pulledby)
			continue
		return target

	return null

/datum/ai_behavior/pull_target/cult_sacrifice

/datum/ai_behavior/pull_target/cult_sacrifice/finish_action(datum/ai_controller/basic_controller/controller, succeeded, target_key)
	. = ..()
	if(!succeeded)
		return
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return
	controller.RegisterSignal(controller.pawn, COMSIG_ATOM_NO_LONGER_PULLING, TYPE_PROC_REF(/datum/ai_controller/basic_controller/pet_cult, delete_pull_target), override = TRUE)

/datum/ai_planning_subtree/drag_target_to_rune

/datum/ai_planning_subtree/drag_target_to_rune/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)

	if(!controller.blackboard_key_exists(BB_SACRIFICE_TARGET)) //no target, we dont need to do anything
		return

	var/mob/living/our_pawn = controller.pawn

	if(isnull(our_pawn.pulling))
		return

	if(!controller.blackboard_key_exists(BB_NEARBY_RUNE))
		controller.queue_behavior(/datum/ai_behavior/use_mob_ability, BB_RUNE_ABILITY)
		return SUBTREE_RETURN_FINISH_PLANNING

	controller.queue_behavior(/datum/ai_behavior/drag_target_to_rune, BB_NEARBY_RUNE, BB_SACRIFICE_TARGET)


/datum/ai_behavior/drag_target_to_rune
	required_distance = 0
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT

/datum/ai_behavior/drag_target_to_rune/setup(datum/ai_controller/controller, target_key, sacrifice_key)
	. = ..()
	var/turf/target = controller.blackboard[target_key]
	if(isnull(target))
		return FALSE
	set_movement_target(controller, target)

/datum/ai_behavior/drag_target_to_rune/perform(seconds_per_tick, datum/ai_controller/controller, target_key, sacrifice_key)
	. = ..()
	var/mob/living/our_pawn = controller.pawn
	var/atom/sacrifice_target = controller.blackboard[sacrifice_key]
	if(isnull(sacrifice_target))
		finish_action(controller, FALSE, target_key, sacrifice_key)
		return
	var/list/possible_dirs = GLOB.alldirs.Copy()
	possible_dirs -= get_dir(our_pawn, sacrifice_target)
	for(var/direction in possible_dirs)
		var/turf/possible_turf = get_step(our_pawn, direction)
		if(possible_turf.is_blocked_turf(source_atom = our_pawn))
			possible_dirs -= direction
	step(our_pawn, pick(possible_dirs))
	our_pawn.stop_pulling()
	finish_action(controller, TRUE, target_key, sacrifice_target)


/datum/ai_behavior/drag_target_to_rune/finish_action(datum/ai_controller/controller, success, target_key, sacrifice_target)
	. = ..()
	if(success)
		var/atom/sacrifice_rune = controller.blackboard[target_key]
		controller.set_blackboard_key(BB_OCCUPIED_RUNE, sacrifice_rune)
	controller.clear_blackboard_key(sacrifice_target)
	controller.clear_blackboard_key(target_key)

