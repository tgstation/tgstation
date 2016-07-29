<<<<<<< HEAD
/mob/living/silicon/pai/Life()
	if (src.stat == DEAD)
		return
	if(src.cable)
		if(get_dist(src, src.cable) > 1)
			var/turf/T = get_turf(src.loc)
			T.visible_message("<span class='warning'>[src.cable] rapidly retracts back into its spool.</span>", "<span class='italics'>You hear a click and the sound of wire spooling rapidly.</span>")
			qdel(src.cable)
			cable = null
	if(silence_time)
		if(world.timeofday >= silence_time)
			silence_time = null
			src << "<font color=green>Communication circuit reinitialized. Speech and messaging functionality restored.</font>"

/mob/living/silicon/pai/updatehealth()
	if(status_flags & GODMODE)
		return
	health = maxHealth - getBruteLoss() - getFireLoss()
	update_stat()
=======
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
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
