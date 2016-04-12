#define SSAIR_PIPENETS 1
#define SSAIR_ATMOSMACHINERY 2
#define SSAIR_ACTIVETURFS 3
#define SSAIR_EXCITEDGROUPS 4
#define SSAIR_HIGHPRESSURE 5
#define SSAIR_HOTSPOTS 6
#define SSAIR_SUPERCONDUCTIVITY 7
var/datum/subsystem/air/SSair

/datum/subsystem/air
	name = "Air"
	priority = -1
	wait = 5
	dynamic_wait = 1
	dwait_upper = 300
	dwait_delta = 7
	display = 1

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
	var/list/obj/machinery/atmos_machinery = list()


	//Special functions lists
	var/list/turf/active_super_conductivity = list()
	var/list/turf/open/high_pressure_delta = list()


	var/list/currentrun = list()
	var/currentpart = SSAIR_PIPENETS


/datum/subsystem/air/New()
	NEW_SS_GLOBAL(SSair)

/datum/subsystem/air/stat_entry(msg)
	msg += "C:{"
	msg += "AT:[round(cost_turfs,0.01)]|"
	msg += "EG:[round(cost_groups,0.01)]|"
	msg += "HP:[round(cost_highpressure,0.01)]|"
	msg += "HS:[round(cost_hotspots,0.01)]|"
	msg += "SC:[round(cost_superconductivity,0.01)]|"
	msg += "PN:[round(cost_pipenets,0.01)]|"
	msg += "AM:[round(cost_atmos_machinery,0.01)]"
	msg += "} "
	msg +=  "AT:[active_turfs.len]|"
	msg +=  "EG:[excited_groups.len]|"
	msg +=  "HS:[hotspots.len]|"
	msg +=  "AS:[active_super_conductivity.len]"
	..(msg)


/datum/subsystem/air/Initialize(timeofday, zlevel)
	setup_allturfs(zlevel)
	setup_atmos_machinery(zlevel)
	setup_pipenets(zlevel)
	..()

#define MC_AVERAGE(average, current) (0.8*(average) + 0.2*(current))
/datum/subsystem/air/fire(resumed = 0)
	var/timer = world.timeofday

	if(currentpart == SSAIR_PIPENETS || !resumed)
		process_pipenets(resumed)
		cost_pipenets = MC_AVERAGE(cost_pipenets, (world.timeofday - timer))
		if(paused)
			return
		resumed = 0
		currentpart = SSAIR_ATMOSMACHINERY

	if(currentpart == SSAIR_ATMOSMACHINERY)
		timer = world.timeofday
		process_atmos_machinery(resumed)
		cost_atmos_machinery = MC_AVERAGE(cost_atmos_machinery, (world.timeofday - timer))
		if(paused)
			return
		resumed = 0
		currentpart = SSAIR_ACTIVETURFS

	if(currentpart == SSAIR_ACTIVETURFS)
		timer = world.timeofday
		process_active_turfs(resumed)
		cost_turfs = MC_AVERAGE(cost_turfs, (world.timeofday - timer))
		if(paused)
			return
		resumed = 0
		currentpart = SSAIR_EXCITEDGROUPS

	if(currentpart == SSAIR_EXCITEDGROUPS)
		timer = world.timeofday
		process_excited_groups(resumed)
		cost_groups = MC_AVERAGE(cost_groups, (world.timeofday - timer))
		if(paused)
			return
		resumed = 0
		currentpart = SSAIR_HIGHPRESSURE

	if(currentpart == SSAIR_HIGHPRESSURE)
		timer = world.timeofday
		process_high_pressure_delta(resumed)
		cost_highpressure = MC_AVERAGE(cost_highpressure, (world.timeofday - timer))
		if(paused)
			return
		resumed = 0
		currentpart = SSAIR_HOTSPOTS

	if(currentpart == SSAIR_HOTSPOTS)
		timer = world.timeofday
		process_hotspots(resumed)
		cost_hotspots = MC_AVERAGE(cost_hotspots, (world.timeofday - timer))
		if(paused)
			return
		resumed = 0
		currentpart = SSAIR_SUPERCONDUCTIVITY

	if(currentpart == SSAIR_SUPERCONDUCTIVITY)
		timer = world.timeofday
		process_super_conductivity(resumed)
		cost_superconductivity = MC_AVERAGE(cost_superconductivity, (world.timeofday - timer))
		if(paused)
			return
		resumed = 0
	currentpart = SSAIR_PIPENETS

#undef MC_AVERAGE


/datum/subsystem/air/proc/process_pipenets(resumed = 0)
	if (!resumed)
		src.currentrun = networks.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun
	while(currentrun.len)
		var/datum/thing = currentrun[1]
		currentrun.Cut(1, 2)
		if(thing)
			thing.process()
		else
			networks.Remove(thing)
		if(MC_TICK_CHECK)
			return


/datum/subsystem/air/proc/process_atmos_machinery(resumed = 0)
	var/seconds = wait * 0.1
	if (!resumed)
		src.currentrun = atmos_machinery.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun
	while(currentrun.len)
		var/obj/machinery/M = currentrun[1]
		currentrun.Cut(1, 2)
		if(!M || (M.process_atmos(seconds) == PROCESS_KILL))
			atmos_machinery.Remove(M)
		if(MC_TICK_CHECK)
			return


