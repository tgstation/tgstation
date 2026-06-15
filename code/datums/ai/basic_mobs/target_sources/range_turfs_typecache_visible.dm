/// Gathers visible turfs in range matching a typecache. Shuffled for variety.
/datum/target_source/range_turfs/typecache_visible
	var/list/typecache

/datum/target_source/range_turfs/typecache_visible/collect_candidates(mob/living/pawn, datum/ai_controller/controller, range)
	var/list/found = RANGE_TURFS(range, pawn)
	var/list/valid = list()
	for(var/turf/candidate as anything in found)
		if(!is_type_in_typecache(candidate, typecache))
			continue
		if(can_see(pawn, candidate, range))
			valid += candidate
	if(valid.len)
		valid = reverse_range(valid)
	return valid

/datum/target_source/range_turfs/typecache_visible/deer_grass
	typecache = list(/turf/open/floor/grass, /turf/open/misc/grass)

/datum/target_source/range_turfs/typecache_visible/deer_grass/New()
	. = ..()
	typecache = typecacheof(typecache)

/datum/target_source/range_turfs/typecache_visible/deer_water
	typecache = list(/turf/open/water)

/datum/target_source/range_turfs/typecache_visible/deer_water/New()
	. = ..()
	typecache = typecacheof(typecache)
