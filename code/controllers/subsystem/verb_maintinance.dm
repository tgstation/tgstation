SUBSYSTEM_DEF(verb_maintinance)
	name = "Verb Maintienance"
	flags = SS_NO_INIT
	wait = 10 SECONDS
	priority = FIRE_PRIORITY_VERB_MAINT
	runlevels = RUNLEVEL_LOBBY | RUNLEVELS_DEFAULT
	var/stale_out_time = 3 MINUTES
	var/kill_threshold_time = 0
	var/kill_threshold_cost = 0
	var/list/currentrun

/datum/controller/subsystem/verb_maintinance/stat_entry(msg)
	msg = "Count: [length(GLOB.average_verb_cost)]"
	return ..()

/datum/controller/subsystem/verb_maintinance/fire(resumed)
	if(!resumed)
		src.currentrun = GLOB.average_verb_cost.Copy() // We only use this for its names to avoid going forever
		kill_threshold_time = world.time - stale_out_time
		kill_threshold_cost = INFINITY
		for(var/null_names in GLOB.nullifiying_verblikes)
			var/intel = GLOB.average_verb_cost[null_names]
			if(!intel)
				continue
			kill_threshold_cost = min(kill_threshold_cost, intel[VERB_LIST_COST])
		if(kill_threshold_cost == INFINITY)
			kill_threshold_cost = 0

	// Locally cache for sonic speed
	var/list/currentrun = src.currentrun
	var/list/average_verb_cost = GLOB.average_verb_cost
	// NOT a copy, this list can get big and I want to be nice to him
	for(var/i in 1 to length(currentrun))
		var/name = currentrun[i]
		if(name in GLOB.nullifiying_verblikes)
			continue
		var/list/intel = average_verb_cost[name]
		if(intel[VERB_LIST_COST] <= kill_threshold_cost) // More expensive to queue then run
			// Why do I care
			average_verb_cost -= name
		else if(intel[VERB_LIST_TIME] <= kill_threshold_time) // Old garbage, in the trash
			average_verb_cost -= name
		if(MC_TICK_CHECK)
			currentrun.Cut(1, i + 1)
			return
	currentrun = list()

