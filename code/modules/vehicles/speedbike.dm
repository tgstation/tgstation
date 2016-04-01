/obj/vehicle/space/speedbike
	name = "Speedbike"
	icon = 'icons/obj/bike.dmi'
	icon_state = "speedbike_blue"
	layer = MOB_LAYER - 0.1
	keytype = null
	vehicle_move_delay = 0
	var/overlay_state = "cover_blue"
	var/image/overlay = null

/obj/vehicle/space/speedbike/New()
	..()
	overlay = image("icons/obj/bike.dmi", overlay_state)
	overlay.layer = MOB_LAYER + 0.1
	overlays += overlay

/obj/effect/overlay/temp/speedbike_trail
	name = "speedbike trails"
	icon_state = "ion_fade"
	layer = MOB_LAYER - 0.2
	duration = 10
	randomdir = 0

/obj/effect/overlay/temp/speedbike_trail/New(loc,move_dir)
	..()
	dir = move_dir

/obj/vehicle/space/speedbike/Move(newloc,move_dir)
	if(buckled_mobs.len)
		PoolOrNew(/obj/effect/overlay/temp/speedbike_trail,list(loc,move_dir))
	. = ..()

/obj/vehicle/space/speedbike/handle_vehicle_layer()
	switch(dir)
		if(NORTH,SOUTH)
			pixel_x = -16
			pixel_y = -16
		if(EAST,WEST)
			pixel_x = -18
			pixel_y = 0

/obj/vehicle/space/speedbike/handle_vehicle_offsets()
	if(buckled_mobs.len)
		for(var/m in buckled_mobs)
			var/mob/living/buckled_mob = m
			buckled_mob.dir = dir
			switch(dir)
				if(NORTH)
					buckled_mob.pixel_x = 0
					buckled_mob.pixel_y = -8
				if(SOUTH)
					buckled_mob.pixel_x = 0
					buckled_mob.pixel_y = 4
				if(EAST)
					buckled_mob.pixel_x = -10
					buckled_mob.pixel_y = 5
				if(WEST)
					buckled_mob.pixel_x = 10
					buckled_mob.pixel_y = 5

/obj/vehicle/space/speedbike/red
	icon_state = "speedbike_red"
	overlay_state = "cover_red"