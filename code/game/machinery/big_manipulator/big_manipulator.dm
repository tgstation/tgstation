/obj/machinery/big_manipulator
	name = "big manipulator"
	desc = "Operates different objects. Truly, a groundbreaking innovation..."
	icon = 'icons/obj/machines/big_manipulator_parts/big_manipulator_core.dmi'
	icon_state = "core"
	post_init_icon_state = "core"
	density = TRUE
	circuit = /obj/item/circuitboard/machine/big_manipulator
	greyscale_colors = "#d8ce13"
	greyscale_config = /datum/greyscale_config/big_manipulator
	hud_possible = list(BIG_MANIP_HUD)

	/// Is the manipulator turned on?
	var/on = FALSE
	/// Was the next cycle already scheduled?
	var/next_cycle_scheduled = FALSE

	/// How quickly the manipulator will process it's actions.
	var/speed_multiplier = 1
	var/min_speed_multiplier =  MIN_SPEED_MULTIPLIER_TIER_1
	var/max_speed_multiplier =  MAX_SPEED_MULTIPLIER_TIER_1

	/// The current task.
	var/current_task = CURRENT_TASK_NONE
	var/current_task_start_time = 0
	var/current_task_duration = 0

	/// The object inside the manipulator.
	var/datum/weakref/held_object = null
	/// The chimp worker that uses the manipulator (handles USE cases).
	var/datum/weakref/monkey_worker = null
	/// Weakref to the ID that locked this manipulator.
	var/datum/weakref/id_lock = null
	/// The manipulator's arm.
	var/obj/effect/big_manipulator_arm/manipulator_arm = null
	/// Is the power access wire cut? Disables the power button if `TRUE`.
	var/power_access_wire_cut = FALSE

	/// How many interaction points of each kind can we have?
	var/interaction_point_limit = MAX_INTERACTION_POINTS_TIER_1
	/// List of pickup points.
	var/list/pickup_points = list()
	/// List of dropoff points.
	var/list/dropoff_points = list()

	/// Which tasking scenario we use for pickup points?
	var/pickup_tasking = TASKING_ROUND_ROBIN
	/// Which tasking scenario we use for dropoff points?
	var/dropoff_tasking = TASKING_ROUND_ROBIN

	/// List of all HUD icons resembling interaction points.
	var/list/hud_points = list()

	/// Pickup strategy for tasking.
	var/datum/tasking_strategy/pickup_strategy
	/// Dropoff strategy for tasking.
	var/datum/tasking_strategy/dropoff_strategy

/// Re-creates hud images for the points
/obj/machinery/big_manipulator/proc/update_hud()
	LAZYCLEARLIST(hud_points)

	var/image/main_hud = hud_list[BIG_MANIP_HUD]
	if(!main_hud)
		return

	main_hud.loc = get_turf(src)
	main_hud.appearance = mutable_appearance('icons/effects/interaction_points.dmi', null, ABOVE_ALL_MOB_LAYER, src, GAME_PLANE)

	main_hud.overlays.Cut()
	var/list/point_overlays = list()

	for(var/i in 1 to length(pickup_points))
		var/datum/interaction_point/point = pickup_points[i]
		var/turf/target_turf = point.interaction_turf
		if(target_turf)
			var/mutable_appearance/point_appearance = mutable_appearance('icons/effects/interaction_points.dmi', "pickup_[i]", ABOVE_ALL_MOB_LAYER, src, GAME_PLANE)
			var/turf/manip_turf = get_turf(src)
			point_appearance.pixel_x = (target_turf.x - manip_turf.x) * 32
			point_appearance.pixel_y = (target_turf.y - manip_turf.y) * 32
			point_overlays += point_appearance

	for(var/i in 1 to length(dropoff_points))
		var/datum/interaction_point/point = dropoff_points[i]
		var/turf/target_turf = point.interaction_turf
		if(target_turf)
			var/mutable_appearance/point_appearance = mutable_appearance('icons/effects/interaction_points.dmi', "dropoff_[i]", ABOVE_ALL_MOB_LAYER, src, GAME_PLANE)
			var/turf/manip_turf = get_turf(src)
			point_appearance.pixel_x = (target_turf.x - manip_turf.x) * 32
			point_appearance.pixel_y = (target_turf.y - manip_turf.y) * 32
			point_overlays += point_appearance

	main_hud.overlays += point_overlays
	hud_points += main_hud
	set_hud_image_active(BIG_MANIP_HUD)

