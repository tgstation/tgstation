
/mob/living/basic/slime/Life(seconds_per_tick = SSMOBS_DT, times_fired)
	..()

	if(!HAS_TRAIT(src, TRAIT_STASIS)) //No hunger in stasis
		handle_nutrition(seconds_per_tick)

	handle_slime_stasis(seconds_per_tick)

/mob/living/basic/slime/handle_environment(datum/gas_mixture/environment, seconds_per_tick, times_fired)
	..()
	if(bodytemperature <= (T0C - 40)) // stun temperature
		apply_status_effect(/datum/status_effect/freon, SLIME_COLD)
	else
		remove_status_effect(/datum/status_effect/freon, SLIME_COLD)

///Handles if a slime's environment would cause it to enter stasis. Ignores TRAIT_STASIS
/mob/living/basic/slime/proc/handle_slime_stasis(seconds_per_tick)
	var/datum/gas_mixture/environment = loc.return_air()

	var/bz_percentage = 0

	if(environment.gases[/datum/gas/bz])
		bz_percentage = environment.gases[/datum/gas/bz][MOLES] / environment.total_moles()

	if(bz_percentage >= 0.05 && bodytemperature < (T0C + 100)) //Check if we should be in stasis
		if(!has_status_effect(/datum/status_effect/grouped/stasis)) //Check if we don't have the status effect yet
			to_chat(src, span_danger("Nerve gas in the air has put you in stasis!"))
			apply_status_effect(/datum/status_effect/grouped/stasis, STASIS_SLIME_BZ)
			powerlevel = 0
			ai_controller?.clear_blackboard_key(BB_SLIME_RABID)
	else if(has_status_effect(/datum/status_effect/grouped/stasis)) //Check if we still have the status effect
		to_chat(src, span_notice("You wake up from the stasis."))
		remove_status_effect(/datum/status_effect/grouped/stasis, STASIS_SLIME_BZ)

///Handles the consumption of nutrition, and growth
/mob/living/basic/slime/proc/handle_nutrition(seconds_per_tick = SSMOBS_DT)
	if(hunger_disabled) //God as my witness, I will never go hungry again
		set_nutrition(700)
		return

	if(SPT_PROB(7.5, seconds_per_tick))
		adjust_nutrition((life_stage == SLIME_LIFE_STAGE_ADULT ? -1 : -0.5) * seconds_per_tick)

	if(nutrition < SLIME_STARVE_NUTRITION)
		ai_controller?.set_blackboard_key(BB_SLIME_HUNGER_LEVEL, SLIME_HUNGER_STARVING)

		if(SPT_PROB(0.5, seconds_per_tick) && LAZYLEN(ai_controller?.blackboard[BB_FRIENDS_LIST]))
			var/your_fault = pick(ai_controller?.blackboard[BB_FRIENDS_LIST])
			unfriend(your_fault)

	else if(nutrition < SLIME_HUNGER_NUTRITION || (nutrition < SLIME_GROW_NUTRITION && SPT_PROB(25, seconds_per_tick)) )
		ai_controller?.set_blackboard_key(BB_SLIME_HUNGER_LEVEL, SLIME_HUNGER_HUNGRY)

	else
		ai_controller?.set_blackboard_key(BB_SLIME_HUNGER_LEVEL, SLIME_HUNGER_NONE)

	if(nutrition == 0) //adjust nutrition ensures it can't go below 0
		if(SPT_PROB(50, seconds_per_tick))
			adjustBruteLoss(rand(0,5))
		return

	if (SLIME_GROW_NUTRITION <= nutrition)

		if(amount_grown < SLIME_EVOLUTION_THRESHOLD)
			adjust_nutrition(-10 * seconds_per_tick)
			amount_grown++

		if(powerlevel < SLIME_MAX_POWER && SPT_PROB(30-powerlevel*2, seconds_per_tick))
			powerlevel++

	else if (powerlevel < SLIME_MEDIUM_POWER && SLIME_HUNGER_NUTRITION <= nutrition && SPT_PROB(25-powerlevel*5, seconds_per_tick))
		powerlevel++

	update_mob_action_buttons()
