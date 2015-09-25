/turf
	icon = 'icons/turf/floors.dmi'
	level = 1.0

	luminosity = 0

	//for floors, use is_plating(), is_plasteel_floor() and is_light_floor()
	var/intact = 1

	//properties for open tiles (/floor)
	var/oxygen = 0
	var/carbon_dioxide = 0
	var/nitrogen = 0
	var/toxins = 0

	//properties for airtight tiles (/wall)
	var/thermal_conductivity = 0.05
	var/heat_capacity = 1

	//properties for both
	var/temperature = T20C

	var/blocks_air = 0
	var/icon_old = null

	//associated PathNode in the A* algorithm
	var/PathNode/PNode = null

	// Bot shit
	var/targetted_by=null

	// Decal shit.
	var/list/decals

	// Flick animation shit
	var/atom/movable/overlay/c_animation = null

	// Powernet /datum/power_connections.  *Uninitialized until used to conserve memory*
	var/list/power_connections = null

	// holy water
	var/holy = 0

	// wizard sleep spell probably better way to do this
	var/sleeping = 0

	// left by bullets that went all the way through
	var/bullet_marks = 0
	penetration_dampening = 10

/*
 * Technically obsoleted by base_turf
	//For building on the asteroid.
 	var/under_turf = /turf/space
 */

	var/explosion_block = 0

	var/dynamic_lighting = 1

	forceinvertredraw = 1

/turf/examine(mob/user)
	..()
	if(bullet_marks)
		user << "It has bullet markings on it."

/turf/proc/process()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/turf/proc/process() called tick#: [world.time]")
	universe.OnTurfTick(src)

/turf/New()
	..()
	for(var/atom/movable/AM as mob|obj in src)
		spawn( 0 )
			src.Entered(AM)
			return
	turfs |= src

	var/area/A = loc
	if(!dynamic_lighting || !A.lighting_use_dynamic)
		luminosity = 1

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
	if(Proj.destroy)
		src.ex_act(2)
	..()
	return 0

/turf/bullet_act(var/obj/item/projectile/Proj)
	if(istype(Proj ,/obj/item/projectile/bullet/gyro))
		explosion(src, -1, 0, 2)
	..()
	return 0

/*
 * IF YOU HAVE BYOND VERSION BELOW 507.1248 OR ARE ABLE TO WALK THROUGH WINDOORS/BORDER WINDOWS COMMENT OUT
 * #define BORDER_USE_TURF_EXIT
 * FOR MORE INFORMATION SEE: http://www.byond.com/forum/?post=1666940
 *
#ifdef BORDER_USE_TURF_EXIT
/turf/Exit(atom/movable/mover, atom/target)
	if(!mover)
		return 1
	// First, make sure it can leave its square
	if(mover.loc == src)
		// Nothing but border objects stop you from leaving a tile, only one loop is needed
		for(var/obj/obstacle in src)
			/*if(ismob(mover) && mover:client)
				world << "<span class='danger'>EXIT</span>origin: checking exit of mob [obstacle]"*/
			if(obstacle != mover && obstacle != target && !obstacle.CheckExit(mover, target))
				/*if(ismob(mover) && mover:client)
					world << "<span class='danger'>EXIT</span>Origin: We are bumping into [obstacle]"*/
				mover.Bump(obstacle, 1)
				return 0
	return 1
#if DM_VERSION < 507
	#warn This compiler is too far out of date! You will experience issues with windows and windoors unles you update to atleast 507.1248 or comment out BORDER_USE_TURF_EXIT in global.dm!

#endif
*/
/turf/Enter(atom/movable/mover as mob|obj, atom/forget as mob|obj|turf|area)
	if (!mover)
		return 1

