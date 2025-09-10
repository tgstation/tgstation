/obj/machinery/big_manipulator
	name = "big manipulator"
	desc = "Operates different objects. Truly, a groundbreaking innovation..."
	icon = 'icons/obj/machines/big_manipulator_parts/big_manipulator_core.dmi'
	icon_state = "core"
	density = TRUE
	circuit = /obj/item/circuitboard/machine/big_manipulator
	greyscale_colors = "#d8ce13"
	greyscale_config = /datum/greyscale_config/big_manipulator
	hud_possible = list(BIG_MANIP_HUD)

	/// How quickly the manipulator will process it's actions.
	var/speed_multiplier = 1

	var/min_speed_multiplier =  MIN_SPEED_MULTIPLIER_TIER_1
	var/max_speed_multiplier =  MAX_SPEED_MULTIPLIER_TIER_1

	/// How many interaction points of each kind can we have?
	var/interaction_point_limit = MAX_INTERACTION_POINTS_TIER_1

	/// The current task of the manipulator.
	var/current_task = CURRENT_TASK_NONE

	/// Is the manipulator turned on?
	var/on = FALSE
	/// Is a cycle timer already running?
	var/cycle_timer_running = FALSE


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

	/// History of accessed pickup points for round-robin tasking.
	var/roundrobin_history_pickup = 1
	/// History of accessed dropoff points for round-robin tasking.
	var/roundrobin_history_dropoff = 1
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

/obj/machinery/big_manipulator/proc/update_hud()
  LAZYCLEARLIST(hud_points)

  var/image/main_hud = hud_list[BIG_MANIP_HUD]
  if(!main_hud)
    return

  main_hud.loc = get_turf(src)
  main_hud.appearance = mutable_appearance('icons/effects/interaction_points.dmi', null, ABOVE_NORMAL_TURF_LAYER, src, GAME_PLANE)

  main_hud.overlays.Cut()
  var/list/point_overlays = list()

  for(var/i = 1; i <= length(pickup_points); i++)
    var/datum/interaction_point/point = pickup_points[i]
    var/turf/target_turf = point.interaction_turf.resolve()
    if(target_turf)
      var/mutable_appearance/point_appearance = mutable_appearance('icons/effects/interaction_points.dmi', "pickup_[i]", ABOVE_NORMAL_TURF_LAYER, src, GAME_PLANE)
      var/turf/manip_turf = get_turf(src)
      point_appearance.pixel_x = (target_turf.x - manip_turf.x) * 32
      point_appearance.pixel_y = (target_turf.y - manip_turf.y) * 32
      point_overlays += point_appearance

  for(var/i = 1; i <= length(dropoff_points); i++)
    var/datum/interaction_point/point = dropoff_points[i]
    var/turf/target_turf = point.interaction_turf.resolve()
    if(target_turf)
      var/mutable_appearance/point_appearance = mutable_appearance('icons/effects/interaction_points.dmi', "dropoff_[i]", ABOVE_NORMAL_TURF_LAYER, src, GAME_PLANE)
      var/turf/manip_turf = get_turf(src)
      point_appearance.pixel_x = (target_turf.x - manip_turf.x) * 32
      point_appearance.pixel_y = (target_turf.y - manip_turf.y) * 32
      point_overlays += point_appearance

  main_hud.overlays += point_overlays
  hud_points += main_hud
  set_hud_image_active(BIG_MANIP_HUD)

/// Attempts to find the closest open turf to the manipulator
/obj/machinery/big_manipulator/proc/find_suitable_turf()
	var/turf/center = get_turf(src)

	var/list/directions = list(NORTH, EAST, SOUTH, WEST, NORTHWEST, SOUTHWEST, SOUTHEAST, NORTHEAST)
	for(var/dir in directions)
		var/turf/checked_turf = get_step(center, dir)
		if(checked_turf && !isclosedturf(checked_turf))
			return checked_turf

	// didn't find any :boowomp:
	return null

/// Attempts to create a new interaction point and assign it to the correct list.
/// Arguments: `new_turf` (turf), `new_filters` (list), `new_filters_status` (boolean),
/// `new_interaction_mode` (use a define), `transfer_type` (use a define).
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

	if(QDELETED(new_interaction_point)) // if something STILL somehow went wrong
		return FALSE

	switch(transfer_type) // assigning to the correct list
		if(TRANSFER_TYPE_PICKUP)
			pickup_points += new_interaction_point
		if(TRANSFER_TYPE_DROPOFF)
			dropoff_points += new_interaction_point

	if(obj_flags & EMAGGED)
		new_interaction_point.type_filters += /mob/living

	if(is_operational)
		update_hud()

	return new_interaction_point

/// Allow each point to interact with mobs when the manipulator is emagged.
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
		toggle_power_state(null)
	set_wires(new /datum/wires/big_manipulator(src))
	register_context()
	prepare_huds()
	for(var/datum/atom_hud/data/diagnostic/diag_hud in GLOB.huds)
		diag_hud.add_atom_to_hud(src)

	update_hud()

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

	// updating all interaction points to maintain their relative positions when the manipulator moves
	// this ensures that interaction points move with the manipulator, preserving their relative layout
	update_interaction_points_on_move(old_loc)

