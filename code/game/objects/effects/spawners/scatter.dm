///This spawner scatters the spawned stuff around where it is placed.
/obj/effect/spawner/scatter
	///determines how many things to scatter
	var/max_spawns = 3
	///determines how big of a range we should scatter things in.
	var/radius = 2
	///This weighted list acts as the loot table for the spawner
	var/list/loot_table

/obj/effect/spawner/scatter/Initialize()
	..()
	if(!length(loot_table))
		return INITIALIZE_HINT_QDEL

	var/list/candidate_locations = list()

	for(var/turf/turf_in_view in oview(radius, get_turf(src)))
		if(!turf_in_view.density)

			candidate_locations += turf_in_view

	if(!candidate_locations.len)
		return INITIALIZE_HINT_QDEL

	var/loot_spawned = 0
	while((max_spawns-loot_spawned) && candidate_locations.len)
		var/spawned_thing = pickweight(loot_table)
		while(islist(spawned_thing))
			spawned_thing = pickweight(spawned_thing)
		new spawned_thing(pick_n_take(candidate_locations))
		loot_spawned++

	return INITIALIZE_HINT_QDEL

///This spawner will scatter garbage around a dirty site.
/obj/effect/spawner/scatter/grime
	name = "trash and grime scatterer"
	max_spawns = 5
	loot_table = list(/obj/effect/spawner/lootdrop/garbage_spawner = 30,
					/mob/living/basic/cockroach = 25,
					/obj/effect/decal/cleanable/garbage = 20,
					/obj/effect/decal/cleanable/vomit/old = 15,
					/obj/effect/spawner/lootdrop/cigbutt = 10)

///This spawner will scatter water related items around a moist site.
/obj/effect/spawner/scatter/moisture
	max_spawns = 2
	radius = 1
	loot_table = list(/obj/item/clothing/head/cone = 35,
					/obj/item/clothing/suit/caution = 15,
					/mob/living/simple_animal/hostile/retaliate/frog = 10,
					/obj/item/reagent_containers/glass/rag = 10,
					/obj/item/reagent_containers/glass/bucket = 10,
					/obj/effect/decal/cleanable/blood/old = 10,
					/obj/structure/mopbucket = 10)
