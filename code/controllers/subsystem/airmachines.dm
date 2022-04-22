SUBSYSTEM_DEF(airmachines)
	name = "Air (Machines)"
	priority = FIRE_PRIORITY_AIRMACHINES
	init_order = INIT_ORDER_AIRMACHINES
	flags = SS_KEEP_TIMING
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME

	var/cached_cost

	var/list/pipe_init_dirs_cache = list()

	var/list/networks = list()
	var/list/rebuild_queue = list()
	var/list/expansion_queue = list()
	var/list/atmos_machinery = list()

	var/list/current_run = list()
	var/list/current_process = SSAIRMACH_PIPENETS

	var/cost_rebuilds
	var/cost_pipenets
	var/cost_atmos_machinery

/datum/controller/subsystem/airmachines/Initialize(timeofday)
	var/starttime = REALTIMEOFDAY
	to_chat(world, span_boldannounce("Airmachines: Setting up atmospheric machinery..."))
	setup_atmos_machinery()
	to_chat(world, span_boldannounce("Airmachines: Airmachine setup completed in [(REALTIMEOFDAY- starttime) / 10] seconds!"))
	starttime = REALTIMEOFDAY
	to_chat(world, span_boldannounce("Airmachines: Creating pipenets..."))
	setup_pipenets()
	to_chat(world, span_boldannounce("Airmachines: Pipenet creation completed in [(REALTIMEOFDAY- starttime) / 10] seconds!"))
	return ..()

/datum/controller/subsystem/airmachines/stat_entry(msg)
	msg += "CR: [cost_rebuilds ? cost_rebuilds : 0]|"
	msg += "CPN: [cost_pipenets]|"
	msg += "CAM: [cost_atmos_machinery]|"
	msg += "NN: [length(networks)]|"
	msg += "NAM: [length(atmos_machinery)]|"
	msg += "RQ: [length(rebuild_queue)]|"
	msg += "EQ: [length(expansion_queue)]"
	return ..()

/datum/controller/subsystem/airmachines/Recover()
	pipe_init_dirs_cache = SSairmachines.pipe_init_dirs_cache
	networks = SSairmachines.networks
	rebuild_queue = SSairmachines.rebuild_queue
	expansion_queue = SSairmachines.expansion_queue
	atmos_machinery = SSairmachines.atmos_machinery
	current_run = SSairmachines.current_run
	current_process = SSairmachines.current_process
	return ..()

/datum/controller/subsystem/airmachines/fire(resumed = FALSE)
	var/timer = TICK_USAGE_REAL
	// Every time we fire, we want to make sure pipenets are rebuilt. The game state could have changed between each fire() proc call
	// and anything missing a pipenet can lead to unintended behaviour at worse and various runtimes at best.
	if(length(rebuild_queue) || length(expansion_queue))
		timer = TICK_USAGE_REAL
		process_rebuilds()
		//This does mean that the apperent rebuild costs fluctuate very quickly, this is just the cost of having them always process, no matter what
		if(state != SS_RUNNING)
			return

	if(current_process == SSAIRMACH_PIPENETS || !resumed)
		timer = TICK_USAGE_REAL
		if(!resumed)
			cached_cost = 0
		process_pipenets(resumed)
		cached_cost += TICK_USAGE_REAL - timer
		if(state != SS_RUNNING)
			return
		cost_pipenets = MC_AVERAGE(cost_pipenets, TICK_DELTA_TO_MS(cached_cost))
		resumed = FALSE
		current_process = SSAIRMACH_MACHINES

	if(current_process == SSAIRMACH_MACHINES)
		timer = TICK_USAGE_REAL
		if(!resumed)
			cached_cost = 0
		process_atmos_machinery(resumed)
		cached_cost += TICK_USAGE_REAL - timer
		if(state != SS_RUNNING)
			return
		cost_atmos_machinery = MC_AVERAGE(cost_atmos_machinery, TICK_DELTA_TO_MS(cached_cost))
		resumed = FALSE

	current_process = SSAIRMACH_PIPENETS

