/mob/living/simple_animal/on_damage_loss(amount, updating_health, forced, damage_type, difference)
	var/transfered_loss
	if(damage_type != BRUTE && damage_type != STAMINA)
		transfered_loss = simple_transfer_to_brute_loss(amount)
	if(!ckey && stat == CONSCIOUS && amount > 0)
		toggle_ai_on_damage()
	. = ..()
	return transfered_loss || .

/mob/living/simple_animal/proc/toggle_ai_on_damage()
	if(AIStatus == AI_IDLE)
		toggle_ai(AI_ON)
