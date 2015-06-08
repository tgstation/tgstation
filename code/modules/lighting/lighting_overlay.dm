/atom/movable/lighting_overlay
	name = ""
	mouse_opacity = 0
	anchored = 1

	icon = LIGHTING_ICON
	layer = LIGHTING_LAYER
	invisibility = INVISIBILITY_LIGHTING
	blend_mode = BLEND_MULTIPLY
	color = "#000000"

	var/lum_r
	var/lum_g
	var/lum_b

	#if LIGHTING_RESOLUTION != 1
	var/xoffset
	var/yoffset
	#endif

	var/needs_update

/atom/movable/lighting_overlay/New()
	. = ..()
	verbs.Cut()

/atom/movable/lighting_overlay/proc/update_lumcount(delta_r, delta_g, delta_b)
	lum_r += delta_r
	lum_g += delta_g
	lum_b += delta_b

	needs_update = 1
	lighting_update_overlays |= src

/atom/movable/lighting_overlay/proc/update_overlay()
	var/mx = max(lum_r, lum_g, lum_b)
	. = 1 // factor
	if(mx > 1)
		. = 1/mx
	#if LIGHTING_TRANSITIONS == 1
	animate(src,
		color = rgb(lum_r * 255 * ., lum_g * 255 * ., lum_b * 255 * .),
		LIGHTING_INTERVAL - 1
	)
	#else
	color = rgb(lum_r * 255 * ., lum_g * 255 * ., lum_b * 255 * .)
	#endif

	var/turf/T = loc

	if(istype(T)) //Incase we're not on a turf, pool ourselves, something happened.
		if(round(max(lum_r, lum_g, lum_b, 0), 0.1))
			T.luminosity = 1
		else  //No light, set the turf's luminosity to 0 to remove it from view()
			#if LIGHTING_TRANSITIONS == 1
			spawn(LIGHTING_INTERVAL - 1)
				T.luminosity = 0
			#else
			T.luminosity = 0
			#endif

		universe.OnTurfTick(T)
	else
		warning("A lighting overlay realised it had no loc in update_overlay() and got pooled!")
		returnToPool(src)

/atom/movable/lighting_overlay/resetVariables()
//	testing("Lighting_overlays: resetvars called")
	loc = null

	lum_r = 0
	lum_g = 0
	lum_b = 0

	color = "#000000"

	#if LIGHTING_RESOLUTION != 1
	xoffset = null
	yoffset = null
	#endif

	needs_update = 0

/atom/movable/lighting_overlay/Destroy()
	all_lighting_overlays -= src
	lighting_update_overlays -= src

	var/turf/T = loc
	if(istype(T))
		#if LIGHTING_RESOLUTION == 1
		T.lighting_overlay = null
		#else
		T.lighting_overlays -= src
		#endif
		for(var/datum/light_source/D in T.affecting_lights) //Remove references to us on the light sources affecting us.
			D.effect_r -= src
			D.effect_g -= src
			D.effect_b -= src

/atom/movable/lighting_overlay/singuloCanEat()
	return 0

/atom/movable/lighting_overlay/ex_act(severity)
	return 0
