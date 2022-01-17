SUBSYSTEM_DEF(air)
	name = "Atmospherics"
	init_order = INIT_ORDER_AIR
	priority = FIRE_PRIORITY_AIR
	wait = 0.5 SECONDS
	flags = SS_BACKGROUND
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME

	var/cached_cost = 0

	var/cost_atoms = 0
	var/cost_turfs = 0
	var/cost_hotspots = 0
	var/cost_groups = 0
	var/cost_highpressure = 0
	var/cost_superconductivity = 0
	var/cost_pipenets = 0
	var/cost_atmos_machinery = 0
	var/cost_rebuilds = 0

	var/list/excited_groups = list()
	var/list/active_turfs = list()
	var/list/hotspots = list()
	var/list/networks = list()
	var/list/rebuild_queue = list()
	//Subservient to rebuild queue
	var/list/expansion_queue = list()
	/// A list of machines that will be processed when currentpart == SSAIR_ATMOSMACHINERY. Use SSair.begin_processing_machine and SSair.stop_processing_machine to add and remove machines.
	var/list/obj/machinery/atmos_machinery = list()
	var/list/pipe_init_dirs_cache = list()

	//atmos singletons
	var/list/gas_reactions = list()
	var/list/atmos_gen
	var/list/planetary = list() //Lets cache static planetary mixes

	//Special functions lists
	var/list/turf/active_super_conductivity = list()
	var/list/turf/open/high_pressure_delta = list()
	var/list/atom_process = list()

	/// A cache of objects that perisists between processing runs when resumed == TRUE. Dangerous, qdel'd objects not cleared from this may cause runtimes on processing.
	var/list/currentrun = list()
	var/currentpart = SSAIR_PIPENETS

	var/map_loading = TRUE
	var/list/queued_for_activation
	var/display_all_groups = FALSE


/datum/controller/subsystem/air/stat_entry(msg)
	msg += "C:{"
	msg += "AT:[round(cost_turfs,1)]|"
	msg += "HS:[round(cost_hotspots,1)]|"
	msg += "EG:[round(cost_groups,1)]|"
	msg += "HP:[round(cost_highpressure,1)]|"
	msg += "SC:[round(cost_superconductivity,1)]|"
	msg += "PN:[round(cost_pipenets,1)]|"
	msg += "AM:[round(cost_atmos_machinery,1)]|"
	msg += "AO:[round(cost_atoms, 1)]|"
	msg += "RB:[round(cost_rebuilds,1)]|"
	msg += "} "
	msg += "AT:[length(active_turfs)]|"
	msg += "HS:[length(hotspots)]|"
	msg += "EG:[length(excited_groups)]|"
	msg += "HP:[length(high_pressure_delta)]|"
	msg += "SC:[length(active_super_conductivity)]|"
	msg += "PN:[length(networks)]|"
	msg += "AM:[length(atmos_machinery)]|"
	msg += "AO:[length(atom_process)]|"
	msg += "RB:[length(rebuild_queue)]|"
	msg += "EP:[length(expansion_queue)]|"
	msg += "AT/MS:[round((cost ? length(active_turfs)/cost_turfs : 0),0.1)]"
	return ..()


/datum/controller/subsystem/air/Initialize(timeofday)
	map_loading = FALSE
	gas_reactions = init_gas_reactions()

	setup_allturfs()
	setup_atmos_machinery()
	setup_pipenets()
	setup_turf_visuals()
	return ..()