/// Attempts to find a suitable turf near the manipulator
/obj/machinery/big_manipulator/proc/find_suitable_turf()
	var/turf/center = get_turf(src)

	for(var/turf/checked_turf in orange(center, 1))
		if(!isclosedturf(checked_turf))
			return checked_turf

	// didn't find any :boowomp:
	return null

/// Attempts to create a new interaction point and assign it to the correct list.
/obj/machinery/big_manipulator/proc/create_new_interaction_point(mob/user, turf/new_turf, list/new_filters, new_filters_status, new_interaction_mode, transfer_type)
	if(!new_turf || !isturf(new_turf))
		new_turf = find_suitable_turf()
		if(!new_turf)
			balloon_alert(user, "no suitable turfs found!")
			return FALSE

	var/list/current_points = (transfer_type == TRANSFER_TYPE_PICKUP) ? pickup_points : dropoff_points
	var/point_type = (transfer_type == TRANSFER_TYPE_PICKUP) ? "pickup" : "dropoff"

	if(length(current_points) + 1 > interaction_point_limit)
		balloon_alert(user, "[point_type] point limit reached!")
		return FALSE

	var/datum/stock_part/servo/locate_servo = locate() in component_parts
	var/manipulator_tier = locate_servo ? locate_servo.tier : 1

	var/datum/interaction_point/new_interaction_point = new(new_turf, new_filters, new_filters_status, new_interaction_mode, manipulator_tier)

	if(QDELETED(new_interaction_point)) // if something STILL somehow went wrong
		return FALSE

	current_points += new_interaction_point

	if(obj_flags & EMAGGED)
		new_interaction_point.type_filters += /mob/living

	if(is_operational)
		update_hud()

	return new_interaction_point

/obj/machinery/big_manipulator/Initialize(mapload)
	. = ..()
	create_manipulator_arm()
	process_upgrades()
	if(on)
		toggle_power_state(null)
	set_wires(new /datum/wires/big_manipulator(src))
	register_context()

	for(var/datum/atom_hud/data/diagnostic/diag_hud in GLOB.huds)
		diag_hud.add_atom_to_hud(src)

	prepare_huds()
	update_hud()
	update_strategies()

/// Checks the component tiers, adjusting the properties of the manipulator.
/obj/machinery/big_manipulator/proc/process_upgrades()
	var/datum/stock_part/servo/locate_servo = locate() in component_parts
	if(!locate_servo)
		return

	var/manipulator_tier = locate_servo.tier
	switch(manipulator_tier)
		if(-INFINITY to 1)
			min_speed_multiplier = MIN_SPEED_MULTIPLIER_TIER_1
			max_speed_multiplier = MAX_SPEED_MULTIPLIER_TIER_1
			interaction_point_limit = MAX_INTERACTION_POINTS_TIER_1
			set_greyscale(COLOR_YELLOW)
			manipulator_arm?.set_greyscale(COLOR_YELLOW)
		if(2)
			min_speed_multiplier = MIN_SPEED_MULTIPLIER_TIER_2
			max_speed_multiplier = MAX_SPEED_MULTIPLIER_TIER_2
			interaction_point_limit = MAX_INTERACTION_POINTS_TIER_2
			set_greyscale(COLOR_ORANGE)
			manipulator_arm?.set_greyscale(COLOR_ORANGE)
		if(3)
			min_speed_multiplier = MIN_SPEED_MULTIPLIER_TIER_3
			max_speed_multiplier = MAX_SPEED_MULTIPLIER_TIER_3
			interaction_point_limit = MAX_INTERACTION_POINTS_TIER_3
			set_greyscale(COLOR_RED)
			manipulator_arm?.set_greyscale(COLOR_RED)
		if(4 to INFINITY)
			min_speed_multiplier = MIN_SPEED_MULTIPLIER_TIER_4
			max_speed_multiplier = MAX_SPEED_MULTIPLIER_TIER_4
			interaction_point_limit = MAX_INTERACTION_POINTS_TIER_4
			set_greyscale(COLOR_PURPLE)
			manipulator_arm?.set_greyscale(COLOR_PURPLE)

	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * BASE_POWER_USAGE * manipulator_tier

	for(var/datum/interaction_point/each_point in pickup_points)
		each_point.interaction_priorities = each_point.fill_priority_list(manipulator_tier)

	for(var/datum/interaction_point/each_point in dropoff_points)
		each_point.interaction_priorities = each_point.fill_priority_list(manipulator_tier)

