PROCESSING_SUBSYSTEM_DEF(goonchat)
	name = "Goonchat"
	flags = SS_TICKER | SS_NO_INIT
	wait = 1
	priority = 1000
	runlevels = RUNLEVELS_DEFAULT | RUNLEVEL_SETUP
	init_order = INIT_ORDER_GOONCHAT

	currentrun = null

/datum/controller/subsystem/processing/goonchat/fire()
	var/list/processing = src.processing
	while(processing.len)
		var/datum/chatOutput/thing = processing[processing.len]
		processing.len--
		if(thing)
			thing.DispatchMessages()
		if(MC_TICK_CHECK)
			break
