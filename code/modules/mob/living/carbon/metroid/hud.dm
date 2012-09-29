
/mob/living/carbon/metroid/proc/regular_hud_updates()
	if(client)
		for(var/hud in client.screen)
			del(hud)

