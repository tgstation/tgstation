/// Subsystem for managing all POIs.
SUBSYSTEM_DEF(points_of_interest)
	name = "Points of Interest"

	flags = SS_NO_FIRE | SS_NO_INIT

	/// List of mob POIs. This list is automatically sorted.
	var/list/datum/point_of_interest/mob_poi/mob_points_of_interest = list()
	/// List of non-mob POIs. This list is automatically sorted.
	var/list/datum/point_of_interest/other_points_of_interest = list()
	/// List of all value:POI datums by their key:target refs.
	var/list/datum/point_of_interest/points_of_interest_by_target_ref = list()

	/// Special helper list of all real nuke disks.
	var/list/obj/item/disk/nuclear/real_nuclear_disks = list()

	/// Special helper list to track any Nar'sies.
	var/list/obj/narsie/narsies = list()

/**
 * Turns new_poi into a new point of interest by adding the /datum/element/point_of_interest element to it.
 */
/datum/controller/subsystem/points_of_interest/proc/make_point_of_interest(atom/new_poi)
	new_poi.AddElement(/datum/element/point_of_interest)

/**
 * Stops old_poi from being a point of interest by removing the /datum/element/point_of_interest element from it.
 */
/datum/controller/subsystem/points_of_interest/proc/remove_point_of_interest(atom/old_poi)
	old_poi.RemoveElement(/datum/element/point_of_interest)

/**
 * Called by [/datum/element/point_of_interest] when it gets removed from old_poi.
 */
/datum/controller/subsystem/points_of_interest/proc/on_poi_element_added(atom/new_poi)
	var/datum/point_of_interest/new_poi_datum
	if(ismob(new_poi))
		new_poi_datum = new /datum/point_of_interest/mob_poi(new_poi)
		BINARY_INSERT_PROC_COMPARE(new_poi_datum, mob_points_of_interest, /datum/point_of_interest/mob_poi, new_poi_datum, compare_to, COMPARE_KEY)
		points_of_interest_by_target_ref[REF(new_poi)] = new_poi_datum
	else
		new_poi_datum = new /datum/point_of_interest(new_poi)
		BINARY_INSERT_PROC_COMPARE(new_poi_datum, other_points_of_interest, /datum/point_of_interest, new_poi_datum, compare_to, COMPARE_KEY)
		points_of_interest_by_target_ref[REF(new_poi)] = new_poi_datum

		// NUKE DISK HELPER
		if(istype(new_poi, /obj/item/disk/nuclear))
			var/obj/item/disk/nuclear/nuke_disk = new_poi
			if(!nuke_disk.fake)
				real_nuclear_disks += nuke_disk
		// NAR'SIE HELPER
		else if(istype(new_poi, /obj/narsie))
			narsies += new_poi

	SEND_SIGNAL(src, COMSIG_ADDED_POINT_OF_INTEREST, new_poi)

/**
 * Called by [/datum/element/point_of_interest] when it gets removed from old_poi.
 */
/datum/controller/subsystem/points_of_interest/proc/on_poi_element_removed(atom/old_poi)
	var/poi_ref = REF(old_poi)
	var/datum/point_of_interest/poi_to_remove = points_of_interest_by_target_ref[poi_ref]

	if(!poi_to_remove)
		return

	if(ismob(old_poi))
		mob_points_of_interest -= poi_to_remove
	else
		other_points_of_interest -= poi_to_remove

		// NUKE DISK HELPER
		if(istype(old_poi, /obj/item/disk/nuclear))
			var/obj/item/disk/nuclear/nuke_disk = old_poi
			if(!nuke_disk.fake)
				real_nuclear_disks -= nuke_disk
		// NAR'SIE HELPER
		else if(istype(old_poi, /obj/narsie))
			narsies -= old_poi

	points_of_interest_by_target_ref -= poi_ref

	poi_to_remove.target = null

	SEND_SIGNAL(src, COMSIG_REMOVED_POINT_OF_INTEREST, old_poi)

/**
 * If there is a valid POI for a given reference, it returns that POI's associated atom. Otherwise, it returns null.
 */
/datum/controller/subsystem/points_of_interest/proc/get_poi_atom_by_ref(reference)
	return points_of_interest_by_target_ref[reference]?.target

/**
 * Returns a list of mob POIs with names as keys and mobs as values.
 *
 * If multiple POIs have the same name, then avoid_assoc_duplicate_keys is used alongside used_name_list to
 * tag them as Mob Name (1), Mob Name (2), Mob Name (3) etc.
 *
 * Arguments:
 * * poi_validation_override - [OPTIONAL] Callback to a proc that takes a single argument for the POI and returns TRUE if this POI should be included. Overrides standard POI validation.
 * * append_dead_role - [OPTIONAL] If TRUE, adds a ghost tag to the end of observer names and a dead tag to the end of any other mob which is not alive.
 */