/datum/controller/subsystem/air/fire(resumed = FALSE)
	var/timer = TICK_USAGE_REAL

	//Rebuilds can happen at any time, so this needs to be done outside of the normal system
	cost_rebuilds = 0

	// Every time we fire, we want to make sure pipenets are rebuilt. The game state could have changed between each fire() proc call
	// and anything missing a pipenet can lead to unintended behaviour at worse and various runtimes at best.
	if(length(rebuild_queue) || length(expansion_queue))
		timer = TICK_USAGE_REAL
		process_rebuilds()
		//This does mean that the apperent rebuild costs fluctuate very quickly, this is just the cost of having them always process, no matter what
		cost_rebuilds = TICK_USAGE_REAL - timer
		if(state != SS_RUNNING)
			return

	if(currentpart == SSAIR_PIPENETS || !resumed)
		timer = TICK_USAGE_REAL
		if(!resumed)
			cached_cost = 0
		process_pipenets(resumed)
		cached_cost += TICK_USAGE_REAL - timer
		if(state != SS_RUNNING)
			return
		cost_pipenets = MC_AVERAGE(cost_pipenets, TICK_DELTA_TO_MS(cached_cost))
		resumed = FALSE
		currentpart = SSAIR_ATMOSMACHINERY

	if(currentpart == SSAIR_ATMOSMACHINERY)
		timer = TICK_USAGE_REAL
		if(!resumed)
			cached_cost = 0
		process_atmos_machinery(resumed)
		cached_cost += TICK_USAGE_REAL - timer
		if(state != SS_RUNNING)
			return
		cost_atmos_machinery = MC_AVERAGE(cost_atmos_machinery, TICK_DELTA_TO_MS(cached_cost))
		resumed = FALSE
		currentpart = SSAIR_ACTIVETURFS

	if(currentpart == SSAIR_ACTIVETURFS)
		timer = TICK_USAGE_REAL
		if(!resumed)
			cached_cost = 0
		process_active_turfs(resumed)
		cached_cost += TICK_USAGE_REAL - timer
		if(state != SS_RUNNING)
			return
		cost_turfs = MC_AVERAGE(cost_turfs, TICK_DELTA_TO_MS(cached_cost))
		resumed = FALSE
		currentpart = SSAIR_HOTSPOTS

	if(currentpart == SSAIR_HOTSPOTS) //We do this before excited groups to allow breakdowns to be independent of adding turfs while still *mostly preventing mass fires
		timer = TICK_USAGE_REAL
		if(!resumed)
			cached_cost = 0
		process_hotspots(resumed)
		cached_cost += TICK_USAGE_REAL - timer
		if(state != SS_RUNNING)
			return
		cost_hotspots = MC_AVERAGE(cost_hotspots, TICK_DELTA_TO_MS(cached_cost))
		resumed = FALSE
		currentpart = SSAIR_EXCITEDGROUPS

	if(currentpart == SSAIR_EXCITEDGROUPS)
		timer = TICK_USAGE_REAL
		if(!resumed)
			cached_cost = 0
		process_excited_groups(resumed)
		cached_cost += TICK_USAGE_REAL - timer
		if(state != SS_RUNNING)
			return
		cost_groups = MC_AVERAGE(cost_groups, TICK_DELTA_TO_MS(cached_cost))
		resumed = FALSE
		currentpart = SSAIR_HIGHPRESSURE

	if(currentpart == SSAIR_HIGHPRESSURE)
		timer = TICK_USAGE_REAL
		if(!resumed)
			cached_cost = 0
		process_high_pressure_delta(resumed)
		cached_cost += TICK_USAGE_REAL - timer
		if(state != SS_RUNNING)
			return
		cost_highpressure = MC_AVERAGE(cost_highpressure, TICK_DELTA_TO_MS(cached_cost))
		resumed = FALSE
		currentpart = SSAIR_SUPERCONDUCTIVITY

	if(currentpart == SSAIR_SUPERCONDUCTIVITY)
		timer = TICK_USAGE_REAL
		if(!resumed)
			cached_cost = 0
		process_super_conductivity(resumed)
		cached_cost += TICK_USAGE_REAL - timer
		if(state != SS_RUNNING)
			return
		cost_superconductivity = MC_AVERAGE(cost_superconductivity, TICK_DELTA_TO_MS(cached_cost))
		resumed = FALSE
		currentpart = SSAIR_PROCESS_ATOMS

	if(currentpart == SSAIR_PROCESS_ATOMS)
		timer = TICK_USAGE_REAL
		if(!resumed)
			cached_cost = 0
		process_atoms(resumed)
		cached_cost += TICK_USAGE_REAL - timer
		if(state != SS_RUNNING)
			return
		cost_atoms = MC_AVERAGE(cost_atoms, TICK_DELTA_TO_MS(cached_cost))
		resumed = FALSE

	currentpart = SSAIR_PIPENETS
	SStgui.update_uis(SSair) //Lightning fast debugging motherfucker

/datum/controller/subsystem/air/Recover()
	excited_groups = SSair.excited_groups
	active_turfs = SSair.active_turfs
	hotspots = SSair.hotspots
	networks = SSair.networks
	rebuild_queue = SSair.rebuild_queue
	expansion_queue = SSair.expansion_queue
	atmos_machinery = SSair.atmos_machinery
	pipe_init_dirs_cache = SSair.pipe_init_dirs_cache
	gas_reactions = SSair.gas_reactions
	atmos_gen = SSair.atmos_gen
	planetary = SSair.planetary
	active_super_conductivity = SSair.active_super_conductivity
	high_pressure_delta = SSair.high_pressure_delta
	atom_process = SSair.atom_process
	currentrun = SSair.currentrun
	queued_for_activation = SSair.queued_for_activation

