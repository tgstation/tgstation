
/mob/living/carbon/alien/get_eye_protection()
	return ..() + 2 //potential cyber implants + natural eye protection

/mob/living/carbon/alien/get_ear_protection()
	return 2 //no ears

/mob/living/carbon/alien/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	..(AM, skipcatch = TRUE, hitpush = FALSE)

/mob/living/carbon/alien/ex_act(severity, target, origin)
	. = ..()
	if(!. || QDELETED(src))
		return FALSE

	var/obj/item/organ/internal/ears/ears = get_organ_slot(ORGAN_SLOT_EARS)
	switch (severity)
		if (EXPLODE_DEVASTATE)
			gib()

		if (EXPLODE_HEAVY)
			take_overall_damage(60, 60)
			if(ears)
				ears.adjustEarDamage(30,120)

		if(EXPLODE_LIGHT)
			take_overall_damage(30,0)
			if(prob(50))
				Unconscious(20)
			if(ears)
				ears.adjustEarDamage(15,60)

	return TRUE


/mob/living/carbon/alien/soundbang_act(intensity = 1, stun_pwr = 20, damage_pwr = 5, deafen_pwr = 15)
	return 0

/mob/living/carbon/alien/acid_act(acidpwr, acid_volume)
	return FALSE//aliens are immune to acid.

/mob/living/carbon/alien/on_fire_stack(seconds_per_tick, times_fired, datum/status_effect/fire_handler/fire_stacks/fire_handler)
	adjust_bodytemperature((BODYTEMP_HEATING_MAX + (fire_handler.stacks * 12)) * 0.5 * seconds_per_tick)
