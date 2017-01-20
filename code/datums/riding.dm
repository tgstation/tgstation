
/datum/riding
	var/generic_pixel_x = 0 //All dirs show this pixel_x for the driver
	var/generic_pixel_y = 0 //All dirs show this pixel_y for the driver, use these vars if the pixel shift is stable across all dir, override handle_vehicle_offsets otherwise.
	var/next_vehicle_move = 0 //used for move delays
	var/vehicle_move_delay = 2 //tick delay between movements, lower = faster, higher = slower
	var/keytype = null
	var/atom/movable/ridden = null

	var/slowed = FALSE
	var/slowvalue = 1

/datum/riding/proc/handle_vehicle_layer()
	if(ridden.dir != NORTH)
		ridden.layer = ABOVE_MOB_LAYER
	else
		ridden.layer = OBJ_LAYER


//Override this to set your vehicle's various pixel offsets
//if they differ between directions, otherwise use the
//generic variables
/datum/riding/proc/handle_vehicle_offsets()
	if(ridden.has_buckled_mobs())
		for(var/m in ridden.buckled_mobs)
			var/mob/living/buckled_mob = m
			buckled_mob.setDir(ridden.dir)
			buckled_mob.pixel_x = generic_pixel_x
			buckled_mob.pixel_y = generic_pixel_y

//KEYS
/datum/riding/proc/keycheck(mob/user)
	if(keytype)
		if(user.is_holding_item_of_type(keytype))
			return TRUE
	else
		return TRUE
	return FALSE


//BUCKLE HOOKS
/datum/riding/proc/restore_position(mob/living/buckled_mob,force = 0)
	if(istype(buckled_mob))
		buckled_mob.pixel_x = 0
		buckled_mob.pixel_y = 0
		if(buckled_mob.client)
			buckled_mob.client.view = world.view






//MOVEMENT
/datum/riding/proc/handle_ride(mob/user, direction)
	if(user.incapacitated())
		ridden.unbuckle_mob(user)
		return

	if(world.time < next_vehicle_move)
		return
	next_vehicle_move = world.time + vehicle_move_delay
	if(keycheck(user))
		if(!Process_Spacemove(direction) || !isturf(ridden.loc))
			return
		step(ridden, direction)

		handle_vehicle_layer()
		handle_vehicle_offsets()
	else
		user << "<span class='notice'>You'll need the keys in one of your hands to drive \the [ridden.name].</span>"

/datum/riding/proc/Process_Spacemove(direction)
	if(ridden.has_gravity())
		return 1

	if(ridden.pulledby)
		return 1

	return 0

/datum/riding/space/Process_Spacemove(direction)
	return 1


//atv
/datum/riding/atv
	keytype = /obj/item/key
	generic_pixel_x = 0
	generic_pixel_y = 4
	vehicle_move_delay = 1

/datum/riding/atv/handle_vehicle_layer()
	if(ridden.dir == SOUTH)
		ridden.layer = ABOVE_MOB_LAYER
	else
		ridden.layer = OBJ_LAYER

/datum/riding/atv/turret
	var/obj/machinery/porta_turret/syndicate/vehicle_turret/turret = null

/datum/riding/atv/turret/handle_vehicle_layer()
	if(ridden.dir == SOUTH)
		ridden.layer = ABOVE_MOB_LAYER
	else
		ridden.layer = OBJ_LAYER

	if(turret)
		if(ridden.dir == NORTH)
			turret.layer = ABOVE_MOB_LAYER
		else
			turret.layer = OBJ_LAYER


/datum/riding/atv/turret/handle_vehicle_offsets()
	..()
	if(turret)
		turret.forceMove(get_turf(ridden))
		switch(ridden.dir)
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


//pimpin ride
/datum/riding/janicart
	keytype = /obj/item/key/janitor


