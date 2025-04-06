#define INTERACT_DROP "drop"
#define INTERACT_USE "use"
#define INTERACT_THROW "throw"

#define TAKE_ITEMS 1
#define TAKE_CLOSETS 2
#define TAKE_HUMANS 3

#define DELAY_STEP 0.1
#define MAX_DELAY 30

#define MIN_DELAY_TIER_1 2
#define MIN_DELAY_TIER_2 1.4
#define MIN_DELAY_TIER_3 0.8
#define MIN_DELAY_TIER_4 0.2

#define STATUS_BUSY TRUE
#define STATUS_IDLE FALSE

#define WORKER_SINGLE_USE "single"
#define WORKER_EMPTY_USE "empty"
#define WORKER_NORMAL_USE "normal"

/// The Big Manipulator's core. Main part of the mechanism that carries out the entire process.
/obj/machinery/big_manipulator
	name = "Big Manipulator"
	desc = "Operates different objects. Truly, a groundbreaking innovation..."
	icon = 'icons/obj/machines/big_manipulator_parts/big_manipulator_core.dmi'
	icon_state = "core"
	density = TRUE
	circuit = /obj/item/circuitboard/machine/big_manipulator
	greyscale_colors = "#d8ce13"
	greyscale_config = /datum/greyscale_config/big_manipulator
	/// Min time manipulator can have in delay. Changing on upgrade.
	var/minimal_delay = MIN_DELAY_TIER_1
	/// The time it takes for the manipulator to complete the action cycle.
	var/interaction_delay = MIN_DELAY_TIER_1

	/// Using high tier manipulators speeds up big manipulator and requires more energy.
	var/power_use_lvl = 0.2
	/// The status of the manipulator - `IDLE` or `BUSY`.
	var/status = STATUS_IDLE
	/// Is the manipulator turned on?
	var/on = FALSE
	/// The direction the manipulator arm will take items from.
	var/take_here = NORTH
	/// The direction the manipulator arm will drop items to.
	var/drop_here = SOUTH
	/// The turf where the manipulator arm will take items from.
	var/turf/take_turf
	/// The turf where the manipulator arm will drop items to.
	var/turf/drop_turf
	/// Priority settings depending on the manipulator drop mode that are available to this manipulator. Filled during Initialize.
	var/list/priority_settings_for_drop = list()
	/// Priority settings depending on the manipulator use mode that are available to this manipulator. Filled during Initialize.
	var/list/priority_settings_for_use = list()
	/// What priority settings are available to use at the moment.
	/// We also use this list to sort priorities from ascending to descending.
	var/list/allowed_priority_settings = list()
	/// The object inside the manipulator.
	var/datum/weakref/containment_obj
	/// The object used as a filter.
	var/datum/weakref/filter_obj
	/// The poor monkey that needs to use mode works.
	var/datum/weakref/monkey_worker
	/// weakref to id that locked this manipualtor.
	var/datum/weakref/locked_by_this_id
	/// Is manipulator locked by identity id.
	var/id_locked = FALSE
	/// The manipulator's arm.
	var/obj/effect/big_manipulator_arm/manipulator_arm

	/// How should the manipulator interact with the object?
	var/interaction_mode = INTERACT_DROP
	/// How should the worker interact with the object?
	var/worker_interaction = WORKER_NORMAL_USE
	/// The distance the thrown object should travel when thrown.
	var/manipulator_throw_range = 1
	/// Overrides the priority selection, only accessing the top priority list element.
	var/override_priority = FALSE
	/// The `type` the manipulator will interact with only.
	var/atom/selected_type
	/// Is the power access wire cut? Disables the power button if `TRUE`.
	var/power_access_wire_cut = FALSE
	/// List where we can set selected type. Taking items by Initialize.
	var/list/allowed_types_to_pick_up = list(
		/obj/item,
		/obj/structure/closet,
	)

