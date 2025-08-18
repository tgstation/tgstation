/obj/golfcart_rear
	name = "golfcart rear"
	icon = 'icons/obj/toys/golfcart_hitbox.dmi'
	density = TRUE
	base_pixel_x = -32
	base_pixel_y = -32
	pixel_x = -32
	pixel_y = -32
	alpha = 128
	glide_size = MAX_GLIDE_SIZE
	layer = ABOVE_ALL_MOB_LAYER
	var/obj/vehicle/ridden/golfcart/parent = null

/obj/vehicle/ridden/golfcart
	name = "all-terrain vehicle"
	desc = "An all-terrain vehicle built for traversing rough terrain with ease. One of the few old-Earth technologies that are still relevant on most planet-bound outposts."
	icon = 'icons/obj/toys/golfcart_split.dmi'
	icon_state = "front"
	max_integrity = 150
	var/static/base_movedelay = 2
	armor_type = /datum/armor/none
	interaction_flags_atom = parent_type::interaction_flags_atom | INTERACT_ATOM_MOUSEDROP_IGNORE_ADJACENT
	pass_flags_self = parent_type::pass_flags_self | LETPASSCLICKS
	integrity_failure = 0.5
	var/obj/golfcart_rear/child = null
	var/obj/structure/closet/crate/crate = null

/obj/vehicle/ridden/golfcart/proc/load(obj/structure/closet/crate/to_load)
	if (!to_load)
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
				update_appearance(UPDATE_ICON)
				return
		crate.forceMove(get_turf(child))
		crate = null
		update_appearance(UPDATE_ICON)
		return
	if (crate)
		return
	to_load.close()
	to_load.forceMove(src)
	crate = to_load
	update_appearance(UPDATE_ICON)

/obj/vehicle/ridden/golfcart/proc/unload()
	return load(null)

/obj/golfcart_rear/attack_hand(mob/user, list/modifiers)
	if(loc == user || (istype(loc, /turf) && !isnull(parent.crate)))
		parent.unload()
		return TRUE
	return ..()

/obj/golfcart_rear/crowbar_act(mob/living/user, obj/item/tool)
	. = ..()
	if (!parent.crate)
		return
	tool.play_tool_sound(src, 50)
	parent.unload()
	return ITEM_INTERACT_SUCCESS

/obj/golfcart_rear/mouse_drop_receive(atom/dropped, mob/user, params)
	if (!istype(dropped, /obj/structure/closet/crate))
		return ..()
	var/obj/structure/closet/crate/dropped_crate = dropped
	parent.load(dropped_crate)

/datum/component/riding/vehicle/golfcart
	ride_check_flags = RIDER_NEEDS_LEGS | RIDER_NEEDS_ARMS | UNBUCKLE_DISABLED_RIDER
	vehicle_move_delay = 1.5

/datum/component/riding/vehicle/golfcart/driver_move(atom/movable/movable_parent, mob/living/user, direction)
	if (!istype(parent, /obj/vehicle/ridden/golfcart))
		return ..()
	var/obj/vehicle/ridden/golfcart/cart = parent
	if (get_turf(cart.child) == get_step(cart, direction))
		cart.set_movedelay_effect(2)
	else
		cart.set_movedelay_effect(1)
	vehicle_move_delay = cart.movedelay
	return ..()

/datum/component/riding/vehicle/golfcart/handle_ride(mob/user, direction)
	return ..()

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

/obj/vehicle/ridden/golfcart/proc/set_movedelay_effect(modification)
	movedelay = base_movedelay * modification
	child.set_glide_size(DELAY_TO_GLIDE_SIZE(movedelay))

/obj/vehicle/ridden/golfcart/Move(atom/newloc, direct, glide_size_override = 0, update_dir = TRUE)
	var/atom/old_loc = get_turf(src)
	var/old_dir = dir
	if (get_turf(child) == newloc)
		set_movedelay_effect(2)
		var/old_child_loc = child.loc
		child.loc = null
		. = ..(newloc, turn(direct, 180))
		child.loc = old_child_loc
	else
		set_movedelay_effect(1)
		. = ..()
	var/atom/behind = get_step(src, turn(dir, 180))
	if (old_dir != dir && get_turf(src) == old_loc)
		if (!behind.Enter(child, child.loc))
			setDir(old_dir)
			behind = get_step(src, turn(dir, 180))
	update_appearance(UPDATE_ICON)
	child.forceMove(behind)
	return .

/datum/component/riding/vehicle/golfcart/get_rider_offsets_and_layers(pass_index, mob/offsetter)
	return list(
		TEXT_NORTH = list(0, -16),
		TEXT_SOUTH = list(0, 10),
		TEXT_EAST =  list(-8, 2),
		TEXT_WEST =  list(8, 2),
	)

