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

	// Bot shit
	var/targetted_by=null

	// Decal shit.
	var/list/decals

	// Flick animation shit
	var/atom/movable/overlay/c_animation = null

	// holy water
	var/holy = 0

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

/turf/Enter(atom/movable/O, atom/oldloc)
	if(movement_disabled && usr.ckey != movement_disabled_exception)
		usr << "\red Movement is admin-disabled." //This is to identify lag problems
		return 0

	// first, check objects to block exit that are not on the border
	for(var/atom/movable/obstacle in oldloc)
		if((obstacle.flags & ~ON_BORDER) && (obstacle != O))
			if(!obstacle.CheckExit(O, src))
				O.Bump(obstacle, 1)
				return 0

	// now, check objects to block exit that are on the border
	for(var/atom/movable/border_obstacle in oldloc)
		if((border_obstacle.flags & ON_BORDER) && (border_obstacle != O))
			if(!border_obstacle.CheckExit(O, src))
				O.Bump(border_obstacle, 1)
				return 0

	// next, check objects to block entry that are on the border
	for(var/atom/movable/border_obstacle in contents)
		if(border_obstacle.flags & ON_BORDER)
			if(!border_obstacle.CanPass(O, oldloc))
				O.Bump(border_obstacle, 1)
				return 0

	// then, check the turf itself
	if (!CanPass(O, src))
		O.Bump(src, 1)
		return 0

	// finally, check objects/mobs to block entry that are not on the border
	for(var/atom/movable/obstacle in contents)
		if(obstacle.flags & ~ON_BORDER)
			if(!obstacle.CanPass(O, oldloc))
				O.Bump(obstacle, 1)
				return 0

	return 1 // nothing found to block so return success!

/turf/Entered(atom/movable/Obj,atom/OldLoc)
	var/loopsanity = 100
	if(ismob(Obj))
		if(!Obj:lastarea)
			Obj:lastarea = get_area(Obj.loc)
		if(Obj:lastarea.has_gravity == 0)
			inertial_drift(Obj)

	/*
		if(Obj.flags & NOGRAV)
			inertial_drift(Obj)
	*/

		else if(!istype(src, /turf/space))
			Obj:inertia_dir = 0
	..()
	var/objects = 0
	for(var/atom/A as mob|obj|turf|area in range(1))
		if(objects > loopsanity)	break
		objects++
		spawn( 0 )
			if ((A && Obj))
				A.HasProximity(Obj, 1)
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
/turf/proc/is_catwalk()
	return 0
/turf/proc/return_siding_icon_state()		//used for grass floors, which have siding.
	return 0

/turf/proc/inertial_drift(atom/movable/A as mob|obj)
	if(!(A.last_move))	return
	if(istype(A, /obj/spacepod) && src.x > 2 && src.x < (world.maxx - 1) && src.y > 2 && src.y < (world.maxy-1))
		var/obj/spacepod/SP = A
		if(SP.Process_Spacemove(1))
			SP.inertia_dir = 0
			return
		spawn(5)
			if((SP && (SP.loc == src)))
				if(SP.inertia_dir)
					step(SP, SP.inertia_dir)
					return
	if(istype(A, /obj/structure/stool/bed/chair/vehicle/) && src.x > 2 && src.x < (world.maxx - 1) && src.y > 2 && src.y < (world.maxy-1))
		var/obj/structure/stool/bed/chair/vehicle/JC = A //A bomb!
		if(JC.Process_Spacemove(1))
			JC.inertia_dir = 0
			return
		spawn(5)
			if((JC && (JC.loc == src)))
				if(JC.inertia_dir)
					step(JC, JC.inertia_dir)
					return
				JC.inertia_dir = JC.last_move
				step(JC, JC.inertia_dir)
	if((istype(A, /mob/) && src.x > 2 && src.x < (world.maxx - 1) && src.y > 2 && src.y < (world.maxy-1)))
		var/mob/M = A
		if(M.Process_Spacemove(1))
			M.inertia_dir  = 0
			return
		spawn(5)
			if((M && !(M.anchored) && !(M.pulledby) && (M.loc == src)))
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

//Creates a new turf
/turf/proc/ChangeTurf(var/turf/N, var/tell_universe=1)
	if (!N)
		return

#ifdef ENABLE_TRI_LEVEL
// Fuck this, for now - N3X
///// Z-Level Stuff ///// This makes sure that turfs are not changed to space when one side is part of a zone
	if(N == /turf/space)
		var/turf/controller = locate(1, 1, src.z)
		for(var/obj/effect/landmark/zcontroller/c in controller)
			if(c.down)
				var/turf/below = locate(src.x, src.y, c.down_target)
				if((air_master.has_valid_zone(below) || air_master.has_valid_zone(src)) && !istype(below, /turf/space)) // dont make open space into space, its pointless and makes people drop out of the station
					var/turf/W = src.ChangeTurf(/turf/simulated/floor/open)
					var/list/temp = list()
					temp += W
					c.add(temp,3,1) // report the new open space to the zcontroller
					return W
