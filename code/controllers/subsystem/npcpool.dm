SUBSYSTEM_DEF(npcpool)
	name = "NPC Pool"
	flags = SS_POST_FIRE_TIMING|SS_NO_INIT|SS_BACKGROUND
	priority = FIRE_PRIORITY_NPC
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME

	var/list/currentrun = list()

/datum/controller/subsystem/npcpool/stat_entry(msg)
	var/list/activelist = GLOB.simple_animals[AI_ON]
	msg = "NPCS:[length(activelist)]"
	return ..()

/datum/controller/subsystem/npcpool/fire(resumed = FALSE)

	if (!resumed)
		var/list/activelist = GLOB.simple_animals[AI_ON]
		src.currentrun = activelist.Copy()

	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun

	while(currentrun.len)
		var/mob/living/simple_animal/SA = currentrun[currentrun.len]
		--currentrun.len

		if (QDELETED(SA)) // Some issue causes nulls to get into this list some times. This keeps it running, but the bug is still there.
			GLOB.simple_animals[AI_ON] -= SA
			stack_trace("Found a null in simple_animals active list [SA.type]!")
			continue

		if(!SA.ckey && !HAS_TRAIT(SA, TRAIT_NO_TRANSFORM))
			if(SA.stat != DEAD)
				SA.handle_automated_movement()
			if(SA.stat != DEAD)
				SA.handle_automated_action()
			if(SA.stat != DEAD)
				SA.handle_automated_speech()
		if (MC_TICK_CHECK)
			return
