/// By how much should the time until they start hiding again be multiplied with.
#define START_HIDING_COOLDOWN_COEFFICIENT 0.1

/// This subtree causes the mob to go into hiding after a random duration
/// since the last time they went into hiding.
/datum/ai_planning_subtree/random_hiding
	operational_datums = list(/datum/element/can_hide)
	/// The blackboard cooldown key to check before we hide.
	var/cooldown_before_hiding_key = BB_HIDING_COOLDOWN_BEFORE_HIDING
	/// The blackboard cooldown key to check before check if we can should stop hiding.
	var/cooldown_before_stop_hiding_key = BB_HIDING_COOLDOWN_BEFORE_STOP_HIDING
	/// The blackboard target key to check, that will force a cooldown reset
	/// if the cooldown is below the minimum cooldown duration.
	var/target_key = BB_BASIC_MOB_CURRENT_TARGET


/datum/ai_planning_subtree/random_hiding/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/cooldown_minimum = controller.blackboard[BB_HIDING_COOLDOWN_MINIMUM] || 1 MINUTES
	var/cooldown_maximum = controller.blackboard[BB_HIDING_COOLDOWN_MAXIMUM] || 3 MINUTES

	if(controller.blackboard[BB_HIDING_HIDDEN])
		// We can't stop hiding randomly until this cooldown is over.
		if(controller.blackboard[cooldown_before_stop_hiding_key] && controller.blackboard[cooldown_before_stop_hiding_key] > world.time)
			return

		var/chance_to_stop_hiding = controller.blackboard[BB_HIDING_RANDOM_STOP_HIDING_CHANCE] || DEFAULT_RANDOM_STOP_HIDING_CHANCE
		if(SPT_PROB(chance_to_stop_hiding, seconds_per_tick))
			controller.queue_behavior(/datum/ai_behavior/toggle_hiding, FALSE)
			var/new_cooldown = world.time + rand(cooldown_minimum, cooldown_maximum) * START_HIDING_COOLDOWN_COEFFICIENT
			controller.set_blackboard_key(cooldown_before_hiding_key, new_cooldown)

			return SUBTREE_RETURN_FINISH_PLANNING

		return // We don't want to do anything else if we're currently hiding.

	// If we have a target, we possibly want to reset the cooldown.
	if(controller.blackboard[target_key])
		// If the cooldown we have is more than the minimum cooldown, don't do anything.
		if(controller.blackboard[cooldown_before_hiding_key] && controller.blackboard[cooldown_before_hiding_key] - world.time >= cooldown_minimum)
			return

		// Let's just reset the cooldown, now, then.
		var/new_cooldown = world.time + rand(cooldown_minimum, cooldown_maximum)
		controller.set_blackboard_key(cooldown_before_hiding_key, new_cooldown)

		return

	// If we can't hide yet, we do nothing.
	if(controller.blackboard[cooldown_before_hiding_key] && controller.blackboard[cooldown_before_hiding_key] > world.time)
		return

	// We can hide, so let's do just that!
	controller.queue_behavior(/datum/ai_behavior/toggle_hiding, TRUE)
	var/new_cooldown = world.time + rand(cooldown_minimum, cooldown_maximum)
	controller.set_blackboard_key(cooldown_before_stop_hiding_key, new_cooldown)

	return SUBTREE_RETURN_FINISH_PLANNING
