#define GC_COLLECTIONS_PER_TICK 100 // maybe make this a config option at some point
#define GC_COLLECTION_TIMEOUT 300 // deciseconds to wait to let running procs finish before we just say fuck it and force del() the object
var/datum/controller/garbage_collector/garbage = new()
var/list/uncollectable_vars=list(
//	"bounds", // bounds and its ilk are all caught by the issaved() check later on
	"contents",
	"gc_destroyed",
	"gender", // Causes runtimes if the logging is on
	"parent",
	"step_size",
)
// These are the vars left from /vg/'s implementation that aren't const or global
// I dunno how many are necessary but since most of these are numbers anyways, I don't care.

/datum/controller/garbage_collector
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
//	testing("GC: Pop([A.type]) - destroyed\[\ref[A]\] = [A.gc_destroyed] current time: [world.timeofday]")
	destroyed["\ref[A]"] = A.gc_destroyed
	queue.Cut(1, 2)

/datum/controller/garbage_collector/proc/process()
	var/i = 1
	while(queue.len && i <= GC_COLLECTIONS_PER_TICK)
		Pop()
		i++
	i = 1
	var/time_to_kill = world.timeofday - GC_COLLECTION_TIMEOUT // Anything qdel() but not GC'd BEFORE this time needs to be manually del()
	if(time_to_kill < 1) // Within the first GC_COLLECTION_TIMEOUT deciseconds of midnight
		time_to_kill += MIDNIGHT_ROLLOVER
	while(i <= destroyed.len && i <= GC_COLLECTIONS_PER_TICK)
		var/refID = destroyed[i]
		var/GCd_at_time = destroyed[refID]
		if(GCd_at_time > time_to_kill)
//			testing("GC: [refID] not old enough, breaking at [world.timeofday] for [time_to_kill - GCd_at_time] deciseconds")
			i++
			break // Everything else is newer, skip them
		var/atom/A = locate(refID)
//		testing("GC: [refID] old enough to test: GCd_at_time: [GCd_at_time] time_to_kill: [time_to_kill] current: [world.timeofday]")
		if(A && A.gc_destroyed == GCd_at_time) // So if something else coincidently gets the same ref, it's not deleted by mistake
			// Something's still referring to the qdel'd object.  Kill it.
			testing("GC: -- \ref[A] | [A.type] was unable to be garbage collected and was force del() --")
			del(A)
//		else
//			testing("GC: [refID] properly GC'd at [world.timeofday] with timeout [GCd_at_time]")
		destroyed.Cut(i, ++i) // also increases i in general
/**
* NEVER USE THIS FOR ANYTHING OTHER THAN /atom/movable
* OTHER TYPES CANNOT BE QDEL'D BECAUSE THEIR LOC IS LOCKED OR THEY DON'T HAVE ONE.
* While I'm leaving the above comment in since /atoms cannot be garbage collected, datums and lists can be garbage collected just fine.
* Read the DM guide on it. Hit f1 and search for "garbage collection"
*/
/proc/qdel(var/atom/movable/A)
	if(!A)
		return
	if(!istype(A))
		warning("qdel() passed object of type [A.type]. qdel() can only handle /atom/movable types.")
		del(A)
		return
	if(!garbage)
		del(A)
		return
	// Let our friend know they're about to get fucked up.
	A.Destroy()
	garbage.AddTrash(A)

/* // If you can get this to run, report the results please.
/client/verb/delete_everything()
	set name = "qdel() everything"
	set category = "Debug"
	set background = 1

	if(input("Are you sure you want to do that?") as null|anything in list("Yes","No") != "Yes")
		return
	src << "qdel(everything)"
	for(var/atom/movable/everything in world)
		qdel(everything)
*/