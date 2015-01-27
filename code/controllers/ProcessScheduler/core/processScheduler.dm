// Singleton instance of game_controller_new, setup in world.New()
var/global/datum/controller/processScheduler/processScheduler

/datum/controller/processScheduler
	// Processes known by the scheduler
	var/tmp/datum/controller/process/list/processes = new

	// Processes that are currently running
	var/tmp/datum/controller/process/list/running = new

	// Processes that are idle
	var/tmp/datum/controller/process/list/idle = new

	// Processes that are queued to run
	var/tmp/datum/controller/process/list/queued = new

	// Process name -> process object map
	var/tmp/datum/controller/process/list/nameToProcessMap = new

	// Process last start times
	var/tmp/datum/controller/process/list/last_start = new

	// Process last run durations
	var/tmp/datum/controller/process/list/last_run_time = new

	// Per process list of the last 20 durations
	var/tmp/datum/controller/process/list/last_twenty_run_times = new

	// Process highest run time
	var/tmp/datum/controller/process/list/highest_run_time = new

	// Sleep 1 tick -- This may be too aggressive.
	var/tmp/scheduler_sleep_interval = 1

	// Controls whether the scheduler is running or not
	var/tmp/isRunning = 0

	// Setup for these processes will be deferred until all the other processes are set up.
	var/tmp/list/deferredSetupList = new

/**
 * deferSetupFor
 * @param path processPath
 * If a process needs to be initialized after everything else, add it to
 * the deferred setup list. On goonstation, only the ticker needs to have
 * this treatment.
 */
/datum/controller/processScheduler/proc/deferSetupFor(var/processPath)
	if (!(processPath in deferredSetupList))
		deferredSetupList += processPath

/datum/controller/processScheduler/proc/setup()
	// There can be only one
	if(processScheduler && (processScheduler != src))
		del(src)
		return 0

	var/process
	// Add all the processes we can find, except for the ticker
	for (process in typesof(/datum/controller/process) - /datum/controller/process)
		if (!(process in deferredSetupList))
			addProcess(new process(src))

	for (process in deferredSetupList)
		addProcess(new process(src))

/datum/controller/processScheduler/proc/start()
	isRunning = 1
	spawn(0)
		process()

/datum/controller/processScheduler/proc/process()
	while(isRunning)
		checkRunningProcesses()
		queueProcesses()
		runQueuedProcesses()
		sleep(scheduler_sleep_interval)

/datum/controller/processScheduler/proc/stop()
	isRunning = 0

/datum/controller/processScheduler/proc/checkRunningProcesses()
	for(var/datum/controller/process/p in running)
		p.update()

		if (isnull(p)) // Process was killed
			continue

		var/status = p.getStatus()
		var/previousStatus = p.getPreviousStatus()

		// Check status changes
		if(status != previousStatus)
			//Status changed.

			switch(status)
				if(PROCESS_STATUS_MAYBE_HUNG)
					message_admins("Process '[p.name]' is [p.getStatusText(status)].")
				if(PROCESS_STATUS_PROBABLY_HUNG)
					message_admins("Process '[p.name]' is [p.getStatusText(status)].")
				if(PROCESS_STATUS_HUNG)
					message_admins("Process '[p.name]' is [p.getStatusText(status)].")
					p.handleHung()

/datum/controller/processScheduler/proc/queueProcesses()
	for(var/datum/controller/process/p in processes)
		// Don't double-queue, don't queue running processes
		if (p.disabled || p.running || p.queued || !p.idle)
			continue

		// If world.timeofday has rolled over, then we need to adjust.
		if (world.timeofday < last_start[p])
			last_start[p] -= 864000

		// If the process should be running by now, go ahead and queue it
		if (world.timeofday > last_start[p] + p.schedule_interval)
			setQueuedProcessState(p)

/datum/controller/processScheduler/proc/runQueuedProcesses()
	for(var/datum/controller/process/p in queued)
		runProcess(p)

/datum/controller/processScheduler/proc/addProcess(var/datum/controller/process/process)
	processes.Add(process)
	process.idle()
	idle.Add(process)

	// init recordkeeping vars
	last_start.Add(process)
	last_start[process] = 0
	last_run_time.Add(process)
	last_run_time[process] = 0
	last_twenty_run_times.Add(process)
	last_twenty_run_times[process] = list()
	highest_run_time.Add(process)
	highest_run_time[process] = 0

	// init starts and stops record starts
	recordStart(process, 0)
	recordEnd(process, 0)

	// Set up process
	process.setup()

	// Save process in the name -> process map
	nameToProcessMap[process.name] = process

