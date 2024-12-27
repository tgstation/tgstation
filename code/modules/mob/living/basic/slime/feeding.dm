
//Feeding

///Can the slime leech life energy from the target?
/mob/living/basic/slime/proc/can_feed_on(mob/living/meal, silent = FALSE, check_adjacent = FALSE, check_friendship = FALSE)

	if(!isliving(meal)) //sanity check
		return FALSE

	if(stat != CONSCIOUS)
		if(!silent)
			balloon_alert(src, "unconscious!")
		return FALSE

	if(hunger_disabled)
		if(!silent)
			balloon_alert(src, "not hungry!")
		return FALSE

	if(check_friendship && (REF(meal) in faction))
		return FALSE

	if(check_adjacent && (!Adjacent(meal) || !isturf(loc)))
		return FALSE

	if(!(mobility_flags & MOBILITY_MOVE))
		if(!silent)
			balloon_alert(src, "can't move!")
		return FALSE

	if(meal.stat == DEAD)
		if(!silent)
			balloon_alert(src, "no life energy!")
		return FALSE

	if(locate(/mob/living/basic/slime) in meal.buckled_mobs)
		if(!silent)
			balloon_alert(src, "another slime in the way!")
		return FALSE

	if(issilicon(meal) || meal.mob_biotypes & MOB_ROBOTIC || meal.flags_1 & HOLOGRAM_1)
		balloon_alert(src, "no life energy!")
		return FALSE

	if(isslime(meal))
		if(!silent)
			balloon_alert(src, "can't eat slime!")
		return FALSE

	if(isanimal(meal))
		var/mob/living/simple_animal/simple_meal = meal
		if(simple_meal.damage_coeff[TOX] <= 0 && simple_meal.damage_coeff[BRUTE] <= 0) //The creature wouldn't take any damage, it must be too weird even for us.
			if(!silent)
				balloon_alert(src, "not food!")
			return FALSE
	else if(isbasicmob(meal))
		var/mob/living/basic/basic_meal = meal
		if(basic_meal.damage_coeff[TOX] <= 0 && basic_meal.damage_coeff[BRUTE] <= 0)
			if (!silent)
				balloon_alert(src, "not food!")
			return FALSE

	return TRUE

///The slime will start feeding on the target
/mob/living/basic/slime/proc/start_feeding(mob/living/target_mob)
	target_mob.unbuckle_all_mobs(force=TRUE) //Slimes rip other mobs (eg: shoulder parrots) off (Slimes Vs Slimes is already handled in can_feed_on())
	if(target_mob.buckle_mob(src, force=TRUE))
		layer = MOB_ABOVE_PIGGYBACK_LAYER //always appear above the target mob, no matter the direction
		target_mob.visible_message(span_danger("[name] latches onto [target_mob]!"), \
						span_userdanger("[name] latches onto [target_mob]!"))
		target_mob.apply_status_effect(/datum/status_effect/slime_leech, src)
	else
		balloon_alert(src, "latch failed!")

///The slime will stop feeding
/mob/living/basic/slime/proc/stop_feeding(silent = FALSE)
	if(!buckled)
		return

	if(!silent)
		visible_message(span_warning("[src] lets go of [buckled]!"), span_notice("You let go of [buckled]"))
	layer = initial(layer)
	buckled.unbuckle_mob(src,force=TRUE)
