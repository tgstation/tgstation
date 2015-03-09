/** 
 * testSlowProcess
 * This process is an example of a simple update loop process that is slow.
 * The update loop here sleeps inside to provide an example, but if you had
 * a computationally intensive loop process that is simply slow, you can use
 * scheck() inside the loop to force it to yield periodically according to
 * the sleep_interval var. By default, scheck will cause a loop to sleep every
 * 2 ticks.
 */
 
/datum/controller/process/testSlowProcess/setup()
	name = "Slow Process"
	schedule_interval = 30 // every 3 seconds
	
/datum/controller/process/testSlowProcess/doWork()
	// set background = 1 will cause loop constructs to sleep periodically,
	// whenever the BYOND scheduler deems it productive to do so.
	// This behavior is not always sufficient, nor is it always consistent.
	// Rather than leaving it up to the BYOND scheduler, we can control it
	// ourselves and leave nothing to the black box.
	set background = 1
	
	for(var/i=1,i<30,i++)
		// Just to pretend we're doing something here
		sleep(rand(3, 5))
	
		// Forces this loop to yield(sleep) periodically.
		scheck()