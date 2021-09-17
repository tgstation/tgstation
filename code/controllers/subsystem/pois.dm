/// Used to specify which POI list has changed when POIs get added or removed from the mob list.
#define POI_MOBS 1
/// Used to specify which POI list has changed when POIs get added or removed from the other list.
#define POI_OTHER 2

/// Subsystem for managing valid POIs that can be orbitted.
SUBSYSTEM_DEF(pois)
	name = "POIs"

	flags = SS_NO_FIRE
	init_order = INIT_ORDER_POINTS_OF_INTEREST

	/// List of mobs that automatically qualify as potential POIs or have the point_of_interest element.
	var/list/mob_points_of_interest = list()
	/// List of everything else that has the point_of_interest element but is not a mob.
	var/list/other_points_of_interest = list()
	/// List of /mob/dead/new_players.
	var/list/lobby_points_of_interest = list()

/datum/controller/subsystem/pois/Initialize()
	RegisterSignal(SSdcs, COMSIG_GLOB_MOB_CREATED, .proc/on_glob_mob_created)
	RegisterSignal(SSdcs, COMSIG_GLOB_POI_ELEMENT_ADDED, .proc/on_glob_poi_created)
	RegisterSignal(SSdcs, COMSIG_GLOB_POI_ELEMENT_REMOVED, .proc/on_glob_poi_removed)
	RegisterSignal(SSdcs, COMSIG_GLOB_MOB_GAIN_STEALTHMIN, .proc/on_glob_stealthmin_gained)
	RegisterSignal(SSdcs, COMSIG_GLOB_MOB_LOSE_STEALTHMIN, .proc/on_glob_stealthmin_lost)
	return ..()

/// Adds mob_poi to the mob POI list and registers key signals if necessary.
/datum/controller/subsystem/pois/proc/add_mob_poi(mob/new_poi)
	// Skip stealthed admins, check when they stop being stealthmin.
	if(new_poi.client?.holder?.fakekey)
		return

	RegisterSignal(new_poi, COMSIG_PARENT_QDELETING, .proc/on_mob_qdel)

	if(isnewplayer(new_poi))
		lobby_points_of_interest += new_poi
	else
		mob_points_of_interest += new_poi

	on_pois_changed(POI_MOBS)

/// Remove old_poi from the mob POI list and unregister signals.
/datum/controller/subsystem/pois/proc/del_mob_poi(mob/old_poi)
	UnregisterSignal(old_poi, COMSIG_PARENT_QDELETING)

	if(isnewplayer(old_poi))
		lobby_points_of_interest -= old_poi
	else
		mob_points_of_interest -= old_poi

	on_pois_changed(POI_MOBS)

/// Adds new_poi to the other POI list and registers key signals if necessary.
/datum/controller/subsystem/pois/proc/add_other_poi(atom/new_poi)
	RegisterSignal(new_poi, COMSIG_PARENT_QDELETING, .proc/on_other_qdel)
	other_points_of_interest += new_poi
	on_pois_changed(POI_OTHER)

/// Remove old_poi from the other POI list and unregister signals.
/datum/controller/subsystem/pois/proc/del_other_poi(atom/old_poi)
	UnregisterSignal(old_poi, COMSIG_PARENT_QDELETING)
	other_points_of_interest -= old_poi
	on_pois_changed(POI_OTHER)

/// Signal handler for when mobs are created.
/datum/controller/subsystem/pois/proc/on_glob_mob_created(datum/source, mob/created_mob)
	SIGNAL_HANDLER
	add_mob_poi(created_mob)

/// Signal handler for when mobs who we consider POIs get deleted.
/datum/controller/subsystem/pois/proc/on_mob_qdel(datum/deleted_mob, force)
	SIGNAL_HANDLER
	del_mob_poi(deleted_mob)

/// Signal handler for when non-mob POIs have been deleted.
/datum/controller/subsystem/pois/proc/on_other_qdel(datum/deleted_poi, force)
	SIGNAL_HANDLER
	del_other_poi(deleted_poi)

