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
	var/static/base_movedelay = 1.5
	armor_type = /datum/armor/none
	interaction_flags_atom = parent_type::interaction_flags_atom | INTERACT_ATOM_MOUSEDROP_IGNORE_ADJACENT
	pass_flags_self = parent_type::pass_flags_self | LETPASSCLICKS
	integrity_failure = 0.5
	var/obj/golfcart_rear/child = null
	var/static/list/allowed_cargo = typecacheof(list(
		/obj/structure/closet/crate,
		/obj/structure/reagent_dispensers,
		/obj/machinery,
	))
	var/charge_per_move = STANDARD_CELL_CHARGE / 300
	var/static/list/banned_cargo = typecacheof(list(
		/obj/structure/reagent_dispensers/wall,
		// i mean it's a fucking door
		/obj/machinery/door,
	))
	var/obj/cargo = null
	var/obj/item/stock_parts/power_store/cell/cell = null
	var/hood_open = FALSE

/obj/vehicle/ridden/golfcart/proc/load(obj/to_load)
	if (!to_load)
		if (!cargo)
			return
		var/list/candidates = list(
			get_step(child, turn(dir, 180)),
			get_step(child, turn(dir, 90)),
			get_step(child, turn(dir, 270)),
		)
		for (var/atom/turf in candidates)
			if (turf.Enter(cargo, src))
				cargo.forceMove(turf)
				cargo = null
				update_appearance(UPDATE_ICON)
				return
		cargo.forceMove(get_turf(child))
		cargo = null
		update_appearance(UPDATE_ICON)
		return
	if (cargo)
		return
	if (to_load.anchored)
		return
	if (istype(to_load, /obj/structure/closet))
		var/obj/structure/closet/crate = to_load
		crate.close()
	to_load.forceMove(src)
	cargo = to_load
	update_appearance(UPDATE_ICON)

/obj/vehicle/ridden/golfcart/proc/unload()
	return load(null)

/obj/vehicle/ridden/golfcart/attackby(obj/item/attacking_item, mob/user, list/modifiers, list/attack_modifiers)
	if (!hood_open)
		return ..()
	if (!istype(attacking_item, /obj/item/stock_parts/power_store/cell))
		return ..()
	if (cell)
		balloon_alert(user, "Already has a cell!")
		// don't thwack the car
		return
	user.transferItemToLoc(attacking_item, src)
	cell = attacking_item
	balloon_alert(user, "Installed \the [cell].")

/obj/vehicle/ridden/golfcart/attack_hand(mob/living/user, list/modifiers)
	if (!hood_open)
		return ..()
	if (isnull(cell))
		return ..()
	var/obj/item/stock_parts/power_store/cell/cell_to_take = cell
	cell = null
	. = TRUE
	if (user.put_in_hands(cell_to_take))
		return
	cell_to_take.forceMove(drop_location())

/obj/golfcart_rear/attack_hand(mob/user, list/modifiers)
	if(!isnull(parent.cargo))
		parent.unload()
		return TRUE
	return ..()

/obj/golfcart_rear/crowbar_act(mob/living/user, obj/item/tool)
	. = ..()
	if (!parent.cargo)
		return
	tool.play_tool_sound(src, 50)
	parent.unload()
	return ITEM_INTERACT_SUCCESS

/obj/vehicle/ridden/golfcart/proc/open_hood()
	if (hood_open)
		return
	hood_open = TRUE
	update_appearance(UPDATE_ICON)

/obj/vehicle/ridden/golfcart/proc/close_hood()
	if (!hood_open)
		return
	hood_open = FALSE
	update_appearance(UPDATE_ICON)

/obj/vehicle/ridden/golfcart/click_alt(mob/user)
	. = ..()
	if (hood_open)
		close_hood()
		to_chat(user, span_notice("You shut \the [src]'s hood."))
		return
	open_hood()
	to_chat(user, span_notice("You pop \the [src]'s hood."))

/obj/golfcart_rear/mouse_drop_receive(atom/dropped, mob/user, params)
	if (!is_type_in_typecache(dropped, parent.allowed_cargo) || is_type_in_typecache(dropped, parent.banned_cargo))
		return ..()
	var/obj/dropped_obj = dropped
	return parent.load(dropped_obj)

/datum/component/riding/vehicle/golfcart
	ride_check_flags = RIDER_NEEDS_LEGS | RIDER_NEEDS_ARMS | UNBUCKLE_DISABLED_RIDER
	vehicle_move_delay = 1.5

/datum/component/riding/vehicle/golfcart/driver_move(atom/movable/movable_parent, mob/living/user, direction)
	if (!istype(parent, /obj/vehicle/ridden/golfcart))
		return ..()
	var/obj/vehicle/ridden/golfcart/cart = parent
	if (!cart.cell)
		return COMPONENT_DRIVER_BLOCK_MOVE
	if (cart.cell.charge <= 0)
		return COMPONENT_DRIVER_BLOCK_MOVE
	if (get_turf(cart.child) == get_step(cart, direction))
		cart.set_movedelay_effect(2)
	else
		cart.set_movedelay_effect(1)
	vehicle_move_delay = cart.movedelay
	return ..()