/obj/machinery/big_manipulator/examine(mob/user)
	. = ..()
	var/mob/monkey_resolve = monkey_worker?.resolve()
	if(!isnull(monkey_resolve))
		. += "You can see a poor [monkey_resolve.name] buckled to [src]. You wonder if it's getting paid enough."

/obj/machinery/big_manipulator/attack_hand_secondary(mob/living/user, list/modifiers)
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

	QDEL_NULL(manipulator_arm)
	// QDEL_NULL(monkey_worker.resolve())
	// QDEL_NULL(held_object.resolve())
	id_lock = null
	. = ..()

/obj/machinery/big_manipulator/Exited(atom/movable/gone, direction)
	. = ..()
	if(isnull(monkey_worker))
		return

	var/mob/living/carbon/human/species/monkey/poor_monkey = monkey_worker.resolve()
	if(gone != poor_monkey)
		return

	manipulator_arm.vis_contents -= poor_monkey
	poor_monkey.remove_offsets(type)
	monkey_worker = null

/obj/machinery/big_manipulator/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	. = ..()

	if(!old_loc || !isturf(old_loc))
		return

	var/turf/old_turf = old_loc
	var/turf/new_turf = get_turf(src)
	if(!new_turf || old_turf == new_turf)
		return

	var/dx = new_turf.x - old_turf.x
	var/dy = new_turf.y - old_turf.y

	if(dx == 0 && dy == 0) // if we rotated for instance
		return

	for(var/datum/interaction_point/point in pickup_points)
		update_point_position(point, dx, dy)

	for(var/datum/interaction_point/point in dropoff_points)
		update_point_position(point, dx, dy)

	if(is_operational)
		update_hud()

/// Updates a single interaction point's position by the given offset
/obj/machinery/big_manipulator/proc/update_point_position(datum/interaction_point/point, dx, dy)
	if(!point || !point.interaction_turf)
		return

	var/turf/old_turf = point.interaction_turf
	if(!old_turf)
		return

	var/turf/manipulator_turf = get_turf(src)
	if(!manipulator_turf)
		return

	var/turf/new_turf = locate(old_turf.x + dx, old_turf.y + dy, manipulator_turf.z)

	// if manipulator is not anchored, allow points to be anywhere (even in walls) to not mess up your stuff when moving it
	if(!anchored)
		if(new_turf)
			point.interaction_turf = new_turf
		return

	if(!new_turf || isclosedturf(new_turf))
		new_turf = find_suitable_turf_near(new_turf || old_turf)
		if(!new_turf)
			remove_invalid_point(point)
			return

	if(new_turf == old_turf)
		return

	point.interaction_turf = new_turf

/// Finds a suitable turf near the given location
/obj/machinery/big_manipulator/proc/find_suitable_turf_near(turf/center)
	if(!center)
		return null

	var/turf/manipulator_turf = get_turf(src)
	if(!manipulator_turf)
		return null

	for(var/turf/each in orange(1, src))
		if(!isclosedturf(each))
			return each

	return null

/// Removes an invalid interaction point from the lists.
/obj/machinery/big_manipulator/proc/remove_invalid_point(datum/interaction_point/point)
	if(!point)
		return

	pickup_points.Remove(point)
	dropoff_points.Remove(point)

	qdel(point)
	if(is_operational)
		update_hud()

