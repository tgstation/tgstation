/mob/living/silicon/decoy/Life()
	if (src.stat == 2)
		return
	else
		if (src.health <= config.health_threshold_dead && src.stat != 2)
			death()
			return


/mob/living/silicon/decoy/updatehealth()
	if (src.nodamage == 0)
		src.health = 100 - src.getOxyLoss() - src.getToxLoss() - src.fireloss - src.getBruteLoss()
	else
		src.health = 100
		src.stat = 0