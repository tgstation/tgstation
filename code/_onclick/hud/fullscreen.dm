/mob
	var/list/screens = list()

/mob/proc/overlay_fullscreen(category, type, severity)
	if(!category)
		return

	var/obj/screen/fullscreen/screen
	if(screens[category])
		screen = screens[category]
		if(screen.type != type)
			clear_fullscreen(category, FALSE)
			return .()
		else if(!severity || severity == screen.severity)
			return null
	else
		screen = PoolOrNew(type)

	screen.icon_state = "[initial(screen.icon_state)][severity]"
	screen.severity = severity

	screens[category] = screen
	if(client && hud_used)
		hud_used.update_fullscreen()

	return screen

/mob/proc/clear_fullscreen(category, animate = 10)
	var/obj/screen/fullscreen/screen = screens[category]
	if(!screen)
		return FALSE

	if(animate)
		animate(screen, alpha = 0, time = animate)
		sleep(animate)

	screens -= category
	if(client)
		client.screen -= screen
	qdel(screen)
	return TRUE

/datum/hud/proc/update_fullscreen()
	var/list/screens = mymob.screens
	if(hud_shown)
		for(var/screen in screens)
			mymob.client.screen |= screens[screen]
	else
		for(var/screen in screens)
			mymob.client.screen -= screens[screen]

/obj/screen/fullscreen
	icon = 'icons/mob/screen_full.dmi'
	icon_state = "default"
	screen_loc = "CENTER-7,CENTER-7"
	layer = 18
	mouse_opacity = 0
	var/severity = 0

/obj/screen/fullscreen/Destroy()
	..()
	severity = 0
	screen_loc = ""
	return QDEL_HINT_PUTINPOOL

/obj/screen/fullscreen/brute
	icon_state = "brutedamageoverlay"

/obj/screen/fullscreen/oxy
	icon_state = "oxydamageoverlay"

/obj/screen/fullscreen/crit
	icon_state = "passage"

/obj/screen/fullscreen/blind
	icon_state = "blackimageoverlay"

/obj/screen/fullscreen/impaired
	icon_state = "impairedoverlay"

/obj/screen/fullscreen/blurry
	icon = 'icons/mob/screen_gen.dmi'
	screen_loc = "WEST,SOUTH to EAST,NORTH"
	icon_state = "blurry"

/obj/screen/fullscreen/flash
	icon = 'icons/mob/screen_gen.dmi'
	screen_loc = "WEST,SOUTH to EAST,NORTH"
	icon_state = "flash"

/obj/screen/fullscreen/flash/noise
	icon = 'icons/mob/screen_gen.dmi'
	screen_loc = "WEST,SOUTH to EAST,NORTH"
	icon_state = "noise"

/obj/screen/fullscreen/high
	icon = 'icons/mob/screen_gen.dmi'
	screen_loc = "WEST,SOUTH to EAST,NORTH"
	icon_state = "druggy"