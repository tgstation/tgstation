/datum/ai_controller/base_hostile
	movement_delay = 0.4 SECONDS
	blackboard = list(BB_BANE_BATMAN = null)
	planning_subtrees = list()



/datum/ai_controller/base_hostile/TryPossessPawn(atom/new_pawn)
	if(isliving(new_pawn))
		movement_delay = living_pawn.cached_multiplicative_slowdown

	return ..() //Run parent at end


/datum/ai_controller/base_hostile/able_to_run()
	. = ..()

	if(isliving)
		var/mob/living/living_pawn = pawn

		if(IS_DEAD_OR_INCAP(living_pawn))
			return FALSE
