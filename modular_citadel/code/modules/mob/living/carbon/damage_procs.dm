/mob/living/carbon/adjustStaminaLossBuffered(amount, updating_stamina = 1)
	if(status_flags & GODMODE)
		return 0
	var/directstamloss = (bufferedstam + amount) - stambuffer
	if(directstamloss > 0)
		adjustStaminaLoss(directstamloss)
	bufferedstam = CLAMP(bufferedstam + amount, 0, stambuffer)
	stambufferregentime = world.time + 2 SECONDS
	if(updating_stamina)
		update_health_hud()

/mob/living/carbon/adjustStaminaLoss(amount, updating_health = TRUE, forced = FALSE)
	if(!forced && (status_flags & GODMODE))
		return FALSE
	if(amount > 0)
		amount = CLAMP(amount, 0, 200 - getStaminaLoss())
		take_overall_damage(0, 0, amount, updating_health)
	else
		heal_overall_damage(0, 0, abs(amount), FALSE, FALSE, updating_health)
	return amount
