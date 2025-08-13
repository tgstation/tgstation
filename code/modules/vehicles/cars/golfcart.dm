/obj/golfcart_rear
	name = "golfcart rear"
	icon = 'icons/obj/toys/golfcart_split.dmi'
	icon_state = "rear"
	var/parent = null

/obj/vehicle/ridden/golfcart
	name = "all-terrain vehicle"
	desc = "An all-terrain vehicle built for traversing rough terrain with ease. One of the few old-Earth technologies that are still relevant on most planet-bound outposts."
	icon = 'icons/obj/toys/golfcart_split.dmi'
	icon_state = "front"
	max_integrity = 150
	armor_type = /datum/armor
	integrity_failure = 0.5
	var/obj/child = null

/datum/component/riding/vehicle/golfcart
	ride_check_flags = RIDER_NEEDS_LEGS | RIDER_NEEDS_ARMS | UNBUCKLE_DISABLED_RIDER
	vehicle_move_delay = 1.5

/datum/component/riding/vehicle/golfcart/driver_move(atom/movable/movable_parent, mob/living/user, direction)
	// calling parent IS the green light
	if (ISDIAGONALDIR(direction))
		return COMPONENT_DRIVER_BLOCK_MOVE
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

	var/old_loc = cart.loc
	cart.Move(next, direction, update_dir = FALSE)
	if (cart.loc != old_loc)
		cart.setDir(direction)
		cart.child.Move(old_loc, cart.dir)
	COOLDOWN_START(src, vehicle_move_cooldown, vehicle_move_delay)

	if(QDELETED(src))
		return
	update_parent_layer_and_offsets(cart.dir)
	return TRUE

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
	src.parent = progenitor

/obj/vehicle/ridden/golfcart/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/golfcart)
	child = new /obj/golfcart_rear(src)
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
