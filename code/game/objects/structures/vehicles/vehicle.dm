/obj/item/key
	name = "key"
	desc = "A simple key."
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "keys"
	w_class = 1
	var/obj/structure/bed/chair/vehicle/paired_to = null
	var/vin = null

/obj/item/key/New()
	if(vin)
		for(var/obj/structure/bed/chair/vehicle/V in world)
			if(V.vin == vin)
				paired_to = V
				V.mykey = src


/obj/structure/bed/chair/vehicle
	name = "vehicle"
	var/nick = null
	icon = 'icons/obj/vehicles.dmi'
	anchored = 1
	density = 1
	var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread

	var/empstun = 0
	var/health = 100
	var/max_health = 100
	var/destroyed = 0
	var/inertia_dir = 0

	var/can_spacemove = 0
	var/ethereal = 0

	var/keytype = null
	var/obj/item/key/mykey

	var/vin=null
	var/datum/delay_controller/move_delayer = new(1, ARBITRARILY_LARGE_NUMBER) //See setup.dm, 12
	var/movement_delay = 0 //Speed of the vehicle decreases as this value increases. Anything above 6 is slow, 1 is fast and 0 is very fast

	var/mob/occupant

/obj/structure/bed/chair/vehicle/proc/getMovementDelay()
	return movement_delay

/obj/structure/bed/chair/vehicle/proc/delayNextMove(var/delay, var/additive=0)
	move_delayer.delayNext(delay,additive)

/obj/structure/bed/chair/vehicle/New()
	..()
	processing_objects |= src

	if(!nick)
		nick=name
	if(keytype && !vin)
		mykey = new keytype(src.loc)
		mykey.paired_to=src

/obj/structure/bed/chair/vehicle/process()
	if(empstun > 0)
		empstun--
	if(empstun < 0)
		empstun = 0

/obj/structure/bed/chair/vehicle/buckle_mob(mob/M as mob, mob/user as mob)
	if(isanimal(M)) return //Animals can't buckle

	..()

