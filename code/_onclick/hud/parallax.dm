#define LOOP_NONE 0
#define LOOP_NORMAL 1
#define LOOP_REVERSE 2
#define LOOP_TIME 50
/client
	var/list/parallax_layers
	var/list/parallax_layers_cached
	var/static/list/parallax_static_layers_tail = newlist(/obj/screen/parallax_pmaster, /obj/screen/parallax_space_whitifier)
	var/atom/movable/movingmob
	var/turf/previous_turf
	var/do_smoothing = TRUE
	var/looping_mode = LOOP_NONE
	var/last_parallax_shift //ds of last update
	var/parallax_throttle = 0 //ds between updates
	var/parallax_movedir = 0
	var/parallax_layers_max = 3

/datum/hud/proc/create_parallax()
	var/client/C = mymob.client
	if (!apply_parallax_pref())
		return

	if(!length(C.parallax_layers_cached))
		C.parallax_layers_cached = list()
		C.parallax_layers_cached += new /obj/screen/parallax_layer/layer_1
		C.parallax_layers_cached += new /obj/screen/parallax_layer/layer_2

	C.parallax_layers = C.parallax_layers_cached.Copy()

	if (length(C.parallax_layers) > C.parallax_layers_max)
		C.parallax_layers.len = C.parallax_layers_max

	C.screen |= (C.parallax_layers + C.parallax_static_layers_tail)

/datum/hud/proc/remove_parallax()
	var/client/C = mymob.client
	C.screen -= (C.parallax_layers_cached + C.parallax_static_layers_tail)
	C.parallax_layers = null

/datum/hud/proc/apply_parallax_pref()
	var/client/C = mymob.client
	switch(C.prefs.parallax)
		if (PARALLAX_INSANE)
			C.parallax_throttle = FALSE
			C.parallax_layers_max = 4
			return TRUE

		if (PARALLAX_MED)
			C.parallax_throttle = PARALLAX_DELAY_MED
			C.parallax_layers_max = 2
			return TRUE

		if (PARALLAX_LOW)
			C.parallax_throttle = PARALLAX_DELAY_LOW
			C.parallax_layers_max = 1
			return TRUE

		if (PARALLAX_DISABLE)
			return FALSE

		else
			C.parallax_throttle = PARALLAX_DELAY_DEFAULT
			C.parallax_layers_max = 3
			return TRUE

/datum/hud/proc/update_parallax_pref()
	remove_parallax()
	create_parallax()

// This sets which way the current shuttle is moving (returns true if anything changed)
/datum/hud/proc/set_parallax_movedir(new_parallax_movedir)
	. = FALSE
	var/client/C = mymob.client
	if(new_parallax_movedir == C.parallax_movedir)
		return
	. = TRUE
	if(new_parallax_movedir == FALSE)
		for(var/thing in C.parallax_layers)
			var/obj/screen/parallax_layer/L = thing
			animate(L)
			L.transform = matrix()
			L.icon_state = initial(L.icon_state)
			L.update_o()
		C.do_smoothing = TRUE
	else
		if(new_parallax_movedir == EAST || new_parallax_movedir == NORTH)
			C.looping_mode = LOOP_NORMAL
		else
			C.looping_mode = LOOP_REVERSE
		for(var/thing in C.parallax_layers)
			var/obj/screen/parallax_layer/L = thing
			var/newstate
			if(new_parallax_movedir == NORTH || new_parallax_movedir == SOUTH)
				newstate = "[initial(L.icon_state)]_vertical"
			else
				newstate = "[initial(L.icon_state)]_horizontal"

			if (newstate in icon_states(L.icon))
				L.icon_state = newstate

			L.update_o()
			var/T = max(LOOP_TIME / L.speed / 2, 2)
			var/matrix/newtransform
			switch(new_parallax_movedir)
				if(NORTH)
					newtransform = matrix(1, 0, 0, 0, 1, 480)
				if(SOUTH)
					newtransform = matrix(1, 0, 0, 0, 1,-480)
				if(EAST)
					newtransform = matrix(1, 0, 480, 0, 1, 0)
				if(WEST)
					newtransform = matrix(1, 0,-480, 0, 1, 0)
			L.transform = newtransform

			animate(L, transform = matrix(), time = T, loop = -1, flags = ANIMATION_END_NOW)
		C.do_smoothing = FALSE

	C.parallax_movedir = new_parallax_movedir

