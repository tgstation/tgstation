/mob/living/simple_animal/adjust_brute_loss(amount, updating_health = TRUE, forced = FALSE, required_bodytype)
	amount = on_adjust_damage_loss(amount, updating_health, forced)
	. = ..()

/mob/living/simple_animal/adjust_fire_loss(amount, updating_health = TRUE, forced = FALSE, required_bodytype)
	amount = on_adjust_damage_loss(amount, updating_health, forced)
	var/old_update = updating_health
	updating_health = FALSE
	. = ..()
	convert_to_brute_loss(BURN, old_update)

/mob/living/simple_animal/adjust_oxy_loss(amount, updating_health = TRUE, forced = FALSE, required_biotype, required_respiration_type)
	amount = on_adjust_damage_loss(amount, updating_health, forced)
	var/old_update = updating_health
	updating_health = FALSE
	. = ..()
	convert_to_brute_loss(OXY, old_update)

/mob/living/simple_animal/adjust_tox_loss(amount, updating_health = TRUE, forced = FALSE, required_biotype)
	amount = on_adjust_damage_loss(amount, updating_health, forced)
	var/old_update = updating_health
	updating_health = FALSE
	. = ..()
	convert_to_brute_loss(TOX, old_update)

/mob/living/simple_animal/received_stamina_damage(current_level, amount_actual, amount)
	return

/mob/living/simple_animal/proc/on_adjust_damage_loss(amount, updating_health, forced)
	SHOULD_CALL_PARENT(TRUE)
	if(updating_health && !ckey && stat == CONSCIOUS && amount > 0)
		toggle_ai_on_damage()
	return amount

/mob/living/simple_animal/proc/toggle_ai_on_damage()
	if(AIStatus == AI_IDLE)
		toggle_ai(AI_ON)