/obj/machinery/big_manipulator/emag_act(mob/user, obj/item/card/emag/emag_card)
	. = ..()
	if(obj_flags & EMAGGED)
		return FALSE

	balloon_alert(user, "overloaded")
	obj_flags |= EMAGGED

	for(var/datum/interaction_point/pickup_point in pickup_points)
		pickup_point.type_filters += /mob/living
	for(var/datum/interaction_point/dropoff_point in dropoff_points)
		dropoff_point.type_filters += /mob/living

	return TRUE

/obj/machinery/big_manipulator/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	default_unfasten_wrench(user, tool, time = 1 SECONDS)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/big_manipulator/can_be_unfasten_wrench(mob/user, silent)
	if(current_task != CURRENT_TASK_NONE || on)
		to_chat(user, span_warning("[src] is activated!"))
		return FAILED_UNFASTEN
	return ..()

/obj/machinery/big_manipulator/default_unfasten_wrench(mob/user, obj/item/wrench, time)
	. = ..()
	if(. == SUCCESSFUL_UNFASTEN)
		if(anchored) // on anchoring, validate all points and remove invalid ones
			validate_all_points()
			update_hud()
		else
			remove_all_huds()

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
	if(current_task != CURRENT_TASK_NONE)
		balloon_alert(user, "turn it off first!")
		return

	var/mob/living/carbon/human/species/monkey/poor_monkey = monkey_worker?.resolve()
	if(!poor_monkey)
		return

	balloon_alert(user, "trying to unbuckle...")
	if(!do_after(user, 3 SECONDS, src))
		balloon_alert(user, "interrupted")
		return

	balloon_alert(user, "unbuckled")
	poor_monkey.drop_all_held_items()
	poor_monkey.forceMove(drop_point)

/obj/machinery/big_manipulator/mouse_drop_receive(atom/monkey, mob/user, params)
	if(current_task != CURRENT_TASK_NONE)
		balloon_alert(user, "turn it off first!")
		return

	if(monkey_worker?.resolve())
		return

	if(!ismonkey(monkey))
		return

	var/mob/living/carbon/human/species/monkey/poor_monkey = monkey
	if(poor_monkey.mind)
		balloon_alert(user, "too smart!")
		return

	poor_monkey.balloon_alert(user, "trying to buckle...")
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

/obj/machinery/big_manipulator/attackby(obj/item/some_item, mob/user, params)
	. = ..()
	if(!isidcard(some_item))
		return

	var/obj/item/card/id/clicked_by_this_id = some_item

	if(!id_lock)
		id_lock = WEAKREF(clicked_by_this_id)
		balloon_alert(user, "successfully locked")
		return
	var/obj/item/card/id/resolve_id = id_lock.resolve()
	if(clicked_by_this_id != resolve_id)
		balloon_alert(user, "locked by another id")
		return
	id_lock = null
	balloon_alert(user, "successfully unlocked")

/// Attaching the arm effect to the core.
/obj/machinery/big_manipulator/proc/create_manipulator_arm()
	manipulator_arm = new /obj/effect/big_manipulator_arm(src)
	manipulator_arm.dir = NORTH
	vis_contents += manipulator_arm

/obj/machinery/big_manipulator/proc/toggle_power_state(mob/user)
	var/newly_on = !on

	if(!user)
		on = newly_on
		if(!on)
			remove_all_huds()
		return

	if(newly_on)
		if(!powered())
			balloon_alert(user, "no power!")
			return

		if(!anchored)
			balloon_alert(user, "anchor first!")
			return

		validate_all_points()

		on = newly_on
		SStgui.update_uis(src)
		try_kickstart(user)

	else
		drop_held_atom()
		on = newly_on
		next_cycle_scheduled = FALSE
		// Set stopping task instead of ending current task immediately
		if(current_task != CURRENT_TASK_NONE && current_task != CURRENT_TASK_STOPPING)
			start_task(CURRENT_TASK_STOPPING, 0)
			// Schedule automatic completion of stopping task
			addtimer(CALLBACK(src, PROC_REF(complete_stopping_task)), 1 SECONDS)
		else
			end_current_task()
		SStgui.update_uis(src)

/obj/machinery/big_manipulator/proc/validate_all_points()
	for(var/datum/interaction_point/point in pickup_points)
		if(!point.is_valid())
			pickup_points -= point
			qdel(point)

	for(var/datum/interaction_point/point in dropoff_points)
		if(!point.is_valid())
			dropoff_points -= point
			qdel(point)

	if(is_operational)
		update_hud()

