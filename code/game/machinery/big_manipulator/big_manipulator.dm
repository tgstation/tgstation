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
	var/min_speed_multiplier = MIN_SPEED_MULTIPLIER_TIER_1
	var/max_speed_multiplier = MAX_SPEED_MULTIPLIER_TIER_1

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

	/// How many tasks total we can have.
	var/interaction_point_limit = MAX_TASKS_TIER_1

	/// A list of tasks for the manipulator.
	var/list/tasks = list()
	/// The task we're currently working on.
	var/datum/manipulator_task/current_task

	/// State of the machine (moving, interacting, idle...)
	var/current_task_state = CURRENT_TASK_NONE
	var/current_task_start_time = 0
	var/current_task_duration = 0

	/// Which tasking scenario we use for iterating tasks.
	var/tasking_strategy = TASKING_SEQUENTIAL
	/// Tasking strategy instance.
	var/datum/tasking_strategy/master_tasking

	/// List of all HUD icons resembling interaction points.
	var/list/hud_points = list()

/// Re-creates hud images for the tasks.
/obj/machinery/big_manipulator/proc/update_hud()
	LAZYCLEARLIST(hud_points)

	// var/image/main_hud = hud_list[BIG_MANIP_HUD]
	// if(!main_hud)
	// 	return

	// main_hud.loc = get_turf(src)
	// main_hud.appearance = mutable_appearance('icons/effects/tasks.dmi', null, ABOVE_ALL_MOB_LAYER, src, GAME_PLANE)

	// main_hud.overlays.Cut()
	// var/list/point_overlays = list()

	// for(var/i in 1 to length(tasks))
	// 	var/datum/manipulator_task/task = tasks[i]
	// 	if(!istype(task, /datum/manipulator_task/cargo))
	// 		continue
	// 	var/datum/manipulator_task/cargo/cargo_task = task
	// 	var/turf/target_turf = cargo_task.interaction_turf
	// 	if(!target_turf)
	// 		continue
	// 	var/mutable_appearance/point_appearance = mutable_appearance('icons/effects/tasks.dmi', "[cargo_task.type]_[i]", ABOVE_ALL_MOB_LAYER, src, GAME_PLANE)
	// 	var/turf/manip_turf = get_turf(src)
	// 	point_appearance.pixel_x = (target_turf.x - manip_turf.x) * 32
	// 	point_appearance.pixel_y = (target_turf.y - manip_turf.y) * 32
	// 	point_overlays += point_appearance

	// main_hud.overlays += point_overlays
	// hud_points += main_hud
	// set_hud_image_active(BIG_MANIP_HUD)

	return

/// Attempts to find a suitable turf near the manipulator for creating a cargo task.
/obj/machinery/big_manipulator/proc/find_suitable_turf()
	for(var/turf/checked_turf in orange(get_turf(src), 1))
		if(!isclosedturf(checked_turf))
			return checked_turf
	return null

