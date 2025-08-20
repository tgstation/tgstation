#define ENGINE_UNWRENCHED 0
#define ENGINE_WRENCHED 1
#define ENGINE_WELDED 2
#define GOLFCART_RIDING_SOURCE "riding_golfcart"
#define CART_VERTICAL_LAYER (ABOVE_MOB_LAYER)
#define CARGO_HITBOX_LAYER (ABOVE_ALL_MOB_LAYER)
#define BELOW_HUMAN_HITBOX_LAYER (CART_VERTICAL_LAYER + 0.01)
#define HUMAN_RIDING_LAYER (CART_VERTICAL_LAYER + 0.02)
#define CART_ROOF_LAYER (CARGO_HITBOX_LAYER + 0.01)
#define CART_LOWER_LAYER (OBJ_LAYER)
#define HUMAN_LOWER_LAYER (MOB_LAYER)

/obj/golfcart_rear
	name = "golf cart bed"
	icon = 'icons/obj/toys/golfcart_split.dmi'
	icon_state = "rear_hitbox"
	density = TRUE
	alpha = 1
	can_buckle = TRUE
	max_buckled_mobs = 2
	glide_size = MAX_GLIDE_SIZE
	layer = BELOW_HUMAN_HITBOX_LAYER
	var/obj/vehicle/ridden/golfcart/parent = null

