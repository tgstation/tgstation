/// Moves to and applies full-body brute damage to a target while pulling them.
/datum/ai_behavior/break_spine
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_REQUIRE_REACH
	time_between_perform = 0.7 SECONDS
	var/give_up_distance = 10

/datum/ai_behavior/break_spine/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE
	set_movement_target(controller, target)

/datum/ai_behavior/break_spine/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	var/mob/living/batman = controller.blackboard[target_key]
	var/mob/living/big_guy = controller.pawn //he was molded by the darkness

	if(QDELETED(batman) || get_dist(batman, big_guy) >= give_up_distance)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

	if(batman.stat != CONSCIOUS)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED

	big_guy.start_pulling(batman)
	big_guy.face_atom(batman)

	batman.visible_message(span_warning("[batman] gets a slightly too tight hug from [big_guy]!"), span_userdanger("You feel your body break as [big_guy] embraces you!"))

	for(var/zone in GLOB.all_body_zones - BODY_ZONE_HEAD)
		batman.apply_damage(15, BRUTE, zone, wound_bonus = 35)

	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/break_spine/finish_action(datum/ai_controller/controller, succeeded, target_key)
	if(succeeded)
		var/mob/living/bane = controller.pawn
		if(QDELETED(bane)) // pawn can be null at this point
			return ..()
		bane.stop_pulling()
		controller.clear_blackboard_key(target_key)
	return ..()
