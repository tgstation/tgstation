// Commented out cos it doesnt work atm; intended to be used in sec_hud_sec_id()
// Leaving here in case I can figure it out, because this would be preferable to the solution I came up with

/*
mob/living/carbon/human/proc/fulp_HUD_update()
	to_chat(world, "X1: jbname [wear_id.GetJobName()] vs [json_encode(GLOB.fulp_jobs)]")
	if((wear_id.GetJobName()) in GLOB.fulp_jobs)
		to_chat(world, "A1")
		for(var/hud in hud_list)
			to_chat(world, "A2")
			if(hud == ID_HUD)
				to_chat(world, "A3")
				var/image/I = image('icons/fulpicons/fulphud.dmi', src, "")
				I.appearance_flags = RESET_COLOR|RESET_TRANSFORM
				hud_list[hud] = I
	else
		for(var/hud in hud_list)
			to_chat(world, "B1")
			if(hud == ID_HUD)
				to_chat(world, "B2")
				var/image/I = image('icons/mob/hud.dmi', src, "")
				I.appearance_flags = RESET_COLOR|RESET_TRANSFORM
				hud_list[hud] = I
*/