/obj/machinery/big_manipulator/Initialize(mapload)
	. = ..()
	take_and_drop_turfs_check()
	create_manipulator_arm()
	RegisterSignal(manipulator_arm, COMSIG_QDELETING, PROC_REF(on_hand_qdel))
	manipulator_lvl()
	set_up_priority_settings()
	selected_type = allowed_types_to_pick_up[1]
	if(on)
		press_on(pressed_by = null)
	set_wires(new /datum/wires/big_manipulator(src))

	register_context()

/// Init priority settings list for all modes.
/obj/machinery/big_manipulator/proc/set_up_priority_settings()
	for(var/datum/manipulator_priority/priority_for_drop as anything in subtypesof(/datum/manipulator_priority/for_drop))
		priority_settings_for_drop += new priority_for_drop
	for(var/datum/manipulator_priority/priority_for_use as anything in subtypesof(/datum/manipulator_priority/for_use))
		priority_settings_for_use += new priority_for_use
	update_priority_list()

/obj/machinery/big_manipulator/examine(mob/user)
	. = ..()
	. += "You can change direction with alternative wrench usage."
	var/mob/monkey_resolve = monkey_worker?.resolve()
	if(!isnull(monkey_resolve))
		. += "You can see [monkey_resolve]: [src] manager."

/obj/machinery/big_manipulator/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()

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
	. = ..()
	qdel(manipulator_arm)
	if(!isnull(containment_obj))
		var/obj/containment_resolve = containment_obj?.resolve()
		containment_resolve?.forceMove(get_turf(containment_resolve))
	if(!isnull(filter_obj))
		var/obj/filter_resolve = filter_obj?.resolve()
		filter_resolve?.forceMove(get_turf(filter_resolve))
	var/mob/monkey_resolve = monkey_worker?.resolve()
	if(!isnull(monkey_resolve))
		monkey_resolve.forceMove(get_turf(monkey_resolve))
	locked_by_this_id = null

/obj/machinery/big_manipulator/Exited(atom/movable/gone, direction)
	if(isnull(monkey_worker))
		return
	var/mob/living/carbon/human/species/monkey/poor_monkey = monkey_worker.resolve()
	if(gone != poor_monkey)
		return
	if(!is_type_in_list(poor_monkey, manipulator_arm.vis_contents))
		return
	manipulator_arm.vis_contents -= poor_monkey
	if(interaction_mode == INTERACT_USE)
		change_mode()
	poor_monkey.remove_offsets(type)
	monkey_worker = null

/obj/machinery/big_manipulator/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	. = ..()
	take_and_drop_turfs_check()
	if(isnull(get_turf(src)))
		qdel(manipulator_arm)
		return
	if(!manipulator_arm)
		create_manipulator_arm()

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
	if(status == STATUS_BUSY || on)
		to_chat(user, span_warning("[src] is activated!"))
		return ITEM_INTERACT_BLOCKING
	rotate_big_hand()
	playsound(src, 'sound/items/deconstruct.ogg', 50, TRUE)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/big_manipulator/can_be_unfasten_wrench(mob/user, silent)
	if(status == STATUS_BUSY || on)
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

/obj/machinery/big_manipulator/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(user.combat_mode)
		return NONE
	if(!panel_open || !is_wire_tool(tool))
		return NONE
	wires.interact(user)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/big_manipulator/RefreshParts()
	. = ..()

	manipulator_lvl()

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
	if(!isnull(locked_by_this_id))
		var/obj/item/card/id/resolve_id = locked_by_this_id.resolve()
		if(clicked_by_this_id != resolve_id)
			balloon_alert(user, "locked by another id")
			return
		locked_by_this_id = null
		change_id_locked_status(user)
		return
	locked_by_this_id = WEAKREF(clicked_by_this_id)
	change_id_locked_status(user)

/obj/machinery/big_manipulator/proc/change_id_locked_status(mob/user)
	id_locked = !id_locked
	balloon_alert(user, "successfully [!id_locked ? "un" : ""]locked")

/// Creat manipulator hand effect on manipulator core.
/obj/machinery/big_manipulator/proc/create_manipulator_arm()
	manipulator_arm = new/obj/effect/big_manipulator_arm(src)
	manipulator_arm.dir = take_here
	vis_contents += manipulator_arm

