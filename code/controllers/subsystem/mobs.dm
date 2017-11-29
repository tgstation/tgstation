SUBSYSTEM_DEF(mobs)
	name = "Mobs"
	priority = 100
	flags = SS_KEEP_TIMING
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME

	var/list/currentrun = list()
	var/static/list/by_zlevel[][]

/datum/controller/subsystem/mobs/stat_entry()
	..("P:[GLOB.mob_living_list.len]")

/datum/controller/subsystem/mobs/Initialize(start_timeofday)
	by_zlevel = new /list(world.maxz,0)
	return ..()


/datum/controller/subsystem/mobs/fire(resumed = 0)
	var/seconds = wait * 0.1
	if (!resumed)
		src.currentrun = GLOB.mob_living_list.Copy()
		if (GLOB.overminds.len) // blob cameras need to Life()
			src.currentrun += GLOB.overminds

	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun
	var/times_fired = src.times_fired
	while(currentrun.len)
		var/mob/M = currentrun[currentrun.len]
		currentrun.len--
		if(M)
			M.Life(seconds, times_fired)
		else
			GLOB.mob_living_list.Remove(M)
		if (istype(M, /mob/living))
			var/mob/living/L = M
			if (L.client && L.registered_z != L.z)
				message_admins("[L] [ADMIN_FLW(L)] has somehow ended up in Z-level [L.z] despite being registered in Z-level [L.registered_z]. If you could ask them how that happened and notify coderbus, it would be appreciated.")
				log_game("Z-TRACKING: [L] has somehow ended up in Z-level [L.z] despite being registered in Z-level [L.registered_z].")
				L.update_z(L.z)
			else if (!L.client && L.registered_z)
				message_admins("[L] [ADMIN_FLW(L)] has a Z-registration despite not having a client.")
				log_game("Z-TRACKING: [L] of type [L.type] has a Z-registration despite not having a client.")
				L.update_z(null)
		if (MC_TICK_CHECK)
			return
