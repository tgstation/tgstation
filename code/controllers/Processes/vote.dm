/datum/controller/process/vote
	schedule_interval = 10 // every second

/datum/controller/process/vote/setup()
	name = "vote"


/datum/controller/process/vote/doWork()
	vote.process()
