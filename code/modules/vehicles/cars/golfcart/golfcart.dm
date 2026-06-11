#define ENGINE_UNWRENCHED 0
#define ENGINE_WRENCHED 1
#define ENGINE_WELDED 2
#define CARGO_HITBOX_LAYER (ABOVE_ALL_MOB_LAYER)
#define CART_ROOF_LAYER (CARGO_HITBOX_LAYER + 0.01)
#define CART_LOWER_LAYER (OBJ_LAYER)
#define FAKE_GLIDE_INITIAL_SOURCE "fake_glide_initial"
#define GOLFCART_RUN_OVER_DAMAGE (25)

/obj/vehicle/ridden/golfcart
	name = "golf cart"
	desc = "An all-purpose cargo hauling vehicle."
	icon = 'icons/obj/toys/golfcart_split.dmi'
	icon_state = "front"
	max_integrity = 100
	armor_type = /datum/armor/none
	pass_flags_self = parent_type::pass_flags_self | LETPASSCLICKS
	integrity_failure = 0.5
	layer = ABOVE_MOB_LAYER
	max_occupants = 1
	key_type = /obj/item/key/golfcart
	///Perform an extra step after movement finishes?
	var/perform_extra_step = FALSE
	///Base movespeed before any modifiers. Humans run at 1.5 movedelay.
	var/static/base_movedelay = 1.25
	///Base movespeed for the hotrod before any modifiers
	var/static/hotrod_base_movedelay = 0.65
	///Particle holder for low integrity smoking
	var/obj/effect/abstract/particle_holder/smoke = null
	///Seperate image for the cargo buckled to the rear
	var/image/cargo_image = null
	///The power source for the cart. Can be replaced with an engine.
	var/obj/item/stock_parts/power_store/cell/cell = null
	///A more powerful power source for the cart.
	var/obj/item/v8_engine/engine = null
	///Can be unwrenched, wrenched, or welded
	var/engine_state = null
	///An invisible sprite that exists as a hitbox
	var/obj/golfcart_rear/child = null
	///Objects that can be buckled to the cargo hitch
	var/static/list/allowed_cargo = typecacheof(list(
		/obj/structure/closet/crate,
		/obj/structure/reagent_dispensers,
		/obj/structure/flatpack_cart,
		/obj/machinery,
		/obj/item/kirbyplants,
	))
	///Each movement requires this much energy to be drawn from the internal cell
	var/charge_per_move = STANDARD_CELL_CHARGE / 300
	///Has the final say on whether something can be buckled.
	var/static/list/banned_cargo = typecacheof(list(
		/obj/structure/reagent_dispensers/wall,
		// i mean it's a fucking door
		/obj/machinery/door,
	))
	///Is the hood open?
	var/hood_open = FALSE

/obj/item/key/golfcart
	name = "golfcart key"
	desc = "A small grey key for using the golf cart."
	icon = 'icons/obj/toys/golfcart_split.dmi'

/obj/item/golfcart_kit
	name = "golfcart parts kit"
	desc = "A box containing a golf cart. Some assembly required. Batteries not included."
	icon = 'icons/obj/toys/golfcart_split.dmi'
	icon_state = "parts_kit"
	w_class = WEIGHT_CLASS_HUGE
	throw_range = 2
	item_flags = SLOWS_WHILE_IN_HAND | IMMUTABLE_SLOW
	slowdown = 2.5
	drag_slowdown = 3.5

/obj/item/golfcart_kit/examine(mob/user)
	. = ..()
	. += span_notice("The instructions say that it needs to be [EXAMINE_HINT("screwed")] together.")

/obj/item/golfcart_kit/proc/play_building_noises(mob/living/user, duration)
	duration = max(duration - (1 SECONDS), 0.5 SECONDS)
	playsound(src, 'sound/items/poster/poster_ripped.ogg', 50, TRUE)
	sleep(1 SECONDS)
	if (!DOING_INTERACTION_WITH_TARGET(user, src))
		return
	playsound(src, 'sound/items/tools/screwdriver_operating.ogg', 50, TRUE)
	sleep(duration / 2)
	if (!DOING_INTERACTION_WITH_TARGET(user, src))
		return
	playsound(src, 'sound/items/tools/ratchet.ogg', 50, TRUE)
	sleep(duration / 2)
	if (!DOING_INTERACTION_WITH_TARGET(user, src))
		return
	playsound(src, 'sound/items/tools/screwdriver.ogg', 50, TRUE)

