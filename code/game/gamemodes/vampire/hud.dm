/datum/hud/proc/vampire_hud(ui_style = 'icons/mob/screen1_Midnight.dmi')

	vampire_blood_display = new /obj/screen()
	vampire_blood_display.name = "Vampire Blood"
	vampire_blood_display.icon_state = "dark128"
	vampire_blood_display.screen_loc = "14:28,9:15"
	vampire_blood_display.layer = 20

	mymob.client.screen += list(vampire_blood_display)