///// Z-Level Stuff
#endif

	var/old_lumcount = lighting_lumcount - initial(lighting_lumcount)

	//world << "Replacing [src.type] with [N]"

	if(connections) connections.erase_all()

	if(istype(src,/turf/simulated))
		//Yeah, we're just going to rebuild the whole thing.
		//Despite this being called a bunch during explosions,
		//the zone will only really do heavy lifting once.
		var/turf/simulated/S = src
		if(S.zone) S.zone.rebuild()

	if(ispath(N, /turf/simulated/floor))
		//if the old turf had a zone, connect the new turf to it as well - Cael
		//Adjusted by SkyMarshal 5/10/13 - The air master will handle the addition of the new turf.
		//if(zone)
		//	zone.RemoveTurf(src)
		//	if(!zone.CheckStatus())
		//		zone.SetStatus(ZONE_ACTIVE)

		var/turf/simulated/W = new N( locate(src.x, src.y, src.z) )
		//W.Assimilate_Air()

		W.lighting_lumcount += old_lumcount
		if(old_lumcount != W.lighting_lumcount)
			W.lighting_changed = 1
			lighting_controller.changed_turfs += W

		if (istype(W,/turf/simulated/floor))
			W.RemoveLattice()

		if(tell_universe)
			universe.OnTurfChange(W)

		if(air_master)
			air_master.mark_for_update(src)

		W.levelupdate()
		return W

	else
		//if(zone)
		//	zone.RemoveTurf(src)
		//	if(!zone.CheckStatus())
		//		zone.SetStatus(ZONE_ACTIVE)

		var/turf/W = new N( locate(src.x, src.y, src.z) )
		W.lighting_lumcount += old_lumcount
		if(old_lumcount != W.lighting_lumcount)
			W.lighting_changed = 1
			lighting_controller.changed_turfs += W

		if(tell_universe)
			universe.OnTurfChange(W)

		if(air_master)
			air_master.mark_for_update(src)

		W.levelupdate()
		return W

/turf/proc/AddDecal(const/image/decal)
	if(!decals)
		decals = new

	decals += decal
	overlays += decal

/turf/proc/ClearDecals()
	if(!decals)
		return

	for(var/image/decal in decals)
		overlays -= decal

	decals = 0


//Commented out by SkyMarshal 5/10/13 - If you are patching up space, it should be vacuum.
//  If you are replacing a wall, you have increased the volume of the room without increasing the amount of gas in it.
//  As such, this will no longer be used.

//////Assimilate Air//////
/*
/turf/simulated/proc/Assimilate_Air()
	var/aoxy = 0//Holders to assimilate air from nearby turfs
	var/anitro = 0
	var/aco = 0
	var/atox = 0
	var/atemp = 0
	var/turf_count = 0

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
	air.oxygen = (aoxy/max(turf_count,1))//Averages contents of the turfs, ignoring walls and the like
	air.nitrogen = (anitro/max(turf_count,1))
	air.carbon_dioxide = (aco/max(turf_count,1))
	air.toxins = (atox/max(turf_count,1))
	air.temperature = (atemp/max(turf_count,1))//Trace gases can get bant
	air.update_values()

	//cael - duplicate the averaged values across adjacent turfs to enforce a seamless atmos change
	for(var/direction in cardinal)//Only use cardinals to cut down on lag
		var/turf/T = get_step(src,direction)
		if(istype(T,/turf/space))//Counted as no air
			continue
		else if(istype(T,/turf/simulated/floor))
			var/turf/simulated/S = T
			if(S.air)//Add the air's contents to the holders
				S.air.oxygen = air.oxygen
				S.air.nitrogen = air.nitrogen
				S.air.carbon_dioxide = air.carbon_dioxide
				S.air.toxins = air.toxins
				S.air.temperature = air.temperature
				S.air.update_values()
*/

/turf/proc/ReplaceWithLattice()
	src.ChangeTurf(/turf/space)
	new /obj/structure/lattice( locate(src.x, src.y, src.z) )

/turf/proc/kill_creatures(mob/U = null)//Will kill people/creatures and damage mechs./N
//Useful to batch-add creatures to the list.
	for(var/mob/living/M in src)
		if(M==U)	continue//Will not harm U. Since null != M, can be excluded to kill everyone.
		spawn(0)
			M.gib()
	for(var/obj/mecha/M in src)//Mecha are not gibbed but are damaged.
		spawn(0)
			M.take_damage(100, "brute")

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

// This Distance proc assumes that only cardinal movement is
//  possible. It results in more efficient (CPU-wise) pathing
//  for bots and anything else that only moves in cardinal dirs.
/turf/proc/Distance_cardinal(turf/t)
	if(!src || !t) return 0
	return abs(src.x - t.x) + abs(src.y - t.y)

/turf/proc/Distance(turf/t)
	if(get_dist(src,t) == 1)
		var/cost = (src.x - t.x) * (src.x - t.x) + (src.y - t.y) * (src.y - t.y)
		return sqrt(cost)
	else
		return get_dist(src,t)
/turf/proc/AdjacentTurfsSpace()
	var/L[] = new()
	for(var/turf/t in oview(src,1))
		if(!t.density)
			if(!LinkBlocked(src, t) && !TurfBlockedNonWindow(t))
				L.Add(t)
	return L

/turf/proc/cultify()
	ChangeTurf(/turf/space)
	return