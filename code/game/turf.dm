/turf/DblClick()
	if(istype(usr, /mob/living/silicon/ai))
		return move_camera_by_click()
	if(usr.stat || usr.restrained() || usr.lying)
		return ..()

	if(usr.hand && istype(usr.l_hand, /obj/item/weapon/flamethrower))
		var/turflist = getline(usr,src)
		var/obj/item/weapon/flamethrower/F = usr.l_hand
		F.flame_turf(turflist)
	else if(!usr.hand && istype(usr.r_hand, /obj/item/weapon/flamethrower))
		var/turflist = getline(usr,src)
		var/obj/item/weapon/flamethrower/F = usr.r_hand
		F.flame_turf(turflist)

	return ..()

/turf/New()
	..()
	for(var/atom/movable/AM as mob|obj in src)
		spawn( 0 )
			src.Entered(AM)
			return
	return

/turf/ex_act(severity)
	return 0


/turf/bullet_act(var/obj/item/projectile/Proj)
	if(istype(Proj ,/obj/item/projectile/beam/pulse))
		src.ex_act(2)
	..()
	return 0

/turf/bullet_act(var/obj/item/projectile/Proj)
	if(istype(Proj ,/obj/item/projectile/bullet/gyro))
		explosion(src, -1, 0, 2)
	..()
	return 0

/turf/Enter(atom/movable/mover as mob|obj, atom/forget as mob|obj|turf|area)
	if (!mover || !isturf(mover.loc))
		return 1


	//First, check objects to block exit that are not on the border
	for(var/obj/obstacle in mover.loc)
		if((obstacle.flags & ~ON_BORDER) && (mover != obstacle) && (forget != obstacle))
			if(!obstacle.CheckExit(mover, src))
				mover.Bump(obstacle, 1)
				return 0

	//Now, check objects to block exit that are on the border
	for(var/obj/border_obstacle in mover.loc)
		if((border_obstacle.flags & ON_BORDER) && (mover != border_obstacle) && (forget != border_obstacle))
			if(!border_obstacle.CheckExit(mover, src))
				mover.Bump(border_obstacle, 1)
				return 0

	//Next, check objects to block entry that are on the border
	for(var/obj/border_obstacle in src)
		if(border_obstacle.flags & ON_BORDER)
			if(!border_obstacle.CanPass(mover, mover.loc, 1, 0) && (forget != border_obstacle))
				mover.Bump(border_obstacle, 1)
				return 0

	//Then, check the turf itself
	if (!src.CanPass(mover, src))
		mover.Bump(src, 1)
		return 0

	//Finally, check objects/mobs to block entry that are not on the border
	for(var/atom/movable/obstacle in src)
		if(obstacle.flags & ~ON_BORDER)
			if(!obstacle.CanPass(mover, mover.loc, 1, 0) && (forget != obstacle))
				mover.Bump(obstacle, 1)
				return 0
	return 1 //Nothing found to block so return success!


/turf/Entered(atom/movable/M as mob|obj)
	var/loopsanity = 100
	if(ismob(M))
		if(!M:lastarea)
			M:lastarea = get_area(M.loc)
		if(M:lastarea.has_gravity == 0)
			inertial_drift(M)

	/*
		if(M.flags & NOGRAV)
			inertial_drift(M)
	*/



		else if(!istype(src, /turf/space))
			M:inertia_dir = 0
	..()
	var/objects = 0
	for(var/atom/A as mob|obj|turf|area in src)
		if(objects > loopsanity)	break
		objects++
		spawn( 0 )
			if ((A && M))
				A.HasEntered(M, 1)
			return
	objects = 0
	for(var/atom/A as mob|obj|turf|area in range(1))
		if(objects > loopsanity)	break
		objects++
		spawn( 0 )
			if ((A && M))
				A.HasProximity(M, 1)
			return
	return

/turf/proc/inertial_drift(atom/movable/A as mob|obj)
	if(!(A.last_move))	return
	if((istype(A, /mob/) && src.x > 2 && src.x < (world.maxx - 1) && src.y > 2 && src.y < (world.maxy-1)))
		var/mob/M = A
		if(M.Process_Spacemove(1))
			M.inertia_dir  = 0
			return
		spawn(5)
			if((M && !(M.anchored) && (M.loc == src)))
				if(M.inertia_dir)
					step(M, M.inertia_dir)
					return
				M.inertia_dir = M.last_move
				step(M, M.inertia_dir)
	return

/turf/proc/levelupdate()
	for(var/obj/O in src)
		if(O.level == 1)
			O.hide(src.intact)

// override for space turfs, since they should never hide anything
/turf/space/levelupdate()
	for(var/obj/O in src)
		if(O.level == 1)
			O.hide(0)

// Removes all signs of lattice on the pos of the turf -Donkieyo
/turf/proc/RemoveLattice()
	var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
	if(L)
		del L

/turf/proc/ReplaceWithFloor(explode=0)
	var/prior_icon = icon_old
	var/old_dir = dir
	var/aoxy = 0//Holders to assimilate air from nearby turfs
	var/anitro = 0
	var/aco = 0
	var/atox = 0
	var/atemp = 0

	var/turf/simulated/floor/W = new /turf/simulated/floor( locate(src.x, src.y, src.z) )

	for(var/direction in cardinal)
		var/turf/T = get_step(src,direction)
		if(istype(T,/turf/space))
			continue
		else if(istype(T,/turf/simulated))
			var/turf/simulated/S = T
			if(S.air)
				aoxy += S.air.oxygen
				anitro += S.air.nitrogen
				aco += S.air.carbon_dioxide
				atox += S.air.toxins
				atemp += S.air.temperature
	W.air.oxygen = (aoxy/4)
	W.air.nitrogen = (anitro/4)
	W.air.carbon_dioxide = (aco/4)
	W.air.toxins = (atox/4)
	W.air.temperature = (atemp/4)

	W.RemoveLattice()
	W.dir = old_dir
	if(prior_icon) W.icon_state = prior_icon
	else W.icon_state = "floor"

	if (!explode)
		W.opacity = 1
		W.sd_SetOpacity(0)
		//This is probably gonna make lighting go a bit wonky in bombed areas, but sd_SetOpacity was the primary reason bombs have been so laggy. --NEO
	W.levelupdate()
	return W

/turf/proc/ReplaceWithPlating()
	var/prior_icon = icon_old
	var/old_dir = dir
	var/aoxy = 0//Holders to assimilate air from nearby turfs
	var/anitro = 0
	var/aco = 0
	var/atox = 0
	var/atemp = 0

	var/turf/simulated/floor/plating/W = new /turf/simulated/floor/plating( locate(src.x, src.y, src.z) )
	for(var/direction in cardinal)
		var/turf/T = get_step(src,direction)
		if(istype(T,/turf/space))
			continue
		else if(istype(T,/turf/simulated))
			var/turf/simulated/S = T
			if(S.air)
				aoxy += S.air.oxygen
				anitro += S.air.nitrogen
				aco += S.air.carbon_dioxide
				atox += S.air.toxins
				atemp += S.air.temperature
	W.air.oxygen = (aoxy/4)
	W.air.oxygen = (aoxy/4)
	W.air.nitrogen = (anitro/4)
	W.air.carbon_dioxide = (aco/4)
	W.air.toxins = (atox/4)
	W.air.temperature = (atemp/4)

	W.RemoveLattice()
	W.dir = old_dir
	if(prior_icon) W.icon_state = prior_icon
	else W.icon_state = "plating"
	W.opacity = 1
	W.sd_SetOpacity(0)
	W.levelupdate()
	return W

/turf/proc/ReplaceWithEngineFloor()
	var/old_dir = dir

	var/turf/simulated/floor/engine/E = new /turf/simulated/floor/engine( locate(src.x, src.y, src.z) )

	E.dir = old_dir
	E.icon_state = "engine"