/datum/subsystem/air/proc/process_super_conductivity(resumed = 0)
	if (!resumed)
		src.currentrun = active_super_conductivity.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun
	while(currentrun.len)
		var/turf/T = currentrun[1]
		currentrun.Cut(1, 2)
		T.super_conduct()
		if(MC_TICK_CHECK)
			return

/datum/subsystem/air/proc/process_hotspots(resumed = 0)
	if (!resumed)
		src.currentrun = hotspots.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun
	while(currentrun.len)
		var/obj/effect/hotspot/H = currentrun[1]
		currentrun.Cut(1, 2)
		if (H)
			H.process()
		else
			hotspots -= H
		if(MC_TICK_CHECK)
			return


/datum/subsystem/air/proc/process_high_pressure_delta(resumed = 0)
	while (high_pressure_delta.len)
		var/turf/open/T = high_pressure_delta[1]
		high_pressure_delta.Cut(1,2)
		T.high_pressure_movements()
		T.pressure_difference = 0
		if(MC_TICK_CHECK)
			return

/datum/subsystem/air/proc/process_active_turfs(resumed = 0)
	//cache for sanic speed
	var/fire_count = times_fired
	if (!resumed)
		src.currentrun = active_turfs.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun
	while(currentrun.len)
		var/turf/open/T = currentrun[1]
		currentrun.Cut(1, 2)
		if (T)
			T.process_cell(fire_count)
		if (MC_TICK_CHECK)
			return

/datum/subsystem/air/proc/process_excited_groups(resumed = 0)
	if (!resumed)
		src.currentrun = excited_groups.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun
	while(currentrun.len)
		var/datum/excited_group/EG = currentrun[1]
		currentrun.Cut(1, 2)
		EG.breakdown_cooldown++
		EG.dismantle_cooldown++
		if(EG.breakdown_cooldown >= EXCITED_GROUP_BREAKDOWN_CYCLES)
			EG.self_breakdown()
		else if(EG.dismantle_cooldown >= EXCITED_GROUP_DISMANTLE_CYCLES)
			EG.dismantle()
		if (MC_TICK_CHECK)
			return


/datum/subsystem/air/proc/remove_from_active(turf/open/T)
	active_turfs -= T
	if(istype(T))
		T.excited = 0
		if(T.excited_group)
			T.excited_group.garbage_collect()


/datum/subsystem/air/proc/add_to_active(turf/open/T, blockchanges = 1)
	if(istype(T) && T.air)
		T.excited = 1
		active_turfs |= T
		if(blockchanges && T.excited_group)
			T.excited_group.garbage_collect()
	else
		for(var/turf/S in T.atmos_adjacent_turfs)
			add_to_active(S)


/datum/subsystem/air/proc/setup_allturfs(z_level)
	var/z_start = 1
	var/z_finish = world.maxz
	var/times_fired = ++src.times_fired
	if(1 <= z_level && z_level <= world.maxz)
		z_level = round(z_level)
		z_start = z_level
		z_finish = z_level

	var/list/turfs_to_init = block(locate(1, 1, z_start), locate(world.maxx, world.maxy, z_finish))
	var/list/active_turfs = src.active_turfs

	for(var/thing in turfs_to_init)
		var/turf/T = thing
		active_turfs -= T
		T.Initalize_Atmos(times_fired)


	if(active_turfs.len)
		warning("There are [active_turfs.len] active turfs at roundstart, this is a mapping error caused by a difference of the air between the adjacent turfs. You can see its coordinates using \"Mapping -> Show roundstart AT list\" verb (debug verbs required)")
		for(var/turf/T in active_turfs)
			active_turfs_startlist += text("[T.x], [T.y], [T.z]\n")

/datum/subsystem/air/proc/setup_atmos_machinery(z_level)
	for (var/obj/machinery/atmospherics/AM in atmos_machinery)
		if (z_level && AM.z != z_level)
			CHECK_TICK
			continue
		AM.atmosinit()
		CHECK_TICK

//this can't be done with setup_atmos_machinery() because
//	all atmos machinery has to initalize before the first
//	pipenet can be built.
/datum/subsystem/air/proc/setup_pipenets(z_level)
	for (var/obj/machinery/atmospherics/AM in atmos_machinery)
		if (z_level && AM.z != z_level)
			CHECK_TICK
			continue
		AM.build_network()
		CHECK_TICK

/datum/subsystem/air/proc/setup_template_machinery(list/atmos_machines)
	for(var/A in atmos_machines)
		var/obj/machinery/atmospherics/AM = A
		AM.atmosinit()
		CHECK_TICK

	for(var/A in atmos_machines)
		var/obj/machinery/atmospherics/AM = A
		AM.build_network()
		CHECK_TICK


#undef SSAIR_PIPENETS
#undef SSAIR_ATMOSMACHINERY
#undef SSAIR_ACTIVETURFS
#undef SSAIR_EXCITEDGROUPS
#undef SSAIR_HIGHPRESSURE
#undef SSAIR_HOTSPOT
#undef SSAIR_SUPERCONDUCTIVITY
