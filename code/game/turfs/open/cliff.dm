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

	var/list/protected_types = list(/obj/projectile, /obj/effect, /mob/dead)

/turf/open/cliff/Initialize(mapload)
	. = ..()

	RegisterSignal(src, COMSIG_TURF_MOVABLE_THROW_LANDED, PROC_REF(on_turf_movable_throw_landed))

/turf/open/cliff/CanPass(atom/movable/mover, border_dir)
	..()

	if(border_dir & can_fall_from_direction || !can_fall(mover))
		return TRUE
	return FALSE

/turf/open/cliff/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()

	try_fall(arrived)

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
	for(var/type in protected_types)
		if(istype(arrived, type))
			return FALSE

	if(arrived.throwing || HAS_TRAIT(arrived, TRAIT_CLIFF_WALKER) || HAS_TRAIT(arrived, TRAIT_MOVE_FLYING))
		return FALSE

	if(arrived.anchored || (arrived in SScliff_falling.cliff_grinders))
		return FALSE

	return TRUE

/// Make them fall!
/turf/open/cliff/proc/fall(atom/movable/arrived)
	SScliff_falling.start_falling(arrived, src) //the movement is handled by the subsystem, but we get asked about behaviour later
	on_fall(arrived)

/// We just fell onto this chasm tile
/turf/open/cliff/proc/on_fall(atom/movable/faller)
	if(isliving(faller))
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
	icon = 'icons/turf/walls/icerock_wall.dmi'
	base_icon_state = "icerock_wall"

	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER
	layer = EDGED_TURF_LAYER
	// This is static
	// Done like this to avoid needing to make it dynamic and save cpu time
	// 4 to the left, 4 down
	transform = MAP_SWITCH(TRANSLATE_MATRIX(-4, -4), matrix())

	initial_gas_mix = ICEMOON_DEFAULT_ATMOS
	planetary_atmos = TRUE

