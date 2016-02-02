#define FULLSCREEN_LAYER 18
#define DAMAGE_LAYER FULLSCREEN_LAYER + 0.1
#define IMPAIRED_LAYER DAMAGE_LAYER + 0.1
#define BLIND_LAYER IMPAIRED_LAYER + 0.1
#define CRIT_LAYER BLIND_LAYER + 0.1

/mob
	var/list/screens = list()

/mob/proc/overlay_fullscreen(category, type, severity)
	var/obj/screen/fullscreen/screen
	if(screens[category])
		screen = screens[category]
		if(screen.type != type)
			clear_fullscreen(category, FALSE)
			return .()
		else if(!severity || severity == screen.severity)
			return null
	else
		screen = getFromPool(type)

	screen.icon_state = "[initial(screen.icon_state)][severity]"
	screen.severity = severity

	screens[category] = screen
	if(client)
		client.screen += screen
	return screen

/mob/proc/clear_fullscreen(category, animate = 10)
	set waitfor = 0
	var/obj/screen/fullscreen/screen = screens[category]
	if(!screen)
		return

	if(animate)
		animate(screen, alpha = 0, time = animate)
		sleep(animate)

	screens -= category
	if(client)
		client.screen -= screen
	qdel(screen)

/mob/proc/clear_fullscreens()
	for(var/category in screens)
		clear_fullscreen(category)

/datum/hud/proc/reload_fullscreen()
	var/list/screens = mymob.screens
	for(var/category in screens)
		mymob.client.screen |= screens[category]

/obj/screen/fullscreen
	icon = 'icons/mob/screen1_full.dmi'
	icon_state = "default"
	screen_loc = "CENTER-7,CENTER-7"
	layer = FULLSCREEN_LAYER
	mouse_opacity = 0
	var/severity = 0

/obj/screen/fullscreen/Destroy()
	severity = 0
	..()

/obj/screen/fullscreen/brute
	icon_state = "brutedamageoverlay"
	layer = DAMAGE_LAYER

/obj/screen/fullscreen/oxy
	icon_state = "oxydamageoverlay"
	layer = DAMAGE_LAYER

/obj/screen/fullscreen/crit
	icon_state = "passage"
	layer = CRIT_LAYER

/obj/screen/fullscreen/blind
	icon_state = "blackimageoverlay"
	layer = BLIND_LAYER

/obj/screen/fullscreen/impaired
	icon_state = "impairedoverlay"
	layer = IMPAIRED_LAYER

/obj/screen/fullscreen/blurry
	icon = 'icons/mob/screen1.dmi'
	screen_loc = "WEST,SOUTH to EAST,NORTH"
	icon_state = "blurry"

/obj/screen/fullscreen/flash
	icon = 'icons/mob/screen1.dmi'
	screen_loc = "WEST,SOUTH to EAST,NORTH"
	icon_state = "flash"

/obj/screen/fullscreen/flash/noise
	icon = 'icons/mob/screen1.dmi'
	screen_loc = "WEST,SOUTH to EAST,NORTH"
	icon_state = "noise"

/obj/screen/fullscreen/high
	icon = 'icons/mob/screen1.dmi'
	screen_loc = "WEST,SOUTH to EAST,NORTH"
	icon_state = "druggy"



#undef FULLSCREEN_LAYER
#undef BLIND_LAYER
#undef IMPAIRED_LAYER
#undef DAMAGE_LAYER
#undef CRIT_LAYER