/// Attempts to create a new task and assign it to the list.
/obj/machinery/big_manipulator/proc/create_new_task(mob/user, task_type, turf/new_turf)
	if(length(tasks) >= interaction_point_limit)
		balloon_alert(user, "task limit reached!")
		return FALSE

	var/datum/stock_part/servo/locate_servo = locate() in component_parts
	var/manipulator_tier = locate_servo ? locate_servo.tier : 1

	var/datum/manipulator_task/new_task
	var/needs_turf = task_type in list(TASK_TYPE_PICKUP, TASK_TYPE_DROP, TASK_TYPE_THROW, TASK_TYPE_USE, TASK_TYPE_INTERACT)

	if(needs_turf)
		if(!new_turf) new_turf = find_suitable_turf()
		if(!new_turf)
			balloon_alert(user, "no suitable turfs found!")
			return FALSE

	switch(task_type)
		if(TASK_TYPE_PICKUP)
			new_task = new /datum/manipulator_task/cargo/pickup(new_turf, manipulator_tier)
		if(TASK_TYPE_DROP)
			new_task = new /datum/manipulator_task/cargo/dropoff_base/drop(new_turf, manipulator_tier)
		if(TASK_TYPE_THROW)
			new_task = new /datum/manipulator_task/cargo/dropoff_base/throw(new_turf, manipulator_tier)
		if(TASK_TYPE_USE)
			new_task = new /datum/manipulator_task/cargo/dropoff_base/use(new_turf, manipulator_tier)
		if(TASK_TYPE_INTERACT)
			new_task = new /datum/manipulator_task/cargo/interact(new_turf, manipulator_tier)
		if(TASK_TYPE_WAIT)
			new_task = new /datum/manipulator_task/simple/wait()
		if(TASK_TYPE_SIGNAL)
			new_task = new /datum/manipulator_task/simple/signal()

	if(!new_task || QDELETED(new_task))
		return FALSE

	tasks += new_task

	if(obj_flags & EMAGGED && istype(new_task, /datum/manipulator_task/cargo))
		var/datum/manipulator_task/cargo/cargo_task = new_task
		cargo_task.type_filters += /mob/living

	if(is_operational)
		update_hud()

	return new_task

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
			interaction_point_limit = MAX_TASKS_TIER_1
			set_greyscale(COLOR_YELLOW)
			manipulator_arm?.set_greyscale(COLOR_YELLOW)
		if(2)
			min_speed_multiplier = MIN_SPEED_MULTIPLIER_TIER_2
			max_speed_multiplier = MAX_SPEED_MULTIPLIER_TIER_2
			interaction_point_limit = MAX_TASKS_TIER_2
			set_greyscale(COLOR_ORANGE)
			manipulator_arm?.set_greyscale(COLOR_ORANGE)
		if(3)
			min_speed_multiplier = MIN_SPEED_MULTIPLIER_TIER_3
			max_speed_multiplier = MAX_SPEED_MULTIPLIER_TIER_3
			interaction_point_limit = MAX_TASKS_TIER_3
			set_greyscale(COLOR_RED)
			manipulator_arm?.set_greyscale(COLOR_RED)
		if(4 to INFINITY)
			min_speed_multiplier = MIN_SPEED_MULTIPLIER_TIER_4
			max_speed_multiplier = MAX_SPEED_MULTIPLIER_TIER_4
			interaction_point_limit = MAX_TASKS_TIER_4
			set_greyscale(COLOR_PURPLE)
			manipulator_arm?.set_greyscale(COLOR_PURPLE)

	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * BASE_POWER_USAGE * manipulator_tier

	for(var/datum/manipulator_task/cargo/cargo_task in tasks)
		cargo_task.interaction_priorities = cargo_task.fill_priority_list(manipulator_tier)

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
	QDEL_LIST(tasks)
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

	if(dx == 0 && dy == 0)
		return

	for(var/datum/manipulator_task/cargo/cargo_task in tasks)
		update_task_position(cargo_task, dx, dy)

	if(is_operational)
		update_hud()

/// Updates a single cargo task's turf position by the given offset.
/obj/machinery/big_manipulator/proc/update_task_position(datum/manipulator_task/cargo/task, dx, dy)
	if(!task || !task.interaction_turf)
		return

	var/turf/old_turf = task.interaction_turf
	var/turf/manipulator_turf = get_turf(src)
	if(!manipulator_turf)
		return

	var/turf/new_turf = locate(old_turf.x + dx, old_turf.y + dy, manipulator_turf.z)

	if(!anchored)
		if(new_turf)
			task.interaction_turf = new_turf
		return

	if(!new_turf || isclosedturf(new_turf))
		new_turf = find_suitable_turf_near(new_turf || old_turf)
		if(!new_turf)
			remove_invalid_task(task)
			return

	if(new_turf == old_turf)
		return

	task.interaction_turf = new_turf

/// Finds a suitable turf near the given location.
/obj/machinery/big_manipulator/proc/find_suitable_turf_near(turf/center)
	if(!center)
		return null
	for(var/turf/each in orange(1, src))
		if(!isclosedturf(each))
			return each
	return null

/// Removes an invalid task from the list.
/obj/machinery/big_manipulator/proc/remove_invalid_task(datum/manipulator_task/task)
	if(!task)
		return
	tasks.Remove(task)
	qdel(task)
	if(is_operational)
		update_hud()

