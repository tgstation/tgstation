
/mob/living/basic/slime/Life(seconds_per_tick = SSMOBS_DT, times_fired)
	..()

	if(bodytemperature <= (T0C - 40)) // stun temperature
		apply_status_effect(/datum/status_effect/freon, SLIME_COLD)
	else
		remove_status_effect(/datum/status_effect/freon, SLIME_COLD)

	var/bz_percentage =0

	var/turf/open/our_turf = loc

	if(our_turf?.air.gases[/datum/gas/bz])
		bz_percentage = our_turf.air.gases[/datum/gas/bz][MOLES] / our_turf.air.total_moles()
	var/stasis = (bz_percentage >= 0.05 && bodytemperature < (T0C + 100))

	if(stasis)
		to_chat(src, span_danger("Nerve gas in the air has put you in stasis!"))
		apply_status_effect(/datum/status_effect/grouped/stasis, STASIS_SLIME_BZ)
		powerlevel = 0
		ai_controller?.clear_blackboard_key(BB_RABID)
	else if(has_status_effect(/datum/status_effect/grouped/stasis))
		to_chat(src, span_notice("You wake up from the stasis."))
		remove_status_effect(/datum/status_effect/grouped/stasis, STASIS_SLIME_BZ)

	handle_nutrition(seconds_per_tick)

///Handles the consumption of nutrition, and growth
/mob/living/basic/slime/proc/handle_nutrition(seconds_per_tick = SSMOBS_DT)
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
