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
	var/list/possible_pack_types = list() ///List of possible supply packs dropped in the pod, if empty picks from the cargo list
	var/static/list/stray_spawnable_supply_packs = list() ///List of default spawnable supply packs, filtered from the cargo list

/datum/round_event/stray_cargo/announce(fake)
	priority_announce("Stray cargo pod detected on long-range scanners. Expected location of impact: [impact_area.name].", "Collision Alert")

/**
* Tries to find a valid area, throws an error if none are found
* Also randomizes the start timer
*/
/datum/round_event/stray_cargo/setup()
	startWhen = rand(20, 40)
	impact_area = find_event_area()
	if(!impact_area)
		CRASH("No valid areas for cargo pod found.")
	var/list/turf_test = get_area_turfs(impact_area)
	if(!turf_test.len)
		CRASH("Stray Cargo Pod : No valid turfs found for [impact_area] - [impact_area.type]")

	if(!stray_spawnable_supply_packs.len)
		stray_spawnable_supply_packs = SSshuttle.supply_packs.Copy()
		for(var/pack in stray_spawnable_supply_packs)
			var/datum/supply_pack/pack_type = pack
			if(initial(pack_type.special))
				stray_spawnable_supply_packs -= pack

///Spawns a random supply pack, puts it in a pod, and spawns it on a random tile of the selected area
/datum/round_event/stray_cargo/start()
	var/turf/LZ = pick(get_area_turfs(impact_area))
	var/pack_type
	if(possible_pack_types.len)
		pack_type = pick(possible_pack_types)
	else
		pack_type = pick(stray_spawnable_supply_packs)
	var/datum/supply_pack/SP = new pack_type
	var/obj/structure/closet/crate/C = SP.generate(null)
	C.locked = FALSE //Unlock secure crates
	C.update_icon()
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

///A rare variant that drops a crate containing syndicate uplink items
/datum/round_event_control/stray_cargo/syndicate
	name = "Stray Syndicate Cargo Pod"
	typepath = /datum/round_event/stray_cargo/syndicate
	weight = 6
	max_occurrences = 1
	earliest_start = 30 MINUTES

/datum/round_event/stray_cargo/syndicate
	possible_pack_types = list(/datum/supply_pack/misc/syndicate)
