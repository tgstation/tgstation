/mob/living/silicon/pai/Life()
	if (src.stat == 2)
		return
	if(src.cable)
		if(get_dist(src, src.cable) > 1)
			var/turf/T = get_turf(src.loc)
			for (var/mob/M in viewers(T))
				M.show_message("<span class='danger'>[src.cable] rapidly retracts back into its spool.</span>", 3, "<span class='danger'>You hear a click and the sound of wire spooling rapidly.</span>", 2)
			qdel(src.cable)
			cable = null

	regular_hud_updates()
	if(src.secHUD == 1)
		src.securityHUD()
	if(src.medHUD == 1)
		src.medicalHUD()
	if(silence_time)
		if(world.timeofday >= silence_time)
			silence_time = null
			src << "<font color=green>Communication circuit reinitialized. Speech and messaging functionality restored.</font>"

/mob/living/silicon/pai/updatehealth()
	if(status_flags & GODMODE)
		health = maxHealth
		stat = CONSCIOUS
		return
	health = maxHealth - getBruteLoss() - getFireLoss()

/mob/living/silicon/pai/proc/follow_pai()
	while(card)
		loc = get_turf(card)
		sleep(5)
	qdel(src) //if there's no pAI we shouldn't exist
