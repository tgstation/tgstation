#define PING_BUFFER_TIME 25

SUBSYSTEM_DEF(server_maint)
	name = "Server Tasks"
	wait = 6
	flags = SS_POST_FIRE_TIMING|SS_FIRE_IN_LOBBY
	priority = 10
	var/list/currentrun

/datum/controller/subsystem/server_maint/Initialize()
	if (config.hub)
		world.visibility = 1
	..()

/datum/controller/subsystem/server_maint/fire(resumed = FALSE)
	if (!resumed)
		src.currentrun = GLOB.clients.Copy()

	var/round_started = Master.round_started
	var/list/currentrun = src.currentrun
	while (length(currentrun))
		var/client/C = currentrun[currentrun.len]
		currentrun.len--

		if(config.kick_inactive)
			if(round_started && C.is_afk(INACTIVITY_KICK))
				if(!istype(C.mob, /mob/dead))
					log_access("AFK: [key_name(C)]")
					to_chat(C, "<span class='danger'>You have been inactive for more than 10 minutes and have been disconnected.</span>")
					qdel(C)

		if (!(!C || world.time - C.connection_time < PING_BUFFER_TIME || C.inactivity >= (wait-1)))
			winset(C, null, "command=.update_ping+[world.time+world.tick_lag*world.tick_usage/100]")

		if (MC_TICK_CHECK) //one day, when ss13 has 1000 people per server, you guys are gonna be glad I added this tick check
			return

#undef PING_BUFFER_TIME
