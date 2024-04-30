/mob/living/basic/cortical_borer/proc/get_possible_evolutions()
	var/list/possible_evolutions = list()
	for(var/evolution_index in past_evolutions)
		var/datum/borer_evolution/evolution = past_evolutions[evolution_index]
		possible_evolutions |= evolution.unlocked_evolutions
	return possible_evolutions

/mob/living/basic/cortical_borer/proc/do_evolution(datum/borer_evolution/evolution_type)
	if(!ispath(evolution_type))
		stack_trace("[type] do_evolution was given an invalid path! (Got: [evolution_type])")
		return FALSE
	if(past_evolutions[evolution_type])
		return FALSE
	var/datum/borer_evolution/initialized_evolution = new evolution_type()
	past_evolutions[evolution_type] = initialized_evolution
	initialized_evolution.on_evolve(src)
	return TRUE
