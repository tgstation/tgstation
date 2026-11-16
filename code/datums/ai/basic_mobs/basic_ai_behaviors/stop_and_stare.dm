/// Faces a nearby scary atom and holds still for a while.
/datum/bt_node/ai_behavior/stop_and_stare
	/// Blackboard key holding the atom we're staring at.
	var/target_key = BB_STATIONARY_CAUSE
	/// Blackboard key holding how long (in deciseconds) to stay frozen for.
	var/stare_duration_key = BB_STATIONARY_SECONDS

/datum/bt_node/ai_behavior/stop_and_stare/setup(datum/ai_controller/controller)
	var/atom/movable/target = controller.blackboard[target_key]
	return ismovable(target) && isturf(target.loc) && ismob(controller.pawn)

/datum/bt_node/ai_behavior/stop_and_stare/get_cooldown(datum/ai_controller/cooldown_for)
	return cooldown_for.blackboard[stare_duration_key] || ..()

/datum/bt_node/ai_behavior/stop_and_stare/perform(seconds_per_tick, datum/ai_controller/controller)
	var/atom/movable/target = controller.blackboard[target_key]
	if(!ismovable(target) || !isturf(target.loc))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/mob/pawn_mob = controller.pawn
	pawn_mob.face_atom(target)
	pawn_mob.balloon_alert_to_viewers("stops and stares...")
	// Returning a long cooldown keeps this leaf RUNNING (and thus the mob standing still) for the stare.
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/bt_node/ai_behavior/stop_and_stare/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	// Forget the cause so we can be spooked fresh next time it wanders into view.
	controller.clear_blackboard_key(target_key)
