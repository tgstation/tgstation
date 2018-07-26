/mob/living/carbon/human/get_footstep_factors()
	if(!..())
		return null
	if(m_intent == MOVE_INTENT_WALK)
		return list(0.5, -3)