/// Check servo tier and change manipulator speed, power_use and colour.
/obj/machinery/big_manipulator/proc/manipulator_lvl()
	var/datum/stock_part/servo/locate_servo = locate() in component_parts
	if(!locate_servo)
		return
	switch(locate_servo.tier)
		if(-INFINITY to 1)
			minimal_delay = interaction_delay = MIN_DELAY_TIER_1
			power_use_lvl = 0.2
			set_greyscale(COLOR_YELLOW)
			manipulator_arm?.set_greyscale(COLOR_YELLOW)
		if(2)
			minimal_delay = interaction_delay = MIN_DELAY_TIER_2
			power_use_lvl = 0.4
			set_greyscale(COLOR_ORANGE)
			manipulator_arm?.set_greyscale(COLOR_ORANGE)
		if(3)
			minimal_delay = interaction_delay = MIN_DELAY_TIER_3
			power_use_lvl = 0.6
			set_greyscale(COLOR_RED)
			manipulator_arm?.set_greyscale(COLOR_RED)
		if(4 to INFINITY)
			minimal_delay = interaction_delay = MIN_DELAY_TIER_4
			power_use_lvl = 0.8
			set_greyscale(COLOR_PURPLE)
			manipulator_arm?.set_greyscale(COLOR_PURPLE)

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
	manipulator_arm.dir = take_here
	var/mob/monkey = monkey_worker?.resolve()
	if(!isnull(monkey))
		monkey.dir = manipulator_arm.dir
	take_and_drop_turfs_check()

/// Deliting hand will destroy our manipulator core.
/obj/machinery/big_manipulator/proc/on_hand_qdel()
	SIGNAL_HANDLER

	deconstruct(TRUE)

/// Pre take and drop proc from [take and drop procs loop]:
/// Can we begin the `take-and-drop` loop?
/obj/machinery/big_manipulator/proc/is_ready_to_work()
	if(worker_interaction == WORKER_EMPTY_USE)
		try_take_thing()
		return TRUE
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

	var/empty_hand_check = worker_interaction == WORKER_EMPTY_USE && interaction_mode == INTERACT_USE

	if(!on)
		return
	if(!anchored)
		return
	if(status == STATUS_BUSY)
		return
	if(!empty_hand_check)
		if(QDELETED(source) || QDELETED(target))
			return
		if(!isturf(target.loc))
			return
		if(!check_filter(target))
			return
	if(!use_energy(active_power_usage, force = FALSE))
		on = FALSE
		say("Not enough energy!")
		return
	start_work(target, empty_hand_check)

/// Second take and drop proc from [take and drop procs loop]:
/// Taking our item and start manipulator hand rotate animation.
/obj/machinery/big_manipulator/proc/start_work(atom/movable/target, hand_is_empty = FALSE)
	if(!hand_is_empty)
		target.forceMove(src)
		containment_obj = WEAKREF(target)
		manipulator_arm.update_claw(containment_obj)
	status = STATUS_BUSY
	do_rotate_animation(1)
	check_next_move(target, hand_is_empty)

/// 2.5 take and drop proc from [take and drop procs loop]:
/// Choose what we will do with our item by checking the interaction_mode.
/obj/machinery/big_manipulator/proc/check_next_move(atom/movable/target, hand_is_empty = FALSE)
	if(hand_is_empty)
		addtimer(CALLBACK(src, PROC_REF(use_thing_with_empty_hand)), interaction_delay SECONDS)
		return
	switch(interaction_mode)
		if(INTERACT_DROP)
			addtimer(CALLBACK(src, PROC_REF(drop_thing), target), interaction_delay SECONDS)
		if(INTERACT_USE)
			addtimer(CALLBACK(src, PROC_REF(use_thing), target), interaction_delay SECONDS)
		if(INTERACT_THROW)
			addtimer(CALLBACK(src, PROC_REF(throw_thing), target), interaction_delay SECONDS)

