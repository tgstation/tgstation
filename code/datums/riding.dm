/datum/riding
	var/generic_pixel_x = 0 //All dirs show this pixel_x for the driver
	var/generic_pixel_y = 0 //All dirs show this pixel_y for the driver, use these vars if the pixel shift is stable across all dir, override handle_vehicle_offsets otherwise.
	var/next_vehicle_move = 0 //used for move delays
	var/vehicle_move_delay = 2 //tick delay between movements, lower = faster, higher = slower
	var/keytype = null
	var/atom/movable/ridden = null

	var/slowed = FALSE
	var/slowvalue = 1

/datum/riding/New(atom/movable/_ridden)
	ridden = _ridden

/datum/riding/Destroy()
	ridden = null
	return ..()

/datum/riding/proc/handle_vehicle_layer()
	if(ridden.dir != NORTH)
		ridden.layer = ABOVE_MOB_LAYER
	else
		ridden.layer = OBJ_LAYER

/datum/riding/proc/on_vehicle_move()
	for(var/mob/living/M in ridden.buckled_mobs)
		ride_check(M)
	handle_vehicle_offsets()
	handle_vehicle_layer()

/datum/riding/proc/ride_check(mob/living/M)
	return TRUE

/datum/riding/proc/force_dismount(mob/living/M)
	ridden.unbuckle_mob(M)

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
/datum/riding/proc/restore_position(mob/living/buckled_mob)
	if(istype(buckled_mob))
		buckled_mob.pixel_x = 0
		buckled_mob.pixel_y = 0
		if(buckled_mob.client)
			buckled_mob.client.change_view(world.view)

//MOVEMENT
/datum/riding/proc/handle_ride(mob/user, direction)
	if(user.incapacitated())
		Unbuckle(user)
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
		to_chat(user, "<span class='notice'>You'll need the keys in one of your hands to drive \the [ridden.name].</span>")

/datum/riding/proc/Unbuckle(atom/movable/M)
	addtimer(CALLBACK(ridden, /atom/movable/.proc/unbuckle_mob, M), 0, TIMER_UNIQUE)

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

//i want to ride my
/datum/riding/bicycle
	keytype = null
	generic_pixel_x = 0
	generic_pixel_y = 4
	vehicle_move_delay = 0

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

//SPEEDUWAGON

/datum/riding/space/speedwagon
	vehicle_move_delay = 0

/datum/riding/space/speedwagon/handle_vehicle_offsets()
	if(ridden.has_buckled_mobs())
		for(var/m in ridden.buckled_mobs)
			var/mob/living/buckled_mob = m
			buckled_mob.setDir(ridden.dir)
			ridden.pixel_x = -48
			ridden.pixel_y = -48
			switch(ridden.dir)
				if(NORTH)
					buckled_mob.pixel_x = -10
					buckled_mob.pixel_y = -3
				if(SOUTH)
					buckled_mob.pixel_x = 16
					buckled_mob.pixel_y = 3
				if(EAST)
					buckled_mob.pixel_x = -4
					buckled_mob.pixel_y = 30
				if(WEST)
					buckled_mob.pixel_x = 4
					buckled_mob.pixel_y = -1

/datum/riding/space/speedwagon/handle_vehicle_layer()
	ridden.layer = BELOW_MOB_LAYER

///////////////BOATS////////////
/datum/riding/boat
	keytype = /obj/item/weapon/oar

/datum/riding/boat/handle_ride(mob/user, direction)
	var/turf/next = get_step(ridden, direction)
	var/turf/current = get_turf(ridden)

	if(istype(next, /turf/open/floor/plating/lava) || istype(current, /turf/open/floor/plating/lava)) //We can move from land to lava, or lava to land, but not from land to land
		..()
	else
		to_chat(user, "Boats don't go on land!")
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
		Unbuckle(user)
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
		to_chat(user, "<span class='notice'>You'll need something  to guide the [ridden.name].</span>")

///////Humans. Yes, I said humans. No, this won't end well...//////////
/datum/riding/human
	keytype = null

/datum/riding/human/ride_check(mob/living/M)
	var/mob/living/carbon/human/H = ridden	//IF this runtimes I'm blaming the admins.
	if(M.incapacitated(FALSE, TRUE) || H.incapacitated(FALSE, TRUE))
		M.visible_message("<span class='warning'>[M] falls off [ridden]!</span>")
		Unbuckle(M)
		return FALSE
	if(M.restrained(TRUE))
		M.visible_message("<span class='warning'>[M] can't hang onto [ridden] with their hands cuffed!</span>")	//Honestly this should put the ridden mob in a chokehold.
		Unbuckle(M)
		return FALSE
	if(H.pulling == M)
		H.stop_pulling()

/datum/riding/human/handle_vehicle_offsets()
	for(var/mob/living/M in ridden.buckled_mobs)
		M.setDir(ridden.dir)
		switch(ridden.dir)
			if(NORTH)
				M.pixel_x = 0
				M.pixel_y = 6
			if(SOUTH)
				M.pixel_x = 0
				M.pixel_y = 6
			if(EAST)
				M.pixel_x = -6
				M.pixel_y = 4
			if(WEST)
				M.pixel_x = 6
				M.pixel_y = 4

