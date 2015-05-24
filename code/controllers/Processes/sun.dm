/datum/controller/process/sun
	schedule_interval = 40 // every 2 seconds
/datum/controller/process/sun/setup()
	name = "sun"

	sun = new

/datum/controller/process/sun/doWork()
	sun.calc_position()
