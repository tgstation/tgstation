#define DROP_ITEM_MODE 1
#define THROW_ITEM_MODE 2

#define TAKE_ITEMS 1
#define TAKE_CLOSETS 2
#define TAKE_HUMANS 3

/// Manipulator Core. Main part of the mechanism that carries out the entire process.
/obj/machinery/big_manipulator
	name = "Big Manipulator"
	desc = "Take and drop objects. Innovation..."
	icon = 'icons/obj/machines/big_manipulator_parts/big_manipulator_core.dmi'
	icon_state = "core"
	density = TRUE
	circuit = /obj/item/circuitboard/machine/big_manipulator
	greyscale_colors = "#d8ce13"
	greyscale_config = /datum/greyscale_config/big_manipulator
	/// How many time manipulator need to take and drop item.
	var/working_speed = 2 SECONDS
	/// Using high tier manipulators speeds up big manipulator and requires more energy.
	var/power_use_lvl = 0.2
	/// When manipulator already working with item inside he don't take any new items.
	var/on_work = FALSE
	/// Activate mechanism.
	var/on = FALSE
	/// Dir to get turf where we take items.
	var/take_here = NORTH
	/// Dir to get turf where we drop items.
	var/drop_here = SOUTH
	/// Turf where we take items.
	var/turf/take_turf
	/// Turf where we drop items.
	var/turf/drop_turf
	/// How will manipulator manipulate the object? drop it out by default.
	var/manipulate_mode = DROP_ITEM_MODE
	/// Priority settings depending on the manipulator mode that are available to this manipulator. Filled during Initialize.
	var/list/priority_settings_for_drop = list()
	/// What priority settings are available to use at the moment.
	/// We also use this list to sort priorities from ascending to descending.
	var/list/allowed_priority_settings = list()
	/// Obj inside manipulator.
	var/datum/weakref/containment_obj
	/// Obj used as filter
	var/datum/weakref/filter_obj
	/// Other manipulator component.
	var/obj/effect/big_manipulator_hand/manipulator_hand
	/// Here some ui setting we can on/off:
	/// If activated: after item was used manipulator will also drop it.
	var/drop_item_after_use = TRUE
	/// If acrivated: will select only 1 priority and will not continue to look at the priorities below.
	var/only_highest_priority = FALSE
	/// Var for throw item mode: changes the range from which the manipulator throws an object.
	var/manipulator_throw_range = 1
	/// Selected type that manipulator will take for take and drop loop.
	var/atom/selected_type
	/// Just a lazy number to change selected_type type in array.
	var/selected_type_by_number = 1
	/// List where we can set selected type. Taking items by Initialize.
	var/list/allowed_types_to_pick_up = list(
		/obj/item,
		/obj/structure/closet,
	)

/obj/machinery/big_manipulator/Initialize(mapload)
	. = ..()
	take_and_drop_turfs_check()
	create_manipulator_hand()
	RegisterSignal(manipulator_hand, COMSIG_QDELETING, PROC_REF(on_hand_qdel))
	manipulator_lvl()
	set_up_priority_settings()
	selected_type = allowed_types_to_pick_up[selected_type_by_number]
	if(on)
		press_on(pressed_by = null)

/// Init priority settings list for all modes.
/obj/machinery/big_manipulator/proc/set_up_priority_settings()
	for(var/datum/manipulator_priority/priority_for_drop as anything in subtypesof(/datum/manipulator_priority/for_drop))
		priority_settings_for_drop += new priority_for_drop
	update_priority_list()

/obj/machinery/big_manipulator/examine(mob/user)
	. = ..()
	. += "You can change direction with alternative wrench usage."

/obj/machinery/big_manipulator/Destroy(force)
	. = ..()
	qdel(manipulator_hand)
	if(!isnull(containment_obj))
		var/obj/containment_resolve = containment_obj?.resolve()
		containment_resolve?.forceMove(get_turf(containment_resolve))
	if(!isnull(filter_obj))
		var/obj/filter_resolve = filter_obj?.resolve()
		filter_resolve?.forceMove(get_turf(filter_resolve))

/obj/machinery/big_manipulator/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	. = ..()
	take_and_drop_turfs_check()
	if(isnull(get_turf(src)))
		qdel(manipulator_hand)
		return
	if(!manipulator_hand)
		create_manipulator_hand()

/obj/machinery/big_manipulator/emag_act(mob/user, obj/item/card/emag/emag_card)
	. = ..()
	if(obj_flags & EMAGGED)
		return FALSE
	balloon_alert(user, "overloaded functions installed")
	obj_flags |= EMAGGED
	allowed_types_to_pick_up += /mob/living
	return TRUE

