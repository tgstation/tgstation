/datum/hud/proc/blob_hud(ui_style = 'icons/mob/screen_midnight.dmi')

	blobdisplay = new /obj/screen()
	blobdisplay.name = "blob power display"
	blobdisplay.icon_state = "block"
	blobdisplay.screen_loc = ui_nutrition
	blobdisplay.layer = 20

	mymob.client.screen = null

	mymob.client.screen += list(blobdisplay)