var/datum/subsystem/SSinput

/datum/subsystem/input
	name = "Input"
	wait = 1 //SS_TICKER means this runs every tick
	flags = SS_FIRE_IN_LOBBY|SS_TICKER|SS_NO_INIT|SS_KEEP_TIMING
	priority = 151
	display_order = 2

/datum/subsystem/input/New()
	NEW_SS_GLOBAL(SSinput)

/datum/subsystem/input/fire()
	var/client/C
	for(var/thing in clients)
		C = thing
		C.keyLoop()