//#ifndef BORDER_USE_TURF_EXIT
//#warn BORDER_USE_TURF_EXIT is not defined, using possibly buggy turf/Enter code.
	// First, make sure it can leave its square
	if(isturf(mover.loc))
		// Nothing but border objects stop you from leaving a tile, only one loop is needed
		for(var/obj/obstacle in mover.loc)
			if(obstacle != mover && obstacle != forget && !obstacle.CheckExit(mover, src) )
				mover.Bump(obstacle, 1)
				return 0
//#endif
	var/list/large_dense = list()
	//Next, check objects to block entry that are on the border
	for(var/atom/movable/border_obstacle in src)
		if(border_obstacle.flags&ON_BORDER)
			/*if(ismob(mover) && mover:client)
				world << "<span class='danger'>ENTER</span>Target(border): checking CanPass of [border_obstacle]"*/
			if(!border_obstacle.CanPass(mover, mover.loc) && (forget != border_obstacle) && mover != border_obstacle)
				/*if(ismob(mover) && mover:client)
					world << "<span class='danger'>ENTER</span>Target(border): We are bumping into [border_obstacle]"*/
				mover.Bump(border_obstacle, 1)
				return 0
		else
			large_dense += border_obstacle

	//Then, check the turf itself
	if (!src.CanPass(mover, src))
		mover.Bump(src, 1)
		return 0

	//Finally, check objects/mobs to block entry that are not on the border
	for(var/atom/movable/obstacle in large_dense)
		/*if(ismob(mover) && mover:client)
			world << "<span class='danger'>ENTER</span>target(large_dense): [mover] checking CanPass of [obstacle]"*/
		if(!obstacle.CanPass(mover, mover.loc) && (forget != obstacle) && mover != obstacle)
			/*if(ismob(mover) && mover:client)
				world << "<span class='danger'>ENTER</span>target(large_dense): checking: We are bumping into [obstacle]"*/
			mover.Bump(obstacle, 1)
			return 0
	return 1 //Nothing found to block so return success!

/turf/Entered(atom/movable/Obj,atom/OldLoc)
	var/loopsanity = 100

	if(ismob(Obj))
		if(Obj.areaMaster && Obj.areaMaster.has_gravity == 0)
			inertial_drift(Obj)
	/*
		if(Obj.flags & NOGRAV)
			inertial_drift(Obj)
	*/

		else if(!istype(src, /turf/space))
			Obj:inertia_dir = 0
	..()
	var/objects = 0
	if(Obj && Obj.flags & PROXMOVE)
		for(var/atom/A as mob|obj|turf|area in range(1))
			if(objects > loopsanity)	break
			objects++
			spawn( 0 )
				if ((A && Obj) && A.flags & PROXMOVE)
					A.HasProximity(Obj, 1)
	return

/turf/proc/is_plating()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/turf/proc/is_plating() called tick#: [world.time]")
	return 0
/turf/proc/is_asteroid_floor()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/turf/proc/is_asteroid_floor() called tick#: [world.time]")
	return 0
/turf/proc/is_plasteel_floor()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/turf/proc/is_plasteel_floor() called tick#: [world.time]")
	return 0
/turf/proc/is_light_floor()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/turf/proc/is_light_floor() called tick#: [world.time]")
	return 0
/turf/proc/is_grass_floor()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/turf/proc/is_grass_floor() called tick#: [world.time]")
	return 0
/turf/proc/is_wood_floor()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/turf/proc/is_wood_floor() called tick#: [world.time]")
	return 0
/turf/proc/is_carpet_floor()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/turf/proc/is_carpet_floor() called tick#: [world.time]")
	return 0
/turf/proc/is_arcade_floor()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/turf/proc/is_arcade_floor() called tick#: [world.time]")
	return 0
/turf/proc/is_mineral_floor()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/turf/proc/is_mineral_floor() called tick#: [world.time]")
	return 0
/turf/proc/return_siding_icon_state()		//used for grass floors, which have siding.
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/turf/proc/return_siding_icon_state() called tick#: [world.time]")
	return 0

