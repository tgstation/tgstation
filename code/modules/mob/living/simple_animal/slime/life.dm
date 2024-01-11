

/mob/living/simple_animal/slime/Life(seconds_per_tick = SSMOBS_DT, times_fired)
	if(HAS_TRAIT(src, TRAIT_NO_TRANSFORM))
		return
	. = ..()
	if(!.)
		return

	// We get some passive bruteloss healing if we're not dead
	if(stat != DEAD && SPT_PROB(16, seconds_per_tick))
		adjustBruteLoss(-0.5 * seconds_per_tick)
	if(ismob(buckled))
		handle_feeding(seconds_per_tick, times_fired)
	if(stat != CONSCIOUS) // Slimes in stasis don't lose nutrition, don't change mood and don't respond to speech
		return
	handle_nutrition(seconds_per_tick, times_fired)
	if(QDELETED(src)) // Stop if the slime split during handle_nutrition()
		return
	handle_targets(seconds_per_tick, times_fired)
	if(ckey)
		return
	handle_mood(seconds_per_tick, times_fired)
	handle_speech(seconds_per_tick, times_fired)


// Unlike most of the simple animals, slimes support UNCONSCIOUS. This is an ugly hack.
/mob/living/simple_animal/slime/update_stat()
	switch(stat)
		if(UNCONSCIOUS, HARD_CRIT)
			if(health > 0)
				return
	return ..()

/mob/living/simple_animal/slime/handle_environment(datum/gas_mixture/environment, seconds_per_tick, times_fired)
	var/loc_temp = get_temperature(environment)
	var/divisor = 10 /// The divisor controls how fast body temperature changes, lower causes faster changes

	var/temp_delta = loc_temp - bodytemperature
	if(abs(temp_delta) > 50) // If the difference is great, reduce the divisor for faster stabilization
		divisor = 5

	if(temp_delta < 0) // It is cold here
		if(!on_fire) // Do not reduce body temp when on fire
			adjust_bodytemperature(clamp((temp_delta / divisor) * seconds_per_tick, temp_delta, 0))
	else // This is a hot place
		adjust_bodytemperature(clamp((temp_delta / divisor) * seconds_per_tick, 0, temp_delta))

	if(bodytemperature < (T0C + 5)) // start calculating temperature damage etc
		if(bodytemperature <= (T0C - 40)) // stun temperature
			ADD_TRAIT(src, TRAIT_IMMOBILIZED, SLIME_COLD)
		else
			REMOVE_TRAIT(src, TRAIT_IMMOBILIZED, SLIME_COLD)

		if(bodytemperature <= (T0C - 50)) // hurt temperature
			if(bodytemperature <= 50) // sqrting negative numbers is bad
				adjustBruteLoss(100 * seconds_per_tick)
			else
				adjustBruteLoss(round(sqrt(bodytemperature)) * seconds_per_tick)
	else
		REMOVE_TRAIT(src, TRAIT_IMMOBILIZED, SLIME_COLD)

	if(stat != DEAD)
		var/bz_percentage =0
		if(environment.gases[/datum/gas/bz])
			bz_percentage = environment.gases[/datum/gas/bz][MOLES] / environment.total_moles()
		var/stasis = (bz_percentage >= 0.05 && bodytemperature < (T0C + 100)) || force_stasis

		switch(stat)
			if(CONSCIOUS)
				if(stasis)
					to_chat(src, span_danger("Nerve gas in the air has put you in stasis!"))
					set_stat(UNCONSCIOUS)
					powerlevel = 0
					rabid = FALSE
					regenerate_icons()
			if(UNCONSCIOUS, HARD_CRIT)
				if(!stasis)
					to_chat(src, span_notice("You wake up from the stasis."))
					set_stat(CONSCIOUS)
					regenerate_icons()

	updatehealth()

