/datum/component/run_over_atom
	var/run_over_message = "drives over"
	var/damage_amount

/datum/component/run_over_atom/Initialize(_damage, _runover_message)
	if(!ismovableatom(parent))
		return COMPONENT_INCOMPATIBLE
	damage_amount = _damage ? _damage : rand(5, 15) //see multipliers below.

	if(_runover_message)
		run_over_message = _runover_message
	RegisterSignal(parent, COMSIG_MOVABLE_CROSSED_OVER, .proc/run_over)

/datum/component/run_over_atom/proc/run_over(atom/movable/AM, atom/movable/thing_ran_over)
	if(thing_ran_over.get_run_over(AM, damage_amount, run_over_message))
		AM.after_running_over(thing_ran_over)

/atom/movable/proc/after_running_over(atom/movable/AM)
	return

/mob/living/simple_animal/bot/mulebot/after_running_over(atom/movable/AM)
	bloodiness += 4

/atom/movable/proc/get_run_over(atom/movable/AM, _damage_amount, run_over_message)
	return

/mob/living/carbon/get_run_over(atom/movable/AM, _damage_amount, run_over_message)
	if(buckled == AM)
		return
	visible_message("<span class='danger'>[AM] [run_over_message] [src]!</span>", \
					"<span class='userdanger'>[AM] [run_over_message] you!</span>")
	playsound(src, 'sound/effects/splat.ogg', 50, TRUE)
	emote("scream")

	apply_damage(2*_damage_amount, BRUTE, BODY_ZONE_HEAD, run_armor_check(BODY_ZONE_HEAD, "melee"))
	apply_damage(2*_damage_amount, BRUTE, BODY_ZONE_CHEST, run_armor_check(BODY_ZONE_CHEST, "melee"))
	apply_damage(0.5*_damage_amount, BRUTE, BODY_ZONE_L_LEG, run_armor_check(BODY_ZONE_L_LEG, "melee"))
	apply_damage(0.5*_damage_amount, BRUTE, BODY_ZONE_R_LEG, run_armor_check(BODY_ZONE_R_LEG, "melee"))
	apply_damage(0.5*_damage_amount, BRUTE, BODY_ZONE_L_ARM, run_armor_check(BODY_ZONE_L_ARM, "melee"))
	apply_damage(0.5*_damage_amount, BRUTE, BODY_ZONE_R_ARM, run_armor_check(BODY_ZONE_R_ARM, "melee"))

	log_combat(AM, src, "ran over", null, "(DAMTYPE: [uppertext(BRUTE)])")

	add_splatter_floor()
	AM.add_blood_DNA(get_blood_dna_list())
	return TRUE

