/// Passes only when no living, conscious human can see or hear the pawn within range.
/// Used by cowardly mobs that only act when nobody is looking.
/datum/bt_node/decorator/no_humans_watching
	/// How far to look for witnesses.
	var/range = 7

/datum/bt_node/decorator/no_humans_watching/check_condition(datum/ai_controller/controller)
	for(var/mob/living/carbon/human/watcher in hearers(range, controller.pawn))
		if(watcher.stat != DEAD)
			return FALSE
	return TRUE
