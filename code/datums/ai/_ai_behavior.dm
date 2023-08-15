///Abstract class for an action an AI can take, can range from movement to grabbing a nearby weapon.
/datum/ai_behavior
	///What distance you need to be from the target to perform the action
	var/required_distance = 1
	///Flags for extra behavior
	var/behavior_flags = NONE
	///Cooldown between actions performances, defaults to the value of CLICK_CD_MELEE because that seemed like a nice standard for the speed of AI behavior
	var/action_cooldown = CLICK_CD_MELEE

/// Called by the ai controller when first being added. Additional arguments depend on the behavior type.
/// Return FALSE to cancel
/datum/ai_behavior/proc/setup(datum/ai_controller/controller, ...)
	return TRUE

///Called by the AI controller when this action is performed
/datum/ai_behavior/proc/perform(seconds_per_tick, datum/ai_controller/controller, ...)
	controller.behavior_cooldowns[src] = world.time + action_cooldown
	return

///Called when the action is finished. This needs the same args as perform besides the default ones
/datum/ai_behavior/proc/finish_action(datum/ai_controller/controller, succeeded, ...)
	LAZYREMOVE(controller.current_behaviors, src)
	controller.behavior_args -= type
	if(behavior_flags & AI_BEHAVIOR_REQUIRE_MOVEMENT) //If this was a movement task, reset our movement target if necessary
		if(!(behavior_flags & AI_BEHAVIOR_KEEP_MOVE_TARGET_ON_FINISH))
			clear_movement_target(controller)
		if(!(behavior_flags & AI_BEHAVIOR_KEEP_MOVING_TOWARDS_TARGET_ON_FINISH))
			controller.ai_movement.stop_moving_towards(controller)

/// Helper proc to ensure consistency in setting the source of the movement target
/datum/ai_behavior/proc/set_movement_target(datum/ai_controller/controller, atom/target, datum/ai_movement/new_movement)
	controller.set_movement_target(type, target, new_movement)

/// Clear the controller's movement target only if it was us who last set it
/datum/ai_behavior/proc/clear_movement_target(datum/ai_controller/controller)
	if (controller.movement_target_source != type)
		return
	controller.set_movement_target(type, null)

/**
 * Wrapper for easily performing an "attack click" on an atom.
 * Intended for use in AI controllers.
 *
 * * clicking_what - The atom to click on.
 * * combat_mode - The combat mode to set the mob to while performing the click. If null, uses the mob's current combat mode.
 * * optional_params - Optional parameters to pass to the mob's ClickOn() proc.
 */
/mob/living/proc/ai_controller_click(atom/clicking_what, combat_mode, optional_params)
	if(isnull(combat_mode))
		return ClickOn(clicking_what, optional_params)

	var/pre_combat = combat_mode
	set_combat_mode(combat_mode)
	. = ClickOn(clicking_what, optional_params)
	set_combat_mode(pre_combat)
	return .