/datum/hud/proc/update_parallax()
	var/client/C = mymob.client
	var/turf/posobj = get_turf(C.eye)
	var/area/areaobj = posobj.loc

	// Update the movement direction of the parallax if necessary (for shuttles)
	var/force = set_parallax_movedir(areaobj.parallax_movedir)

	if (!force && world.time < C.last_parallax_shift+C.parallax_throttle)
		return

	if(!C.previous_turf || (C.previous_turf.z != posobj.z))
		C.previous_turf = posobj
		force = TRUE

	//Doing it this way prevents parallax layers from "jumping" when you change Z-Levels.
	var/offset_x = posobj.x - C.previous_turf.x
	var/offset_y = posobj.y - C.previous_turf.y
	if(!offset_x && !offset_y && !force)
		return
	var/last_delay = world.time - C.last_parallax_shift
	last_delay = min(last_delay, C.parallax_throttle)
	C.previous_turf = posobj
	C.last_parallax_shift = world.time

	for(var/thing in C.parallax_layers)
		var/obj/screen/parallax_layer/L = thing
		var/change_x = offset_x * L.speed
		L.offset_x -= change_x
		var/change_y = offset_y * L.speed
		L.offset_y -= change_y
		switch(C.looping_mode)
			if(LOOP_NONE)
				if(L.offset_x > 240)
					L.offset_x -= 480
				if(L.offset_x < -240)
					L.offset_x += 480
				if(L.offset_y > 240)
					L.offset_y -= 480
				if(L.offset_y < -240)
					L.offset_y += 480
			if(LOOP_NORMAL)
				if(L.offset_x > 0)
					L.offset_x -= 480
				if(L.offset_x < -480)
					L.offset_x += 480
				if(L.offset_y > 0)
					L.offset_y -= 480
				if(L.offset_y < -480)
					L.offset_y += 480
			if(LOOP_REVERSE)
				if(L.offset_x >= 480)
					L.offset_x -= 480
				if(L.offset_x < 0)
					L.offset_x += 480
				if(L.offset_y >= 480)
					L.offset_y -= 480
				if(L.offset_y < 0)
					L.offset_y += 480

		if(C.do_smoothing && (offset_x || offset_y) && abs(offset_x) <= max(C.parallax_throttle/world.tick_lag+1,1) && abs(offset_y) <= max(C.parallax_throttle/world.tick_lag+1,1) && (round(abs(change_x)) > 1 || round(abs(change_y)) > 1))
			L.transform = matrix(1, 0, offset_x*L.speed, 0, 1, offset_y*L.speed)
			animate(L, transform=matrix(), time = last_delay, flags = ANIMATION_END_NOW)

		L.screen_loc = "CENTER-7:[round(L.offset_x,1)],CENTER-7:[round(L.offset_y,1)]"

// Plays the launch animation for parallax
/datum/hud/proc/parallax_launch_anim(dir = EAST, slowing = FALSE)
	var/client/C = mymob.client
	C.do_smoothing = FALSE
	if(dir == EAST || dir == NORTH)
		C.looping_mode = LOOP_NORMAL
	else
		C.looping_mode = LOOP_REVERSE
	for(var/thing in C.parallax_layers)
		var/obj/screen/parallax_layer/L = thing
		animate(L) // Cancel the current animation
		var/M = L.speed * 480
		var/O = -480 + M
		switch(dir)
			if(NORTH)
				L.transform = matrix(1, 0, 0, 0, 1, M)
				L.offset_y += O
			if(SOUTH)
				L.transform = matrix(1, 0, 0, 0, 1,-M)
				L.offset_y -= O
			if(EAST)
				L.transform = matrix(1, 0, M, 0, 1, 0)
				L.offset_x += O
			if(WEST)
				L.transform = matrix(1, 0,-M, 0, 1, 0)
				L.offset_x -= O
	update_parallax() // Adjust the layers, they should all now be in the appropriate corner.
	for(var/thing in C.parallax_layers)
		var/obj/screen/parallax_layer/L = thing
		animate(L, transform = matrix(), time = LOOP_TIME, easing = QUAD_EASING | (slowing ? EASE_OUT : EASE_IN), flags = ANIMATION_END_NOW)
	spawn(LOOP_TIME)
		if(C && slowing)
			C.do_smoothing = TRUE
			C.looping_mode = LOOP_NONE


// Helper global procs for performing shuttle animations
/proc/parallax_launch_in_area(var/area/A, dir = EAST, slowing = FALSE)
	for(var/mob/M in mob_list)
		if(M.client && M.hud_used && length(M.client.parallax_layers) && get_area(M) == A)
			M.hud_used.parallax_launch_anim(dir, slowing)

/proc/parallax_movedir_in_area(var/area/A, dir = EAST)
	A.parallax_movedir = dir
	for(var/thing in mob_list)
		var/mob/M = thing
		if(M && M.client && M.hud_used && length(M.client.parallax_layers) && get_area(M) == A)
			M.hud_used.update_parallax()

/atom/movable/proc/update_parallax_contents()
	if(length(client_mobs_in_contents)) //this is even faster!
		for(var/thing in client_mobs_in_contents)
			var/mob/M = thing
			if(M && M.client && M.hud_used && length(M.client.parallax_layers))
				M.hud_used.update_parallax()

/obj/screen/parallax_layer
	icon = 'icons/effects/parallax.dmi'
	var/speed = 1
	var/offset_x = 0
	var/offset_y = 0
	blend_mode = BLEND_ADD
	plane = PLANE_SPACE_PARALLAX
	screen_loc = "CENTER-7,CENTER-7"
	mouse_opacity = 0

/obj/screen/parallax_layer/New()
	..()
	update_o()

/obj/screen/parallax_layer/proc/update_o()
	var/list/new_overlays = list()
	for(var/x in -2 to 2)
		for(var/y in -2 to 2)
			if(x == 0 && y == 0)
				continue
			var/image/I = image(icon, null, icon_state)
			I.transform = matrix(1, 0, x*480, 0, 1, y*480)
			new_overlays += I

	overlays = new_overlays

/obj/screen/parallax_layer/layer_1
	icon_state = "layer1"
	speed = 0.6
	layer = 1

/obj/screen/parallax_layer/layer_2
	icon_state = "layer2"
	speed = 1
	layer = 2

/obj/screen/parallax_pmaster
	appearance_flags = PLANE_MASTER
	plane = PLANE_SPACE_PARALLAX
	blend_mode = BLEND_MULTIPLY
	mouse_opacity = FALSE
	screen_loc = "CENTER-7,CENTER-7"

/obj/screen/parallax_space_whitifier
	appearance_flags = PLANE_MASTER
	plane = PLANE_SPACE
	color = list(
		0, 0, 0, 0,
		0, 0, 0, 0,
		0, 0, 0, 0,
		1, 1, 1, 1,
		0, 0, 0, 0
		)
	screen_loc = "CENTER-7,CENTER-7"


#undef LOOP_NONE
#undef LOOP_NORMAL
#undef LOOP_REVERSE
#undef LOOP_TIME