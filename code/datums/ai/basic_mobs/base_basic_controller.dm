/datum/ai_controller/basic_controller
	movement_delay = 0.4 SECONDS

/datum/ai_controller/basic_controller/TryPossessPawn(atom/new_pawn)
	if(isliving(new_pawn))
		var/mob/living/living_pawn = new_pawn

		movement_delay = living_pawn.cached_multiplicative_slowdown

	return ..() //Run parent at end


/datum/ai_controller/basic_controller/able_to_run()
	. = ..()

	if(isliving(pawn))
		var/mob/living/living_pawn = pawn

		if(IS_DEAD_OR_INCAP(living_pawn))
			return FALSE
	return TRUE

///Should this be turned into datums? Probably. Need to think about this.
/datum/ai_controller/basic_controller/PerformIdleBehavior(delta_time)
	. = ..()














