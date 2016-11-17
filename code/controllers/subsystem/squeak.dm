var/datum/subsystem/squeak/SSsqueak

// The Squeak
// because this is about placement of mice mobs, and nothing to do with
// mice - the computer peripheral

/datum/subsystem/squeak
	name = "Squeak"
	priority = 40
	flags = SS_NO_FIRE

	var/list/exposed_wires = list()

/datum/subsystem/squeak/New()
	NEW_SS_GLOBAL(SSsqueak)

/datum/subsystem/squeak/Initialize(timeofday)
	trigger_migration()

/datum/subsystem/squeak/proc/trigger_migration(num_mice=10)
	find_exposed_wires()

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

/datum/subsystem/squeak/proc/find_exposed_wires()
	exposed_wires.Cut()

	var/list/all_turfs = block(locate(1,1,1), locate(world.maxx,world.maxy,1))
	for(var/turf/open/floor/plating/T in all_turfs)
		if(is_blocked_turf(T))
			continue
		if(locate(/obj/structure/cable) in T)
			exposed_wires += T
