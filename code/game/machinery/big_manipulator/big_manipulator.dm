//   ___   _   __  __ _  _ _  _ _  _ _  _ _  _ _  _ _  _ _  _ _  _ _  _
//  |   \ /_\ |  \/  | \| | \| | \| | \| | \| | \| | \| | \| | \| | \| |
//  | |) / _ \| |\/| | .` | .` | .` | .` | .` | .` | .` | .` | .` | .` |
//  |___/_/ \_\_|  |_|_|\_|_|\_|_|\_|_|\_|_|\_|_|\_|_|\_|_|\_|_|\_|_|\_|
//
/obj/machinery/big_manipulator
	name = "big manipulator"
	desc = "Operates different objects. Truly, a groundbreaking innovation..."
	icon = 'icons/obj/machines/big_manipulator_parts/big_manipulator_core.dmi'
	icon_state = "core"
	density = TRUE
	circuit = /obj/item/circuitboard/machine/big_manipulator
	greyscale_colors = "#d8ce13"
	greyscale_config = /datum/greyscale_config/big_manipulator
	hud_possible = list(DIAG_LAUNCHPAD_HUD)

	/// Min time manipulator can have in delay. Changing on upgrade.
	var/minimal_interaction_multiplier = MIN_ROTATION_MULTIPLIER_TIER_1
	/// Base interaction delay (between repeating actions and adjacent points)
	var/interaction_delay = BASE_INTERACTION_TIME * STARTING_MULTIPLIER
	/// How many interaction points of each kind can we have?
	var/interaction_point_limit = MAX_INTERACTION_POINTS_TIER_1

	/// The status of the manipulator - `IDLE` or `BUSY`.
	var/status = STATUS_IDLE
	/// Is the manipulator turned on?
	var/on = FALSE

	var/current_task_start_time = 0
	var/current_task_duration = 0
	var/current_task_type = "idle"

	/// The object inside the manipulator.
	var/datum/weakref/held_object
	/// The chimp worker that uses the manipulator (handles USE cases).
	var/datum/weakref/monkey_worker
	/// Weakref to the ID that locked this manipulator.
	var/datum/weakref/id_lock = null
	/// The manipulator's arm.
	var/obj/effect/big_manipulator_arm/manipulator_arm
	/// Overrides the priority selection, only accessing the top priority list element.
	var/override_priority = FALSE
	/// Is the power access wire cut? Disables the power button if `TRUE`.
	var/power_access_wire_cut = FALSE

	/// History of accessed pickup points for round-robin tasking.
	var/list/roundrobin_history_pickup = 1
	/// History of accessed dropoff points for round-robin tasking.
	var/list/roundrobin_history_dropoff = 1
	/// Which tasking scenario we use for pickup points?
	var/pickup_tasking = TASKING_ROUND_ROBIN
	/// Which tasking scenario we use for dropoff points?
	var/dropoff_tasking = TASKING_ROUND_ROBIN
	/// List of pickup points.
	var/list/pickup_points = list()
	/// List of dropoff points.
	var/list/dropoff_points = list()
	/// List of all HUD icons resembling interaction points.
	var/list/hud_points = list()

/obj/machinery/big_manipulator/proc/update_hud_for_all_points()
	for(var/datum/interaction_point/point in pickup_points)
		update_hud_for_point(point, TRANSFER_TYPE_PICKUP)

	for(var/datum/interaction_point/point in dropoff_points)
		update_hud_for_point(point, TRANSFER_TYPE_DROPOFF)

/obj/machinery/big_manipulator/proc/update_hud_for_point(datum/interaction_point/point, point_type)
	if(!is_operational)
		return

	// Creating a new HUD element
	var/image/holder = new
	hud_list[DIAG_LAUNCHPAD_HUD] = holder
	var/mutable_appearance/target = mutable_appearance('icons/effects/effects.dmi', point_type == TRANSFER_TYPE_PICKUP ? "launchpad_pull" : "launchpad_launch", ABOVE_NORMAL_TURF_LAYER, src, GAME_PLANE)

	var/target_turf = point.interaction_turf
	holder.appearance = target
	holder.loc = target_turf
	hud_points += holder

/obj/machinery/big_manipulator/proc/find_suitable_turf()
	var/turf/center = get_turf(src)
	if(!center)
		return null

	var/turf/north = get_step(center, NORTH)
	if(north && !isclosedturf(north))
		return north

	var/list/directions = list(EAST, SOUTH, WEST, NORTHWEST, SOUTHWEST, SOUTHEAST, NORTHEAST)
	for(var/dir in directions)
		var/turf/check = get_step(center, dir)
		if(check && !isclosedturf(check))
			return check

	return null

