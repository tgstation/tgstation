/datum/ai_planning_subtree/dog
	COOLDOWN_DECLARE(heel_cooldown)
	COOLDOWN_DECLARE(reset_ignore_cooldown)

/datum/ai_planning_subtree/dog/SelectBehaviors(datum/ai_controller/dog/controller, delta_time)
	var/mob/living/living_pawn = controller.pawn

	// occasionally reset our ignore list
	if(COOLDOWN_FINISHED(src, reset_ignore_cooldown) && length(controller.blackboard[BB_FETCH_IGNORE_LIST]))
		COOLDOWN_START(src, reset_ignore_cooldown, AI_FETCH_IGNORE_DURATION)
		controller.blackboard[BB_FETCH_IGNORE_LIST] = list()

	// if we were just ordered to heel, chill out for a bit
	if(!COOLDOWN_FINISHED(src, heel_cooldown))
		return

	// if we're not already carrying something and we have a fetch target (and we're not already doing something with it), see if we can eat/equip it
	if(!controller.blackboard[BB_SIMPLE_CARRY_ITEM] && controller.blackboard[BB_FETCH_TARGET])
		var/atom/movable/interact_target = controller.blackboard[BB_FETCH_TARGET]
		if(in_range(living_pawn, interact_target) && (isturf(interact_target.loc)))
			controller.current_movement_target = interact_target
			if(IS_EDIBLE(interact_target))
				controller.queue_behavior(/datum/ai_behavior/eat_snack)
			else if(isitem(interact_target))
				controller.queue_behavior(/datum/ai_behavior/simple_equip)
			else
				controller.blackboard[BB_FETCH_TARGET] = null
				controller.blackboard[BB_FETCH_DELIVER_TO] = null
			return

	// if we're carrying something and we have a destination to deliver it, do that
	if(controller.blackboard[BB_SIMPLE_CARRY_ITEM] && controller.blackboard[BB_FETCH_DELIVER_TO])
		var/atom/return_target = controller.blackboard[BB_FETCH_DELIVER_TO]
		if(!can_see(controller.pawn, return_target, length=AI_DOG_VISION_RANGE))
			// if the return target isn't in sight, we'll just forget about it and carry the thing around
			controller.blackboard[BB_FETCH_DELIVER_TO] = null
			return
		controller.current_movement_target = return_target
		controller.queue_behavior(/datum/ai_behavior/deliver_item)
		return
