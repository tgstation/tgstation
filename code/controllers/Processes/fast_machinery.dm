//Faster version of the one in machinery.dm

var/global/list/fast_machines = list()
/datum/controller/process/fast_machinery
	schedule_interval = 7 // every 0.7 second.

/datum/controller/process/fast_machinery/setup()
	name = "fast_machinery"

/datum/controller/process/fast_machinery/doWork()
	//#ifdef PROFILE_MACHINES
	//machine_profiling.len = 0
	//#endif
	if(!fast_machines || !fast_machines.len) return
	for(var/i = 1 to fast_machines.len)
		if(i > fast_machines.len)
			break
		var/obj/machinery/M = fast_machines[i]

		if(istype(M) && !M.gcDestroyed)
			if(M.timestopped) continue
			#ifdef PROFILE_MACHINES
			var/time_start = world.timeofday
			#endif

			if(M.process() == PROCESS_KILL)
				M.inMachineList = 0
				fast_machines.Remove(M)
				continue

			if(M && M.use_power)
				M.auto_use_power()

			if(istype(M))
				#ifdef PROFILE_MACHINES
				var/time_end = world.timeofday

				if(!(M.type in machine_profiling))
					machine_profiling[M.type] = 0

				machine_profiling[M.type] += (time_end - time_start)
				#endif
			else
				if(!fast_machines.Remove(M))
					fast_machines.Cut(i, i + 1)

		else
			if(M)
				M.inMachineList = 0

			if(!fast_machines.Remove(M))
				fast_machines.Cut(i, i + 1)

		if(!(i % 20)) scheck()
