/mob/living/silicon/decoy/Life()
	if (src.stat == 2)
		return
	else
		if (src.health <= config.health_threshold_dead && src.stat != 2)
			death()
			return


/mob/living/silicon/decoy/updatehealth()
	if(status_flags & GODMODE)
		health = maxHealth
		stat = CONSCIOUS
	else
		health = maxHealth - getOxyLoss() - getToxLoss() - getFireLoss() - getBruteLoss()