/obj/machinery/big_manipulator/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	default_unfasten_wrench(user, tool, time = 1 SECONDS)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/big_manipulator/wrench_act_secondary(mob/living/user, obj/item/tool)
	. = ..()
	if(on_work || on)
		to_chat(user, span_warning("[src] is activated!"))
		return ITEM_INTERACT_BLOCKING
	rotate_big_hand()
	playsound(src, 'sound/items/deconstruct.ogg', 50, TRUE)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/big_manipulator/can_be_unfasten_wrench(mob/user, silent)
	if(on_work || on)
		to_chat(user, span_warning("[src] is activated!"))
		return FAILED_UNFASTEN
	return ..()

/obj/machinery/big_manipulator/default_unfasten_wrench(mob/user, obj/item/wrench, time)
	. = ..()
	if(. == SUCCESSFUL_UNFASTEN)
		take_and_drop_turfs_check()

/obj/machinery/big_manipulator/screwdriver_act(mob/living/user, obj/item/tool)
	if(default_deconstruction_screwdriver(user, icon_state, icon_state, tool))
		return ITEM_INTERACT_SUCCESS
	return ITEM_INTERACT_BLOCKING

/obj/machinery/big_manipulator/crowbar_act(mob/living/user, obj/item/tool)
	. = ..()
	if(default_deconstruction_crowbar(tool))
		return ITEM_INTERACT_SUCCESS
	return ITEM_INTERACT_BLOCKING

/obj/machinery/big_manipulator/RefreshParts()
	. = ..()

	manipulator_lvl()

/// Creat manipulator hand effect on manipulator core.
/obj/machinery/big_manipulator/proc/create_manipulator_hand()
	manipulator_hand = new/obj/effect/big_manipulator_hand(src)
	manipulator_hand.dir = take_here
	vis_contents += manipulator_hand

/// Check servo tier and change manipulator speed, power_use and colour.
/obj/machinery/big_manipulator/proc/manipulator_lvl()
	var/datum/stock_part/servo/locate_servo = locate() in component_parts
	if(!locate_servo)
		return
	switch(locate_servo.tier)
		if(-INFINITY to 1)
			working_speed = 2 SECONDS
			power_use_lvl = 0.2
			set_greyscale(COLOR_YELLOW)
			manipulator_hand?.set_greyscale(COLOR_YELLOW)
		if(2)
			working_speed = 1.4 SECONDS
			power_use_lvl = 0.4
			set_greyscale(COLOR_ORANGE)
			manipulator_hand?.set_greyscale(COLOR_ORANGE)
		if(3)
			working_speed = 0.8 SECONDS
			power_use_lvl = 0.6
			set_greyscale(COLOR_RED)
			manipulator_hand?.set_greyscale(COLOR_RED)
		if(4 to INFINITY)
			working_speed = 0.2 SECONDS
			power_use_lvl = 0.8
			set_greyscale(COLOR_PURPLE)
			manipulator_hand?.set_greyscale(COLOR_PURPLE)

	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * power_use_lvl

/// Changing take and drop turf tiles when we anchore manipulator or if manipulator not in turf.
/obj/machinery/big_manipulator/proc/take_and_drop_turfs_check()
	if(anchored && isturf(src.loc))
		take_turf = get_step(src, take_here)
		drop_turf = get_step(src, drop_here)
	else
		take_turf = null
		drop_turf = null

/// Changing take and drop turf dirs and also changing manipulator hand sprite dir.
/obj/machinery/big_manipulator/proc/rotate_big_hand()
	switch(take_here)
		if(NORTH)
			take_here = EAST
			drop_here = WEST
		if(EAST)
			take_here = SOUTH
			drop_here = NORTH
		if(SOUTH)
			take_here = WEST
			drop_here = EAST
		if(WEST)
			take_here = NORTH
			drop_here = SOUTH
	manipulator_hand.dir = take_here
	take_and_drop_turfs_check()

/// Deliting hand will destroy our manipulator core.
/obj/machinery/big_manipulator/proc/on_hand_qdel()
	SIGNAL_HANDLER

	deconstruct(TRUE)

/// Pre take and drop proc from [take and drop procs loop]:
/// Check if we can start take and drop loop
/obj/machinery/big_manipulator/proc/is_work_check()
	if(isclosedturf(drop_turf))
		on = !on
		say("Output blocked")
		return FALSE
	for(var/take_item in take_turf.contents)
		if(!check_filter(take_item))
			continue
		try_take_thing(take_turf, take_item)
		break

	return TRUE

