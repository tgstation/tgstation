/datum/controller/process/garbage
	schedule_interval = 61 // every 2 seconds


/datum/controller/process/garbage/setup()
	name = "garbage"

	if(!garbageCollector)
		garbageCollector = new

/datum/controller/process/garbage/doWork()
	garbageCollector.process()
	scheck()