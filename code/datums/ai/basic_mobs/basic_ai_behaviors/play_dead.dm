/// Plays dead until a per-tick probability check (default 10%) triggers revival.
/datum/bt_node/ai_behavior/play_dead
	var/probability = 10

/datum/bt_node/ai_behavior/play_dead/setup(datum/ai_controller/controller)
	var/mob/living/basic/pawn = controller.pawn
	if(!istype(pawn) || pawn.stat)
		return FALSE
	pawn.emote("deathgasp", intentional = FALSE)
	ADD_TRAIT(pawn, TRAIT_FAKEDEATH, BASIC_MOB_DEATH_TRAIT)
	pawn.look_dead()

/datum/bt_node/ai_behavior/play_dead/perform(seconds_per_tick, datum/ai_controller/controller)
	if(SPT_PROB(probability, seconds_per_tick))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	return AI_BEHAVIOR_DELAY

/datum/bt_node/ai_behavior/play_dead/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	var/mob/living/basic/pawn = controller.pawn
	if(QDELETED(pawn) || pawn.stat)
		return
	pawn.visible_message(span_notice("[pawn] miraculously springs back to life!"))
	REMOVE_TRAIT(pawn, TRAIT_FAKEDEATH, BASIC_MOB_DEATH_TRAIT)
	pawn.look_alive()