/datum/controller/subsystem/air/proc/process_pipenets(resumed = FALSE)
	if (!resumed)
		src.currentrun = networks.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun
	while(currentrun.len)
		var/datum/thing = currentrun[length(currentrun)]
		currentrun.len--
		if(thing)
			thing.process()
		else
			networks.Remove(thing)
		if(MC_TICK_CHECK)
			return

/datum/controller/subsystem/air/proc/add_to_rebuild_queue(obj/machinery/atmospherics/atmos_machine)
	if(istype(atmos_machine, /obj/machinery/atmospherics) && !atmos_machine.rebuilding)
		rebuild_queue += atmos_machine
		atmos_machine.rebuilding = TRUE

/datum/controller/subsystem/air/proc/add_to_expansion(datum/pipeline/line, starting_point)
	var/list/new_packet = new(SSAIR_REBUILD_QUEUE)
	new_packet[SSAIR_REBUILD_PIPELINE] = line
	new_packet[SSAIR_REBUILD_QUEUE] = list(starting_point)
	expansion_queue += list(new_packet)

/datum/controller/subsystem/air/proc/remove_from_expansion(datum/pipeline/line)
	for(var/list/packet in expansion_queue)
		if(packet[SSAIR_REBUILD_PIPELINE] == line)
			expansion_queue -= packet
			return

/datum/controller/subsystem/air/proc/process_atoms(resumed = FALSE)
	if(!resumed)
		src.currentrun = atom_process.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun
	while(currentrun.len)
		var/atom/talk_to = currentrun[currentrun.len]
		currentrun.len--
		if(!talk_to)
			return
		talk_to.process_exposure()
		if(MC_TICK_CHECK)
			return

/datum/controller/subsystem/air/proc/process_atmos_machinery(resumed = FALSE)
	if (!resumed)
		src.currentrun = atmos_machinery.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun
	while(currentrun.len)
		var/obj/machinery/M = currentrun[currentrun.len]
		currentrun.len--
		if(!M)
			atmos_machinery -= M
		if(M.process_atmos() == PROCESS_KILL)
			stop_processing_machine(M)
		if(MC_TICK_CHECK)
			return


/datum/controller/subsystem/air/proc/process_super_conductivity(resumed = FALSE)
	if (!resumed)
		src.currentrun = active_super_conductivity.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun
	while(currentrun.len)
		var/turf/T = currentrun[currentrun.len]
		currentrun.len--
		T.super_conduct()
		if(MC_TICK_CHECK)
			return

/datum/controller/subsystem/air/proc/process_hotspots(resumed = FALSE)
	if (!resumed)
		src.currentrun = hotspots.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun
	while(currentrun.len)
		var/obj/effect/hotspot/H = currentrun[currentrun.len]
		currentrun.len--
		if (H)
			H.process()
		else
			hotspots -= H
		if(MC_TICK_CHECK)
			return

/datum/controller/subsystem/air/proc/process_high_pressure_delta(resumed = FALSE)
	while (high_pressure_delta.len)
		var/turf/open/T = high_pressure_delta[high_pressure_delta.len]
		high_pressure_delta.len--
		T.high_pressure_movements()
		T.pressure_difference = 0
		if(MC_TICK_CHECK)
			return

/datum/controller/subsystem/air/proc/process_active_turfs(resumed = FALSE)
	//cache for sanic speed
	var/fire_count = times_fired
	if (!resumed)
		src.currentrun = active_turfs.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun
	while(currentrun.len)
		var/turf/open/T = currentrun[currentrun.len]
		currentrun.len--
		if (T)
			T.process_cell(fire_count)
		if (MC_TICK_CHECK)
			return

/datum/controller/subsystem/air/proc/process_excited_groups(resumed = FALSE)
	if (!resumed)
		src.currentrun = excited_groups.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun
	while(currentrun.len)
		var/datum/excited_group/EG = currentrun[currentrun.len]
		currentrun.len--
		EG.breakdown_cooldown++
		EG.dismantle_cooldown++
		if(EG.breakdown_cooldown >= EXCITED_GROUP_BREAKDOWN_CYCLES)
			EG.self_breakdown(poke_turfs = TRUE)
		else if(EG.dismantle_cooldown >= EXCITED_GROUP_DISMANTLE_CYCLES)
			EG.dismantle()
		if (MC_TICK_CHECK)
			return

