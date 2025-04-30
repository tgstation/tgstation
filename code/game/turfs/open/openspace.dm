/turf/open/openspace
	name = "open space"
	desc = "Watch your step!"
	// We don't actually draw openspace, but it needs to have color
	// In its icon state so we can count it as a "non black" tile
	icon_state = MAP_SWITCH("pure_white", "invisible")
	baseturfs = /turf/open/openspace
	overfloor_placed = FALSE
	underfloor_accessibility = UNDERFLOOR_INTERACTABLE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	pathing_pass_method = TURF_PATHING_PASS_PROC
	plane = TRANSPARENT_FLOOR_PLANE
	layer = SPACE_LAYER
	rust_resistance = RUST_RESISTANCE_ABSOLUTE
	var/can_cover_up = TRUE
	var/can_build_on = TRUE

/turf/open/openspace/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/openspace/airless/planetary
	planetary_atmos = TRUE

// Reminder, any behavior code written here needs to be duped to /turf/open/space/openspace
// I am so sorry
/turf/open/openspace/Initialize(mapload) // handle plane and layer here so that they don't cover other obs/turfs in Dream Maker
	. = ..()
	if(PERFORM_ALL_TESTS(focus_only/openspace_clear) && !GET_TURF_BELOW(src))
		stack_trace("[src] was inited as openspace with nothing below it at ([x], [y], [z])")
	RegisterSignal(src, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON, PROC_REF(on_atom_created))
	var/area/our_area = loc
	if(istype(our_area, /area/space))
		force_no_gravity = TRUE
	return INITIALIZE_HINT_LATELOAD

/turf/open/openspace/LateInitialize()
	ADD_TURF_TRANSPARENCY(src, INNATE_TRAIT)

/turf/open/openspace/ChangeTurf(path, list/new_baseturfs, flags)
	UnregisterSignal(src, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON)
	return ..()

/**
 * Prepares a moving movable to be precipitated if Move() is successful.
 * This is done in Enter() and not Entered() because there's no easy way to tell
 * if the latter was called by Move() or forceMove() while the former is only called by Move().
 */
/turf/open/openspace/Enter(atom/movable/movable, atom/oldloc)
	. = ..()
	if(.)
		//higher priority than CURRENTLY_Z_FALLING so the movable doesn't fall on Entered()
		movable.set_currently_z_moving(CURRENTLY_Z_FALLING_FROM_MOVE)

///Makes movables fall when forceMove()'d to this turf.
/turf/open/openspace/Entered(atom/movable/movable)
	. = ..()
	if(movable.set_currently_z_moving(CURRENTLY_Z_FALLING))
		zFall(movable, falling_from_move = TRUE)
/**
 * Drops movables spawned on this turf after they are successfully initialized.
 * so that spawned movables that should fall to gravity, will fall.
 */
/turf/open/openspace/proc/on_atom_created(datum/source, atom/created_atom)
	SIGNAL_HANDLER
	if(ismovable(created_atom))
		zfall_if_on_turf(created_atom)

/turf/open/openspace/proc/zfall_if_on_turf(atom/movable/movable)
	if(QDELETED(movable) || movable.loc != src)
		return
	zFall(movable)

/turf/open/openspace/can_have_cabling()
	if(locate(/obj/structure/lattice/catwalk, src))
		return TRUE
	return FALSE

/turf/open/openspace/zAirIn()
	return TRUE

/turf/open/openspace/zAirOut()
	return TRUE

/turf/open/openspace/zPassIn(direction)
	if(direction == DOWN)
		for(var/obj/contained_object in contents)
			if(contained_object.obj_flags & BLOCK_Z_IN_DOWN)
				return FALSE
		return TRUE
	if(direction == UP)
		for(var/obj/contained_object in contents)
			if(contained_object.obj_flags & BLOCK_Z_IN_UP)
				return FALSE
		return TRUE
	return FALSE

/turf/open/openspace/zPassOut(direction)
	if(direction == DOWN)
		for(var/obj/contained_object in contents)
			if(contained_object.obj_flags & BLOCK_Z_OUT_DOWN)
				return FALSE
		return TRUE
	if(direction == UP)
		for(var/obj/contained_object in contents)
			if(contained_object.obj_flags & BLOCK_Z_OUT_UP)
				return FALSE
		return TRUE
	return FALSE

/turf/open/openspace/proc/CanCoverUp()
	return can_cover_up

/turf/open/openspace/proc/CanBuildHere()
	return can_build_on

