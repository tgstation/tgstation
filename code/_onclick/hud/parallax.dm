/*
 * This file handles all parallax-related business once the parallax itself is initialized with the rest of the HUD
 */

var/list/parallax_on_clients = list()

/obj/screen/parallax
	var/base_offset_x = 0
	var/base_offset_y = 0
	mouse_opacity = 0
	icon = 'icons/turf/space.dmi'
	icon_state = "blank"
	name = "space parallax"
	blend_mode = BLEND_ADD
	layer = AREA_LAYER
	plane = PLANE_SPACE_PARALLAX//changing this var doesn't actually change the plane of its overlays
	globalscreen = 1
	var/parallax_speed = 0

/obj/screen/plane_master
	appearance_flags = PLANE_MASTER
	screen_loc = "1,1"
	globalscreen = 1

/obj/screen/plane_master/parallax_master
	plane = PLANE_SPACE_PARALLAX
	color = list(
	1,0,0,0,
	0,1,0,0,
	0,0,1,0,
	0,0,0,0,
	0,0,0,1)

/obj/screen/plane_master/parallax_dustmaster
	plane = PLANE_SPACE_DUST

/datum/hud/proc/update_parallax()
	var/client/C = mymob.client
	if(!parallax_initialized || C.updating_parallax) return

	for(var/turf/T in range(get_turf(C.eye),C.view))
		if(istype(T,/turf/space))
			C.updating_parallax = 1
			break

	if(!C.updating_parallax)
		return

	//multiple sub-procs for profiling purposes
	if(update_parallax1())
		update_parallax2(0)
		update_parallax3()
		C.updating_parallax = 0
	else
		C.updating_parallax = 0

/datum/hud/proc/update_parallax_and_dust()
	var/client/C = mymob.client
	if(!parallax_initialized || C.updating_parallax) return
	C.updating_parallax = 1
	if(update_parallax1())
		update_parallax2(1)
		update_parallax3()
		C.updating_parallax = 0
	else
		C.updating_parallax = 0

/datum/hud/proc/update_parallax1()
	var/client/C = mymob.client
	//DO WE UPDATE PARALLAX
	if(C.prefs.space_parallax)//have to exclude Centcom so parallax doens't appear during hyperspace
		parallax_on_clients |= C
	else
		for(var/obj/screen/parallax/bgobj in C.parallax)
			C.screen -= bgobj
		parallax_on_clients -= C
		C.screen -= C.parallax_master
		C.screen -= C.parallax_dustmaster
		return 0

	if(!C.parallax_master)
		C.parallax_master = getFromPool(/obj/screen/plane_master/parallax_master)
	if(!C.parallax_dustmaster)
		C.parallax_dustmaster = getFromPool(/obj/screen/plane_master/parallax_dustmaster)
	return 1

/datum/hud/proc/update_parallax2(forcerecalibrate = 0)
	var/client/C = mymob.client
	//DO WE HAVE TO REPLACE ALL THE LAYERS

	if(!C.parallax.len)
		for(var/obj/screen/parallax/bgobj in parallax_icon)
			var/obj/screen/parallax/parallax_layer = getFromPool(/obj/screen/parallax)
			parallax_layer.appearance = bgobj.appearance
			parallax_layer.base_offset_x = bgobj.base_offset_x
			parallax_layer.base_offset_y = bgobj.base_offset_y
			parallax_layer.parallax_speed = bgobj.parallax_speed
			C.parallax += parallax_layer

	var/parallax_loaded = 0
	for(var/obj/screen/S in C.screen)
		if(istype(S,/obj/screen/parallax))
			parallax_loaded = 1
			break

	if(forcerecalibrate || !parallax_loaded)
		for(var/obj/screen/parallax/bgobj in C.parallax)
			C.screen |= bgobj

		C.screen |= C.parallax_master
		C.screen |= C.parallax_dustmaster
		C.parallax_dustmaster.color = list(0,0,0,0)
		if(C.prefs.space_dust)
			C.parallax_dustmaster.color = list(
			1,0,0,0,
			0,1,0,0,
			0,0,1,0,
			0,0,0,1)

	if(!C.parallax_offset.len)
		C.parallax_offset["horizontal"] = 0
		C.parallax_offset["vertical"] = 0

