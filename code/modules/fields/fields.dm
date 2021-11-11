//Movable and easily code-modified fields! Allows for custom AOE effects that affect movement and anything inside of them, and can do custom turf effects!
//Supports automatic recalculation/reset on movement.
//If there's any way to make this less CPU intensive than I've managed, gimme a call or do it yourself! - kevinz000

/datum/proximity_monitor/advanced
	var/name = "\improper Energy Field"
	loc_connections = list(
		COMSIG_ATOM_ENTERED = .proc/on_entered,
		COMSIG_ATOM_EXITED =.proc/on_uncrossed,
		COMSIG_TURF_CANPASS = .proc/can_pass,
	)
	//Processing
	var/process_inner_turfs = FALSE //Don't do this unless it's absolutely necessary
	var/process_edge_turfs = FALSE //Don't do this either unless it's absolutely necessary, you can just track what things are inside manually or on the initial setup.
	var/requires_processing = FALSE
	var/setup_edge_turfs = FALSE //Setup edge turfs/all field turfs. Set either or both to ON when you need it, it's defaulting to off unless you do to save CPU.
	var/setup_field_turfs = FALSE
	var/use_host_turf = FALSE //For fields from items carried on mobs to check turf instead of loc...

	var/list/turf/field_turfs = list()
	var/list/turf/edge_turfs = list()
	var/list/turf/field_turfs_new = list()
	var/list/turf/edge_turfs_new = list()

/datum/proximity_monitor/advanced/Destroy()
	for(var/turf/T in edge_turfs)
		cleanup_edge_turf(T)
	for(var/turf/T in field_turfs)
		cleanup_field_turf(T)
	return ..()

//Call every time the field moves (done automatically if you use update_center) or a setup specification is changed.
/datum/proximity_monitor/advanced/proc/recalculate_field()
	update_new_turfs()
	if(setup_field_turfs)
		for(var/turf/T in field_turfs)
			if(!(T in field_turfs_new))
				cleanup_field_turf(T)
			CHECK_TICK
		for(var/turf/T in field_turfs_new)
			setup_field_turf(T)
			CHECK_TICK
	if(setup_edge_turfs)
		for(var/turf/T in edge_turfs)
			cleanup_edge_turf(T)
			CHECK_TICK
		for(var/turf/T in edge_turfs_new)
			setup_edge_turf(T)
			CHECK_TICK

/datum/proximity_monitor/advanced/proc/can_pass(turf/source, atom/movable/mover, border_dir)
	SIGNAL_HANDLER
	var/edge_turf = get_dist(source, host) == current_range
	if(edge_turf ? field_edge_canpass(mover, src, border_dir) : field_turf_canpass(mover, src, border_dir))
		return COMPONENT_CANNOT_PASS

/datum/proximity_monitor/advanced/on_entered(atom/source, atom/movable/entered)
	. = ..()
	if(get_dist(source, host) == current_range)
		field_edge_crossed(entered, src)
	else
		field_turf_crossed(entered, src)

/datum/proximity_monitor/advanced/on_uncrossed(atom/source, atom/movable/gone, direction)
	. = ..()
	if(get_dist(source, host) == current_range)
		field_edge_uncrossed(gone, src)
	else
		field_turf_uncrossed(gone, src)

/datum/proximity_monitor/advanced/HandleMove(atom/movable/source, atom/old_loc)
	. = ..()
	if(host.loc != old_loc)
		INVOKE_ASYNC(src, .proc/recalculate_field)

/datum/proximity_monitor/advanced/proc/cleanup_field_turf(turf/T)
	return

/datum/proximity_monitor/advanced/proc/cleanup_edge_turf(turf/T)
	return

/datum/proximity_monitor/advanced/proc/setup_field_turf(turf/T)
	return

/datum/proximity_monitor/advanced/proc/setup_edge_turf(turf/T)
	return

/datum/proximity_monitor/advanced/proc/update_new_turfs()
	if(!istype(host))
		return FALSE
	field_turfs_new = list()
	edge_turfs_new = list()
	if(ignore_if_not_on_turf && !isturf(host.loc))
		return
	var/turf/center = get_turf(host.loc)
	for(var/turf/target in RANGE_TURFS(current_range, center))
		if(get_dist(center, target) == current_range)
			edge_turfs_new += target
		else
			field_turfs_new += target