/obj/machinery/big_manipulator/emag_act(mob/user, obj/item/card/emag/emag_card)
	. = ..()
	if(obj_flags & EMAGGED)
		return FALSE

	balloon_alert(user, "overloaded")
	obj_flags |= EMAGGED

	for(var/datum/manipulator_task/cargo/cargo_task in tasks)
		cargo_task.type_filters += /mob/living

	return TRUE

/obj/machinery/big_manipulator/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	default_unfasten_wrench(user, tool, time = 1 SECONDS)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/big_manipulator/can_be_unfasten_wrench(mob/user, silent)
	if(current_task_state != CURRENT_TASK_NONE || on)
		to_chat(user, span_warning("[src] is activated!"))
		return FAILED_UNFASTEN
	return ..()

/obj/machinery/big_manipulator/default_unfasten_wrench(mob/user, obj/item/wrench, time)
	. = ..()
	if(. == SUCCESSFUL_UNFASTEN)
		if(anchored)
			validate_all_tasks()
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
	if(current_task_state != CURRENT_TASK_NONE)
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
	if(current_task_state != CURRENT_TASK_NONE)
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

		validate_all_tasks()

		on = newly_on
		SStgui.update_uis(src)
		try_kickstart(user)

	else
		drop_held_atom()
		on = newly_on
		next_cycle_scheduled = FALSE
		if(current_task_state != CURRENT_TASK_NONE && current_task_state != CURRENT_TASK_STOPPING)
			start_task_state(CURRENT_TASK_STOPPING, 0)
			addtimer(CALLBACK(src, PROC_REF(complete_stopping_task)), 1 SECONDS)
		else
			end_current_task()
		SStgui.update_uis(src)

/// Validates all cargo tasks, removing those on closed turfs.
/obj/machinery/big_manipulator/proc/validate_all_tasks()
	for(var/datum/manipulator_task/cargo/cargo_task in tasks)
		if(!cargo_task.is_valid())
			tasks.Remove(cargo_task)
			qdel(cargo_task)

	if(is_operational)
		update_hud()

