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
	/// Obj inside manipulator.
	var/datum/weakref/containment_obj
	/// Other manipulator component.
	var/obj/effect/manipulator_hand

/obj/machinery/big_manipulator/Initialize(mapload)
	. = ..()
	take_and_drop_turfs_check()
	create_manipulator_hand()
	RegisterSignal(manipulator_hand, COMSIG_QDELETING, PROC_REF(on_hand_qdel))
	manipulator_lvl()
	if(on)
		press_on(pressed_by = null)

/obj/machinery/big_manipulator/examine(mob/user)
	. = ..()
	. += "You can change direction with alternative wrench usage."

/obj/machinery/big_manipulator/Destroy(force)
	. = ..()
	qdel(manipulator_hand)
	if(isnull(containment_obj))
		return
	var/obj/obj_resolve = containment_obj?.resolve()
	obj_resolve?.forceMove(get_turf(obj_resolve))

/obj/machinery/big_manipulator/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	. = ..()
	take_and_drop_turfs_check()
	if(isnull(get_turf(src)))
		qdel(manipulator_hand)
		return
	if(!manipulator_hand)
		create_manipulator_hand()
	manipulator_hand.forceMove(get_turf(src))

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
	manipulator_hand = new/obj/effect/big_manipulator_hand(get_turf(src))
	manipulator_hand.dir = take_here

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
	for(var/obj/item/take_item in take_turf.contents)
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
	if(isitem(target))
		start_work(target)

/// Second take and drop proc from [take and drop procs loop]:
/// Taking our item and start manipulator hand rotate animation.
/obj/machinery/big_manipulator/proc/start_work(atom/movable/target)
	target.forceMove(src)
	containment_obj = WEAKREF(target)
	on_work = TRUE
	do_rotate_animation(1)
	addtimer(CALLBACK(src, PROC_REF(drop_thing), target), working_speed)

/// Third take and drop proc from [take and drop procs loop]:
/// Drop our item and start manipulator hand backward animation.
/obj/machinery/big_manipulator/proc/drop_thing(atom/movable/target)
	target.forceMove(drop_turf)
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
	data["active"] = on
	return data

/obj/machinery/big_manipulator/ui_act(action, params, datum/tgui/ui)
	. = ..()
	if(.)
		return
	switch(action)
		if("on")
			press_on(pressed_by = TRUE)
			return TRUE

/// Manipulator hand. Effect we animate to show that the manipulator is working and moving something.
/obj/effect/big_manipulator_hand
	name = "Manipulator claw"
	desc = "Take and drop objects. Innovation..."
	icon = 'icons/obj/machines/big_manipulator_parts/big_manipulator_hand.dmi'
	icon_state = "hand"
	layer = LOW_ITEM_LAYER
	anchored = TRUE
	greyscale_config = /datum/greyscale_config/manipulator_hand
	pixel_x = -32
	pixel_y = -32
