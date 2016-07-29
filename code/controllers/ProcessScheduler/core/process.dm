// Process

/datum/controller/process
	/**
	 * State vars
	 */
	// Main controller ref
	var/tmp/datum/controller/processScheduler/main

	// 1 if process is not running or queued
	var/tmp/idle = 1

	// 1 if process is queued
	var/tmp/queued = 0

	// 1 if process is running
	var/tmp/running = 0

	// 1 if process is blocked up
	var/tmp/hung = 0

	// 1 if process was killed
	var/tmp/killed = 0

	// Status text var
	var/tmp/status

	// Previous status text var
	var/tmp/previousStatus

	// 1 if process is disabled
	var/tmp/disabled = 0

	/**
	 * Config vars
	 */
	// Process name
	var/name

	// Process schedule interval
	// This controls how often the process would run under ideal conditions.
	// If the process scheduler sees that the process has finished, it will wait until
	// this amount of time has elapsed from the start of the previous run to start the
	// process running again.
	var/tmp/schedule_interval = PROCESS_DEFAULT_SCHEDULE_INTERVAL // run every 50 ticks

	// Process tick allowance
	// This controls what percentage a single tick (0 to 100) the process should be
	// allowed to run before sleeping.
	var/tmp/tick_allowance = PROCESS_DEFAULT_TICK_ALLOWANCE

	// hang_warning_time - this is the time (in 1/10 seconds) after which the server will begin to show "maybe hung" in the context window
	var/tmp/hang_warning_time = PROCESS_DEFAULT_HANG_WARNING_TIME

	// hang_alert_time - After this much time(in 1/10 seconds), the server will send an admin debug message saying the process may be hung
	var/tmp/hang_alert_time = PROCESS_DEFAULT_HANG_ALERT_TIME

	// hang_restart_time - After this much time(in 1/10 seconds), the server will automatically kill and restart the process.
	var/tmp/hang_restart_time = PROCESS_DEFAULT_HANG_RESTART_TIME

	// How many times in the current run has the process deferred work till the next tick?
	var/tmp/cpu_defer_count = 0

	/**
	 * recordkeeping vars
	 */

	// Records the time (1/10s timeofday) at which the process last finished sleeping
	var/tmp/last_slept = 0

	// Records the time (1/10s timeofday) at which the process last began running
	var/tmp/run_start = 0

	// Records the world.tick_usage (0 to 100) at which the process last began running
	/var/tmp/tick_start = 0

	// Records the number of times this process has been killed and restarted
	var/tmp/times_killed

	// Tick count
	var/tmp/ticks = 0

	var/tmp/last_task = ""

	var/tmp/last_object

datum/controller/process/New(var/datum/controller/processScheduler/scheduler)
	..()
	main = scheduler
	previousStatus = "idle"
	idle()
	name = "process"
	last_slept = 0
	run_start = 0
	tick_start = 0
	ticks = 0
	last_task = 0
	last_object = null

datum/controller/process/proc/started()
	// Initialize last_slept so we can record timing information
	last_slept = TimeOfGame

	// Initialize run_start so we can detect hung processes.
	run_start = TimeOfGame

	// Initialize tick_start so we can know when to sleep
	tick_start = world.tick_usage

	// Initialize defer count
	cpu_defer_count = 0

	running()
	main.processStarted(src)

	onStart()

datum/controller/process/proc/finished()
	ticks++
	idle()
	main.processFinished(src)

	onFinish()

datum/controller/process/proc/doWork()

datum/controller/process/proc/setup()

datum/controller/process/proc/process()
	started()
	doWork()
	finished()

datum/controller/process/proc/running()
	idle = 0
	queued = 0
	running = 1
	hung = 0
	setStatus(PROCESS_STATUS_RUNNING)

datum/controller/process/proc/idle()
	queued = 0
	running = 0
	idle = 1
	hung = 0
	setStatus(PROCESS_STATUS_IDLE)

datum/controller/process/proc/queued()
	idle = 0
	running = 0
	queued = 1
	hung = 0
	setStatus(PROCESS_STATUS_QUEUED)

datum/controller/process/proc/hung()
	hung = 1
	setStatus(PROCESS_STATUS_HUNG)

datum/controller/process/proc/handleHung()
	var/datum/lastObj = last_object
	var/lastObjType = "null"
	if(istype(lastObj))
		lastObjType = lastObj.type

	var/msg = "[name] process hung at tick #[ticks]. Process was unresponsive for [(TimeOfHour - run_start) / 10] seconds and was restarted. Last task: [last_task]. Last Object Type: [lastObjType]"
	log_debug(msg)
	message_admins(msg)

	main.restartProcess(src.name)

