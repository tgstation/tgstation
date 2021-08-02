///This behavior handles performing a specific emote
/datum/ai_behavior/perform_emote/basic_mob
	emote_to_perform_key = BB_BASIC_MOB_NEXT_EMOTE

/datum/ai_behavior/perform_emote/perform(delta_time, datum/ai_controller/controller)
	var/mob/living/living_pawn = controller.pawn
	if(!istype(living_pawn))
		return
	living_pawn.manual_emote(controller.blackboard[emote_to_perform_key])
