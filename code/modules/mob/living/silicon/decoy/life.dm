/mob/living/silicon/decoy/Life()
	if (src.stat == 2)
		return
	else
		if (src.health <= config.health_threshold_dead && src.stat != 2)
			death()
			return


/mob/living/silicon/decoy/updatehealth()
	if(status_flags & GODMODE)
		health = 100
		stat = CONSCIOUS
	else
		health = 100 - getOxyLoss() - getToxLoss() - getFireLoss() - getBruteLoss()