/// Attempts to press the power button.
/obj/machinery/big_manipulator/proc/try_press_on(mob/living/carbon/human/user)
	if(power_access_wire_cut)
		balloon_alert(user, "unresponsive!")
		return

	// Reject activation during stopping task
	if(current_task == CURRENT_TASK_STOPPING)
		balloon_alert(user, "stopping in progress!")
		return

	toggle_power_state(user)
	if(on)
		balloon_alert(user, "activated")
	else
		balloon_alert(user, "deactivated")

/// Drop the held atom.
/obj/machinery/big_manipulator/proc/drop_held_atom()
	if(isnull(held_object))
		return
	var/obj/obj_resolve = held_object?.resolve()
	obj_resolve?.forceMove(get_turf(obj_resolve))
	finish_manipulation(TRANSFER_TYPE_DROPOFF) // MCBALAAM TODO

/obj/machinery/big_manipulator/ui_interact(mob/user, datum/tgui/ui)
	if(id_lock)
		to_chat(user, span_warning("[src] is locked behind ID authentication!"))
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
	data["current_task"] = current_task
	data["current_task_duration"] = current_task_duration
	data["speed_multiplier"] = speed_multiplier
	data["min_speed_multiplier"] = min_speed_multiplier
	data["max_speed_multiplier"] = max_speed_multiplier
	data["manipulator_position"] = "[x],[y]"
	data["pickup_tasking"] = pickup_tasking
	data["dropoff_tasking"] = dropoff_tasking

	var/list/pickup_points_data = list()
	for(var/datum/interaction_point/point in pickup_points)
		var/list/point_data = list()
		point_data["name"] = point.name
		point_data["id"] = REF(point)
		var/turf/resolved_turf = point.interaction_turf
		point_data["turf"] = resolved_turf ? "[resolved_turf.x],[resolved_turf.y]" : "0,0"
		point_data["mode"] = "PICK"
		var/list/filter_names = list()
		for(var/obj/item/some_path as anything in point.atom_filters)
			filter_names += some_path::name
		point_data["item_filters"] = filter_names
		point_data["filters_status"] = point.should_use_filters
		point_data["filtering_mode"] = point.filtering_mode
		point_data["worker_interaction"] = point.worker_interaction
		point_data["overflow_status"] = point.overflow_status
		point_data["worker_use_rmb"] = point.worker_use_rmb
		point_data["worker_combat_mode"] = point.worker_combat_mode
		point_data["throw_range"] = point.throw_range

		var/list/settings_list_pick = list()
		for(var/datum/manipulator_priority/pr_pick in point.interaction_priorities)
			var/list/entry_pick = list()
			entry_pick["name"] = pr_pick.name
			entry_pick["active"] = pr_pick.active
			settings_list_pick += list(entry_pick)
		point_data["settings_list"] = settings_list_pick
		pickup_points_data += list(point_data)
	data["pickup_points"] = pickup_points_data

	var/list/dropoff_points_data = list()
	for(var/datum/interaction_point/point in dropoff_points)
		var/list/point_data = list()
		point_data["name"] = point.name
		point_data["id"] = REF(point)
		var/turf/resolved_turf = point.interaction_turf
		point_data["turf"] = resolved_turf ? "[resolved_turf.x],[resolved_turf.y]" : "0,0"
		point_data["mode"] = point.interaction_mode
		var/list/filter_names = list()
		for(var/obj/item/some_path as anything in point.atom_filters)
			filter_names += some_path::name
		point_data["item_filters"] = filter_names
		point_data["filters_status"] = point.should_use_filters
		point_data["filtering_mode"] = point.filtering_mode
		point_data["worker_interaction"] = point.worker_interaction
		point_data["overflow_status"] = point.overflow_status
		point_data["worker_use_rmb"] = point.worker_use_rmb
		point_data["worker_combat_mode"] = point.worker_combat_mode
		point_data["throw_range"] = point.throw_range
		point_data["use_post_interaction"] = point.use_post_interaction

		var/list/settings_list_drop = list()
		for(var/datum/manipulator_priority/pr_drop in point.interaction_priorities)
			var/list/entry_drop = list()
			entry_drop["name"] = pr_drop.name
			entry_drop["active"] = pr_drop.active
			settings_list_drop += list(entry_drop)
		point_data["settings_list"] = settings_list_drop
		dropoff_points_data += list(point_data)
	data["dropoff_points"] = dropoff_points_data

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
			create_new_interaction_point(ui.user, null, list(), FALSE, null, TRANSFER_TYPE_PICKUP)
			return TRUE

		if("create_dropoff_point")
			create_new_interaction_point(ui.user, null, list(), FALSE, INTERACT_DROP, TRANSFER_TYPE_DROPOFF)
			return TRUE

		if("reset_tasking_Pickup Points")
			pickup_strategy.current_index = 1
			balloon_alert(ui.user, "index reset")
			return TRUE

		if("reset_tasking_Dropoff Points")
			dropoff_strategy.current_index = 1
			balloon_alert(ui.user, "index reset")
			return TRUE

		if("cycle_tasking_schedule")
			var/new_schedule = params["new_schedule"]

			if(new_schedule in list(TASKING_ROUND_ROBIN, TASKING_STRICT_ROBIN, TASKING_PREFER_FIRST))
				var/is_pickup = params["is_pickup"]
				if(is_pickup)
					pickup_tasking = new_schedule
				else
					dropoff_tasking = new_schedule
				update_strategies()
			return TRUE

		if("adjust_interaction_speed")
			var/new_speed = text2num(params["new_speed"])
			if(isnull(new_speed))
				return FALSE

			speed_multiplier = clamp(new_speed, min_speed_multiplier, max_speed_multiplier)
			return TRUE

		if("unbuckle")
			unbuckle_all_mobs()
			monkey_worker = null
			return TRUE

		if("adjust_point_param")
			return adjust_param_for_point(params["pointId"], params["param"], params["value"], ui.user)