/datum/hud/proc/update_parallax3()
	var/client/C = mymob.client
	//ACTUALLY MOVING THE PARALLAX
	var/turf/posobj = get_turf(C.eye)

	if(!C.previous_turf || (C.previous_turf.z != posobj.z))
		C.previous_turf = posobj

	//Doing it this way prevents parallax layers from "jumping" when you change Z-Levels.
	C.parallax_offset["horizontal"] += posobj.x - C.previous_turf.x
	C.parallax_offset["vertical"] += posobj.y - C.previous_turf.y

	C.previous_turf = posobj

	for(var/obj/screen/parallax/bgobj in C.parallax)
		if(bgobj.parallax_speed)//only the middle and front layers actually move
			var/accumulated_offset_x = bgobj.base_offset_x - round(C.parallax_offset["horizontal"] * bgobj.parallax_speed * (C.prefs.parallax_speed/2))
			var/accumulated_offset_y = bgobj.base_offset_y - round(C.parallax_offset["vertical"] * bgobj.parallax_speed * (C.prefs.parallax_speed/2))

			while(accumulated_offset_x > 720)
				accumulated_offset_x -= 1440
			while(accumulated_offset_x < -720)
				accumulated_offset_x += 1440

			while(accumulated_offset_y > 720)
				accumulated_offset_y -= 1440
			while(accumulated_offset_y < -720)
				accumulated_offset_y += 1440

			bgobj.screen_loc = "CENTER-7:[accumulated_offset_x],CENTER-7:[accumulated_offset_y]"
		else
			bgobj.screen_loc = "CENTER-7:[bgobj.base_offset_x],CENTER-7:[bgobj.base_offset_y]"

//Parallax generation code below

#define PARALLAX4_ICON_NUMBER 20
#define PARALLAX3_ICON_NUMBER 14
#define PARALLAX2_ICON_NUMBER 10

/datum/controller/game_controller/proc/cachespaceparallax()
	var/list/plane1 = list()
	var/list/plane2 = list()
	var/list/plane3 = list()
	var/list/pixel_x = list()
	var/list/pixel_y = list()
	var/index = 1
	for(var/i = 0 to 224)
		for(var/j = 1 to 9)
			plane1 += rand(1,26)
			plane2 += rand(1,26)
			plane3 += rand(1,26)
		pixel_x += 32 * (i%15)
		pixel_y += 32 * round(i/15)

	for(var/i in 0 to 8)
		var/obj/screen/parallax/parallax_layer = new /obj/screen/parallax()

		var/list/L = list()
		for(var/j in 1 to 225)
			if(plane1[j+i*225] <= PARALLAX4_ICON_NUMBER)
				var/image/I = image('icons/turf/space_parallax4.dmi',"[plane1[j+i*225]]")
				I.pixel_x = pixel_x[j]
				I.pixel_y = pixel_y[j]
				I.plane = PLANE_SPACE_PARALLAX
				L += I

		parallax_layer.overlays = L
		parallax_layer.parallax_speed = 0
		parallax_layer.plane = PLANE_SPACE_PARALLAX
		calibrate_parallax(parallax_layer,i+1)
		parallax_icon[index] = parallax_layer
		index++

	for(var/i in 0 to 8)
		var/obj/screen/parallax/parallax_layer = new /obj/screen/parallax()

		var/list/L = list()
		for(var/j in 1 to 225)
			if(plane2[j+i*225] <= PARALLAX3_ICON_NUMBER)
				var/image/I = image('icons/turf/space_parallax3.dmi',"[plane2[j+i*225]]")
				I.pixel_x = pixel_x[j]
				I.pixel_y = pixel_y[j]
				I.plane = PLANE_SPACE_PARALLAX
				L += I

		parallax_layer.overlays = L
		parallax_layer.parallax_speed = 1
		parallax_layer.plane = PLANE_SPACE_PARALLAX
		calibrate_parallax(parallax_layer,i+1)
		parallax_icon[index] = parallax_layer
		index++

	for(var/i in 0 to 8)
		var/obj/screen/parallax/parallax_layer = new /obj/screen/parallax()
		var/list/L = list()
		for(var/j in 1 to 225)
			if(plane3[j+i*225] <= PARALLAX2_ICON_NUMBER)
				var/image/I = image('icons/turf/space_parallax2.dmi',"[plane3[j+i*225]]")
				I.pixel_x = pixel_x[j]
				I.pixel_y = pixel_y[j]
				I.plane = PLANE_SPACE_PARALLAX
				L += I

		parallax_layer.overlays = L
		parallax_layer.parallax_speed = 2
		parallax_layer.plane = PLANE_SPACE_PARALLAX
		calibrate_parallax(parallax_layer,i+1)
		parallax_icon[index] = parallax_layer
		index++

	parallax_initialized = 1

/proc/calibrate_parallax(var/obj/screen/parallax/p_layer,var/i)
	if(!p_layer || !i) return

	/* Placement of screen objects
	1	2	3
	4	5	6
	7	8	9
	*/
	switch(i)
		if(1,4,7)
			p_layer.base_offset_x = -480
		if(3,6,9)
			p_layer.base_offset_x = 480
	switch(i)
		if(1,2,3)
			p_layer.base_offset_y = 480
		if(7,8,9)
			p_layer.base_offset_y = -480

#undef PARALLAX4_ICON_NUMBER
#undef PARALLAX3_ICON_NUMBER
#undef PARALLAX2_ICON_NUMBER