/// Signal handler for when the POI element gets attached to something.
/datum/controller/subsystem/pois/proc/on_glob_poi_created(datum/source, atom/new_poi)
	SIGNAL_HANDLER

	if(ismob(new_poi))
		add_mob_poi(new_poi)
		return

	add_other_poi(new_poi)

/// Signal handler for when the POI element gets removed from something
/datum/controller/subsystem/pois/proc/on_glob_poi_removed(datum/source, atom/former_poi)
	SIGNAL_HANDLER
	if(ismob(former_poi))
		del_mob_poi(former_poi)
		return

	del_other_poi(former_poi)

/// Signal handler for when new stealthmin created. Removes them as a mob POI.
/datum/controller/subsystem/pois/proc/on_glob_stealthmin_gained(datum/source, mob/new_stealthmin)
	SIGNAL_HANDLER

	del_mob_poi(new_stealthmin)

/// Signal handler for when stealthmin ends, re-adds them as a mob POI.
/datum/controller/subsystem/pois/proc/on_glob_stealthmin_lost(datum/source, mob/former_stealthmin)
	SIGNAL_HANDLER

	add_mob_poi(former_stealthmin)

/// Send a signal to indicate that this SS's POI lists have changed. Listeners can then update.
/datum/controller/subsystem/pois/proc/on_pois_changed(var/poi_type)
	switch(poi_type)
		if(POI_MOBS)
			SEND_SIGNAL(src, COMSIG_MOB_POIS_CHANGED)
			return
		if(POI_OTHER)
			SEND_SIGNAL(src, COMSIG_OTHER_POIS_CHANGED)
			return

/**
 * Returns a list of all POIs with names as keys and pois as values.
 *
 * Arguments:
 * * mobs_only - If TRUE, returns only mob POIs.
 * * skip_mindless - If TRUE, Skips mob POIs without minds and ckeys except bots, cameras and megafauna.
 * * specify_dead_role - If TRUE, appends whether the POI is dead or a ghost as part of the POI's name.
 * * include_lobby - If TRUE, includes /mob/living/new_player as a POI.
 */
/datum/controller/subsystem/pois/proc/get_pois(mobs_only = FALSE, skip_mindless = FALSE, specify_dead_role = TRUE, include_lobby = FALSE)
	var/list/mobs = sortmobs(mob_points_of_interest)
	var/list/namecounts = list()
	var/list/pois = list()

	for(var/mob/mob_poi as anything in mobs)
		// People at the lobby are never POIs.
		if(isnewplayer(mob_poi))
			stack_trace("/mob/dead/new_player \[[mob_poi]\] POI somehow made its way into the mob POI list. This is bad and it has been removed.")
			del_mob_poi(mob_poi)
			continue

		// Stealthmins are never POIs.
		if(mob_poi.client?.holder?.fakekey)
			stack_trace("Stealthmin \[[mob_poi]\] POI somehow made its way into the mob POI list. This is bad and it has been removed.")
			del_mob_poi(mob_poi)
			continue

		if(skip_mindless && (!mob_poi.mind && !mob_poi.ckey))
			if(!isbot(mob_poi) && !iscameramob(mob_poi) && !ismegafauna(mob_poi))
				continue

		var/name = avoid_assoc_duplicate_keys(mob_poi.name, namecounts) + mob_poi.get_realname_string()

		if(mob_poi.stat == DEAD && specify_dead_role)
			if(isobserver(mob_poi))
				name += " \[ghost\]"
			else
				name += " \[dead\]"
		pois[name] = mob_poi

	if(!mobs_only)
		for(var/atom/other_poi as anything in other_points_of_interest)
			if(!other_poi || !other_poi.loc)
				stack_trace("Null or nullspaced POI \[[other_poi]\] somehow made its way into the mob POI list. This is bad and it has been removed.")
				del_other_poi(other_poi)
				continue
			pois[avoid_assoc_duplicate_keys(other_poi.name, namecounts)] = other_poi

	return pois

#undef POI_MOBS
#undef POI_OTHER
