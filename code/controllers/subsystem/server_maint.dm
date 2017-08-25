#define PING_BUFFER_TIME 25

SUBSYSTEM_DEF(server_maint)
	name = "Server Tasks"
	wait = 6
	flags = SS_POST_FIRE_TIMING
	priority = 10
	init_order = INIT_ORDER_SERVER_MAINT
	runlevels = RUNLEVEL_LOBBY | RUNLEVELS_DEFAULT
	var/list/currentrun

/datum/controller/subsystem/server_maint/Initialize(timeofday)
	if (config.hub)
		world.update_hub_visibility(TRUE)
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
				if(!(isobserver(cmob) || (isdead(cmob) && C.holder)))
					log_access("AFK: [key_name(C)]")
					to_chat(C, "<span class='danger'>You have been inactive for more than [config.afk_period / 600] minutes and have been disconnected.</span>")
					qdel(C)

		if (!(!C || world.time - C.connection_time < PING_BUFFER_TIME || C.inactivity >= (wait-1)))
			winset(C, null, "command=.update_ping+[world.time+world.tick_lag*TICK_USAGE_REAL/100]")

		if (MC_TICK_CHECK) //one day, when ss13 has 1000 people per server, you guys are gonna be glad I added this tick check
			return

/datum/controller/subsystem/server_maint/Shutdown()
	kick_clients_in_lobby("<span class='boldannounce'>The round came to an end with you in the lobby.</span>", TRUE) //second parameter ensures only afk clients are kicked
	var/server = config.server
	for(var/thing in GLOB.clients)
		if(!thing)
			continue
		var/client/C = thing
		var/datum/chatOutput/co = C.chatOutput
		if(co)
			co.ehjax_send(data = "roundrestart")
		if(server)	//if you set a server location in config.txt, it sends you there instead of trying to reconnect to the same world address. -- NeoFite
			C << link("byond://[server]")

#undef PING_BUFFER_TIME
