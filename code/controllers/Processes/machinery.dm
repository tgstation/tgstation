var/global/list/machines = list()
/datum/controller/process/machinery
	schedule_interval = 23 // every 2 seconds

/datum/controller/process/machinery/setup()
	name = "machinery"


/datum/controller/process/machinery/doWork()
	//#ifdef PROFILE_MACHINES
	//machine_profiling.len = 0
	//#endif
	if(!machines || !machines.len) return
	for(var/i = 1 to machines.len)
		if(i > machines.len)
			break
		try
			var/obj/machinery/M = machines[i]
			if(istype(M) && !M.gcDestroyed)
				if(M.timestopped) continue
				#ifdef PROFILE_MACHINES
				var/time_start = world.timeofday
				#endif

				if(M.process() == PROCESS_KILL)
					M.inMachineList = 0
					machines.Remove(M)
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
					if(!machines.Remove(M))
						machines.Cut(i,i+1)
			else
				if(M)
					M.inMachineList = 0
				if(!machines.Remove(M))
					machines.Cut(i,i+1)
		catch(var/exception/e)
			world.Error(e)
			continue
		if(!(i%20)) scheck()