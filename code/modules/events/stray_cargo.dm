///Spawns a cargo pod containing a random cargo supply pack on a random area of the station
/datum/round_event_control/stray_cargo
	name = "Stray Cargo Pod"
	typepath = /datum/round_event/stray_cargo
	weight = 20
	max_occurrences = 4
	earliest_start = 10 MINUTES

///Spawns a cargo pod containing a random cargo supply pack on a random area of the station
/datum/round_event/stray_cargo
	var/area/impact_area ///Randomly picked area
	announceChance = 75
	announceWhen

/datum/round_event/stray_cargo/announce(fake)
	priority_announce("Stray cargo pod detected on long-range scanners. Expected location of impact: [impact_area.name].", "Collision Alert")

/**
* Tries to find a valid area, throws an error if none are found
* Also randomizes the start timer
*/
/datum/round_event/stray_cargo/setup()
	startWhen = rand(20, 40)
	impact_area = findEventArea()
	if(!impact_area)
		CRASH("No valid areas for cargo pod found.")
	var/list/turf_test = get_area_turfs(impact_area)
	if(!turf_test.len)
		CRASH("Stray Cargo Pod : No valid turfs found for [impact_area] - [impact_area.type]")

///Spawns a random supply pack, puts it in a pod, and spawns it on a random tile of the selected area
/datum/round_event/stray_cargo/start()
	var/turf/LZ = pick(get_area_turfs(impact_area))
	var/datum/supply_pack/SP = pick(SSshuttle.supply_packs)
	var/obj/structure/closet/crate/C = SP.generate(null)
	new /obj/effect/DPtarget(LZ, /obj/structure/closet/supplypod, C)

///Picks an area that wouldn't risk critical damage if hit by a pod explosion
/datum/round_event/stray_cargo/proc/find_event_area()
	var/static/list/allowed_areas
	if(!allowed_areas)
		///Places that shouldn't explode
		var/list/safe_area_types = typecacheof(list(
		/area/ai_monitored/turret_protected/ai,
		/area/ai_monitored/turret_protected/ai_upload,
		/area/engine,
		/area/shuttle)
		)

		///Subtypes from the above that actually should explode.
		var/list/unsafe_area_subtypes = typecacheof(list(/area/engine/break_room))
		allowed_areas = make_associative(GLOB.the_station_areas) - safe_area_types + unsafe_area_subtypes
	var/list/possible_areas = typecache_filter_list(GLOB.sortedAreas,allowed_areas)
	if (length(possible_areas))
		return pick(possible_areas)
