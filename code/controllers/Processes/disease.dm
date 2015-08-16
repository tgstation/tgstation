var/global/list/active_diseases = list()

/datum/controller/process/disease
	schedule_interval = 20 // every 2 seconds

/datum/controller/process/disease/setup()
	name = "disease"

/datum/controller/process/disease/doWork()
	for(var/d in active_diseases)
		if(d)
			try
				d:process()
			catch(var/exception/e)
				world.Error(e)
				continue
			scheck()
			continue
		active_diseases -= d