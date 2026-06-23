/mob/living/simple_animal/adjust_brute_loss(amount, updating_health = TRUE, forced = FALSE, required_bodytype)
	. = ..()
	toggle_ai_on_health_adjusted()

/mob/living/simple_animal/adjust_fire_loss(amount, updating_health = TRUE, forced = FALSE, required_bodytype)
	. = ..()
	toggle_ai_on_health_adjusted()

/mob/living/simple_animal/adjust_oxy_loss(amount, updating_health = TRUE, forced = FALSE, required_biotype, required_respiration_type)
	. = ..()
	toggle_ai_on_health_adjusted()

/mob/living/simple_animal/adjust_tox_loss(amount, updating_health = TRUE, forced = FALSE, required_biotype)
	. = ..()
	toggle_ai_on_health_adjusted()

/mob/living/simple_animal/received_stamina_damage(current_level, amount_actual, amount)
	return

///For the samke of simplicity, simple animal mobs only suffer one standard damage type (someday simple animals will be removed...)
/mob/living/simple_animal/updatehealth()
	var/damage_sources_converted_to_brute = get_oxy_loss() + get_tox_loss() + get_fire_loss()
	fireloss = 0
	toxloss = 0
	oxyloss = 0
	bruteloss = round(clamp(bruteloss + damage_sources_converted_to_brute, 0, maxHealth * 2), DAMAGE_PRECISION)
	return ..()

/mob/living/simple_animal/proc/toggle_ai_on_health_adjusted(health_change)
	if(!updating_health || ckey || stat)
		return FALSE
	if(AIStatus == AI_IDLE)
		toggle_ai(AI_ON)
	return TRUE