/turf/proc/inertial_drift(atom/movable/A as mob|obj)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/turf/proc/inertial_drift() called tick#: [world.time]")
	if(!(A.last_move))	return
	if(istype(A, /obj/spacepod) && src.x > 2 && src.x < (world.maxx - 1) && src.y > 2 && src.y < (world.maxy-1))
		var/obj/spacepod/SP = A
		if(SP.Process_Spacemove(1))
			SP.inertia_dir = 0
			return
		spawn(5)
			if((SP && (SP.loc == src)))
				if(SP.inertia_dir)
					SP.Move(get_step(SP, SP.inertia_dir), SP.inertia_dir)
					return
	if(istype(A, /obj/structure/bed/chair/vehicle/) && src.x > 2 && src.x < (world.maxx - 1) && src.y > 2 && src.y < (world.maxy-1))
		var/obj/structure/bed/chair/vehicle/JC = A //A bomb!
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
				var/mob/living/carbon/carbons = M
				if(istype(carbons))
					carbons.update_minimap() //Should this even be here, oh well whatever
				if(M.inertia_dir)
					step(M, M.inertia_dir)
					return
				M.inertia_dir = M.last_move
				step(M, M.inertia_dir)
	return

/turf/proc/levelupdate()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/turf/proc/levelupdate() called tick#: [world.time]")
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
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/turf/proc/RemoveLattice() called tick#: [world.time]")
	var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
	if(L)
		del L

//Creates a new turf
/turf/proc/ChangeTurf(var/turf/N, var/tell_universe=1, var/force_lighting_update = 0)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/turf/proc/ChangeTurf() called tick#: [world.time]")
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

					if(opacity != initialOpacity)
						UpdateAffectingLights()

					return W
///// Z-Level Stuff
#endif

	var/datum/gas_mixture/env

	var/old_opacity = opacity
	var/old_dynamic_lighting = dynamic_lighting
	var/list/old_affecting_lights = affecting_lights
	var/old_lighting_overlay = lighting_overlay

	//world << "Replacing [src.type] with [N]"

	if(connections) connections.erase_all()

	if(istype(src,/turf/simulated))
		//Yeah, we're just going to rebuild the whole thing.
		//Despite this being called a bunch during explosions,
		//the zone will only really do heavy lifting once.
		var/turf/simulated/S = src
		env = S.air //Get the air before the change
		if(S.zone) S.zone.rebuild()
	if(istype(src,/turf/simulated/floor))
		var/turf/simulated/floor/F = src
		if(F.floor_tile)
			returnToPool(F.floor_tile)
			F.floor_tile = null
		F = null
	if(ispath(N, /turf/simulated/floor))
		//if the old turf had a zone, connect the new turf to it as well - Cael
		//Adjusted by SkyMarshal 5/10/13 - The air master will handle the addition of the new turf.
		//if(zone)
		//	zone.RemoveTurf(src)
		//	if(!zone.CheckStatus())
		//		zone.SetStatus(ZONE_ACTIVE)

		var/turf/simulated/W = new N( locate(src.x, src.y, src.z) )
		if(env)
			W.air = env //Copy the old environment data over if both turfs were simulated

		if (istype(W,/turf/simulated/floor))
			W.RemoveLattice()

		if(tell_universe)
			universe.OnTurfChange(W)

		if(air_master)
			air_master.mark_for_update(src)

		W.levelupdate()

		. = W

	else
		//if(zone)
		//	zone.RemoveTurf(src)
		//	if(!zone.CheckStatus())
		//		zone.SetStatus(ZONE_ACTIVE)

		var/turf/W = new N( locate(src.x, src.y, src.z) )

		if(tell_universe)
			universe.OnTurfChange(W)

		if(air_master)
			air_master.mark_for_update(src)

		W.levelupdate()

		. = W

	lighting_overlay = old_lighting_overlay
	affecting_lights = old_affecting_lights
	if((old_opacity != opacity) || (dynamic_lighting != old_dynamic_lighting) || force_lighting_update)
		reconsider_lights()
	if(dynamic_lighting != old_dynamic_lighting)
		if(dynamic_lighting)
			lighting_build_overlays()
		else
			lighting_clear_overlays()