/obj/structure/bed/chair/vehicle/attackby(obj/item/W, mob/user)
	if (istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W
		if (WT.remove_fuel(0))
			if(destroyed)
				to_chat(user, "<span class='warning'>\The [src.name] is destroyed beyond repair.</span>")
			add_fingerprint(user)
			user.visible_message("<span class='notice'>[user] has fixed some of the dents on \the [src].</span>", "<span class='notice'>You fix some of the dents on \the [src]</span>")
			health += 20
			HealthCheck()
		else
			to_chat(user, "Need more welding fuel!")
			return
	else if(istype(W, /obj/item/key))
		if(keytype)
			to_chat(user, "Hold \the [W] in one of your hands while you drive \the [src].")
		else
			to_chat(user, "You don't need a key.")

/obj/structure/bed/chair/vehicle/proc/check_key(var/mob/user)
	if(!keytype)
		return 1
	if(mykey)
		return user.l_hand == mykey || user.r_hand == mykey
	return 0

/obj/structure/bed/chair/vehicle/relaymove(var/mob/living/user, direction)
	if(user.stat || user.stunned || user.weakened || user.paralysis  || destroyed)
		unlock_atom(user)
		return
	if(!check_key(user))
		to_chat(user, "<span class='notice'>You'll need the keys in one of your hands to drive \the [src].</span>")
		return 0
	if(empstun > 0)
		if(user)
			to_chat(user, "<span class='warning'>\The [src] is unresponsive.</span>")
		return 0
	if(move_delayer.blocked())
		return 0

	//If we're in space or our area has no gravity...
	if(istype(get_turf(src), /turf/space) || (areaMaster && areaMaster.has_gravity == 0))

		// Block relaymove() if needed.
		if(!Process_Spacemove(0))
			return 0

	var/can_pull_tether = 0
	if(user.tether)
		if(user.tether.attempt_to_follow(user,get_step(src,direction)))
			can_pull_tether = 1
		else
			var/datum/chain/tether_datum = user.tether.chain_datum
			tether_datum.snap = 1
			tether_datum.Delete_Chain()
	var/turf/T = loc

	step(src, direction)
	delayNextMove(getMovementDelay())

	if(T != loc)
		user.handle_hookchain(direction)

	if(user.tether && can_pull_tether)
		user.tether.follow(user,T)
		var/datum/chain/tether_datum = user.tether.chain_datum
		if(!tether_datum.Check_Integrity())
			tether_datum.snap = 1
			tether_datum.Delete_Chain()

	update_mob()
	/*
	if(istype(src.loc, /turf/space) && (!src.Process_Spacemove(0, user)))
		var/turf/space/S = src.loc
		S.Entered(src)*/
	return 0

/obj/structure/bed/chair/vehicle/proc/Process_Spacemove(var/check_drift = 0, mob/user)

	if(can_spacemove && occupant)
		return 1

	var/dense_object = 0
	if(!user)
		for(var/turf/turf in oview(1, src))

			if(istype(turf, /turf/space))
				continue

			if(istype(turf, /turf/simulated/floor) && (src.areaMaster && src.areaMaster.has_gravity == 0)) //No gravity
				continue

			dense_object++
			break

		if(!dense_object && (locate(/obj/structure/lattice) in oview(1, src)))
			dense_object++

		if(!dense_object && (locate(/obj/structure/catwalk) in oview(1, src)))
			dense_object++

		//Lastly attempt to locate any dense objects we could push off of
		//TODO: If we implement objects drifing in space this needs to really push them
		//Due to a few issues only anchored and dense objects will now work.
		if(!dense_object)
			for(var/obj/O in oview(1, src))
				if((O) && (O.density) && (O.anchored))
					dense_object++
					break
	else
		for(var/turf/turf in oview(1, user))

			if(istype(turf, /turf/space))
				continue

			if(istype(turf, /turf/simulated/floor) && (src.areaMaster && src.areaMaster.has_gravity == 0)) //No gravity
				continue

			dense_object++
			break

		if(!dense_object && (locate(/obj/structure/lattice) in oview(1, user)))
			dense_object++

		if(!dense_object && (locate(/obj/structure/catwalk) in oview(1, src)))
			dense_object++

		//Lastly attempt to locate any dense objects we could push off of
		//TODO: If we implement objects drifing in space this needs to really push them
		//Due to a few issues only anchored and dense objects will now work.
		if(!dense_object)
			for(var/obj/O in oview(1, user))
				if((O) && (O.density) && (O.anchored))
					dense_object++
					break

	//Nothing to push off of so end here
	if(!dense_object)
		return 0

	//Check to see if we slipped
	if(prob(5))
		to_chat(src, "<span class='bnotice'>You slipped!</span>")
		src.inertia_dir = src.last_move
		step(src, src.inertia_dir)
		return 0
	//If not then we can reset inertia and move
	inertia_dir = 0
	return 1

/obj/structure/bed/chair/vehicle/proc/can_buckle(mob/M, mob/user)
	if(M != user || !ishuman(user) || !Adjacent(user) || user.restrained() || user.lying || user.stat || user.locked_to || destroyed || occupant)
		return 0
	return 1

/obj/structure/bed/chair/vehicle/buckle_mob(mob/M, mob/user)
	if(!can_buckle(M,user))
		return

	M.visible_message(\
		"<span class='notice'>[M] climbs onto \the [nick]!</span>",\
		"<span class='notice'>You climb onto \the [nick]!</span>")

	lock_atom(M)

	add_fingerprint(user)

/obj/structure/bed/chair/vehicle/handle_layer()
	if(dir == SOUTH)
		layer = FLY_LAYER
	else
		layer = OBJ_LAYER

/obj/structure/bed/chair/vehicle/update_dir()
	. = ..()

	update_mob()

/obj/structure/bed/chair/vehicle/proc/update_mob()
	if(!occupant)
		return

	switch(dir)
		if(SOUTH)
			occupant.pixel_x = 0
			occupant.pixel_y = 7
		if(WEST)
			occupant.pixel_x = 13
			occupant.pixel_y = 7
		if(NORTH)
			occupant.pixel_x = 0
			occupant.pixel_y = 4
		if(EAST)
			occupant.pixel_x = -13
			occupant.pixel_y = 7

/obj/structure/bed/chair/vehicle/emp_act(severity)
	switch(severity)
		if(1)
			src.empstun = (rand(5,10))
		if(2)
			src.empstun = (rand(1,5))
	src.visible_message("<span class='danger'>The [src.name]'s motor short circuits!</span>")
	spark_system.attach(src)
	spark_system.set_up(5, 0, src)
	spark_system.start()

/obj/structure/bed/chair/vehicle/bullet_act(var/obj/item/projectile/Proj)
	var/hitrider = 0
	if(istype(Proj, /obj/item/projectile/ion))
		Proj.on_hit(src, 2)
		return

	if(occupant)
		if(prob(75))
			hitrider = 1
			var/act = occupant.bullet_act(Proj)
			if(act >= 0)
				visible_message("<span class='warning'>[occupant] is hit by \the [Proj]!")
				if(istype(Proj, /obj/item/projectile/energy))
					unlock_atom(occupant)
			return
		if(istype(Proj, /obj/item/projectile/energy/electrode))
			if(prob(25))
				visible_message("<span class='warning'>\The [src.name] absorbs \the [Proj]")
				if(!istype(occupant, /mob/living/carbon/human))
					occupant.bullet_act(Proj)
				else
					var/mob/living/carbon/human/H = occupant
					H.electrocute_act(0, src, 1, 0)
				unlock_atom(occupant)

	if(!hitrider)
		visible_message("<span class='warning'>[Proj] hits \the [nick]!</span>")
		if(!Proj.nodamage && Proj.damage_type == BRUTE || Proj.damage_type == BURN)
			health -= Proj.damage
		HealthCheck()

/obj/structure/bed/chair/vehicle/proc/HealthCheck()
	if(health > max_health) health = max_health
	if(health <= 0 && !destroyed)
		die()

/obj/structure/bed/chair/vehicle/ex_act(severity)
	switch (severity)
		if(1.0)
			health -= 100
		if(2.0)
			health -= 75
		if(3.0)
			health -= 45
	HealthCheck()

/obj/structure/bed/chair/vehicle/proc/die() //called when health <= 0
	destroyed = 1
	density = 0
	visible_message("<span class='warning'>\The [nick] explodes!</span>")
	explosion(src.loc,-1,0,2,7,10)
	icon_state = "pussywagon_destroyed"
	unlock_atom(occupant)

/obj/structure/bed/chair/vehicle/Bump(var/atom/movable/obstacle)
	if(obstacle == src || (locked_atoms.len && obstacle == locked_atoms[1]))
		return

	if(istype(obstacle, /obj/structure))// || istype(obstacle, /mob/living)
		if(!obstacle.anchored)
			obstacle.Move(get_step(obstacle,src.dir))
	..()

/obj/structure/bed/chair/vehicle/unlock_atom(var/atom/movable/AM)
	. = ..()
	if(!.)
		return

	AM.pixel_x = 0
	AM.pixel_y = 0

	if(occupant == AM)
		occupant = null

/obj/structure/bed/chair/vehicle/lock_atom(var/atom/movable/AM)
	. = ..()
	if(!.)
		return

	update_mob()

	occupant = AM
