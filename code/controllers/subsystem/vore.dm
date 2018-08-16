#define SSBELLIES_PROCESSED 1
#define SSBELLIES_IGNORED 2

//
// Bellies subsystem - Process vore bellies
//

SUBSYSTEM_DEF(bellies)
	name = "Bellies"
	priority = 5
	wait = 1 SECONDS
	flags = SS_KEEP_TIMING|SS_NO_INIT
	runlevels = RUNLEVEL_GAME|RUNLEVEL_POSTGAME

	var/static/list/belly_list = list()
	var/list/currentrun = list()
	var/ignored_bellies = 0

/datum/controller/subsystem/bellies/stat_entry()
	..("#: [belly_list.len] | P: [ignored_bellies]")

/datum/controller/subsystem/bellies/fire(resumed = 0)
	if (!resumed)
		ignored_bellies = 0
		src.currentrun = belly_list.Copy()

	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun
	var/times_fired = src.times_fired
	while(currentrun.len)
		var/obj/belly/B = currentrun[currentrun.len]
		currentrun.len--

		if(QDELETED(B))
			belly_list -= B
		else
			if(B.process_belly(times_fired,wait) == SSBELLIES_IGNORED)
				ignored_bellies++

		if (MC_TICK_CHECK)
			return