/// 3.1 take and drop proc from [take and drop procs loop]:
/// Drop our item.
/// Checks the priority to drop item not only ground but also in the storage.
/obj/machinery/big_manipulator/proc/drop_thing(atom/movable/target)
	var/where_we_drop = search_type_by_priority_in_drop_turf(allowed_priority_settings)
	if(isnull(where_we_drop))
		addtimer(CALLBACK(src, PROC_REF(drop_thing), target), interaction_delay SECONDS)
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

/// 3.2 take and drop proc from [take and drop procs loop]:
/// Use our item on random atom in drop turf contents then
/// Starts manipulator hand backward animation by defualt, but
/// You can also set the setting in ui so that it does not return to its privious position and continues to use object in its hand.
/// Checks the priority so that you can configure which object it will select: mob/obj/turf.
/// Also can use filter to interact only with obj in filter.
/obj/machinery/big_manipulator/proc/use_thing(atom/movable/target, hand_is_empty = FALSE)
	var/obj/obj_resolve = containment_obj?.resolve()
	if(isnull(obj_resolve))
		finish_manipulation()
		return
	var/mob/living/carbon/human/species/monkey/monkey_resolve = monkey_worker?.resolve()
	if(isnull(monkey_resolve))
		finish_manipulation()
		return
	/// If we forceMoved from manipulator we are free now.
	if(obj_resolve.loc != src && obj_resolve.loc != monkey_resolve)
		finish_manipulation()
		return
	if(!isitem(target))
		target.forceMove(drop_turf) /// We use only items
		target.dir = get_dir(get_turf(target), get_turf(src))
		finish_manipulation()
		return
	var/obj/item/im_item = target
	var/atom/type_to_use = search_type_by_priority_in_drop_turf(allowed_priority_settings)
	if(isnull(type_to_use))
		check_end_of_use(im_item, item_was_used = FALSE)
		return
	monkey_resolve.put_in_active_hand(im_item)
	if(im_item.GetComponent(/datum/component/two_handed)) /// Using two-handed items in two hands.
		im_item.attack_self(monkey_resolve)
	im_item.melee_attack_chain(monkey_resolve, type_to_use)
	do_attack_animation(drop_turf)
	manipulator_arm.do_attack_animation(drop_turf)
	check_end_of_use(im_item, item_was_used = TRUE)

/obj/machinery/big_manipulator/proc/use_thing_with_empty_hand()
	var/mob/living/carbon/human/species/monkey/monkey_resolve = monkey_worker?.resolve()
	if(isnull(monkey_resolve))
		finish_manipulation()
		return
	var/atom/type_to_use = search_type_by_priority_in_drop_turf(allowed_priority_settings)
	if(isnull(type_to_use))
		check_end_of_use_for_use_with_empty_hand()
		return
	/// We don't do unarmed attack on item because we will take it so we just attack self it like if we wanna to on/off table lamp.
	if(isitem(type_to_use))
		var/obj/item/interact_with_item = type_to_use
		var/resolve_loc = interact_with_item.loc
		monkey_resolve.put_in_active_hand(interact_with_item)
		interact_with_item.attack_self(monkey_resolve)
		interact_with_item.forceMove(resolve_loc)
	else
		monkey_resolve.UnarmedAttack(type_to_use)
	do_attack_animation(drop_turf)
	manipulator_arm.do_attack_animation(drop_turf)
	check_end_of_use_for_use_with_empty_hand()

/obj/machinery/big_manipulator/proc/check_end_of_use_for_use_with_empty_hand(obj/item/my_item, item_was_used)
	if(!on || (worker_interaction != WORKER_EMPTY_USE && interaction_mode == INTERACT_USE))
		finish_manipulation()
		return
	addtimer(CALLBACK(src, PROC_REF(use_thing_with_empty_hand), my_item), interaction_delay SECONDS)

