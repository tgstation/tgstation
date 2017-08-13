/turf
	icon = 'icons/turf/floors.dmi'
	level = 1

	var/intact = 1
	var/turf/baseturf = /turf/open/space

	var/temperature = T20C
	var/to_be_destroyed = 0 //Used for fire, if a melting temperature was reached, it will be destroyed
	var/max_fire_temperature_sustained = 0 //The max temperature of the fire which it was subjected to

	var/blocks_air = FALSE

	flags = CAN_BE_DIRTY

	var/image/obscured	//camerachunks

	var/list/image/blueprint_data //for the station blueprints, images of objects eg: pipes

	var/explosion_level = 0	//for preventing explosion dodging
	var/explosion_id = 0

	var/list/decals
	var/requires_activation	//add to air processing after initialize?
	var/changing_turf = FALSE

/turf/vv_edit_var(var_name, new_value)
	var/static/list/banned_edits = list("x", "y", "z")
	if(var_name in banned_edits)
		return FALSE
	. = ..()

/turf/Initialize()
	if(initialized)
		stack_trace("Warning: [src]([type]) initialized multiple times!")
	initialized = TRUE

	levelupdate()
	if(smooth)
		queue_smooth(src)
	visibilityChanged()

	for(var/atom/movable/AM in src)
		Entered(AM)

	var/area/A = loc
	if(!IS_DYNAMIC_LIGHTING(src) && IS_DYNAMIC_LIGHTING(A))
		add_overlay(/obj/effect/fullbright)

	if(requires_activation)
		CalculateAdjacentTurfs()
		SSair.add_to_active(src)

	if (light_power && light_range)
		update_light()

	if (opacity)
		has_opaque_atom = TRUE
	return INITIALIZE_HINT_NORMAL

/turf/proc/Initalize_Atmos(times_fired)
	CalculateAdjacentTurfs()

/turf/Destroy(force)
	. = QDEL_HINT_IWILLGC
	if(!changing_turf)
		stack_trace("Incorrect turf deletion")
	changing_turf = FALSE
	if(force)
		..()
		//this will completely wipe turf state
		var/turf/B = new world.turf(src)
		for(var/A in B.contents)
			qdel(A)
		for(var/I in B.vars)
			B.vars[I] = null
		return
	SSair.remove_from_active(src)
	visibilityChanged()
	QDEL_LIST(blueprint_data)
	initialized = FALSE
	requires_activation = FALSE
	..()

/turf/attack_hand(mob/user)
	user.Move_Pulled(src)

/turf/proc/handleRCL(obj/item/weapon/twohanded/rcl/C, mob/user)
	if(C.loaded)
		for(var/obj/structure/cable/LC in src)
			if(!LC.d1 || !LC.d2)
				LC.handlecable(C, user)
				return
		C.loaded.place_turf(src, user)
		C.is_empty(user)