/turf/simulated/Entered(atom/A, atom/OL)
	if (istype(A,/mob/living/carbon))
		var/mob/living/carbon/M = A
		if(M.lying)	return
		if(istype(M, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = M
			if(istype(H.shoes, /obj/item/clothing/shoes/clown_shoes))
				if(H.m_intent == "run")
					if(H.footstep >= 2)
						H.footstep = 0
					else
						H.footstep++
					if(H.footstep == 0)
						playsound(src, "clownstep", 50, 1) // this will get annoying very fast.
				else
					playsound(src, "clownstep", 20, 1)

		switch (src.wet)
			if(1)
				if(istype(M, /mob/living/carbon/human)) // Added check since monkeys don't have shoes
					if ((M.m_intent == "run") && !(istype(M:shoes, /obj/item/clothing/shoes) && M:shoes.flags&NOSLIP))
						M.stop_pulling()
						step(M, M.dir)
						M << "\blue You slipped on the wet floor!"
						playsound(src.loc, 'slip.ogg', 50, 1, -3)
						M.Stun(8)
						M.Weaken(5)
					else
						M.inertia_dir = 0
						return
				else if(!istype(M, /mob/living/carbon/metroid))
					if (M.m_intent == "run")
						M.stop_pulling()
						step(M, M.dir)
						M << "\blue You slipped on the wet floor!"
						playsound(src.loc, 'slip.ogg', 50, 1, -3)
						M.Stun(8)
						M.Weaken(5)
					else
						M.inertia_dir = 0
						return

			if(2) //lube
				if(!istype(M, /mob/living/carbon/metroid))
					M.stop_pulling()
					step(M, M.dir)
					spawn(1) step(M, M.dir)
					spawn(2) step(M, M.dir)
					spawn(3) step(M, M.dir)
					spawn(4) step(M, M.dir)
					M.take_organ_damage(2) // Was 5 -- TLE
					M << "\blue You slipped on the floor!"
					playsound(src.loc, 'slip.ogg', 50, 1, -3)
					M.Weaken(10)

	..()

/turf/proc/ReplaceWithSpace()
	var/old_dir = dir
	var/turf/space/S = new /turf/space( locate(src.x, src.y, src.z) )
	S.dir = old_dir
	return S

/turf/proc/ReplaceWithLattice()
	var/old_dir = dir
	var/turf/space/S = new /turf/space( locate(src.x, src.y, src.z) )
	S.dir = old_dir
	S.sd_LumReset()
	new /obj/structure/lattice( locate(src.x, src.y, src.z) )
	return S

/turf/proc/ReplaceWithWall()
	var/old_icon = icon_state
	var/turf/simulated/wall/S = new /turf/simulated/wall( locate(src.x, src.y, src.z) )
	S.icon_old = old_icon
	S.opacity = 0
	S.sd_NewOpacity(1)
	S.sd_LumReset()
	return S

/turf/proc/ReplaceWithRWall()
	var/old_icon = icon_state
	var/turf/simulated/wall/r_wall/S = new /turf/simulated/wall/r_wall( locate(src.x, src.y, src.z) )
	S.icon_old = old_icon
	S.opacity = 0
	S.sd_NewOpacity(1)
	S.sd_LumReset()
	return S

/turf/proc/ReplaceWithMineralWall(var/ore)
	var/old_icon = icon_state
	var/turf/simulated/wall/mineral/S = new /turf/simulated/wall/mineral( locate(src.x, src.y, src.z) )
	S.icon_old = old_icon
	S.opacity = 0
	S.sd_NewOpacity(1)
	S.mineral = ore
	S.New()//Hackish as fuck, but what can you do? -Sieve
	S.sd_LumReset()
	return S

//turf/simulated/wall/New()
//	..()

/turf/simulated/wall/proc/dismantle_wall(devastated=0, explode=0)
	if(istype(src,/turf/simulated/wall/r_wall))
		if(!devastated)
			playsound(src.loc, 'Welder.ogg', 100, 1)
			new /obj/structure/girder/reinforced(src)
			new /obj/item/stack/sheet/plasteel( src )
		else
			new /obj/item/stack/sheet/metal( src )
			new /obj/item/stack/sheet/metal( src )
			new /obj/item/stack/sheet/plasteel( src )
	else if(istype(src,/turf/simulated/wall/cult))
		if(!devastated)
			playsound(src.loc, 'Welder.ogg', 100, 1)
			new /obj/effect/decal/cleanable/blood(src)
			new /obj/structure/cultgirder(src)
		else
			new /obj/effect/decal/cleanable/blood(src)
			new /obj/effect/decal/remains/human(src)

	else
		if(!devastated)
			playsound(src.loc, 'Welder.ogg', 100, 1)
			switch(mineral)
				if("metal")
					new /obj/structure/girder(src)
					new /obj/item/stack/sheet/metal( src )
					new /obj/item/stack/sheet/metal( src )
				if("gold")
					new /obj/structure/girder(src)
					new /obj/item/stack/sheet/gold( src )
					new /obj/item/stack/sheet/gold( src )
				if("silver")
					new /obj/structure/girder(src)
					new /obj/item/stack/sheet/silver( src )
					new /obj/item/stack/sheet/silver( src )
				if("diamond")
					new /obj/structure/girder(src)
					new /obj/item/stack/sheet/diamond( src )
					new /obj/item/stack/sheet/diamond( src )
				if("uranium")
					new /obj/structure/girder(src)
					new /obj/item/stack/sheet/uranium( src )
					new /obj/item/stack/sheet/uranium( src )
				if("plasma")
					new /obj/structure/girder(src)
					new /obj/item/stack/sheet/plasma( src )
					new /obj/item/stack/sheet/plasma( src )
				if("clown")
					new /obj/structure/girder(src)
					new /obj/item/stack/sheet/clown( src )
					new /obj/item/stack/sheet/clown( src )
				if("sandstone")
					new /obj/structure/girder(src)
					new /obj/item/stack/sheet/sandstone( src )
					new /obj/item/stack/sheet/sandstone( src )
				if("wood")
					new /obj/structure/girder(src)
					new /obj/item/stack/sheet/wood( src )
					new /obj/item/stack/sheet/wood( src )

		else
			switch(mineral)
				if("metal")
					new /obj/item/stack/sheet/metal( src )
					new /obj/item/stack/sheet/metal( src )
					new /obj/item/stack/sheet/metal( src )
				if("gold")
					new /obj/item/stack/sheet/gold( src )
					new /obj/item/stack/sheet/gold( src )
					new /obj/item/stack/sheet/metal( src )
				if("silver")
					new /obj/item/stack/sheet/silver( src )
					new /obj/item/stack/sheet/silver( src )
					new /obj/item/stack/sheet/metal( src )
				if("diamond")
					new /obj/item/stack/sheet/diamond( src )
					new /obj/item/stack/sheet/diamond( src )
					new /obj/item/stack/sheet/metal( src )
				if("uranium")
					new /obj/item/stack/sheet/uranium( src )
					new /obj/item/stack/sheet/uranium( src )
					new /obj/item/stack/sheet/metal( src )
				if("plasma")
					new /obj/item/stack/sheet/plasma( src )
					new /obj/item/stack/sheet/plasma( src )
					new /obj/item/stack/sheet/metal( src )
				if("clown")
					new /obj/item/stack/sheet/clown( src )
					new /obj/item/stack/sheet/clown( src )
					new /obj/item/stack/sheet/metal( src )
				if("sandstone")
					new /obj/item/stack/sheet/sandstone( src )
					new /obj/item/stack/sheet/sandstone( src )
					new /obj/item/stack/sheet/metal( src )
				if("wood")
					new /obj/item/stack/sheet/wood( src )
					new /obj/item/stack/sheet/wood( src )
					new /obj/item/stack/sheet/metal( src )

	for(var/obj/O in src.contents) //Eject contents!
		if(istype(O,/obj/effect/decal/poster))
			var/obj/effect/decal/poster/P = O
			P.roll_and_drop(src)
		else
			O.loc = src
	ReplaceWithPlating(explode)

/turf/simulated/wall/examine()
	set src in oview(1)

	usr << "It looks like a regular wall."
	return

/turf/simulated/wall/ex_act(severity)
	switch(severity)
		if(1.0)
			//SN src = null
			src.ReplaceWithSpace()
			del(src)
			return
		if(2.0)
			if (prob(50))
				dismantle_wall(0,1)
			else
				dismantle_wall(1,1)
		if(3.0)
			var/proba
			if (istype(src, /turf/simulated/wall/r_wall))
				proba = 15
			else
				proba = 40
			if (prob(proba))
				dismantle_wall(0,1)
		else
	return

/turf/simulated/wall/blob_act()
	if(prob(50))
		dismantle_wall()

/turf/simulated/wall/attack_paw(mob/user as mob)
	if ((HULK in user.mutations))
		if (prob(40))
			usr << text("\blue You smash through the wall.")
			dismantle_wall(1)
			return
		else
			usr << text("\blue You punch the wall.")
			return

	return src.attack_hand(user)


/turf/simulated/wall/attack_animal(mob/living/simple_animal/M as mob)
	if(M.wall_smash)
		if (istype(src, /turf/simulated/wall/r_wall))
			M << text("\blue This wall is far too strong for you to destroy.")
			return
		else
			if (prob(40))
				M << text("\blue You smash through the wall.")
				dismantle_wall(1)
				return
			else
				M << text("\blue You smash against the wall.")
				return

	M << "\blue You push the wall but nothing happens!"
	return

/turf/simulated/wall/attack_hand(mob/user as mob)
	if ((HULK in user.mutations) || (SUPRSTR in user.augmentations))
		if (prob(40))
			usr << text("\blue You smash through the wall.")
			dismantle_wall(1)
			return
		else
			usr << text("\blue You punch the wall.")
			return

	user << "\blue You push the wall but nothing happens!"
	playsound(src.loc, 'Genhit.ogg', 25, 1)
	src.add_fingerprint(user)
	return

/turf/simulated/wall/attackby(obj/item/weapon/W as obj, mob/user as mob)

	if (!(istype(user, /mob/living/carbon/human) || ticker) && ticker.mode.name != "monkey")
		user << "<span class='warning'>You don't have the dexterity to do this!</span>"
		return

	//get the user's location
	if( !istype(user.loc, /turf) )	return	//can't do this stuff whilst inside objects and such

	//THERMITE related stuff. Calls src.thermitemelt() which handles melting simulated walls and the relevant effects
	if( thermite )
		if( istype(W, /obj/item/weapon/weldingtool) )
			var/obj/item/weapon/weldingtool/WT = W
			if( WT.remove_fuel(0,user) )
				thermitemelt(user)
				return

		else if(istype(W, /obj/item/weapon/pickaxe/plasmacutter))
			thermitemelt(user)
			return

		else if( istype(W, /obj/item/weapon/melee/energy/blade) )
			var/obj/item/weapon/melee/energy/blade/EB = W

			EB.spark_system.start()
			user << "<span class='notice'>You slash \the [src] with \the [EB]; the thermite ignites!</span>"
			playsound(src.loc, "sparks", 50, 1)
			playsound(src.loc, 'blade1.ogg', 50, 1)

			thermitemelt(user)
			return

	var/turf/T = user.loc	//get user's location for delay checks

	//DECONSTRUCTION
	if( istype(W, /obj/item/weapon/weldingtool) )
		var/obj/item/weapon/weldingtool/WT = W
		if( WT.remove_fuel(0,user) )
			user << "<span class='notice'>You begin slicing through the outer plating.</span>"
			playsound(src.loc, 'Welder.ogg', 100, 1)

			sleep(100)
			if( !istype(src, /turf/simulated/wall) || !user || !WT || !WT.isOn() || !T )	return

			if( user.loc == T && user.get_active_hand() == WT )
				user << "<span class='notice'>You remove the outer plating.</span>"
				dismantle_wall()
		else
			user << "<span class='notice'>You need more welding fuel to complete this task.</span>"
			return

	else if( istype(W, /obj/item/weapon/pickaxe/plasmacutter) )

		user << "<span class='notice'>You begin slicing through the outer plating.</span>"
		playsound(src.loc, 'Welder.ogg', 100, 1)

		sleep(60)
		if(mineral == "diamond")//Oh look, it's tougher
			sleep(60)
		if( !istype(src, /turf/simulated/wall) || !user || !W || !T )	return

		if( user.loc == T && user.get_active_hand() == W )
			user << "<span class='notice'>You remove the outer plating.</span>"
			dismantle_wall()
			for(var/mob/O in viewers(user, 5))
				O.show_message("<span class='warning'>The wall was sliced apart by [user]!</span>", 1, "<span class='warning'>You hear metal being sliced apart.</span>", 2)
		return

	//DRILLING
	else if (istype(W, /obj/item/weapon/pickaxe/diamonddrill))

		user << "<span class='notice'>You begin to drill though the wall.</span>"

		sleep(60)
		if(mineral == "diamond")
			sleep(60)
		if( !istype(src, /turf/simulated/wall) || !user || !W || !T )	return

		if( user.loc == T && user.get_active_hand() == W )
			user << "<span class='notice'>Your drill tears though the last of the reinforced plating.</span>"
			dismantle_wall()
			for(var/mob/O in viewers(user, 5))
				O.show_message("<span class='warning'>The wall was drilled through by [user]!</span>", 1, "<span class='warning'>You hear the grinding of metal.</span>", 2)
		return

	else if( istype(W, /obj/item/weapon/melee/energy/blade) )
		var/obj/item/weapon/melee/energy/blade/EB = W

		EB.spark_system.start()
		user << "<span class='notice'>You stab \the [EB] into the wall and begin to slice it apart.</span>"
		playsound(src.loc, "sparks", 50, 1)

		sleep(70)
		if(mineral == "diamond")
			sleep(70)
		if( !istype(src, /turf/simulated/wall) || !user || !EB || !T )	return

		if( user.loc == T && user.get_active_hand() == W )
			EB.spark_system.start()
			playsound(src.loc, "sparks", 50, 1)
			playsound(src.loc, 'blade1.ogg', 50, 1)
			dismantle_wall(1)
			for(var/mob/O in viewers(user, 5))
				O.show_message("<span class='warning'>The wall was sliced apart by [user]!</span>", 1, "<span class='warning'>You hear metal being sliced apart and sparks flying.</span>", 2)
		return

	else if(istype(W,/obj/item/apc_frame))
		var/obj/item/apc_frame/AH = W
		AH.try_build(src)
		return

	else if(istype(W,/obj/item/light_fixture_frame))
		var/obj/item/light_fixture_frame/AH = W
		AH.try_build(src)
		return

	else if(istype(W,/obj/item/light_fixture_frame/small))
		var/obj/item/light_fixture_frame/small/AH = W
		AH.try_build(src)
		return

	//Poster stuff
	else if(istype(W,/obj/item/weapon/contraband/poster))
		place_poster(W,user)
		return

	else
		return attack_hand(user)
	return

/turf/simulated/wall/r_wall/attack_hand(mob/user as mob)
	if ((HULK in user.mutations) || (SUPRSTR in user.augmentations))
		if (prob(5))
			usr << text("\blue You smash through the wall.")
			dismantle_wall(1)
			return
		else
			usr << text("\blue You punch the wall.")
			return

	user << "\blue You push the wall but nothing happens!"
	playsound(src.loc, 'Genhit.ogg', 25, 1)
	src.add_fingerprint(user)
	return

/turf/simulated/wall/r_wall/attackby(obj/item/W as obj, mob/user as mob)

	if (!(istype(user, /mob/living/carbon/human) || ticker) && ticker.mode.name != "monkey")
		user << "<span class='warning'>You don't have the dexterity to do this!</span>"
		return

	//get the user's location
	if( !istype(user.loc, /turf) )	return	//can't do this stuff whilst inside objects and such


	//THERMITE related stuff. Calls src.thermitemelt() which handles melting simulated walls and the relevant effects
	if( thermite )
		if( istype(W, /obj/item/weapon/weldingtool) )
			var/obj/item/weapon/weldingtool/WT = W
			if( WT.remove_fuel(0,user) )
				thermitemelt(user)
				return

		else if(istype(W, /obj/item/weapon/pickaxe/plasmacutter))
			thermitemelt(user)
			return

		else if( istype(W, /obj/item/weapon/melee/energy/blade) )
			var/obj/item/weapon/melee/energy/blade/EB = W

			EB.spark_system.start()
			user << "<span class='notice'>You slash \the [src] with \the [EB]; the thermite ignites!</span>"
			playsound(src.loc, "sparks", 50, 1)
			playsound(src.loc, 'blade1.ogg', 50, 1)

			thermitemelt(user)
			return

	else if(istype(W, /obj/item/weapon/melee/energy/blade))
		user << "<span class='notice'>This wall is too thick to slice through. You will need to find a different path.</span>"
		return

	var/turf/T = user.loc	//get user's location for delay checks

	//DECONSTRUCTION
	switch(d_state)
		if(0)
			if (istype(W, /obj/item/weapon/wirecutters))
				playsound(src.loc, 'Wirecutter.ogg', 100, 1)
				src.d_state = 1
				src.icon_state = "r_wall-1"
				new /obj/item/stack/rods( src )
				user << "<span class='notice'>You cut the outer grille.</span>"
				return

		if(1)
			if (istype(W, /obj/item/weapon/screwdriver))
				user << "<span class='notice'>You begin removing the support lines.</span>"
				playsound(src.loc, 'Screwdriver.ogg', 100, 1)

				sleep(40)
				if( !istype(src, /turf/simulated/wall/r_wall) || !user || !W || !T )	return

				if( d_state == 1 && user.loc == T && user.get_active_hand() == W )
					src.d_state = 2
					src.icon_state = "r_wall-2"
					user << "<span class='notice'>You remove the support lines.</span>"
				return

			//REPAIRING (replacing the outer grille for cosmetic damage)
			else if( istype(W, /obj/item/stack/rods) )
				var/obj/item/stack/O = W
				src.d_state = 0
				src.icon_state = "r_wall"
				relativewall_neighbours()	//call smoothwall stuff
				user << "<span class='notice'>You replace the outer grille.</span>"
				if (O.amount > 1)
					O.amount--
				else
					del(O)
				return

		if(2)
			if( istype(W, /obj/item/weapon/weldingtool) )
				var/obj/item/weapon/weldingtool/WT = W
				if( WT.remove_fuel(0,user) )

					user << "<span class='notice'>You begin slicing through the metal cover.</span>"
					playsound(src.loc, 'Welder.ogg', 100, 1)

					sleep(60)
					if( !istype(src, /turf/simulated/wall/r_wall) || !user || !WT || !WT.isOn() || !T )	return

					if( d_state == 2 && user.loc == T && user.get_active_hand() == WT )
						src.d_state = 3
						src.icon_state = "r_wall-3"
						user << "<span class='notice'>You press firmly on the cover, dislodging it.</span>"
				else
					user << "<span class='notice'>You need more welding fuel to complete this task.</span>"
				return

			if( istype(W, /obj/item/weapon/pickaxe/plasmacutter) )

				user << "<span class='notice'>You begin slicing through the metal cover.</span>"
				playsound(src.loc, 'Welder.ogg', 100, 1)

				sleep(40)
				if( !istype(src, /turf/simulated/wall/r_wall) || !user || !W || !T )	return

				if( d_state == 2 && user.loc == T && user.get_active_hand() == W )
					src.d_state = 3
					src.icon_state = "r_wall-3"
					user << "<span class='notice'>You press firmly on the cover, dislodging it.</span>"
				return

		if(3)
			if (istype(W, /obj/item/weapon/crowbar))

				user << "<span class='notice'>You struggle to pry off the cover.</span>"
				playsound(src.loc, 'Crowbar.ogg', 100, 1)

				sleep(100)
				if( !istype(src, /turf/simulated/wall/r_wall) || !user || !W || !T )	return

				if( d_state == 3 && user.loc == T && user.get_active_hand() == W )
					src.d_state = 4
					src.icon_state = "r_wall-4"
					user << "<span class='notice'>You pry off the cover.</span>"
				return

		if(4)
			if (istype(W, /obj/item/weapon/wrench))

				user << "<span class='notice'>You start loosening the anchoring bolts which secure the support rods to their frame.</span>"
				playsound(src.loc, 'Ratchet.ogg', 100, 1)

				sleep(40)
				if( !istype(src, /turf/simulated/wall/r_wall) || !user || !W || !T )	return

				if( d_state == 4 && user.loc == T && user.get_active_hand() == W )
					src.d_state = 5
					src.icon_state = "r_wall-5"
					user << "<span class='notice'>You remove the bolts anchoring the support rods.</span>"
				return

		if(5)
			if( istype(W, /obj/item/weapon/weldingtool) )
				var/obj/item/weapon/weldingtool/WT = W
				if( WT.remove_fuel(0,user) )

					user << "<span class='notice'>You begin slicing through the support rods.</span>"
					playsound(src.loc, 'Welder.ogg', 100, 1)

					sleep(100)
					if( !istype(src, /turf/simulated/wall/r_wall) || !user || !WT || !WT.isOn() || !T )	return

					if( d_state == 5 && user.loc == T && user.get_active_hand() == WT )
						src.d_state = 6
						src.icon_state = "r_wall-6"
						new /obj/item/stack/rods( src )
						user << "<span class='notice'>The support rods drop out as you cut them loose from the frame.</span>"
				else
					user << "<span class='notice'>You need more welding fuel to complete this task.</span>"
				return

			if( istype(W, /obj/item/weapon/pickaxe/plasmacutter) )

				user << "<span class='notice'>You begin slicing through the support rods.</span>"
				playsound(src.loc, 'Welder.ogg', 100, 1)

				sleep(70)
				if( !istype(src, /turf/simulated/wall/r_wall) || !user || !W || !T )	return

				if( d_state == 5 && user.loc == T && user.get_active_hand() == W )
					src.d_state = 6
					src.icon_state = "r_wall-6"
					new /obj/item/stack/rods( src )
					user << "<span class='notice'>The support rods drop out as you cut them loose from the frame.</span>"
				return

		if(6)
			if( istype(W, /obj/item/weapon/crowbar) )

				user << "<span class='notice'>You struggle to pry off the outer sheath.</span>"
				playsound(src.loc, 'Crowbar.ogg', 100, 1)

				sleep(100)
				if( !istype(src, /turf/simulated/wall/r_wall) || !user || !W || !T )	return

				if( user.loc == T && user.get_active_hand() == W )
					user << "<span class='notice'>You pry off the outer sheath.</span>"
					dismantle_wall()
				return

//vv OK, we weren't performing a valid deconstruction step or igniting thermite,let's check the other possibilities vv

	//DRILLING
	if (istype(W, /obj/item/weapon/pickaxe/diamonddrill))

		user << "<span class='notice'>You begin to drill though the wall.</span>"

		sleep(200)
		if( !istype(src, /turf/simulated/wall/r_wall) || !user || !W || !T )	return

		if( user.loc == T && user.get_active_hand() == W )
			user << "<span class='notice'>Your drill tears though the last of the reinforced plating.</span>"
			dismantle_wall()

	//REPAIRING
	else if( istype(W, /obj/item/stack/sheet/metal) && d_state )
		var/obj/item/stack/sheet/metal/MS = W

		user << "<span class='notice'>You begin patching-up the wall with \a [MS].</span>"

		sleep( max(20*d_state,100) )	//time taken to repair is proportional to the damage! (max 10 seconds)
		if( !istype(src, /turf/simulated/wall/r_wall) || !user || !MS || !T )	return

		if( user.loc == T && user.get_active_hand() == MS && d_state )
			src.d_state = 0
			src.icon_state = "r_wall"
			relativewall_neighbours()	//call smoothwall stuff
			user << "<span class='notice'>You repair the last of the damage.</span>"
			if (MS.amount > 1)
				MS.amount--
			else
				del(MS)

	//APC
	else if( istype(W,/obj/item/apc_frame) )
		var/obj/item/apc_frame/AH = W
		AH.try_build(src)

	else if(istype(W,/obj/item/light_fixture_frame))
		var/obj/item/light_fixture_frame/AH = W
		AH.try_build(src)
		return

	else if(istype(W,/obj/item/light_fixture_frame/small))
		var/obj/item/light_fixture_frame/small/AH = W
		AH.try_build(src)
		return

	//Poster stuff
	else if(istype(W,/obj/item/weapon/contraband/poster))
		place_poster(W,user)
		return

	//Finally, CHECKING FOR FALSE WALLS if it isn't damaged
	else if(!d_state)
		return attack_hand(user)
	return

/turf/simulated/wall/mineral/attack_hand(mob/user as mob)
	if(mineral == "uranium")
		radiate()
	..()

/turf/simulated/wall/mineral/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if((mineral == "plasma") && W)
		if(is_hot(W) > 300)//If the temperature of the object is over 300, then ignite
			ignite(is_hot(W))
			return
	if(mineral == "uranium")
		radiate()
//	if((mineral == "gold") || (mineral == "silver"))
//		if(shocked)
//			shock()
	..()

/turf/simulated/wall/mineral/proc/PlasmaBurn(temperature)
	spawn(2)
	new /obj/structure/girder(src)
	src.ReplaceWithFloor()
	for(var/turf/simulated/floor/target_tile in range(0,src))
		if(target_tile.parent && target_tile.parent.group_processing)
			target_tile.parent.suspend_group_processing()
		var/datum/gas_mixture/napalm = new
		var/toxinsToDeduce = 20
		napalm.toxins = toxinsToDeduce
		napalm.temperature = 400+T0C
		target_tile.assume_air(napalm)
		spawn (0) target_tile.hotspot_expose(temperature, 400)
	for(var/obj/structure/falsewall/plasma/F in range(3,src))//Hackish as fuck, but until temperature_expose works, there is nothing I can do -Sieve
		var/turf/T = get_turf(F)
		T.ReplaceWithMineralWall("plasma")
		del (F)
	for(var/turf/simulated/wall/mineral/W in range(3,src))
		if(mineral == "plasma")
			W.ignite((temperature/4))//Added so that you can't set off a massive chain reaction with a small flame
	for(var/obj/machinery/door/airlock/plasma/D in range(3,src))
		D.ignite(temperature/4)

/turf/simulated/wall/mineral/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)//Doesn't fucking work because walls don't interact with air :(
	if(mineral == "plasma")
		if(exposed_temperature > 300)
			PlasmaBurn(exposed_temperature)

/turf/simulated/wall/mineral/proc/ignite(exposed_temperature)
	if(mineral == "plasma")
		if(exposed_temperature > 300)
			PlasmaBurn(exposed_temperature)

/turf/simulated/wall/mineral/Bumped(AM as mob|obj)
	if(mineral == "uranium")
		radiate()
	..()

/turf/simulated/wall/mineral/bullet_act(var/obj/item/projectile/Proj)
	if(mineral == "plasma")
		if(istype(Proj,/obj/item/projectile/beam))
			PlasmaBurn(2500)
		else if(istype(Proj,/obj/item/projectile/ion))
			PlasmaBurn(500)
	..()

/turf/simulated/wall/proc/thermitemelt(mob/user as mob)
	if(mineral == "diamond")
		return
	var/obj/effect/overlay/O = new/obj/effect/overlay( src )
	O.name = "Thermite"
	O.desc = "Looks hot."
	O.icon = 'icons/effects/fire.dmi'
	O.icon_state = "2"
	O.anchored = 1
	O.density = 1
	O.layer = 5

	var/turf/simulated/floor/F = ReplaceWithPlating()
	F.burn_tile()
	F.icon_state = "wall_thermite"
	user << "<span class='warning'>The thermite melts through the wall.</span>"

	spawn(100)
		if(O)	del(O)
	F.sd_LumReset()
	return

/turf/simulated/wall/meteorhit(obj/M as obj)
	if (prob(15))
		dismantle_wall()
	else if(prob(70))
		ReplaceWithPlating()
	else
		ReplaceWithLattice()
	return 0


//This is so damaged or burnt tiles or platings don't get remembered as the default tile
var/list/icons_to_ignore_at_floor_init = list("damaged1","damaged2","damaged3","damaged4",
				"damaged5","panelscorched","floorscorched1","floorscorched2","platingdmg1","platingdmg2",
				"platingdmg3","plating","light_on","light_on_flicker1","light_on_flicker2",
				"light_on_clicker3","light_on_clicker4","light_on_clicker5","light_broken",
				"light_on_broken","light_off","wall_thermite","grass1","grass2","grass3","grass4",
				"asteroid","asteroid_dug",
				"asteroid0","asteroid1","asteroid2","asteroid3","asteroid4",
				"asteroid5","asteroid6","asteroid7","asteroid8","asteroid9","asteroid10","asteroid11","asteroid12",
				"burning","oldburning","light-on-r","light-on-y","light-on-g","light-on-b", "wood", "wood-broken")

var/list/plating_icons = list("plating","platingdmg1","platingdmg2","platingdmg3","asteroid","asteroid_dug")
var/list/wood_icons = list("wood","wood-broken")

/turf/simulated/floor

	//Note to coders, the 'intact' var can no longer be used to determine if the floor is a plating or not.
	//Use the is_plating(), is_plasteel_floor() and is_light_floor() procs instead. --Errorage
	name = "floor"
	icon = 'icons/turf/floors.dmi'
	icon_state = "floor"
	var/icon_regular_floor = "floor" //used to remember what icon the tile should have by default
	var/icon_plating = "plating"
	thermal_conductivity = 0.040
	heat_capacity = 10000
	var/broken = 0
	var/burnt = 0
	var/obj/item/stack/tile/floor_tile = new/obj/item/stack/tile/plasteel

/turf/simulated/floor/airless
	icon_state = "floor"
	name = "airless floor"
	oxygen = 0.01
	nitrogen = 0.01
	temperature = TCMB

	New()
		..()
		name = "floor"

/turf/simulated/floor/light
	name = "Light floor"
	luminosity = 5
	icon_state = "light_on"
	floor_tile = new/obj/item/stack/tile/light

	New()
		floor_tile.New() //I guess New() isn't run on objects spawned without the definition of a turf to house them, ah well.
		var/n = name //just in case commands rename it in the ..() call
		..()
		spawn(4)
			if(src)
				update_icon()
				name = n

/turf/simulated/floor/grass
	name = "Grass patch"
	icon_state = "grass1"
	floor_tile = new/obj/item/stack/tile/grass

	New()
		floor_tile.New() //I guess New() isn't run on objects spawned without the definition of a turf to house them, ah well.
		icon_state = "grass[pick("1","2","3","4")]"
		..()
		spawn(4)
			if(src)
				update_icon()
				for(var/direction in cardinal)
					if(istype(get_step(src,direction),/turf/simulated/floor))
						var/turf/simulated/floor/FF = get_step(src,direction)
						FF.update_icon() //so siding get updated properly

/turf/simulated/floor/wood
	name = "floor"
	icon_state = "wood"
	floor_tile = new/obj/item/stack/tile/wood

/turf/simulated/floor/vault
	icon_state = "rockvault"

	New(location,type)
		..()
		icon_state = "[type]vault"

/turf/simulated/wall/vault
	icon_state = "rockvault"

	New(location,type)
		..()
		icon_state = "[type]vault"

/turf/simulated/floor/engine
	name = "reinforced floor"
	icon_state = "engine"
	thermal_conductivity = 0.025
	heat_capacity = 325000

/turf/simulated/floor/engine/cult
	name = "engraved floor"
	icon_state = "cult"


/turf/simulated/floor/engine/n20
	New()
		..()
		var/datum/gas_mixture/adding = new
		var/datum/gas/sleeping_agent/trace_gas = new

		trace_gas.moles = 2000
		adding.trace_gases += trace_gas
		adding.temperature = T20C

		assume_air(adding)

/turf/simulated/floor/engine/vacuum
	name = "vacuum floor"
	icon_state = "engine"
	oxygen = 0
	nitrogen = 0.001
	temperature = TCMB

/turf/simulated/floor/plating
	name = "plating"
	icon_state = "plating"
	floor_tile = null
	intact = 0

/turf/simulated/floor/plating/airless
	icon_state = "plating"
	name = "airless plating"
	oxygen = 0.01
	nitrogen = 0.01
	temperature = TCMB

	New()
		..()
		name = "plating"

/turf/simulated/floor/bluegrid
	icon = 'icons/turf/floors.dmi'
	icon_state = "bcircuit"

/turf/simulated/floor/greengrid
	icon = 'icons/turf/floors.dmi'
	icon_state = "gcircuit"

/turf/simulated/floor/New()
	..()
	if(icon_state in icons_to_ignore_at_floor_init) //so damaged/burned tiles or plating icons aren't saved as the default
		icon_regular_floor = "floor"
	else
		icon_regular_floor = icon_state

//turf/simulated/floor/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
//	if ((istype(mover, /obj/machinery/vehicle) && !(src.burnt)))
//		if (!( locate(/obj/machinery/mass_driver, src) ))
//			return 0
//	return ..()

/turf/simulated/floor/ex_act(severity)
	//set src in oview(1)
	switch(severity)
		if(1.0)
			src.ReplaceWithSpace()
		if(2.0)
			switch(pick(1,2;75,3))
				if (1)
					src.ReplaceWithLattice()
					if(prob(33)) new /obj/item/stack/sheet/metal(src)
				if(2)
					src.ReplaceWithSpace()
				if(3)
					if(prob(80))
						src.break_tile_to_plating()
					else
						src.break_tile()
					src.hotspot_expose(1000,CELL_VOLUME)
					if(prob(33)) new /obj/item/stack/sheet/metal(src)
		if(3.0)
			if (prob(50))
				src.break_tile()
				src.hotspot_expose(1000,CELL_VOLUME)
	return

/turf/simulated/floor/blob_act()
	return

turf/simulated/floor/proc/update_icon()
	if(is_plasteel_floor())
		if(!broken && !burnt)
			icon_state = icon_regular_floor
	if(is_plating())
		if(!broken && !burnt)
			icon_state = icon_plating //Because asteroids are 'platings' too.
	if(is_light_floor())
		var/obj/item/stack/tile/light/T = floor_tile
		if(T.on)
			switch(T.state)
				if(0)
					icon_state = "light_on"
					sd_SetLuminosity(5)
				if(1)
					var/num = pick("1","2","3","4")
					icon_state = "light_on_flicker[num]"
					sd_SetLuminosity(5)
				if(2)
					icon_state = "light_on_broken"
					sd_SetLuminosity(5)
				if(3)
					icon_state = "light_off"
					sd_SetLuminosity(0)
		else
			sd_SetLuminosity(0)
			icon_state = "light_off"
	if(is_grass_floor())
		if(!broken && !burnt)
			if(!(icon_state in list("grass1","grass2","grass3","grass4")))
				icon_state = "grass[pick("1","2","3","4")]"
	if(is_wood_floor())
		if(!broken && !burnt)
			if( !(icon_state in wood_icons) )
				icon_state = "wood"
				//world << "[icon_state]'s got [icon_state]"
	spawn(1)
		if(istype(src,/turf/simulated/floor)) //Was throwing runtime errors due to a chance of it changing to space halfway through.
			if(air)
				update_visuals(air)

/turf/simulated/floor/return_siding_icon_state()
	..()
	if(is_grass_floor())
		var/dir_sum = 0
		for(var/direction in cardinal)
			var/turf/T = get_step(src,direction)
			if(!(T.is_grass_floor()))
				dir_sum += direction
		if(dir_sum)
			return "wood_siding[dir_sum]"
		else
			return 0


/turf/simulated/floor/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/turf/simulated/floor/attack_hand(mob/user as mob)
	if (is_light_floor())
		var/obj/item/stack/tile/light/T = floor_tile
		T.on = !T.on
	update_icon()
	if ((!( user.canmove ) || user.restrained() || !( user.pulling )))
		return
	if (user.pulling.anchored)
		return
	if ((user.pulling.loc != user.loc && get_dist(user, user.pulling) > 1))
		return
	if (ismob(user.pulling))
		var/mob/M = user.pulling

//		if(M==user)					//temporary hack to stop runtimes. ~Carn
//			user.stop_pulling()		//but...fixed the root of the problem
//			return					//shoudn't be needed now, unless somebody fucks with pulling again.

		var/mob/t = M.pulling
		M.stop_pulling()
		step(user.pulling, get_dir(user.pulling.loc, src))
		M.start_pulling(t)
	else
		step(user.pulling, get_dir(user.pulling.loc, src))
	return

/turf/simulated/floor/engine/attackby(obj/item/weapon/C as obj, mob/user as mob)
	if(!C)
		return
	if(!user)
		return
	if(istype(C, /obj/item/weapon/wrench))
		user << "\blue Removing rods..."
		playsound(src.loc, 'Ratchet.ogg', 80, 1)
		if(do_after(user, 30))
			new /obj/item/stack/rods(src, 2)
			ReplaceWithFloor()
			var/turf/simulated/floor/F = src
			F.make_plating()
			return

/turf/simulated/floor/proc/gets_drilled()
	return

/turf/simulated/floor/proc/break_tile_to_plating()
	if(!is_plating())
		make_plating()
	break_tile()

/turf/simulated/floor/is_plasteel_floor()
	if(istype(floor_tile,/obj/item/stack/tile/plasteel))
		return 1
	else
		return 0

/turf/simulated/floor/is_light_floor()
	if(istype(floor_tile,/obj/item/stack/tile/light))
		return 1
	else
		return 0

/turf/simulated/floor/is_grass_floor()
	if(istype(floor_tile,/obj/item/stack/tile/grass))
		return 1
	else
		return 0

/turf/simulated/floor/is_wood_floor()
	if(istype(floor_tile,/obj/item/stack/tile/wood))
		return 1
	else
		return 0

/turf/simulated/floor/is_plating()
	if(!floor_tile)
		return 1
	return 0

/turf/simulated/floor/proc/break_tile()
	if(istype(src,/turf/simulated/floor/engine)) return
	if(istype(src,/turf/simulated/floor/mech_bay_recharge_floor))
		src.ReplaceWithPlating()
	if(broken) return
	if(is_plasteel_floor())
		src.icon_state = "damaged[pick(1,2,3,4,5)]"
		broken = 1
	else if(is_light_floor())
		src.icon_state = "light_broken"
		broken = 1
	else if(is_plating())
		src.icon_state = "platingdmg[pick(1,2,3)]"
		broken = 1
	else if(is_wood_floor())
		src.icon_state = "wood-broken"
		broken = 1
	else if(is_grass_floor())
		src.icon_state = "sand[pick("1","2","3")]"
		broken = 1

/turf/simulated/floor/proc/burn_tile()
	if(istype(src,/turf/simulated/floor/engine)) return
	if(istype(src,/turf/simulated/floor/plating/airless/asteroid)) return//Asteroid tiles don't burn
	if(broken || burnt) return
	if(is_plasteel_floor())
		src.icon_state = "damaged[pick(1,2,3,4,5)]"
		burnt = 1
	else if(is_plasteel_floor())
		src.icon_state = "floorscorched[pick(1,2)]"
		burnt = 1
	else if(is_plating())
		src.icon_state = "panelscorched"
		burnt = 1
	else if(is_wood_floor())
		src.icon_state = "wood-broken"
		burnt = 1
	else if(is_grass_floor())
		src.icon_state = "sand[pick("1","2","3")]"
		burnt = 1

//This proc will delete the floor_tile and the update_iocn() proc will then change the icon_state of the turf
//This proc auto corrects the grass tiles' siding.
/turf/simulated/floor/proc/make_plating()
	if(istype(src,/turf/simulated/floor/engine)) return

	if(is_grass_floor())
		for(var/direction in cardinal)
			if(istype(get_step(src,direction),/turf/simulated/floor))
				var/turf/simulated/floor/FF = get_step(src,direction)
				FF.update_icon() //so siding get updated properly

	if(!floor_tile) return
	del(floor_tile)
	icon_plating = "plating"
	sd_SetLuminosity(0)
	floor_tile = null
	intact = 0
	broken = 0
	burnt = 0

	update_icon()
	levelupdate()

//This proc will make the turf a plasteel floor tile. The expected argument is the tile to make the turf with
//If none is given it will make a new object. dropping or unequipping must be handled before or after calling
//this proc.
/turf/simulated/floor/proc/make_plasteel_floor(var/obj/item/stack/tile/plasteel/T = null)
	broken = 0
	burnt = 0
	intact = 1
	sd_SetLuminosity(0)
	if(T)
		if(istype(T,/obj/item/stack/tile/plasteel))
			floor_tile = T
			if (icon_regular_floor)
				icon_state = icon_regular_floor
			else
				icon_state = "floor"
				icon_regular_floor = icon_state
			update_icon()
			levelupdate()
			return
	//if you gave a valid parameter, it won't get thisf ar.
	floor_tile = new/obj/item/stack/tile/plasteel
	icon_state = "floor"
	icon_regular_floor = icon_state

	update_icon()
	levelupdate()

//This proc will make the turf a light floor tile. The expected argument is the tile to make the turf with
//If none is given it will make a new object. dropping or unequipping must be handled before or after calling
//this proc.
/turf/simulated/floor/proc/make_light_floor(var/obj/item/stack/tile/light/T = null)
	broken = 0
	burnt = 0
	intact = 1
	if(T)
		if(istype(T,/obj/item/stack/tile/light))
			floor_tile = T
			update_icon()
			levelupdate()
			return
	//if you gave a valid parameter, it won't get thisf ar.
	floor_tile = new/obj/item/stack/tile/light

	update_icon()
	levelupdate()

//This proc will make a turf into a grass patch. Fun eh? Insert the grass tile to be used as the argument
//If no argument is given a new one will be made.
/turf/simulated/floor/proc/make_grass_floor(var/obj/item/stack/tile/grass/T = null)
	broken = 0
	burnt = 0
	intact = 1
	if(T)
		if(istype(T,/obj/item/stack/tile/grass))
			floor_tile = T
			update_icon()
			levelupdate()
			return
	//if you gave a valid parameter, it won't get thisf ar.
	floor_tile = new/obj/item/stack/tile/grass

	update_icon()
	levelupdate()

//This proc will make a turf into a wood floor. Fun eh? Insert the wood tile to be used as the argument
//If no argument is given a new one will be made.
/turf/simulated/floor/proc/make_wood_floor(var/obj/item/stack/tile/wood/T = null)
	broken = 0
	burnt = 0
	intact = 1
	if(T)
		if(istype(T,/obj/item/stack/tile/wood))
			floor_tile = T
			update_icon()
			levelupdate()
			return
	//if you gave a valid parameter, it won't get thisf ar.
	floor_tile = new/obj/item/stack/tile/wood

	update_icon()
	levelupdate()

/turf/simulated/floor/attackby(obj/item/C as obj, mob/user as mob)

	if(!C || !user)
		return 0

	if(istype(C,/obj/item/weapon/light/bulb)) //only for light tiles
		if(is_light_floor())
			var/obj/item/stack/tile/light/T = floor_tile
			if(T.state)
				user.drop_item(C)
				del(C)
				T.state = C //fixing it by bashing it with a light bulb, fun eh?
				update_icon()
				user << "\blue You replace the light bulb."
			else
				user << "\blue The lightbulb seems fine, no need to replace it."

	if(istype(C, /obj/item/weapon/crowbar) && (!(is_plating())))
		if(broken || burnt)
			user << "\red You remove the broken plating."
		else
			if(is_wood_floor())
				user << "\red You forcefully pry off the planks, destroying them in the process."
			else
				user << "\red You remove the [floor_tile.name]."
				new floor_tile.type(src)

		make_plating()
		playsound(src.loc, 'Crowbar.ogg', 80, 1)

		return

	if(istype(C, /obj/item/weapon/screwdriver) && is_wood_floor())
		if(broken || burnt)
			return
		else
			if(is_wood_floor())
				user << "\red You unscrew the planks."
				new floor_tile.type(src)

		make_plating()
		playsound(src.loc, 'Screwdriver.ogg', 80, 1)

		return

	if(istype(C, /obj/item/stack/rods))
		var/obj/item/stack/rods/R = C
		if (is_plating())
			if (R.amount >= 2)
				user << "\blue Reinforcing the floor..."
				if(do_after(user, 30) && R && R.amount >= 2 && is_plating())
					ReplaceWithEngineFloor()
					playsound(src.loc, 'Deconstruct.ogg', 80, 1)
					R.use(2)
					return
			else
				user << "\red You need more rods."
		else
			user << "\red You must remove the plating first."
		return

	if(istype(C, /obj/item/stack/tile))
		if(is_plating())
			if(!broken && !burnt)
				var/obj/item/stack/tile/T = C
				floor_tile = new T.type
				intact = 1
				if(istype(T,/obj/item/stack/tile/light))
					var/obj/item/stack/tile/light/L = T
					var/obj/item/stack/tile/light/F = floor_tile
					F.state = L.state
					F.on = L.on
				if(istype(T,/obj/item/stack/tile/grass))
					for(var/direction in cardinal)
						if(istype(get_step(src,direction),/turf/simulated/floor))
							var/turf/simulated/floor/FF = get_step(src,direction)
							FF.update_icon() //so siding gets updated properly
				T.use(1)
				update_icon()
				levelupdate()
				playsound(src.loc, 'Genhit.ogg', 50, 1)
			else
				user << "\blue This section is too damaged to support a tile. Use a welder to fix the damage."


	if(istype(C, /obj/item/weapon/cable_coil))
		if(is_plating())
			var/obj/item/weapon/cable_coil/coil = C
			coil.turf_place(src, user)
		else
			user << "\red You must remove the plating first."

	if(istype(C, /obj/item/weapon/shovel))
		if(is_grass_floor())
			new /obj/item/weapon/ore/glass(src)
			new /obj/item/weapon/ore/glass(src) //Make some sand if you shovel grass
			user << "\blue You shovel the grass."
			make_plating()
		else
			user << "\red You cannot shovel this."

	if(istype(C, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/welder = C
		if(welder.isOn() && (is_plating()))
			if(broken || burnt)
				if(welder.remove_fuel(0,user))
					user << "\red You fix some dents on the broken plating."
					playsound(src.loc, 'Welder.ogg', 80, 1)
					icon_state = "plating"
					burnt = 0
					broken = 0
				else
					user << "\blue You need more welding fuel to complete this task."

/turf/unsimulated/floor/attack_paw(user as mob)
	return src.attack_hand(user)

/turf/unsimulated/floor/attack_hand(var/mob/user as mob)
	if ((!( user.canmove ) || user.restrained() || !( user.pulling )))
		return
	if (user.pulling.anchored)
		return
	if ((user.pulling.loc != user.loc && get_dist(user, user.pulling) > 1))
		return
	if (ismob(user.pulling))
		var/mob/M = user.pulling
		var/mob/t = M.pulling
		M.stop_pulling()
		step(user.pulling, get_dir(user.pulling.loc, src))
		M.start_pulling(t)
	else
		step(user.pulling, get_dir(user.pulling.loc, src))
	return

// imported from space.dm

/turf/space/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/turf/space/attack_hand(mob/user as mob)
	if ((user.restrained() || !( user.pulling )))
		return
	if (user.pulling.anchored)
		return
	if ((user.pulling.loc != user.loc && get_dist(user, user.pulling) > 1))
		return
	if (ismob(user.pulling))
		var/mob/M = user.pulling
		var/atom/movable/t = M.pulling
		M.stop_pulling()
		step(user.pulling, get_dir(user.pulling.loc, src))
		M.start_pulling(t)
	else
		step(user.pulling, get_dir(user.pulling.loc, src))
	return

/turf/space/attackby(obj/item/C as obj, mob/user as mob)

	if (istype(C, /obj/item/stack/rods))
		var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
		if(L)
			return
		var/obj/item/stack/rods/R = C
		user << "\blue Constructing support lattice ..."
		playsound(src.loc, 'Genhit.ogg', 50, 1)
		ReplaceWithLattice()
		R.use(1)
		return

	if (istype(C, /obj/item/stack/tile/plasteel))
		var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
		if(L)
			var/obj/item/stack/tile/plasteel/S = C
			del(L)
			playsound(src.loc, 'Genhit.ogg', 50, 1)
			S.build(src)
			S.use(1)
			return
		else
			user << "\red The plating is going to need some support."
	return


// Ported from unstable r355

/turf/space/Entered(atom/movable/A as mob|obj)
	..()
	if ((!(A) || src != A.loc || istype(null, /obj/effect/beam)))	return

	inertial_drift(A)

	if(ticker && ticker.mode)

		// Okay, so let's make it so that people can travel z levels but not nuke disks!
		// if(ticker.mode.name == "nuclear emergency")	return
		if (src.x <= TRANSITIONEDGE || A.x >= (world.maxx - TRANSITIONEDGE - 1) || src.y <= TRANSITIONEDGE || A.y >= (world.maxy - TRANSITIONEDGE - 1))
			if(istype(A, /obj/effect/meteor)||istype(A, /obj/effect/space_dust))
				del(A)
				return

			if(istype(A, /obj/item/weapon/disk/nuclear)) // Don't let nuke disks travel Z levels  ... And moving this shit down here so it only fires when they're actually trying to change z-level.
				del(A) //The disk's Del() proc ensures a new one is created
				return

			if(!isemptylist(A.search_contents_for(/obj/item/weapon/disk/nuclear)))
				if(istype(A, /mob/living))
					var/mob/living/MM = A
					if(MM.client)
						MM << "\red Something you are carrying is preventing you from leaving. Don't play stupid; you know exactly what it is."
				return

			var/move_to_z_str = pickweight(accessable_z_levels)

			var/move_to_z = text2num(move_to_z_str)

			if(!move_to_z)
				return

			A.z = move_to_z

			if(src.x <= TRANSITIONEDGE)
				A.x = world.maxx - TRANSITIONEDGE - 2

			else if (A.x >= (world.maxx - TRANSITIONEDGE - 1))
				A.x = TRANSITIONEDGE + 1

			else if (src.y <= TRANSITIONEDGE)
				A.y = world.maxy - TRANSITIONEDGE -2

			else if (A.y >= (world.maxy - TRANSITIONEDGE - 1))
				A.y = TRANSITIONEDGE +1

			spawn (0)
				if ((A && A.loc))
					A.loc.Entered(A)

/turf/space/proc/Sandbox_Spacemove(atom/movable/A as mob|obj)
	var/cur_x
	var/cur_y
	var/next_x
	var/next_y
	var/target_z
	var/list/y_arr

	if(src.x <= 1)
		if(istype(A, /obj/effect/meteor)||istype(A, /obj/effect/space_dust))
			del(A)
			return

		var/list/cur_pos = src.get_global_map_pos()
		if(!cur_pos) return
		cur_x = cur_pos["x"]
		cur_y = cur_pos["y"]
		next_x = (--cur_x||global_map.len)
		y_arr = global_map[next_x]
		target_z = y_arr[cur_y]
/*
		//debug
		world << "Src.z = [src.z] in global map X = [cur_x], Y = [cur_y]"
		world << "Target Z = [target_z]"
		world << "Next X = [next_x]"
		//debug
*/
		if(target_z)
			A.z = target_z
			A.x = world.maxx - 2
			spawn (0)
				if ((A && A.loc))
					A.loc.Entered(A)
	else if (src.x >= world.maxx)
		if(istype(A, /obj/effect/meteor))
			del(A)
			return

		var/list/cur_pos = src.get_global_map_pos()
		if(!cur_pos) return
		cur_x = cur_pos["x"]
		cur_y = cur_pos["y"]
		next_x = (++cur_x > global_map.len ? 1 : cur_x)
		y_arr = global_map[next_x]
		target_z = y_arr[cur_y]
/*
		//debug
		world << "Src.z = [src.z] in global map X = [cur_x], Y = [cur_y]"
		world << "Target Z = [target_z]"
		world << "Next X = [next_x]"
		//debug
*/
		if(target_z)
			A.z = target_z
			A.x = 3
			spawn (0)
				if ((A && A.loc))
					A.loc.Entered(A)
	else if (src.y <= 1)
		if(istype(A, /obj/effect/meteor))
			del(A)
			return
		var/list/cur_pos = src.get_global_map_pos()
		if(!cur_pos) return
		cur_x = cur_pos["x"]
		cur_y = cur_pos["y"]
		y_arr = global_map[cur_x]
		next_y = (--cur_y||y_arr.len)
		target_z = y_arr[next_y]
/*
		//debug
		world << "Src.z = [src.z] in global map X = [cur_x], Y = [cur_y]"
		world << "Next Y = [next_y]"
		world << "Target Z = [target_z]"
		//debug
*/
		if(target_z)
			A.z = target_z
			A.y = world.maxy - 2
			spawn (0)
				if ((A && A.loc))
					A.loc.Entered(A)

	else if (src.y >= world.maxy)
		if(istype(A, /obj/effect/meteor)||istype(A, /obj/effect/space_dust))
			del(A)
			return
		var/list/cur_pos = src.get_global_map_pos()
		if(!cur_pos) return
		cur_x = cur_pos["x"]
		cur_y = cur_pos["y"]
		y_arr = global_map[cur_x]
		next_y = (++cur_y > y_arr.len ? 1 : cur_y)
		target_z = y_arr[next_y]
/*
		//debug
		world << "Src.z = [src.z] in global map X = [cur_x], Y = [cur_y]"
		world << "Next Y = [next_y]"
		world << "Target Z = [target_z]"
		//debug
*/
		if(target_z)
			A.z = target_z
			A.y = 3
			spawn (0)
				if ((A && A.loc))
					A.loc.Entered(A)
	return

/obj/effect/vaultspawner
	var/maxX = 6
	var/maxY = 6
	var/minX = 2
	var/minY = 2

/obj/effect/vaultspawner/New(turf/location as turf,lX = minX,uX = maxX,lY = minY,uY = maxY,var/type = null)
	if(!type)
		type = pick("sandstone","rock","alien")

	var/lowBoundX = location.x
	var/lowBoundY = location.y

	var/hiBoundX = location.x + rand(lX,uX)
	var/hiBoundY = location.y + rand(lY,uY)

	var/z = location.z

	for(var/i = lowBoundX,i<=hiBoundX,i++)
		for(var/j = lowBoundY,j<=hiBoundY,j++)
			if(i == lowBoundX || i == hiBoundX || j == lowBoundY || j == hiBoundY)
				new /turf/simulated/wall/vault(locate(i,j,z),type)
			else
				new /turf/simulated/floor/vault(locate(i,j,z),type)

	del(src)

/turf/proc/kill_creatures(mob/U = null)//Will kill people/creatures and damage mechs./N
//Useful to batch-add creatures to the list.
	for(var/mob/living/M in src)
		if(M==U)	continue//Will not harm U. Since null != M, can be excluded to kill everyone.
		spawn(0)
			M.gib()
	for(var/obj/mecha/M in src)//Mecha are not gibbed but are damaged.
		spawn(0)
			M.take_damage(100, "brute")
	for(var/obj/effect/critter/M in src)
		spawn(0)
			M.Die()

/turf/proc/Bless()
	if(flags & NOJAUNT)
		return
	flags |= NOJAUNT
	overlays += image('icons/effects/water.dmi',src,"holywater")
