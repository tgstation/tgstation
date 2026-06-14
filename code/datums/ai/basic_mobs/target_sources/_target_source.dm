/// Singleton datum that defines how an acquire_target behavior gathers candidates.
/// Subtype collect_candidates() to change what atoms are considered.
/// Subtype with a typecache var to pre-filter by type before targeting_strategy validation.
/datum/target_source

/// Returns a list of candidate atoms for the behavior to filter and select from.
/datum/target_source/proc/collect_candidates(mob/living/pawn, datum/ai_controller/controller, range)
	return list()

/// Gathers nearby atoms via oview(). No type pre-filtering.
/datum/target_source/oview

/datum/target_source/oview/collect_candidates(mob/living/pawn, datum/ai_controller/controller, range)
	return oview(range, pawn)

/// Gathers nearby atoms via oview(), pre-filtered by a typecache
/datum/target_source/oview_typed
	/// Optional typecache for pre-filtering candidates; null means no type pre-filter.
	var/list/typecache

/datum/target_source/oview_typed/collect_candidates(mob/living/pawn, datum/ai_controller/controller, range)
	if(isnull(typecache))
		CRASH("[pawn] using [controller] ran [src] with no typecache.")
	return typecache_filter_list(oview(range, pawn), typecache)

/// Gathers nearby atoms via oview(), pre-filtered by a typecache stored in a blackboard key.
/// Use this when the typecache varies per mob species (e.g. BB_BASIC_FOODS).
/datum/target_source/oview_typed/from_bb_key
	/// Blackboard key whose value is the typecache list to filter by.
	var/typecache_key

/datum/target_source/oview_typed/from_bb_key/collect_candidates(mob/living/pawn, datum/ai_controller/controller, range)
	var/list/bb_typecache = controller.blackboard[typecache_key]
	if(isnull(bb_typecache))
		return oview(range, pawn)
	return typecache_filter_list(oview(range, pawn), bb_typecache)

/// Gathers nearby atoms via hearers() plus any hostile machines on the same z-level.
/// This is the enemy-scanning source used by update_targets.
/datum/target_source/hearers

/datum/target_source/hearers/collect_candidates(mob/living/pawn, datum/ai_controller/controller, range)
	var/list/candidates = hearers(range, get_turf(pawn)) - pawn
	var/turf/mob_turf = get_turf(pawn)
	if(mob_turf?.z)
		for(var/atom/hostile_machine as anything in GLOB.hostile_machines_by_z[mob_turf.z])
			if(can_see(pawn, hostile_machine, range))
				candidates += hostile_machine
	return candidates

/// Gathers turfs in range via RANGE_TURFS().
/datum/target_source/range_turfs

/datum/target_source/range_turfs/collect_candidates(mob/living/pawn, datum/ai_controller/controller, range)
	return RANGE_TURFS(range, pawn)

/// Gathers items currently held in the pawn's hands.
/datum/target_source/held_items

/datum/target_source/held_items/collect_candidates(mob/living/pawn, datum/ai_controller/controller, range)
	return pawn.held_items?.Copy() || list()

/// Reads a typecache from BB_BASIC_FOODS and filters oview candidates by it.
/// For mobs whose food list varies by species (set in Initialize via set_blackboard_key).
/datum/target_source/oview_typed/from_bb_key/basic_foods
	typecache_key = BB_BASIC_FOODS

/// Reads candidates directly from a blackboard list. No spatial filtering; range is ignored.
/datum/target_source/from_bb_list
	var/list_key

/datum/target_source/from_bb_list/collect_candidates(mob/living/pawn, datum/ai_controller/controller, range)
	return controller.blackboard[list_key]?.Copy() || list()

/// Reads from BB_BASIC_MOB_RETALIATE_LIST.
/datum/target_source/from_bb_list/retaliate_list
	list_key = BB_BASIC_MOB_RETALIATE_LIST
