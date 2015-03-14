/mob/living/carbon/death(gibbed)
	silent = 0
	med_hud_set_health()
	med_hud_set_status()
	..(gibbed)