/datum/controller/subsystem/airmachines/proc/process_rebuilds()
	//Yes this does mean rebuilding pipenets can freeze up the subsystem forever, but if we're in that situation something else is very wrong
	var/list/currentrun = rebuild_queue
	while(currentrun.len || length(expansion_queue))
		while(currentrun.len && !length(expansion_queue)) //If we found anything, process that first
			var/obj/machinery/atmospherics/remake = currentrun[currentrun.len]
			currentrun.len--
			if (!remake)
				continue
			remake.rebuild_pipes()
			if (MC_TICK_CHECK)
				return

		var/list/queue = expansion_queue
		while(queue.len)
			var/list/pack = queue[queue.len]
			//We operate directly with the pipeline like this because we can trust any rebuilds to remake it properly
			var/datum/pipeline/linepipe = pack[SSAIRMACH_REBUILD_PIPELINE]
			var/list/border = pack[SSAIRMACH_REBUILD_QUEUE]
			expand_pipeline(linepipe, border)
			if(state != SS_RUNNING) //expand_pipeline can fail a tick check, we shouldn't let things get too fucky here
				return

			linepipe.building = FALSE
			queue.len--
			if (MC_TICK_CHECK)
				return

/datum/controller/subsystem/airmachines/proc/process_pipenets(resumed = FALSE)
	if (!resumed)
		src.current_run = networks.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.current_run
	while(currentrun.len)
		var/datum/thing = current_run[current_run.len]
		current_run.len--
		if(thing)
			thing.process()
		else
			networks.Remove(thing)
		if(MC_TICK_CHECK)
			return

/datum/controller/subsystem/airmachines/proc/process_atmos_machinery(resumed = FALSE)
	if (!resumed)
		src.current_run = atmos_machinery.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/current_run = src.current_run
	while(current_run.len)
		var/obj/machinery/M = current_run[current_run.len]
		current_run.len--
		if(!M)
			atmos_machinery -= M
		if(M.process_atmos() == PROCESS_KILL)
			stop_processing_machine(M)
		if(MC_TICK_CHECK)
			return

///Rebuilds a pipeline by expanding outwards, while yielding when sane
/datum/controller/subsystem/airmachines/proc/expand_pipeline(datum/pipeline/net, list/border)
	while(border.len)
		var/obj/machinery/atmospherics/borderline = border[border.len]
		border.len--

		var/list/result = borderline.pipeline_expansion(net)
		if(!length(result))
			continue
		for(var/obj/machinery/atmospherics/considered_device in result)
			if(!istype(considered_device, /obj/machinery/atmospherics/pipe))
				considered_device.set_pipenet(net, borderline)
				net.add_machinery_member(considered_device)
				continue
			var/obj/machinery/atmospherics/pipe/item = considered_device
			if(net.members.Find(item))
				continue
			if(item.parent)
				var/static/pipenetwarnings = 10
				if(pipenetwarnings > 0)
					log_mapping("build_pipeline(): [item.type] added to a pipenet while still having one. (pipes leading to the same spot stacking in one turf) around [AREACOORD(item)].")
					pipenetwarnings--
				if(pipenetwarnings == 0)
					log_mapping("build_pipeline(): further messages about pipenets will be suppressed")

			net.members += item
			border += item

			net.air.volume += item.volume
			item.parent = net

			if(item.air_temporary)
				net.air.merge(item.air_temporary)
				item.air_temporary = null

		if (MC_TICK_CHECK)
			return

/datum/controller/subsystem/airmachines/proc/add_to_rebuild_queue(obj/machinery/atmospherics/atmos_machine)
	if(istype(atmos_machine, /obj/machinery/atmospherics) && !atmos_machine.rebuilding)
		rebuild_queue += atmos_machine
		atmos_machine.rebuilding = TRUE

