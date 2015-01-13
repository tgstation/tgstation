/**
 * testBadZombieProcess
 * This process is an example of a simple update loop process that hangs.
 */

/datum/controller/process/testZombieProcess/setup()
	name = "Zombie Process"
	schedule_interval = 30 // every 3 seconds

/datum/controller/process/testZombieProcess/doWork()
	for (var/i = 0, i < 1000, i++)
		sleep(1)
		scheck()