/datum/riding/janicart/handle_vehicle_offsets()
	..()
	if(ridden.has_buckled_mobs())
		for(var/m in ridden.buckled_mobs)
			var/mob/living/buckled_mob = m
			switch(buckled_mob.dir)
				if(NORTH)
					buckled_mob.pixel_x = 0
					buckled_mob.pixel_y = 4
				if(EAST)
					buckled_mob.pixel_x = -12
					buckled_mob.pixel_y = 7
				if(SOUTH)
					buckled_mob.pixel_x = 0
					buckled_mob.pixel_y = 7
				if(WEST)
					buckled_mob.pixel_x = 12
					buckled_mob.pixel_y = 7
//scooter
/datum/riding/scooter/handle_vehicle_layer()
	if(ridden.dir == SOUTH)
		ridden.layer = ABOVE_MOB_LAYER
	else
		ridden.layer = OBJ_LAYER

/datum/riding/scooter/handle_vehicle_offsets()
	..()
	if(ridden.has_buckled_mobs())
		for(var/m in ridden.buckled_mobs)
			var/mob/living/buckled_mob = m
			switch(buckled_mob.dir)
				if(NORTH)
					buckled_mob.pixel_x = 0
				if(EAST)
					buckled_mob.pixel_x = -2
				if(SOUTH)
					buckled_mob.pixel_x = 0
				if(WEST)
					buckled_mob.pixel_x = 2
			if(buckled_mob.get_num_legs() > 0)
				buckled_mob.pixel_y = 5
			else
				buckled_mob.pixel_y = -4

/datum/riding/proc/account_limbs(mob/living/M)
	if(M.get_num_legs() < 2 && !slowed)
		vehicle_move_delay = vehicle_move_delay + slowvalue
		slowed = TRUE
	else if(slowed)
		vehicle_move_delay = vehicle_move_delay - slowvalue
		slowed = FALSE

/datum/riding/scooter/skateboard
	vehicle_move_delay = 0//fast


//secway
/datum/riding/secway
	keytype = /obj/item/key/security
	generic_pixel_x = 0
	generic_pixel_y = 4

//speedbike
/datum/riding/space/speedbike
	keytype = null
	vehicle_move_delay = 0

/datum/riding/space/speedbike/handle_vehicle_layer()
	switch(ridden.dir)
		if(NORTH,SOUTH)
			ridden.pixel_x = -16
			ridden.pixel_y = -16
		if(EAST,WEST)
			ridden.pixel_x = -18
			ridden.pixel_y = 0

/datum/riding/space/speedbike/handle_vehicle_offsets()
	if(ridden.has_buckled_mobs())
		for(var/m in ridden.buckled_mobs)
			var/mob/living/buckled_mob = m
			buckled_mob.setDir(ridden.dir)
			switch(ridden.dir)
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

///////////////BOATS////////////
/datum/riding/boat
	keytype = /obj/item/weapon/oar

/datum/riding/boat/handle_ride(mob/user, direction)
	var/turf/next = get_step(ridden, direction)
	var/turf/current = get_turf(ridden)

	if(istype(next, /turf/open/floor/plating/lava) || istype(current, /turf/open/floor/plating/lava)) //We can move from land to lava, or lava to land, but not from land to land
		..()
	else
		user << "Boats don't go on land!"
		return 0

/datum/riding/boat/dragon
	keytype = null
	generic_pixel_y = 2
	generic_pixel_x = 1
	vehicle_move_delay = 1


///////////////ANIMALS////////////
//general animals
/datum/riding/animal
	keytype = null
	generic_pixel_x = 0
	generic_pixel_y = 4

/datum/riding/animal/handle_ride(mob/user, direction)
	if(user.incapacitated())
		ridden.unbuckle_mob(user)
		return

	if(world.time < next_vehicle_move)
		return

	next_vehicle_move = world.time + vehicle_move_delay
	if(keycheck(user))
		if(!isturf(ridden.loc))
			return
		step(ridden, direction)

		handle_vehicle_layer()
		handle_vehicle_offsets()
	else
		user << "<span class='notice'>You'll need something  to guide the [ridden.name].</span>"