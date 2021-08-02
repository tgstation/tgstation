/datum/ai_controller/basic_controller
	movement_delay = 0.4 SECONDS
	blackboard = list(BB_BANE_BATMAN = null)
	planning_subtrees = list()

/datum/ai_controller/basic_controller/TryPossessPawn(atom/new_pawn)
	if(isliving(new_pawn))
		var/mob/living/living_pawn = pawn

		movement_delay = living_pawn.cached_multiplicative_slowdown

	return ..() //Run parent at end


/datum/ai_controller/basic_controller/able_to_run()
	. = ..()

	if(isliving(pawn))
		var/mob/living/living_pawn = pawn

		if(IS_DEAD_OR_INCAP(living_pawn))
			return FALSE



///Should this be turned into datums? Probably. Need to think about this.
/datum/ai_controller/basic_controller/PerformIdleBehavior(delta_time)
	. = ..()


///Make this into an element
var/list/speak_emote = list()

/mob/living/simple_animal/say_mod(input, list/message_mods = list())
	if(length(speak_emote))
		verb_say = pick(speak_emote)
	return ..()
