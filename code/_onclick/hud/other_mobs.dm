/datum/hud/proc/unplayer_hud()
	return

/datum/hud/proc/brain_hud(ui_style = 'icons/mob/screen_midnight.dmi')
	mymob.blind = new /obj/screen()
	mymob.blind.icon = 'icons/mob/screen_full.dmi'
	mymob.blind.icon_state = "blackimageoverlay"
	mymob.blind.name = " "
	mymob.blind.screen_loc = "CENTER-7,CENTER-7"
	mymob.blind.layer = 0
	mymob.blind.mouse_opacity = 0

	mymob.client.screen = list()
	mymob.client.screen += list(mymob.blind)
	mymob.client.screen += mymob.client.void

/datum/hud/proc/hoggod_hud(ui_style = 'icons/mob/screen_midnight.dmi')
	deity_health_display = new /obj/screen()
	deity_health_display.name = "Nexus Health"
	deity_health_display.icon_state = "deity_nexus"
	deity_health_display.screen_loc = ui_deityhealth
	deity_health_display.layer = 20

	deity_power_display = new /obj/screen()
	deity_power_display.name = "Faith"
	deity_power_display.icon_state = "deity_power"
	deity_power_display.screen_loc = ui_deitypower
	deity_power_display.layer = 20

	deity_follower_display = new /obj/screen()
	deity_follower_display.name = "Followers"
	deity_follower_display.icon_state = "deity_followers"
	deity_follower_display.screen_loc = ui_deityfollowers
	deity_follower_display.layer = 20

	mymob.client.screen = null

	mymob.client.screen += list(deity_health_display, deity_power_display, deity_follower_display)
