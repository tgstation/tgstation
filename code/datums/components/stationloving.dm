/// Teleports the movable atom back to a safe turf on the station if it leaves the z-level or becomes inaccessible.
/datum/component/stationloving
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	/// If TRUE, notifies admins when parent is teleported back to the station.
	var/inform_admins = FALSE
	var/disallow_soul_imbue = TRUE
	/// If FALSE, prevents parent from being qdel'd unless it's a force = TRUE qdel.
	var/allow_item_destruction = FALSE
	var/datum/weakref/connect_ref

/datum/component/stationloving/Initialize(inform_admins = FALSE, allow_item_destruction = FALSE)
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE
	src.inform_admins = inform_admins
	src.allow_item_destruction = allow_item_destruction

	// Just in case something is being created outside of station/centcom
	if(!atom_in_bounds(parent))
		relocate()

/datum/component/stationloving/RegisterWithParent()
	RegisterSignal(parent, COMSIG_PREQDELETED, PROC_REF(on_parent_pre_qdeleted))
	RegisterSignal(parent, COMSIG_ITEM_IMBUE_SOUL, PROC_REF(check_soul_imbue))
	RegisterSignal(parent, COMSIG_ITEM_MARK_RETRIEVAL, PROC_REF(check_mark_retrieval))
	// Relocate when we become unreachable
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(on_parent_moved))
	// Relocate when our loc, or any of our loc's locs, becomes unreachable
	var/static/list/loc_connections = list(
		COMSIG_MOVABLE_MOVED = PROC_REF(on_parent_moved),
		SIGNAL_ADDTRAIT(TRAIT_SECLUDED_LOCATION) = PROC_REF(on_loc_secluded),
	)
	connect_ref = WEAKREF(AddComponent(/datum/component/connect_containers, parent, loc_connections))

/datum/component/stationloving/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_MOVABLE_Z_CHANGED,
		COMSIG_PREQDELETED,
		COMSIG_ITEM_IMBUE_SOUL,
		COMSIG_ITEM_MARK_RETRIEVAL,
		COMSIG_MOVABLE_MOVED,
	))

	qdel(connect_ref)

/datum/component/stationloving/InheritComponent(datum/component/stationloving/newc, original, inform_admins, allow_death)
	if (original)
		if (newc)
			inform_admins = newc.inform_admins
			allow_death = newc.allow_item_destruction
		else
			inform_admins = inform_admins

/// Teleports parent to a safe turf on the station z-level.
/datum/component/stationloving/proc/relocate()

	var/target_turf = length(GLOB.the_station_areas) ? get_safe_random_station_turf(GLOB.the_station_areas) : find_safe_turf() //Fallback. Mostly for debug maps.

	if(!target_turf)
		if(GLOB.blobstart.len > 0)
			target_turf = get_turf(pick(GLOB.blobstart))
		else
			CRASH("Unable to find a blobstart landmark for [type] to relocate [parent].")

	var/atom/movable/movable_parent = parent
	playsound(movable_parent, 'sound/machines/synth/synth_no.ogg', 5, TRUE)

	var/mob/holder = get(movable_parent, /mob)
	if(holder)
		to_chat(holder, span_danger("You can't help but feel that you just lost something back there..."))
		holder.temporarilyRemoveItemFromInventory(parent, TRUE) // prevents ghost diskie

	movable_parent.forceMove(target_turf)

	return target_turf

/// Signal proc for [COMSIG_MOVABLE_MOVED], called when our parent moves, or our parent's loc, or our parent's loc loc...
/// To check if our disk is moving somewhere it shouldn't be, such as off Z level, or into an invalid area
/datum/component/stationloving/proc/on_parent_moved(atom/movable/source, turf/old_turf)
	SIGNAL_HANDLER

	if(atom_in_bounds(source))
		return

	var/turf/current_turf = get_turf(source)
	var/turf/new_destination = relocate()
	// Our turf actually didn't change, so it's more likely we became secluded
	if(current_turf == old_turf)
		log_game("[parent] moved out of bounds at [loc_name(current_turf)], becoming inaccessible / secluded. \
			Moving it to [loc_name(new_destination)].")

		if(inform_admins)
			message_admins("[parent] moved out of bounds at [ADMIN_VERBOSEJMP(current_turf)], becoming inaccessible / secluded. \
				Moving it to [ADMIN_VERBOSEJMP(new_destination)].")

	// Our locs changes, we did in fact move somewhere
	else
		log_game("[parent] attempted to be moved out of bounds from [loc_name(old_turf)] \
			to [loc_name(current_turf)]. Moving it to [loc_name(new_destination)].")

		if(inform_admins)
			message_admins("[parent] attempted to be moved out of bounds from [ADMIN_VERBOSEJMP(old_turf)] \
				to [ADMIN_VERBOSEJMP(current_turf)]. Moving it to [ADMIN_VERBOSEJMP(new_destination)].")