/turf/proc/AddDecal(const/image/decal)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/turf/proc/AddDecal() called tick#: [world.time]")
	if(!decals)
		decals = new

	decals += decal
	overlays += decal

/turf/proc/ClearDecals()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/turf/proc/ClearDecals() called tick#: [world.time]")
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
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/turf/simulated/proc/Assimilate_Air() called tick#: [world.time]")
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
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/turf/proc/ReplaceWithLattice() called tick#: [world.time]")
	src.ChangeTurf(get_base_turf(src.z))
	if(istype(src, /turf/space))
		new /obj/structure/lattice(src)

/turf/proc/kill_creatures(mob/U = null)//Will kill people/creatures and damage mechs./N
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/turf/proc/kill_creatures() called tick#: [world.time]")
//Useful to batch-add creatures to the list.
	for(var/mob/living/M in src)
		if(M==U)	continue//Will not harm U. Since null != M, can be excluded to kill everyone.
		spawn(0)
			M.gib()
	for(var/obj/mecha/M in src)//Mecha are not gibbed but are damaged.
		spawn(0)
			M.take_damage(100, "brute")

/turf/proc/Bless()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/turf/proc/Bless() called tick#: [world.time]")
	flags |= NOJAUNT

/////////////////////////////////////////////////////////////////////////
// Navigation procs
// Used for A-star pathfinding
////////////////////////////////////////////////////////////////////////

///////////////////////////
//Cardinal only movements
///////////////////////////

// Returns the surrounding cardinal turfs with open links
// Including through doors openable with the ID
/turf/proc/CardinalTurfsWithAccess(var/obj/item/weapon/card/id/ID)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/turf/proc/CardinalTurfsWithAccess() called tick#: [world.time]")
	var/list/L = new()
	var/turf/simulated/T

	for(var/dir in cardinal)
		T = get_step(src, dir)
		if(istype(T) && !T.density)
			if(!LinkBlockedWithAccess(src, T, ID))
				L.Add(T)
	return L

// Returns the surrounding cardinal turfs with open links
// Don't check for ID, doors passable only if open
/turf/proc/CardinalTurfs()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/turf/proc/CardinalTurfs() called tick#: [world.time]")
	var/list/L = new()
	var/turf/simulated/T

	for(var/dir in cardinal)
		T = get_step(src, dir)
		if(istype(T) && !T.density)
			if(!LinkBlocked(src, T))
				L.Add(T)
	return L

///////////////////////////
//All directions movements
///////////////////////////

// Returns the surrounding simulated turfs with open links
// Including through doors openable with the ID
/turf/proc/AdjacentTurfsWithAccess(var/obj/item/weapon/card/id/ID = null,var/list/closed)//check access if one is passed
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/turf/proc/AdjacentTurfsWithAccess() called tick#: [world.time]")
	var/list/L = new()
	var/turf/simulated/T
	for(var/dir in list(NORTHWEST,NORTHEAST,SOUTHEAST,SOUTHWEST,NORTH,EAST,SOUTH,WEST)) //arbitrarily ordered list to favor non-diagonal moves in case of ties
		T = get_step(src,dir)
		if(T in closed) //turf already proceeded in A*
			continue
		if(istype(T) && !T.density)
			if(!LinkBlockedWithAccess(src, T, ID))
				L.Add(T)
	return L

