/obj/item/key
	name = "key"
	desc = "A simple key."
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "keys"
	w_class = 1
	var/obj/structure/stool/bed/chair/vehicle/paired_to=null
	var/vin = null

	New()
		if(vin)
			for(var/obj/structure/stool/bed/chair/vehicle/V in world)
				if(V.vin == vin)
					paired_to=V
					V.mykey=src


/obj/structure/stool/bed/chair/vehicle
	name = "vehicle"
	var/nick = null
	icon = 'icons/obj/vehicles.dmi'
	anchored = 1
	density = 1
	var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread

	var/empstun = 0
	var/health = 100
	var/destroyed = 0
	var/inertia_dir = 0

	var/can_spacemove = 0
	var/ethereal = 0

	var/keytype=null
	var/obj/item/key/mykey

	var/vin=null

/obj/structure/stool/bed/chair/vehicle/New()
	processing_objects |= src
	handle_rotation()

	if(!nick)
		nick=name
	if(keytype && !vin)
		mykey = new keytype(src.loc)
		mykey.paired_to=src

/obj/structure/stool/bed/chair/vehicle/process()
	if(empstun > 0)
		empstun--
	if(empstun < 0)
		empstun = 0

/obj/structure/stool/bed/chair/vehicle/attackby(obj/item/W, mob/user)
	if (istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W
		if (WT.remove_fuel(0))
			if(destroyed)
				user << "\red \The [src.name] is destroyed beyond repair."
			add_fingerprint(user)
			user.visible_message("\blue [user] has fixed some of the dents on \the [src].", "\blue You fix some of the dents on \the [src]")
			health += 20
			HealthCheck()
		else
			user << "Need more welding fuel!"
			return
	else if(istype(W, /obj/item/key))
		if(keytype)
			user << "Hold \the [W] in one of your hands while you drive \the [src]."
		else
			user << "You don't need a key."

/obj/structure/stool/bed/chair/vehicle/proc/check_key(var/mob/user)
	if(!keytype)
		return 1
	if(mykey)
		return user.l_hand == mykey || user.r_hand == mykey
	return 0

/obj/structure/stool/bed/chair/vehicle/relaymove(var/mob/user, direction)
	if(user.stat || user.stunned || user.weakened || user.paralysis  || destroyed)
		unbuckle()
		return
	if(!check_key(user))
		user << "<span class='notice'>You'll need the keys in one of your hands to drive \the [src].</span>"
		return
	if(empstun > 0)
		if(user)
			user << "\red \the [src] is unresponsive."
		return
	if(istype(src.loc, /turf/space))
		if(!src.Process_Spacemove(0))	return
	step(src, direction)
	update_mob()
	handle_rotation()
	/*
	if(istype(src.loc, /turf/space) && (!src.Process_Spacemove(0, user)))
		var/turf/space/S = src.loc
		S.Entered(src)*/

/obj/structure/stool/bed/chair/vehicle/proc/Process_Spacemove(var/check_drift = 0, mob/user)
	if(can_spacemove && buckled_mob)
		return 1
	//First check to see if we can do things

	/*
	if(istype(src,/mob/living/carbon))
		if(src.l_hand && src.r_hand)
			return 0
	*/

	var/dense_object = 0
	if(!user)
		for(var/turf/turf in oview(1,src))
			if(istype(turf,/turf/space))
				continue
			/*
			if((istype(turf,/turf/simulated/floor))
				if(user)
					if(user.lastarea.has_gravity == 0)
						continue*/



		/*
		if(istype(turf,/turf/simulated/floor) && (src.flags & NOGRAV))
			continue
		*/


			dense_object++
			break

		if(!dense_object && (locate(/obj/structure/lattice) in oview(1, src)))
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
		for(var/turf/turf in oview(1,user))
			if(istype(turf,/turf/space))
				continue
			/*
			if((istype(turf,/turf/simulated/floor))
				if(user)
					if(user.lastarea.has_gravity == 0)
						continue*/



		/*
		if(istype(turf,/turf/simulated/floor) && (src.flags & NOGRAV))
			continue
		*/


			dense_object++
			break

		if(!dense_object && (locate(/obj/structure/lattice) in oview(1, user)))
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


/* The cart has very grippy tires and or magnets to keep it from slipping when on a good surface
	//Check to see if we slipped
	if(prob(Process_Spaceslipping(5)))
		src << "\blue <B>You slipped!</B>"
		src.inertia_dir = src.last_move
		step(src, src.inertia_dir)
		return 0
	//If not then we can reset inertia and move
	*/
	inertia_dir = 0
	return 1

/obj/structure/stool/bed/chair/vehicle/Move()
	..()
	if(buckled_mob)
		if(buckled_mob.buckled == src)
			buckled_mob.loc = loc

/obj/structure/stool/bed/chair/vehicle/buckle_mob(mob/M, mob/user)
	if(M != user || !ismob(M) || get_dist(src, user) > 1 || user.restrained() || user.lying || user.stat || M.buckled || istype(user, /mob/living/silicon) || destroyed)
		return

	if(!check_key(M))
		M << "\red You don't have the key for this."
		return

	unbuckle()

	M.visible_message(\
		"<span class='notice'>[M] climbs onto \the [nick]!</span>",\
		"<span class='notice'>You climb onto \the [nick]!</span>")
	M.buckled = src
	M.loc = loc
	M.dir = dir
	M.update_canmove()
	buckled_mob = M
	update_mob()
	add_fingerprint(user)
	return

/obj/structure/stool/bed/chair/vehicle/unbuckle()
	if(buckled_mob)
		buckled_mob.pixel_x = 0
		buckled_mob.pixel_y = 0
	..()

/obj/structure/stool/bed/chair/vehicle/handle_rotation()
	if(dir == SOUTH)
		layer = FLY_LAYER
	else
		layer = OBJ_LAYER

	if(buckled_mob)
		if(buckled_mob.loc != loc)
			buckled_mob.buckled = null //Temporary, so Move() succeeds.
			buckled_mob.buckled = src //Restoring

	update_mob()

/obj/structure/stool/bed/chair/vehicle/proc/update_mob()
	if(buckled_mob)
		buckled_mob.dir = dir
		switch(dir)
			if(SOUTH)
				buckled_mob.pixel_x = 0
				buckled_mob.pixel_y = 7
			if(WEST)
				buckled_mob.pixel_x = 13
				buckled_mob.pixel_y = 7
			if(NORTH)
				buckled_mob.pixel_x = 0
				buckled_mob.pixel_y = 4
			if(EAST)
				buckled_mob.pixel_x = -13
				buckled_mob.pixel_y = 7

/obj/structure/stool/bed/chair/vehicle/emp_act(severity)
	switch(severity)
		if(1)
			src.empstun = (rand(5,10))
		if(2)
			src.empstun = (rand(1,5))
	src.visible_message("\red The [src.name]'s motor short circuits!")
	spark_system.attach(src)
	spark_system.set_up(5, 0, src)
	spark_system.start()

/obj/structure/stool/bed/chair/vehicle/bullet_act(var/obj/item/projectile/Proj)
	var/hitrider = 0
	if(istype(Proj, /obj/item/projectile/ion))
		Proj.on_hit(src, 2)
		return
	if(buckled_mob)
		if(prob(75))
			hitrider = 1
			var/act = buckled_mob.bullet_act(Proj)
			if(act >= 0)
				visible_message("<span class='warning'>[buckled_mob.name] is hit by [Proj]!")
				if(istype(Proj, /obj/item/projectile/energy))
					unbuckle()
			return
		if(istype(Proj, /obj/item/projectile/energy/electrode))
			if(prob(25))
				unbuckle()
				visible_message("<span class='warning'>\The [src.name] absorbs the [Proj]")
				if(!istype(buckled_mob, /mob/living/carbon/human))
					return buckled_mob.bullet_act(Proj)
				else
					var/mob/living/carbon/human/H = buckled_mob
					return H.electrocute_act(0, src, 1, 0)
	if(!hitrider)
		visible_message("<span class='warning'>[Proj] hits \the [nick]!</span>")
		if(!Proj.nodamage && Proj.damage_type == BRUTE || Proj.damage_type == BURN)
			health -= Proj.damage
		HealthCheck()

/obj/structure/stool/bed/chair/vehicle/proc/HealthCheck()
	if(health > 100) health = 100
	if(health <= 0 && !destroyed)
		die()

/obj/structure/stool/bed/chair/vehicle/ex_act(severity)
	switch (severity)
		if(1.0)
			health -= 100
		if(2.0)
			health -= 75
		if(3.0)
			health -= 45
	HealthCheck()

/obj/structure/stool/bed/chair/vehicle/proc/die() //called when health <= 0
	destroyed = 1
	density = 0
	if(buckled_mob)
		unbuckle()
	visible_message("<span class='warning'>\The [nick] explodes!</span>")
	explosion(src.loc,-1,0,2,7,10)
	icon_state = "pussywagon_destroyed"