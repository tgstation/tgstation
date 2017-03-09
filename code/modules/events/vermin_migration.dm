//Mice and lizards

//MICE//
//why is there an entire not easily generizable subsystem just for this one event I swear to mouse jesus

/datum/round_event_control/mice_migration
	name = "Mice Migration"
	typepath = /datum/round_event/mice_migration
	weight = 10

/datum/round_event/mice_migration
	announceWhen = 0
	var/minimum_mice = 5
	var/maximum_mice = 15

/datum/round_event/mice_migration/announce()
	var/cause = pick("space-winter", "budget-cuts", "Ragnarok",
		"space being cold", "\[REDACTED\]", "climate change",
		"bad luck")
	var/plural = pick("a number of", "a horde of", "a pack of", "a swarm of",
		"a whoop of", "not more than [maximum_mice]")
	var/name = pick("rodents", "mice", "squeaking things",
		"wire eating mammals", "\[REDACTED\]", "energy draining parasites")
	var/movement = pick("migrated", "swarmed", "stampeded", "descended")
	var/location = pick("maintenance tunnels", "maintenance areas",
		"\[REDACTED\]", "place with all those juicy wires")

	priority_announce("Due to [cause], [plural] [name] have [movement] \
		into the [location].", "Migration Alert",
		'sound/effects/mousesqueek.ogg', 100, 1)

/datum/round_event/mice_migration/start()
	SSsqueak.trigger_migration(rand(minimum_mice, maximum_mice))

// Lizard filth //

/datum/round_event_control/lizard_infestation
	name = "Lizard Infestation"
	typepath = /datum/round_event/lizard_infestation
	weight = 10

/datum/round_event/lizard_infestation
	announceWhen = 5
	var/lizardcount = 15
	startWhen = 10

/datum/round_event/lizard_infestation/announce()
	priority_announce("Unusual levels of vermin have been detected near [station_name()]. Please be alert for potential contamination.", "Lifesign Alert")

/datum/round_event/lizard_infestation/start()
	var/list/turfs = list()
	for(var/area/maintenance/A in world) // to spawn lizards in maint
		for(var/turf/open/floor/T in A)
			turfs += T

	if(turfs.len)
		for(var/i = 1, i <= lizardcount, i++)
			var/turf/T = pick(turfs)
			if(prob(66))
				new /mob/living/simple_animal/hostile/lizard/filthy(T)
			else // #notalllizards
				new /mob/living/simple_animal/hostile/lizard(T)