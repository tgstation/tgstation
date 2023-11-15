#define FIELD_TURFS_KEY "field_turfs"
#define EDGE_TURFS_KEY "edge_turfs"

/**
 * Movable and easily code-modified fields! Allows for custom AOE effects that affect movement
 * and anything inside of them, and can do custom turf effects!
 * Supports automatic recalculation/reset on movement.
 *
 * "What do I gain from using advanced over standard prox monitors?"
 * - You can set different effects on edge vs field entrance
 * - You can set effects when the proximity monitor starts and stops tracking a turf
 */
/datum/proximity_monitor/advanced
	/// If TRUE, edge turfs will be included as "in the field" for effects
	/// Can be used in certain situations where you may have effects that trigger only at the edge,
	/// while also wanting the field effect to trigger at edge turfs as well
	var/edge_is_a_field = FALSE
	/// All turfs on the inside of the proximity monitor - range - 1 turfs
	var/list/turf/field_turfs = list()
	/// All turfs on the very last tile of the proximity monitor's radius
	var/list/turf/edge_turfs = list()

/datum/proximity_monitor/advanced/Destroy()
	cleanup_field()
	return ..()

/datum/proximity_monitor/advanced/proc/cleanup_field()
	for(var/turf/turf as anything in edge_turfs)
		cleanup_edge_turf(turf)
	for(var/turf/turf as anything in field_turfs)
		cleanup_field_turf(turf)

//Call every time the field moves (done automatically if you use update_center) or a setup specification is changed.
/datum/proximity_monitor/advanced/proc/recalculate_field()
	var/list/new_turfs = update_new_turfs()

	var/list/new_field_turfs = new_turfs[FIELD_TURFS_KEY]
	var/list/new_edge_turfs = new_turfs[EDGE_TURFS_KEY]

	for(var/turf/old_turf as anything in field_turfs)
		if(!(old_turf in new_field_turfs))
			cleanup_field_turf(old_turf)
	for(var/turf/old_turf as anything in edge_turfs)
		cleanup_edge_turf(old_turf)

	for(var/turf/new_turf as anything in new_field_turfs)
		field_turfs |= new_turf
		setup_field_turf(new_turf)
	for(var/turf/new_turf as anything in new_edge_turfs)
		edge_turfs |= new_turf
		setup_edge_turf(new_turf)

/datum/proximity_monitor/advanced/on_entered(turf/source, atom/movable/entered)
	. = ..()
	if(get_dist(source, host) == current_range)
		field_edge_crossed(entered, source)
	else
		field_turf_crossed(entered, source)

/datum/proximity_monitor/advanced/on_moved(atom/movable/movable, atom/old_loc)
	. = ..()
	if(ignore_if_not_on_turf)
		//Early return if it's not the host that has moved.
		if(movable != host)
			return
		//Cleanup the field if the host was on a turf but isn't anymore.
		if(!isturf(host.loc))
			if(isturf(old_loc))
				cleanup_field()
			return
	recalculate_field()

/datum/proximity_monitor/advanced/on_uncrossed(turf/source, atom/movable/gone, direction)
	if(get_dist(source, host) == current_range)
		field_edge_uncrossed(gone, source)
	else
		field_turf_uncrossed(gone, source)

/// Called when a turf in the field of the monitor is linked
/datum/proximity_monitor/advanced/proc/setup_field_turf(turf/target)
	return

/// Called when a turf in the field of the monitor is unlinked
/datum/proximity_monitor/advanced/proc/cleanup_field_turf(turf/target)
	field_turfs -= target

/// Called when a turf in the edge of the monitor is linked
/datum/proximity_monitor/advanced/proc/setup_edge_turf(turf/target)
	if(edge_is_a_field) // If the edge is considered a field, set it up like one
		setup_field_turf(target)

/// Called when a turf in the edge of the monitor is unlinked
/datum/proximity_monitor/advanced/proc/cleanup_edge_turf(turf/target)
	if(edge_is_a_field) // If the edge is considered a field, clean it up like one
		cleanup_field_turf(target)
	edge_turfs -= target

/datum/proximity_monitor/advanced/proc/update_new_turfs()
	. = list(FIELD_TURFS_KEY = list(), EDGE_TURFS_KEY = list())
	if(ignore_if_not_on_turf && !isturf(host.loc))
		return
	var/turf/center = get_turf(host)
	for(var/turf/target in RANGE_TURFS(current_range, center))
		if(get_dist(center, target) == current_range)
			.[EDGE_TURFS_KEY] += target
		else
			.[FIELD_TURFS_KEY] += target

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

/datum/proximity_monitor/advanced/proc/field_turf_crossed(atom/movable/movable, turf/location)
	return

/datum/proximity_monitor/advanced/proc/field_turf_uncrossed(atom/movable/movable, turf/location)
	return

/datum/proximity_monitor/advanced/proc/field_edge_crossed(atom/movable/movable, turf/location)
	if(edge_is_a_field) // If the edge is considered a field, pass crossed to that
		field_turf_crossed(movable, location)

/datum/proximity_monitor/advanced/proc/field_edge_uncrossed(atom/movable/movable, turf/location)
	if(edge_is_a_field) // If the edge is considered a field, pass uncrossed to that
		field_turf_uncrossed(movable, location)

//DEBUG FIELD ITEM
/obj/item/multitool/field_debug
	name = "strange multitool"
	desc = "Seems to project a colored field!"
	var/operating = FALSE
	var/datum/proximity_monitor/advanced/debug/current = null

/obj/item/multitool/field_debug/Destroy()
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

/obj/item/multitool/field_debug/attack_self_secondary(mob/user, modifiers)
	current.edge_is_a_field = !current.edge_is_a_field
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

//DEBUG FIELDS
/datum/proximity_monitor/advanced/debug
	current_range = 5
	var/set_fieldturf_color = "#aaffff"
	var/set_edgeturf_color = "#ffaaff"

/datum/proximity_monitor/advanced/debug/setup_edge_turf(turf/target)
	. = ..()
	target.color = set_edgeturf_color

/datum/proximity_monitor/advanced/debug/cleanup_edge_turf(turf/target)
	. = ..()
	target.color = initial(target.color)

/datum/proximity_monitor/advanced/debug/setup_field_turf(turf/target)
	. = ..()
	target.color = set_fieldturf_color

/datum/proximity_monitor/advanced/debug/cleanup_field_turf(turf/target)
	. = ..()
	target.color = initial(target.color)

#undef FIELD_TURFS_KEY
#undef EDGE_TURFS_KEY
