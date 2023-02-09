#define PROB_MOUSE_SPAWN 98

SUBSYSTEM_DEF(minor_mapping)
	name = "Minor Mapping"
	init_order = INIT_ORDER_MINOR_MAPPING
	flags = SS_NO_FIRE

/datum/controller/subsystem/minor_mapping/Initialize()
	#ifdef UNIT_TESTS // This whole subsystem just introduces a lot of odd confounding variables into unit test situations, so let's just not bother with doing an initialize here.
	return SS_INIT_NO_NEED
	#endif // the mice are easily the bigger problem, but let's just avoid anything that could cause some bullshit.
	trigger_migration(CONFIG_GET(number/mice_roundstart))
	place_satchels()
	return SS_INIT_SUCCESS

/datum/controller/subsystem/minor_mapping/proc/trigger_migration(num_mice=10)
	var/list/exposed_wires = find_exposed_wires()

	var/mob/living/basic/mouse/mouse
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
	///List of areas where satchels should not be placed.
	var/list/blacklisted_area_types = list(/area/station/holodeck)

	while(turfs.len && amount > 0)
		var/turf/turf = pick_n_take(turfs)
		if(is_type_in_list(get_area(turf), blacklisted_area_types))
			continue
		var/obj/item/storage/backpack/satchel/flat/flat_satchel = new(turf)

		SEND_SIGNAL(flat_satchel, COMSIG_OBJ_HIDE, turf.underfloor_accessibility)
		amount--

/proc/find_exposed_wires()
	var/list/exposed_wires = list()

	var/list/all_turfs
	for(var/z in SSmapping.levels_by_trait(ZTRAIT_STATION))
		all_turfs += Z_TURFS(z)
	for(var/turf/open/floor/plating/T in all_turfs)
		if(T.is_blocked_turf())
			continue
		if(locate(/obj/structure/cable) in T)
			exposed_wires += T

	return shuffle(exposed_wires)

/proc/find_satchel_suitable_turfs()
	var/list/suitable = list()

	for(var/z in SSmapping.levels_by_trait(ZTRAIT_STATION))
		for(var/turf/detected_turf as anything in Z_TURFS(z))
			if(isfloorturf(detected_turf) && detected_turf.underfloor_accessibility == UNDERFLOOR_HIDDEN)
				suitable += detected_turf

	return shuffle(suitable)

#undef PROB_MOUSE_SPAWN
