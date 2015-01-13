/**
 * updateQueue.dm
 */

#ifdef UPDATE_QUEUE_DEBUG
#define uq_dbg(text) world << text
#else
#define uq_dbg(text)
#endif
/datum/updateQueue
	var/tmp/list/objects
	var/tmp/previousStart
	var/tmp/procName
	var/tmp/list/arguments
	var/tmp/datum/updateQueueWorker/currentWorker
	var/tmp/workerTimeout
	var/tmp/adjustedWorkerTimeout
	var/tmp/currentKillCount
	var/tmp/totalKillCount
	
/datum/updateQueue/New(list/objects = list(), procName = "update", list/arguments = list(), workerTimeout = 2, inplace = 0)
	..()
	
	uq_dbg("Update queue created.")
	
	// Init proc allows for recycling the worker.
	init(objects = objects, procName = procName, arguments = arguments, workerTimeout = workerTimeout, inplace = inplace)

/**
 * init
 * @param list objects objects to update
 * @param text procName the proc to call on each item in the object list
 * @param list arguments optional arguments to pass to the update proc
 * @param number workerTimeout number of ticks to wait for an update to
	                           finish before forking a new update worker
 * @param bool inplace whether the updateQueue should make a copy of objects.
                       the internal list will be modified, so it is usually
					   a good idea to leave this alone. Default behavior is to
					   copy.
 */
/datum/updateQueue/proc/init(list/objects = list(), procName = "update", list/arguments = list(), workerTimeout = 2, inplace = 0)
	uq_dbg("Update queue initialization started.")
	
	if (!inplace)
		// Make an internal copy of the list so we're not modifying the original.
		initList(objects)
	else
		src.objects = objects
		
	// Init vars
	src.procName = procName
	src.arguments = arguments
	src.workerTimeout = workerTimeout
	
	adjustedWorkerTimeout = workerTimeout
	currentKillCount = 0
	totalKillCount = 0
		
	uq_dbg("Update queue initialization finished. procName = '[procName]'")
		
/datum/updateQueue/proc/initList(list/toCopy)
	/**
	 * We will copy the list in reverse order, as our doWork proc 
	 * will access them by popping an element off the end of the list.
	 * This ends up being quite a lot faster than taking elements off
	 * the head of the list.
	 */
	objects = new
		
	uq_dbg("Copying [toCopy.len] items for processing.")
	
	for(var/i=toCopy.len,i>0,)
		objects.len++
		objects[objects.len] = toCopy[i--]
		
/datum/updateQueue/proc/Run()
	uq_dbg("Starting run...")

	startWorker()
	while (istype(currentWorker) && !currentWorker.finished)
		sleep(2)
		checkWorker()
		
	uq_dbg("UpdateQueue completed run.")
		
/datum/updateQueue/proc/checkWorker()
	if(istype(currentWorker))
		// If world.timeofday has rolled over, then we need to adjust.
		if(world.timeofday < currentWorker.lastStart)
			currentWorker.lastStart -= 864000
			
		if(world.timeofday - currentWorker.lastStart > adjustedWorkerTimeout) 
			// This worker is a bit slow, let's spawn a new one and kill the old one.
			uq_dbg("Current worker is lagging... starting a new one.")
			killWorker()
			startWorker()
	else // No worker!
		uq_dbg("update queue ended up without a worker... starting a new one...")
		startWorker()
		
/datum/updateQueue/proc/startWorker()
	// only run the worker if we have objects to work on
	if(objects.len)
		uq_dbg("Starting worker process.")
		
		// No need to create a fresh worker if we already have one...
		if (istype(currentWorker))
			currentWorker.init(objects, procName, arguments)
		else
			currentWorker = new(objects, procName, arguments)
		currentWorker.start()
	else
		uq_dbg("Queue is empty. No worker was started.")
		currentWorker = null
		
/datum/updateQueue/proc/killWorker()
	// Kill the worker
	currentWorker.kill()
	currentWorker = null
	// After we kill a worker, yield so that if the worker's been tying up the cpu, other stuff can immediately resume
	sleep(-1)
	currentKillCount++
	totalKillCount++
	if (currentKillCount >= 3)
		uq_dbg("[currentKillCount] workers have been killed with a timeout of [adjustedWorkerTimeout]. Increasing worker timeout to compensate.")
		adjustedWorkerTimeout++
		currentKillCount = 0