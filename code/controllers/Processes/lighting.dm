/datum/controller/process/lighting/setup()
	name = "lighting"
	schedule_interval = 5 // every .5 second
	lighting_controller.Initialize()

/datum/controller/process/lighting/doWork()
	lighting_controller.lights_workload_max = \
		max(lighting_controller.lights_workload_max, lighting_controller.lights.len)

	for(var/datum/light_source/L in lighting_controller.lights)
		if(L && L.check())
			lighting_controller.lights.Remove(L)

		scheck()

	lighting_controller.changed_turfs_workload_max = \
		max(lighting_controller.changed_turfs_workload_max, lighting_controller.changed_turfs.len)

	for(var/turf/T in lighting_controller.changed_turfs)
		if(T && T.lighting_changed)
			T.shift_to_subarea()

		scheck()

	if(lighting_controller.changed_turfs && lighting_controller.changed_turfs.len)
		lighting_controller.changed_turfs.len = 0 // reset the changed list
