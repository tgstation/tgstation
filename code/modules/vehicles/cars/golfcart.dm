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
	pixel_x = -32
	pixel_y = -32
	max_integrity = 150
	armor_type = /datum/armor
	interaction_flags_atom = parent_type::interaction_flags_atom | INTERACT_ATOM_MOUSEDROP_IGNORE_ADJACENT
	integrity_failure = 0.5
	var/obj/golfcart_rear/child = null
	var/obj/structure/closet/crate/crate = null

/obj/vehicle/ridden/golfcart/crowbar_act(mob/living/user, obj/item/tool)
	. = ..()
	if (!crate)
		return
	var/list/candidates = list(
		get_step(child, turn(dir, 180)),
		get_step(child, turn(dir, 90)),
		get_step(child, turn(dir, 270)),
	)
	for (var/atom/turf in candidates)
		if (turf.Enter(crate, src))
			crate.forceMove(turf)
			crate = null
			return ITEM_INTERACT_SUCCESS
	crate.forceMove(get_turf(child))
	crate = null
	return ITEM_INTERACT_SUCCESS

/obj/vehicle/ridden/golfcart/mouse_drop_receive(atom/dropped, mob/user, params)
	if (!istype(dropped, /obj/structure/closet/crate))
		return ..()
	var/obj/structure/closet/crate/dropped_crate = dropped
	balloon_alert_to_viewers(dropped_crate)
	if (crate)
		balloon_alert_to_viewers("already has crate")
		return
	dropped_crate.forceMove(src)
	crate = dropped_crate
	balloon_alert_to_viewers("attached crate")

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

/obj/vehicle/ridden/golfcart/proc/pre_move(atom/source, atom/new_loc)
	SIGNAL_HANDLER

	// see if space behind new loc is free
	var/atom/behind = get_step(new_loc, turn(dir, 180))
	if ((!behind.Enter(child, child.loc)) && behind != get_step(src, 0))
		return COMPONENT_MOVABLE_BLOCK_PRE_MOVE
	// otherwise permit move
	return

/obj/vehicle/ridden/golfcart/proc/dist_to(atom/thing)
	return min(get_dist(thing, loc), get_dist(thing.loc, child.loc))

/obj/vehicle/ridden/golfcart/proc/check_mousedroppable(atom/source, atom/target)
	balloon_alert_to_viewers("hello")
	return dist_to(target) > 1 ? COMPONENT_CANCEL_MOUSEDROPPED_ONTO : .

/obj/vehicle/ridden/golfcart/proc/on_canreach(atom/target, mob/source)
	SIGNAL_HANDLER

	if (!istype(target, /obj/vehicle/ridden/golfcart))
		return

	if (dist_to(target) <= 1)
		return COMPONENT_ALLOW_REACH
	return

/obj/vehicle/ridden/golfcart/Move(newloc, newdir)
	var/atom/old_loc = get_turf(src)
	var/old_dir = dir
	if (get_turf(child) == newloc)
		var/old_child_loc = child.loc
		child.loc = null
		. = ..(newloc, turn(newdir, 180))
		child.loc = old_child_loc
	else
		. = ..()
	var/atom/behind = get_step(src, turn(dir, 180))
	if (old_dir != dir && get_turf(src) == old_loc)
		if (!behind.Enter(child, child.loc))
			setDir(old_dir)
			behind = get_step(src, turn(dir, 180))
	if (!.)
		child.loc = behind
		return .
	child.loc = behind
	return .

/datum/component/riding/vehicle/golfcart/get_rider_offsets_and_layers(pass_index, mob/offsetter)
	return list(
		TEXT_NORTH = list(0, 4),
		TEXT_SOUTH = list(0, 4),
		TEXT_EAST =  list(0, 4),
		TEXT_WEST =  list(0, 4),
	)

/datum/component/riding/vehicle/golfcart/get_parent_offsets_and_layers()
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
	return parent.Move(get_step(parent, get_dir(loc, newloc)), parent.dir)

/obj/golfcart_rear/proc/nudgeto(atom/new_loc)
	return Move(new_loc, dir, was_nudged = TRUE)

/obj/vehicle/ridden/golfcart/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/golfcart)
	RegisterSignal(src, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(pre_move))
	RegisterSignal(src, COMSIG_ATOM_REACHABLE_BY, PROC_REF(on_canreach))
	RegisterSignal(src, COMSIG_MOUSEDROPPED_ONTO, PROC_REF(check_mousedroppable))
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
