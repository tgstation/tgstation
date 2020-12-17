///Abstract class for an action an AI can take, can range from movement to grabbing a nearby weapon.
/datum/ai_behavior
	///What distance you need to be from the target to perform the action
	var/required_distance = 1
	///Flags for extra behavior
	var/behavior_flags = NONE
	///Cooldown between actions performances
	var/action_cooldown = 0

///Called by the AI controller when this action is performed
/datum/ai_behavior/proc/perform(delta_time, datum/ai_controller/controller)
	controller.behavior_cooldowns[src] = world.time + action_cooldown
	return

///Called when the action is finished.
/datum/ai_behavior/proc/finish_action(datum/ai_controller/controller, succeeded)
	controller.current_behaviors.Remove(src)
	if(behavior_flags & AI_BEHAVIOR_REQUIRE_MOVEMENT) //If this was a movement task, reset our movement target.
		controller.current_movement_target = null
	return
