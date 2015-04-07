/datum/controller/process/sun/setup()
	name = "sun"
	schedule_interval = 40 // every 2 seconds
	sun = new

/datum/controller/process/sun/doWork()
	sun.calc_position()
