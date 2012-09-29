/datum/hud/proc/brain_hud(var/ui_style='icons/mob/screen1_old.dmi')

	//ui_style='icons/mob/screen1_old.dmi' //Overriding the parameter. Only this UI style is acceptable with the 'sleek' layout.

	mymob.blind = new /obj/screen()
	mymob.blind.icon = 'icons/mob/screen1_full.dmi'
	mymob.blind.icon_state = "blackimageoverlay"
	mymob.blind.name = " "
	mymob.blind.screen_loc = "1,1"
	mymob.blind.layer = 0
