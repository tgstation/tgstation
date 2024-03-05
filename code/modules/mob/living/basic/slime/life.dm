
/mob/living/basic/slime/Life(seconds_per_tick = SSMOBS_DT, times_fired)
	..()

	if(hunger_disabled) //God as my witness, I will never go hungry again
		set_nutrition(700)
		return

	if(SPT_PROB(7.5, seconds_per_tick))
		adjust_nutrition((life_stage == SLIME_LIFE_STAGE_ADULT ? -1 : -0.5) * seconds_per_tick)

	if(nutrition == 0) //adjust nutrition ensures it can't go below 0
		if(SPT_PROB(50, seconds_per_tick))
			adjustBruteLoss(rand(0,5))
		return

	if (grow_nutrition <= nutrition)

		if(amount_grown < SLIME_EVOLUTION_THRESHOLD)
			adjust_nutrition(-10 * seconds_per_tick)
			amount_grown++

		if(powerlevel < SLIME_MAX_POWER && SPT_PROB(30-powerlevel*2, seconds_per_tick))
			powerlevel++

	else if (powerlevel < SLIME_MEDIUM_POWER && hunger_nutrition <= nutrition && SPT_PROB(25-powerlevel*5, seconds_per_tick))
		powerlevel++


	update_mob_action_buttons()
