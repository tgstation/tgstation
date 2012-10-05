/turf
	icon = 'icons/turf/floors.dmi'
	level = 1.0

	//for floors, use is_plating(), is_plasteel_floor() and is_light_floor()
	var/intact = 1

	//Properties for open tiles (/floor)
	var/oxygen = 0
	var/carbon_dioxide = 0
	var/nitrogen = 0
	var/toxins = 0

	//Properties for airtight tiles (/wall)
	var/thermal_conductivity = 0.05
	var/heat_capacity = 1

	//Properties for both
	var/temperature = T20C

	var/blocks_air = 0
	var/icon_old = null
	var/pathweight = 1

/turf/New()
	..()
	for(var/atom/movable/AM as mob|obj in src)
		spawn( 0 )
			src.Entered(AM)
			return
	return

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

/turf/Click()
	if(!isAI(usr))
		..()

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


/turf/Entered(atom/atom as mob|obj)
	..()
//vvvvv Infared beam stuff vvvvv

	if ((atom && atom.density && !( istype(atom, /obj/effect/beam) )))
		for(var/obj/effect/beam/i_beam/I in src)
			spawn( 0 )
				if (I)
					I.hit()
				break

//^^^^^ Infared beam stuff ^^^^^

	if(!istype(atom, /atom/movable))
		return

	var/atom/movable/M = atom

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

/turf/proc/is_plating()
	return 0
/turf/proc/is_asteroid_floor()
	return 0
/turf/proc/is_plasteel_floor()
	return 0
/turf/proc/is_light_floor()
	return 0
/turf/proc/is_grass_floor()
	return 0
/turf/proc/is_wood_floor()
	return 0
/turf/proc/is_carpet_floor()
	return 0
/turf/proc/return_siding_icon_state()		//used for grass floors, which have siding.
	return 0

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
	var/turf_count = 0

	var/old_lumcount = lighting_lumcount - initial(lighting_lumcount)
	var/turf/simulated/floor/W = new /turf/simulated/floor( locate(src.x, src.y, src.z) )
	W.lighting_lumcount += old_lumcount
	if(old_lumcount != W.lighting_lumcount)
		W.lighting_changed = 1
		lighting_controller.changed_turfs += W

//////Assimilate Air//////
	for(var/direction in cardinal)//Only use cardinals to cut down on lag
		var/turf/T = get_step(src,direction)
		if(istype(T,/turf/space))//Counted as no air
			turf_count++//Considered a valid turf for air calcs
			continue
		else if(istype(T,/turf/simulated/floor))
			var/turf/simulated/S = T
			if(S.air)//Add the air's contents to the holders
				aoxy += S.air.oxygen
				anitro += S.air.nitrogen
				aco += S.air.carbon_dioxide
				atox += S.air.toxins
				atemp += S.air.temperature
			turf_count ++
	W.air.oxygen = (aoxy/max(turf_count,1))//Averages contents of the turfs, ignoring walls and the like
	W.air.nitrogen = (anitro/max(turf_count,1))
	W.air.carbon_dioxide = (aco/max(turf_count,1))
	W.air.toxins = (atox/max(turf_count,1))
	W.air.temperature = (atemp/max(turf_count,1))//Trace gases can get bant

	W.RemoveLattice()
	W.dir = old_dir
	if(prior_icon) W.icon_state = prior_icon
	else W.icon_state = "floor"

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
	var/turf_count = 0

//////Assimilate Air//////
	var/old_lumcount = lighting_lumcount - initial(lighting_lumcount)
	var/turf/simulated/floor/plating/W = new /turf/simulated/floor/plating( locate(src.x, src.y, src.z) )
	W.lighting_lumcount += old_lumcount
	if(old_lumcount != W.lighting_lumcount)
		W.lighting_changed = 1
		lighting_controller.changed_turfs += W

	for(var/direction in cardinal)
		var/turf/T = get_step(src,direction)
		if(istype(T,/turf/space))
			turf_count++
			continue
		else if(istype(T,/turf/simulated/floor))
			var/turf/simulated/S = T
			if(S.air)
				aoxy += S.air.oxygen
				anitro += S.air.nitrogen
				aco += S.air.carbon_dioxide
				atox += S.air.toxins
				atemp += S.air.temperature
			turf_count++
	W.air.oxygen = (aoxy/max(turf_count,1))
	W.air.nitrogen = (anitro/max(turf_count,1))
	W.air.carbon_dioxide = (aco/max(turf_count,1))
	W.air.toxins = (atox/max(turf_count,1))
	W.air.temperature = (atemp/max(turf_count,1))

	W.RemoveLattice()
	W.dir = old_dir
	if(prior_icon) W.icon_state = prior_icon
	else W.icon_state = "plating"

	W.levelupdate()
	return W