/datum/controller/subsystem/air/proc/process_rebuilds()
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
			var/datum/pipeline/linepipe = pack[SSAIR_REBUILD_PIPELINE]
			var/list/border = pack[SSAIR_REBUILD_QUEUE]
			expand_pipeline(linepipe, border)
			if(state != SS_RUNNING) //expand_pipeline can fail a tick check, we shouldn't let things get too fucky here
				return

			linepipe.building = FALSE
			queue.len--
			if (MC_TICK_CHECK)
				return

///Rebuilds a pipeline by expanding outwards, while yielding when sane
/datum/controller/subsystem/air/proc/expand_pipeline(datum/pipeline/net, list/border)
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

///Removes a turf from processing, and causes its excited group to clean up so things properly adapt to the change
/datum/controller/subsystem/air/proc/remove_from_active(turf/open/T)
	active_turfs -= T
	if(currentpart == SSAIR_ACTIVETURFS)
		currentrun -= T
	#ifdef VISUALIZE_ACTIVE_TURFS //Use this when you want details about how the turfs are moving, display_all_groups should work for normal operation
	T.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, COLOR_VIBRANT_LIME)
	#endif
	if(istype(T))
		T.excited = FALSE
		if(T.excited_group)
			//If this fires during active turfs it'll cause a slight removal of active turfs, as they breakdown if they have no excited group
			//The group also expands by a tile per rebuild on each edge, suffering
			T.excited_group.garbage_collect() //Kill the excited group, it'll reform on its own later

///Puts an active turf to sleep so it doesn't process. Do this without cleaning up its excited group.
/datum/controller/subsystem/air/proc/sleep_active_turf(turf/open/T)
	active_turfs -= T
	if(currentpart == SSAIR_ACTIVETURFS)
		currentrun -= T
	#ifdef VISUALIZE_ACTIVE_TURFS
	T.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, COLOR_VIBRANT_LIME)
	#endif
	if(istype(T))
		T.excited = FALSE

///Adds a turf to active processing, handles duplicates. Call this with blockchanges == TRUE if you want to nuke the assoc excited group
/datum/controller/subsystem/air/proc/add_to_active(turf/open/T, blockchanges = FALSE)
	if(istype(T) && T.air)
		T.significant_share_ticker = 0
		if(blockchanges && T.excited_group) //This is used almost exclusivly for shuttles, so the excited group doesn't stay behind
			T.excited_group.garbage_collect() //Nuke it
		if(T.excited) //Don't keep doing it if there's no point
			return
		#ifdef VISUALIZE_ACTIVE_TURFS
		T.add_atom_colour(COLOR_VIBRANT_LIME, TEMPORARY_COLOUR_PRIORITY)
		#endif
		T.excited = TRUE
		active_turfs += T
		if(currentpart == SSAIR_ACTIVETURFS)
			currentrun += T
	else if(T.flags_1 & INITIALIZED_1)
		for(var/turf/S in T.atmos_adjacent_turfs)
			add_to_active(S, TRUE)
	else if(map_loading)
		if(queued_for_activation)
			queued_for_activation[T] = T
		return
	else
		T.requires_activation = TRUE

/datum/controller/subsystem/air/StartLoadingMap()
	LAZYINITLIST(queued_for_activation)
	map_loading = TRUE

/datum/controller/subsystem/air/StopLoadingMap()
	map_loading = FALSE
	for(var/T in queued_for_activation)
		add_to_active(T, TRUE)
	queued_for_activation.Cut()

