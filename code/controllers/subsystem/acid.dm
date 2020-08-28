SUBSYSTEM_DEF(acid)
	name = "Acid"
	priority = FIRE_PRIORITY_ACID
	flags = SS_NO_INIT|SS_BACKGROUND
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME

	var/list/currentrun = list()
	var/list/processing = list()

/datum/controller/subsystem/acid/stat_entry(msg)
	msg = "P:[length(processing)]"
	return ..()


/datum/controller/subsystem/acid/fire(resumed = 0)
	if(!resumed)
		src.currentrun = processing.Copy()

	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun

	while(currentrun.len)
		var/datum/component/acid/acid = currentrun[currentrun.len]
		currentrun.len--
		if(!acid || QDELETED(acid))
			processing -= acid
			if(MC_TICK_CHECK)
				return
			continue

		if(acid.process() == PROCESS_KILL)
			processing -= acid

		if(MC_TICK_CHECK)
			return
