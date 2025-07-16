/datum/status_effect/rust_corruption
	alert_type = null
	id = "rust_turf_effects"
	tick_interval = 2 SECONDS
	remove_on_fullheal = TRUE

/datum/status_effect/rust_corruption/tick(seconds_between_ticks)
	if(issilicon(owner) || isbot(owner))
		owner.adjustBruteLoss(10 * seconds_between_ticks)
		return
	owner.adjust_disgust(5 * seconds_between_ticks)
	owner.reagents?.remove_all(0.75 * seconds_between_ticks)
	if(!iscarbon(owner))
		return
	var/mob/living/carbon/carbon_owner = owner
	for(var/obj/item/bodypart/robotic_limb as anything in carbon_owner.bodyparts)
		if(IS_ROBOTIC_LIMB(robotic_limb))
			robotic_limb.receive_damage(10)
