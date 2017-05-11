#define PING_BUFFER_TIME 25

SUBSYSTEM_DEF(server_maint)
	name = "Server Tasks"
	wait = 6
	flags = SS_POST_FIRE_TIMING
	priority = 10
	runlevels = RUNLEVEL_LOBBY | RUNLEVELS_DEFAULT
	var/list/currentrun

/datum/controller/subsystem/server_maint/Initialize(timeofday)
	if (config.hub)
		world.visibility = 1
	..()

/datum/controller/subsystem/server_maint/fire(resumed = FALSE)
	if(!resumed)
		src.currentrun = GLOB.clients.Copy()
	
	var/list/currentrun = src.currentrun
	var/round_started = SSticker.HasRoundStarted()

	for(var/I in currentrun)
		var/client/C = I
		//handle kicking inactive players
		if(round_started && config.kick_inactive)
			if(C.is_afk(config.afk_period))
				var/cmob = C.mob
				if(!(istype(cmob, /mob/dead/observer) || (istype(cmob, /mob/dead) && C.holder)))
					log_access("AFK: [key_name(C)]")
					to_chat(C, "<span class='danger'>You have been inactive for more than [config.afk_period / 600] minutes and have been disconnected.</span>")
					qdel(C)

		if (!(!C || world.time - C.connection_time < PING_BUFFER_TIME || C.inactivity >= (wait-1)))
			winset(C, null, "command=.update_ping+[world.time+world.tick_lag*world.tick_usage/100]")

		if (MC_TICK_CHECK) //one day, when ss13 has 1000 people per server, you guys are gonna be glad I added this tick check
			return

#undef PING_BUFFER_TIME