/obj/item/golfcart_kit/screwdriver_act(mob/living/user, obj/item/tool)
	if (!isturf(loc))
		user.balloon_alert(user, "set down first!")
		return ITEM_INTERACT_BLOCKING
	user.visible_message(span_notice("[user] starts putting together the [src]..."), span_notice("You start assembling the [src]..."))
	var/unboxing_duration = 7 SECONDS
	INVOKE_ASYNC(src, PROC_REF(play_building_noises), user, unboxing_duration * tool.toolspeed)
	if(!tool.use_tool(src, user, unboxing_duration))
		return ITEM_INTERACT_BLOCKING
	if (!isturf(loc))
		return ITEM_INTERACT_BLOCKING
	var/obj/vehicle/ridden/golfcart/cart = new(get_turf(src))
	user.visible_message(span_notice("[user] assembles the [cart]!"), span_notice("You assemble the [cart]."))
	qdel(src)

/obj/vehicle/ridden/golfcart/atom_break()
	. = ..()
	if (smoke)
		return
	smoke = new(src, /particles/smoke/ash)

/obj/vehicle/ridden/golfcart/atom_fix()
	. = ..()
	if (smoke)
		QDEL_NULL(smoke)

/obj/vehicle/ridden/golfcart/atom_destruction()
	explosion(src, devastation_range = -1, light_impact_range = 2, flame_range = 3, flash_range = 4)
	return ..()

///Jiggles the cargo_image up and down.
/obj/vehicle/ridden/golfcart/proc/shake_cargo(pixelshiftx = 2, pixelshifty = 2, duration)
	if (!cargo_image)
		return
	var/inital_pixel_x = cargo_image.pixel_x
	var/inital_pixel_y = cargo_image.pixel_y
	animate(cargo_image, pixel_x = inital_pixel_x + rand(-pixelshiftx, pixelshiftx), pixel_y = inital_pixel_y + rand(pixelshifty/2, pixelshifty), time=duration, flags=ANIMATION_PARALLEL)
	animate(pixel_x = inital_pixel_x, pixel_y = inital_pixel_y, time=duration)

/obj/vehicle/ridden/golfcart/proc/is_hotrod()
	return engine && engine_state == ENGINE_WELDED

///Called when something we crash into lands after being flinged
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
	if (mob in child.buckled_mobs)
		return
	mob.throw_at(get_edge_target_turf(mob, dir), 2, 3)
	RegisterSignal(mob, COMSIG_MOVABLE_THROW_LANDED, PROC_REF(thrown_mob_landed))
	mob.visible_message(
		span_danger("[src] hits [mob] at full speed!"),
		span_userdanger("[src] slams into you!"),
	)

///Called when a resting victim is run over
/obj/vehicle/ridden/golfcart/proc/run_over(mob/living/victim)
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

			var/damage = rand(GOLFCART_RUN_OVER_DAMAGE - GOLFCART_RUN_OVER_DAMAGE / 5, GOLFCART_RUN_OVER_DAMAGE + GOLFCART_RUN_OVER_DAMAGE / 5)
			//adds up to exactly 1
			person.apply_damage((1/3) * damage, BRUTE, BODY_ZONE_HEAD)
			person.apply_damage((1/3) * damage, BRUTE, BODY_ZONE_CHEST)
			person.apply_damage((1/12) * damage, BRUTE, BODY_ZONE_L_LEG)
			person.apply_damage((1/12) * damage, BRUTE, BODY_ZONE_R_LEG)
			person.apply_damage((1/12) * damage, BRUTE, BODY_ZONE_L_ARM)
			person.apply_damage((1/12) * damage, BRUTE, BODY_ZONE_R_ARM)

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
		if (!(future_pancake in child.buckled_mobs))
			run_over(future_pancake)

