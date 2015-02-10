var/global/list/power_machinery_profiling = list()

/datum/controller/process/power_machinery
	var/tmp/datum/updateQueue/updateQueueInstance

/datum/controller/process/power_machinery/setup()
	name = "pow_machine"
	schedule_interval = 20 // every 2 seconds

/datum/controller/process/power_machinery/doWork()
	for(var/i = 1 to power_machines.len)
		if(i > power_machines.len)
			break
		var/obj/machinery/M = power_machines[i]
		if(istype(M) && !M.gcDestroyed)
			#ifdef PROFILE_MACHINES
			var/time_start = world.timeofday
			#endif

			if(M.process() == PROCESS_KILL)
				M.inMachineList = 0
				power_machines.Remove(M)
				continue

			if(M && M.use_power)
				M.auto_use_power()
			if(istype(M))
				#ifdef PROFILE_MACHINES
				var/time_end = world.timeofday

				if(!(M.type in power_machinery_profiling))
					power_machinery_profiling[M.type] = 0

				power_machinery_profiling[M.type] += (time_end - time_start)
				#endif
			else
				if(!power_machines.Remove(M))
					power_machines.Cut(i,i+1)
		else
			if(M)
				M.inMachineList = 0
			if(!power_machines.Remove(M))
				power_machines.Cut(i,i+1)

		scheck()
