datum/updateQueueWorker
	var/tmp/list/objects
	var/tmp/killed
	var/tmp/finished
	var/tmp/procName
	var/tmp/list/arguments
	var/tmp/lastStart
	var/tmp/cpuThreshold

datum/updateQueueWorker/New(var/list/objects, var/procName, var/list/arguments, var/cpuThreshold = 90)
	..()
	uq_dbg("updateQueueWorker created.")

	init(objects, procName, arguments, cpuThreshold)

datum/updateQueueWorker/proc/init(var/list/objects, var/procName, var/list/arguments, var/cpuThreshold = 90)
	src.objects = objects
	src.procName = procName
	src.arguments = arguments
	src.cpuThreshold = cpuThreshold

	killed = 0
	finished = 0

datum/updateQueueWorker/proc/doWork()
	// If there's nothing left to execute or we were killed, mark finished and return.
	if (!objects || !objects.len) return finished()

	lastStart = world.timeofday // Absolute number of ticks since the world started up

	var/datum/object = objects[objects.len] // Pull out the object
	objects.len-- // Remove the object from the list

	if (istype(object) && !isturf(object) && !object.disposed && isnull(object.gcDestroyed)) // We only work with real objects
		call(object, procName)(arglist(arguments))

	// If there's nothing left to execute
	// or we were killed while running the above code, mark finished and return.
	if (!objects || !objects.len) return finished()

	if (world.cpu > cpuThreshold)
		// We don't want to force a tick into overtime!
		// If the tick is about to go overtime, spawn the next update to go
		// in the next tick.
		uq_dbg("tick went into overtime with world.cpu = [world.cpu], deferred next update to next tick [1+(world.time / world.tick_lag)]")

		spawn(1)
			doWork()
	else
		spawn(0) // Execute anonymous function immediately as if we were in a while loop...
			doWork()

datum/updateQueueWorker/proc/finished()
	uq_dbg("updateQueueWorker finished.")
	/**
	 * If the worker was killed while it was working on something, it
	 * should delete itself when it finally finishes working on it.
	 * Meanwhile, the updateQueue will have proceeded on with the rest of
	 * the queue. This will also terminate the spawned function that was
	 * created in the kill() proc.
	 */
	if(killed)
		del(src)

	finished = 1

datum/updateQueueWorker/proc/kill()
	uq_dbg("updateQueueWorker killed.")
	killed = 1
	objects = null

	/**
	 * If the worker is not done in 30 seconds after it's killed,
	 * we'll forcibly delete it, causing the anonymous function it was
	 * running to be terminated. Hasta la vista, baby.
	 */
	spawn(300)
		del(src)

datum/updateQueueWorker/proc/start()
	uq_dbg("updateQueueWorker started.")
	spawn(0)
		doWork()