/datum/component/riding/vehicle/golfcart/get_parent_offsets_and_layers()
	return list(
		TEXT_NORTH = list(0, 0, ABOVE_MOB_LAYER),
		TEXT_SOUTH = list(0, 0, ABOVE_MOB_LAYER),
		TEXT_EAST =  list(0, 0, OBJ_LAYER),
		TEXT_WEST =  list(0, 0, OBJ_LAYER),
	)

/obj/golfcart_rear/Initialize(mapload, obj/vehicle/ridden/golfcart/progenitor)
	. = ..()
	parent = progenitor

/proc/normalize_dir(dir)
	if(dir & (EAST|WEST))
		return (dir & EAST) ? EAST : WEST
	else if(dir & (NORTH|SOUTH))
		return (dir & NORTH) ? NORTH : SOUTH
	return dir

/obj/golfcart_rear/Move(atom/newloc, direct, glide_size_override = 0, update_dir = TRUE)
	if(pulledby)
		var/olddir = dir
		var/newdir = normalize_dir(direct)
		. = ..()
		dir = newdir
		if (get_step(src, turn(dir, 180)) != get_turf(pulledby))
			setDir(turn(dir, 180))
		var/atom/behind = get_step(src, dir)
		if (!behind.Enter(parent))
			setDir(olddir)
			behind = get_step(src, dir)
		parent.set_glide_size(pulledby.glide_size)
		parent.forceMove(behind)
		parent.setDir(dir)
		parent.update_appearance(UPDATE_ICON)
		return

	return parent.Move(get_step(parent, get_dir(loc, newloc)), direct)

/obj/vehicle/ridden/golfcart/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/golfcart)
	RegisterSignal(src, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(pre_move))
	child = new /obj/golfcart_rear(mapload, src)
	child.loc = get_step(src, NORTH)
	update_appearance()

/obj/vehicle/ridden/golfcart/update_appearance(updates=ALL)
	. = ..()
	child.setDir(dir)
	child.update_appearance(updates)

/obj/vehicle/ridden/golfcart/proc/generate_cargo_overlay(crate_x_offset = 0, crate_y_offset = 0, layer=null)
	if (!crate)
		return
	if (!layer)
		layer = src.layer
	var/crate_layer_offset = 0
	if (dir & NORTH)
		crate_y_offset += -30
		crate_layer_offset = 0.01
	else if (dir & SOUTH)
		crate_y_offset += 30
	else if (dir & EAST)
		crate_x_offset += -32
	else if (dir & WEST)
		crate_x_offset += 32
	var/mutable_appearance/crate_overlay = mutable_appearance(crate.icon, crate.icon_state, layer + crate_layer_offset)
	crate_overlay.pixel_x = crate_x_offset
	crate_overlay.pixel_y = crate_y_offset
	crate_overlay.pixel_z = initial(crate.pixel_z) + 11
	return crate_overlay

/obj/vehicle/ridden/golfcart/proc/get_rear_offset()
	var/x = 0
	var/y = 0
	if (dir & NORTH)
		y = -32
	else if (dir & SOUTH)
		y = 32
	else if (dir & EAST)
		x = -32
	else if (dir & WEST)
		x = 32
	return vector(x, y)

/obj/golfcart_rear/update_overlays()
	. = ..()
	if(!parent.crate)
		return
	var/vector/rear_offsets = parent.get_rear_offset()
	. += parent.generate_cargo_overlay(-rear_offsets.x - base_pixel_x, -rear_offsets.y - base_pixel_y, layer=layer)

/obj/vehicle/ridden/golfcart/update_overlays()
	. = ..()
	var/mutable_appearance/lower_overlay = mutable_appearance(icon, "lower", OBJ_LAYER)
	var/mutable_appearance/roof_overlay = null
	var/mutable_appearance/rear_overlay = mutable_appearance(icon, "rear", layer)
	var/vector/rear_offsets = get_rear_offset()
	rear_overlay.pixel_x = rear_offsets.x
	rear_overlay.pixel_y = rear_offsets.y
	if (dir & NORTH)
	else if (dir & SOUTH)
		lower_overlay.pixel_y = 32
	else if (dir & EAST)
		lower_overlay.pixel_x = -32
		lower_overlay.layer -= 0.02

		roof_overlay = mutable_appearance(icon, "roof", ABOVE_MOB_LAYER)
		roof_overlay.pixel_y = 31
		roof_overlay.pixel_x = -10
	else if (dir & WEST)
		lower_overlay.pixel_x = 32
		lower_overlay.layer -= 0.02

		roof_overlay = mutable_appearance(icon, "roof", ABOVE_MOB_LAYER)
		roof_overlay.pixel_y = 31
		roof_overlay.pixel_x = 10
	. += lower_overlay
	. += rear_overlay
	if (roof_overlay)
		. += roof_overlay
	if (crate)
		. += generate_cargo_overlay()

/obj/vehicle/ridden/golfcart/post_buckle_mob(mob/living/M)
	if (M.pulling)
		M.stop_pulling()
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