/obj/machinery/big_manipulator/proc/create_new_interaction_point(turf/new_turf, list/new_filters, new_filters_status, new_interaction_mode, transfer_type)
	if(!new_turf)
		new_turf = find_suitable_turf()
		if(!new_turf)
			balloon_alert(usr, "no suitable turfs found!")
			return FALSE

	if(transfer_type == TRANSFER_TYPE_PICKUP && length(pickup_points) + 1 > interaction_point_limit)
		balloon_alert(usr, "pickup point limit reached!")
		return FALSE
	if(transfer_type == TRANSFER_TYPE_DROPOFF && length(dropoff_points) + 1 > interaction_point_limit)
		balloon_alert(usr, "dropoff point limit reached!")
		return FALSE

	var/datum/interaction_point/new_interaction_point = new(new_turf, new_filters, new_filters_status, new_interaction_mode)

	if(QDELETED(new_interaction_point))
		return FALSE

	switch(transfer_type)
		if(TRANSFER_TYPE_PICKUP)
			pickup_points += new_interaction_point
		if(TRANSFER_TYPE_DROPOFF)
			dropoff_points += new_interaction_point

	// If emagged, allow interacting with living mobs as well.
	if(obj_flags & EMAGGED)
		new_interaction_point.type_filters += /mob/living

	// Update HUD only when the manipulator is operational.
	if(is_operational)
		update_hud_for_point(new_interaction_point, transfer_type)

	return new_interaction_point

/obj/machinery/big_manipulator/proc/update_all_points_on_emag_act()
	for(var/datum/interaction_point/pickup_point in pickup_points)
		pickup_point.type_filters += /mob/living
	for(var/datum/interaction_point/dropoff_point in dropoff_points)
		dropoff_point.type_filters += /mob/living

/obj/machinery/big_manipulator/Initialize(mapload)
	. = ..()
	create_manipulator_arm()
	RegisterSignal(manipulator_arm, COMSIG_QDELETING, PROC_REF(on_hand_qdel))
	process_upgrades()
	if(on)
		switch_power_state(null)
	set_wires(new /datum/wires/big_manipulator(src))
	register_context()
	prepare_huds()
	for(var/datum/atom_hud/data/diagnostic/diag_hud in GLOB.huds)
		diag_hud.add_atom_to_hud(src)

/// Checks the component tiers, adjusting the properties of the manipulator.
/obj/machinery/big_manipulator/proc/process_upgrades()
	var/datum/stock_part/servo/locate_servo = locate() in component_parts
	if(!locate_servo)
		return

	var/manipulator_tier = locate_servo.tier
	switch(manipulator_tier)
		if(-INFINITY to 1)
			minimal_interaction_multiplier = MIN_ROTATION_MULTIPLIER_TIER_1
			interaction_delay = BASE_INTERACTION_TIME * MIN_ROTATION_MULTIPLIER_TIER_1
			interaction_point_limit = MAX_INTERACTION_POINTS_TIER_1
			set_greyscale(COLOR_YELLOW)
			manipulator_arm?.set_greyscale(COLOR_YELLOW)
		if(2)
			minimal_interaction_multiplier = MIN_ROTATION_MULTIPLIER_TIER_2
			interaction_delay = BASE_INTERACTION_TIME * MIN_ROTATION_MULTIPLIER_TIER_2
			interaction_point_limit = MAX_INTERACTION_POINTS_TIER_2
			set_greyscale(COLOR_ORANGE)
			manipulator_arm?.set_greyscale(COLOR_ORANGE)
		if(3)
			minimal_interaction_multiplier = MIN_ROTATION_MULTIPLIER_TIER_3
			interaction_delay = BASE_INTERACTION_TIME * MIN_ROTATION_MULTIPLIER_TIER_3
			interaction_point_limit = MAX_INTERACTION_POINTS_TIER_3
			set_greyscale(COLOR_RED)
			manipulator_arm?.set_greyscale(COLOR_RED)
		if(4 to INFINITY)
			minimal_interaction_multiplier = MIN_ROTATION_MULTIPLIER_TIER_4
			interaction_delay = BASE_INTERACTION_TIME * MIN_ROTATION_MULTIPLIER_TIER_4
			interaction_point_limit = MAX_INTERACTION_POINTS_TIER_4
			set_greyscale(COLOR_PURPLE)
			manipulator_arm?.set_greyscale(COLOR_PURPLE)

	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * BASE_POWER_USAGE * manipulator_tier

