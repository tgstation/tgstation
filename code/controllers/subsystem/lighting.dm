var/datum/subsystem/lighting/SSlighting

#define MC_AVERAGE(average, current) (0.8*(average) + 0.2*(current))

/datum/subsystem/lighting
	name = "Lighting"
	wait = 5
	priority = 1
	dynamic_wait = 1
	dwait_delta = 1

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
/datum/subsystem/lighting/fire()
	changed_lights_workload = MC_AVERAGE(changed_lights_workload, changed_lights.len)

	for(var/thing in changed_lights)
		var/datum/light_source/LS = thing
		LS.check()
	changed_lights.Cut()

	changed_turfs_workload = MC_AVERAGE(changed_turfs_workload, changed_turfs.len)
	for(var/thing in changed_turfs)
		var/turf/T = thing
		if(T.lighting_changed)
			T.redraw_lighting()
	changed_turfs.Cut()

//same as above except it attempts to shift ALL turfs in the world regardless of lighting_changed status
//Does not loop. Should be run prior to process() being called for the first time.
//Note: if we get additional z-levels at runtime (e.g. if the gateway thin ever gets finished) we can initialize specific
//z-levels with the z_level argument
/datum/subsystem/lighting/Initialize(timeofday, z_level)


	for(var/thing in changed_lights)
		var/datum/light_source/LS = thing
		LS.check()
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

	if(z_level)
		//we need to loop through to clear only shifted turfs from the list. or we will cause errors
		var/i=1
		for(var/thing in changed_turfs)
			var/turf/T = thing
			if(T.z in z_start to z_finish)
				++i
				continue
			changed_turfs.Cut(i, i+1)
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
			if("tag","bestF","type","parent_type","vars")	continue
			else
				var/varval1 = SSlighting.vars[varname]
				var/varval2 = vars[varname]
				if(istype(varval1,/list))
					varval1 = "/list([length(varval1)])"
					varval2 = "/list([length(varval2)])"
				msg += "\t [varname] = [varval1] -> [varval2]\n"
	world.log << msg