/obj/machinery/big_manipulator/proc/adjust_param_for_point(point_ref, param, value, mob/user)
	if(!param) // there may be no value if we're resetting stuff
		return FALSE

	var/datum/interaction_point/target_point = locate(point_ref) in (pickup_points + dropoff_points)
	if(!target_point)
		return FALSE

	switch(param)
		if("set_name")
			target_point.name = sanitize_name(value, allow_numbers = TRUE)
			return TRUE

		if("toggle_priority")
			return target_point.tick_priority_by_index(value)

		if("remove_point")
			pickup_points.Remove(target_point)
			dropoff_points.Remove(target_point) // one'll hit for sure
			update_hud()
			qdel(target_point)
			return TRUE

		if("reset_atom_filters")
			target_point.atom_filters = list()
			return TRUE

		if("cycle_dropoff_point_interaction")
			target_point.interaction_mode = cycle_value(target_point.interaction_mode, monkey_worker ? list(INTERACT_DROP, INTERACT_THROW, INTERACT_USE) : list(INTERACT_DROP, INTERACT_THROW))
			var/datum/stock_part/servo/locate_servo = locate() in component_parts
			var/manipulator_tier = locate_servo ? locate_servo.tier : 1
			target_point.interaction_priorities = target_point.fill_priority_list(manipulator_tier)
			return TRUE

		if("toggle_filter_skip")
			target_point.should_use_filters = !target_point.should_use_filters
			return TRUE

		if("cycle_pickup_point_type")
			target_point.filtering_mode = cycle_value(target_point.filtering_mode, obj_flags & EMAGGED ? list(TAKE_ITEMS, TAKE_CLOSETS, TAKE_HUMANS) : list(TAKE_ITEMS, TAKE_CLOSETS))
			return TRUE

		if("cycle_worker_interaction")
			target_point.worker_interaction = cycle_value(target_point.worker_interaction, list(WORKER_NORMAL_USE, WORKER_SINGLE_USE, WORKER_EMPTY_USE))
			return TRUE

		if("cycle_overflow_status")
			target_point.overflow_status = cycle_value(target_point.overflow_status, list(POINT_OVERFLOW_ALLOWED, POINT_OVERFLOW_FILTERS, POINT_OVERFLOW_HELD, POINT_OVERFLOW_FORBIDDEN))
			return TRUE

		if("cycle_throw_range")
			target_point.throw_range = cycle_value(target_point.throw_range, list(1, 2, 3, 4, 5, 6, 7))
			return TRUE

		if("cycle_post_interaction")
			target_point.use_post_interaction = cycle_value(target_point.use_post_interaction, list(POST_INTERACTION_DROP_AT_POINT, POST_INTERACTION_DROP_AT_MACHINE, POST_INTERACTION_DROP_NEXT_FITTING, POST_INTERACTION_WAIT))
			return TRUE

		if("add_atom_filter_from_held")
			var/obj/item/held_item = user.get_active_held_item()

			if(!held_item)
				return FALSE

			for(var/filter_path in target_point.atom_filters)
				if(istype(held_item, filter_path))
					return FALSE

			target_point.atom_filters += held_item.type
			return TRUE

		if("delete_filter")
			target_point.atom_filters.Cut(value, value + 1)
			return TRUE

		if("toggle_worker_rmb")
			target_point.worker_use_rmb = !target_point.worker_use_rmb
			return TRUE

		if("toggle_worker_combat")
			target_point.worker_combat_mode = !target_point.worker_combat_mode
			return TRUE

		if("priority_move_up")
			return target_point.move_priority_up_by_index(value)

		if("move_to")
			var/button_number = text2num(value["buttonNumber"])

			var/dx = ((button_number - 1) % 3) - 1
			var/dy = 1 - round((button_number - 1) / 3)

			var/turf/new_turf = locate(x + dx, y + dy, z)
			if(!new_turf || isclosedturf(new_turf))
				return FALSE

			target_point.interaction_turf = new_turf
			update_hud()
			return TRUE