/datum/controller/subsystem/air/proc/setup_allturfs()
	var/list/turfs_to_init = block(locate(1, 1, 1), locate(world.maxx, world.maxy, world.maxz))
	var/list/active_turfs = src.active_turfs
	var/times_fired = ++src.times_fired

	// Clear active turfs - faster than removing every single turf in the world
	// one-by-one, and Initalize_Atmos only ever adds `src` back in.
	#ifdef VISUALIZE_ACTIVE_TURFS
	for(var/jumpy in active_turfs)
		var/turf/active = jumpy
		active.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, COLOR_VIBRANT_LIME)
	#endif
	active_turfs.Cut()

	for(var/thing in turfs_to_init)
		var/turf/T = thing
		if (T.blocks_air)
			continue
		T.Initalize_Atmos(times_fired)
		CHECK_TICK

	if(active_turfs.len)
		var/starting_ats = active_turfs.len
		sleep(world.tick_lag)
		var/timer = world.timeofday
		log_mapping("There are [starting_ats] active turfs at roundstart caused by a difference of the air between the adjacent turfs. You can see its coordinates using \"Mapping -> Show roundstart AT list\" verb (debug verbs required).")
		for(var/turf/T in active_turfs)
			GLOB.active_turfs_startlist += T

		//now lets clear out these active turfs
		var/list/turfs_to_check = active_turfs.Copy()
		do
			var/list/new_turfs_to_check = list()
			for(var/turf/open/T in turfs_to_check)
				new_turfs_to_check += T.resolve_active_graph()
			CHECK_TICK

			active_turfs += new_turfs_to_check
			turfs_to_check = new_turfs_to_check

		while (turfs_to_check.len)
		var/ending_ats = active_turfs.len
		for(var/thing in excited_groups)
			var/datum/excited_group/EG = thing
			EG.self_breakdown(roundstart = TRUE)
			EG.dismantle()
			CHECK_TICK

		var/msg = "HEY! LISTEN! [DisplayTimeText(world.timeofday - timer)] were wasted processing [starting_ats] turf(s) (connected to [ending_ats - starting_ats] other turfs) with atmos differences at round start."
		to_chat(world, span_boldannounce("[msg]"))
		warning(msg)

/turf/open/proc/resolve_active_graph()
	. = list()
	var/datum/excited_group/EG = excited_group
	if (blocks_air || !air)
		return
	if (!EG)
		EG = new
		EG.add_turf(src)

	for (var/turf/open/ET as anything in atmos_adjacent_turfs)
		if (ET.blocks_air || !ET.air)
			continue

		var/ET_EG = ET.excited_group
		if (ET_EG)
			if (ET_EG != EG)
				EG.merge_groups(ET_EG)
				EG = excited_group //merge_groups() may decide to replace our current EG
		else
			EG.add_turf(ET)
		if (!ET.excited)
			ET.excited = TRUE
			. += ET

/turf/open/space/resolve_active_graph()
	return list()

/datum/controller/subsystem/air/proc/setup_atmos_machinery()
	for (var/obj/machinery/atmospherics/AM in atmos_machinery)
		AM.atmos_init()
		CHECK_TICK

//this can't be done with setup_atmos_machinery() because
// all atmos machinery has to initalize before the first
// pipenet can be built.
/datum/controller/subsystem/air/proc/setup_pipenets()
	for (var/obj/machinery/atmospherics/AM in atmos_machinery)
		var/list/targets = AM.get_rebuild_targets()
		for(var/datum/pipeline/build_off as anything in targets)
			build_off.build_pipeline_blocking(AM)
		CHECK_TICK

GLOBAL_LIST_EMPTY(colored_turfs)
GLOBAL_LIST_EMPTY(colored_images)
/datum/controller/subsystem/air/proc/setup_turf_visuals()
	for(var/sharp_color in GLOB.contrast_colors)
		var/obj/effect/overlay/atmos_excited/suger_high = new()
		GLOB.colored_turfs += suger_high
		var/image/shiny = new('icons/effects/effects.dmi', suger_high, "atmos_top")
		shiny.plane = ATMOS_GROUP_PLANE
		shiny.color = sharp_color
		GLOB.colored_images += shiny

/datum/controller/subsystem/air/proc/setup_template_machinery(list/atmos_machines)
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


/datum/controller/subsystem/air/proc/get_init_dirs(type, dir, init_dir)

	if(!pipe_init_dirs_cache[type])
		pipe_init_dirs_cache[type] = list()

	if(!pipe_init_dirs_cache[type]["[init_dir]"])
		pipe_init_dirs_cache[type]["[init_dir]"] = list()

	if(!pipe_init_dirs_cache[type]["[init_dir]"]["[dir]"])
		var/obj/machinery/atmospherics/temp = new type(null, FALSE, dir, init_dir)
		pipe_init_dirs_cache[type]["[init_dir]"]["[dir]"] = temp.get_init_directions()
		qdel(temp)

	return pipe_init_dirs_cache[type]["[init_dir]"]["[dir]"]

/datum/controller/subsystem/air/proc/generate_atmos()
	atmos_gen = list()
	for(var/T in subtypesof(/datum/atmosphere))
		var/datum/atmosphere/atmostype = T
		atmos_gen[initial(atmostype.id)] = new atmostype