/obj/vehicle/ridden/golfcart/mouse_drop_receive(atom/dropped, mob/user, params)
	if (child.can_load(dropped))
		return child.mouse_drop_receive(dropped, user, params)
	return ..()

/obj/vehicle/ridden/golfcart/item_interaction(mob/living/user, obj/item/attacking_item, list/modifiers)
	if (!hood_open)
		return ..()
	if (istype(attacking_item, /obj/item/v8_engine))
		if (engine || cell)
			balloon_alert(user, "already has an engine!")
			return ITEM_INTERACT_BLOCKING
		user.transferItemToLoc(attacking_item, src)
		engine = attacking_item
		engine_state = ENGINE_UNWRENCHED
		balloon_alert(user, "installed \the [engine]")
		return ITEM_INTERACT_SUCCESS
	if (istype(attacking_item, /obj/item/stock_parts/power_store/cell))
		if (cell || engine)
			balloon_alert(user, "already has an engine!")
			return ITEM_INTERACT_BLOCKING
		user.transferItemToLoc(attacking_item, src)
		cell = attacking_item
		balloon_alert(user, "installed \the [cell]")
		return ITEM_INTERACT_SUCCESS
	return ..()

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

/obj/vehicle/ridden/golfcart/proc/can_wrench_engine()
	return hood_open && engine && (engine_state == ENGINE_UNWRENCHED || engine_state == ENGINE_WRENCHED)

/obj/vehicle/ridden/golfcart/proc/can_weld_engine()
	return hood_open && engine && (engine_state == ENGINE_WRENCHED || engine_state == ENGINE_WELDED)

/obj/vehicle/ridden/golfcart/proc/set_engine_state(state)
	engine_state = state
	if (engine_state == ENGINE_WELDED && icon != 'icons/obj/toys/golfcart_hotrod_split.dmi')
		icon = 'icons/obj/toys/golfcart_hotrod_split.dmi'
		update_appearance(UPDATE_ICON)
	else if (engine_state != ENGINE_WELDED && icon != initial(icon))
		icon = initial(icon)

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
	if (user.combat_mode)
		return
	if(!tool.tool_start_check(user, heat_required = HIGH_TEMPERATURE_REQUIRED, amount = 1))
		return ITEM_INTERACT_BLOCKING
	. = ITEM_INTERACT_SUCCESS
	if (hood_open)
		if(!tool.use_tool(src, user, 3 SECONDS, amount = 1, volume = 50, extra_checks = CALLBACK(src, PROC_REF(can_weld_engine))))
			return ITEM_INTERACT_BLOCKING
		if (engine_state == ENGINE_WRENCHED)
			set_engine_state(ENGINE_WELDED)
		else if (engine_state == ENGINE_WELDED)
			set_engine_state(ENGINE_WRENCHED)
	else
		if(DOING_INTERACTION(user, src))
			balloon_alert(user, "already repairing it!")
			return
		if(atom_integrity >= max_integrity)
			balloon_alert(user, "it's not damaged!")
			return
		// takes 10 seconds to repair from full
		balloon_alert(user, "started repairing")
		if (!tool.use_tool(src, user, ((max_integrity - atom_integrity) / max_integrity * 10) SECONDS, volume = 50))
			balloon_alert(user, "repair interrupted!")
			return
		repair_damage(max_integrity - atom_integrity)
		balloon_alert(user, "repaired")
	return

/obj/vehicle/ridden/golfcart/proc/toggle_hood()
	hood_open = !hood_open
	update_appearance(UPDATE_ICON)

/obj/vehicle/ridden/golfcart/click_alt(mob/user)
	if (user in buckled_mobs)
		return ..()
	else
		to_chat(user, span_warning("You must be sitting down to remove the key!"))
	. = CLICK_ACTION_SUCCESS
	toggle_hood()
	if (hood_open)
		to_chat(user, span_notice("You pop \the [src]'s hood."))
	else
		to_chat(user, span_notice("You shut \the [src]'s hood."))

