/// Makes a mob simply stop and stare at a movable... yea...
/datum/ai_behavior/stop_and_stare

/datum/ai_behavior/stop_and_stare/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/datum/weakref/weak_target = controller.blackboard[target_key]
	var/atom/movable/target = weak_target?.resolve()
	return ismovable(target) && isturf(target.loc) && ismob(controller.pawn)

/datum/ai_behavior/stop_and_stare/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	var/datum/weakref/weak_target = controller.blackboard[target_key]
	var/atom/movable/target = weak_target?.resolve()
	if(!ismovable(target) || !isturf(target.loc)) // just to make sure that nothing funky happened between setup and perform
		return

	controller.pawn.face_atom(target)
	balloon_alert_to_viewers(controller.pawn, "stops and stares...")