/obj/machinery/big_manipulator/examine(mob/user)
	. = ..()
	var/mob/monkey_resolve = monkey_worker?.resolve()
	if(!isnull(monkey_resolve))
		. += "You can see [monkey_resolve]: [src] manager."

/obj/machinery/big_manipulator/attack_hand_secondary(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	try_press_on(user)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/machinery/big_manipulator/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()

	context[SCREENTIP_CONTEXT_RMB] = "Toggle"

	if(isnull(held_item))
		context[SCREENTIP_CONTEXT_LMB] = panel_open ? "Interact with wires" : "Open UI"
		return CONTEXTUAL_SCREENTIP_SET

	if(held_item.tool_behaviour == TOOL_WRENCH)
		context[SCREENTIP_CONTEXT_LMB] = "[anchored ? "Una" : "A"]nchor"
		context[SCREENTIP_CONTEXT_RMB] = "Rotate clockwise"
		return CONTEXTUAL_SCREENTIP_SET
	if(held_item.tool_behaviour == TOOL_SCREWDRIVER)
		context[SCREENTIP_CONTEXT_LMB] = "[panel_open ? "Close" : "Open"] panel"
		return CONTEXTUAL_SCREENTIP_SET
	if(held_item.tool_behaviour == TOOL_CROWBAR && panel_open)
		context[SCREENTIP_CONTEXT_LMB] = "Deconstruct"
		return CONTEXTUAL_SCREENTIP_SET
	if(is_wire_tool(held_item) && panel_open)
		context[SCREENTIP_CONTEXT_LMB] = "Interact with wires"
		return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/big_manipulator/Destroy(force)
	remove_all_huds()
	for(var/datum/atom_hud/data/diagnostic/diag_hud in GLOB.huds)
		diag_hud.remove_atom_from_hud(src)
	qdel(manipulator_arm)
	if(!isnull(held_object))
		var/obj/containment_resolve = held_object?.resolve()
		containment_resolve?.forceMove(get_turf(containment_resolve))
	var/mob/monkey_resolve = monkey_worker?.resolve()
	if(!isnull(monkey_resolve))
		monkey_resolve.forceMove(get_turf(monkey_resolve))
	id_lock = null
	return ..()

/obj/machinery/big_manipulator/Exited(atom/movable/gone, direction)
	if(isnull(monkey_worker))
		return
	var/mob/living/carbon/human/species/monkey/poor_monkey = monkey_worker.resolve()
	if(gone != poor_monkey)
		return
	if(!is_type_in_list(poor_monkey, manipulator_arm.vis_contents))
		return
	manipulator_arm.vis_contents -= poor_monkey
	poor_monkey.remove_offsets(type)
	monkey_worker = null

/obj/machinery/big_manipulator/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	. = ..()
	if(isnull(get_turf(src)))
		qdel(manipulator_arm)
		return
	if(!manipulator_arm)
		create_manipulator_arm()

/obj/machinery/big_manipulator/emag_act(mob/user, obj/item/card/emag/emag_card)
	. = ..()
	if(obj_flags & EMAGGED)
		return FALSE
	balloon_alert(user, "overloaded")
	obj_flags |= EMAGGED
	// Update existing points to accept living mobs as targets
	update_all_points_on_emag_act()
	return TRUE

/obj/machinery/big_manipulator/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	default_unfasten_wrench(user, tool, time = 1 SECONDS)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/big_manipulator/can_be_unfasten_wrench(mob/user, silent)
	if(status == STATUS_BUSY || on)
		to_chat(user, span_warning("[src] is activated!"))
		return FAILED_UNFASTEN
	return ..()

/obj/machinery/big_manipulator/default_unfasten_wrench(mob/user, obj/item/wrench, time)
	. = ..()
	if(. == SUCCESSFUL_UNFASTEN)
		return

/obj/machinery/big_manipulator/screwdriver_act(mob/living/user, obj/item/tool)
	if(default_deconstruction_screwdriver(user, icon_state, icon_state, tool))
		return ITEM_INTERACT_SUCCESS
	return ITEM_INTERACT_BLOCKING

/obj/machinery/big_manipulator/crowbar_act(mob/living/user, obj/item/tool)
	. = ..()
	if(default_deconstruction_crowbar(tool))
		return ITEM_INTERACT_SUCCESS
	return ITEM_INTERACT_BLOCKING

/obj/machinery/big_manipulator/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(user.combat_mode)
		return NONE
	if(!panel_open || !is_wire_tool(tool))
		return NONE
	wires.interact(user)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/big_manipulator/RefreshParts()
	. = ..()
	process_upgrades()

/obj/machinery/big_manipulator/mouse_drop_dragged(atom/drop_point, mob/user, src_location, over_location, params)
	if(isnull(monkey_worker))
		return
	if(status == STATUS_BUSY)
		balloon_alert(user, "turn it off first!")
		return
	var/mob/living/carbon/human/species/monkey/poor_monkey = monkey_worker.resolve()
	if(isnull(poor_monkey))
		return
	balloon_alert(user, "trying unbuckle...")
	if(!do_after(user, 3 SECONDS, src))
		balloon_alert(user, "interrupted")
		return
	balloon_alert(user, "unbuckled")
	poor_monkey.drop_all_held_items()
	poor_monkey.forceMove(drop_point)

/obj/machinery/big_manipulator/mouse_drop_receive(atom/monkey, mob/user, params)
	if(!ismonkey(monkey))
		return
	if(!isnull(monkey_worker))
		return
	if(status == STATUS_BUSY)
		balloon_alert(user, "turn it off first!")
		return
	var/mob/living/carbon/human/species/monkey/poor_monkey = monkey
	if(poor_monkey.mind)
		balloon_alert(user, "too smart!")
		return
	poor_monkey.balloon_alert(user, "trying buckle...")
	if(!do_after(user, 3 SECONDS, poor_monkey))
		poor_monkey.balloon_alert(user, "interrupted")
		return
	balloon_alert(user, "buckled")
	monkey_worker = WEAKREF(poor_monkey)
	poor_monkey.drop_all_held_items()
	poor_monkey.forceMove(src)
	manipulator_arm.vis_contents += poor_monkey
	poor_monkey.dir = manipulator_arm.dir
	poor_monkey.add_offsets(
		type,
		x_add = 32 + manipulator_arm.calculate_item_offset(TRUE, pixels_to_offset = 16),
		y_add = 32 + manipulator_arm.calculate_item_offset(FALSE, pixels_to_offset = 16)
	)

/obj/machinery/big_manipulator/attackby(obj/item/is_card, mob/user, params)
	. = ..()
	if(!isidcard(is_card))
		return
	var/obj/item/card/id/clicked_by_this_id = is_card
	if(id_lock)
		var/obj/item/card/id/resolve_id = id_lock.resolve()
		if(clicked_by_this_id != resolve_id)
			balloon_alert(user, "locked by another id")
			return
		id_lock = null
	else
		id_lock = WEAKREF(clicked_by_this_id)
	balloon_alert(user, "successfully [id_lock ? "" : "un"]locked")

/// Creat manipulator hand effect on manipulator core.
/obj/machinery/big_manipulator/proc/create_manipulator_arm()
	manipulator_arm = new/obj/effect/big_manipulator_arm(src)
	manipulator_arm.dir = NORTH
	vis_contents += manipulator_arm

/// Deliting hand will destroy our manipulator core.
/obj/machinery/big_manipulator/proc/on_hand_qdel()
	SIGNAL_HANDLER

	deconstruct(TRUE)

/obj/machinery/big_manipulator/proc/switch_power_state(mob/user)
	var/new_power_state = !on

	if(!user)
		on = new_power_state
		if(!on)
			remove_all_huds()
		return

	if(new_power_state)
		if(!powered())
			balloon_alert(user, "no power!")
			return

		if(!anchored)
			balloon_alert(user, "anchor first!")
			return

		validate_all_points()

		on = new_power_state
		SStgui.update_uis(src)
		try_begin_full_cycle()

	else
		drop_held_atom()
		on = new_power_state
		remove_all_huds()
		end_current_task()
		SStgui.update_uis(src)

/obj/machinery/big_manipulator/proc/validate_all_points()
	for(var/datum/interaction_point/point in pickup_points)
		if(!point.is_valid())
			remove_hud_for_point(point)
			pickup_points.Remove(point)

	for(var/datum/interaction_point/point in dropoff_points)
		if(!point.is_valid())
			remove_hud_for_point(point)
			dropoff_points.Remove(point)

/// Attempts to press the power button.
/obj/machinery/big_manipulator/proc/try_press_on(mob/living/carbon/human/user)
	if(power_access_wire_cut)
		balloon_alert(user, "unresponsive!")
		return
	switch_power_state(user)
	if(on)
		balloon_alert(user, "activated")
	else
		balloon_alert(user, "deactivated")

/// Drop item that manipulator is manipulating.
/obj/machinery/big_manipulator/proc/drop_held_atom()
	if(isnull(held_object))
		return
	var/obj/obj_resolve = held_object?.resolve()
	obj_resolve?.forceMove(get_turf(obj_resolve))
	finish_manipulation()

/obj/machinery/big_manipulator/ui_interact(mob/user, datum/tgui/ui)
	if(id_lock)
		to_chat(user, span_warning("[src] is locked behind id authentication!"))
		ui?.close()
		return
	if(!anchored)
		to_chat(user, span_warning("[src] isn't attached to the ground!"))
		ui?.close()
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BigManipulator")
		ui.open()

/obj/machinery/big_manipulator/ui_data(mob/user)
	var/list/data = list()
	data["active"] = on
	data["highest_priority"] = override_priority
	data["current_task_type"] = current_task_type
	data["current_task_duration"] = current_task_duration
	data["min_delay"] = minimal_interaction_multiplier
	data["manipulator_position"] = "[x],[y]"

	var/list/pickup_points_data = list()
	for(var/datum/interaction_point/point in pickup_points)
		var/list/point_data = list()
		point_data["name"] = point.name
		point_data["turf"] = "[point.interaction_turf.x],[point.interaction_turf.y]"
		point_data["mode"] = "PICK"
		point_data["filters"] = point.type_filters
		point_data["item_filters"] = point.atom_filters
		point_data["filtering_mode"] = point.filtering_mode
		pickup_points_data += list(point_data)
	data["pickup_points"] = pickup_points_data

	var/list/dropoff_points_data = list()
	for(var/datum/interaction_point/point in dropoff_points)
		var/list/point_data = list()
		point_data["name"] = point.name
		point_data["turf"] = "[point.interaction_turf.x],[point.interaction_turf.y]"
		point_data["mode"] = point.interaction_mode
		point_data["filters"] = point.type_filters
		point_data["item_filters"] = point.atom_filters
		dropoff_points_data += list(point_data)
	data["dropoff_points"] = dropoff_points_data

	var/list/priority_list = list()
	for(var/datum/interaction_point/point in pickup_points)
		for(var/datum/manipulator_priority/priority in point.get_sorted_priorities())
			var/list/priority_data = list()
			priority_data["name"] = priority.name
			priority_data["priority_width"] = priority.number
			priority_list += list(priority_data)
	data["settings_list"] = priority_list

	return data

/obj/machinery/big_manipulator/ui_static_data(mob/user)
	var/list/data = list()
	data["delay_step"] = DELAY_STEP
	data["max_delay"] = MAX_DELAY
	return data

/obj/machinery/big_manipulator/ui_act(action, params, datum/tgui/ui)
	. = ..()
	if(.)
		return
	switch(action)
		if("run_cycle")
			try_press_on(ui.user)
			return TRUE

		if("drop_held_atom")
			drop_held_atom()
			return TRUE

		if("create_pickup_point")
			create_new_interaction_point(null, list(), FALSE, null, TRANSFER_TYPE_PICKUP)
			return TRUE

		if("create_dropoff_point")
			create_new_interaction_point(null, list(), FALSE, INTERACT_DROP, TRANSFER_TYPE_DROPOFF)
			return TRUE

		if("adjust_interaction_delay")
			var/new_delay = text2num(params["new_delay"])
			if(isnull(new_delay))
				return FALSE
			var/min_d = BASE_INTERACTION_TIME * minimal_interaction_multiplier
			interaction_delay = clamp(new_delay, min_d, MAX_DELAY)
			SStgui.update_uis(src)
			return TRUE

		if("highest_priority_change")
			override_priority = !override_priority
			return TRUE

		if("worker_interaction_change")
			// TODO: cycle interaction on the interaction point
			return TRUE
		if("change_priority")
			var/new_priority_number = params["priority"]
			for(var/datum/interaction_point/point in pickup_points)
				for(var/datum/manipulator_priority/priority in point.interaction_priorities)
					if(priority.number == new_priority_number)
						point.update_priority(priority, new_priority_number - 1)
						break
			return TRUE
		if("change_throw_range")
			// cycle_throw_range() TODO: should be handled in interaction_points.dm
			return TRUE

		if("move_point")
			var/index = params["index"]
			var/dx = text2num(params["dx"])
			var/dy = text2num(params["dy"])
			var/is_pickup = params["is_pickup"] == "true"

			var/list/points = is_pickup ? pickup_points : dropoff_points
			if(index < 1 || index > length(points))
				return FALSE

			var/datum/interaction_point/point = points[index]
			var/turf/new_turf = locate(x + dx, y + dy, z)

			if(!new_turf || isclosedturf(new_turf))

				return FALSE

			// Remove old HUD for this point before moving
			remove_hud_for_point(point)
			point.interaction_turf = new_turf
			update_hud_for_point(point, is_pickup ? TRANSFER_TYPE_PICKUP : TRANSFER_TYPE_DROPOFF)
			return TRUE


/obj/machinery/big_manipulator/proc/adjust_param_for_point(point_ref, param, value, mob/user)
	if(!param) // there may be no value if we're resetting stuff
		return FALSE

	var/datum/interaction_point/target_point = locate(point_ref)
	if(!target_point)
		return FALSE

	switch(param)
		if("set_name")
			target_point.name = "[value]"
			return TRUE

		if("reset_atom_filters")
			target_point.atom_filters = list()
			return TRUE

		if("toggle_dropoff_point_overflow")
			target_point.should_overflow = !target_point.should_overflow
			return TRUE

		if("cycle_dropoff_point_interaction")
			target_point.interaction_mode = cycle_value(target_point.interaction_mode, list(INTERACT_DROP, INTERACT_USE, INTERACT_THROW))
			return TRUE

		if("toggle_filter_skip")
			target_point.filters_status = !target_point.filters_status
			return TRUE

		if("cycle_pickup_point_type")
			target_point.filtering_mode = cycle_value(target_point.filtering_mode, list(TAKE_ITEMS, TAKE_CLOSETS, TAKE_HUMANS))
			return TRUE

		if("cycle_worker_interaction")
			target_point.worker_interaction = cycle_value(target_point.worker_interaction, list(WORKER_NORMAL_USE, WORKER_SINGLE_USE, WORKER_EMPTY_USE))
			return TRUE

		if("set_throw_range")
			target_point.throw_range = clamp(text2num(value), 1, 7)
			return TRUE

		if("add_atom_filter_from_held")
			var/obj/item/held_item = user.get_active_held_item()
			if(held_item)
				target_point.atom_filters += WEAKREF(held_item)
			return TRUE




/// Cycles the given value in the given list. Retuns the next value in the list, or the first one if the list isn't long enough.
/obj/machinery/big_manipulator/proc/cycle_value(current_value, list/possible_values)
	var/current_index = possible_values.Find(current_value)
	if(current_index == null)
		to_chat(world, span_notice("DEBUG: Value cycled to [possible_values[1]]"))
		return possible_values[1]

	var/next_index = (current_index % possible_values.len) + 1
	to_chat(world, span_notice("DEBUG: Value cycled to [possible_values[next_index]]"))
	return possible_values[next_index]

/// Begins a new task with the specified type and duration
/obj/machinery/big_manipulator/proc/start_task(task_type, duration)
	end_current_task() // End any previous task first (momentarily sets IDLE)

	current_task_start_time = world.time
	current_task_duration = duration / 10 // Duration is in deciseconds for TGUI
	current_task_type = task_type
	status = STATUS_BUSY // Set status to BUSY for the new task
	SStgui.update_uis(src)

/// Ends the current task
/obj/machinery/big_manipulator/proc/end_current_task()
	current_task_start_time = 0
	current_task_duration = 0
	current_task_type = "idle"
	balloon_alert(usr, "idle")
	status = STATUS_IDLE // Set status to IDLE when a task truly ends
	SStgui.update_uis(src) // Update UI immediately

/obj/machinery/big_manipulator/proc/remove_hud_for_point(datum/interaction_point/point)
	if(!point)
		return

	// Удаляем все HUD-элементы, связанные с этой точкой
	for(var/image/hud_image in hud_points)
		if(hud_image.loc == point.interaction_turf)
			hud_points -= hud_image
			qdel(hud_image)
			break

/obj/machinery/big_manipulator/proc/remove_all_huds()
	for(var/image/hud_image in hud_points)
		qdel(hud_image)
	hud_points.Cut()
