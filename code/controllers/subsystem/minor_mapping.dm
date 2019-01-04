SUBSYSTEM_DEF(minor_mapping)
	name = "Minor Mapping"
	init_order = INIT_ORDER_MINOR_MAPPING
	flags = SS_NO_FIRE

/datum/controller/subsystem/minor_mapping/Initialize(timeofday)
	trigger_migration(CONFIG_GET(number/mice_roundstart))
	return ..()

/datum/controller/subsystem/minor_mapping/proc/trigger_migration(num_mice=10)
	var/list/exposed_wires = find_exposed_wires()

	var/mob/living/simple_animal/mouse/M
	var/turf/proposed_turf

	while((num_mice > 0) && exposed_wires.len)
		proposed_turf = pick_n_take(exposed_wires)
		if(!M)
			M = new(proposed_turf)
		else
			M.forceMove(proposed_turf)
		if(M.environment_is_safe())
			num_mice -= 1
			M = null

/proc/find_exposed_wires()
	var/list/exposed_wires = list()

	var/list/all_turfs
	for (var/z in SSmapping.levels_by_trait(ZTRAIT_STATION))
		all_turfs += block(locate(1,1,z), locate(world.maxx,world.maxy,z))
	for(var/turf/open/floor/plating/T in all_turfs)
		if(is_blocked_turf(T))
			continue
		if(locate(/obj/structure/cable) in T)
			exposed_wires += T

	return shuffle(exposed_wires)
