SUBSYSTEM_DEF(mobs)
	name = "Mobs"
	priority = FIRE_PRIORITY_MOBS
	flags = SS_KEEP_TIMING | SS_NO_INIT
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	wait = 2 SECONDS

	var/list/currentrun = list()
	var/static/list/clients_by_zlevel[][]
	var/static/list/dead_players_by_zlevel[][] = list(list()) // Needs to support zlevel 1 here, MaxZChanged only happens when z2 is created and new_players can login before that.
	var/cubemonkeys = 0
	var/static/list/cheeserats
	var/next_slow_check = 0

/datum/controller/subsystem/mobs/stat_entry(msg)
	msg = "P:[length(GLOB.mob_living_list)]"
	return ..()

/datum/controller/subsystem/mobs/proc/MaxZChanged()
	if (!islist(clients_by_zlevel))
		clients_by_zlevel = new /list(world.maxz,0)
		dead_players_by_zlevel = new /list(world.maxz,0)
	while (clients_by_zlevel.len < world.maxz)
		clients_by_zlevel.len++
		clients_by_zlevel[clients_by_zlevel.len] = list()
		dead_players_by_zlevel.len++
		dead_players_by_zlevel[dead_players_by_zlevel.len] = list()

/datum/controller/subsystem/mobs/fire(resumed = FALSE)
	if(!resumed)
		currentrun = GLOB.mob_living_list.Copy()

	///Cache for speed as lists are references
	var/list/currentprocrun = currentrun
	while(currentprocrun.len)
		var/mob/living/L = currentprocrun[currentprocrun.len]
		currentprocrun.len--
		if(!L)
			GLOB.mob_living_list.Remove(L)//something removed us so dont process

		L.life_process()

		if(L.client && (currentrun >= next_slow_check))//only check for the zlevel every 5 runs
			next_slow_check = currentrun + 5

			var/turf/T = get_turf(L)
			if(!T)
				L.move_to_error_room()
				var/msg = "[ADMIN_LOOKUPFLW(L)] was found to have no .loc with an attached client, if the cause is unknown it would be wise to ask how this was accomplished."
				message_admins(msg)
				send2tgs_adminless_only("Mob", msg, R_ADMIN)
				log_game("[key_name(L)] was found to have no .loc with an attached client.")

				// This is a temporary error tracker to make sure we've caught everything
			else if(L.registered_z != T.z)
#ifdef TESTING
				message_admins("[ADMIN_LOOKUPFLW(L)] has somehow ended up in Z-level [T.z] despite being registered in Z-level [registered_z]. If you could ask them how that happened and notify coderbus, it would be appreciated.")
#endif
				log_game("Z-TRACKING: [L] has somehow ended up in Z-level [T.z] despite being registered in Z-level [L.registered_z].")
				L.update_z(T.z)
			else if(L.registered_z)
				log_game("Z-TRACKING: [L] of type [L.type] has a Z-registration despite not having a client.")
				L.update_z(null)


		if(MC_TICK_CHECK)
			return
