/*

Possible objectives:
	1. Steal the memories of # humans. (# = round population / 4)

*/

/datum/objective/revenant
	explanation_text = "Be an revenant."

/datum/objective/revenant/check_completion()
	return 1

/datum/objective/revenant/lobotomize
	explanation_text = "Steal the memories of several humans."

/datum/objective/revenant/lobotomize/New()
	target_amount = round(ticker.mode.num_players() / 4)
	explanation_text = "Steal the memories of [target_amount] humans."
	..()

/datum/objective/revenant/lobotomize/check_completion()
	if(!isrevenant(owner.current))
		return 0
	var/mob/living/simple_animal/revenant/U = owner.current
	if(U.lobotomized.len >= target_amount)
		return 1
	return 0