/turf/proc/ReplaceWithEngineFloor()
	var/old_dir = dir

	var/old_lumcount = lighting_lumcount - initial(lighting_lumcount)
	var/turf/simulated/floor/engine/E = new /turf/simulated/floor/engine( locate(src.x, src.y, src.z) )
	E.lighting_lumcount += old_lumcount
	if(old_lumcount != E.lighting_lumcount)
		E.lighting_changed = 1
		lighting_controller.changed_turfs += E

	E.dir = old_dir
	E.icon_state = "engine"
	E.levelupdate()



/turf/proc/ReplaceWithSpace()
	var/old_dir = dir

	var/old_lumcount = lighting_lumcount - initial(lighting_lumcount)
	var/turf/space/S = new /turf/space( locate(src.x, src.y, src.z) )
	S.lighting_lumcount += old_lumcount
	if(old_lumcount != S.lighting_lumcount)
		S.lighting_changed = 1
		lighting_controller.changed_turfs += S

	S.dir = old_dir
	S.levelupdate()
	return S

/turf/proc/ReplaceWithLattice()
	var/old_dir = dir

	var/old_lumcount = lighting_lumcount - initial(lighting_lumcount)
	var/turf/space/S = new /turf/space( locate(src.x, src.y, src.z) )
	S.lighting_lumcount += old_lumcount
	if(old_lumcount != S.lighting_lumcount)
		S.lighting_changed = 1
		lighting_controller.changed_turfs += S

	S.dir = old_dir
	new /obj/structure/lattice( locate(src.x, src.y, src.z) )
	S.levelupdate()
	return S

/turf/proc/ReplaceWithWall()
	var/old_icon = icon_state

	var/old_lumcount = lighting_lumcount - initial(lighting_lumcount)
	var/turf/simulated/wall/S = new /turf/simulated/wall( locate(src.x, src.y, src.z) )
	S.lighting_lumcount += old_lumcount
	if(old_lumcount != S.lighting_lumcount)
		S.lighting_changed = 1
		lighting_controller.changed_turfs += S

	S.icon_old = old_icon
	S.levelupdate()
	return S

/turf/proc/ReplaceWithRWall()
	var/old_icon = icon_state

	var/old_lumcount = lighting_lumcount - initial(lighting_lumcount)
	var/turf/simulated/wall/r_wall/S = new /turf/simulated/wall/r_wall( locate(src.x, src.y, src.z) )
	S.lighting_lumcount += old_lumcount
	if(old_lumcount != S.lighting_lumcount)
		S.lighting_changed = 1
		lighting_controller.changed_turfs += S

	S.icon_old = old_icon
	S.levelupdate()
	return S

/turf/proc/ReplaceWithMineralWall(var/ore)
	var/old_icon = icon_state

	var/old_lumcount = lighting_lumcount - initial(lighting_lumcount)
	var/turf/simulated/wall/mineral/S = new /turf/simulated/wall/mineral( locate(src.x, src.y, src.z) )
	S.lighting_lumcount += old_lumcount
	if(old_lumcount != S.lighting_lumcount)
		S.lighting_changed = 1
		lighting_controller.changed_turfs += S

	S.icon_old = old_icon
	S.mineral = ore
	S.New()//Hackish as fuck, but what can you do? -Sieve	//build it into the goddamn new() call up there ^ ~Carn
															//e.g. new(turf/loc, mineral)
	S.levelupdate()
	return S


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

/turf/proc/AdjacentTurfs()
	var/L[] = new()
	for(var/turf/simulated/t in oview(src,1))
		if(!t.density)
			if(!LinkBlocked(src, t) && !TurfBlockedNonWindow(t))
				L.Add(t)
	return L
/turf/proc/Distance(turf/t)
	if(get_dist(src,t) == 1)
		var/cost = (src.x - t.x) * (src.x - t.x) + (src.y - t.y) * (src.y - t.y)
		cost *= (pathweight+t.pathweight)/2
		return cost
	else
		return get_dist(src,t)
/turf/proc/AdjacentTurfsSpace()
	var/L[] = new()
	for(var/turf/t in oview(src,1))
		if(!t.density)
			if(!LinkBlocked(src, t) && !TurfBlockedNonWindow(t))
				L.Add(t)
	return L