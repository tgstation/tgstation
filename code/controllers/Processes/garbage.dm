/datum/controller/process/garbage/setup()
	name = "garbage"
	schedule_interval = 20 // every 2 seconds

	if(!garbageCollector)
		garbageCollector = new

/datum/controller/process/garbage/doWork()
	garbageCollector.process()
	scheck()