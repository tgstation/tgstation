/datum/component/stationloving
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	var/inform_admins = FALSE
	var/disallow_soul_imbue = TRUE

/datum/component/stationloving/Initialize(inform_admins = FALSE)
	if(!ismovableatom(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(list(COMSIG_MOVABLE_Z_CHANGED), .proc/check_in_bounds)
	RegisterSignal(list(COMSIG_PARENT_PREQDELETED), .proc/check_deletion)
	RegisterSignal(list(COMSIG_ITEM_IMBUE_SOUL), .proc/check_soul_imbue)
	src.inform_admins = inform_admins
	check_in_bounds() // Just in case something is being created outside of station/centcom

/datum/component/stationloving/InheritComponent(datum/component/stationloving/newc, original, list/arguments)
	if (original)
		if (istype(newc))
			inform_admins = newc.inform_admins
		else if (LAZYLEN(arguments))
			inform_admins = arguments[1]

/datum/component/stationloving/proc/relocate()
	var/targetturf = find_safe_turf()
	if(!targetturf)
		if(GLOB.blobstart.len > 0)
			targetturf = get_turf(pick(GLOB.blobstart))
		else
			CRASH("Unable to find a blobstart landmark")

	var/atom/movable/AM = parent
	if(ismob(AM.loc))
		var/mob/M = AM.loc
		M.transferItemToLoc(AM, targetturf, TRUE)	//nodrops disks when?
	else if(AM.loc.SendSignal(COMSIG_CONTAINS_STORAGE))
		AM.loc.SendSignal(COMSIG_TRY_STORAGE_TAKE, src, targetturf, TRUE)
	else
		AM.forceMove(targetturf)
	// move the disc, so ghosts remain orbiting it even if it's "destroyed"
	return targetturf

/datum/component/stationloving/proc/check_in_bounds()
	if(in_bounds())
		return
	else
		var/turf/currentturf = get_turf(src)
		to_chat(get(parent, /mob), "<span class='danger'>You can't help but feel that you just lost something back there...</span>")
		var/turf/targetturf = relocate()
		log_game("[parent] has been moved out of bounds in [COORD(currentturf)]. Moving it to [COORD(targetturf)].")
		if(inform_admins)
			message_admins("[parent] has been moved out of bounds in [ADMIN_COORDJMP(currentturf)]. Moving it to [ADMIN_COORDJMP(targetturf)].")

/datum/component/stationloving/proc/check_soul_imbue()
	return disallow_soul_imbue

/datum/component/stationloving/proc/in_bounds()
	var/static/list/allowed_shuttles = typecacheof(list(/area/shuttle/syndicate, /area/shuttle/escape, /area/shuttle/pod_1, /area/shuttle/pod_2, /area/shuttle/pod_3, /area/shuttle/pod_4))
	var/turf/T = get_turf(parent)
	if (!T)
		return FALSE
	if (is_station_level(T.z) || is_centcom_level(T.z))
		return TRUE
	if (is_transit_level(T.z))
		var/area/A = T.loc
		if (is_type_in_typecache(A, allowed_shuttles))
			return TRUE

	return FALSE

/datum/component/stationloving/proc/check_deletion(force) // TRUE = interrupt deletion, FALSE = proceed with deletion

	var/turf/T = get_turf(parent)

	if(inform_admins && force)
		message_admins("[parent] has been !!force deleted!! in [ADMIN_COORDJMP(T)].")
		log_game("[parent] has been !!force deleted!! in [COORD(T)].")

	if(!force)
		var/turf/targetturf = relocate()
		log_game("[parent] has been destroyed in [COORD(T)]. Moving it to [COORD(targetturf)].")
		if(inform_admins)
			message_admins("[parent] has been destroyed in [ADMIN_COORDJMP(T)]. Moving it to [ADMIN_COORDJMP(targetturf)].")
		return TRUE
	return FALSE
