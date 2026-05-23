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
// BT-native pet planning
// =============================================================================

/**
 * BT-native pet planning node. Checks BB_ACTIVE_PET_COMMAND and delegates to
 * command.execute_action(). Returns BT_SUCCESS when the command signals it should block
 * further planning (SUBTREE_RETURN_FINISH_PLANNING), BT_FAILURE when there is no command
 * or the command allows planning to continue.
 *
 * NOTE: Individual pet command execute_action() implementations currently call queue_behavior()
 * which is a no-op. Those commands need to be ported to direct BT actions to function.
 */
/datum/bt_node/subtree/pet_planning
	behavior_nodes = null // tick() implemented directly; no internal tree

/datum/bt_node/subtree/pet_planning/tick(datum/ai_controller/controller, seconds_per_tick)
	var/datum/pet_command/command = controller.blackboard[BB_ACTIVE_PET_COMMAND]
	if(isnull(command))
		return BT_FAILURE
	var/result = command.execute_action(controller)
	return (result == SUBTREE_RETURN_FINISH_PLANNING) ? BT_SUCCESS : BT_FAILURE
