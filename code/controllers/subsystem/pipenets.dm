var/datum/subsystem/pipenets/SSpipe

/datum/subsystem/pipenets
	name = "Pipenets"
	priority = 11

	var/list/networks = list()

/datum/subsystem/pipenets/New()
	NEW_SS_GLOBAL(SSpipe)

/datum/subsystem/pipenets/Initialize()
	set background = BACKGROUND_ENABLED

	//is it possible to combine all these procs into initialize() ??
	for(var/obj/machinery/atmospherics/M in world)
		M.build_network()

	for(var/obj/machinery/atmospherics/unary/U in world)
		if(istype(U, /obj/machinery/atmospherics/unary/vent_pump))
			var/obj/machinery/atmospherics/unary/vent_pump/V = U
			V.broadcast_status()
		else if(istype(U, /obj/machinery/atmospherics/unary/vent_scrubber))
			var/obj/machinery/atmospherics/unary/vent_scrubber/V = U
			V.broadcast_status()

	..()

/datum/subsystem/pipenets/fire()
	var/i=1
	for(var/thing in networks)
		if(thing)
			thing:process()
			++i
			continue
		networks.Cut(i, i+1)
