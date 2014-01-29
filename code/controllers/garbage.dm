
#define GC_COLLECTIONS_PER_TICK 100
var/global/datum/controller/garbage_collector/garbage

/datum/controller/garbage_collector
	var/list/queue=list()
	var/waiting=0
	var/turf/trashbin=null

	New()
		trashbin=locate(0,0,CENTCOMM_Z)

	proc/AddTrash(var/atom/movable/A)
		if(!A)
			return
		A.loc=trashbin
		queue.Add(A)
		waiting++

	proc/Pop()
		var/atom/movable/A = queue[1]
		if(!A) return
		if(!istype(A,/atom/movable))
			testing("GC given a [A.type].")
			del(A)
			return
		for(var/vname in A.vars)
			switch(vname)
				if("tag","bestF","type","parent_type","vars","type","loc","locs","vars", "parent", "parent_type","verbs","ckey","key","x","y","z","contents", "luminosity", "gender", "alpha", "color")
					continue
				else
					A.vars[vname]=null
		queue.Remove(A)

	proc/process()
		for(var/i=0;i<min(waiting,GC_COLLECTIONS_PER_TICK);i++)
			if(waiting)
				Pop()
				waiting--

/proc/qdel(var/atom/A)
	garbage.AddTrash(A)