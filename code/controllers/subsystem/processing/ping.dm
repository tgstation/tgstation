#define PING_BUFFER_TIME 25

var/datum/subsystem/processing/ping/SSping

/datum/subsystem/processing/ping
	name = "Ping"
	wait = 6
	flags = SS_NO_INIT|SS_POST_FIRE_TIMING|SS_FIRE_IN_LOBBY
	priority = 10

	stat_tag = "C"
	processing_list = null	//use clients

/datum/subsystem/processing/ping/New()
	NEW_SS_GLOBAL(SSping)

/datum/subsystem/processing/ping/Initialize()
	processing_list = clients
	..()

/datum/subsystem/processing/ping/stop_processing()
	//noop

/datum/subsystem/processing/ping/Recover()
	//noop

/client/process(wait)
	. = (world.time - connection_time < PING_BUFFER_TIME || inactivity >= (wait-1))
	if(!.)
		winset(src, null, "command=.update_ping+[world.time+world.tick_lag*world.tick_usage/100]")

#undef PING_BUFFER_TIME