/turf/open/openspace/attackby(obj/item/attacking_item, mob/user, list/modifiers)
	..()
	if(!CanBuildHere())
		return
	if(istype(attacking_item, /obj/item/stack/rods))
		build_with_rods(attacking_item, user)
	else if(ismetaltile(attacking_item))
		build_with_floor_tiles(attacking_item, user)
	else if(istype(attacking_item, /obj/item/stack/thermoplastic))
		build_with_transport_tiles(attacking_item, user)
	else if(istype(attacking_item, /obj/item/stack/sheet/mineral/titanium))
		build_with_titanium(attacking_item, user)

/turf/open/openspace/build_with_floor_tiles(obj/item/stack/tile/iron/used_tiles)
	if(!CanCoverUp())
		return
	return ..()

/turf/open/openspace/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	if(!CanBuildHere())
		return FALSE

	if(the_rcd.mode == RCD_TURF && the_rcd.rcd_design_path == /turf/open/floor/plating/rcd)
		var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
		if(L)
			return list("delay" = 0, "cost" = 1)
		else
			return list("delay" = 0, "cost" = 3)

	return FALSE

/turf/open/openspace/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, list/rcd_data)
	if(rcd_data["[RCD_DESIGN_MODE]"] == RCD_TURF && rcd_data["[RCD_DESIGN_PATH]"] == /turf/open/floor/plating/rcd)
		place_on_top(/turf/open/floor/plating, flags = CHANGETURF_INHERIT_AIR)
		return TRUE
	return FALSE

/turf/open/openspace/CanAStarPass(to_dir, datum/can_pass_info/pass_info)
	var/atom/movable/our_movable = pass_info.requester_ref.resolve()
	if(our_movable && !our_movable.can_z_move(DOWN, src, null, ZMOVE_FALL_FLAGS)) //If we can't fall here (flying/lattice), it's fine to path through
		return TRUE
	return FALSE

/turf/open/openspace/replace_floor(turf/open/new_floor_path, flags)
	if (!initial(new_floor_path.overfloor_placed))
		ChangeTurf(new_floor_path, flags = flags)
		return
	// Create plating under tiled floor we try to create directly onto the air
	place_on_top(/turf/open/floor/plating, flags = flags)
	place_on_top(new_floor_path, flags = flags)

/turf/open/openspace/can_cross_safely(atom/movable/crossing)
	return HAS_TRAIT(crossing, TRAIT_MOVE_FLYING) || !crossing.can_z_move(DOWN, src, z_move_flags = ZMOVE_FALL_FLAGS)

/turf/open/openspace/icemoon
	name = "ice chasm"
	baseturfs = /turf/open/openspace/icemoon
	initial_gas_mix = ICEMOON_DEFAULT_ATMOS
	planetary_atmos = TRUE
	/// Replaces itself with replacement_turf if the turf has the no ruins allowed flag (usually ruins themselves)
	var/protect_ruin = TRUE
	/// The turf that will replace this one if the turf below has the no ruins allowed flag. we use this one so we don't get any potential double whammies
	var/replacement_turf = /turf/open/misc/asteroid/snow/icemoon/do_not_chasm
	/// If true mineral turfs below this openspace turf will be mined automatically
	var/drill_below = TRUE

/turf/open/openspace/icemoon/Initialize(mapload)
	. = ..()
	var/turf/T = GET_TURF_BELOW(src)
	//I wonder if I should error here
	if(!T)
		return
	if(T.turf_flags & NO_RUINS && protect_ruin)
		var/turf/newturf = ChangeTurf(replacement_turf, null, CHANGETURF_IGNORE_AIR)
		if(!isopenspaceturf(newturf)) // only openspace turfs should be returning INITIALIZE_HINT_LATELOAD
			return INITIALIZE_HINT_NORMAL
		return
	if(!ismineralturf(T) || !drill_below)
		return
	var/turf/closed/mineral/M = T
	M.mineralAmt = 0
	M.gets_drilled()
	baseturfs = /turf/open/openspace/icemoon //This is to ensure that IF random turf generation produces a openturf, there won't be other turfs assigned other than openspace.

/turf/open/openspace/icemoon/keep_below
	drill_below = FALSE

/turf/open/openspace/xenobio
	name = "xenobio bz air"
	initial_gas_mix = XENOBIO_BZ

/turf/open/openspace/icemoon/ruins
	protect_ruin = FALSE
	drill_below = FALSE

/turf/open/openspace/telecomms
	initial_gas_mix = TCOMMS_ATMOS

/turf/open/openspace/coldroom
	initial_gas_mix = KITCHEN_COLDROOM_ATMOS
