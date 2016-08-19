
/datum/hud/brain/show_hud(version = 0)
	if(!ismob(mymob))
		return 0
	if(!mymob.client)
		return 0
	mymob.client.screen = list()
	mymob.client.screen += mymob.client.void

/mob/living/carbon/brain/create_mob_hud()
	if(client && !hud_used)
		hud_used = new /datum/hud/brain(src)

/datum/hud/hog_god/New(mob/owner)
	..()
	healths = new /obj/screen/healths/deity()
	infodisplay += healths

	deity_power_display = new /obj/screen/deity_power_display()
	infodisplay += deity_power_display

	deity_follower_display = new /obj/screen/deity_follower_display()
	infodisplay += deity_follower_display


/mob/camera/god/create_mob_hud()
	if(client && !hud_used)
		hud_used = new /datum/hud/hog_god(src)

/obj/screen/deity_power_display
	name = "Faith"
	icon_state = "deity_power"
	screen_loc = ui_deitypower
	layer = HUD_LAYER

/obj/screen/deity_follower_display
	name = "Followers"
	icon_state = "deity_followers"
	screen_loc = ui_deityfollowers
	layer = HUD_LAYER

