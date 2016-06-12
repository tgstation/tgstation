/obj/vehicle/space/speedbike
	name = "Speedbike"
	icon = 'icons/obj/bike.dmi'
	icon_state = "speedbike_blue"
	layer = LYING_MOB_LAYER
	keytype = null
	vehicle_move_delay = 0
	var/overlay_state = "cover_blue"
	var/image/overlay = null

/obj/vehicle/space/speedbike/New()
	..()
	overlay = image("icons/obj/bike.dmi", overlay_state)
	overlay.layer = ABOVE_MOB_LAYER
	overlays += overlay

/obj/effect/overlay/temp/speedbike_trail
	name = "speedbike trails"
	icon_state = "ion_fade"
	layer = BELOW_MOB_LAYER
	duration = 10
	randomdir = 0

/obj/effect/overlay/temp/speedbike_trail/New(loc,move_dir)
	..()
	setDir(move_dir)

/obj/vehicle/space/speedbike/Move(newloc,move_dir)
	if(has_buckled_mobs())
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
	if(has_buckled_mobs())
		for(var/m in buckled_mobs)
			var/mob/living/buckled_mob = m
			buckled_mob.setDir(dir)
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