/datum/component/riding/vehicle/golfcart/handle_ride(mob/user, direction)
	if (!istype(parent, /obj/vehicle/ridden/golfcart))
		return ..()
	var/obj/vehicle/ridden/golfcart/cart = parent
	var/charge_to_use = min(cart.charge_per_move, cart.cell.charge)
	cart.cell.use(charge_to_use)
	return ..()

/obj/vehicle/ridden/golfcart/examine(mob/user)
	. = ..()
	if (cargo)
		. += span_info("The bed is holding \a [cargo].")
	if(!in_range(user, src) && !issilicon(user) && !isobserver(user))
		. += span_warning("You're too far away to examine [src]'s gauges.")
		return
	var/power = 0
	if (cell)
		power = floor(cell.charge / cell.maxcharge * 100)
	. += span_info("\The [src] currently is at [power]% charge.")
	if (hood_open)
		. += span_warning("The hood is open[isnull(cell) ? "!" : " and you can see \the [cell] inside!"]")

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

/datum/component/riding/vehicle/golfcart/update_parent_layer_and_offsets(dir, animate)
	. = ..()
	if (istype(parent, /obj))
		var/obj/objectified = parent
		objectified.update_appearance(UPDATE_ICON)

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
		TEXT_EAST =  list(0, 0, VEHICLE_LAYER),
		TEXT_WEST =  list(0, 0, VEHICLE_LAYER),
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
	cell = new /obj/item/stock_parts/power_store/cell/lead(src)
	cell.charge = cell.maxcharge
	update_appearance()

/obj/vehicle/ridden/golfcart/update_appearance(updates=ALL)
	. = ..()
	child.setDir(dir)
	child.update_appearance(updates)

/obj/vehicle/ridden/golfcart/proc/get_cargo_offsets(crate_x_offset = 0, crate_y_offset = 0)
	if (dir & NORTH)
		crate_y_offset += -30
	else if (dir & SOUTH)
		crate_y_offset += 30
	else if (dir & EAST)
		crate_x_offset += -32
	else if (dir & WEST)
		crate_x_offset += 32
	return vector(crate_x_offset, crate_y_offset)

/obj/vehicle/ridden/golfcart/proc/generate_cargo_overlay(crate_x_offset = 0, crate_y_offset = 0, layer=null)
	if (!cargo)
		return
	if (!layer)
		layer = src.layer
	var/vector/offsets = get_cargo_offsets(crate_x_offset, crate_y_offset)
	var/crate_layer_offset = 0
	if (dir & NORTH)
		crate_layer_offset = 0.01
	else if (dir & SOUTH)
		crate_layer_offset = -0.01
	var/list/overlays = list()
	if (cargo.icon)
		overlays += mutable_appearance(cargo.icon, cargo.icon_state, cargo.layer)
	overlays += cargo.update_overlays()
	for(var/i in 1 to overlays.len)
		var/entry = overlays[i]
		var/mutable_appearance/overlay = entry
		if(istext(entry))
			overlay = mutable_appearance(cargo.icon, entry, layer + crate_layer_offset)
			overlays[i] = overlay
		// nested lists may exist and i can't be asked to flatten them
		if (!isnull(overlay))
			overlay.layer = min(layer + crate_layer_offset + (overlay.layer - cargo.layer), ABOVE_MOB_LAYER + 0.01)
			overlay.pixel_x += offsets.x
			overlay.pixel_y += offsets.y
			overlay.pixel_z += 11
	return overlays

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
	if(!parent.cargo)
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

		roof_overlay = mutable_appearance(icon, "roof", ABOVE_MOB_LAYER + 0.02)
		roof_overlay.pixel_y = 31
		roof_overlay.pixel_x = -10
	else if (dir & WEST)
		lower_overlay.pixel_x = 32
		lower_overlay.layer -= 0.02

		roof_overlay = mutable_appearance(icon, "roof", ABOVE_MOB_LAYER + 0.02)
		roof_overlay.pixel_y = 31
		roof_overlay.pixel_x = 10
	. += lower_overlay
	. += rear_overlay
	if (hood_open)
		. += mutable_appearance(icon, "hood", layer + 0.01)
	if (roof_overlay)
		. += roof_overlay
	if (cargo)
		. += generate_cargo_overlay()

/obj/vehicle/ridden/golfcart/post_buckle_mob(mob/living/M)
	if (M.pulling)
		M.stop_pulling()
	return ..()

/obj/vehicle/ridden/golfcart/post_unbuckle_mob(mob/living/M)
	update_appearance(UPDATE_ICON) // because for some reason the overlays aren't properly redrawn
	return ..()

/obj/vehicle/ridden/golfcart/atom_break()
	explosion(src, devastation_range = -1, light_impact_range = 2, flame_range = 3, flash_range = 4)
	return ..()

/obj/vehicle/ridden/golfcart/atom_destruction()
	explosion(src, devastation_range = -1, light_impact_range = 2, flame_range = 3, flash_range = 4)
	return ..()

/obj/golfcart_rear/Destroy()
	if (!QDELETED(parent))
		qdel(parent)
	parent = null
	return ..()

/obj/vehicle/ridden/golfcart/Destroy()
	if (!QDELETED(child))
		qdel(child)
	child = null
	if (cargo && !QDELETED(cargo))
		cargo.forceMove(drop_location())
	cargo = null
	if (!QDELETED(cell))
		qdel(cell)
	cell = null
	return ..()
