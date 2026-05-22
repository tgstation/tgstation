///A subtree is attached to a controller and is occasionally called by /ai_controller/SelectBehaviors(), this mainly exists to act as a way to subtype and modify SelectBehaviors() without needing to subtype the ai controller itself
/// Extends /datum/bt_node via parent_type so that existing subtrees participate in the BT system
/// without requiring any migration. tick() wraps SelectBehaviors() for backward compatibility.
/datum/ai_planning_subtree
	parent_type = /datum/bt_node
	/// A list of typepaths of "operational datums" (elements/components) we absolutely NEED to run. Checked in unit tests, as well as be a nice reminder to developers that such a thing might be needed.
	/// Note that in the Attach/Inititalize/New (or any future equivalent for these procs), you will need to add the trait TRAIT_SUBTREE_REQUIRED_OPERATIONAL_DATUM to the mob in question
	/// in order for unit tests to succeed. This will break obviously enough if you don't do this and declare the required datum here however.
	var/list/operational_datums = null

///Determines what behaviors should the controller try processing; if this returns SUBTREE_RETURN_FINISH_PLANNING then the controller won't go through the other subtrees should multiple exist in controller.behavior_nodes
/datum/ai_planning_subtree/proc/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	return

/**
 * BT node shim. Wraps SelectBehaviors() for the behavior tree system.
 * SUBTREE_RETURN_FINISH_PLANNING → BT_RUNNING (stop evaluating further siblings).
 * null/anything else             → BT_FAILURE (continue to next sibling).
 */
/datum/ai_planning_subtree/tick(datum/ai_controller/controller, seconds_per_tick)
	if(!should_tick(controller))
		return tick_results[controller] || BT_FAILURE
	var/result = (SelectBehaviors(controller, seconds_per_tick) == SUBTREE_RETURN_FINISH_PLANNING) ? BT_RUNNING : BT_FAILURE
	if(tick_rate)
		tick_cooldowns[controller] = world.time
		tick_results[controller] = result
	return result
