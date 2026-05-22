///Abstract class for an action an AI can take, can range from movement to grabbing a nearby weapon.
/// Extends /datum/bt_node so that behaviors can be used as leaf nodes directly in a behavior tree
/// without changing their type path. tick() is the BT leaf implementation; perform() is the execution actor.
/datum/ai_behavior
	parent_type = /datum/bt_node
	///What distance you need to be from the target to perform the action
	var/required_distance = 1
	///Flags for extra behavior
	var/behavior_flags = NONE
	///Cooldown between actions performances, defaults to the value of CLICK_CD_MELEE because that seemed like a nice standard for the speed of AI behavior
	///Do not read directly or mutate, instead use get_cooldown()
	var/action_cooldown = CLICK_CD_MELEE
	/// Static args to pass to queue_behavior() when this behavior is used as a BT leaf node.
	/// Set this list on the subtype to define which blackboard keys and values to forward.
	/// Unpacked with arglist() — do NOT include the behavior type itself, only the extra args.
	var/list/default_behavior_args = null

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
	controller.dequeue_behavior(src)
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

/**
 * BT leaf node implementation. Called during SelectBehaviors().
 * If this behavior is already running on the controller, returns BT_RUNNING immediately.
 * Otherwise, queues it via queue_behavior() using default_behavior_args, then returns BT_RUNNING.
 * Always returns BT_RUNNING — the behavior tree never considers an action "done" from the planning side.
 */
/datum/ai_behavior/tick(datum/ai_controller/controller, seconds_per_tick)
	if(!should_tick(controller))
		return BT_RUNNING
	var/datum/ai_behavior/self = GET_AI_BEHAVIOR(type)
	if(self in controller.current_behaviors)
		// Behavior is already running — keep it alive in planned_behaviors so SelectBehaviors
		// doesn't treat it as "forgotten" and call finish_action on it.
		controller.planned_behaviors[self] = TRUE
		return BT_RUNNING
	if(LAZYLEN(default_behavior_args))
		call(controller, /datum/ai_controller/proc/queue_behavior)(arglist(list(type) + default_behavior_args))
	else
		controller.queue_behavior(type)
	if(tick_rate)
		tick_cooldowns[controller] = world.time
		tick_results[controller] = BT_RUNNING
	return BT_RUNNING
