
/obj/vehicle/atv
	name = "all-terrain vehicle"
	desc = "An all-terrain vehicle built for traversing rough terrain with ease. One of the few old-earth technologies that are still relevant on most planet-bound outposts."
	icon_state = "flashlight"
	keytype = /obj/item/key
	generic_pixel_x = 0
	generic_pixel_y = 4
	vehicle_move_delay = 1
	var/static/image/atvcover = null
	//headlight code copypasta'd from the flashlight
	actions_types = list(/datum/action/item_action/toggle_light)
	var/on = 0
	var/brightness_on = 6 //luminosity when on
	
/obj/vehicle/atv/initialize() //this code might be totally broken because i can't test it
	..()
	if(on)
		icon_state = "[initial(icon_state)]-on"
		SetLuminosity(brightness_on)
	else
		icon_state = initial(icon_state)
		SetLuminosity(0)

/obj/vehicle/atv/proc/update_brightness(mob/user = null)
	if(on)
		icon_state = "[initial(icon_state)]-on"
		if(loc == user)
			user.AddLuminosity(brightness_on)
		else if(isturf(loc))
			SetLuminosity(brightness_on)
	else
		icon_state = initial(icon_state)
		if(loc == user)
			user.AddLuminosity(-brightness_on)
		else if(isturf(loc))
			SetLuminosity(0)


/obj/vehicle/atv/New()
	..()
	if(!atvcover)
		atvcover = image("icons/obj/vehicles.dmi", "atvcover")
		atvcover.layer = ABOVE_MOB_LAYER


obj/vehicle/atv/post_buckle_mob(mob/living/M)
	if(has_buckled_mobs())
		add_overlay(atvcover)
	else
		overlays -= atvcover


/obj/vehicle/atv/handle_vehicle_layer()
	if(dir == SOUTH)
		layer = ABOVE_MOB_LAYER
	else
		layer = OBJ_LAYER


//TURRETS!
/obj/vehicle/atv/turret
	var/obj/machinery/porta_turret/syndicate/vehicle_turret/turret = null


/obj/machinery/porta_turret/syndicate/vehicle_turret
	name = "mounted turret"
	scan_range = 7
	emp_vunerable = 1
	density = 0


/obj/vehicle/atv/turret/New()
	..()
	turret = new(loc)
	turret.base = src


/obj/vehicle/atv/turret/handle_vehicle_layer()
	if(dir == SOUTH)
		layer = ABOVE_MOB_LAYER
	else
		layer = OBJ_LAYER

	if(turret)
		if(dir == NORTH)
			turret.layer = ABOVE_MOB_LAYER
		else
			turret.layer = OBJ_LAYER


/obj/vehicle/atv/turret/handle_vehicle_offsets()
	..()
	if(turret)
		turret.loc = loc
		switch(dir)
			if(NORTH)
				turret.pixel_x = 0
				turret.pixel_y = 4
			if(EAST)
				turret.pixel_x = -12
				turret.pixel_y = 4
			if(SOUTH)
				turret.pixel_x = 0
				turret.pixel_y = 4
			if(WEST)
				turret.pixel_x = 12
				turret.pixel_y = 4