///Handles the slime draining the target it is attached to
/mob/living/simple_animal/slime/proc/handle_feeding(seconds_per_tick, times_fired)
	var/mob/living/prey = buckled

	if(stat)
		stop_feeding(silent = TRUE)

	if(prey.stat == DEAD) // our victim died
		if(!client)
			if(!rabid && !attacked_stacks)
				var/mob/last_to_hurt = prey.LAssailant?.resolve()
				if(last_to_hurt && last_to_hurt != prey)
					if(SPT_PROB(30, seconds_per_tick))
						add_friendship(last_to_hurt, 1)
		else
			to_chat(src, "<i>This subject does not have a strong enough life energy anymore...</i>")

		if(prey.client && ishuman(prey))
			if(SPT_PROB(61, seconds_per_tick))
				rabid = TRUE //we go rabid after finishing to feed on a human with a client.

		stop_feeding()
		return

	if(iscarbon(prey))
		prey.adjustBruteLoss(rand(2, 4) * 0.5 * seconds_per_tick)
		prey.adjustToxLoss(rand(1, 2) * 0.5 * seconds_per_tick)

		if(SPT_PROB(5, seconds_per_tick) && prey.client)
			to_chat(prey, "<span class='userdanger'>[pick("You can feel your body becoming weak!", \
			"You feel like you're about to die!", \
			"You feel every part of your body screaming in agony!", \
			"A low, rolling pain passes through your body!", \
			"Your body feels as if it's falling apart!", \
			"You feel extremely weak!", \
			"A sharp, deep pain bathes every inch of your body!")]</span>")

	else if(isanimal_or_basicmob(prey))
		var/mob/living/animal_victim = prey

		var/totaldamage = 0 //total damage done to this unfortunate animal
		var/need_mob_update
		need_mob_update = totaldamage += animal_victim.adjustBruteLoss(rand(2, 4) * 0.5 * seconds_per_tick, updating_health = FALSE)
		need_mob_update += totaldamage += animal_victim.adjustToxLoss(rand(1, 2) * 0.5 * seconds_per_tick, updating_health = FALSE)
		if(need_mob_update)
			animal_victim.updatehealth()

		if(totaldamage >= 0) // AdjustBruteLoss returns a negative value on succesful damage adjustment
			stop_feeding(FALSE, FALSE)
			return

	else
		stop_feeding(FALSE, FALSE)
		return

	add_nutrition((rand(7, 15) * 0.5 * seconds_per_tick * CONFIG_GET(number/damage_multiplier)))

	//Heal yourself.
	adjustBruteLoss(-1.5 * seconds_per_tick)

///Handles the slime's nutirion level
/mob/living/simple_animal/slime/proc/handle_nutrition(seconds_per_tick, times_fired)

	if(docile) //God as my witness, I will never go hungry again
		set_nutrition(700) //fuck you for using the base nutrition var
		return

	if(SPT_PROB(7.5, seconds_per_tick))
		adjust_nutrition((life_stage == SLIME_LIFE_STAGE_ADULT ? -1 : -0.5) * seconds_per_tick)

	if(nutrition <= 0)
		set_nutrition(0)
		if(SPT_PROB(50, seconds_per_tick))
			adjustBruteLoss(rand(0,5))

	else if (nutrition >= grow_nutrition && amount_grown < SLIME_EVOLUTION_THRESHOLD)
		adjust_nutrition(-10 * seconds_per_tick)
		amount_grown++
		update_mob_action_buttons()

	if(amount_grown >= SLIME_EVOLUTION_THRESHOLD && !buckled && !Target && !ckey)
		if(life_stage == SLIME_LIFE_STAGE_ADULT && loc.AllowDrop())
			Reproduce()
		else
			Evolve()

///Adds nutrition to the slime's nutrition level. Has a chance to increase its electric levels.
/mob/living/simple_animal/slime/proc/add_nutrition(nutrition_to_add = 0)
	set_nutrition(min((nutrition + nutrition_to_add), max_nutrition))
	if(nutrition >= grow_nutrition)
		if(powerlevel<SLIME_MAX_POWER)
			if(prob(30-powerlevel*2))
				powerlevel++
	else if(nutrition >= hunger_nutrition + 100) //can't get power levels unless you're a bit above hunger level.
		if(powerlevel<SLIME_MEDIUM_POWER)
			if(prob(25-powerlevel*5))
				powerlevel++
