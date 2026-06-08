/**
 * Finds a conscious human within a configurable distance of an anchor atom.
 * Useful for bards, entertainers, or any AI that wants a nearby audience.
 */
/datum/bt_node/ai_behavior/find_and_set/conscious_person_near_anchor
	/// Blackboard key holding the anchor atom (e.g. home village landmark).
	var/anchor_key
	/// Blackboard key whose integer value caps how far from the anchor the human can be.
	var/max_distance_key

/datum/bt_node/ai_behavior/find_and_set/conscious_person_near_anchor/search_tactic(datum/ai_controller/controller, locate_path, search_range = SEARCH_TACTIC_DEFAULT_RANGE)
	var/atom/anchor = controller.blackboard[anchor_key]
	var/max_dist = controller.blackboard[max_distance_key] || search_range
	for(var/mob/living/carbon/human/target in oview(max_dist, controller.pawn))
		if(target.stat > UNCONSCIOUS || !target.mind)
			continue
		if(!isnull(anchor) && get_dist(target, anchor) > max_dist)
			continue
		return target
