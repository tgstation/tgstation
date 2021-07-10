/*
You yourself fought the decadence of Gotham for years with all your strength, all your resources, all your moral authority.
And the only victory you achieved was a lie. Now you understand Gotham is beyond saving, and must be allowed to die.
*/
/datum/ai_controller/bane
	movement_delay = 0.4 SECONDS
	blackboard = list(BB_BANE_BATMAN = null)

/datum/ai_controller/bane/TryPossessPawn(atom/new_pawn)
	if(!isliving(new_pawn))
		return AI_CONTROLLER_INCOMPATIBLE
	return ..() //Run parent at end

/datum/ai_controller/bane/able_to_run()
	var/mob/living/living_pawn = pawn
	if(IS_DEAD_OR_INCAP(living_pawn))
		return FALSE
	return ..()

/datum/ai_controller/bane/SelectBehaviors(delta_time)
	current_behaviors = list()
	var/mob/living/batman = blackboard[BB_BANE_BATMAN]
	if(!batman)
		for(var/mob/living/possibly_the_dark_knight in oview(7, pawn))
			if(IS_DEAD_OR_INCAP(possibly_the_dark_knight)) //I HAVE BROKEN THE BAT
				continue
			blackboard[BB_BANE_BATMAN] = possibly_the_dark_knight
			batman = possibly_the_dark_knight
			break
	if(batman)
		current_movement_target = batman
		current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/break_spine/bane)


