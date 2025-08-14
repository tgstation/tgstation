/obj/golfcart_rear
	name = "golfcart rear"
	icon = 'icons/obj/toys/golfcart_split.dmi'
	icon_state = "cybe"
	density = TRUE
	var/obj/vehicle/ridden/golfcart/parent = null

/obj/vehicle/ridden/golfcart
	name = "all-terrain vehicle"
	desc = "An all-terrain vehicle built for traversing rough terrain with ease. One of the few old-Earth technologies that are still relevant on most planet-bound outposts."
	icon = 'icons/obj/toys/golfcart_glob.dmi'
	icon_state = "default"
	base_pixel_y = -32
	base_pixel_x = -32
	max_integrity = 150
	set_dir_on_move = FALSE
	armor_type = /datum/armor
	integrity_failure = 0.5
	var/obj/golfcart_rear/child = null

/datum/component/riding/vehicle/golfcart
	ride_check_flags = RIDER_NEEDS_LEGS | RIDER_NEEDS_ARMS | UNBUCKLE_DISABLED_RIDER
	vehicle_move_delay = 1.5

/datum/component/riding/vehicle/golfcart/driver_move(atom/movable/movable_parent, mob/living/user, direction)
	// calling parent IS the green light
	return ..()

/datum/component/riding/vehicle/golfcart/handle_ride(mob/user, direction)
	var/obj/vehicle/ridden/golfcart/cart = parent

	var/turf/next = get_step(cart, direction)
	var/turf/current = get_turf(cart)
	if(!istype(next) || !istype(current))
		return
	if(!turf_check(next, current))
		to_chat(user, span_warning("\The [cart] can not go onto [next]!"))
		return
	if(!Process_Spacemove(direction) || !isturf(cart.loc))
		return

	step(cart, direction)
	COOLDOWN_START(src, vehicle_move_cooldown, vehicle_move_delay)

	if(QDELETED(src))
		return
	update_parent_layer_and_offsets(cart.dir)
	return TRUE

/obj/vehicle/ridden/golfcart/Move(newloc, new_dir)
	var/old_dir = dir
	if (!ISDIAGONALDIR(new_dir))
		var/old_loc = loc
		. = ..()
		if (!.)
			setDir(old_dir)
			return .
		child.nudgeto(old_loc, dir)
		return .
	if (ISDIAGONALDIR(old_dir))
		balloon_alert_to_viewers("uh oh")
	var/atom/newloc_child = get_step(newloc, turn(old_dir, 180))
	if (!child.loc.Exit(child, new_dir))
		return FALSE
	if (!newloc_child.Enter(child))
		return FALSE
	. = ..()
	if (!.)
		setDir(old_dir)
		return .
	setDir(old_dir)
	child.nudgeto(newloc_child, old_dir)

/datum/component/riding/vehicle/golfcart/get_rider_offsets_and_layers(pass_index, mob/offsetter)
	return list(
		TEXT_NORTH = list(0, 4),
		TEXT_SOUTH = list(0, 4),
		TEXT_EAST =  list(0, 4),
		TEXT_WEST =  list(0, 4),
	)

/datum/component/riding/vehicle/atv/get_parent_offsets_and_layers()
	return list(
		TEXT_NORTH = list(0, 0, OBJ_LAYER),
		TEXT_SOUTH = list(0, 0, ABOVE_MOB_LAYER),
		TEXT_EAST =  list(0, 0, OBJ_LAYER),
		TEXT_WEST =  list(0, 0, OBJ_LAYER),
	)

/obj/golfcart_rear/Initialize(mapload, obj/vehicle/ridden/golfcart/progenitor)
	. = ..()
	parent = progenitor

/obj/golfcart_rear/Move(atom/newloc, direct, glide_size_override = 0, update_dir = TRUE, was_nudged = FALSE)
	if (was_nudged)
		return ..(newloc, direct, glide_size_override, update_dir)
	return parent.Move(step(parent, get_dir(loc, newloc), parent.dir))

/obj/golfcart_rear/proc/nudgeto(atom/new_loc)
	return Move(new_loc, dir, was_nudged = TRUE)

/obj/vehicle/ridden/golfcart/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/golfcart)
	child = new /obj/golfcart_rear(mapload, src)
	child.loc = get_step(src, NORTH)

/obj/vehicle/ridden/golfcart/post_buckle_mob(mob/living/M)
	return ..()

/obj/vehicle/ridden/golfcart/post_unbuckle_mob(mob/living/M)
	return ..()

/obj/vehicle/ridden/golfcart/atom_break()
	explosion(src, devastation_range = -1, light_impact_range = 2, flame_range = 3, flash_range = 4)
	return ..()

/obj/vehicle/ridden/golfcart/atom_destruction()
	explosion(src, devastation_range = -1, light_impact_range = 2, flame_range = 3, flash_range = 4)
	return ..()

/obj/vehicle/ridden/golfcart/Destroy()
	return ..()