/// Attempts to press the power button.
/obj/machinery/big_manipulator/proc/try_press_on(mob/living/carbon/human/user)
	if(power_access_wire_cut)
		balloon_alert(user, "unresponsive!")
		return

	if(current_task_state == CURRENT_TASK_STOPPING)
		balloon_alert(user, "stopping in progress!")
		return

	toggle_power_state(user)
	if(on)
		balloon_alert(user, "activated")
	else
		balloon_alert(user, "deactivated")

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
	data["current_task_state"] = current_task_state
	data["current_task_id"] = current_task ? REF(current_task) : null
	data["current_task_duration"] = current_task_duration
	data["speed_multiplier"] = speed_multiplier
	data["min_speed_multiplier"] = min_speed_multiplier
	data["max_speed_multiplier"] = max_speed_multiplier
	data["manipulator_position"] = "[x],[y]"
	data["tasking_strategy"] = tasking_strategy
	data["has_monkey"] = !isnull(monkey_worker?.resolve())

	var/list/tasks_data = list()
	for(var/datum/manipulator_task/task in tasks)
		var/list/td = list()
		td["name"] = task.name
		td["id"] = REF(task)

		if(istype(task, /datum/manipulator_task/cargo/pickup))
			td["task_type"] = TASK_TYPE_PICKUP
			var/datum/manipulator_task/cargo/pickup/t = task
			var/turf/turf = t.interaction_turf
			td["turf"] = turf ? "[turf.x],[turf.y]" : "0,0"
			td["filters_status"] = t.should_use_filters
			td["filtering_mode"] = t.filtering_mode
			td["item_filters"] = _collect_filter_names(t.atom_filters)
			td["settings_list"] = _collect_priorities(t.interaction_priorities)
			td["pickup_eagerness"] = t.pickup_eagerness

		else if(istype(task, /datum/manipulator_task/cargo/dropoff_base/drop))
			td["task_type"] = TASK_TYPE_DROP
			var/datum/manipulator_task/cargo/dropoff_base/drop/t = task
			var/turf/turf = t.interaction_turf
			td["turf"] = turf ? "[turf.x],[turf.y]" : "0,0"
			td["filters_status"] = t.should_use_filters
			td["filtering_mode"] = t.filtering_mode
			td["item_filters"] = _collect_filter_names(t.atom_filters)
			td["settings_list"] = _collect_priorities(t.interaction_priorities)
			td["overflow_status"] = t.overflow_status

		else if(istype(task, /datum/manipulator_task/cargo/dropoff_base/throw))
			td["task_type"] = TASK_TYPE_THROW
			var/datum/manipulator_task/cargo/dropoff_base/throw/t = task
			var/turf/turf = t.interaction_turf
			td["turf"] = turf ? "[turf.x],[turf.y]" : "0,0"
			td["filters_status"] = t.should_use_filters
			td["filtering_mode"] = t.filtering_mode
			td["item_filters"] = _collect_filter_names(t.atom_filters)
			td["settings_list"] = _collect_priorities(t.interaction_priorities)
			td["throw_range"] = t.throw_range

		else if(istype(task, /datum/manipulator_task/cargo/dropoff_base/use))
			td["task_type"] = TASK_TYPE_USE
			var/datum/manipulator_task/cargo/dropoff_base/use/t = task
			var/turf/turf = t.interaction_turf
			td["turf"] = turf ? "[turf.x],[turf.y]" : "0,0"
			td["filters_status"] = t.should_use_filters
			td["filtering_mode"] = t.filtering_mode
			td["item_filters"] = _collect_filter_names(t.atom_filters)
			td["settings_list"] = _collect_priorities(t.interaction_priorities)
			td["worker_interaction"] = t.worker_interaction
			td["use_post_interaction"] = t.use_post_interaction
			td["worker_use_rmb"] = t.worker_use_rmb
			td["worker_combat_mode"] = t.worker_combat_mode

		else if(istype(task, /datum/manipulator_task/cargo/interact))
			td["task_type"] = TASK_TYPE_INTERACT
			var/datum/manipulator_task/cargo/interact/t = task
			var/turf/turf = t.interaction_turf
			td["turf"] = turf ? "[turf.x],[turf.y]" : "0,0"
			td["filters_status"] = t.should_use_filters
			td["filtering_mode"] = t.filtering_mode
			td["item_filters"] = _collect_filter_names(t.atom_filters)
			td["settings_list"] = _collect_priorities(t.interaction_priorities)
			td["worker_interaction"] = t.worker_interaction
			td["use_post_interaction"] = t.use_post_interaction
			td["worker_use_rmb"] = t.worker_use_rmb
			td["worker_combat_mode"] = t.worker_combat_mode

		else if(istype(task, /datum/manipulator_task/simple/wait))
			td["task_type"] = TASK_TYPE_WAIT
			var/datum/manipulator_task/simple/wait/t = task
			td["time"] = t.time_seconds

		else if(istype(task, /datum/manipulator_task/simple/signal))
			td["task_type"] = TASK_TYPE_SIGNAL

		tasks_data += list(td)

	data["tasks_data"] = tasks_data
	return data

/obj/machinery/big_manipulator/proc/_collect_filter_names(list/filters)
	var/list/names = list()
	for(var/atom/f as anything in filters)
		names += initial(f.name)
	return names

/obj/machinery/big_manipulator/proc/_collect_priorities(list/priorities)
	var/list/out = list()
	for(var/datum/manipulator_priority/pr in priorities)
		var/list/entry = list()
		entry["name"] = pr.name
		entry["active"] = pr.active
		out += list(entry)
	return out

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

		if("create_task")
			create_new_task(ui.user, params["task_type"])
			return TRUE

		if("reset_tasking_index")
			master_tasking.current_index = 1
			balloon_alert(ui.user, "tasking index reset")
			return TRUE

		if("cycle_tasking_strategy")
			var/new_strategy = params["new_strategy"]
			if(new_strategy in list(TASKING_SEQUENTIAL, TASKING_STRICT))
				tasking_strategy = new_strategy
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

		if("adjust_task_param")
			return adjust_param_for_task(params["taskId"], params["param"], params["value"], ui.user)

