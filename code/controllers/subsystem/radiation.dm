SUBSYSTEM_DEF(radiation)
	name = "Radiation"
	flags = SS_NO_INIT

	var/list/processing = list()
	var/list/currentrun = list()

/datum/controller/subsystem/radiation/fire(resumed=FALSE)
	if(!resumed)
		currentrun = processing.Copy()

	var/list/runcache = currentrun
	while(runcache.len)
		var/datum/thing = runcache[runcache.len]
		runcache.len--

		if(!thing || QDELETED(thing))
			processing -= thing
			if(MC_TICK_CHECK)
				return

		thing.process()
		
		if(MC_TICK_CHECK)
			return