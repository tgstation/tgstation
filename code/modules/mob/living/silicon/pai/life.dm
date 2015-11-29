/mob/living/silicon/pai/Life()
	if(timestopped) return 0 //under effects of time magick

	if (src.stat == 2)
		return

	regular_hud_updates()
	if(src.secHUD)
		process_sec_hud(src)
	if(src.medHUD)
		process_med_hud(src)
	if(silence_time)
		if(world.timeofday >= silence_time)
			silence_time = null
			to_chat(src, "<font color=green>Communication circuit reinitialized. Speech and messaging functionality restored.</font>")

/mob/living/silicon/pai/updatehealth()
	if(status_flags & GODMODE)
		health = maxHealth
		stat = CONSCIOUS
	else
		health = maxHealth - getBruteLoss() - getFireLoss()
