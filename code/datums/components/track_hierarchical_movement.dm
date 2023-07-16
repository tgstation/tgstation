/**
 * Component which outputs a signal if the attached atom or any of its containers moves
 */
/datum/component/track_hierarchical_movement
	/// List of things we're currently listening out for movement from
	var/list/containers

/datum/component/track_hierarchical_movement/Initialize()
	. = ..()
	if (!ismovable(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/track_hierarchical_movement/Destroy(force, silent)
	LAZYCLEARLIST(containers)
	return ..()

/datum/component/track_hierarchical_movement/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))
	rebuild_hierarchy()

/datum/component/track_hierarchical_movement/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, COMSIG_MOVABLE_MOVED)
	for (var/container in containers)
		UnregisterSignal(container, COMSIG_MOVABLE_MOVED)

/// Something in our hierarchy moved, send signal then rebuild hierarchy
/datum/component/track_hierarchical_movement/proc/on_moved(datum/source, old_loc, dir, forced)
	SIGNAL_HANDLER
	SEND_SIGNAL(parent, COMSIG_MOVABLE_OR_CONTAINER_MOVED, old_loc, dir, forced)
	rebuild_hierarchy()

/// Listen for the movement signal on every parent which isn't the floor or the void
/datum/component/track_hierarchical_movement/proc/rebuild_hierarchy()
	for (var/container in containers)
		UnregisterSignal(container, COMSIG_MOVABLE_MOVED)
	LAZYCLEARLIST(containers)
	var/atom/checked = parent
	while (!isnull(checked.loc) && !isturf(checked.loc))
		RegisterSignal(checked.loc, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))
		checked = checked.loc
		LAZYADD(containers, checked)
