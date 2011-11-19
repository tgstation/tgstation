/mob/living/silicon/pai/Life()
	if (src.stat == 2)
		return
	if(src.cable)
		if(get_dist(src, src.cable) > 1)
			var/turf/T = get_turf_or_move(src.loc)
			for (var/mob/M in viewers(T))
				M.show_message("\red [src.cable] rapidly retracts back into its spool.", 3, "\red You hear a click and the sound of wire spooling rapidly.", 2)
			del(src.cable)

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
	if(src.nodamage)
		src.health = 100
		src.stat = 0
	else
		src.health = 100 - src.getBruteLoss() - src.fireloss