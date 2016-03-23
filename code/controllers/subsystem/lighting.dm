var/datum/subsystem/lighting/SSlighting

#define MC_AVERAGE(average, current) (0.8*(average) + 0.2*(current))

/datum/subsystem/lighting
	name = "Lighting"
	priority = 1
	wait = 6
	display = 5

	var/list/changed_lights = list()		//list of all datum/light_source that need updating
	var/changed_lights_workload = 0			//stats on the largest number of lights (max changed_lights.len)
	var/list/changed_turfs = list()			//list of all turfs which may have a different light level
	var/changed_turfs_workload = 0			//stats on the largest number of turfs changed (max changed_turfs.len)


/datum/subsystem/lighting/New()
	NEW_SS_GLOBAL(SSlighting)

	return ..()


/datum/subsystem/lighting/stat_entry()
	..("L:[round(changed_lights_workload,1)]|T:[round(changed_turfs_workload,1)]")


//Workhorse of lighting. It cycles through each light that needs updating. It updates their
//effects and then processes every turf in the queue, updating their lighting object's appearance
//Any light that returns 1 in check() deletes itself
//By using queues we are ensuring we don't perform more updates than are necessary
/datum/subsystem/lighting/fire(resumed = 0)
	var/list/changed_lights = src.changed_lights
	if (!resumed)
		changed_lights_workload = MC_AVERAGE(changed_lights_workload, changed_lights.len)
	while (changed_lights.len)
		var/datum/light_source/LS = changed_lights[1]
		changed_lights.Cut(1, 2)
		LS.check()
		if (MC_TICK_CHECK)
			return

	var/list/changed_turfs = src.changed_turfs
	if (!resumed)
		changed_turfs_workload = MC_AVERAGE(changed_turfs_workload, changed_turfs.len)
	while (changed_turfs.len)
		var/turf/T = changed_turfs[1]
		changed_turfs.Cut(1, 2)
		if(T.lighting_changed)
			T.redraw_lighting()
		if (MC_TICK_CHECK)
			return

//same as above except it attempts to shift ALL turfs in the world regardless of lighting_changed status
//Does not loop. Should be run prior to process() being called for the first time.
//Note: if we get additional z-levels at runtime (e.g. if the gateway thin ever gets finished) we can initialize specific
//z-levels with the z_level argument
/datum/subsystem/lighting/Initialize(timeofday, z_level)
	for(var/area/A in world)
		if (A.lighting_use_dynamic == DYNAMIC_LIGHTING_IFSTARLIGHT)
			if (config.starlight)
				A.SetDynamicLighting()
		CHECK_TICK


	for(var/thing in changed_lights)
		var/datum/light_source/LS = thing
		LS.check()
		CHECK_TICK
	changed_lights.Cut()

	var/z_start = 1
	var/z_finish = world.maxz
	if(z_level >= 1 && z_level <= world.maxz)
		z_level = round(z_level)
		z_start = z_level
		z_finish = z_level

	var/list/turfs_to_init = block(locate(1, 1, z_start), locate(world.maxx, world.maxy, z_finish))

	for(var/thing in turfs_to_init)
		var/turf/T = thing
		T.init_lighting()
		CHECK_TICK

	if(z_level)
		//we need to loop through to clear only shifted turfs from the list. or we will cause errors
		for(var/thing in changed_turfs)
			var/turf/T = thing
			if(T.z in z_start to z_finish)
				continue
			changed_turfs.Remove(thing)
			CHECK_TICK
	else
		changed_turfs.Cut()

	..()

//Used to strip valid information from an existing instance and transfer it to the replacement. i.e. when a crash occurs
//It works by using spawn(-1) to transfer the data, if there is a runtime the data does not get transfered but the loop
//does not crash
/datum/subsystem/lighting/Recover()
	if(!istype(SSlighting.changed_turfs))
		SSlighting.changed_turfs = list()
	if(!istype(SSlighting.changed_lights))
		SSlighting.changed_lights = list()

	for(var/thing in SSlighting.changed_lights)
		var/datum/light_source/LS = thing
		spawn(-1)			//so we don't crash the loop (inefficient)
			LS.check()

	for(var/thing in changed_turfs)
		var/turf/T = thing
		if(T.lighting_changed)
			spawn(-1)
				T.redraw_lighting()

	var/msg = "## DEBUG: [time2text(world.timeofday)] [name] subsystem restarted. Reports:\n"
	for(var/varname in SSlighting.vars)
		switch(varname)
			if("tag","bestF","type","parent_type","vars")
				continue
			else
				var/varval1 = SSlighting.vars[varname]
				var/varval2 = vars[varname]
				if(istype(varval1,/list))
					varval1 = "/list([length(varval1)])"
					varval2 = "/list([length(varval2)])"
				msg += "\t [varname] = [varval1] -> [varval2]\n"
	world.log << msg