/// First take and drop proc from [take and drop procs loop]:
/// Check if we can take item from take_turf to work with him. This proc also calling from ATOM_ENTERED signal.
/obj/machinery/big_manipulator/proc/try_take_thing(datum/source, atom/movable/target)
	SIGNAL_HANDLER

	if(!on)
		return
	if(!anchored)
		return
	if(QDELETED(source) || QDELETED(target))
		return
	if(!isturf(target.loc))
		return
	if(on_work)
		return
	if(!use_energy(active_power_usage, force = FALSE))
		on = FALSE
		say("Not enough energy!")
		return
	if(!check_filter(target))
		return
	start_work(target)

/// Second take and drop proc from [take and drop procs loop]:
/// Taking our item and start manipulator hand rotate animation.
/obj/machinery/big_manipulator/proc/start_work(atom/movable/target)
	target.forceMove(src)
	containment_obj = WEAKREF(target)
	manipulator_hand.update_claw(containment_obj)
	on_work = TRUE
	do_rotate_animation(1)
	check_next_move(target)

/// 2.5 take and drop proc from [take and drop procs loop]:
/// Choose what we will do with our item by checking the manipulate_mode.
/obj/machinery/big_manipulator/proc/check_next_move(atom/movable/target)
	switch(manipulate_mode)
		if(DROP_ITEM_MODE)
			addtimer(CALLBACK(src, PROC_REF(drop_thing), target), working_speed)
		if(THROW_ITEM_MODE)
			addtimer(CALLBACK(src, PROC_REF(throw_thing), target), working_speed)

/// 3.1 take and drop proc from [take and drop procs loop]:
/// Drop our item.
/// Checks the priority to drop item not only ground but also in the storage.
/obj/machinery/big_manipulator/proc/drop_thing(atom/movable/target)
	var/where_we_drop = search_type_by_priority_in_drop_turf(allowed_priority_settings)
	if(isnull(where_we_drop))
		addtimer(CALLBACK(src, PROC_REF(drop_thing), target), working_speed)
		return
	if((where_we_drop == drop_turf) || !isitem(target))
		target.forceMove(drop_turf)
		target.dir = get_dir(get_turf(target), get_turf(src))
	else
		var/atom/drop_target = where_we_drop
		if(drop_target.atom_storage)
			if(!drop_target.atom_storage.attempt_insert(target, override = TRUE, messages = FALSE))
				target.forceMove(drop_target.drop_location())
		else
			target.forceMove(where_we_drop)
	finish_manipulation()

/// 3.3 take and drop proc from [take and drop procs loop]:
/// Throw item away!!!
/obj/machinery/big_manipulator/proc/throw_thing(atom/movable/target)
	if(!(isitem(target) || isliving(target)))
		target.forceMove(drop_turf)
		target.dir = get_dir(get_turf(target), get_turf(src))
		finish_manipulation()  /// We throw only items and living mobs
		return
	var/obj/item/im_item = target
	im_item.forceMove(drop_turf)
	im_item.throw_at(get_edge_target_turf(get_turf(src), drop_here), manipulator_throw_range - 1, 2)
	src.do_attack_animation(drop_turf)
	manipulator_hand.do_attack_animation(drop_turf)
	finish_manipulation()

/// End of thirds take and drop proc from [take and drop procs loop]:
/// Starts manipulator hand backward animation.
/obj/machinery/big_manipulator/proc/finish_manipulation()
	containment_obj = null
	manipulator_hand.update_claw(null)
	do_rotate_animation(0)
	addtimer(CALLBACK(src, PROC_REF(end_work)), working_speed)

/// Fourth and last take and drop proc from [take and drop procs loop]:
/// Finishes work and begins to look for a new item for [take and drop procs loop].
/obj/machinery/big_manipulator/proc/end_work()
	on_work = FALSE
	is_work_check()

/// Rotates manipulator hand 90 degrees.
/obj/machinery/big_manipulator/proc/do_rotate_animation(backward)
	animate(manipulator_hand, transform = matrix(90, MATRIX_ROTATE), working_speed*0.5)
	addtimer(CALLBACK(src, PROC_REF(finish_rotate_animation), backward), working_speed*0.5)

/// Rotates manipulator hand from 90 degrees to 180 or 0 if backward.
/obj/machinery/big_manipulator/proc/finish_rotate_animation(backward)
	animate(manipulator_hand, transform = matrix(180 * backward, MATRIX_ROTATE), working_speed*0.5)