/obj/machinery/big_manipulator/proc/adjust_param_for_task(task_ref, param, value, mob/user)
	if(!param)
		return FALSE

	var/datum/manipulator_task/target_task = locate(task_ref) in tasks
	if(!target_task)
		return FALSE

	switch(param)
		if("set_name")
			target_task.name = sanitize_name(value, allow_numbers = TRUE)
			return TRUE

		if("remove_task")
			tasks.Remove(target_task)
			qdel(target_task)
			update_hud()
			return TRUE

		if("move_up")
			var/idx = tasks.Find(target_task)
			if(idx <= 1) return FALSE
			tasks.Swap(idx, idx - 1)
			return TRUE

		if("move_down")
			var/idx = tasks.Find(target_task)
			if(idx >= length(tasks)) return FALSE
			tasks.Swap(idx, idx + 1)
			return TRUE

		if("move_to")
			if(!istype(target_task, /datum/manipulator_task/cargo))
				return FALSE
			var/datum/manipulator_task/cargo/cargo_task = target_task
			var/button_number = text2num(value["buttonNumber"])
			var/dx = ((button_number - 1) % 3) - 1
			var/dy = 1 - round((button_number - 1) / 3)
			var/turf/new_turf = locate(x + dx, y + dy, z)
			if(!new_turf || isclosedturf(new_turf))
				return FALSE
			cargo_task.interaction_turf = new_turf
			update_hud()
			return TRUE

		if("toggle_filter_skip")
			if(!istype(target_task, /datum/manipulator_task/cargo))
				return FALSE
			var/datum/manipulator_task/cargo/ct = target_task
			ct.should_use_filters = !ct.should_use_filters
			return TRUE

		if("reset_atom_filters")
			if(!istype(target_task, /datum/manipulator_task/cargo))
				return FALSE
			var/datum/manipulator_task/cargo/ct = target_task
			ct.atom_filters = list()
			return TRUE

		if("add_atom_filter_from_held")
			if(!istype(target_task, /datum/manipulator_task/cargo))
				return FALSE
			var/datum/manipulator_task/cargo/ct = target_task
			var/obj/item/held_item = user.get_active_held_item()
			if(!held_item)
				return FALSE
			for(var/filter_path in ct.atom_filters)
				if(istype(held_item, filter_path))
					return FALSE
			ct.atom_filters += held_item.type
			return TRUE

		if("delete_filter")
			if(!istype(target_task, /datum/manipulator_task/cargo))
				return FALSE
			var/datum/manipulator_task/cargo/ct = target_task
			ct.atom_filters.Cut(value, value + 1)
			return TRUE

		if("cycle_filtering_mode")
			if(!istype(target_task, /datum/manipulator_task/cargo))
				return FALSE
			var/datum/manipulator_task/cargo/ct = target_task
			ct.filtering_mode = cycle_value(ct.filtering_mode, obj_flags & EMAGGED ? list(TAKE_ITEMS, TAKE_CLOSETS, TAKE_HUMANS) : list(TAKE_ITEMS, TAKE_CLOSETS))
			return TRUE

		if("toggle_priority")
			if(!istype(target_task, /datum/manipulator_task/cargo))
				return FALSE
			var/datum/manipulator_task/cargo/current_task = target_task
			return current_task.tick_priority_by_index(value)

		if("priority_move_up")
			if(!istype(target_task, /datum/manipulator_task/cargo))
				return FALSE
			var/datum/manipulator_task/cargo/current_task = target_task
			return current_task.tick_priority_by_index(value)

		if("cycle_pickup_eagerness")
			if(!istype(target_task, /datum/manipulator_task/cargo/pickup))
				return FALSE
			var/datum/manipulator_task/cargo/pickup/t = target_task
			t.pickup_eagerness = cycle_value(t.pickup_eagerness, list(PICKUP_CAN_WAIT, PICKUP_EAGER))
			return TRUE

		if("cycle_overflow_status")
			if(!istype(target_task, /datum/manipulator_task/cargo/dropoff_base/drop))
				return FALSE
			var/datum/manipulator_task/cargo/dropoff_base/drop/t = target_task
			t.overflow_status = cycle_value(t.overflow_status, list(POINT_OVERFLOW_ALLOWED, POINT_OVERFLOW_FILTERS, POINT_OVERFLOW_HELD, POINT_OVERFLOW_FORBIDDEN))
			return TRUE

		if("cycle_throw_range")
			if(!istype(target_task, /datum/manipulator_task/cargo/dropoff_base/throw))
				return FALSE
			var/datum/manipulator_task/cargo/dropoff_base/throw/t = target_task
			t.throw_range = cycle_value(t.throw_range, list(1, 2, 3, 4, 5, 6, 7))
			return TRUE

		if("cycle_worker_interaction")
			var/list/vals = list(WORKER_NORMAL_USE, WORKER_SINGLE_USE, WORKER_EMPTY_USE)
			if(istype(target_task, /datum/manipulator_task/cargo/dropoff_base/use))
				var/datum/manipulator_task/cargo/dropoff_base/use/t = target_task
				t.worker_interaction = cycle_value(t.worker_interaction, vals)
				return TRUE
			if(istype(target_task, /datum/manipulator_task/cargo/interact))
				var/datum/manipulator_task/cargo/interact/t = target_task
				t.worker_interaction = cycle_value(t.worker_interaction, vals)
				return TRUE
			return FALSE

		if("cycle_post_interaction")
			var/list/vals = list(POST_INTERACTION_DROP_AT_POINT, POST_INTERACTION_DROP_AT_MACHINE, POST_INTERACTION_DROP_NEXT_FITTING, POST_INTERACTION_WAIT)
			if(istype(target_task, /datum/manipulator_task/cargo/dropoff_base/use))
				var/datum/manipulator_task/cargo/dropoff_base/use/t = target_task
				t.use_post_interaction = cycle_value(t.use_post_interaction, vals)
				return TRUE
			if(istype(target_task, /datum/manipulator_task/cargo/interact))
				var/datum/manipulator_task/cargo/interact/t = target_task
				t.use_post_interaction = cycle_value(t.use_post_interaction, vals)
				return TRUE
			return FALSE

		if("toggle_worker_rmb")
			if(istype(target_task, /datum/manipulator_task/cargo/dropoff_base/use))
				var/datum/manipulator_task/cargo/dropoff_base/use/t = target_task
				t.worker_use_rmb = !t.worker_use_rmb
				return TRUE
			if(istype(target_task, /datum/manipulator_task/cargo/interact))
				var/datum/manipulator_task/cargo/interact/t = target_task
				t.worker_use_rmb = !t.worker_use_rmb
				return TRUE
			return FALSE

		if("toggle_worker_combat")
			if(istype(target_task, /datum/manipulator_task/cargo/dropoff_base/use))
				var/datum/manipulator_task/cargo/dropoff_base/use/t = target_task
				t.worker_combat_mode = !t.worker_combat_mode
				return TRUE
			if(istype(target_task, /datum/manipulator_task/cargo/interact))
				var/datum/manipulator_task/cargo/interact/t = target_task
				t.worker_combat_mode = !t.worker_combat_mode
				return TRUE
			return FALSE

/// Cycles the given value in the given list.
/obj/machinery/big_manipulator/proc/cycle_value(current_value, list/possible_values)
	var/current_index = possible_values.Find(current_value)
	if(current_index == 0)
		return possible_values[1]
	return possible_values[(current_index % length(possible_values)) + 1]

/obj/machinery/big_manipulator/proc/remove_all_huds()
	var/image/main_hud = hud_list[BIG_MANIP_HUD]
	if(main_hud)
		main_hud.overlays.Cut()
		main_hud.loc = null

	hud_points.Cut()
	set_hud_image_inactive(BIG_MANIP_HUD)

/obj/machinery/big_manipulator/proc/update_strategies()
	master_tasking = create_strategy(tasking_strategy)

/obj/machinery/big_manipulator/proc/create_strategy(strategy_mode)
	switch(strategy_mode)
		if(TASKING_SEQUENTIAL)
			return new /datum/tasking_strategy/sequential()
		if(TASKING_STRICT)
			return new /datum/tasking_strategy/strict()
	return new /datum/tasking_strategy/sequential()
