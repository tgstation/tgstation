/turf/open/floor/lowered/iron/pool
	name = "pool floor"
	floor_tile = /obj/item/stack/tile/lowered/iron/pool
	icon = 'monkestation/icons/turf/pool_tile.dmi'
	base_icon_state = "pool_tile"
	icon_state = "pool_tile"
	smoothing_flags = NONE
	liquid_height = -30
	turf_height = -30

	///the id we use to get the connected blob of connected objects
	var/merger_id = "pool_floors"
	///the typecache of merging
	var/static/list/merger_typecache
	///our cached liquid group
	var/datum/liquid_group/pool_group/cached_group

/turf/open/floor/lowered/iron/pool/Initialize(mapload)
	. = ..()
	if(!merger_typecache)
		merger_typecache = typecacheof(/turf/open/floor/lowered/iron/pool)

	return INITIALIZE_HINT_LATELOAD

/turf/open/floor/lowered/iron/pool/LateInitialize()
	. = ..()
	GetMergeGroup(merger_id, merger_typecache)


/turf/open/floor/lowered/iron/pool/proc/start_fill(list/reagent_list, temperature = 300)
	if(!cached_group)
		var/datum/liquid_group/pool_group/pool_group = new
		src.liquids = new(src, pool_group)
		pool_group.add_reagents(src.liquids, reagent_list, temperature)
		src.liquids.liquid_group = pool_group
		pool_group.check_edges(src)
		cached_group = pool_group

	var/datum/merger/merge_group = GetMergeGroup(merger_id, merger_typecache)
	for(var/turf/open/floor/lowered/iron/pool/listed_pool as anything in merge_group.members)
		cached_group.merger_turfs += listed_pool
		listed_pool.cached_group = cached_group


/turf/open/floor/lowered/iron/pool/proc/debug_pool_startup()
	start_fill(list(/datum/reagent/water = 300), 300)
