/mob/living/carbon/death(gibbed)
	eye_blind = max(eye_blind, 1)
	silent = 0
	med_hud_set_health()
	med_hud_set_status()
	..(gibbed)