/obj/vehicle/ridden/golfcart
	name = "golf cart"
	desc = "An all-purpose cargo hauling vehicle."
	icon = 'icons/obj/toys/golfcart_split.dmi'
	icon_state = "front"
	max_integrity = 150
	var/static/base_movedelay = 1.5
	var/static/hotrod_base_movedelay = 0.75
	armor_type = /datum/armor/none
	interaction_flags_atom = parent_type::interaction_flags_atom | INTERACT_ATOM_MOUSEDROP_IGNORE_ADJACENT
	pass_flags_self = parent_type::pass_flags_self | LETPASSCLICKS
	integrity_failure = 0.5
	layer = ABOVE_MOB_LAYER
	max_occupants = 1
	var/obj/item/v8_engine/engine = null
	var/engine_state = null
	var/obj/golfcart_rear/child = null
	var/static/list/allowed_cargo = typecacheof(list(
		/obj/structure/closet/crate,
		/obj/structure/reagent_dispensers,
		/obj/machinery,
		/obj/item/kirbyplants,
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
		var/atom/dropoff = get_turf(child)
		for (var/atom/turf in candidates)
			if (turf.Enter(cargo, src))
				dropoff = turf
				break
		cargo.forceMove(dropoff)
		cargo = null
		child.layer = BELOW_HUMAN_HITBOX_LAYER
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
	child.layer = CARGO_HITBOX_LAYER
	update_appearance(UPDATE_ICON)

/obj/vehicle/ridden/golfcart/proc/unload()
	return load(null)

/obj/vehicle/ridden/golfcart/proc/is_hotrod()
	return engine && engine_state && engine_state == ENGINE_WELDED

/obj/vehicle/ridden/golfcart/proc/thrown_mob_landed(atom/thrown_atom)
	if (!isliving(thrown_atom))
		UnregisterSignal(thrown_atom, COMSIG_MOVABLE_THROW_LANDED)
		return
	var/mob/living/thrown_mob = thrown_atom
	thrown_mob.Knockdown(3 SECONDS)
	UnregisterSignal(thrown_atom, COMSIG_MOVABLE_THROW_LANDED)

/obj/vehicle/ridden/golfcart/Bump(atom/bumped_atom)
	if (..())
		return
	if (!is_hotrod())
		return
	if(!isliving(bumped_atom))
		return
	var/mob/living/mob = bumped_atom
	mob.throw_at(get_edge_target_turf(mob, dir), 2, 3)
	RegisterSignal(mob, COMSIG_MOVABLE_THROW_LANDED, PROC_REF(thrown_mob_landed))
	mob.visible_message(
		span_danger("[src] hits [mob] at full speed!"),
		span_userdanger("[src] slams into you!"),
	)

/obj/vehicle/ridden/golfcart/proc/run_over(var/mob/living/victim)
	if (!has_gravity())
		victim.throw_at(get_edge_target_turf(victim, dir), 4, 3)
		RegisterSignal(victim, COMSIG_MOVABLE_THROW_LANDED, PROC_REF(thrown_mob_landed))
		return
	if (istype(victim, /mob/living/carbon))
		var/mob/living/carbon/person = victim
		if (person.body_position == LYING_DOWN)
			log_combat(src, victim, "run over", addition = "(DAMTYPE: [uppertext(BRUTE)])")
			playsound(src, 'sound/effects/pop_expl.ogg', 50, TRUE)
			playsound(src, 'sound/effects/splat.ogg', 50, TRUE)
			victim.visible_message(
				span_danger("[src] drives over [victim]!"),
				span_userdanger("[src] drives over you!"),
			)

			var/damage = rand(5, 15)
			person.apply_damage(2 * damage, BRUTE, BODY_ZONE_HEAD)
			person.apply_damage(2 * damage, BRUTE, BODY_ZONE_CHEST)
			person.apply_damage(0.5 * damage, BRUTE, BODY_ZONE_L_LEG)
			person.apply_damage(0.5 * damage, BRUTE, BODY_ZONE_R_LEG)
			person.apply_damage(0.5 * damage, BRUTE, BODY_ZONE_L_ARM)
			person.apply_damage(0.5 * damage, BRUTE, BODY_ZONE_R_ARM)

			add_mob_blood(person)
			var/turf/below_us = get_turf(src)
			below_us.add_mob_blood(person)

			AddComponent(/datum/component/blood_walk, \
				blood_type = /obj/effect/decal/cleanable/blood/tracks, \
				target_dir_change = TRUE, \
				transfer_blood_dna = TRUE, \
				max_blood = 4)

/obj/vehicle/ridden/golfcart/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	if (!is_hotrod())
		return
	for(var/mob/living/future_pancake in loc)
		run_over(future_pancake)


/obj/vehicle/ridden/golfcart/proc/install_cell(obj/item/stock_parts/power_store/cell/cell_to_install, mob/user)
	if (cell || engine)
		balloon_alert(user, "already has an engine!")
		return FALSE
	user.transferItemToLoc(cell_to_install, src)
	cell = cell_to_install
	balloon_alert(user, "installed \the [cell]")
	return TRUE

/obj/vehicle/ridden/golfcart/proc/install_engine(obj/item/v8_engine/engine_to_install, mob/user)
	if (engine || cell)
		balloon_alert(user, "already has an engine!")
		return FALSE
	user.transferItemToLoc(engine_to_install, src)
	engine = engine_to_install
	engine_state = ENGINE_UNWRENCHED
	balloon_alert(user, "installed \the [engine]")
	return TRUE

/obj/vehicle/ridden/golfcart/attackby(obj/item/attacking_item, mob/user, list/modifiers, list/attack_modifiers)
	. = FALSE
	if (!hood_open)
		return ..()
	if (istype(attacking_item, /obj/item/v8_engine))
		. = install_engine(attacking_item, user)
	if (istype(attacking_item, /obj/item/stock_parts/power_store/cell))
		. = install_cell(attacking_item, user)
	if (!.)
		. = ..()
	return

/obj/vehicle/ridden/golfcart/attack_hand(mob/living/user, list/modifiers)
	if (!hood_open)
		return ..()
	if (engine && engine_state == ENGINE_UNWRENCHED)
		. = TRUE
		var/obj/item/engine_item = engine
		engine_state = null
		engine = null
		if (user.put_in_hands(engine_item))
			return
		engine_item.forceMove(drop_location())
		return
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

/obj/vehicle/ridden/golfcart/proc/can_wrench_engine()
	return hood_open && engine && (engine_state == ENGINE_UNWRENCHED || engine_state == ENGINE_WRENCHED)

/obj/vehicle/ridden/golfcart/proc/can_weld_engine()
	return hood_open && engine && (engine_state == ENGINE_WRENCHED || engine_state == ENGINE_WELDED)

/obj/vehicle/ridden/golfcart/proc/set_engine_state(state)
	engine_state = state
	update_appearance(UPDATE_ICON)

/obj/vehicle/ridden/golfcart/wrench_act(mob/living/user, obj/item/tool)
	if (!can_wrench_engine())
		return ..()
	tool.play_tool_sound(src, 50)
	if (!tool.use_tool(src, user, 3 SECONDS, extra_checks = CALLBACK(src, PROC_REF(can_wrench_engine))))
		return ITEM_INTERACT_BLOCKING
	if (engine_state == ENGINE_WRENCHED)
		set_engine_state(ENGINE_UNWRENCHED)
	else if (engine_state == ENGINE_UNWRENCHED)
		set_engine_state(ENGINE_WRENCHED)
	playsound(src, 'sound/items/deconstruct.ogg', 50, TRUE)
	return ITEM_INTERACT_SUCCESS

/obj/vehicle/ridden/golfcart/welder_act(mob/living/user, obj/item/tool)
	if(!tool.tool_start_check(user, amount = 1))
		return ITEM_INTERACT_BLOCKING
	if(!tool.use_tool(src, user, 3 SECONDS, amount = 1, volume = 50, extra_checks = CALLBACK(src, PROC_REF(can_weld_engine))))
		return ITEM_INTERACT_BLOCKING
	if (engine_state == ENGINE_WRENCHED)
		set_engine_state(ENGINE_WELDED)
	else if (engine_state == ENGINE_WELDED)
		set_engine_state(ENGINE_WRENCHED)
	return ITEM_INTERACT_SUCCESS

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
	if (has_buckled_mobs())
		user.balloon_alert("blocked!")
		return ..()
	var/obj/dropped_obj = dropped
	return parent.load(dropped_obj)

/datum/component/riding/vehicle/golfcart
	ride_check_flags = RIDER_NEEDS_LEGS | RIDER_NEEDS_ARMS | UNBUCKLE_DISABLED_RIDER
	vehicle_move_delay = 1.5

/datum/component/riding/vehicle/golfcart/restore_parent_layer_and_offsets()
	// just don't restore anything
	return

/datum/component/riding/vehicle/golfcart/driver_move(atom/movable/movable_parent, mob/living/user, direction)
	if (!istype(parent, /obj/vehicle/ridden/golfcart))
		return ..()
	var/obj/vehicle/ridden/golfcart/cart = parent
	if (!cart.cell && !cart.is_hotrod())
		return COMPONENT_DRIVER_BLOCK_MOVE
	if (cart.cell)
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
	if (cart.cell)
		var/charge_to_use = min(cart.charge_per_move, cart.cell.charge)
		cart.cell.use(charge_to_use)
	return ..()

/obj/golfcart_rear/examine(mob/user)
	if (!parent)
		. = ..()
		. += span_warning("A lone golf cart bed must be a bad omen...")
		return
	return parent.examine(user)

/obj/golfcart_rear/examine_more(mob/user)
	if (!parent)
		return ..()
	return parent.examine_more(user)

/obj/vehicle/ridden/golfcart/examine_more(mob/user)
	. = ..()
	if (!cargo)
		return
	. += span_slightly_larger("It is currently transporting the [cargo]")
	. += cargo.examine(user)

/obj/vehicle/ridden/golfcart/examine(mob/user)
	. = ..()
	if (cargo)
		. += span_info("The bed is holding \the [cargo].")
	if(!in_range(user, src) && !issilicon(user) && !isobserver(user))
		. += span_warning("You're too far away to examine [src] closely.")
		return
	if (!engine)
		var/power = 0
		if (cell)
			power = floor(cell.charge / cell.maxcharge * 100)
		. += span_info("It is currently is at [power]% charge.")
	if (hood_open)
		. += span_warning("The hood is open!")
		if (engine)
			. += span_info("You can see \the [engine] inside.")
			if (engine_state == ENGINE_UNWRENCHED)
				. += span_notice("It needs to be [EXAMINE_HINT("wrenched")] into place.")
			else if (engine_state == ENGINE_WRENCHED)
				. += span_notice("It needs to be [EXAMINE_HINT("welded")] down.")
			// last state is ENGINE_WELDED
		else
			. += span_info("You can see \the [cell] inside.")
			. += span_smallnotice("If you remove the cell you could probably install another power source...")

/obj/golfcart_rear/doMove(atom/destination)
	. = ..()
	for(var/mob/living/buckled_mob as anything in buckled_mobs)
		buckled_mob.Move(destination, dir)
		// realistically should do something if move fails but not sure what

/obj/golfcart_rear/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if (parent && parent.allow_crawler_through(mover))
		return TRUE

/obj/vehicle/ridden/golfcart/proc/allow_crawler_through(atom/crawler)
	if (!isliving(crawler))
		return FALSE
	var/mob/living/living_crawler = crawler
	return living_crawler.body_position == LYING_DOWN

/obj/vehicle/ridden/golfcart/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if (allow_crawler_through(mover))
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

/obj/vehicle/ridden/golfcart/proc/set_movedelay_effect(modification)
	var/base_movedelay_effect = base_movedelay
	if (is_hotrod())
		base_movedelay_effect = hotrod_base_movedelay
	movedelay = base_movedelay_effect * modification
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
		TEXT_NORTH = list(0, 0, CART_VERTICAL_LAYER),
		TEXT_SOUTH = list(0, 0, CART_VERTICAL_LAYER),
		TEXT_EAST =  list(0, 0, VEHICLE_LAYER),
		TEXT_WEST =  list(0, 0, VEHICLE_LAYER),
	)

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

/obj/golfcart_rear/proc/allow_movement_between_passengers(atom/source, atom/mover)
	if (!(source in buckled_mobs))
		return
	if (!(mover in buckled_mobs))
		return
	return COMSIG_COMPONENT_PERMIT_PASSAGE

/obj/golfcart_rear/proc/update_passenger_layers(new_dir)
	if (isnull(new_dir))
		new_dir = dir
	var/layer = HUMAN_RIDING_LAYER
	var/px = 0
	var/py = 0
	var/pz = 0
	var/px_second_offset = 0
	var/py_second_offset = 0
	var/pz_second_offset = 0
	if (new_dir & NORTH)
		px = -4
		px_second_offset = 8

		pz = 24
		pz_second_offset = -4
	else if (new_dir & SOUTH)
		layer = HUMAN_LOWER_LAYER

		px = -4
		px_second_offset = 8

		pz = 4
		pz_second_offset = 4
	else if (new_dir & WEST)
		px = -4
		px_second_offset = 12

		pz = 13
	else if (new_dir & EAST)
		px = 4
		px_second_offset = -12

		pz = 13

	for(var/i in 1 to buckled_mobs.len)
		var/mob/living/passenger = buckled_mobs[i]
		passenger.add_offsets(GOLFCART_RIDING_SOURCE,
			x_add = px + px_second_offset * (i - 1),
			y_add = py + py_second_offset * (i - 1),
			z_add = pz + pz_second_offset * (i - 1)
			)
		passenger.layer = layer

/obj/golfcart_rear/proc/on_dir_changed(datum/source, old_dir, new_dir)
	if (!has_buckled_mobs())
		return
	update_passenger_layers(new_dir)

/obj/golfcart_rear/Initialize(mapload, obj/vehicle/ridden/golfcart/progenitor)
	. = ..()
	parent = progenitor
	RegisterSignal(parent, COMSIG_ATOM_POST_DIR_CHANGE, PROC_REF(on_dir_changed))

/obj/vehicle/ridden/golfcart/hotrod/Initialize(mapload)
	. = ..()
	cell = null
	engine = new /obj/item/v8_engine(src)
	set_engine_state(ENGINE_WELDED)

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

/obj/vehicle/ridden/golfcart/proc/generate_cargo_overlay(crate_x_offset = 0, crate_y_offset = 0, layer=null, max_layer=null)
	if (!cargo)
		return
	if (!layer)
		layer = src.layer
	if (!max_layer)
		max_layer = ABOVE_ALL_MOB_LAYER
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
	var/base_cargo_layer = layer + crate_layer_offset
	for(var/i in 1 to overlays.len)
		var/entry = overlays[i]
		var/mutable_appearance/overlay = entry
		if(istext(entry))
			overlay = mutable_appearance(cargo.icon, entry, base_cargo_layer)
			overlays[i] = overlay
		// nested lists may exist and i can't be asked to flatten them
		if (!isnull(overlay))
			// preserves relative offsets
			if (overlay.layer > 0)
				overlay.layer = min(base_cargo_layer + (overlay.layer - cargo.layer), max_layer)
			else
				overlay.layer = min(base_cargo_layer + (overlay.layer * -0.01) - 0.01, max_layer)
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
	if (dir & NORTH)
		var/mutable_appearance/hitbox_overlay = mutable_appearance(icon, "rear_hitbox_overlay", layer)
		hitbox_overlay.pixel_y += 32
		. += hitbox_overlay
	else if (dir & SOUTH)
		. += mutable_appearance(icon, "rear_hitbox_lower", CART_LOWER_LAYER + 0.01)
	if(!parent.cargo)
		return
	var/vector/rear_offsets = parent.get_rear_offset()
	. += parent.generate_cargo_overlay(-rear_offsets.x, -rear_offsets.y, layer=layer)

/obj/vehicle/ridden/golfcart/update_overlays()
	. = ..()
	var/mutable_appearance/lower_overlay = mutable_appearance(icon, "lower", CART_LOWER_LAYER)
	var/mutable_appearance/roof_overlay = null
	var/mutable_appearance/rear_overlay = mutable_appearance(icon, "rear", layer)
	var/vector/rear_offsets = get_rear_offset()
	rear_overlay.pixel_x = rear_offsets.x
	rear_overlay.pixel_y = rear_offsets.y
	if (dir & NORTH)
	else if (dir & SOUTH)
		lower_overlay.pixel_y = 32

		roof_overlay = mutable_appearance(icon, "roof", CART_ROOF_LAYER)
		roof_overlay.pixel_y = 32
	else if (dir & EAST)
		lower_overlay.pixel_x = -32
		lower_overlay.layer -= 0.02

		roof_overlay = mutable_appearance(icon, "roof", CART_ROOF_LAYER)
		roof_overlay.pixel_y = 31
		roof_overlay.pixel_x = -10
	else if (dir & WEST)
		lower_overlay.pixel_x = 32
		lower_overlay.layer -= 0.02

		roof_overlay = mutable_appearance(icon, "roof", CART_ROOF_LAYER)
		roof_overlay.pixel_y = 31
		roof_overlay.pixel_x = 10
	. += lower_overlay
	. += rear_overlay
	if (hood_open)
		. += mutable_appearance(icon, "hood", layer + 0.01)
	if (roof_overlay)
		. += roof_overlay
	if (cargo)
		. += generate_cargo_overlay(max_layer=CARGO_HITBOX_LAYER)

/obj/vehicle/ridden/golfcart/post_buckle_mob(mob/living/M)
	if (M.pulling)
		M.stop_pulling()
	return ..()

/obj/golfcart_rear/proc/passenger_falling_down(atom/source, new_bodypos)
	if (!isliving(source))
		return // should runtime?
	if (new_bodypos == STANDING_UP)
		return
	var/mob/living/passenger = source
	unbuckle_mob(passenger, TRUE)

/obj/golfcart_rear/is_buckle_possible(mob/living/target, force, check_loc)
	. = ..()
	if (parent && parent.cargo)
		target.balloon_alert("blocked!")
		return FALSE
	if (target.body_position != STANDING_UP)
		target.balloon_alert("stand up!")
		return FALSE

/obj/golfcart_rear/post_buckle_mob(mob/living/buckled_mob)
	buckled_mob.pulledby?.stop_pulling()
	RegisterSignal(buckled_mob, COMSIG_ATOM_TRIED_PASS, PROC_REF(allow_movement_between_passengers))
	RegisterSignal(buckled_mob, COMSIG_LIVING_SET_BODY_POSITION, PROC_REF(passenger_falling_down))
	. = ..()
	update_passenger_layers()

/obj/golfcart_rear/post_unbuckle_mob(mob/living/buckled_mob)
	UnregisterSignal(buckled_mob, COMSIG_ATOM_TRIED_PASS)
	UnregisterSignal(buckled_mob, COMSIG_LIVING_SET_BODY_POSITION)
	buckled_mob.remove_offsets(GOLFCART_RIDING_SOURCE)
	buckled_mob.layer = initial(buckled_mob.layer)
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

#undef GOLFCART_RIDING_SOURCE
#undef ENGINE_UNWRENCHED
#undef ENGINE_WRENCHED
#undef ENGINE_WELDED
#undef CART_VERTICAL_LAYER
#undef CARGO_HITBOX_LAYER
#undef BELOW_HUMAN_HITBOX_LAYER
#undef HUMAN_RIDING_LAYER
#undef CART_ROOF_LAYER
#undef CART_LOWER_LAYER
#undef HUMAN_LOWER_LAYER
