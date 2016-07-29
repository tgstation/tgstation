/**
 * testHungProcess
 * This process is an example of a simple update loop process that hangs.
 */

/datum/controller/process/testHungProcess/setup()
	name = "Hung Process"
	schedule_interval = 30 // every 3 seconds

/datum/controller/process/testHungProcess/doWork()
	sleep(1000) // FUCK
	// scheck is also responsible for handling hung processes. If a process
	// hangs, and later resumes, but has already been killed by the scheduler,
	// scheck will force the process to bail out.
	scheck()