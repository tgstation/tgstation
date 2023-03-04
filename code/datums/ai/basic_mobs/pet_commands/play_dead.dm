/// Pretend to be dead
/datum/ai_behavior/play_dead

/datum/ai_behavior/play_dead/setup(datum/ai_controller/controller)
	. = ..()
	var/mob/living/basic/basic_pawn = controller.pawn
	if(!istype(basic_pawn) || basic_pawn.stat) // Can't act dead if you're dead
		return
	basic_pawn.emote("deathgasp", intentional=FALSE)
	basic_pawn.look_dead()

/datum/ai_behavior/play_dead/perform(delta_time, datum/ai_controller/controller)
	. = ..()
	if(DT_PROB(10, delta_time))
		finish_action(controller, TRUE)

/datum/ai_behavior/play_dead/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	var/mob/living/basic/basic_pawn = controller.pawn
	if(!istype(basic_pawn) || basic_pawn.stat) // imagine actually dying while playing dead. hell, imagine being the kid waiting for your pup to get back up :(
		return
	basic_pawn.visible_message(span_notice("[basic_pawn] miraculously springs back to life!"))
	basic_pawn.look_alive()
	controller.blackboard[BB_ACTIVE_PET_COMMAND] = null
