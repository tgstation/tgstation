// DEPRECATED — port to /datum/bt_node/subtree. SelectBehaviors() and operational_datums are kept
// so that subtypes compile without modification until they are individually ported.
/datum/ai_planning_subtree
	/// A list of typepaths of "operational datums" (elements/components) we absolutely NEED to run.
	var/list/operational_datums = null

/// DEPRECATED — override SelectBehaviors() on subtypes is kept for compile compatibility only.
/datum/ai_planning_subtree/proc/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	return
