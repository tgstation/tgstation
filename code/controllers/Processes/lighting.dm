/datum/controller/process/lighting/setup()
	name = "lighting"
	schedule_interval = 5 // every .5 second
	lighting_controller.Initialize()

/datum/controller/process/lighting/doWork()
	lighting_controller.lights_workload_max = \
		max(lighting_controller.lights_workload_max, lighting_controller.lights.len)

	for(var/i = 1 to lighting_controller.lights.len)
		if(i > lighting_controller.lights.len)
			break
		var/datum/light_source/L = lighting_controller.lights[i]
		if(L && L.check())
			lighting_controller.lights.Remove(L)

		scheck()

	lighting_controller.changed_turfs_workload_max = \
		max(lighting_controller.changed_turfs_workload_max, lighting_controller.changed_turfs.len)

	for(var/i = 1 to lighting_controller.changed_turfs.len)
		if(i > lighting_controller.changed_turfs.len)
			break
		var/turf/T = lighting_controller.changed_turfs[i]
		if(T && T.lighting_changed)
			T.shift_to_subarea()

		scheck()

	if(lighting_controller.changed_turfs && lighting_controller.changed_turfs.len)
		lighting_controller.changed_turfs.len = 0 // reset the changed list