/// Check what we gonna do next with our item. Drop it or use again.
/obj/machinery/big_manipulator/proc/check_end_of_use(obj/item/my_item, item_was_used)
	if(!on)
		my_item.forceMove(drop_turf)
		my_item.dir = get_dir(get_turf(my_item), get_turf(src))
		finish_manipulation()
		return
	if(worker_interaction == WORKER_SINGLE_USE && item_was_used)
		my_item.forceMove(drop_turf)
		my_item.dir = get_dir(get_turf(my_item), get_turf(src))
		finish_manipulation()
		return
	addtimer(CALLBACK(src, PROC_REF(use_thing), my_item), interaction_delay SECONDS)

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
	manipulator_arm.do_attack_animation(drop_turf)
	finish_manipulation()

/// End of thirds take and drop proc from [take and drop procs loop]:
/// Starts manipulator hand backward animation.
/obj/machinery/big_manipulator/proc/finish_manipulation()
	containment_obj = null
	manipulator_arm.update_claw(null)
	do_rotate_animation(0)
	addtimer(CALLBACK(src, PROC_REF(end_work)), interaction_delay SECONDS)

/// Fourth and last take and drop proc from [take and drop procs loop]:
/// Finishes work and begins to look for a new item for [take and drop procs loop].
/obj/machinery/big_manipulator/proc/end_work()
	status = STATUS_IDLE
	is_ready_to_work()

/// Rotates manipulator hand 90 degrees.
/obj/machinery/big_manipulator/proc/do_rotate_animation(backward)
	animate(manipulator_arm, transform = matrix(90, MATRIX_ROTATE), interaction_delay SECONDS * 0.5)
	addtimer(CALLBACK(src, PROC_REF(finish_rotate_animation), backward), interaction_delay SECONDS * 0.5)

/// Rotates manipulator hand from 90 degrees to 180 or 0 if backward.
/obj/machinery/big_manipulator/proc/finish_rotate_animation(backward)
	animate(manipulator_arm, transform = matrix(180 * backward, MATRIX_ROTATE), interaction_delay SECONDS * 0.5)

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
	var/list/available_modes = list(INTERACT_DROP, INTERACT_USE, INTERACT_THROW)

	if(isnull(monkey_worker))
		available_modes = list(INTERACT_DROP, INTERACT_THROW)

	interaction_mode = cycle_value(interaction_mode, available_modes)
	update_priority_list()
	is_ready_to_work()

/// Update priority list in ui. Creating new list and sort it by priority number.
/obj/machinery/big_manipulator/proc/update_priority_list()
	allowed_priority_settings = list()
	var/list/priority_mode_list
	if(interaction_mode == INTERACT_DROP)
		priority_mode_list = priority_settings_for_drop.Copy()
	if(interaction_mode == INTERACT_USE)
		priority_mode_list = priority_settings_for_use.Copy()
	if(isnull(priority_mode_list))
		return
	for(var/we_need_increasing in 1 to length(priority_mode_list))
		for(var/datum/manipulator_priority/what_priority in priority_mode_list)
			if(what_priority.number != we_need_increasing)
				continue
			allowed_priority_settings += what_priority

/// Proc that return item by type in priority list. Selects item and increasing priority number if don't found req type.
/obj/machinery/big_manipulator/proc/search_type_by_priority_in_drop_turf(list/priority_list)
	var/lazy_counter = 1
	for(var/datum/manipulator_priority/take_type in priority_list)
		/// If we set override_priority on TRUE we don't go to priority below.
		if(lazy_counter > 1 && override_priority)
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
	if(!is_ready_to_work())
		return
	if(on)
		RegisterSignal(take_turf, COMSIG_ATOM_ENTERED, PROC_REF(try_take_thing))
		RegisterSignal(take_turf, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON, PROC_REF(try_take_thing))
	else
		UnregisterSignal(take_turf, COMSIG_ATOM_ENTERED)
		UnregisterSignal(take_turf, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON)

/// Proc that check if button not cutted when we press on button.
/obj/machinery/big_manipulator/proc/try_press_on(mob/user)
	if(power_access_wire_cut)
		balloon_alert(user, "button is cut off!")
		return
	press_on(pressed_by = TRUE)

