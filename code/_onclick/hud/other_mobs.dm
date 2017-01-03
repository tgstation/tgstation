
/datum/hud/brain/show_hud(version = 0)
	if(!ismob(mymob))
		return 0
	if(!mymob.client)
		return 0
	mymob.client.screen = list()
	mymob.client.screen += mymob.client.void

/mob/living/brain/create_mob_hud()
	if(client && !hud_used)
		hud_used = new /datum/hud/brain(src)

