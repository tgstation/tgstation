SUBSYSTEM_DEF(mobs)
	name = "Mobs"
	priority = FIRE_PRIORITY_MOBS
	ss_flags = SS_KEEP_TIMING | SS_NO_INIT
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	wait = 2 SECONDS

	var/list/currentrun = list()
	///only contains living players for some reason
	var/static/list/clients_by_zlevel[][]
	var/static/list/dead_players_by_zlevel[][] = list(list()) // Needs to support zlevel 1 here, MaxZChanged only happens when z2 is created and new_players can login before that.
	var/static/list/cubemonkeys = list()
	var/static/list/cheeserats = list()
	var/static/list/relicmobs = list()

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
	if (!resumed)
		src.currentrun = GLOB.mob_living_list.Copy()

	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun
	var/seconds_per_tick = wait / (1 SECONDS)
	while(currentrun.len)
		var/mob/living/processing_mob = currentrun[currentrun.len]
		currentrun.len--
		if(processing_mob)
			processing_mob.Life(seconds_per_tick)
		else
			GLOB.mob_living_list.Remove(processing_mob)
		if (MC_TICK_CHECK)
			return

/datum/controller/subsystem/mobs/proc/register_relic_mob(mob/living/spawned)
	relicmobs |= spawned
	RegisterSignal(spawned, COMSIG_QDELETING, PROC_REF(relic_mob_deleted))

/datum/controller/subsystem/mobs/proc/relic_mob_deleted(mob/living/source)
	SIGNAL_HANDLER
	relicmobs -= source