/datum/controller/processScheduler/proc/replaceProcess(var/datum/controller/process/oldProcess, var/datum/controller/process/newProcess)
	processes.Remove(oldProcess)
	processes.Add(newProcess)

	newProcess.idle()
	idle.Remove(oldProcess)
	running.Remove(oldProcess)
	queued.Remove(oldProcess)
	idle.Add(newProcess)

	last_start.Remove(oldProcess)
	last_start.Add(newProcess)
	last_start[newProcess] = 0

	last_run_time.Add(newProcess)
	last_run_time[newProcess] = last_run_time[oldProcess]
	last_run_time.Remove(oldProcess)

	last_twenty_run_times.Add(newProcess)
	last_twenty_run_times[newProcess] = last_twenty_run_times[oldProcess]
	last_twenty_run_times.Remove(oldProcess)

	highest_run_time.Add(newProcess)
	highest_run_time[newProcess] = highest_run_time[oldProcess]
	highest_run_time.Remove(oldProcess)

	recordStart(newProcess, 0)
	recordEnd(newProcess, 0)

	nameToProcessMap[newProcess.name] = newProcess


/datum/controller/processScheduler/proc/runProcess(var/datum/controller/process/process)
	spawn(0)
		process.process()

/datum/controller/processScheduler/proc/processStarted(var/datum/controller/process/process)
	setRunningProcessState(process)
	recordStart(process)

/datum/controller/processScheduler/proc/processFinished(var/datum/controller/process/process)
	setIdleProcessState(process)
	recordEnd(process)

/datum/controller/processScheduler/proc/setIdleProcessState(var/datum/controller/process/process)
	if (process in running)
		running -= process
	if (process in queued)
		queued -= process
	if (!(process in idle))
		idle += process

	process.idle()

/datum/controller/processScheduler/proc/setQueuedProcessState(var/datum/controller/process/process)
	if (process in running)
		running -= process
	if (process in idle)
		idle -= process
	if (!(process in queued))
		queued += process

	// The other state transitions are handled internally by the process.
	process.queued()

/datum/controller/processScheduler/proc/setRunningProcessState(var/datum/controller/process/process)
	if (process in queued)
		queued -= process
	if (process in idle)
		idle -= process
	if (!(process in running))
		running += process

	process.running()

/datum/controller/processScheduler/proc/recordStart(var/datum/controller/process/process, var/time = null)
	if (isnull(time))
		time = world.timeofday

	last_start[process] = time

/datum/controller/processScheduler/proc/recordEnd(var/datum/controller/process/process, var/time = null)
	if (isnull(time))
		time = world.timeofday

	// If world.timeofday has rolled over, then we need to adjust.
	if (time < last_start[process])
		last_start[process] -= 864000

	var/lastRunTime = time - last_start[process]

	if(lastRunTime < 0)
		lastRunTime = 0

	recordRunTime(process, lastRunTime)

/**
 * recordRunTime
 * Records a run time for a process
 */
/datum/controller/processScheduler/proc/recordRunTime(var/datum/controller/process/process, time)
	last_run_time[process] = time
	if(time > highest_run_time[process])
		highest_run_time[process] = time

	var/list/lastTwenty = last_twenty_run_times[process]
	if (lastTwenty.len == 20)
		lastTwenty.Cut(1, 2)
	lastTwenty.len++
	lastTwenty[lastTwenty.len] = time

/**
 * averageRunTime
 * returns the average run time (over the last 20) of the process
 */
/datum/controller/processScheduler/proc/averageRunTime(var/datum/controller/process/process)
	var/lastTwenty = last_twenty_run_times[process]

	var/t = 0
	var/c = 0
	for(var/time in lastTwenty)
		t += time
		c++

	if(c > 0)
		return t / c
	return c

/datum/controller/processScheduler/proc/getStatusData()
	var/list/data = new

	for (var/datum/controller/process/p in processes)
		data.len++
		data[data.len] = p.getContextData()

	return data

/datum/controller/processScheduler/proc/getProcessCount()
	return processes.len

/datum/controller/processScheduler/proc/hasProcess(var/processName as text)
	if (nameToProcessMap[processName])
		return 1

/datum/controller/processScheduler/proc/killProcess(var/processName as text)
	restartProcess(processName)

/datum/controller/processScheduler/proc/restartProcess(var/processName as text)
	if (hasProcess(processName))
		var/datum/controller/process/oldInstance = nameToProcessMap[processName]
		var/datum/controller/process/newInstance = new oldInstance.type(src)
		newInstance._copyStateFrom(oldInstance)
		replaceProcess(oldInstance, newInstance)
		oldInstance.kill()

/datum/controller/processScheduler/proc/enableProcess(var/processName as text)
	if (hasProcess(processName))
		var/datum/controller/process/process = nameToProcessMap[processName]
		process.enable()

/datum/controller/processScheduler/proc/disableProcess(var/processName as text)
	if (hasProcess(processName))
		var/datum/controller/process/process = nameToProcessMap[processName]
		process.disable()

/datum/controller/processScheduler/proc/getProcess(var/name)
	return nameToProcessMap[name]

/datum/controller/processScheduler/proc/getProcessLastRunTime(var/datum/controller/process/process)
	return last_run_time[process]

/datum/controller/processScheduler/proc/getIsRunning()
	return isRunning
