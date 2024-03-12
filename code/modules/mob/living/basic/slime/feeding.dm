
//Feeding

///Can the slime leech life energy from the target?
/mob/living/basic/slime/proc/can_feed_on(mob/living/meal, silent = FALSE)

	if(!isliving(meal)) //sanity check
		return FALSE

	if(stat)
		if(silent)
			return FALSE
		balloon_alert(src, span_warning("unconscious!"))
		return FALSE

	if(hunger_disabled)
		if(silent)
			return FALSE
		balloon_alert(src, span_notice("not hungry!"))
		return FALSE

	if(!Adjacent(meal))
		return FALSE

	if(meal.stat == DEAD)
		if(silent)
			return FALSE
		balloon_alert(src, span_warning("no life energy!"))
		return FALSE

	if(locate(/mob/living/basic/slime) in meal.buckled_mobs)
		if(silent)
			return FALSE
		balloon_alert(src, span_warning("another slime in the way!"))
		return FALSE

	if(issilicon(meal) || meal.mob_biotypes & MOB_ROBOTIC || meal.flags_1 & HOLOGRAM_1)
		balloon_alert(src, "no life energy!")
		return FALSE

	if(isslime(meal))
		if(silent)
			return FALSE
		balloon_alert(src, "can't eat slime!")
		return FALSE

	if(isanimal(meal))
		var/mob/living/simple_animal/simple_meal = meal
		if(simple_meal.damage_coeff[TOX] <= 0 && simple_meal.damage_coeff[BRUTE] <= 0) //The creature wouldn't take any damage, it must be too weird even for us.
			if(silent)
				return FALSE
			balloon_alert(src, "not food!")
			return FALSE
	else if(isbasicmob(meal))
		var/mob/living/basic/basic_meal = meal
		if(basic_meal.damage_coeff[TOX] <= 0 && basic_meal.damage_coeff[BRUTE] <= 0)
			if (silent)
				return FALSE
			balloon_alert(src, "not food!")
			return FALSE

	return TRUE

///The slime consumes the mob's lifeforce
/mob/living/basic/slime/proc/feed_process(seconds_per_tick = SSMOBS_DT)
	if(!isliving(buckled)) //Just in case
		stop_feeding(silent = TRUE)

	var/mob/living/prey = buckled

	if(stat)
		stop_feeding(silent = TRUE)

	if(prey.stat == DEAD) // our victim died
		if(client)
			to_chat(src, span_info("This subject does not have a strong enough life energy anymore..."))

		if(ai_controller && !ai_controller.blackboard[BB_RABID])
			var/mob/last_to_hurt = prey.LAssailant?.resolve()
			if(prob(30) && last_to_hurt && last_to_hurt != prey) //30 percent chance to befriend the last person who punched our food
				befriend(last_to_hurt)

			if(prob(60) && prey.client && ishuman(prey))
				ai_controller?.set_blackboard_key(BB_RABID, TRUE) //we might go rabid after finishing to feed on a human with a client.

		stop_feeding()
		return

	var/totaldamage = 0 //total damage done to this unfortunate soul

	if(iscarbon(prey))
		totaldamage += prey.adjustBruteLoss(rand(2, 4) * 0.5 * seconds_per_tick)
		totaldamage += prey.adjustToxLoss(rand(1, 2) * 0.5 * seconds_per_tick)

	if(isanimal_or_basicmob(prey))

		var/need_mob_update
		need_mob_update = totaldamage += prey.adjustBruteLoss(rand(2, 4) * 0.5 * seconds_per_tick, updating_health = FALSE)
		need_mob_update += totaldamage += prey.adjustToxLoss(rand(1, 2) * 0.5 * seconds_per_tick, updating_health = FALSE)
		if(need_mob_update)
			prey.updatehealth()

	if(totaldamage >= 0) // AdjustBruteLoss returns a negative value on succesful damage adjustment
		stop_feeding(FALSE, FALSE)
		return

	if(totaldamage < 0 && SPT_PROB(5, seconds_per_tick) && prey.client)

		var/static/list/pain_lines
		if(!pain_lines)
			pain_lines = list(
				"You can feel your body becoming weak!",
				"You feel like you're about to die!",
				"You feel every part of your body screaming in agony!",
				"A low, rolling pain passes through your body!",
				"Your body feels as if it's falling apart!",
				"You feel extremely weak!",
				"A sharp, deep pain bathes every inch of your body!",
			)

		to_chat(prey, span_userdanger(pick(pain_lines)))

	adjust_nutrition(-1 * totaldamage * 2 * seconds_per_tick) //twice the damage dealt

	//Heal yourself.
	adjustBruteLoss(-1.5 * seconds_per_tick)

///The slime will start feeding on the target
/mob/living/basic/slime/proc/start_feeding(mob/living/target_mob)
	target_mob.unbuckle_all_mobs(force=TRUE) //Slimes rip other mobs (eg: shoulder parrots) off (Slimes Vs Slimes is already handled in can_feed_on())
	if(target_mob.buckle_mob(src, force=TRUE))
		layer = target_mob.layer+0.01 //appear above the target mob
		target_mob.visible_message(span_danger("[name] latches onto [target_mob]!"), \
						span_userdanger("[name] latches onto [target_mob]!"))
	else
		balloon_alert(src, "latch failed!")

///The slime will stop feeding
/mob/living/basic/slime/proc/stop_feeding(silent = FALSE, living=TRUE)
	if(!buckled)
		return

	if(!living)
		balloon_alert(src, "not food!")
	var/mob/living/victim = buckled

	if(istype(victim))
		var/bio_protection = 100 - victim.getarmor(null, BIO)
		if(prob(bio_protection))
			victim.apply_status_effect(/datum/status_effect/slimed, slime_type.rgb_code, slime_type.colour == SLIME_TYPE_RAINBOW)

	if(!silent)
		visible_message(span_warning("[src] lets go of [buckled]!"), \
						span_notice("<i>I stopped feeding.</i>"))
	layer = initial(layer)
	buckled.unbuckle_mob(src,force=TRUE)