/// Drop item that manipulator is manipulating.
/obj/machinery/big_manipulator/proc/drop_held_object()
	if(isnull(containment_obj))
		return
	var/obj/obj_resolve = containment_obj?.resolve()
	obj_resolve?.forceMove(get_turf(obj_resolve))
	finish_manipulation()

/// Changes manipulator working speed time.
/obj/machinery/big_manipulator/proc/change_delay(new_delay)
	interaction_delay = round(clamp(new_delay, minimal_delay, MAX_DELAY), DELAY_STEP)

/obj/machinery/big_manipulator/ui_interact(mob/user, datum/tgui/ui)
	if(id_locked)
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
	data["item_as_filter"] = filter_obj?.resolve()
	data["selected_type"] = selected_type.name
	data["interaction_mode"] = interaction_mode
	data["worker_interaction"] = worker_interaction
	data["highest_priority"] = override_priority
	data["throw_range"] = manipulator_throw_range
	var/list/priority_list = list()
	data["settings_list"] = list()
	for(var/datum/manipulator_priority/allowed_setting as anything in allowed_priority_settings)
		var/list/priority_data = list()
		priority_data["name"] = allowed_setting.name
		priority_data["priority_width"] = allowed_setting.number
		priority_list += list(priority_data)
	data["settings_list"] = priority_list
	data["min_delay"] = minimal_delay
	data["interaction_delay"] = interaction_delay
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
		if("on")
			try_press_on(ui.user)
			return TRUE
		if("drop")
			drop_held_object()
			return TRUE
		if("change_take_item_type")
			cycle_pickup_type()
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
				is_ready_to_work()
				to_chat(living_user, span_warning("Filter removed"))
				return TRUE
			var/obj/item/get_active_held_item = living_user.get_active_held_item()
			if(isnull(get_active_held_item))
				to_chat(living_user, span_warning("You need item in hand to put it as filter"))
				return FALSE
			filter_obj = WEAKREF(get_active_held_item)
			get_active_held_item.forceMove(src)
			is_ready_to_work()
			return TRUE
		if("highest_priority_change")
			override_priority = !override_priority
			return TRUE
		if("worker_interaction_change")
			cycle_worker_interaction()
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
		if("cycle_throw_range")
			cycle_throw_range()
			return TRUE
		if("changeDelay")
			change_delay(text2num(params["new_delay"]))
			return TRUE

/// Using on change_priority: looks for a setting with the same number that we set earlier and reduce it.
/obj/machinery/big_manipulator/proc/check_similarities(number_we_minus)
	for(var/datum/manipulator_priority/similarities as anything in allowed_priority_settings)
		if(similarities.number != number_we_minus)
			continue
		similarities.number++
		break

/// Manipulator hand. Effect we animate to show that the manipulator is working and moving something.
/obj/effect/big_manipulator_arm
	name = "mechanical claw"
	desc = "Takes and drops objects."
	icon = 'icons/obj/machines/big_manipulator_parts/big_manipulator_hand.dmi'
	icon_state = "hand"
	layer = LOW_ITEM_LAYER
	appearance_flags = KEEP_TOGETHER | LONG_GLIDE | TILE_BOUND | PIXEL_SCALE
	anchored = TRUE
	greyscale_config = /datum/greyscale_config/manipulator_arm
	pixel_x = -32
	pixel_y = -32
	/// We get item from big manipulator and takes its icon to create overlay.
	var/datum/weakref/item_in_my_claw
	/// Var to icon that used as overlay on manipulator claw to show what item it grabs.
	var/mutable_appearance/icon_overlay

/obj/effect/big_manipulator_arm/update_overlays()
	. = ..()
	. += update_item_overlay()

/obj/effect/big_manipulator_arm/proc/update_item_overlay()
	if(isnull(item_in_my_claw))
		return icon_overlay = null
	var/atom/movable/item_data = item_in_my_claw.resolve()
	icon_overlay = mutable_appearance(item_data.icon, item_data.icon_state, item_data.layer, src, item_data.plane, item_data.alpha, item_data.appearance_flags)
	icon_overlay.color = item_data.color
	icon_overlay.appearance = item_data.appearance
	icon_overlay.pixel_w = 32 + calculate_item_offset(is_x = TRUE)
	icon_overlay.pixel_z = 32 + calculate_item_offset(is_x = FALSE)
	return icon_overlay

