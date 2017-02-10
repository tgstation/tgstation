var/datum/subsystem/processing/air/SSair

/datum/subsystem/processing/air
	name = "Air"
	init_order = -1
	priority = 20
	wait = 5
	flags = SS_BACKGROUND
	display_order = 1

	processing_list = null	//we have a special fire

	var/cost_turfs = 0
	var/cost_groups = 0
	var/cost_highpressure = 0
	var/cost_hotspots = 0
	var/cost_superconductivity = 0
	var/cost_pipenets = 0
	var/cost_atmos_machinery = 0

	var/list/excited_groups = list()
	var/list/active_turfs = list()
	var/list/hotspots = list()
	var/list/networks = list()
	var/list/atmos_machinery = list()
	var/list/active_super_conductivity = list()
	var/list/high_pressure_delta = list()

	//processing delegates
	var/process_atmos_delegate = /obj/machinery/.proc/process_atmos
	var/high_pressure_delegate = /turf/open/.proc/high_pressure_movements
	var/super_conduct_delegate = /turf/.proc/super_conduct

	var/currentpart = SSAIR_PIPENETS
 
	var/map_loading = TRUE
	var/list/queued_for_activation

/datum/subsystem/processing/air/New()
	NEW_SS_GLOBAL(SSair)

/datum/subsystem/processing/air/stat_entry(msg)
	msg += "C:{"
	msg += "AT:[round(cost_turfs)]|"
	msg += "EG:[round(cost_groups)]|"
	msg += "HP:[round(cost_highpressure)]|"
	msg += "HS:[round(cost_hotspots)]|"
	msg += "SC:[round(cost_superconductivity)]|"
	msg += "PN:[round(cost_pipenets)]|"
	msg += "AM:[round(cost_atmos_machinery)]"
	msg += "} "
	msg +=  "AT:[active_turfs.len]|"
	msg +=  "EG:[excited_groups.len]|"
	msg +=  "HS:[hotspots.len]|"
	msg +=  "AS:[active_super_conductivity.len]"
	..(msg, TRUE)

/datum/subsystem/processing/air/Initialize(timeofday)
	map_loading = FALSE
	setup_allturfs()
	setup_atmos_machinery()
	setup_pipenets()
	..()

/datum/subsystem/processing/air/Recover()
	currentpart = SSair.currentpart
	excited_groups = SSair.excited_groups
	active_turfs = SSair.active_turfs
	hotspots = SSair.hotspots
	networks = SSair.networks
	atmos_machinery = SSair.atmos_machinery
	active_super_conductivity = SSair.active_super_conductivity
	high_pressure_delta = SSair.high_pressure_delta
	..(SSair)

#define PROCESS_ATMOS_LIST_NO_CHECK(L, nextpart, deleg, cost_var, argument)\
	timer = world.tick_usage;\
	processing_list = L;\
	delegate = deleg;\
	..(resumed, argument);\
	cost_var = MC_AVERAGE(cost_var, TICK_DELTA_TO_MS(world.tick_usage - timer));\
	if(state != SS_RUNNING) { return; }\
	resumed = FALSE;\
	currentpart = nextpart;

#define PROCESS_ATMOS_LIST(L, cpart, nextpart, deleg, cost_var, argument) if(currentpart == cpart) { PROCESS_ATMOS_LIST_NO_CHECK(L, nextpart, deleg, cost_var, argument) }

/datum/subsystem/processing/air/fire(resumed = 0)
	var/timer

	if(!resumed || currentpart == SSAIR_PIPENETS)
		PROCESS_ATMOS_LIST_NO_CHECK(networks, SSAIR_ATMOSMACHINERY, null, cost_pipenets, null)

	PROCESS_ATMOS_LIST(atmos_machinery, SSAIR_ATMOSMACHINERY, SSAIR_ACTIVETURFS, process_atmos_delegate, cost_atmos_machinery, wait * 0.1)

	PROCESS_ATMOS_LIST(active_turfs, SSAIR_ACTIVETURFS, SSAIR_EXCITEDGROUPS, null, cost_turfs, times_fired)

	PROCESS_ATMOS_LIST(excited_groups, SSAIR_EXCITEDGROUPS, SSAIR_HIGHPRESSURE, null, cost_groups, null)

	PROCESS_ATMOS_LIST(high_pressure_delta, SSAIR_HIGHPRESSURE, SSAIR_HOTSPOTS, high_pressure_delegate, cost_highpressure, null)
	
	PROCESS_ATMOS_LIST(hotspots, SSAIR_HOTSPOTS, SSAIR_SUPERCONDUCTIVITY, null, cost_hotspots, null)

	PROCESS_ATMOS_LIST(active_super_conductivity, SSAIR_SUPERCONDUCTIVITY, SSAIR_PIPENETS, super_conduct_delegate, cost_superconductivity, null)

#undef PROCESS_ATMOS_LIST_NO_CHECK
#undef PROCESS_ATMOS_LIST