/obj/machinery/big_manipulator/proc/check_filter(atom/movable/target)
	if (target.anchored || HAS_TRAIT(target, TRAIT_NODROP))
		return FALSE
	if(!istype(target, selected_type))
		return FALSE
	/// We use filter only on items. closets, humans and etc don't need filter check.
	if(!isitem(target))
		return TRUE
	var/obj/item/target_item = target
	if (target_item.item_flags & (ABSTRACT|DROPDEL))
		return FALSE
	var/filtered_obj = filter_obj?.resolve()
	if((filtered_obj && !istype(target_item, filtered_obj)))
		return FALSE
	return TRUE

/// Proc called when we changing item interaction mode.
/obj/machinery/big_manipulator/proc/change_mode()
	manipulate_mode++
	if(manipulate_mode > THROW_ITEM_MODE)
		manipulate_mode = DROP_ITEM_MODE
	update_priority_list()
	is_work_check()

/// Update priority list in ui. Creating new list and sort it by priority number.
/obj/machinery/big_manipulator/proc/update_priority_list()
	allowed_priority_settings = list()
	var/list/priority_mode_list
	if(manipulate_mode == DROP_ITEM_MODE)
		priority_mode_list = priority_settings_for_drop.Copy()
	if(isnull(priority_mode_list))
		return
	for(var/we_need_increasing in 1 to length(priority_mode_list))
		for(var/datum/manipulator_priority/what_priority in priority_mode_list)
			if(what_priority.number != we_need_increasing)
				continue
			allowed_priority_settings += what_priority

/// Proc thet return item by type in priority list. Selects item and increasing priority number if don't found req type.
/obj/machinery/big_manipulator/proc/search_type_by_priority_in_drop_turf(list/priority_list)
	var/lazy_counter = 1
	for(var/datum/manipulator_priority/take_type in priority_list)
		/// If we set only_highest_priority on TRUE we don't go to priority below.
		if(lazy_counter > 1 && only_highest_priority)
			return null
		/// If we need turf we don't check turf.contents and just return drop_turf.
		if(take_type.what_type == /turf)
			return drop_turf
		lazy_counter++
		for(var/type_in_priority in drop_turf.contents)
			if(!istype(type_in_priority, take_type.what_type))
				continue
			return type_in_priority

/// Proc call when we press on/off button
/obj/machinery/big_manipulator/proc/press_on(pressed_by)
	if(pressed_by)
		on = !on
	if(!is_work_check())
		return
	if(on)
		RegisterSignal(take_turf, COMSIG_ATOM_ENTERED, PROC_REF(try_take_thing))
	else
		UnregisterSignal(take_turf, COMSIG_ATOM_ENTERED)

/obj/machinery/big_manipulator/ui_interact(mob/user, datum/tgui/ui)
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
	var/mode
	switch(manipulate_mode)
		if(DROP_ITEM_MODE)
			mode = "Drop"
		if(THROW_ITEM_MODE)
			mode = "Throw"
	data["active"] = on
	data["item_as_filter"] = filter_obj?.resolve()
	data["selected_type"] = selected_type.name
	data["manipulate_mode"] = mode
	data["highest_priority"] = only_highest_priority
	data["throw_range"] = manipulator_throw_range
	var/list/priority_list = list()
	data["settings_list"] = list()
	for(var/datum/manipulator_priority/allowed_setting as anything in allowed_priority_settings)
		var/list/priority_data = list()
		priority_data["name"] = allowed_setting.name
		priority_data["priority_width"] = allowed_setting.number
		priority_list += list(priority_data)
	data["settings_list"] = priority_list
	return data