/// Updates item that is in the claw.
/obj/effect/big_manipulator_arm/proc/update_claw(clawed_item)
	item_in_my_claw = clawed_item
	update_appearance()

/// Calculate x and y coordinates so that the item icon appears in the claw and not somewhere in the corner.
/obj/effect/big_manipulator_arm/proc/calculate_item_offset(is_x = TRUE, pixels_to_offset = 32)
	var/offset
	switch(dir)
		if(NORTH)
			offset = is_x ? 0 : pixels_to_offset
		if(SOUTH)
			offset = is_x ? 0 : -pixels_to_offset
		if(EAST)
			offset = is_x ? pixels_to_offset : 0
		if(WEST)
			offset = is_x ? -pixels_to_offset : 0
	return offset

/// Priorities that manipulator use to choose to work on item with type same with what_type.
/datum/manipulator_priority
	/// Name that user will see in ui.
	var/name
	/// What type carries this priority.
	var/what_type
	/**
	* Place in the priority queue. The lower the number, the more important the priority.
	* Doesn't really matter what number you enter, user can set priority for themselves,
	* BUT!!!
	* Don't write the same numbers in the same parent otherwise something may go wrong.
	*/
	var/number

/datum/manipulator_priority/for_drop/on_floor
	name = "DROP ON FLOOR"
	what_type = /turf
	number = 1

/datum/manipulator_priority/for_drop/in_storage
	name = "DROP IN STORAGE"
	what_type = /obj/item/storage
	number = 2

/datum/manipulator_priority/for_use/on_living
	name = "USE ON LIVING"
	what_type = /mob/living
	number = 1

/datum/manipulator_priority/for_use/on_structure
	name = "USE ON STRUCTURE"
	what_type = /obj/structure
	number = 2

/datum/manipulator_priority/for_use/on_machinery
	name = "USE ON MACHINERY"
	what_type = /obj/machinery
	number = 3

/datum/manipulator_priority/for_use/on_items
	name = "USE ON ITEM"
	what_type = /obj/item
	number = 4

/// Cycles the given value in the given list. Retuns the next value in the list, or the first one if the list isn't long enough.
/obj/machinery/big_manipulator/proc/cycle_value(current_value, list/possible_values)
	var/current_index = possible_values.Find(current_value)
	if(current_index == null)
		return possible_values[1]

	var/next_index = (current_index % possible_values.len) + 1
	return possible_values[next_index]

/obj/machinery/big_manipulator/proc/cycle_worker_interaction()
	var/list/worker_modes = list(WORKER_NORMAL_USE, WORKER_SINGLE_USE, WORKER_EMPTY_USE)
	worker_interaction = cycle_value(worker_interaction, worker_modes)

/obj/machinery/big_manipulator/proc/cycle_throw_range()
	var/list/possible_ranges = list(1, 2, 3, 4, 5, 6, 7)
	manipulator_throw_range = cycle_value(manipulator_throw_range, possible_ranges)

/obj/machinery/big_manipulator/proc/cycle_pickup_type()
	selected_type = cycle_value(selected_type, allowed_types_to_pick_up)
	is_ready_to_work()

#undef INTERACT_DROP
#undef INTERACT_USE
#undef INTERACT_THROW

#undef TAKE_ITEMS
#undef TAKE_CLOSETS
#undef TAKE_HUMANS

#undef DELAY_STEP
#undef MAX_DELAY

#undef WORKER_NORMAL_USE
#undef WORKER_SINGLE_USE
#undef WORKER_EMPTY_USE

#undef STATUS_IDLE
#undef STATUS_BUSY

#undef MIN_DELAY_TIER_1
#undef MIN_DELAY_TIER_2
#undef MIN_DELAY_TIER_3
#undef MIN_DELAY_TIER_4
