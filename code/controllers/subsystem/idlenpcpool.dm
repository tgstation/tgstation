SUBSYSTEM_DEF(idlenpcpool)
	name = "Idle NPC Pool"
	flags = SS_POST_FIRE_TIMING|SS_NO_INIT|SS_BACKGROUND
	priority = FIRE_PRIORITY_IDLE_NPC
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME

	var/list/idlerun = list()

/datum/controller/subsystem/idlenpcpool/stat_entry(msg)
	var/list/idlelist = GLOB.simple_animals[AI_IDLE]
	msg = "NPCS:[length(idlelist)]"
	return ..()

/datum/controller/subsystem/idlenpcpool/fire(resumed = FALSE)

	if (!resumed)
		var/list/idlelist = GLOB.simple_animals[AI_IDLE]
		src.idlerun = idlelist.Copy()
	var/list/idlerun = src.idlerun

	while(idlerun.len)
		var/mob/living/simple_animal/ISA = idlerun[idlerun.len]
		--idlerun.len

		if (QDELETED(ISA))
			GLOB.simple_animals[AI_IDLE] -= ISA
			stack_trace("Found a null in simple_animals idle list [ISA.type]!")
			continue

		if(!ISA.ckey && !HAS_TRAIT(ISA, TRAIT_NO_TRANSFORM) && !isbot(ISA))
			if(ISA.stat != DEAD)
				ISA.handle_automated_action()
			if(ISA.stat != DEAD)
				ISA.handle_automated_speech()
		if (MC_TICK_CHECK)
			return
