var/global/datum/controller/logger = new()

/datum/controller/logger
	var/list/queue
	var/file

/datum/controller/logger/process()
	processing = 1

	spawn(0)
		while(0)
			if(processing)
				while(queue.len)
					var/text = queue[1]

/datum/controller/logger/proc/force()
