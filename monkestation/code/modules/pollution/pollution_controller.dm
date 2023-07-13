SUBSYSTEM_DEF(pollution)
	name = "Pollution"
	init_order = INIT_ORDER_POLLUTION //Before atoms, because the emitters may need to know the singletons
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	wait = 2 SECONDS
	/// Currently active pollution
	var/list/active_pollution = list()
	/// All pollution in the world
	var/list/all_polution = list()
	/// Currently processed batch of pollutants
	var/list/current_run = list()
	/// Already processed pollutants in cell process
	var/list/processed_this_run = list()
	/// Ticker for dissipation task
	var/dissapation_ticker = 0
	/// What's the current task we're doing
	var/pollution_task = POLLUTION_TASK_PROCESS
	/// Associative list of types of pollutants to their instanced singletons
	var/list/singletons = list()

/datum/controller/subsystem/pollution/stat_entry(msg)
	msg += "|AT:[active_pollution.len]|P:[all_polution.len]"
	return ..()

/datum/controller/subsystem/pollution/Initialize()
	//Initialize singletons
	for(var/type in subtypesof(/datum/pollutant))
		var/datum/pollutant/pollutant_cast = type
		if(!initial(pollutant_cast.name))
			continue
		singletons[type] = new type()
	return SS_INIT_SUCCESS

/datum/controller/subsystem/pollution/fire(resumed = FALSE)
	var/list/current_run_cache = current_run
	if(pollution_task == POLLUTION_TASK_PROCESS)
		if(!current_run_cache.len)
			current_run_cache = active_pollution.Copy()
			processed_this_run.Cut()
		while(current_run_cache.len)
			var/datum/pollution/pollution = current_run_cache[current_run_cache.len]
			current_run_cache.len--
			processed_this_run[pollution] = TRUE
			pollution.process_cell()
			if(MC_TICK_CHECK)
				return
		dissapation_ticker++
		if(dissapation_ticker >= TICKS_TO_DISSIPATE)
			pollution_task = POLLUTION_TASK_DISSIPATE
			dissapation_ticker = 0
			current_run_cache = all_polution.Copy()
	if(pollution_task == POLLUTION_TASK_DISSIPATE)
		while(current_run_cache.len)
			var/datum/pollution/pollution = current_run_cache[current_run_cache.len]
			current_run_cache.len--
			pollution.scrub_amount(POLLUTION_HEIGHT_DIVISOR, FALSE, TRUE)
			if(MC_TICK_CHECK)
				return
		pollution_task = POLLUTION_TASK_PROCESS
