/** 
 * testNiceProcess
 * This process is an example of a simple update loop process that is
 * relatively fast.
 */

/datum/controller/process/testNiceProcess/setup()
	name = "Nice Process"
	schedule_interval = 10 // every second
	
/datum/controller/process/testNiceProcess/doWork()
	sleep(rand(1,5)) // Just to pretend we're doing something
	