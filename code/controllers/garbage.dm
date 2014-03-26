#define GC_COLLECTIONS_PER_TICK 100 // how many objects we're going to null the vars of per tick
#define GC_COLLECTION_TIMEOUT 300 // deciseconds to wait to let running procs finish before we just say fuck it and force del() the object
#define GC_DEL_CHECK_PER_TICK 100 // number of tests per tick to make sure our GC'd objects are actually GC'd
#define GC_FORCE_DEL_PER_TICK 20 // max force del() calls per tick

var/datum/controller/garbage_collector/garbage = new()

var/list/uncollectable_vars=list(
//	"bounds", // bounds and its ilk are all caught by the issaved() check later on
	"contents",
	"gc_destroyed",
	"invisibility",
	"gender", // Causes runtimes if the logging is on
	"parent",
	"step_size",
)
// These are the vars left from /vg/'s implementation that aren't const or global
// I dunno how many are necessary but since most of these are numbers anyways, I don't care.

/datum/controller/garbage_collector
	var/dels = 0				// number of del()'s we've done this tick
	var/list/queue = list() 	// list of things that have yet to have all their vars nulled out
	var/list/destroyed = list() // list of refID's of things that should be garbage collected
								// refID's are associated with the time at which they time out and need to be manually del()
								// we do this so we aren't constantly locating them and preventing them from being gc'd

/datum/controller/garbage_collector/proc/AddTrash(var/atom/movable/A)
	if(!istype(A))
		return
//	testing("GC: AddTrash([A.type])")
	queue |= A

/datum/controller/garbage_collector/proc/Pop()
	var/atom/movable/A = queue[1]
	if(!A)
		queue.Cut(1, 2)
//		testing("GC: Pop() given null")
		return
	if(!istype(A,/atom/movable))
//		testing("GC: -- Pop() given [A.type]  --")
		queue.Cut(1, 2)
		dels++
		del(A)
		return
	for(var/vname in A.vars)
		if(!issaved(A.vars[vname]))
//			testing("GC: Skipping [vname] in [A.type]: it's const|global|tmp")
			continue
		if(vname in uncollectable_vars)
//			testing("GC: Skipping [vname] in [A.type]: it's uncollectable")
			continue
//		testing("GC: Unsetting [vname] in [A.type]")
		A.vars[vname] = null
//	testing("GC: Pop([A.type]) - destroyed\[\ref[A]\] = [A.gc_destroyed] current time: [world.time] first:[queue[1]] second:[queue.len > 1 ? "[queue[2]]" : "NOTHING"]")
	destroyed["\ref[A]"] = A.gc_destroyed
	queue.Cut(1, 2)

/datum/controller/garbage_collector/proc/process()
	dels = 0
	var/i
	for(i = 1, queue.len && i <= GC_COLLECTIONS_PER_TICK, i++)
		Pop()
	var/time_to_kill = world.time - GC_COLLECTION_TIMEOUT // Anything qdel() but not GC'd BEFORE this time needs to be manually del()
	for(i = 1, destroyed.len && i <= GC_DEL_CHECK_PER_TICK, i++)
		var/refID = destroyed[1]
		var/GCd_at_time = destroyed[refID]
		if(GCd_at_time > time_to_kill)
//			testing("GC: [refID] not old enough, breaking at [world.time] for [GCd_at_time - time_to_kill] deciseconds until [GCd_at_time + GC_COLLECTION_TIMEOUT]")
			break // Everything else is newer, skip them
		var/atom/A = locate(refID)
//		testing("GC: [refID] old enough to test: GCd_at_time: [GCd_at_time] time_to_kill: [time_to_kill] current: [world.time]")
		if(A && A.gc_destroyed == GCd_at_time) // So if something else coincidently gets the same ref, it's not deleted by mistake
			// Something's still referring to the qdel'd object.  Kill it.
			if(dels >= GC_FORCE_DEL_PER_TICK)
//				testing("GC: Reached max force dels per tick [dels] vs [GC_FORCE_DEL_PER_TICK]")
				break // Server's already pretty pounded, everything else can wait 2 seconds
			testing("GC: -- \ref[A] | [A.type] was unable to be garbage collected and was force del() --")
			del(A)
			dels++
//		else
//			testing("GC: [refID] properly GC'd at [world.time] with timeout [GCd_at_time]")
		destroyed.Cut(1, 2)

/**
* NEVER USE THIS FOR ANYTHING OTHER THAN /atom/movable
* OTHER TYPES CANNOT BE QDEL'D BECAUSE THEIR LOC IS LOCKED OR THEY DON'T HAVE ONE.
* While I'm leaving the above comment in since /atoms cannot be garbage collected, datums and lists can be garbage collected just fine.
* Read the DM guide on it. Hit f1 and search for "garbage collection"
*/
/proc/qdel(var/atom/movable/A)
	if(!A)
		return
	if(!garbage)
		del(A)
		return
	if(!istype(A))
		warning("qdel() passed object of type [A.type]. qdel() can only handle /atom/movable types.")
		garbage.dels++
		del(A)
		return
	// Let our friend know they're about to get fucked up.
	A.Destroy()
	garbage.AddTrash(A)


/*
// Uncomment this verb and run it on things to report blockages.
/atom/verb/qdel_test()
	set name = "qdel with test"
	set category = "Debug"
	set background = 1
	set src in world

	qdel(src)
	for(var/datum/everything) //Yes this works.
		for(var/everyvar in everything.vars)
			var/variable = everything.vars[everyvar]
			if(variable == src)
				testing("Found [src.type] \ref[src] in [everything.type]'s [everyvar] var.")
			else if(islist(variable))
				if(src in variable)
					testing("Found [src.type]\ref[src] in [everything.type]'s [everyvar] var.")
	for(var/atom/movable/everything) //The slow part.
		for(var/everyvar in everything.vars)
			var/variable = everything.vars[everyvar]
			if(variable == src)
				testing("Found [src.type] \ref[src] in [everything.type]'s [everyvar] var.")
			else if(islist(variable))
				if(src in variable)
					testing("Found [src.type]\ref[src] in [everything.type]'s [everyvar] var.")
*/