SUBSYSTEM_DEF(reagent_states)
	name = "Reagents"
	priority = 40
	flags = SS_NO_INIT|SS_BACKGROUND
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	var/deleting = FALSE

	var/list/currentrun = list()
	var/list/processing = list()

/datum/controller/subsystem/reagent_states/stat_entry()
	..("P:[processing.len]")


/datum/controller/subsystem/reagent_states/fire(resumed = 0)
	if (!resumed)
		src.currentrun = processing.Copy()

	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun

	while(currentrun.len)
		var/datum/thing = currentrun[currentrun.len]
		currentrun.len--
		if(thing)
			thing.process(wait)
		else
			SSreagent_states.processing -= thing
		if(MC_TICK_CHECK)
			if(!deleting && cost > 2000)
				deleting = TRUE
				for(var/I in GLOB.smoke)
					qdel(I)
				for(var/I in GLOB.vapour)
					qdel(I)
				deleting = FALSE
			return

/datum/controller/subsystem/reagent_states/Recover()
	processing = SSreagent_states.processing