/obj/vehicle/ridden/golfcart/examine_more(mob/user)
	. = ..()
	if (!child.cargo)
		return
	. += span_slightly_larger("It is currently transporting the [child.cargo]")
	. += child.cargo.examine(user)

/obj/vehicle/ridden/golfcart/examine(mob/user)
	. = ..()
	. += span_notice("Pop the hood by alt-clicking while not riding it.")
	if (child.cargo)
		. += span_info("The bed is holding \the [child.cargo].")
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
		else if (cell)
			. += span_info("You can see \the [cell] inside.")
			. += span_smallnotice("If you remove the cell you could probably install another power source...")
		else
			. += span_info("There is no power cell installed.")

///Called when something tries to pass us. Returns TRUE if it is trying to crawl past us.
/obj/vehicle/ridden/golfcart/proc/allow_crawler_through(atom/crawler)
	if (!isliving(crawler))
		return FALSE
	var/mob/living/living_crawler = crawler
	return living_crawler.body_position == LYING_DOWN

/obj/vehicle/ridden/golfcart/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if (mover == child)
		return TRUE
	if (mover in child.buckled_mobs)
		return TRUE
	if (allow_crawler_through(mover))
		return TRUE

///Called for COMSIG_MOVABLE_PRE_MOVE on the golfcart front. If the rear of the cart doesn't fit where we want to go, block movement.
/obj/vehicle/ridden/golfcart/proc/pre_move(atom/source, atom/new_loc)
	SIGNAL_HANDLER

	// see if space behind new loc is free
	var/atom/behind = get_step(new_loc, turn(dir, 180))
	if ((!behind.Enter(child, child.loc)) && behind != get_step(src, 0))
		return COMPONENT_MOVABLE_BLOCK_PRE_MOVE
	// otherwise permit move
	return

///Makes movedelay a factor of base_movedelay
/obj/vehicle/ridden/golfcart/proc/set_movedelay_effect(modification)
	var/base_movedelay_effect = base_movedelay
	if (is_hotrod())
		base_movedelay_effect = hotrod_base_movedelay
	movedelay = base_movedelay_effect * modification
	child.set_glide_size(DELAY_TO_GLIDE_SIZE(movedelay))

///Sets perform_extra_step to TRUE if we are going up stairs.
/obj/vehicle/ridden/golfcart/zMove(dir, turf/target, z_move_flags)
	var/can_do_extra_step = FALSE
	if (currently_z_moving == CURRENTLY_Z_ASCENDING)
		can_do_extra_step = TRUE
	. = ..()
	if (!.)
		return
	perform_extra_step = perform_extra_step || can_do_extra_step

///Creates a fake glide effect on the golfcart and anything buckled to it. Called when moving up stairs as moving up stairs creates a two-tile move.
/obj/vehicle/ridden/golfcart/proc/fake_glide(direct)
	var/px = 0
	var/py = 0
	if (direct & NORTH)
		py -= 32
	else if (direct & SOUTH)
		py += 32
	if (direct & EAST)
		px -= 32
	else if (direct & WEST)
		px += 32
	pixel_x += px
	pixel_y += py
	child.pixel_x += px
	child.pixel_y += py
	animate(src, movedelay, pixel_x=0, pixel_y=0)
	animate(child, movedelay, pixel_x=0, pixel_y=0)
	for (var/mob/buckled in (buckled_mobs + child.buckled_mobs))
		var/inital_pixel_x = buckled.pixel_x
		var/inital_pixel_y = buckled.pixel_y
		buckled.pixel_x += px
		buckled.pixel_y += py
		animate(buckled, movedelay, pixel_x=inital_pixel_x, pixel_y=inital_pixel_y)
		if (buckled.client)
			var/client/client = buckled.client
			var/initial_client_pixel_x = client.pixel_x
			var/initial_client_pixel_y = client.pixel_y
			client.pixel_x += px
			client.pixel_y += py
			animate(client, movedelay, pixel_x=initial_client_pixel_x, pixel_y=initial_client_pixel_y)

