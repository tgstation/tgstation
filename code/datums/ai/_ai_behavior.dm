///Abstract class for an action an AI can take, can range from movement to grabbing a nearby weapon.
/datum/ai_behavior
	///What distance you need to be from the target to perform the action
	var/required_distance = 1
	///Flags for extra behavior
	var/behavior_flags = NONE
	///Cooldown between actions performances, defaults to the value of CLICK_CD_MELEE because that seemed like a nice standard for the speed of AI behavior
	///Do not read directly or mutate, instead use get_cooldown()
	var/action_cooldown = CLICK_CD_MELEE

/// Returns the delay to use for this behavior in the moment
/// Override to return a conditional delay
/datum/ai_behavior/proc/get_cooldown(datum/ai_controller/cooldown_for)
	return action_cooldown

/// Called by the ai controller when first being added. Additional arguments depend on the behavior type.
/// Return FALSE to cancel
/datum/ai_behavior/proc/setup(datum/ai_controller/controller, ...)
	return TRUE

///Called by the AI controller when this action is performed
///Returns a set of flags defined in [code/__DEFINES/ai/ai.dm]
/datum/ai_behavior/proc/perform(seconds_per_tick, datum/ai_controller/controller, ...)
	return

///Called when the action is finished. This needs the same args as perform besides the default ones
/datum/ai_behavior/proc/finish_action(datum/ai_controller/controller, succeeded, ...)
	LAZYREMOVE(controller.current_behaviors, src)
	controller.behavior_args -= type
	if(!(behavior_flags & AI_BEHAVIOR_REQUIRE_MOVEMENT)) //If this was a movement task, reset our movement target if necessary
		return
	if(behavior_flags & AI_BEHAVIOR_KEEP_MOVE_TARGET_ON_FINISH)
		return
	clear_movement_target(controller)
	controller.ai_movement.stop_moving_towards(controller)

/// Helper proc to ensure consistency in setting the source of the movement target
/datum/ai_behavior/proc/set_movement_target(datum/ai_controller/controller, atom/target, datum/ai_movement/new_movement)
	controller.set_movement_target(type, target, new_movement)

/// Clear the controller's movement target only if it was us who last set it
/datum/ai_behavior/proc/clear_movement_target(datum/ai_controller/controller)
	if (controller.movement_target_source != type)
		return
	controller.set_movement_target(type, null)