//Gets edge direction/corner, only works with square radius/WDH fields!
/datum/proximity_monitor/advanced/proc/get_edgeturf_direction(turf/T, turf/center_override = null)
	var/turf/checking_from = get_turf(host)
	if(istype(center_override))
		checking_from = center_override
	if(!(T in edge_turfs))
		return
	if(((T.x == (checking_from.x + current_range)) || (T.x == (checking_from.x - current_range))) && ((T.y == (checking_from.y + current_range)) || (T.y == (checking_from.y - current_range))))
		return get_dir(checking_from, T)
	if(T.x == (checking_from.x + current_range))
		return EAST
	if(T.x == (checking_from.x - current_range))
		return WEST
	if(T.y == (checking_from.y - current_range))
		return SOUTH
	if(T.y == (checking_from.y + current_range))
		return NORTH


/datum/proximity_monitor/advanced/proc/field_turf_canpass(atom/movable/AM, obj/effect/abstract/proximity_checker/advanced/field_turf/F, border_dir)
	return TRUE

/datum/proximity_monitor/advanced/proc/field_turf_crossed(atom/movable/AM, obj/effect/abstract/proximity_checker/advanced/field_turf/F)
	return TRUE

/datum/proximity_monitor/advanced/proc/field_turf_uncrossed(atom/movable/AM, obj/effect/abstract/proximity_checker/advanced/field_turf/F)
	return TRUE

/datum/proximity_monitor/advanced/proc/field_edge_canpass(atom/movable/AM, obj/effect/abstract/proximity_checker/advanced/field_edge/F, border_dir)
	return TRUE

/datum/proximity_monitor/advanced/proc/field_edge_crossed(atom/movable/AM, obj/effect/abstract/proximity_checker/advanced/field_edge/F)
	return TRUE

/datum/proximity_monitor/advanced/proc/field_edge_uncrossed(atom/movable/AM, obj/effect/abstract/proximity_checker/advanced/field_edge/F)
	return TRUE


//DEBUG FIELD ITEM
/obj/item/multitool/field_debug
	name = "strange multitool"
	desc = "Seems to project a colored field!"
	var/operating = FALSE
	var/datum/proximity_monitor/advanced/debug/current = null

/obj/item/multitool/field_debug/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/multitool/field_debug/Destroy()
	STOP_PROCESSING(SSobj, src)
	QDEL_NULL(current)
	return ..()

/obj/item/multitool/field_debug/proc/setup_debug_field()
	current = new(src, 5, FALSE)
	current.set_fieldturf_color = "#aaffff"
	current.set_edgeturf_color = "#ffaaff"
	current.recalculate_field()

/obj/item/multitool/field_debug/attack_self(mob/user)
	operating = !operating
	to_chat(user, span_notice("You turn [src] [operating? "on":"off"]."))
	if(!istype(current) && operating)
		setup_debug_field()
	else if(!operating)
		QDEL_NULL(current)

/obj/item/multitool/field_debug/process()
	check_turf(get_turf(src))

/obj/item/multitool/field_debug/proc/check_turf(turf/T)
	current.HandleMove()

/proc/is_turf_in_field(atom/target, datum/proximity_monitor/advanced/field)
	if(!field.host || !get_turf(target) || !get_turf(field.host))
		return FALSE
	var/distance = get_dist(target, field.host)
	//Can't be a switch() statement since it requires constant expressions
	if(distance > field.current_range)
		return FALSE
	return distance == field.current_range ? FIELD_EDGE : FIELD_TURF

//DEBUG FIELDS
/datum/proximity_monitor/advanced/debug
	name = "\improper Color Matrix Field"
	current_range = 5
	var/set_fieldturf_color = "#aaffff"
	var/set_edgeturf_color = "#ffaaff"
	setup_field_turfs = TRUE
	setup_edge_turfs = TRUE

/datum/proximity_monitor/advanced/debug/setup_edge_turf(turf/T)
	T.color = set_edgeturf_color

/datum/proximity_monitor/advanced/debug/cleanup_edge_turf(turf/T)
	T.color = initial(T.color)

/datum/proximity_monitor/advanced/debug/setup_field_turf(turf/T)
	T.color = set_fieldturf_color

/datum/proximity_monitor/advanced/debug/cleanup_field_turf(turf/T)
	T.color = initial(T.color)
