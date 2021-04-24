PROCESSING_SUBSYSTEM_DEF(fluids)
	name = "Fluids"
	wait = 20
	stat_tag = "FD" //its actually Fluid Ducts
	flags = SS_NO_INIT | SS_TICKER

	///We randomly pick a duct from this list to start building a network
	var/list/prime_queued = list()
	///We track all the ducts that are currently building and queued in the timer subsystem, so we only prime new ductnetworks
	var/list/build_queued = list()

/datum/controller/subsystem/processing/fluids/fire(resumed = FALSE)
	. = ..()

	if(!build_queued.len && prime_queued.len)
		var/obj/machinery/duct/D = pick(prime_queued)
		D.attempt_connect()

//yes this is the exact same as the above function, but i dont want to make unnecessary proc calls in something thats called non-stop
///If a player lays down a duct, we'll check if its safe and then instantly built it, otherwise the delay might be a bit jarring to players
/datum/controller/subsystem/processing/fluids/proc/attempt_quick_build()
	if(!build_queued.len && prime_queued.len)
		var/obj/machinery/duct/D = pick(prime_queued)
		D.attempt_connect()
