/// A cliff tile from where people can fall. Should generally fall downwards, but you can change it if you want
/turf/open/cliff
	icon_state = "cliff"
	icon = 'icons/turf/cliff/cliff.dmi'
	density = TRUE
	/// From our perspective, where does someone need to stand to be able to fall from us? Cardinal only, we do the diagonals automatically
	var/can_fall_from_direction = NORTH
	/// If we fall, in which direction?
	var/fall_direction = SOUTH
	/// Directions to which we can move towards while grinding down
	var/valid_move_dirs = SOUTH | WEST | EAST | SOUTHWEST | SOUTHEAST
	/// Speed at which we fall / traverse downwards
	var/fall_speed = 0.2 SECONDS
	/// Movables that can move freely on cliffs
	var/list/protected_types = list(/obj/projectile, /obj/effect, /mob/dead)
	/// Do we draw a tile as underlay for half tiles?
	var/turf/underlay_tile
	/// The pixel x of the underlay image
	var/undertile_pixel_x = 0
	/// The pixel y of the underlay image
	var/undertile_pixel_y = 0
	/// if given, sets the underlays plane to this
	var/underlay_plane

/turf/open/cliff/Initialize(mapload)
	. = ..()

	RegisterSignal(src, COMSIG_TURF_MOVABLE_THROW_LANDED, PROC_REF(on_turf_movable_throw_landed))

	if(isnull(underlay_tile))
		return
	var/image/underlay = image(icon_state = initial(underlay_tile.icon_state), icon = initial(underlay_tile.icon))
	underlay.pixel_x = undertile_pixel_x //if there's a pixel offset, correct it because we should be lined up with the grid
	underlay.pixel_y = undertile_pixel_y
	SET_PLANE(underlay, underlay_plane || plane, src)
	underlays += underlay

/turf/open/cliff/Destroy(force)
	UnregisterSignal(src, COMSIG_TURF_MOVABLE_THROW_LANDED)
	return ..()

/turf/open/cliff/CanPass(atom/movable/mover, border_dir)
	..()

	if(border_dir & can_fall_from_direction || !can_fall(mover))
		return TRUE

	return FALSE

/turf/open/cliff/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()

	try_fall(arrived)

/turf/open/cliff/zImpact(atom/movable/falling, levels, turf/prev_turf, flags)
	. = ..(flags = flags | FALL_INTERCEPTED)

/// Something landed on us
/turf/open/cliff/proc/on_turf_movable_throw_landed(turf/turf, atom/movable/arrived)
	SIGNAL_HANDLER

	try_fall(arrived)

/// Try and make them fall
/turf/open/cliff/proc/try_fall(atom/movable/arrived)
	if(can_fall(arrived))
		fall(arrived)

/// Check if they can fall from us
/turf/open/cliff/proc/can_fall(atom/movable/arrived)
	// Check if we're a protected type that doesnt make sense to fall (like effects and bullets)
	if(is_type_in_list(arrived, protected_types))
		return FALSE

	if(arrived.throwing || HAS_TRAIT(arrived, TRAIT_CLIFF_WALKER) || HAS_TRAIT(arrived, TRAIT_MOVE_FLYING))
		return FALSE

	// We're already falling
	if(arrived.anchored || (arrived in SScliff_falling.cliff_grinders))
		return FALSE

	// We can walk infront of the bottom cliff turf, so check that here
	if(!iscliffturf(get_step(src, fall_direction)) && !(get_dir(arrived, src) & fall_direction))
		return FALSE
	
	// gravity
	// marked in UNLINT due to a spacemandmm bug: https://github.com/SpaceManiac/SpacemanDMM/issues/382 (REMOVE ONCE FIXED!)
	if(UNLINT(!arrived.has_gravity(src)))
		return FALSE

	return TRUE

/// Make them fall!
/turf/open/cliff/proc/fall(atom/movable/arrived)
	SScliff_falling.start_falling(arrived, src) //the movement is handled by the subsystem, but we get asked about behaviour later
	on_fall(arrived)

/// We just fell onto this chasm tile
/turf/open/cliff/proc/on_fall(atom/movable/faller)
	if(!isliving(faller))
		return
	var/mob/living/living = faller
	living.Knockdown(fall_speed) //OUCH- OW- CRAP- SHIT- OW-
	living.spin(fall_speed, fall_speed)

/// Check if the movement direction we're moving on (while already falling on us) is valid
/turf/open/cliff/proc/can_move(atom/movable/mover, turf/target)
	//check if the relative direction we're moving is allowed, if not we block the movement
	if(!(valid_move_dirs & get_dir(src, target)))
		return FALSE

	//we're trying to leave the cliff from somewhere that's not the bottom? no can do pall
	if(!iscliffturf(target) && get_dir(src, target) != fall_direction)
		return FALSE

	return TRUE

/// Snowy cliff!
/turf/open/cliff/snowrock
	icon_state = "icerock_wall-0"
	icon = 'icons/turf/cliff/icerock_cliff.dmi'
	base_icon_state = "icerock_wall"

	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN_CLIFF
	canSmoothWith = SMOOTH_GROUP_TURF_OPEN_CLIFF
	layer = EDGED_TURF_LAYER
	plane = WALL_PLANE

	// This is static
	// Done like this to avoid needing to make it dynamic and save cpu time
	// 4 to the left, 4 down
	transform = MAP_SWITCH(TRANSLATE_MATRIX(-4, -4), matrix())

	undertile_pixel_x = 4
	undertile_pixel_y = 4

	initial_gas_mix = ICEMOON_DEFAULT_ATMOS
	planetary_atmos = TRUE

	underlay_tile = /turf/open/misc/asteroid/snow/icemoon
	underlay_plane = FLOOR_PLANE
