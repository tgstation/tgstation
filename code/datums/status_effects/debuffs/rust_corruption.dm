/datum/status_effect/rust_corruption
	alert_type = null
	id = "rust_turf_effects"
	tick_interval = 2 SECONDS
	remove_on_fullheal = TRUE
	status_type = STATUS_EFFECT_REFRESH

/datum/status_effect/rust_corruption/tick(seconds_between_ticks)
	if(issilicon(owner))
		var/mob/living/silicon/silicon_victim = owner
		silicon_victim.adjustBruteLoss(10)
		return
	if(!iscarbon(owner))
		return
	var/mob/living/carbon/victim = owner
	victim.adjust_disgust(3, DISGUST_LEVEL_VERYDISGUSTED)
