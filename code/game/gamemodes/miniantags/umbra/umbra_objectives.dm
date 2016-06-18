/*

Possible objectives:
	1. Steal the memories of # humans. (# = 10-20)

*/

/datum/objective/umbra
	explanation_text = "Be an umbra."

/datum/objective/umbra/check_completion()
	return 1

/datum/objective/umbra/lobotomize
	explanation_text = "Steal the memories of several humans."

/datum/objective/umbra/lobotomize/New()
	target_amount = rand(10, 20)
	explanation_text = "Steal the memories of [target_amount] humans."
	..()

/datum/objective/umbra/lobotomize/check_completion()
	if(!isumbra(owner.current))
		return 0
	var/mob/living/simple_animal/umbra/U = owner.current
	if(U.lobotomized.len >= target_amount)
		return 1
	return 0