/// Signal proc for [SIGNAL_ADDTRAIT], via [TRAIT_SECLUDED_LOCATION] on our locs, to ensure nothing funky happens
/datum/component/stationloving/proc/on_loc_secluded(atom/movable/source)
	SIGNAL_HANDLER

	var/turf/new_destination = relocate()
	log_game("[parent] moved out of bounds at [loc_name(source)], becoming inaccessible / secluded. \
		Moving it to [loc_name(new_destination)].")

	if(inform_admins)
		message_admins("[parent] moved out of bounds at [ADMIN_VERBOSEJMP(source)], becoming inaccessible / secluded. \
			Moving it to [ADMIN_VERBOSEJMP(new_destination)].")

/datum/component/stationloving/proc/check_soul_imbue(datum/source)
	SIGNAL_HANDLER

	if(disallow_soul_imbue)
		return COMPONENT_BLOCK_IMBUE

/datum/component/stationloving/proc/check_mark_retrieval(datum/source)
	SIGNAL_HANDLER

	return COMPONENT_BLOCK_MARK_RETRIEVAL

/// Checks whether a given atom's turf is within bounds. Returns TRUE if it is, FALSE if it isn't.
/datum/component/stationloving/proc/atom_in_bounds(atom/atom_to_check)
	// Typecache of shuttles that we allow the disk to stay on
	var/static/list/allowed_shuttles = typecacheof(list(
		/area/shuttle/syndicate,
		/area/shuttle/escape,
		/area/shuttle/pod_1,
		/area/shuttle/pod_2,
		/area/shuttle/pod_3,
		/area/shuttle/pod_4,
	))
	// Typecache of areas on the centcom Z-level that we allow the disk to stay on
	var/static/list/disallowed_centcom_areas = typecacheof(list(
		/area/centcom/abductor_ship,
		/area/awaymission/errorroom,
	))

	// Our loc is a secluded location = not in bounds
	if (atom_to_check.loc && HAS_TRAIT(atom_to_check.loc, TRAIT_SECLUDED_LOCATION))
		return FALSE
	// No turf below us = nullspace = not in bounds
	var/turf/destination_turf = get_turf(atom_to_check)
	if (!destination_turf)
		return FALSE
	if (is_station_level(destination_turf.z))
		return TRUE
	if(atom_to_check.onSyndieBase())
		return TRUE

	var/area/destination_area = destination_turf.loc
	if (is_centcom_level(destination_turf.z))
		if (is_type_in_typecache(destination_area, disallowed_centcom_areas))
			return FALSE
		return TRUE
	if (is_reserved_level(destination_turf.z))
		if (is_type_in_typecache(destination_area, allowed_shuttles))
			return TRUE

	return FALSE

/// Signal handler for before the parent is qdel'd. Can prevent the parent from being deleted where allow_item_destruction is FALSE and force is FALSE.
/datum/component/stationloving/proc/on_parent_pre_qdeleted(datum/source, force)
	SIGNAL_HANDLER

	var/turf/current_turf = get_turf(parent)

	if(force && inform_admins)
		message_admins("[parent] has been !!force deleted!! in [ADMIN_VERBOSEJMP(current_turf)].")
		log_game("[parent] has been !!force deleted!! in [loc_name(current_turf)].")

	if(force || allow_item_destruction)
		return FALSE

	var/turf/new_turf = relocate()
	log_game("[parent] has been destroyed in [loc_name(current_turf)]. \
		Preventing destruction and moving it to [loc_name(new_turf)].")
	if(inform_admins)
		message_admins("[parent] has been destroyed in [ADMIN_VERBOSEJMP(current_turf)]. \
			Preventing destruction and moving it to [ADMIN_VERBOSEJMP(new_turf)].")
	return TRUE