/obj/vehicle/ridden/golfcart/Move(atom/newloc, direct, glide_size_override = 0, update_dir = TRUE)
	perform_extra_step = FALSE
	var/atom/old_loc = get_turf(src)
	var/old_dir = dir
	if (get_turf(child) == newloc)
		set_movedelay_effect(2)
		. = ..(newloc, turn(direct, 180))
	else
		set_movedelay_effect(1)
		. = ..()
	var/atom/behind = get_step(src, turn(dir, 180))
	if (old_dir != dir && get_turf(src) == old_loc)
		if (!behind.Enter(child, child.loc))
			setDir(old_dir)
			behind = get_step(src, turn(dir, 180))
	update_appearance(UPDATE_ICON)
	child.move_from_parent(behind)
	// working theory is that somehow the cart can't move onto stairs -> perform_extra_step is true but loc is never set to newloc
	if ((perform_extra_step && loc.z != old_loc.z) || loc.z < old_loc.z)
		// this should be called when descending Z levels, or when going up stairs
		if (!Move(get_step(src, dir), dir, glide_size_override, update_dir))
			return
		fake_glide(dir)

///Called for COMSIG_ATOM_TRIED_PASS on the golfcart front. Allows mobs buckled to the rear of the cart to not get blocked by the front of the cart.
/obj/vehicle/ridden/golfcart/proc/allow_movement_between_passengers(atom/source, atom/mover)
	SIGNAL_HANDLER

	if (mover in child.buckled_mobs)
		return COMSIG_COMPONENT_PERMIT_PASSAGE

/obj/vehicle/ridden/golfcart/Initialize(mapload, direction = null)
	. = ..()
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/golfcart)
	RegisterSignal(src, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(pre_move))
	child = new /obj/golfcart_rear(null, src)
	if (isnull(direction))
		if (get_step(src, NORTH).Enter(child))
			direction = NORTH
		else if (get_step(src, EAST).Enter(child))
			direction = EAST
		else if (get_step(src, WEST).Enter(child))
			direction = WEST
		else if (get_step(src, SOUTH).Enter(child))
			direction = SOUTH
		else
			direction = SOUTH
		direction = turn(direction, 180)
	setDir(direction)
	child.loc = get_step(src, turn(dir, 180))
	update_appearance()

/obj/vehicle/ridden/golfcart/loaded/Initialize(mapload)
	. = ..()
	cell = new /obj/item/stock_parts/power_store/cell/lead(src)

/obj/vehicle/ridden/golfcart/hotrod/Initialize(mapload)
	. = ..()
	engine = new /obj/item/v8_engine(src)
	set_engine_state(ENGINE_WELDED)

/obj/vehicle/ridden/golfcart/update_appearance(updates=ALL)
	. = ..()
	child.setDir(dir)
	child.update_appearance(updates)

/obj/vehicle/ridden/golfcart/proc/get_cargo_offsets()
	var/crate_x_offset = 0
	var/crate_y_offset = 0
	if (dir & NORTH)
		crate_y_offset += -30
	else if (dir & SOUTH)
		crate_y_offset += 30
	else if (dir & EAST)
		crate_x_offset += -32
	else if (dir & WEST)
		crate_x_offset += 32
	return vector(crate_x_offset, crate_y_offset)

///Flattens the attached cargo into a list of mutable_appearances with proper layering to fit between layer and max_layer
/obj/vehicle/ridden/golfcart/proc/generate_cargo_overlay(crate_x_offset = 0, crate_y_offset = 0, layer=null, max_layer=null, shift_all=TRUE)
	if (!child.cargo)
		return
	var/obj/cargo = child.cargo
	if (!layer)
		layer = src.layer
	if (!max_layer)
		max_layer = ABOVE_ALL_MOB_LAYER
	var/vector/offsets = get_cargo_offsets()
	offsets.x += crate_x_offset
	offsets.y += crate_y_offset
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
			if (shift_all || i == 1)
				overlay.pixel_x += offsets.x
				overlay.pixel_y += offsets.y
				overlay.pixel_z += 11
	return overlays

