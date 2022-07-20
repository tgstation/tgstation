/// Teleports the movable atom back to a safe turf on the station if it leaves the z-level or becomes inaccessible.
/datum/component/stationloving
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	/// If TRUE, notifies admins when parent is teleported back to the station.
	var/inform_admins = FALSE
	var/disallow_soul_imbue = TRUE
	/// If FALSE, prevents parent from being qdel'd unless it's a force = TRUE qdel.
	var/allow_item_destruction = FALSE

/datum/component/stationloving/Initialize(inform_admins = FALSE, allow_item_destruction = FALSE)
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_MOVABLE_Z_CHANGED, .proc/on_parent_z_change)
	RegisterSignal(parent, COMSIG_MOVABLE_SECLUDED_LOCATION, .proc/on_parent_unreachable)
	RegisterSignal(parent, COMSIG_PARENT_PREQDELETED, .proc/on_parent_pre_qdeleted)
	RegisterSignal(parent, COMSIG_ITEM_IMBUE_SOUL, .proc/check_soul_imbue)
	RegisterSignal(parent, COMSIG_ITEM_MARK_RETRIEVAL, .proc/check_mark_retrieval)
	src.inform_admins = inform_admins
	src.allow_item_destruction = allow_item_destruction

	// Just in case something is being created outside of station/centcom
	if(!atom_in_bounds(parent))
		relocate()

/datum/component/stationloving/InheritComponent(datum/component/stationloving/newc, original, inform_admins, allow_death)
	if (original)
		if (newc)
			inform_admins = newc.inform_admins
			allow_death = newc.allow_item_destruction
		else
			inform_admins = inform_admins

/// Teleports parent to a safe turf on the station z-level.
/datum/component/stationloving/proc/relocate()
	var/target_turf = find_safe_turf()

	if(!target_turf)
		if(GLOB.blobstart.len > 0)
			target_turf = get_turf(pick(GLOB.blobstart))
		else
			CRASH("Unable to find a blobstart landmark")

	var/atom/movable/movable_parent = parent
	playsound(movable_parent, 'sound/machines/synth_no.ogg', 5, TRUE)
	movable_parent.forceMove(target_turf)
	to_chat(get(parent, /mob), span_danger("You can't help but feel that you just lost something back there..."))

	return target_turf

/// Signal handler when the parent has changed z-levels.
/// Checks to make sure it's a valid destination, if it's not then it relacates the parent instead.
/datum/component/stationloving/proc/on_parent_z_change(datum/source, turf/old_turf, turf/new_turf)
	SIGNAL_HANDLER

	if(atom_in_bounds(parent))
		return

	var/turf/current_turf = get_turf(parent)
	var/turf/new_destination = relocate()
	log_game("[parent] attempted to be moved out of bounds from [loc_name(old_turf)] to [loc_name(current_turf)]. Moving it to [loc_name(new_destination)].")
	if(inform_admins)
		message_admins("[parent] attempted to be moved out of bounds from [ADMIN_VERBOSEJMP(old_turf)] to [ADMIN_VERBOSEJMP(current_turf)]. Moving it to [ADMIN_VERBOSEJMP(new_destination)].")

	return COMPONENT_MOVABLE_BLOCK_PRE_MOVE

/datum/component/stationloving/proc/check_soul_imbue(datum/source)
	SIGNAL_HANDLER

	if(disallow_soul_imbue)
		return COMPONENT_BLOCK_IMBUE

/datum/component/stationloving/proc/check_mark_retrieval(datum/source)
	SIGNAL_HANDLER

	return COMPONENT_BLOCK_MARK_RETRIEVAL

/// Checks whether a given atom's turf is within bounds. Returns TRUE if it is, FALSE if it isn't.
/datum/component/stationloving/proc/atom_in_bounds(atom/atom_to_check)
	var/static/list/allowed_shuttles = typecacheof(list(/area/shuttle/syndicate, /area/shuttle/escape, /area/shuttle/pod_1, /area/shuttle/pod_2, /area/shuttle/pod_3, /area/shuttle/pod_4))
	var/static/list/disallowed_centcom_areas = typecacheof(list(/area/centcom/abductor_ship, /area/awaymission/errorroom))
	var/turf/destination_turf = get_turf(atom_to_check)
	if (!destination_turf)
		return FALSE
	var/area/destination_area = destination_turf.loc
	if (is_station_level(destination_turf.z))
		return TRUE
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

	if(inform_admins && force)
		message_admins("[parent] has been !!force deleted!! in [ADMIN_VERBOSEJMP(current_turf)].")
		log_game("[parent] has been !!force deleted!! in [loc_name(current_turf)].")

	if(force || allow_item_destruction)
		UnregisterSignal(parent, list(COMSIG_MOVABLE_PRE_MOVE, COMSIG_MOVABLE_SECLUDED_LOCATION))
		return FALSE

	var/turf/new_turf = relocate()
	log_game("[parent] has been destroyed in [loc_name(current_turf)]. Preventing destruction and moving it to [loc_name(new_turf)].")
	if(inform_admins)
		message_admins("[parent] has been destroyed in [ADMIN_VERBOSEJMP(current_turf)]. Preventing destruction and moving it to [ADMIN_VERBOSEJMP(new_turf)].")
	return TRUE

/// Signal handler for when the parent enters an unreachable location. Always relocates the parent.
/datum/component/stationloving/proc/on_parent_unreachable()
	SIGNAL_HANDLER

	var/turf/current_turf = get_turf(parent)
	var/turf/new_turf = relocate()
	log_game("[parent] has been moved to unreachable location in [loc_name(current_turf)]. Moving it to [loc_name(new_turf)].")
	if(inform_admins)
		message_admins("[parent] has been moved to unreachable location in [ADMIN_VERBOSEJMP(current_turf)]. Moving it to [ADMIN_VERBOSEJMP(new_turf)].")

	return COMPONENT_MOVABLE_BLOCK_PRE_MOVE
