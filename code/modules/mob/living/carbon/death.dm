/mob/living/carbon/death(gibbed)
	silent = 0
	losebreath = 0
	med_hud_set_health()
	med_hud_set_status()
	for(var/datum/medical_effect/E in medical_effects)
		remove_medical_effect(E)
	..()