/datum/riding/human/handle_vehicle_layer()
	if(ridden.buckled_mobs && ridden.buckled_mobs.len)
		if(ridden.dir == SOUTH)
			ridden.layer = ABOVE_MOB_LAYER
		else
			ridden.layer = OBJ_LAYER
	else
		ridden.layer = MOB_LAYER

/datum/riding/human/force_dismount(mob/living/user)
	ridden.unbuckle_mob(user)
	user.Weaken(3)
	user.Stun(3)
	user.visible_message("<span class='warning'>[ridden] pushes [user] off of them!</span>")

/datum/riding/cyborg
	keytype = null

/datum/riding/cyborg/ride_check(mob/user)
	if(user.incapacitated())
		var/kick = TRUE
		if(istype(ridden, /mob/living/silicon/robot))
			var/mob/living/silicon/robot/R = ridden
			if(R.module && R.module.ride_allow_incapacitated)
				kick = FALSE
		if(kick)
			to_chat(user, "<span class='userdanger'>You fall off of [ridden]!</span>")
			Unbuckle(user)
			return
	if(istype(user, /mob/living/carbon))
		var/mob/living/carbon/carbonuser = user
		if(!carbonuser.get_num_arms())
			Unbuckle(user)
			to_chat(user, "<span class='userdanger'>You can't grab onto [ridden] with no hands!</span>")
			return

/datum/riding/cyborg/handle_vehicle_layer()
	if(ridden.buckled_mobs && ridden.buckled_mobs.len)
		if(ridden.dir == SOUTH)
			ridden.layer = ABOVE_MOB_LAYER
		else
			ridden.layer = OBJ_LAYER
	else
		ridden.layer = MOB_LAYER

/datum/riding/cyborg/handle_vehicle_offsets()
	if(ridden.has_buckled_mobs())
		for(var/mob/living/M in ridden.buckled_mobs)
			M.setDir(ridden.dir)
			if(iscyborg(ridden))
				var/mob/living/silicon/robot/R = ridden
				if(istype(R.module))
					M.pixel_x = R.module.ride_offset_x[dir2text(ridden.dir)]
					M.pixel_y = R.module.ride_offset_y[dir2text(ridden.dir)]
			else
				switch(ridden.dir)
					if(NORTH)
						M.pixel_x = 0
						M.pixel_y = 4
					if(SOUTH)
						M.pixel_x = 0
						M.pixel_y = 4
					if(EAST)
						M.pixel_x = -6
						M.pixel_y = 3
					if(WEST)
						M.pixel_x = 6
						M.pixel_y = 3

/datum/riding/cyborg/force_dismount(mob/living/M)
	ridden.unbuckle_mob(M)
	var/turf/target = get_edge_target_turf(ridden, ridden.dir)
	var/turf/targetm = get_step(get_turf(ridden), ridden.dir)
	M.Move(targetm)
	M.visible_message("<span class='warning'>[M] is thrown clear of [ridden]!</span>")
	M.throw_at(target, 14, 5, ridden)
	M.Weaken(3)

/datum/riding/proc/equip_buckle_inhands(mob/living/carbon/human/user, amount_required = 1)
	var/amount_equipped = 0
	for(var/amount_needed = amount_required, amount_needed > 0, amount_needed--)
		var/obj/item/riding_offhand/inhand = new /obj/item/riding_offhand(user)
		inhand.rider = user
		inhand.ridden = ridden
		if(user.put_in_hands(inhand, TRUE))
			amount_equipped++
		else
			break
	if(amount_equipped >= amount_required)
		return TRUE
	else
		unequip_buckle_inhands(user)
		return FALSE

/datum/riding/proc/unequip_buckle_inhands(mob/living/carbon/user)
	for(var/obj/item/riding_offhand/O in user.contents)
		if(O.ridden != ridden)
			CRASH("RIDING OFFHAND ON WRONG MOB")
			continue
		if(O.selfdeleting)
			continue
		else
			qdel(O)
	return TRUE

/obj/item/riding_offhand
	name = "offhand"
	icon = 'icons/obj/weapons.dmi'
	icon_state = "offhand"
	w_class = WEIGHT_CLASS_HUGE
	flags = ABSTRACT | DROPDEL | NOBLUDGEON
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	var/mob/living/carbon/rider
	var/mob/living/ridden
	var/selfdeleting = FALSE

/obj/item/riding_offhand/dropped()
	selfdeleting = TRUE
	. = ..()

/obj/item/riding_offhand/equipped()
	if(loc != rider)
		selfdeleting = TRUE
		qdel(src)
	. = ..()

/obj/item/riding_offhand/Destroy()
	if(selfdeleting)
		if(rider in ridden.buckled_mobs)
			ridden.unbuckle_mob(rider)
	. = ..()
