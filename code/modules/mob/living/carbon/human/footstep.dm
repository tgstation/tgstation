/mob/living/carbon/human/get_footstep_modifiers()
	. = ..()
	if(!.)
		return
	if(m_intent == MOVE_INTENT_WALK)
		return list(0.5, -3)