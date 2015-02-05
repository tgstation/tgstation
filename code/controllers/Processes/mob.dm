/datum/controller/process/mob
	var/tmp/datum/updateQueue/updateQueueInstance

/datum/controller/process/mob/setup()
	name = "mob"
	schedule_interval = 20 // every 2 seconds
	updateQueueInstance = new

/datum/controller/process/mob/doWork()
	for(var/i = 1 to mob_list.len)
		if(i > mob_list.len)
			break
		var/mob/L = mob_list[i]
		if(ismob(L))
			L.Life()
			if(!ismob(L))
				if(!mob_list.Remove(L))
					mob_list.Cut(i,i+1)
		else
			if(!mob_list.Remove(L))
				mob_list.Cut(i,i+1)

		scheck()
	//updateQueueInstance.init(mob_list, "Life")
	//updateQueueInstance.Run()
