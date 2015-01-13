/datum/controller/process/vote/setup()
	name = "vote"
	schedule_interval = 10 // every second

/datum/controller/process/vote/doWork()
	vote.process()
