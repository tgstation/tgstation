SUBSYSTEM_DEF(mobs)
	name = "Mobs"
	priority = FIRE_PRIORITY_MOBS
	flags = SS_KEEP_TIMING | SS_NO_INIT
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	wait = 2 SECONDS

	var/list/currentrun = list()

	var/list/processing = list()

	var/static/list/clients_by_zlevel[][]
	var/static/list/dead_players_by_zlevel[][] = list(list()) // Needs to support zlevel 1 here, MaxZChanged only happens when z2 is created and new_players can login before that.
	var/static/list/cubemonkeys = list()
	var/static/list/cheeserats = list()

/datum/controller/subsystem/mobs/stat_entry(msg)
	msg = "P:[length(processing)]"
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
		src.currentrun = processing.Copy()

	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun

	var/times_fired = src.times_fired
	var/delta_time = wait / (1 SECONDS) // TODO: Make this actually responsive to stuff like pausing and resuming

	while(currentrun.len)
		var/mob/living/living_mob = currentrun[currentrun.len]
		currentrun.len--

		if(living_mob)
			living_mob.Life(delta_time, times_fired)
		else
			GLOB.mob_living_list -= living_mob
			processing -= living_mob

		if (MC_TICK_CHECK)
			return

/datum/controller/subsystem/mobs/proc/add_to_processing(mob/living/new_life)
	if(!istype(new_life))
		return FALSE

	processing |= new_life
	return TRUE

/datum/controller/subsystem/mobs/proc/remove_from_processing(mob/living/old_life)
	if(!istype(old_life))
		return FALSE

	processing -= old_life
	return TRUE

