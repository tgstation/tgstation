
/mob/living/simple_animal/received_stamina_damage(current_level, amount_actual, amount)
	return

/mob/living/simple_animal/on_damage_loss_changed(amount, updating_health, forced, damage_type)
	if(damage_type != BRUTE)
		simple_transfer_to_brute_loss(amount)
	if(!ckey && stat == CONSCIOUS && amount > 0)
		toggle_ai_on_damage()
	return ..()

/mob/living/simple_animal/proc/toggle_ai_on_damage()
	if(AIStatus == AI_IDLE)
		toggle_ai(AI_ON)
