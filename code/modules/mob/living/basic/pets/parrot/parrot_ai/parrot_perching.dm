///subtree to perch on targets
/datum/ai_planning_subtree/perch_on_target
	///perchance...
	var/perch_chance = 5
	///chance we unbuckle
	var/unperch_chance = 15


/datum/ai_planning_subtree/perch_on_target/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/living_pawn = controller.pawn
	var/atom/buckled_to = living_pawn.buckled

	//do we have a current target or is chance to unbuckle has passed? then unbuckle!
	if(buckled_to)
		if((SPT_PROB(unperch_chance, seconds_per_tick) || controller.blackboard_key_exists(BB_BASIC_MOB_CURRENT_TARGET)))
			controller.queue_behavior(/datum/ai_behavior/unbuckle_mob)
			return
		return SUBTREE_RETURN_FINISH_PLANNING

	//if we are perched, we can go find something else to perch too
	var/final_chance = HAS_TRAIT(living_pawn, TRAIT_PARROT_PERCHED) ? unperch_chance : perch_chance

	if(!SPT_PROB(final_chance, seconds_per_tick) || controller.blackboard_key_exists(BB_BASIC_MOB_CURRENT_TARGET))
		return

	if(controller.blackboard_key_exists(BB_PERCH_TARGET))
		controller.queue_behavior(/datum/ai_behavior/perch_on_target, BB_PERCH_TARGET)
		return SUBTREE_RETURN_FINISH_PLANNING

	//50 50 chance to look for an object, or a friend
	if(prob(50))
		controller.queue_behavior(/datum/ai_behavior/find_and_set/nearby_friends, BB_PERCH_TARGET)
		return

	controller.queue_behavior(/datum/ai_behavior/find_and_set/in_list, BB_PERCH_TARGET, controller.blackboard[BB_PARROT_PERCH_TYPES])

/// Parrot behavior that allows them to perch on a target.
/datum/ai_behavior/perch_on_target
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_REQUIRE_REACH | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/ai_behavior/perch_on_target/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE

	set_movement_target(controller, target)

/datum/ai_behavior/perch_on_target/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/mob/living/basic/parrot/living_pawn = controller.pawn

	if(!ishuman(target))
		living_pawn.start_perching(target)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

	if(!check_human_conditions(target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	living_pawn.start_perching(target)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/perch_on_target/proc/check_human_conditions(mob/living/living_human)
	if(living_human.stat == DEAD || LAZYLEN(living_human.buckled_mobs) >= living_human.max_buckled_mobs)
		return FALSE

	return TRUE

/datum/ai_behavior/perch_on_target/finish_action(datum/ai_controller/controller, succeeded, target_key)
	. = ..()
	controller.clear_blackboard_key(target_key)
