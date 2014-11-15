/datum/subsystem/server_maint
	name = "Server Tasks"
	wait = 6000
	priority = 19

/datum/subsystem/server_maint/fire()
	//handle kicking inactive players
	if(config.kick_inactive > 0)
		for(var/client/C in clients)
			if(C.is_afk(INACTIVITY_KICK))
				if(!istype(C.mob, /mob/dead))
					log_access("AFK: [key_name(C)]")
					C << "<span class='danger'>You have been inactive for more than 10 minutes and have been disconnected.</span>"
					del(C)

	if(config.sql_enabled)
		sql_poll_players()
		sql_poll_admins()