/// Updates all interaction points to maintain their relative positions when the manipulator moves
/obj/machinery/big_manipulator/proc/update_interaction_points_on_move(atom/old_loc)
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

	var/turf/old_turf = point.interaction_turf.resolve()
	if(!old_turf)
		return

	var/turf/manipulator_turf = get_turf(src)
	if(!manipulator_turf)
		return

	var/turf/new_turf = locate(old_turf.x + dx, old_turf.y + dy, manipulator_turf.z)

	// if manipulator is not anchored, allow points to be anywhere (even in walls) to not mess up your stuff when moving it
	if(!anchored)
		if(new_turf)
			point.interaction_turf = WEAKREF(new_turf)
		return

	if(!new_turf || isclosedturf(new_turf))
		new_turf = find_suitable_turf_near(new_turf || old_turf)
		if(!new_turf)
			remove_invalid_point(point)
			return

	if(new_turf == old_turf)
		return

	point.interaction_turf = WEAKREF(new_turf)

/// Finds a suitable turf near the given location
/obj/machinery/big_manipulator/proc/find_suitable_turf_near(turf/center)
	if(!center)
		return null

	var/turf/manipulator_turf = get_turf(src)
	if(!manipulator_turf)
		return null

	if(center.z != manipulator_turf.z)
		center = locate(center.x, center.y, manipulator_turf.z)
		if(!center)
			return null

	var/list/directions = list(NORTH, EAST, SOUTH, WEST, NORTHEAST, SOUTHEAST, SOUTHWEST, NORTHWEST)
	for(var/dir in directions)
		var/turf/check = get_step(center, dir)
		if(check && !isclosedturf(check))
			return check

	return null

/// Removes an invalid interaction point from the manipulator
/obj/machinery/big_manipulator/proc/remove_invalid_point(datum/interaction_point/point) // TODO
	if(!point)
		return

	if(point in pickup_points)
		pickup_points -= point
	else if(point in dropoff_points)
		dropoff_points -= point

	qdel(point)
	if(is_operational)
		update_hud()

/obj/machinery/big_manipulator/emag_act(mob/user, obj/item/card/emag/emag_card)
	. = ..()
	if(obj_flags & EMAGGED)
		return FALSE

	balloon_alert(user, "overloaded")
	obj_flags |= EMAGGED

	update_all_points_on_emag_act()
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
	if(isnull(monkey_worker))
		return

	if(current_task != CURRENT_TASK_NONE)
		balloon_alert(user, "turn it off first!")
		return

	var/mob/living/carbon/human/species/monkey/poor_monkey = monkey_worker.resolve()
	if(isnull(poor_monkey))
		return

	balloon_alert(user, "trying to unbuckle...")
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

	if(current_task != CURRENT_TASK_NONE)
		balloon_alert(user, "turn it off first!")
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

	if(id_lock)
		var/obj/item/card/id/resolve_id = id_lock.resolve()
		if(clicked_by_this_id != resolve_id)
			balloon_alert(user, "locked by another id")
			return
		id_lock = null
	else
		id_lock = WEAKREF(clicked_by_this_id)
	balloon_alert(user, "successfully [id_lock ? "" : "un"]locked")

/// Attaching the arm effect to the core.
/obj/machinery/big_manipulator/proc/create_manipulator_arm()
	manipulator_arm = new/obj/effect/big_manipulator_arm(src)
	manipulator_arm.dir = NORTH
	vis_contents += manipulator_arm

/// Destroying the manipulator if the arm is destroyed.
/obj/machinery/big_manipulator/proc/on_hand_qdel()
	SIGNAL_HANDLER

	deconstruct(TRUE)

/obj/machinery/big_manipulator/proc/toggle_power_state(mob/user)
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
		try_kickstart(user)

	else
		drop_held_atom()
		on = new_power_state
		cycle_timer_running = FALSE
		// Set stopping task instead of ending current task immediately
		if(current_task != CURRENT_TASK_NONE || current_task != CURRENT_TASK_STOPPING)
			start_task(CURRENT_TASK_STOPPING, 0)
			// Schedule automatic completion of stopping task
			addtimer(CALLBACK(src, PROC_REF(complete_stopping_task)), 1 SECONDS)
		else
			end_current_task()
		SStgui.update_uis(src)

