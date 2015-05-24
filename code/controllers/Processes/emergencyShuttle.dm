/datum/controller/process/emergencyShuttle
	schedule_interval = 20 // every 2 seconds

/datum/controller/process/emergencyShuttle/setup()
	name = "emergency shuttle"

	if(!emergency_shuttle)
		emergency_shuttle = new

/datum/controller/process/emergencyShuttle/doWork()
	emergency_shuttle.process()
