
SUBSYSTEM_DEF(fields)
	name = "Fields"
	wait = 2
	priority = 40
	flags = SS_KEEP_TIMING
	var/list/datum/proximity_monitor/advanced/running = list()
	var/list/datum/proximity_monitor/advanced/currentrun = list()

/datum/controller/subsystem/fields/fire(resumed = 0)
	if(!resumed)
		src.currentrun = running.Copy()
	var/list/currentrun = src.currentrun
	while(currentrun.len)
		var/datum/proximity_monitor/advanced/F = currentrun[currentrun.len]
		currentrun.len--
		if(!F.requires_processing)
			continue
		F.process()
		if(MC_TICK_CHECK)
			return

/datum/controller/subsystem/fields/proc/register_new_field(datum/proximity_monitor/advanced/F)
	running += F

/datum/controller/subsystem/fields/proc/unregister_field(datum/proximity_monitor/advanced/F)
	running -= F
