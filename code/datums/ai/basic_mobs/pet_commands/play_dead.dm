/// Pretend to be dead
/datum/ai_behavior/play_dead

/datum/ai_behavior/play_dead/setup(datum/ai_controller/controller)
	. = ..()
	var/mob/living/basic/basic_pawn = controller.pawn
	if(!istype(basic_pawn) || basic_pawn.stat) // Can't act dead if you're dead
		return
	basic_pawn.emote("deathgasp", intentional=FALSE)
	ADD_TRAIT(basic_pawn, TRAIT_FAKEDEATH, BASIC_MOB_DEATH_TRAIT)
	basic_pawn.look_dead()

/datum/ai_behavior/play_dead/perform(seconds_per_tick, datum/ai_controller/controller)
	. = ..()
	if(SPT_PROB(10, seconds_per_tick))
		finish_action(controller, TRUE)

/datum/ai_behavior/play_dead/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	var/mob/living/basic/basic_pawn = controller.pawn
	if(!istype(basic_pawn) || basic_pawn.stat) // imagine actually dying while playing dead. hell, imagine being the kid waiting for your pup to get back up :(
		return
	basic_pawn.visible_message(span_notice("[basic_pawn] miraculously springs back to life!"))
	REMOVE_TRAIT(basic_pawn, TRAIT_FAKEDEATH, BASIC_MOB_DEATH_TRAIT)
	basic_pawn.look_alive()
	controller.clear_blackboard_key(BB_ACTIVE_PET_COMMAND)
