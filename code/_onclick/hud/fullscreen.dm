
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
		screen = new type()

	screen.icon_state = "[initial(screen.icon_state)][severity]"
	screen.severity = severity

	screens[category] = screen
	if(client && stat != DEAD)
		client.screen += screen
	return screen

/mob/proc/clear_fullscreen(category, animated = 10)
	var/obj/screen/fullscreen/screen = screens[category]
	if(!screen)
		return

	screens -= category

	if(animated)
		animate(screen, alpha = 0, time = animated)
		addtimer(CALLBACK(src, .proc/clear_fullscreen_after_animate, screen), animated, TIMER_CLIENT_TIME)
	else
		if(client)
			client.screen -= screen
		qdel(screen)

/mob/proc/clear_fullscreen_after_animate(obj/screen/fullscreen/screen)
	if(client)
		client.screen -= screen
	qdel(screen)

/mob/proc/clear_fullscreens()
	for(var/category in screens)
		clear_fullscreen(category)

/mob/proc/hide_fullscreens()
	if(client)
		for(var/category in screens)
			client.screen -= screens[category]

/mob/proc/reload_fullscreen()
	if(client && stat != DEAD) //dead mob do not see any of the fullscreen overlays that he has.
		for(var/category in screens)
			client.screen |= screens[category]

/obj/screen/fullscreen
	icon = 'icons/mob/screen_full.dmi'
	icon_state = "default"
	screen_loc = "CENTER-7,CENTER-7"
	layer = FULLSCREEN_LAYER
	plane = FULLSCREEN_PLANE
	mouse_opacity = 0
	var/severity = 0

/obj/screen/fullscreen/Destroy()
	severity = 0
	. = ..()

/obj/screen/fullscreen/brute
	icon_state = "brutedamageoverlay"
	layer = UI_DAMAGE_LAYER
	plane = FULLSCREEN_PLANE

/obj/screen/fullscreen/oxy
	icon_state = "oxydamageoverlay"
	layer = UI_DAMAGE_LAYER
	plane = FULLSCREEN_PLANE

/obj/screen/fullscreen/crit
	icon_state = "passage"
	layer = CRIT_LAYER
	plane = FULLSCREEN_PLANE

/obj/screen/fullscreen/blind
	icon_state = "blackimageoverlay"
	layer = BLIND_LAYER
	plane = FULLSCREEN_PLANE

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

/obj/screen/fullscreen/flash/static
	icon = 'icons/mob/screen_gen.dmi'
	screen_loc = "WEST,SOUTH to EAST,NORTH"
	icon_state = "noise"

/obj/screen/fullscreen/high
	icon = 'icons/mob/screen_gen.dmi'
	screen_loc = "WEST,SOUTH to EAST,NORTH"
	icon_state = "druggy"

/obj/screen/fullscreen/color_vision
	icon = 'icons/mob/screen_gen.dmi'
	screen_loc = "WEST,SOUTH to EAST,NORTH"
	icon_state = "flash"
	alpha = 80

/obj/screen/fullscreen/color_vision/green
	color = "#00ff00"

/obj/screen/fullscreen/color_vision/red
	color = "#ff0000"

/obj/screen/fullscreen/color_vision/blue
	color = "#0000ff"