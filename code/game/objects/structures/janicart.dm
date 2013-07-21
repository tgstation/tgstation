/obj/structure/stool/bed/chair/janicart
	name = "janicart"
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "pussywagon"
	anchored = 1
	density = 1
	flags = OPENCONTAINER
	var/inertia_dir = 0
	//copypaste sorry
	var/amount_per_transfer_from_this = 5 //shit I dunno, adding this so syringes stop runtime erroring. --NeoFite
	var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread
	var/obj/item/weapon/storage/bag/trash/mybag	= null
	var/empstun = 0
	var/health = 100
	var/destroyed = 0

/obj/structure/stool/bed/chair/janicart/process()
	if(empstun > 0)
		empstun--
	if(empstun < 0)
		empstun = 0

/obj/structure/stool/bed/chair/janicart/New()
	processing_objects |= src
	handle_rotation()

	var/datum/reagents/R = new/datum/reagents(100)
	reagents = R
	R.my_atom = src


/obj/structure/stool/bed/chair/janicart/examine()
	set src in usr
	usr << "\icon[src] This pimpin' ride contains [reagents.total_volume] unit\s of water!"
	switch(health)
		if(75 to 99)
			usr << "\blue It appears slightly dented."
		if(40 to 74)
			usr << "\red It appears heavily dented."
		if(1 to 39)
			usr << "\red It appears severely dented."
		if((INFINITY * -1) to 0)
			usr << "It appears completely unsalvageable"
	if(mybag)
		usr << "\A [mybag] is hanging on the pimpin' ride."

/obj/structure/stool/bed/chair/janicart/attackby(obj/item/W, mob/user)
	if (istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W
		if (WT.remove_fuel(0))
			if(destroyed)
				user << "\red The [src.name] is destroyed beyond repair."
			add_fingerprint(user)
			user.visible_message("\blue [user] has fixed some of the dents on [src].", "\blue You fix some of the dents on \the [src]")
			health += 20
			HealthCheck()
		else
			user << "Need more welding fuel!"
			return
	if(istype(W, /obj/item/weapon/mop))
		if(reagents.total_volume >= 2)
			reagents.trans_to(W, 2)
			user << "<span class='notice'>You wet the mop in the pimpin' ride.</span>"
			playsound(src.loc, 'sound/effects/slosh.ogg', 25, 1)
		if(reagents.total_volume < 1)
			user << "<span class='notice'>This pimpin' ride is out of water!</span>"
	else if(istype(W, /obj/item/key))
		user << "Hold [W] in one of your hands while you drive this pimpin' ride."
	else if(istype(W, /obj/item/weapon/storage/bag/trash))
		user << "<span class='notice'>You hook the trashbag onto the pimpin' ride.</span>"
		user.drop_item()
		W.loc = src
		mybag = W


/obj/structure/stool/bed/chair/janicart/attack_hand(mob/user)
	if(mybag)
		mybag.loc = get_turf(user)
		user.put_in_hands(mybag)
		mybag = null
	else
		..()


/obj/structure/stool/bed/chair/janicart/relaymove(mob/user, direction)
	if(user.stat || user.stunned || user.weakened || user.paralysis  || destroyed)
		unbuckle()
		return
	if(empstun > 0)
		if(user)
			user << "\red \the [src] is unresponsive."
		return
	if((istype(src.loc, /turf/space)))
		if(!src.Process_Spacemove(0))	return
	if(istype(user.l_hand, /obj/item/key) || istype(user.r_hand, /obj/item/key))
		step(src, direction)
		update_mob()
		handle_rotation()
		/*
		if(istype(src.loc, /turf/space) && (!src.Process_Spacemove(0, user)))
			var/turf/space/S = src.loc
			S.Entered(src)*/
	else
		user << "<span class='notice'>You'll need the keys in one of your hands to drive this pimpin' ride.</span>"

/obj/structure/stool/bed/chair/janicart/proc/Process_Spacemove(var/check_drift = 0, mob/user)
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

/obj/structure/stool/bed/chair/janicart/Move()
	..()
	if(buckled_mob)
		if(buckled_mob.buckled == src)
			buckled_mob.loc = loc

/obj/structure/stool/bed/chair/janicart/buckle_mob(mob/M, mob/user)
	if(M != user || !ismob(M) || get_dist(src, user) > 1 || user.restrained() || user.lying || user.stat || M.buckled || istype(user, /mob/living/silicon) || destroyed)
		return

	unbuckle()

	M.visible_message(\
		"<span class='notice'>[M] climbs onto the pimpin' ride!</span>",\
		"<span class='notice'>You climb onto the pimpin' ride!</span>")
	M.buckled = src
	M.loc = loc
	M.dir = dir
	M.update_canmove()
	buckled_mob = M
	update_mob()
	add_fingerprint(user)
	return

/obj/structure/stool/bed/chair/janicart/unbuckle()
	if(buckled_mob)
		buckled_mob.pixel_x = 0
		buckled_mob.pixel_y = 0
	..()

/obj/structure/stool/bed/chair/janicart/handle_rotation()
	if(dir == SOUTH)
		layer = FLY_LAYER
	else
		layer = OBJ_LAYER

	if(buckled_mob)
		if(buckled_mob.loc != loc)
			buckled_mob.buckled = null //Temporary, so Move() succeeds.
			buckled_mob.buckled = src //Restoring

	update_mob()

/obj/structure/stool/bed/chair/janicart/proc/update_mob()
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

/obj/structure/stool/bed/chair/janicart/emp_act(severity)
	switch(severity)
		if(1)
			src.empstun = (rand(5,10))
		if(2)
			src.empstun = (rand(1,5))
	src.visible_message("\red The [src.name]'s motor short circuits!")
	spark_system.attach(src)
	spark_system.set_up(5, 0, src)
	spark_system.start()

/obj/structure/stool/bed/chair/janicart/bullet_act(var/obj/item/projectile/Proj)
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
				visible_message("<span class='warning'>The [src.name] absorbs the [Proj]")
				if(!istype(buckled_mob, /mob/living/carbon/human))
					return buckled_mob.bullet_act(Proj)
				else
					var/mob/living/carbon/human/H = buckled_mob
					return H.electrocute_act(0, src, 1, 0)
	if(!hitrider)
		visible_message("<span class='warning'>[Proj] hits the pimpin' ride!</span>")
		if(!Proj.nodamage && Proj.damage_type == BRUTE || Proj.damage_type == BURN)
			health -= Proj.damage
		HealthCheck()

/obj/structure/stool/bed/chair/janicart/proc/HealthCheck()
	if(health > 100) health = 100
	if(health <= 0 && !destroyed)
		destroyed = 1
		density = 0
		if(buckled_mob)
			unbuckle()
		visible_message("<span class='warning'>The pimpin' ride explodes!</span>")
		explosion(src.loc,-1,0,2,7,10)

/obj/structure/stool/bed/chair/janicart/ex_act(severity)
	switch (severity)
		if(1.0)
			health -= 100
		if(2.0)
			health -= 75
		if(3.0)
			health -= 45
	HealthCheck()
/obj/item/key
	name = "key"
	desc = "A keyring with a small steel key, and a pink fob reading \"Pussy Wagon\"."
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "keys"
	w_class = 1