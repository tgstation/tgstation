///The bat is broken!
/datum/ai_planning_subtree/bane_hunting/SelectBehaviors(datum/ai_controller/controller, delta_time)
	var/mob/living/batman = controller.blackboard[BB_BANE_BATMAN]
	if(!batman)
		for(var/mob/living/possibly_the_dark_knight in oview(7, controller.pawn))
			if(IS_DEAD_OR_INCAP(possibly_the_dark_knight)) //I HAVE BROKEN THE BAT
				continue
			controller.blackboard[BB_BANE_BATMAN] = possibly_the_dark_knight
			batman = possibly_the_dark_knight
			break
	if(batman)
		controller.queue_behavior(/datum/ai_behavior/break_spine/bane, BB_BANE_BATMAN)
		return SUBTREE_RETURN_FINISH_PLANNING
