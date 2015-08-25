var/global/list/power_machinery_profiling = list()
var/global/list/power_machines = list()

/datum/controller/process/power_machinery
	schedule_interval = 37 // every 2 seconds

/datum/controller/process/power_machinery/setup()
	name = "pow_machine"


/datum/controller/process/power_machinery/doWork()
	for(var/i = 1 to power_machines.len)
		if(i > power_machines.len)
			break
		try
			if(istype(power_machines[i], /obj/machinery))
				var/obj/machinery/M = power_machines[i]
				if(M.timestopped) continue
				if(!M.gcDestroyed)
					#ifdef PROFILE_MACHINES
					var/time_start = world.timeofday
					#endif

					if(M.check_rebuild()) //Checks to make sure the powernet doesn't need to be rebuilt, rebuilds it if it does
						scheck()

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

			else if(istype(power_machines[i], /datum/power_connection))
				var/datum/power_connection/C = power_machines[i]

				#ifdef PROFILE_MACHINES
				var/time_start = world.timeofday
				#endif

				if(C.check_rebuild()) //Checks to make sure the powernet doesn't need to be rebuilt, rebuilds it if it does
					scheck()

				if(C.process() == PROCESS_KILL)
					C.inMachineList = 0
					power_machines.Remove(C)
					continue

				//if(C && C.use_power)
				//	C.auto_use_power()

				if(istype(C))
					#ifdef PROFILE_MACHINES
					var/time_end = world.timeofday

					if(!(C.type in power_machinery_profiling))
						power_machinery_profiling[C.type] = 0

					power_machinery_profiling[C.type] += (time_end - time_start)
					#endif
				else
					if(!power_machines.Remove(C))
						power_machines.Cut(i,i+1)

		catch(var/exception/e)
			world.Error(e)
			continue

		scheck()