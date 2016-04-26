var/global/list/active_diseases = list()

/datum/controller/process/disease
	schedule_interval = 20 // every 2 seconds

/datum/controller/process/disease/setup()
	name = "disease"

/datum/controller/process/disease/doWork()
	for(var/d in active_diseases)
		if(d)
			d:process()
			scheck()
			continue
		active_diseases -= d