/datum/controller/subsystem/airmachines/proc/add_to_expansion(datum/pipeline/line, starting_point)
	var/list/new_packet = new(SSAIRMACH_REBUILD_QUEUE)
	new_packet[SSAIRMACH_REBUILD_PIPELINE] = line
	new_packet[SSAIRMACH_REBUILD_QUEUE] = list(starting_point)
	expansion_queue += list(new_packet)

/datum/controller/subsystem/airmachines/proc/remove_from_expansion(datum/pipeline/line)
	for(var/list/packet in expansion_queue)
		if(packet[SSAIRMACH_REBUILD_PIPELINE] == line)
			expansion_queue -= packet
			return

/datum/controller/subsystem/airmachines/proc/setup_template_machinery(list/atmos_machines)
	var/obj/machinery/atmospherics/AM
	for(var/A in 1 to atmos_machines.len)
		AM = atmos_machines[A]
		AM.atmos_init()
		CHECK_TICK

	for(var/A in 1 to atmos_machines.len)
		AM = atmos_machines[A]
		var/list/targets = AM.get_rebuild_targets()
		for(var/datum/pipeline/build_off as anything in targets)
			build_off.build_pipeline_blocking(AM)
		CHECK_TICK

/datum/controller/subsystem/airmachines/proc/get_init_dirs(type, dir, init_dir)

	if(!pipe_init_dirs_cache[type])
		pipe_init_dirs_cache[type] = list()

	if(!pipe_init_dirs_cache[type]["[init_dir]"])
		pipe_init_dirs_cache[type]["[init_dir]"] = list()

	if(!pipe_init_dirs_cache[type]["[init_dir]"]["[dir]"])
		var/obj/machinery/atmospherics/temp = new type(null, FALSE, dir, init_dir)
		pipe_init_dirs_cache[type]["[init_dir]"]["[dir]"] = temp.get_init_directions()
		qdel(temp)

	return pipe_init_dirs_cache[type]["[init_dir]"]["[dir]"]

/**
 * Adds a given machine to the processing system for SSAIR_ATMOSMACHINERY processing.
 *
 * Arguments:
 * * machine - The machine to start processing. Can be any /obj/machinery.
 */
/datum/controller/subsystem/airmachines/proc/start_processing_machine(obj/machinery/machine)
	if(machine.atmos_processing)
		return
	if(QDELETED(machine))
		stack_trace("We tried to add a garbage collecting machine to SSzas. Don't")
		return
	machine.atmos_processing = TRUE
	atmos_machinery += machine
	machine.flags_1 |= ATMOS_IS_PROCESSING_1

/**
 * Removes a given machine to the processing system for SSZAS_MACHINES processing.
 *
 * Arguments:
 * * machine - The machine to stop processing.
 */
/datum/controller/subsystem/airmachines/proc/stop_processing_machine(obj/machinery/machine)
	if(!machine.atmos_processing)
		return
	machine.atmos_processing = FALSE
	atmos_machinery -= machine
	machine.flags_1 &= ~ATMOS_IS_PROCESSING_1

	// If we're currently processing atmos machines, there's a chance this machine is in
	// the currentrun list, which is a cache of atmos_machinery. Remove it from that list
	// as well to prevent processing qdeleted objects in the cache.
	if(current_process == SSAIRMACH_MACHINES)
		current_run -= machine

/datum/controller/subsystem/airmachines/proc/setup_atmos_machinery()
	for (var/obj/machinery/atmospherics/AM in atmos_machinery)
		AM.atmos_init()
		CHECK_TICK

//this can't be done with setup_atmos_machinery() because
// all atmos machinery has to initalize before the first
// pipenet can be built.
/datum/controller/subsystem/airmachines/proc/setup_pipenets()
	for (var/obj/machinery/atmospherics/AM in atmos_machinery)
		var/list/targets = AM.get_rebuild_targets()
		for(var/datum/pipeline/build_off as anything in targets)
			build_off.build_pipeline_blocking(AM)
		CHECK_TICK