/turf/attackby(obj/item/C, mob/user, params)
	if(can_lay_cable() && istype(C, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/coil = C
		for(var/obj/structure/cable/LC in src)
			if(!LC.d1 || !LC.d2)
				LC.attackby(C,user)
				return
		coil.place_turf(src, user)
		return TRUE

	else if(istype(C, /obj/item/weapon/twohanded/rcl))
		handleRCL(C, user)

	return FALSE

/turf/CanPass(atom/movable/mover, turf/target)
	if(!target) return FALSE

	if(istype(mover)) // turf/Enter(...) will perform more advanced checks
		return !density

	stack_trace("Non movable passed to turf CanPass : [mover]")
	return FALSE

/turf/Enter(atom/movable/mover as mob|obj, atom/forget as mob|obj|turf|area)
	if (!mover)
		return TRUE
	// First, make sure it can leave its square
	if(isturf(mover.loc))
		// Nothing but border objects stop you from leaving a tile, only one loop is needed
		for(var/obj/obstacle in mover.loc)
			if(!obstacle.CheckExit(mover, src) && obstacle != mover && obstacle != forget)
				mover.Collide(obstacle)
				return FALSE

	var/list/large_dense = list()

	//Next, check objects to block entry that are on the border
	for(var/atom/movable/border_obstacle in src)
		if(border_obstacle.flags & ON_BORDER)
			if(!border_obstacle.CanPass(mover, mover.loc, 1) && (forget != border_obstacle))
				mover.Collide(border_obstacle)
				return FALSE
		else
			large_dense += border_obstacle

	//Then, check the turf itself
	if (!src.CanPass(mover, src))
		mover.Collide(src)
		return FALSE

	//Finally, check objects/mobs to block entry that are not on the border
	var/atom/movable/tompost_bump
	var/top_layer = FALSE
	for(var/atom/movable/obstacle in large_dense)
		if(!obstacle.CanPass(mover, mover.loc, 1) && (forget != obstacle))
			if(obstacle.layer > top_layer)
				tompost_bump = obstacle
				top_layer = obstacle.layer
	if(tompost_bump)
		mover.Collide(tompost_bump)
		return FALSE

	return TRUE //Nothing found to block so return success!

/turf/Entered(atom/movable/AM)
	..()
	if(explosion_level && AM.ex_check(explosion_id))
		AM.ex_act(explosion_level)

/turf/open/Entered(atom/movable/AM)
	..()
	//melting
	if(isobj(AM) && air && air.temperature > T0C)
		var/obj/O = AM
		if(HAS_SECONDARY_FLAG(O, FROZEN))
			O.make_unfrozen()

/turf/proc/is_plasteel_floor()
	return FALSE

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

//wrapper for ChangeTurf()s that you want to prevent/affect without overriding ChangeTurf() itself
/turf/proc/TerraformTurf(path, new_baseturf, defer_change = FALSE, ignore_air = FALSE, forceop = FALSE)
	return ChangeTurf(path, new_baseturf, defer_change, ignore_air, forceop)

//Creates a new turf
/turf/proc/ChangeTurf(path, new_baseturf, defer_change = FALSE, ignore_air = FALSE, forceop = FALSE)
	if(!path)
		return
	if(!GLOB.use_preloader && path == type && !forceop) // Don't no-op if the map loader requires it to be reconstructed
		return src

	var/old_opacity = opacity
	var/old_dynamic_lighting = dynamic_lighting
	var/old_affecting_lights = affecting_lights
	var/old_lighting_object = lighting_object
	var/old_corners = corners
 
	var/old_exl = explosion_level
	var/old_exi = explosion_id
	var/old_bp = blueprint_data
	blueprint_data = null

	var/old_baseturf = baseturf
	changing_turf = TRUE

	qdel(src)	//Just get the side effects and call Destroy
	var/turf/W = new path(src)

	if(new_baseturf)
		W.baseturf = new_baseturf
	else
		W.baseturf = old_baseturf

	W.explosion_id = old_exi
	W.explosion_level = old_exl

	if(!defer_change)
		W.AfterChange(ignore_air)

	W.blueprint_data = old_bp
 
	if(SSlighting.initialized)
		recalc_atom_opacity()
		lighting_object = old_lighting_object
		affecting_lights = old_affecting_lights
		corners = old_corners
		if (old_opacity != opacity || dynamic_lighting != old_dynamic_lighting)
			reconsider_lights()

		if (dynamic_lighting != old_dynamic_lighting)
			if (IS_DYNAMIC_LIGHTING(src))
				lighting_build_overlay()
			else
				lighting_clear_overlay()

		for(var/turf/open/space/S in RANGE_TURFS(1, src)) //RANGE_TURFS is in code\__HELPERS\game.dm
			S.update_starlight()

	return W

/turf/proc/AfterChange(ignore_air = FALSE) //called after a turf has been replaced in ChangeTurf()
	levelupdate()
	CalculateAdjacentTurfs()

	//update firedoor adjacency
	var/list/turfs_to_check = get_adjacent_open_turfs(src) | src
	for(var/I in turfs_to_check)
		var/turf/T = I
		for(var/obj/machinery/door/firedoor/FD in T)
			FD.CalculateAffectingAreas()

	queue_smooth_neighbors(src)

	HandleTurfChange(src)

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
	SSair.add_to_active(src)

/turf/proc/ReplaceWithLattice()
	ChangeTurf(baseturf)
	new /obj/structure/lattice(locate(x, y, z))

/turf/proc/phase_damage_creatures(damage,mob/U = null)//>Ninja Code. Hurts and knocks out creatures on this turf //NINJACODE
	for(var/mob/living/M in src)
		if(M==U)
			continue//Will not harm U. Since null != M, can be excluded to kill everyone.
		M.adjustBruteLoss(damage)
		M.Unconscious(damage * 4)
	for(var/obj/mecha/M in src)
		M.take_damage(damage*2, BRUTE, "melee", 1)

/turf/proc/Bless()
	flags |= NOJAUNT

/turf/storage_contents_dump_act(obj/item/weapon/storage/src_object, mob/user)
	if(src_object.contents.len)
		to_chat(usr, "<span class='notice'>You start dumping out the contents...</span>")
		if(!do_after(usr,20,target=src_object))
			return FALSE

	var/list/things = src_object.contents.Copy()
	var/datum/progressbar/progress = new(user, things.len, src)
	while (do_after(usr, 10, TRUE, src, FALSE, CALLBACK(src_object, /obj/item/weapon/storage.proc/mass_remove_from_storage, src, things, progress)))
		sleep(1)
	qdel(progress)

	return TRUE

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
	if(!src || !T) return FALSE
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
	return TRUE

/turf/proc/can_lay_cable()
	return can_have_cabling() & !intact

/turf/proc/visibilityChanged()
	GLOB.cameranet.updateVisibility(src)

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
			if(ismovableatom(A))
				var/atom/movable/AM = A
				if(!AM.ex_check(explosion_id))
					continue
			A.ex_act(severity, target)
			CHECK_TICK

/turf/narsie_act(force, ignore_mobs, probability = 20)
	. = (prob(probability) || force)
	for(var/I in src)
		var/atom/A = I
		if(ignore_mobs && ismob(A))
			continue
		if(ismob(A) || .)
			A.narsie_act()

/turf/ratvar_act(force, ignore_mobs, probability = 40)
	. = (prob(probability) || force)
	for(var/I in src)
		var/atom/A = I
		if(ignore_mobs && ismob(A))
			continue
		if(ismob(A) || .)
			A.ratvar_act()

/turf/proc/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	underlay_appearance.icon = icon
	underlay_appearance.icon_state = icon_state
	underlay_appearance.dir = adjacency_dir
	return TRUE

/turf/proc/add_blueprints(atom/movable/AM)
	var/image/I = new
	I.appearance = AM.appearance
	I.appearance_flags = RESET_COLOR|RESET_ALPHA|RESET_TRANSFORM
	I.loc = src
	I.setDir(AM.dir)
	I.alpha = 128

	LAZYADD(blueprint_data, I)


/turf/proc/add_blueprints_preround(atom/movable/AM)
	if(!SSticker.HasRoundStarted())
		add_blueprints(AM)

/turf/proc/empty(turf_type=/turf/open/space, baseturf_type, list/ignore_typecache, forceop = FALSE)
	// Remove all atoms except observers, landmarks, docking ports
	var/static/list/ignored_atoms = typecacheof(list(/mob/dead, /obj/effect/landmark, /obj/docking_port, /atom/movable/lighting_object))
	var/list/allowed_contents = typecache_filter_list_reverse(GetAllContents(ignore_typecache), ignored_atoms)
	allowed_contents -= src
	for(var/i in 1 to allowed_contents.len)
		var/thing = allowed_contents[i]
		qdel(thing, force=TRUE)

	var/turf/newT = ChangeTurf(turf_type, baseturf_type, FALSE, FALSE, forceop = forceop)

	SSair.remove_from_active(newT)
	newT.CalculateAdjacentTurfs()
	SSair.add_to_active(newT,1)

/turf/proc/is_transition_turf()
	return

/turf/acid_act(acidpwr, acid_volume)
	. = 1
	var/acid_type = /obj/effect/acid
	if(acidpwr >= 200) //alien acid power
		acid_type = /obj/effect/acid/alien
	var/has_acid_effect = FALSE
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
		for(var/group in decals)
			T.add_decal(decals[group],group)
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


/turf/proc/add_decal(decal,group)
	LAZYINITLIST(decals)
	if(!decals[group])
		decals[group] = list()
	decals[group] += decal
	add_overlay(decals[group])

/turf/proc/remove_decal(group)
	LAZYINITLIST(decals)
	cut_overlay(decals[group])
	decals[group] = null

/turf/proc/photograph(limit=20)
	var/image/I = new()
	I.overlays += src
	for(var/V in contents)
		var/atom/A = V
		if(A.invisibility)
			continue
		I.overlays += A
		if(limit)
			limit--
		else
			return I
	return I
