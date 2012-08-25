var/datum/controller/lighting/lighting_controller = new ()

datum/controller/lighting
	var/processing = 0
	var/processing_interval = 4	//setting this too low will probably kill the server. Don't be silly with it!
	var/process_cost = 0
	var/iteration = 0

	var/lighting_states = 7

	var/list/lights = list()
	var/lights_workload_max = 0

//	var/list/changed_lights()		//TODO: possibly implement this to reduce on overheads?

	var/list/changed_turfs = list()
	var/changed_turfs_workload_max = 0

//Workhorse of lighting. It cycles through each light to see which ones need their effects updating. It updates their
//effects and then processes every turf in the queue, moving the turfs to the corresponing lighting sub-area.
//All queue lists prune themselves, which will cause lights with no luminosity to be garbage collected (cheaper and safer
//than deleting them). Processing interval should be roughly half a second for best results.
//By using queues we are ensuring we don't perform more updates than are necessary
datum/controller/lighting/proc/process()
	processing = 1
	spawn(0)
		set background = 1
		while(1)
			var/started = world.timeofday

			if(processing)
				iteration++
				lights_workload_max = max(lights_workload_max,lights.len)
				for(var/i=1, i<=lights.len, i++)
					var/datum/light_source/L = lights[i]
					if(L.check())
						lights.Cut(i,i+1)
						i--

				sleep(-1)

				changed_turfs_workload_max = max(changed_turfs_workload_max,changed_turfs.len)
				for(var/i=1, i<=changed_turfs.len, i++)
					var/turf/T = changed_turfs[i]
					if(T && T.lighting_changed)
						T.shift_to_subarea()
				changed_turfs.Cut()		// reset the changed list

			process_cost = (world.timeofday - started)

			sleep(processing_interval)

//same as above except it attempts to shift ALL turfs in the world regardless of lighting_changed status
//Does not loop. Should be run prior to process() being called for the first time.
//Note: if we get additional z-levels at runtime (e.g. if the gateway thin ever gets finished) we can initialize specific
//z-levels with the z_level argument
datum/controller/lighting/proc/Initialize(var/z_level)
	processing = 0
	spawn(-1)
		set background = 1
		for(var/i=1, i<=lights.len, i++)
			var/datum/light_source/L = lights[i]
			if(L.check())
				lights.Cut(i,i+1)
				i--

		var/z_start = 1
		var/z_finish = world.maxz
		if(z_level)
			z_level = round(z_level,1)
			if(z_level > 0 && z_level <= world.maxz)
				z_start = z_level
				z_finish = z_level

		for(var/k=z_start,k<=z_finish,k++)
			for(var/i=1,i<=world.maxx,i++)
				for(var/j=1,j<=world.maxy,j++)
					var/turf/T = locate(i,j,k)
					if(T)	T.shift_to_subarea()

		changed_turfs.Cut()		// reset the changed list