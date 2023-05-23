// Proximity monitor applies forced gravity to all turfs in range.
/datum/proximity_monitor/advanced/gravity
	edge_is_a_field = TRUE
	var/gravity_value = 0
	var/list/modified_turfs = list()

/datum/proximity_monitor/advanced/gravity/New(atom/_host, range, _ignore_if_not_on_turf = TRUE, gravity)
	. = ..()
	gravity_value = gravity
	recalculate_field()

/datum/proximity_monitor/advanced/gravity/setup_field_turf(turf/target)
	. = ..()
	if (isnull(modified_turfs[target]))
		return

	target.AddElement(/datum/element/forced_gravity, gravity_value)
	modified_turfs[target] = gravity_value

/datum/proximity_monitor/advanced/gravity/cleanup_field_turf(turf/target)
	. = ..()
	if(isnull(modified_turfs[target]))
		return
	target.RemoveElement(/datum/element/forced_gravity, modified_turfs[target])
	modified_turfs -= target

// Subtype which pops up a balloon alert when a mob enters the field
/datum/proximity_monitor/advanced/gravity/warns_on_entrance
	/// This is a list of mob refs that have recently entered the field.
	/// We track it so that we don't spam a player who is stutter stepping in and out with balloon alerts.
	var/list/recently_warned

/datum/proximity_monitor/advanced/field_edge_crossed(atom/movable/movable, turf/location)
	. = ..()
	if(!ismob(movable))
		return
	var/movable_ref_key = REF(movable)
	if(movable_ref_key in recently_warned)
		return

	location.balloon_alert(movable, "gravity shifts!")
	LAZYADD(recently_warned, movable_ref_key)
	addtimer(CALLBACK(src, PROC_REF(clear_recent_warning), movable_ref_key), 4 SECONDS)

/datum/proximity_monitor/advanced/field_edge_uncrossed(atom/movable/movable, turf/location)
	. = ..()
	if(!ismob(movable))
		return
	if(movable_ref_key in recently_warned)
		return

	location.balloon_alert(movable, "gravity reverts...")

/datum/proximity_monitor/advanced/proc/clear_recent_warning(movable_ref_key)
	LAZYREMOVE(recently_warned, movable_ref_key)
