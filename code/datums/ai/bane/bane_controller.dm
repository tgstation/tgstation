/*
You yourself fought the decadence of Gotham for years with all your strength, all your resources, all your moral authority.
And the only victory you achieved was a lie. Now you understand Gotham is beyond saving, and must be allowed to die.
*/
/datum/ai_controller/bane
	movement_delay = 0.4 SECONDS
	blackboard = list(BB_BANE_BATMAN = null)
	planning_subtrees = list(/datum/ai_planning_subtree/bane_hunting)

/datum/ai_controller/bane/TryPossessPawn(atom/new_pawn)
	if(!isliving(new_pawn))
		return AI_CONTROLLER_INCOMPATIBLE
	return ..() //Run parent at end

/datum/ai_controller/bane/on_stat_changed(mob/living/source, new_stat)
	. = ..()
	update_able_to_run()

/datum/ai_controller/bane/setup_able_to_run()
	. = ..()
	RegisterSignal(pawn, COMSIG_MOB_INCAPACITATE_CHANGED, PROC_REF(update_able_to_run))

/datum/ai_controller/bane/clear_able_to_run()
	UnregisterSignal(pawn, list(COMSIG_MOB_INCAPACITATE_CHANGED, COMSIG_MOB_STATCHANGE))
	return ..()

/datum/ai_controller/bane/get_able_to_run()
	var/mob/living/living_pawn = pawn
	if(IS_DEAD_OR_INCAP(living_pawn))
		return AI_UNABLE_TO_RUN
	return ..()
