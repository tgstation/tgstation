/turf
	icon = 'icons/turf/floors.dmi'
	level = 1

	var/intact = 1
	var/turf/baseturf = /turf/open/space

	var/temperature = T20C
	var/to_be_destroyed = 0 //Used for fire, if a melting temperature was reached, it will be destroyed
	var/max_fire_temperature_sustained = 0 //The max temperature of the fire which it was subjected to

	var/blocks_air = 0

	var/PathNode/PNode = null //associated PathNode in the A* algorithm

	flags = CAN_BE_DIRTY

	var/list/proximity_checkers

	var/image/obscured	//camerachunks

	var/list/image/blueprint_data //for the station blueprints, images of objects eg: pipes


/turf/New()
	..()

	levelupdate()
	if(smooth)
		smooth_icon(src)
	visibilityChanged()

	for(var/atom/movable/AM in src)
		Entered(AM)

/turf/proc/Initalize_Atmos(times_fired)
	CalculateAdjacentTurfs()

/turf/Destroy()
	visibilityChanged()
	..()
	return QDEL_HINT_HARDDEL_NOW

/turf/attack_hand(mob/user)
	user.Move_Pulled(src)

/turf/attackby(obj/item/C, mob/user, params)
	if(can_lay_cable() && istype(C, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/coil = C
		for(var/obj/structure/cable/LC in src)
			if((LC.d1==0)||(LC.d2==0))
				LC.attackby(C,user)
				return
		coil.place_turf(src, user)
		return 1

	return 0

/turf/Enter(atom/movable/mover as mob|obj, atom/forget as mob|obj|turf|area)
	if (!mover)
		return 1
	// First, make sure it can leave its square
	if(isturf(mover.loc))
		// Nothing but border objects stop you from leaving a tile, only one loop is needed
		for(var/obj/obstacle in mover.loc)
			if(!obstacle.CheckExit(mover, src) && obstacle != mover && obstacle != forget)
				mover.Bump(obstacle, 1)
				return 0

	var/list/large_dense = list()
	//Next, check objects to block entry that are on the border
	for(var/atom/movable/border_obstacle in src)
		if(border_obstacle.flags&ON_BORDER)
			if(!border_obstacle.CanPass(mover, mover.loc, 1) && (forget != border_obstacle))
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
		if(!obstacle.CanPass(mover, mover.loc, 1) && (forget != obstacle))
			mover.Bump(obstacle, 1)
			return 0
	return 1 //Nothing found to block so return success!

/turf/Entered(atom/movable/AM)
	for(var/A in proximity_checkers)
		var/atom/B = A
		B.HasProximity(AM)

/turf/open/Entered(atom/movable/AM)
	..()
	//slipping
	if (istype(AM,/mob/living/carbon))
		var/mob/living/carbon/M = AM
		if(M.movement_type & FLYING)
			return
		switch(wet)
			if(TURF_WET_WATER)
				if(!M.slip(0, 3, null, NO_SLIP_WHEN_WALKING))
					M.inertia_dir = 0
			if(TURF_WET_LUBE)
				if(M.slip(0, 4, null, (SLIDE|GALOSHES_DONT_HELP)))
					M.confused = max(M.confused, 8)
			if(TURF_WET_ICE)
				M.slip(0, 6, null, (SLIDE|GALOSHES_DONT_HELP))
			if(TURF_WET_PERMAFROST)
				M.slip(0, 6, null, (SLIDE_ICE|GALOSHES_DONT_HELP))
			if(TURF_WET_SLIDE)
				M.slip(0, 4, null, (SLIDE|GALOSHES_DONT_HELP))

/turf/proc/is_plasteel_floor()
	return 0

/turf/proc/levelupdate()
	for(var/obj/O in src)
		if(O.level == 1)
			O.hide(src.intact)

// override for space turfs, since they should never hide anything
/turf/open/space/levelupdate()
	for(var/obj/O in src)
		if(O.level == 1)
			O.hide(0)

// Removes all signs of lattice on the pos of the turf -Donkieyo
/turf/proc/RemoveLattice()
	var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
	if(L)
		qdel(L)

//Creates a new turf
/turf/proc/ChangeTurf(path, defer_change = FALSE)
	if(!path)
		return
	if(!use_preloader && path == type) // Don't no-op if the map loader requires it to be reconstructed
		return src
	var/old_blueprint_data = blueprint_data

	SSair.remove_from_active(src)

	Destroy()	//❄
	var/turf/W = new path(src)
	if(!defer_change)
		W.AfterChange()
	W.blueprint_data = old_blueprint_data
	return W

/turf/proc/AfterChange() //called after a turf has been replaced in ChangeTurf()
	levelupdate()
	CalculateAdjacentTurfs()

	if(!can_have_cabling())
		for(var/obj/structure/cable/C in contents)
			C.deconstruct()

	queue_smooth_neighbors(src)

/turf/open/AfterChange(ignore_air)
	..()
	RemoveLattice()
	if(!ignore_air)
		Assimilate_Air()

//////Assimilate Air//////
/turf/open/proc/Assimilate_Air()
	if(blocks_air)
		return

	var/datum/gas_mixture/total = new//Holders to assimilate air from nearby turfs
	var/list/total_gases = total.gases
	var/turf_count = LAZYLEN(atmos_adjacent_turfs)

	for(var/T in atmos_adjacent_turfs)
		var/turf/open/S = T
		if(!S.air)
			continue
		var/list/S_gases = S.air.gases
		for(var/id in S_gases)
			total.assert_gas(id)
			total_gases[id][MOLES] += S_gases[id][MOLES]
		total.temperature += S.air.temperature

	air.copy_from(total)

	if(!turf_count) //if there weren't any open turfs, no need to update.
		return

	var/list/air_gases = air.gases
	for(var/id in air_gases)
		air_gases[id][MOLES] /= turf_count //Averages contents of the turfs, ignoring walls and the like

	air.temperature /= turf_count
	air.holder = src
	SSair.add_to_active(src)

/turf/proc/ReplaceWithLattice()
	ChangeTurf(baseturf)
	new /obj/structure/lattice(locate(x, y, z))

/turf/proc/ReplaceWithCatwalk()
	ChangeTurf(baseturf)
	new /obj/structure/lattice/catwalk(locate(x, y, z))

/turf/proc/phase_damage_creatures(damage,mob/U = null)//>Ninja Code. Hurts and knocks out creatures on this turf //NINJACODE
	for(var/mob/living/M in src)
		if(M==U)
			continue//Will not harm U. Since null != M, can be excluded to kill everyone.
		M.adjustBruteLoss(damage)
		M.Paralyse(damage/5)
	for(var/obj/mecha/M in src)
		M.take_damage(damage*2, BRUTE, "melee", 1)

/turf/proc/Bless()
	flags |= NOJAUNT

/turf/storage_contents_dump_act(obj/item/weapon/storage/src_object, mob/user)
	if(src_object.contents.len)
		usr << "<span class='notice'>You start dumping out the contents...</span>"
		if(!do_after(usr,20,target=src_object))
			return 0
	for(var/obj/item/I in src_object)
		if(user.s_active != src_object)
			if(I.on_found(user))
				return
		src_object.remove_from_storage(I, src) //No check needed, put everything inside
	return 1

//////////////////////////////
//Distance procs
//////////////////////////////

//Distance associates with all directions movement
/turf/proc/Distance(var/turf/T)
	return get_dist(src,T)

//  This Distance proc assumes that only cardinal movement is
//  possible. It results in more efficient (CPU-wise) pathing
//  for bots and anything else that only moves in cardinal dirs.
/turf/proc/Distance_cardinal(turf/T)
	if(!src || !T) return 0
	return abs(x - T.x) + abs(y - T.y)

////////////////////////////////////////////////////

/turf/singularity_act()
	if(intact)
		for(var/obj/O in contents) //this is for deleting things like wires contained in the turf
			if(O.level != 1)
				continue
			if(O.invisibility == INVISIBILITY_MAXIMUM)
				O.singularity_act()
	ChangeTurf(src.baseturf)
	return(2)

/turf/proc/can_have_cabling()
	return 1

/turf/proc/can_lay_cable()
	return can_have_cabling() & !intact

/turf/proc/visibilityChanged()
	if(ticker)
		cameranet.updateVisibility(src)

/turf/proc/burn_tile()

/turf/proc/is_shielded()

/turf/contents_explosion(severity, target)
	var/affecting_level
	if(severity == 1)
		affecting_level = 1
	else if(is_shielded())
		affecting_level = 3
	else if(intact)
		affecting_level = 2
	else
		affecting_level = 1

	for(var/V in contents)
		var/atom/A = V
		if(A.level >= affecting_level)
			A.ex_act(severity, target)
			CHECK_TICK

/turf/ratvar_act(force)
	. = (prob(40) || force)
	for(var/I in src)
		var/atom/A = I
		if(ismob(A) || .)
			A.ratvar_act()

/turf/proc/add_blueprints(atom/movable/AM)
	var/image/I = new
	I.appearance = AM.appearance
	I.appearance_flags = RESET_COLOR|RESET_ALPHA|RESET_TRANSFORM
	I.loc = src
	I.setDir(AM.dir)
	I.alpha = 128

	if(!blueprint_data)
		blueprint_data = list()
	blueprint_data += I


/turf/proc/add_blueprints_preround(atom/movable/AM)
	if(!ticker || ticker.current_state != GAME_STATE_PLAYING)
		add_blueprints(AM)

/turf/proc/empty(turf_type=/turf/open/space)
	// Remove all atoms except observers, landmarks, docking ports
	var/turf/T0 = src
	for(var/A in T0.GetAllContents())
		if(istype(A, /mob/dead))
			continue
		if(istype(A, /obj/effect/landmark))
			continue
		if(istype(A, /obj/docking_port))
			continue
		qdel(A, force=TRUE)

	T0.ChangeTurf(turf_type)

	T0.redraw_lighting()
	SSair.remove_from_active(T0)
	T0.CalculateAdjacentTurfs()
	SSair.add_to_active(T0,1)

/turf/proc/is_transition_turf()
	return


/turf/acid_act(acidpwr, acid_volume)
	. = 1
	var/acid_type = /obj/effect/acid
	if(acidpwr >= 200) //alien acid power
		acid_type = /obj/effect/acid/alien
	var/has_acid_effect = 0
	for(var/obj/O in src)
		if(intact && O.level == 1) //hidden under the floor
			continue
		if(istype(O, acid_type))
			var/obj/effect/acid/A = O
			A.acid_level = min(A.level + acid_volume * acidpwr, 12000)//capping acid level to limit power of the acid
			has_acid_effect = 1
			continue
		O.acid_act(acidpwr, acid_volume)
	if(!has_acid_effect)
		new acid_type(src, acidpwr, acid_volume)


/turf/proc/acid_melt()
	return


/turf/proc/copyTurf(turf/T)
	if(T.type != type)
		var/obj/O
		if(underlays.len)	//we have underlays, which implies some sort of transparency, so we want to a snapshot of the previous turf as an underlay
			O = new()
			O.underlays.Add(T)
		T.ChangeTurf(type)
		if(underlays.len)
			T.underlays = O.underlays
	if(T.icon_state != icon_state)
		T.icon_state = icon_state
	if(T.icon != icon)
		T.icon = icon
	if(color)
		T.atom_colours = atom_colours.Copy()
		T.update_atom_colour()
	if(T.dir != dir)
		T.setDir(dir)
	return T

/turf/handle_fall(mob/faller, forced)
	faller.lying = pick(90, 270)
	if(!forced)
		return
	if(has_gravity(src))
		playsound(src, "bodyfall", 50, 1)