/// Cycles the given value in the given list. Retuns the next value in the list, or the first one if the list isn't long enough.
/obj/machinery/big_manipulator/proc/cycle_value(current_value, list/possible_values)
	var/current_index = possible_values.Find(current_value)
	if(current_index == 0)
		return possible_values[1]

	var/next_index = (current_index % length(possible_values)) + 1
	return possible_values[next_index]

/// Begins a new task with the specified type and duration
/obj/machinery/big_manipulator/proc/start_task(task_type, duration)
	if(current_task == CURRENT_TASK_STOPPING)
		return

	end_current_task() // ends any previous task first (momentarily sets IDLE)
	current_task_start_time = world.time
	current_task_duration = duration
	current_task = task_type
	SStgui.update_uis(src)

/// Ends the current task
/obj/machinery/big_manipulator/proc/end_current_task()
	current_task_start_time = 0
	current_task_duration = 0
	if(current_task == CURRENT_TASK_STOPPING)
		current_task = CURRENT_TASK_NONE
	SStgui.update_uis(src) // Update UI immediately

/// Completes the stopping task and transitions to TASK_NONE
/obj/machinery/big_manipulator/proc/complete_stopping_task()
	on = FALSE
	next_cycle_scheduled = FALSE
	end_current_task()
	SStgui.update_uis(src)

/obj/machinery/big_manipulator/proc/remove_all_huds()
	var/image/main_hud = hud_list[BIG_MANIP_HUD]
	if(main_hud)
		main_hud.overlays.Cut()
		main_hud.loc = null

	hud_points.Cut()
	set_hud_image_inactive(BIG_MANIP_HUD)

/obj/machinery/big_manipulator/proc/update_strategies()
	pickup_strategy = create_strategy(pickup_tasking)
	dropoff_strategy = create_strategy(dropoff_tasking)

/obj/machinery/big_manipulator/proc/create_strategy(tasking_mode)
	switch(tasking_mode)
		if(TASKING_PREFER_FIRST)
			return new /datum/tasking_strategy/prefer_first()
		if(TASKING_ROUND_ROBIN)
			return new /datum/tasking_strategy/round_robin()
		if(TASKING_STRICT_ROBIN)
			return new /datum/tasking_strategy/strict_robin()
	return new /datum/tasking_strategy/prefer_first()
