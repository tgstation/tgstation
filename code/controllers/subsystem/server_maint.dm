SUBSYSTEM_DEF(server_maint)
	name = "Server Tasks"
	wait = 6000
	flags = SS_NO_TICK_CHECK

/datum/controller/subsystem/server_maint/Initialize(timeofday)
	if (config.hub)
		world.visibility = 1
	..()

/datum/controller/subsystem/server_maint/fire()
	//handle kicking inactive players
	if(config.kick_inactive)
		for(var/client/C in GLOB.clients)
			if(C.is_afk(config.afk_period))
				var/cmob = C.mob
				if(!(istype(cmob, /mob/dead/observer) || (istype(cmob, /mob/dead) && C.holder)))
					log_access("AFK: [key_name(C)]")
					to_chat(C, "<span class='danger'>You have been inactive for more than [config.afk_period / 600] minutes and have been disconnected.</span>")
					qdel(C)

	if(config.sql_enabled)
		sql_poll_population()