//Idem, but don't check for ID and goes through open doors
/turf/proc/AdjacentTurfs(var/list/closed)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/turf/proc/AdjacentTurfs() called tick#: [world.time]")
	var/list/L = new()
	var/turf/simulated/T
	for(var/dir in list(NORTHWEST,NORTHEAST,SOUTHEAST,SOUTHWEST,NORTH,EAST,SOUTH,WEST)) //arbitrarily ordered list to favor non-diagonal moves in case of ties
		T = get_step(src,dir)
		if(T in closed) //turf already proceeded by A*
			continue
		if(istype(T) && !T.density)
			if(!LinkBlocked(src, T))
				L.Add(T)
	return L

// check for all turfs, including unsimulated ones
/turf/proc/AdjacentTurfsSpace(var/obj/item/weapon/card/id/ID = null, var/list/closed)//check access if one is passed
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/turf/proc/AdjacentTurfsSpace() called tick#: [world.time]")
	var/list/L = new()
	var/turf/T
	for(var/dir in list(NORTHWEST,NORTHEAST,SOUTHEAST,SOUTHWEST,NORTH,EAST,SOUTH,WEST)) //arbitrarily ordered list to favor non-diagonal moves in case of ties
		T = get_step(src,dir)
		if(T in closed) //turf already proceeded by A*
			continue
		if(istype(T) && !T.density)
			if(!ID)
				if(!LinkBlocked(src, T))
					L.Add(T)
			else
				if(!LinkBlockedWithAccess(src, T, ID))
					L.Add(T)
	return L

//////////////////////////////
//Distance procs
//////////////////////////////

//Distance associates with all directions movement
/turf/proc/Distance(var/turf/T)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/turf/proc/Distance() called tick#: [world.time]")
	return get_dist(src,T)

//  This Distance proc assumes that only cardinal movement is
//  possible. It results in more efficient (CPU-wise) pathing
//  for bots and anything else that only moves in cardinal dirs.
/turf/proc/Distance_cardinal(turf/T)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/turf/proc/Distance_cardinal() called tick#: [world.time]")
	if(!src || !T) return 0
	return abs(src.x - T.x) + abs(src.y - T.y)

////////////////////////////////////////////////////


/turf/proc/cultify()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/turf/proc/cultify() called tick#: [world.time]")
	if(istype(src, get_base_turf(src.z))) //Don't cultify the base turf, ever
		return
	ChangeTurf(get_base_turf(src.z))

/turf/projectile_check()
	return PROJREACT_WALLS

/turf/singularity_act()
	if(istype(src, get_base_turf(src.z))) //Don't singulo the base turf, ever
		return
	if(intact)
		for(var/obj/O in contents)
			if(O.level != 1)
				continue
			if(O.invisibility == 101)
				O.singularity_act()
	ChangeTurf(get_base_turf(src.z))
	return(2)

//Return a lattice to allow catwalk building
/turf/proc/canBuildCatwalk()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/turf/proc/canBuildCatwalk() called tick#: [world.time]")
	return BUILD_FAILURE

//Return true to allow lattice building
/turf/proc/canBuildLattice()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/turf/proc/canBuildLattice() called tick#: [world.time]")
	return BUILD_FAILURE

//Return a lattice to allow plating building, return 0 for error message, return -1 for silent fail.
/turf/proc/canBuildPlating()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/turf/proc/canBuildPlating() called tick#: [world.time]")
	return BUILD_SILENT_FAILURE

/turf/proc/dismantle_wall()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/turf/proc/dismantle_wall() called tick#: [world.time]")
	return

/turf/change_area(oldarea, newarea)
	lighting_build_overlays()

/////////////////////////////////////////////////////

/turf/proc/spawn_powerup()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/turf/proc/spawn_powerup() called tick#: [world.time]")
	spawn(5)
		var/powerup = pick(
			50;/obj/structure/powerup/bombup,
			50;/obj/structure/powerup/fire,
			50;/obj/structure/powerup/skate,
			10;/obj/structure/powerup/kick,
			10;/obj/structure/powerup/line,
			10;/obj/structure/powerup/power,
			10;/obj/structure/powerup/skull,
			5;/obj/structure/powerup/full,
			)
		new powerup(src)
