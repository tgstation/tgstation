/// This limb regens in light! Only BODYTYPE_PLANT limbs will heal, but limbs without the flag (and with the effect) still contribute to healing of the other limbs
/datum/status_effect/grouped/bodypart_effect/photosynthesis
	processing_speed = STATUS_EFFECT_NORMAL_PROCESS
	tick_interval = 1 SECONDS
	id = "photosynthesis"

/datum/status_effect/grouped/bodypart_effect/photosynthesis/tick(seconds_between_ticks)
	var/light_amount = 0 // How much light there is in the place, affects receiving nutrition and healing
	var/bodypart_coefficient = GET_BODYPART_COEFFICIENT(bodyparts)

	if(!isturf(owner.loc)) // There's considered to be no light inside of objects
		if(owner.nutrition < NUTRITION_LEVEL_STARVING + 50)
			owner.take_overall_damage(brute = 1 * bodypart_coefficient, required_bodytype = BODYTYPE_PLANT)
		return

	var/turf/turf_loc = owner.loc
	light_amount = min(1, turf_loc.get_lumcount()) - 0.5

	if(owner.nutrition < NUTRITION_LEVEL_ALMOST_FULL)
		owner.adjust_nutrition(5 * light_amount * bodypart_coefficient)

	if(light_amount > 0.2) // If there's enough light, heal
		var/need_mob_update = FALSE
		need_mob_update += owner.heal_overall_damage(brute = 0.5 * bodypart_coefficient, \
			burn = 0.5 * bodypart_coefficient, updating_health = FALSE, required_bodytype = BODYTYPE_PLANT)
		need_mob_update += owner.adjust_tox_loss(-0.5 * bodypart_coefficient, updating_health = FALSE)
		need_mob_update += owner.adjust_oxy_loss(-0.5 * bodypart_coefficient, updating_health = FALSE)
		if(need_mob_update)
			owner.updatehealth()

	if(owner.nutrition < NUTRITION_LEVEL_STARVING + 50)
		owner.take_overall_damage(brute = 1 * bodypart_coefficient, required_bodytype = BODYTYPE_PLANT)
