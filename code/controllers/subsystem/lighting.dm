var/datum/subsystem/lighting/SSlighting

#define MC_AVERAGE(average, current) (0.8*(average) + 0.2*(current))
#define LIGHTING_ICON 'icons/effects/ss13_dark_alpha6.dmi'
#define LIGHTING_LAYER 10									//Drawing layer for lighting overlays

/datum/subsystem/lighting
	name = "Lighting"
	wait = 5
	priority = 1

	var/list/lighting_images = list()		//replaces lighting_states (use lighting_images.len) ~carn
	var/list/lights = list()				//list of all datum/light_source
	var/lights_workload = 0					//stats on the largest number of lights (max lights.len)
	var/list/changed_turfs = list()			//list of all turfs which need moving to a new lighting subarea
	var/changed_turfs_workload = 0			//stats on the largest number of turfs changed (max changed_turfs.len)


/datum/subsystem/lighting/New()
	NEW_SS_GLOBAL(SSlighting)

	//cache lighting images
	if(!lighting_images.len)
		for(var/icon_state in icon_states(LIGHTING_ICON))
			lighting_images += image(LIGHTING_ICON, null, icon_state, LIGHTING_LAYER)

	return ..()


/datum/subsystem/lighting/stat_entry()
	stat(name, "[round(cost,0.001)]ds (CPU:[round(cpu,1)]%) L:[round(lights_workload,1)]/T:[round(changed_turfs_workload,1)]")


//Workhorse of lighting. It cycles through each light to see which ones need their effects updating. It updates their
//effects and then processes every turf in the queue, moving the turfs to the corresponing lighting sub-area.
//All queue lists prune themselves, which will cause lights with no luminosity to be garbage collected (cheaper and safer
//than deleting them).
//By using queues we are ensuring we don't perform more updates than are necessary
/datum/subsystem/lighting/fire()
	lights_workload = MC_AVERAGE(lights_workload, lights.len)
	var/i=1
	for(var/thing in lights)
		if(thing && !thing:check())	//yes, cry that I'm using the : operator, it's much faster looping like this. And this gets called a lot. Dealwithit.
			++i
			continue
		lights.Cut(i, i+1)

	changed_turfs_workload = MC_AVERAGE(changed_turfs_workload, changed_turfs.len)
	for(var/thing in changed_turfs)
		if(thing && thing:lighting_changed)
			thing:shift_to_subarea()
	changed_turfs.Cut()


//same as above except it attempts to shift ALL turfs in the world regardless of lighting_changed status
//Does not loop. Should be run prior to process() being called for the first time.
//Note: if we get additional z-levels at runtime (e.g. if the gateway thin ever gets finished) we can initialize specific
//z-levels with the z_level argument
/datum/subsystem/lighting/Initialize(timeofday, z_level)

	var/i=1
	for(var/thing in lights)
		if(thing && !thing:check())
			++i
			continue
		lights.Cut(i, i+1)

	var/z_start = 1
	var/z_finish = world.maxz
	if(1 <= z_level && z_level <= world.maxz)
		z_level = round(z_level)
		z_start = z_level
		z_finish = z_level

	for(var/z=z_start, z<=z_finish, ++z)
		for(var/x=1, x<=world.maxx, ++x)
			for(var/y=1, y<=world.maxy, ++y)
				var/turf/T = locate(x,y,z)
				if(T)
					T.shift_to_subarea()

	if(z_level)
		//we need to loop through to clear only shifted turfs from the list. or we will cause errors
		i=1
		for(var/thing in changed_turfs)
			if(thing && thing:z < z_start && z_finish < thing:z)
				++i
				continue
			changed_turfs.Cut(i, i+1)
	else
		changed_turfs.Cut()

	if(config.starlight)
		set background = 1
		for(var/turf/space/S in world)
			S.update_starlight()

	..()

//Used to strip valid information from an existing instance and transfer it to the replacement. i.e. when a crash occurs
//It works by using spawn(-1) to transfer the data, if there is a runtime the data does not get transfered but the loop
//does not crash
/datum/subsystem/lighting/Recover()
	if(!istype(SSlighting.changed_turfs))
		SSlighting.changed_turfs = list()
	if(!istype(SSlighting.lights))
		SSlighting.lights = list()

	if(istype(SSlighting.lighting_images))
		lighting_images = SSlighting.lighting_images

	for(var/datum/light_source/L in SSlighting.lights)
		spawn(-1)			//so we don't crash the loop (inefficient)
			L.check()
			lights += L		//If we didn't runtime then this will get transferred over

	for(var/turf/T in changed_turfs)
		if(T.lighting_changed)
			spawn(-1)
				T.shift_to_subarea()

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

#undef LIGHTING_ICON
#undef LIGHTING_LAYER