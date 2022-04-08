SUBSYSTEM_DEF(simple_mobs)
	name = "Simple Mobs"
	priority = FIRE_PRIORITY_SIMPLE_MOBS
	flags = SS_NO_INIT | SS_BACKGROUND
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	wait = 3 SECONDS

	///what simple animals get processed by this subsystem. some stay in the global list but are removed from here.
	var/list/processing_simple_mobs = list()

	var/list/current_run = list()

/datum/controller/subsystem/simple_mobs/stat_entry(msg)
	msg = "P:[length(processing_simple_mobs)]"
	return ..()

/datum/controller/subsystem/simple_mobs/fire(resumed = FALSE)
	if(!resumed)
		src.current_run = processing_simple_mobs.Copy()

	//something something sanic speeds and references
	var/list/current_run = src.current_run
	var/times_fired = src.times_fired
	var/delta_time = wait / (1 SECONDS)

	while(current_run.len)
		var/mob/living/simple_animal/mob_to_process = current_run[current_run.len]
		current_run.len--

		if(mob_to_process)
			mob_to_process.Life(delta_time, times_fired)
		else
			processing_simple_mobs -= mob_to_process

		if(MC_TICK_CHECK)
			return