/datum/subsystem/processing/air/start_processing(datum/D, list_type, add_to_active_block_changes = TRUE)
	var/added = TRUE
	//most of these are safe (re: only called in one place) to just +=
	switch(list_type)
		if(SSAIR_PIPENETS)
			networks += D
		if(SSAIR_ATMOSMACHINERY)
			atmos_machinery += D
		if(SSAIR_ACTIVETURFS)	//except this
			var/turf/open/T = D
			if(istype(T) && T.air)
				T.excited = 1
				active_turfs[T] = T
				if(add_to_active_block_changes && T.excited_group)
					T.excited_group.garbage_collect()
				return
			else if(T.initialized)
				for(var/S in T.atmos_adjacent_turfs)	//this was typed as var/turf/S before, any reason for that?
					start_processing(S, SSAIR_ACTIVETURFS)
			else if(map_loading)
				if(queued_for_activation)
					queued_for_activation[T] = T
			else
				T.requires_activation = TRUE
			added = FALSE
		if(SSAIR_EXCITEDGROUPS)
			excited_groups += D
		if(SSAIR_HIGHPRESSURE)	//and this
			high_pressure_delta[D] = D
		if(SSAIR_HOTSPOTS)
			hotspots += D
		if(SSAIR_SUPERCONDUCTIVITY)
			active_super_conductivity += D
		else
			CRASH("SSair/start_processing: Invalid list_type: [list_type]")

/datum/subsystem/processing/air/stop_processing(datum/D, list_type)
	if(list_type == TRUE)	//called by base fire
		list_type = currentpart
	else if(currentpart == list_type)
		run_cache -= D

	switch(list_type)
		if(SSAIR_PIPENETS)
			networks -= D
		if(SSAIR_ATMOSMACHINERY)
			atmos_machinery -= D
		if(SSAIR_ACTIVETURFS)
			var/turf/open/T = D
			src.active_turfs -= T
			if(istype(T))
				T.excited = 0
				if(T.excited_group)
					T.excited_group.garbage_collect()
		if(SSAIR_EXCITEDGROUPS)
			excited_groups -= D
		if(SSAIR_HIGHPRESSURE)
			high_pressure_delta -= D
		if(SSAIR_HOTSPOTS)
			hotspots -= D
		if(SSAIR_SUPERCONDUCTIVITY)
			active_super_conductivity -= D
		else
			CRASH("SSair/stop_processing: Invalid list_type: [list_type]")

/datum/subsystem/processing/air/proc/begin_map_load()
	LAZYINITLIST(queued_for_activation)
	map_loading = TRUE
 
 
/datum/subsystem/processing/air/proc/end_map_load()
	map_loading = FALSE
	for(var/T in queued_for_activation)
		START_ATMOS_PROCESSING(T, SSAIR_ACTIVETURFS)
	queued_for_activation.Cut()

/datum/subsystem/processing/air/proc/setup_allturfs()
	var/list/turfs_to_init = block(locate(1, 1, 1), locate(world.maxx, world.maxy, world.maxz))
	var/list/active_turfs = src.active_turfs
	var/times_fired = ++src.times_fired

	for(var/thing in turfs_to_init)
		var/turf/T = thing
		active_turfs -= T
		if (T.blocks_air)
			continue
		T.Initalize_Atmos(times_fired)
		CHECK_TICK

	if(active_turfs.len)
		var/starting_ats = active_turfs.len
		sleep(world.tick_lag)
		var/timer = world.timeofday
		warning("There are [starting_ats] active turfs at roundstart, this is a mapping error caused by a difference of the air between the adjacent turfs. You can see its coordinates using \"Mapping -> Show roundstart AT list\" verb (debug verbs required)")
		for(var/turf/T in active_turfs)
			active_turfs_startlist += text("[T.x], [T.y], [T.z]\n")

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
			EG.self_breakdown(space_is_all_consuming = 1)
			EG.dismantle()
			CHECK_TICK

		var/msg = "HEY! LISTEN! [(world.timeofday - timer)/10] Seconds were wasted processing [starting_ats] turf(s) (connected to [ending_ats] other turfs) with atmos differences at round start."
		world << "<span class='boldannounce'>[msg]</span>"
		warning(msg)

/turf/open/proc/resolve_active_graph()
	. = list()
	var/datum/excited_group/EG = excited_group
	if (blocks_air || !air)
		return
	if (!EG)
		EG = new
		EG.add_turf(src)

	for (var/turf/open/ET in atmos_adjacent_turfs)
		if ( ET.blocks_air || !ET.air)
			continue

		var/ET_EG = ET.excited_group
		if (ET_EG)
			if (ET_EG != EG)
				EG.merge_groups(ET_EG)
				EG = excited_group //merge_groups() may decide to replace our current EG
		else
			EG.add_turf(ET)
		if (!ET.excited)
			ET.excited = 1
			. += ET
/turf/open/space/resolve_active_graph()
	return list()

/datum/subsystem/processing/air/proc/setup_atmos_machinery()
	for (var/obj/machinery/atmospherics/AM in atmos_machinery)
		AM.atmosinit()
		CHECK_TICK

//this can't be done with setup_atmos_machinery() because
//	all atmos machinery has to initalize before the first
//	pipenet can be built.
/datum/subsystem/processing/air/proc/setup_pipenets()
	for (var/obj/machinery/atmospherics/AM in atmos_machinery)
		AM.build_network()
		CHECK_TICK

/datum/subsystem/processing/air/proc/setup_template_machinery(list/atmos_machines)
	for(var/A in atmos_machines)
		var/obj/machinery/atmospherics/AM = A
		AM.atmosinit()
		CHECK_TICK

	for(var/A in atmos_machines)
		var/obj/machinery/atmospherics/AM = A
		AM.build_network()
		CHECK_TICK