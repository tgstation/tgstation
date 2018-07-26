/mob/living
	var/step_count = 0

// returns volume factor and range factor
/mob/living/proc/get_footstep_factors()
	if(lying || !canmove || resting || buckled || throwing)
		return null
	step_count++
	if(!has_gravity(src) && step_count % 3) // don't need to step as often when you hop around
		return null
	if(m_intent == MOVE_INTENT_WALK)
		return list(0.25, 0.5, 0)
	return list(1, 1, 1)
