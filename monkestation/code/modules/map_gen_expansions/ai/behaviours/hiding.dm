/// This behavior is to run any code that needs to be ran when the mob is going
/// into hiding, or coming out from hiding.
/datum/ai_behavior/toggle_hiding
	/// The blackboard cooldown key to check before we can hide. Only here
	/// to avoid copy-paste in other subtrees/behaviors, should only be SET,
	/// not READ here.
	var/cooldown_before_hiding_key = BB_HIDING_COOLDOWN_BEFORE_HIDING


/datum/ai_behavior/toggle_hiding/setup(datum/ai_controller/controller, ...)
	. = ..()

	if(!controller.blackboard[BB_HIDING_AGGRO_RANGE_NOT_HIDING])
		controller.set_blackboard_key(BB_HIDING_AGGRO_RANGE_NOT_HIDING, controller.blackboard[BB_AGGRO_RANGE])


/datum/ai_behavior/toggle_hiding/perform(seconds_per_tick, datum/ai_controller/controller, now_hiding)
	var/mob/living/basic/hiding_pawn = controller.pawn

	if(!istype(hiding_pawn))
		finish_action(controller, FALSE)
		return

	var/mob/living/living_pawn = controller.pawn

	// Let's add some checks if we're trying to hide.
	if(now_hiding)
		// We can't hide if we can't move properly, or if we don't have any valid hiding locations.
		if(!(living_pawn.mobility_flags & MOBILITY_MOVE) || !isturf(living_pawn.loc) || living_pawn.pulledby || !islist(controller.blackboard[BB_HIDING_CAN_HIDE_ON]))
			finish_action(controller, FALSE)
			return

		// We can't hide if we don't match the proper turf type we need to hide onto.
		if(!controller.blackboard[BB_HIDING_CAN_HIDE_ON][living_pawn.loc.type])
			finish_action(controller, FALSE)
			return

	var/hiding_status_changed = controller.blackboard[BB_HIDING_HIDDEN] != now_hiding

	if(!hiding_status_changed)
		finish_action(controller, TRUE)
		return

	controller.set_blackboard_key(BB_HIDING_HIDDEN, now_hiding)
	SEND_SIGNAL(living_pawn, COMSIG_MOVABLE_TOGGLE_HIDING, now_hiding, TRUE)

	var/new_vision_range = now_hiding ? controller.blackboard[BB_HIDING_AGGRO_RANGE] || DEFAULT_HIDING_AGGRO_RANGE : controller.blackboard[BB_HIDING_AGGRO_RANGE_NOT_HIDING]

	if(!now_hiding)
		var/cooldown_minimum = controller.blackboard[BB_HIDING_COOLDOWN_MINIMUM] || 1 MINUTES
		var/cooldown_maximum = controller.blackboard[BB_HIDING_COOLDOWN_MAXIMUM] || 3 MINUTES
		var/new_cooldown = world.time + rand(cooldown_minimum, cooldown_maximum)
		controller.set_blackboard_key(cooldown_before_hiding_key, new_cooldown)

	controller.set_blackboard_key(BB_AGGRO_RANGE, new_vision_range)

	finish_action(controller, TRUE)
	return

