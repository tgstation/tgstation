/mob/living
	var/step_track = 0

// returns volume factor and extra range addition value
/mob/living/proc/get_footstep_factors()
	if(lying || !canmove || resting || buckled || throwing)
		return null
	if(prob(80))
		step_track++
	if(prob(10))
		step_track++
	if(step_track > 5)
		step_track = 0
	if(step_track % 2)
		return null
	if(!has_gravity(src) && step_track != 0) // don't need to step as often when you hop around
		return null
	return list(0.5, -1)
