SUBSYSTEM_DEF(stamina)
	name = "Stamina"

	priority = FIRE_PRIORITY_STAMINA
	flags = SS_BACKGROUND|SS_POST_FIRE_TIMING|SS_NO_INIT
	wait = 1 SECONDS

	var/list/processing = list()
	var/list/currentrun = list()

/datum/controller/subsystem/stamina/stat_entry(msg)
	msg = "P:[length(processing)]"
	return ..()

/datum/controller/subsystem/stamina/fire(resumed = FALSE)
	if (!resumed)
		currentrun = processing.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/current_run = currentrun

	while(current_run.len)
		var/datum/stamina_container/thing = current_run[current_run.len]
		current_run.len--
		thing.update(wait * 0.1)
		if (MC_TICK_CHECK)
			return