/obj/machinery/big_manipulator/proc/validate_all_points()
	var/list/pickup_to_remove = list()
	for(var/datum/interaction_point/point in pickup_points)
		if(!point.is_valid())
			pickup_to_remove += point

	for(var/datum/interaction_point/point_to_remove in pickup_to_remove)
		pickup_points.Remove(point_to_remove)

	var/list/dropoff_to_remove = list()
	for(var/datum/interaction_point/point in dropoff_points)
		if(!point.is_valid())
			dropoff_to_remove += point

	for(var/datum/interaction_point/point_to_remove in dropoff_to_remove)
		dropoff_points.Remove(point_to_remove)

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
	finish_manipulation()

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
	data["speed_multiplier"] = speed_multiplier // TODO: ui fix
	data["min_speed_multiplier"] = min_speed_multiplier // TODO: ui fix
	data["max_speed_multiplier"] = max_speed_multiplier // TODO: ui fix
	data["manipulator_position"] = "[x],[y]"
	data["pickup_tasking"] = pickup_tasking
	data["dropoff_tasking"] = dropoff_tasking

	var/list/pickup_points_data = list()
	for(var/datum/interaction_point/point in pickup_points)
		var/list/point_data = list()
		point_data["name"] = point.name
		point_data["id"] = REF(point)
		var/turf/resolved_turf = point.interaction_turf.resolve()
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
		pickup_points_data += list(point_data)
	data["pickup_points"] = pickup_points_data

	var/list/dropoff_points_data = list()
	for(var/datum/interaction_point/point in dropoff_points)
		var/list/point_data = list()
		point_data["name"] = point.name
		point_data["id"] = REF(point)
		var/turf/resolved_turf = point.interaction_turf.resolve()
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
			create_new_interaction_point(null, list(), FALSE, null, TRANSFER_TYPE_PICKUP)
			return TRUE

		if("create_dropoff_point")
			create_new_interaction_point(null, list(), FALSE, INTERACT_DROP, TRANSFER_TYPE_DROPOFF)
			return TRUE

		if("cycle_tasking_schedule")
			var/new_schedule = params["new_schedule"]
			var/is_pickup = params["is_pickup"]
			if(new_schedule in list("Round Robin", "Strict Robin", "Prefer First"))
				if(is_pickup)
					pickup_tasking = new_schedule
				else
					dropoff_tasking = new_schedule
				SStgui.update_uis(src)
			return TRUE

		if("adjust_interaction_speed")
			var/new_speed = text2num(params["new_speed"])
			if(isnull(new_speed))
				return FALSE

			speed_multiplier = clamp(new_speed, min_speed_multiplier, max_speed_multiplier)
			SStgui.update_uis(src)
			return TRUE

		if("adjust_point_param")
			return adjust_param_for_point(params["pointId"], params["param"], params["value"], ui.user)

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

		if("remove_point")
			if(value)
				pickup_points -= target_point
			else
				dropoff_points -= target_point
			qdel(target_point)
			return TRUE

		if("reset_atom_filters")
			target_point.atom_filters = list()
			return TRUE

		if("cycle_dropoff_point_interaction")
			target_point.interaction_mode = cycle_value(target_point.interaction_mode, monkey_worker ? list(INTERACT_DROP, INTERACT_THROW, INTERACT_USE) : list(INTERACT_DROP, INTERACT_THROW))
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

		if("set_throw_range")
			target_point.throw_range = clamp(text2num(value), 1, 7)
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

		if("move_to")
			var/button_number = text2num(value["buttonNumber"])

			var/dx = 0
			var/dy = 0
			switch(button_number)
				if(1)
					dx = -1
					dy = 1
				if(2)
					dx = 0
					dy = 1
				if(3)
					dx = 1
					dy = 1
				if(4)
					dx = -1
					dy = 0
				if(5)
					dx = 0
					dy = 0
				if(6)
					dx = 1
					dy = 0
				if(7)
					dx = -1
					dy = -1
				if(8)
					dx = 0
					dy = -1
				if(9)
					dx = 1
					dy = -1

			var/turf/new_turf = locate(x + dx, y + dy, z)
			if(!new_turf || isclosedturf(new_turf))
				return FALSE

			target_point.interaction_turf = WEAKREF(new_turf)
			update_hud()
			return TRUE

/// Cycles the given value in the given list. Retuns the next value in the list, or the first one if the list isn't long enough.
/obj/machinery/big_manipulator/proc/cycle_value(current_value, list/possible_values)
	var/current_index = possible_values.Find(current_value)
	if(current_index == null)
		return possible_values[1]

	var/next_index = (current_index % possible_values.len) + 1
	return possible_values[next_index]

/// Begins a new task with the specified type and duration
/obj/machinery/big_manipulator/proc/start_task(task_type, duration)
	if(current_task == CURRENT_TASK_STOPPING)
		return

	end_current_task() // End any previous task first (momentarily sets IDLE)
	current_task_start_time = world.time
	current_task_duration = duration / 10 // Duration is in deciseconds for TGUI
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
	if(current_task == CURRENT_TASK_STOPPING)
		on = FALSE
		cycle_timer_running = FALSE
		end_current_task()
		SStgui.update_uis(src)

/obj/machinery/big_manipulator/proc/remove_all_huds()
	for(var/image/hud_image in hud_points)
		qdel(hud_image)
	hud_points.Cut()
