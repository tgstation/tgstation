/**
 * # Pet Planning
 * Perform behaviour based on what pet commands you have received. This is delegated to the pet command datum.
 * When a command is set, we blackboard a key to our currently active command.
 * The blackboard also has a weak reference to every command datum available to us.
 * We use the key to figure out which datum to run, then ask it to figure out how to execute its action.
 */
/datum/ai_planning_subtree/pet_planning

/datum/ai_planning_subtree/pet_planning/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/datum/pet_command/command = controller.blackboard[BB_ACTIVE_PET_COMMAND]
	if (!command)
		return // Do something else
	return command.execute_action(controller)

// =============================================================================
// BT-native pet planning — DEPRECATED
// =============================================================================

/**
 * DEPRECATED. The pet command dispatch model no longer uses this leaf.
 * Pet command trees now use an override slot subtree (override_id = SUBPLAN_ID_PET_COMMAND).
 * execute_action() is called once from set_command_active() to install the correct override.
 *
 * This type is kept only for compile compat with any trees not yet updated to the override
 * slot model. It always returns BT_FAILURE so it is a no-op in a BT selector.
 */
/datum/bt_node/ai_behavior/pet_planning

/datum/bt_node/ai_behavior/pet_planning/perform(seconds_per_tick, datum/ai_controller/controller)
	return AI_BEHAVIOR_FAILED