/obj/machinery/big_manipulator/ui_act(action, params, datum/tgui/ui)
	. = ..()
	if(.)
		return
	switch(action)
		if("on")
			press_on(pressed_by = TRUE)
			return TRUE
		if("drop")
			if(isnull(containment_obj))
				return
			var/obj/obj_resolve = containment_obj?.resolve()
			obj_resolve?.forceMove(get_turf(obj_resolve))
			finish_manipulation()
			return TRUE
		if("change_take_item_type")
			selected_type_by_number++
			if(selected_type_by_number > allowed_types_to_pick_up.len)
				selected_type_by_number = 1
			selected_type = allowed_types_to_pick_up[selected_type_by_number]
			is_work_check()
			return TRUE
		if("change_mode")
			change_mode()
			return TRUE
		if("add_filter")
			var/mob/living/living_user = ui.user
			if(!isliving(living_user))
				return FALSE
			var/obj/give_obj_back = filter_obj?.resolve()
			if(give_obj_back)
				give_obj_back.forceMove(get_turf(src))
				filter_obj = null
				is_work_check()
				to_chat(living_user, span_warning("Filter removed"))
				return TRUE
			var/obj/item/get_active_held_item = living_user.get_active_held_item()
			if(isnull(get_active_held_item))
				to_chat(living_user, span_warning("You need item in hand to put it as filter"))
				return FALSE
			filter_obj = WEAKREF(get_active_held_item)
			get_active_held_item.forceMove(src)
			is_work_check()
			return TRUE
		if("highest_priority_change")
			only_highest_priority = !only_highest_priority
			return TRUE
		if("change_priority")
			var/new_priority_number = params["priority"]
			for(var/datum/manipulator_priority/new_order as anything in allowed_priority_settings)
				if(new_order.number != new_priority_number)
					continue
				new_order.number--
				check_similarities(new_order.number)
				break
			update_priority_list()
			return TRUE
		if("change_throw_range")
			manipulator_throw_range++
			if(manipulator_throw_range > 7)
				manipulator_throw_range = 1
			return TRUE

/// Using on change_priority: looks for a setting with the same number that we set earlier and reduce it.
/obj/machinery/big_manipulator/proc/check_similarities(number_we_minus)
	for(var/datum/manipulator_priority/similarities as anything in allowed_priority_settings)
		if(similarities.number != number_we_minus)
			continue
		similarities.number++
		break

/// Manipulator hand. Effect we animate to show that the manipulator is working and moving something.
/obj/effect/big_manipulator_hand
	name = "Manipulator claw"
	desc = "Take and drop objects. Innovation..."
	icon = 'icons/obj/machines/big_manipulator_parts/big_manipulator_hand.dmi'
	icon_state = "hand"
	layer = LOW_ITEM_LAYER
	appearance_flags = KEEP_TOGETHER | LONG_GLIDE | TILE_BOUND | PIXEL_SCALE
	anchored = TRUE
	greyscale_config = /datum/greyscale_config/manipulator_hand
	pixel_x = -32
	pixel_y = -32
	/// We get item from big manipulator and takes its icon to create overlay.
	var/datum/weakref/item_in_my_claw
	/// Var to icon that used as overlay on manipulator claw to show what item it grabs.
	var/mutable_appearance/icon_overlay

/obj/effect/big_manipulator_hand/update_overlays()
	. = ..()
	if(isnull(item_in_my_claw))
		icon_overlay = null
		return
	var/atom/movable/item_data = item_in_my_claw.resolve()
	icon_overlay = mutable_appearance(item_data.icon, item_data.icon_state, item_data.layer, src, item_data.appearance_flags)
	icon_overlay.color = item_data.color
	icon_overlay.appearance = item_data.appearance
	icon_overlay.pixel_x = 32 + calculate_item_offset(is_x = TRUE)
	icon_overlay.pixel_y = 32 + calculate_item_offset(is_x = FALSE)
	. += icon_overlay

/// Updates item that is in the claw.
/obj/effect/big_manipulator_hand/proc/update_claw(clawed_item)
	item_in_my_claw = clawed_item
	update_appearance()

/// Calculate x and y coordinates so that the item icon appears in the claw and not somewhere in the corner.
/obj/effect/big_manipulator_hand/proc/calculate_item_offset(is_x = TRUE)
	var/offset
	switch(dir)
		if(NORTH)
			offset = is_x ? 0 : 32
		if(SOUTH)
			offset = is_x ? 0 : -32
		if(EAST)
			offset = is_x ? 32 : 0
		if(WEST)
			offset = is_x ? -32 : 0
	return offset

/// Priorities that manipulator use to choose to work on item with type same with what_type.
/datum/manipulator_priority
	/// Name that user will see in ui.
	var/name
	/// What type carries this priority.
	var/what_type
	/**
	* Place in the priority queue. The lower the number, the more important the priority.
	* Doesn’t really matter what number you enter, user can set priority for themselves,
	* BUT!!!
	* Don't write the same numbers in the same parent otherwise something may go wrong.
	*/
	var/number

/datum/manipulator_priority/for_drop/on_floor
	name = "Drop on Floor"
	what_type = /turf
	number = 1

/datum/manipulator_priority/for_drop/in_storage
	name = "Drop in Storage"
	what_type = /obj/item/storage
	number = 2

#undef DROP_ITEM_MODE
#undef THROW_ITEM_MODE

#undef TAKE_ITEMS
#undef TAKE_CLOSETS
#undef TAKE_HUMANS