///Gets the pixel offsets of the rear part of the golf cart
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

/obj/vehicle/ridden/golfcart/update_overlays()
	. = ..()
	// the overlays for the cart are fairly complicated.
	// the main three are the front, rear, and lower overlays
	// the front/rear overlay are the same layer
	// but the lower overlay is always below buckled mobs and the cargo

	var/mutable_appearance/lower_overlay = mutable_appearance(icon, "lower", CART_LOWER_LAYER)
	var/mutable_appearance/roof_overlay = null
	var/mutable_appearance/rear_overlay = mutable_appearance(icon, "rear", layer)
	var/vector/rear_offsets = get_rear_offset()
	rear_overlay.pixel_x = rear_offsets.x
	rear_overlay.pixel_y = rear_offsets.y
	if (dir & SOUTH)
		// however, specifically when facing south, we require another overlay.
		// it is effectively an extension of the lower overlay, but it has to be on a different tile so it has to be a different overlay
		var/mutable_appearance/floor_overlay = mutable_appearance(icon, "floor", CART_LOWER_LAYER)
		floor_overlay.pixel_y += 25
		. += floor_overlay

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

	if (child.cargo)
		// the cargo is a seperate vis_overlay so that it can be animate()d
		vis_contents -= cargo_image
		cargo_image = null
		var/vector/offsets = get_cargo_offsets()
		var/list/overlays = generate_cargo_overlay(max_layer=CARGO_HITBOX_LAYER, shift_all=FALSE)
		if (overlays.len)
			var/mutable_appearance/base_overlay = overlays[1]
			overlays.Remove(base_overlay)
			cargo_image = SSvis_overlays.add_vis_overlay(src, base_overlay.icon, base_overlay.icon_state, base_overlay.layer, plane, dir)
			cargo_image.overlays = overlays
			cargo_image.pixel_x = offsets.x
			cargo_image.pixel_y = offsets.y
			cargo_image.pixel_z = 11
			cargo_image.layer = base_overlay.layer
			vis_contents += cargo_image
	else
		cargo_image = null

///Allows mobs sitting in the rear of the cart to not shoot either the front of the cart or the driver of the cart.
/obj/vehicle/ridden/golfcart/proc/dodge_friendly_fire(mob/source, obj/projectile/projectile)
	SIGNAL_HANDLER

	if (!projectile.firer)
		return
	if (QDELETED(projectile.firer))
		return
	// so that you don't murder your driver when shooting off the back
	if (projectile.firer in child.buckled_mobs)
		return PROJECTILE_INTERRUPT_HIT_PHASE

/obj/vehicle/ridden/golfcart/post_buckle_mob(mob/living/M)
	if (M.pulling)
		M.stop_pulling()
	RegisterSignal(M, COMSIG_PROJECTILE_PREHIT, PROC_REF(dodge_friendly_fire))
	RegisterSignal(M, COMSIG_ATOM_TRIED_PASS, PROC_REF(allow_movement_between_passengers))
	return ..()

/obj/vehicle/ridden/golfcart/post_unbuckle_mob(mob/living/M)
	update_appearance(UPDATE_ICON) // because for some reason the overlays aren't properly redrawn
	UnregisterSignal(M, COMSIG_ATOM_TRIED_PASS)
	UnregisterSignal(M, COMSIG_PROJECTILE_PREHIT)
	return ..()

/obj/vehicle/ridden/golfcart/Destroy()
	UnregisterSignal(src, COMSIG_MOVABLE_PRE_MOVE)
	if (!QDELETED(child))
		qdel(child)
	child = null
	return ..()

#undef ENGINE_UNWRENCHED
#undef ENGINE_WRENCHED
#undef ENGINE_WELDED
#undef CARGO_HITBOX_LAYER
#undef CART_ROOF_LAYER
#undef CART_LOWER_LAYER
#undef FAKE_GLIDE_INITIAL_SOURCE
#undef GOLFCART_RUN_OVER_DAMAGE