datum/controller/process/proc/kill()
	if (!killed)
		var/msg = "[name] process was killed at tick #[ticks]."
		log_debug(msg)
		message_admins(msg)
		//finished()

		// Allow inheritors to clean up if needed
		onKill()

		// This should del
		del(src)

datum/controller/process/proc/scheck(var/tickId = 0)
	if (killed)
		// The kill proc is the only place where killed is set.
		// The kill proc should have deleted this datum, and all sleeping procs that are
		// owned by it.
		CRASH("A killed process is still running somehow...")
	if (hung)
		// This will only really help if the doWork proc ends up in an infinite loop.
		handleHung()
		CRASH("Process [name] hung and was restarted.")

	// For each tick the process defers, it increments the cpu_defer_count so we don't
	// defer indefinitely
	if (world.tick_usage > 100 || (world.tick_usage - tick_start) > tick_allowance)
		sleep(world.tick_lag)
		cpu_defer_count++
		last_slept = TimeOfHour
		tick_start = world.tick_usage

		return 1

	return 0

datum/controller/process/proc/update()
	// Clear delta
	if(previousStatus != status)
		setStatus(status)

	var/elapsedTime = getElapsedTime()

	if (hung)
		handleHung()
		return
	else if (elapsedTime > hang_restart_time)
		hung()
	else if (elapsedTime > hang_alert_time)
		setStatus(PROCESS_STATUS_PROBABLY_HUNG)
	else if (elapsedTime > hang_warning_time)
		setStatus(PROCESS_STATUS_MAYBE_HUNG)

datum/controller/process/proc/getElapsedTime()
	return TimeOfGame - run_start

datum/controller/process/proc/tickDetail()
	return

datum/controller/process/proc/getContext()
	return "<tr><td>[name]</td><td>[main.averageRunTime(src)]</td><td>[main.last_run_time[src]]</td><td>[main.highest_run_time[src]]</td><td>[ticks]</td></tr>\n"

datum/controller/process/proc/getContextData()
	return list(
	"name" = name,
	"averageRunTime" = main.averageRunTime(src),
	"lastRunTime" = main.last_run_time[src],
	"highestRunTime" = main.highest_run_time[src],
	"ticks" = ticks,
	"schedule" = schedule_interval,
	"status" = getStatusText(),
	"disabled" = disabled
	)

datum/controller/process/proc/getStatus()
	return status

datum/controller/process/proc/getStatusText(var/s = 0)
	if(!s)
		s = status
	switch(s)
		if(PROCESS_STATUS_IDLE)
			return "idle"
		if(PROCESS_STATUS_QUEUED)
			return "queued"
		if(PROCESS_STATUS_RUNNING)
			return "running"
		if(PROCESS_STATUS_MAYBE_HUNG)
			return "maybe hung"
		if(PROCESS_STATUS_PROBABLY_HUNG)
			return "probably hung"
		if(PROCESS_STATUS_HUNG)
			return "HUNG"
		else
			return "UNKNOWN"

datum/controller/process/proc/getPreviousStatus()
	return previousStatus

datum/controller/process/proc/getPreviousStatusText()
	return getStatusText(previousStatus)

datum/controller/process/proc/setStatus(var/newStatus)
	previousStatus = status
	status = newStatus

datum/controller/process/proc/setLastTask(var/task, var/object)
	last_task = task
	last_object = object

datum/controller/process/proc/_copyStateFrom(var/datum/controller/process/target)
	main = target.main
	name = target.name
	schedule_interval = target.schedule_interval
	last_slept = 0
	run_start = 0
	tick_start = 0
	times_killed = target.times_killed
	ticks = target.ticks
	last_task = target.last_task
	last_object = target.last_object
	copyStateFrom(target)

datum/controller/process/proc/copyStateFrom(var/datum/controller/process/target)

datum/controller/process/proc/onKill()

datum/controller/process/proc/onStart()

datum/controller/process/proc/onFinish()

datum/controller/process/proc/disable()
	disabled = 1

datum/controller/process/proc/enable()
	disabled = 0

/datum/controller/process/proc/getLastRunTime()
	return main.getProcessLastRunTime(src)

/datum/controller/process/proc/getTicks()
	return ticks
