#define PROB_MOUSE_SPAWN 98

SUBSYSTEM_DEF(minor_mapping)
	name = "Minor Mapping"
	init_order = INIT_ORDER_MINOR_MAPPING
	flags = SS_NO_FIRE

/datum/controller/subsystem/minor_mapping/Initialize(timeofday)
	trigger_migration(CONFIG_GET(number/mice_roundstart))
	place_satchels()
	place_pads()
	return ..()

/datum/controller/subsystem/minor_mapping/proc/trigger_migration(num_mice=10)
	var/list/exposed_wires = find_exposed_wires()

	var/mob/living/simple_animal/mouse/mouse
	var/turf/open/proposed_turf


	while((num_mice > 0) && exposed_wires.len)
		proposed_turf = pick_n_take(exposed_wires)

		if(!istype(proposed_turf))
			continue

		if(prob(PROB_MOUSE_SPAWN))
			if(!mouse)
				mouse = new(proposed_turf)
			else
				mouse.forceMove(proposed_turf)
		else
			mouse = new /mob/living/simple_animal/hostile/regalrat/controlled(proposed_turf)
		if(proposed_turf.air.has_gas(/datum/gas/oxygen, 5))
			num_mice -= 1
			mouse = null

/datum/controller/subsystem/minor_mapping/proc/place_satchels(amount=10)
	var/list/turfs = find_satchel_suitable_turfs()

	while(turfs.len && amount > 0)
		var/turf/T = pick_n_take(turfs)
		var/obj/item/storage/backpack/satchel/flat/F = new(T)

		SEND_SIGNAL(F, COMSIG_OBJ_HIDE, T.underfloor_accessibility < UNDERFLOOR_VISIBLE)
		amount--

/datum/controller/subsystem/minor_mapping/proc/place_pads(amount=5)
	var/list/turfs = find_pad_suitable_turfs()
	var/min_link_distance = 50 //we'll try to avoid creating pads closer together than this
	var/spawned_note = FALSE

	while(turfs.len && amount > 0) //while we have valid turfs to pick and have not placed enough pads
		var/list/unattractive_spawn_turfs = list() //we keep a list of target turfs we've rejected in case we can't find an ideal one
		var/turf/first_turf = pick_n_take(turfs) //pick a first turf and remove it from the list

		if(first_turf.HasDenseAnchoredAtoms()) //if it has a window or something above it we don't want it, but things like crates and lockers are fine
			continue

		if(!spawned_note)
			new /obj/item/paper/crumpled/fluff/stations/maintenancepad(first_turf)
			spawned_note = TRUE
			continue

		var/done = FALSE
		for (var/turf/second_turf in turfs) //go through the remaining turfs in the list to find a pair

			if(second_turf.HasDenseAnchoredAtoms())
				turfs -= second_turf //don't want to grab this for our first turf on accident
				continue

			var/distance_from_me = abs(get_dist_euclidian(first_turf,second_turf))
			if(distance_from_me > min_link_distance) //we got off easy
				var/obj/machinery/quantumpad/maintenance/first_pad = new(first_turf)
				first_pad.CreateAndLinkSecondPad(second_turf)
				turfs -= second_turf //don't want to accidentally grab this turf we've already used for our first turf
				done = TRUE
				amount--
				break

			unattractive_spawn_turfs[second_turf] = distance_from_me //turf isn't far enough away, add to list of potential backups

		if(!done && unattractive_spawn_turfs.len) //we didn't find an optimal turf, let's pick the best from what we did find
			sortTim(unattractive_spawn_turfs,cmp=/proc/cmp_numeric_dsc,associative=TRUE) //put furthest turf at top of list
			var/obj/machinery/quantumpad/maintenance/first_pad = new(first_turf)
			first_pad.CreateAndLinkSecondPad(unattractive_spawn_turfs[1]) //create pad using furthest turf
			turfs -= unattractive_spawn_turfs[1]
			amount--

/proc/find_exposed_wires()
	var/list/exposed_wires = list()

	var/list/all_turfs
	for(var/z in SSmapping.levels_by_trait(ZTRAIT_STATION))
		all_turfs += block(locate(1,1,z), locate(world.maxx,world.maxy,z))
	for(var/turf/open/floor/plating/T in all_turfs)
		if(T.is_blocked_turf())
			continue
		if(locate(/obj/structure/cable) in T)
			exposed_wires += T

	return shuffle(exposed_wires)

/proc/find_satchel_suitable_turfs()
	var/list/suitable = list()

	for(var/z in SSmapping.levels_by_trait(ZTRAIT_STATION))
		for(var/turf/detected_turf as anything in block(locate(1,1,z), locate(world.maxx,world.maxy,z)))
			if(isfloorturf(detected_turf) && detected_turf.underfloor_accessibility == UNDERFLOOR_HIDDEN)
				suitable += detected_turf

	return shuffle(suitable)

/proc/find_pad_suitable_turfs()
	var/list/suitable = list()
	var/static/list/suitable_areas = typecacheof(list(
		/area/maintenance,
		/area/service/abandoned_gambling_den,
		/area/service/kitchen/abandoned,
		/area/service/library/abandoned,
		/area/service/theater/abandoned,
		/area/service/hydroponics/garden/abandoned,
		/area/science/research/abandoned,
		/area/commons/toilet
	))
	var/static/list/unsuitable_areas = typecacheof(list(
		/area/maintenance/disposal/incinerator, //on Delta at least this is in atmospherics
	))

	for(var/z in SSmapping.levels_by_trait(ZTRAIT_STATION))
		for(var/turf/detected_turf as anything in block(locate(1,1,z), locate(world.maxx,world.maxy,z)))
			if(!isfloorturf(detected_turf))
				continue

			var/my_area = get_area(detected_turf)
			if(is_type_in_typecache(my_area, unsuitable_areas))
				continue
			if (is_type_in_typecache(my_area, suitable_areas))
				suitable += detected_turf

	return shuffle(suitable)

#undef PROB_MOUSE_SPAWN