/datum/controller/subsystem/points_of_interest/proc/get_mob_pois(datum/callback/poi_validation_override = null, append_dead_role = TRUE)
	var/list/pois = list()
	var/list/used_name_list = list()

	for(var/datum/point_of_interest/mob_poi/mob_poi as anything in mob_points_of_interest)
		if(poi_validation_override)
			if(!poi_validation_override.Invoke(mob_poi))
				continue
		else if(!mob_poi.validate())
			continue

		var/mob/target_mob = mob_poi.target
		var/name = avoid_assoc_duplicate_keys(target_mob.name, used_name_list) + target_mob.get_realname_string()

		// Add the ghost/dead tag to the end of dead mob POIs.
		if(append_dead_role && target_mob.stat == DEAD)
			if(isobserver(target_mob))
				name += " \[ghost\]"
			else
				name += " \[dead\]"

		pois[name] = target_mob

	return pois

/**
 * Returns a list of non-mob POIs with names as keys and atoms as values.
 *
 * If multiple POIs have the same name, then avoid_assoc_duplicate_keys is used alongside used_name_list to
 * tag them as Object Name (1), Object Name (2), Object Name (3) etc.
 *
 * Arguments:
 * * poi_validation_override - [OPTIONAL] Callback to a proc that takes a single argument for the POI and returns TRUE if this POI should be included. Overrides standard POI validation.
 */
/datum/controller/subsystem/points_of_interest/proc/get_other_pois(datum/callback/poi_validation_override = null)
	var/list/pois = list()
	var/list/used_name_list = list()

	for(var/datum/point_of_interest/other_poi as anything in other_points_of_interest)
		if(poi_validation_override)
			if(!poi_validation_override.Invoke(other_poi))
				continue
		else if(!other_poi.validate())
			continue

		var/atom/target_poi = other_poi.target

		pois[avoid_assoc_duplicate_keys(target_poi.name, used_name_list)] = target_poi

	return pois

/// Returns TRUE if potential_poi has an associated poi_datum that validates.
/datum/controller/subsystem/points_of_interest/proc/is_valid_poi(atom/potential_poi, datum/callback/poi_validation_override = null)
	var/datum/point_of_interest/poi_datum = points_of_interest_by_target_ref[REF(potential_poi)]

	if(!poi_datum)
		return FALSE

	if(poi_validation_override)
		return poi_validation_override.Invoke(poi_datum)

	return poi_datum.validate()

/// Simple helper datum for points of interest.
/datum/point_of_interest
	/// The specific point of interest this datum references. This won't hard del as the POI element will be removed from the target when it qdels, which will clear this reference.
	var/atom/target
	/// The type of POI this datum references.
	var/poi_type = /atom

/datum/point_of_interest/New(poi_target)
	if(!istype(poi_target, poi_type))
		CRASH("Incorrect target type provided to /datum/point_of_interest/New: Expected \[[poi_type]\]")

	target = poi_target

/// Validates the POI. Returns TRUE if the POI has valid state, returns FALSE if the POI has invalid state.
/datum/point_of_interest/proc/validate()
	// In nullspace, invalid as a POI.
	if(!target.loc)
		return FALSE

	return TRUE

/// Comparison proc used to sort POIs. Override to implement logic used doing binary sort insertions.
/datum/point_of_interest/proc/compare_to(datum/point_of_interest/rhs)
	return cmp_name_asc(target, rhs.target)

/datum/point_of_interest/mob_poi
	poi_type = /mob

/// Validation for mobs is expanded to invalidate stealthmins and /mob/dead/new_player as POIs.
/datum/point_of_interest/mob_poi/validate()
	. = ..()

	if(!.)
		return

	var/mob/poi_mob = target

	// Stealthmin, invalid as a POI.
	if(poi_mob.client?.holder?.fakekey)
		return FALSE

	// POI is a /mob/dead/new_player, players in the lobby are invalid as POIs.
	if(isnewplayer(poi_mob))
		return FALSE

	return TRUE

/// Mob POIs are sorted by a simple priority list depending on their type. When their type priority is identical, they're sub-sorted by name.
/datum/point_of_interest/mob_poi/compare_to(datum/point_of_interest/mob_poi/rhs)
	var/sort_difference = get_type_sort_priority() - rhs.get_type_sort_priority()

	// If they're equal in priority, call parent to sort by name.
	if(sort_difference == 0)
		return ..()
	// Else sort by priority.
	else
		return sort_difference

/// Priority list broadly stolen from /proc/sortmobs(). Lower numbers are higher priorities when sorted and appear closer to the top or start of lists.
/datum/point_of_interest/mob_poi/proc/get_type_sort_priority()
	if(isAI(target))
		return 0
	if(iscameramob(target))
		return 1
	if(ispAI(target))
		return 2
	if(iscyborg(target))
		return 3
	if(ishuman(target))
		return 4
	if(isbrain(target))
		return 5
	if(isalien(target))
		return 6
	if(isobserver(target))
		return 7
	if(isnewplayer(target))
		return 8
	if(isslime(target))
		return 9
	if(isanimal(target))
		return 10
	if(isbasicmob(target))
		return 11
	return 12
