/// Faces the target each tick while it's within range. When the target is absent or out of range, resets to BB_STARTING_DIRECTION.
/// Captures BB_STARTING_DIRECTION once on setup from the pawn's current facing direction.
/datum/bt_node/ai_behavior/face_target_or_face_initial
	var/target_key = BB_CURRENT_TARGET

/datum/bt_node/ai_behavior/face_target_or_face_initial/setup(datum/ai_controller/controller)
	. = ..()
	var/mob/living/we = controller.pawn
	if(!istype(we))
		return FALSE
	var/atom/movable/target = controller.blackboard[target_key]
	if(!ismovable(target) || !isturf(target.loc))
		return FALSE
	controller.set_blackboard_key(BB_STARTING_DIRECTION, we.dir)
	return TRUE

/datum/bt_node/ai_behavior/face_target_or_face_initial/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/we = controller.pawn
	var/atom/movable/target = controller.blackboard[target_key]
	if(isnull(target) || get_dist(we, target) > 8)
		we.dir = controller.blackboard[BB_STARTING_DIRECTION]
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	we.face_atom(target)
	return AI_BEHAVIOR_DELAY