/datum/controller/subsystem/air/proc/preprocess_gas_string(gas_string)
	if(!atmos_gen)
		generate_atmos()
	if(!atmos_gen[gas_string])
		return gas_string
	var/datum/atmosphere/mix = atmos_gen[gas_string]
	return mix.gas_string

/**
 * Adds a given machine to the processing system for SSAIR_ATMOSMACHINERY processing.
 *
 * Arguments:
 * * machine - The machine to start processing. Can be any /obj/machinery.
 */
/datum/controller/subsystem/air/proc/start_processing_machine(obj/machinery/machine)
	if(machine.atmos_processing)
		return
	if(QDELETED(machine))
		stack_trace("We tried to add a garbage collecting machine to SSair. Don't")
		return
	machine.atmos_processing = TRUE
	atmos_machinery += machine

/**
 * Removes a given machine to the processing system for SSAIR_ATMOSMACHINERY processing.
 *
 * Arguments:
 * * machine - The machine to stop processing.
 */
/datum/controller/subsystem/air/proc/stop_processing_machine(obj/machinery/machine)
	if(!machine.atmos_processing)
		return
	machine.atmos_processing = FALSE
	atmos_machinery -= machine

	// If we're currently processing atmos machines, there's a chance this machine is in
	// the currentrun list, which is a cache of atmos_machinery. Remove it from that list
	// as well to prevent processing qdeleted objects in the cache.
	if(currentpart == SSAIR_ATMOSMACHINERY)
		currentrun -= machine

/datum/controller/subsystem/air/ui_state(mob/user)
	return GLOB.debug_state

/datum/controller/subsystem/air/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AtmosControlPanel")
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/controller/subsystem/air/ui_data(mob/user)
	var/list/data = list()
	data["excited_groups"] = list()
	for(var/datum/excited_group/group in excited_groups)
		var/turf/T = group.turf_list[1]
		var/area/target = get_area(T)
		var/max = 0
		#ifdef TRACK_MAX_SHARE
		for(var/who in group.turf_list)
			var/turf/open/lad = who
			max = max(lad.max_share, max)
		#endif
		data["excited_groups"] += list(list(
			"jump_to" = REF(T), //Just go to the first turf
			"group" = REF(group),
			"area" = target.name,
			"breakdown" = group.breakdown_cooldown,
			"dismantle" = group.dismantle_cooldown,
			"size" = group.turf_list.len,
			"should_show" = group.should_display,
			"max_share" = max
		))
	data["active_size"] = active_turfs.len
	data["hotspots_size"] = hotspots.len
	data["excited_size"] = excited_groups.len
	data["conducting_size"] = active_super_conductivity.len
	data["frozen"] = can_fire
	data["show_all"] = display_all_groups
	data["fire_count"] = times_fired
	#ifdef TRACK_MAX_SHARE
	data["display_max"] = TRUE
	#else
	data["display_max"] = FALSE
	#endif
	var/atom/movable/screen/plane_master/plane = user.hud_used.plane_masters["[ATMOS_GROUP_PLANE]"]
	data["showing_user"] = (plane.alpha == 255)
	return data

/datum/controller/subsystem/air/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(. || !check_rights_for(usr.client, R_DEBUG))
		return
	switch(action)
		if("move-to-target")
			var/turf/target = locate(params["spot"])
			if(!target)
				return
			usr.forceMove(target)
			usr.update_parallax_contents()
		if("toggle-freeze")
			can_fire = !can_fire
			return TRUE
		if("toggle_show_group")
			var/datum/excited_group/group = locate(params["group"])
			if(!group)
				return
			group.should_display = !group.should_display
			if(display_all_groups)
				return TRUE
			if(group.should_display)
				group.display_turfs()
			else
				group.hide_turfs()
			return TRUE
		if("toggle_show_all")
			display_all_groups = !display_all_groups
			for(var/datum/excited_group/group in excited_groups)
				if(display_all_groups)
					group.display_turfs()
				else if(!group.should_display) //Don't flicker yeah?
					group.hide_turfs()
			return TRUE
		if("toggle_user_display")
			var/atom/movable/screen/plane_master/plane = ui.user.hud_used.plane_masters["[ATMOS_GROUP_PLANE]"]
			if(!plane.alpha)
				if(ui.user.client)
					ui.user.client.images += GLOB.colored_images
				plane.alpha = 255
			else
				if(ui.user.client)
					ui.user.client.images -= GLOB.colored_images
				plane.alpha = 0
			return TRUE
