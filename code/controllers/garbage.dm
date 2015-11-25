#define GC_COLLECTIONS_PER_TICK 300 // Was 100.
#define GC_COLLECTION_TIMEOUT (30 SECONDS)
#define GC_FORCE_DEL_PER_TICK 60
//#define GC_DEBUG

var/list/gc_hard_del_types = new
var/datum/garbage_collector/garbageCollector
var/soft_dels = 0
/client/verb/gc_dump_hdl()
	set name = "(GC) Hard Del List"
	set desc = "List types that are hard del()'d by the GC."
	set category = "Debug"

	for(var/A in gc_hard_del_types)
		to_chat(usr, "[A] = [gc_hard_del_types[A]]")

/datum/garbage_collector
	var/list/queue = new
	var/del_everything = 0

	// To let them know how hardworking am I :^).
	var/dels_count = 0
	var/hard_dels = 0

/datum/garbage_collector/proc/addTrash(const/datum/D)
	if(istype(D, /atom) && !istype(D, /atom/movable))
		return

	if(del_everything)
		del(D)
		hard_dels++
		dels_count++
		return

	queue["\ref[D]"] = world.timeofday

/datum/garbage_collector/proc/process()
	var/remainingCollectionPerTick = GC_COLLECTIONS_PER_TICK
	var/remainingForceDelPerTick = GC_FORCE_DEL_PER_TICK
	var/collectionTimeScope = world.timeofday - GC_COLLECTION_TIMEOUT
	if(narsie_cometh) return //don't even fucking bother, its over.
	while(queue.len && --remainingCollectionPerTick >= 0)
		var/refID = queue[1]
		var/destroyedAtTime = queue[refID]

		if(destroyedAtTime > collectionTimeScope)
			break

		var/datum/D = locate(refID)
		if(D) // Something's still referring to the qdel'd object. del it.
			if(isnull(D.gcDestroyed))
				queue -= refID
				continue
			if(remainingForceDelPerTick <= 0)
				break

			#ifdef GC_DEBUG
			WARNING("gc process force delete [D.type]")
			#endif

			if(istype(D, /atom/movable))
				var/atom/movable/AM = D
				AM.hard_deleted = 1

			del D

			hard_dels++
			remainingForceDelPerTick--
			if(world.cpu > 80)
				#ifdef GG_DEBUG
				WARNING("GC process sleeping due to high CPU usage!")
				#endif
				sleep(calculateticks(2))

#ifdef GC_DEBUG
#undef GC_DEBUG
#endif

#undef GC_FORCE_DEL_PER_TICK
#undef GC_COLLECTION_TIMEOUT
#undef GC_COLLECTIONS_PER_TICK

/datum/garbage_collector/proc/dequeue(id)
	if (queue)
		queue -= id

	dels_count++

/*
 * NEVER USE THIS FOR /atom OTHER THAN /atom/movable
 * BASE ATOMS CANNOT BE QDEL'D BECAUSE THEIR LOC IS LOCKED.
 */
/proc/qdel(const/datum/D, ignore_pooling = 0, ignore_destroy = 0)
	if(isnull(D))
		return

	if(isnull(garbageCollector))
		del(D)
		return

	if(istype(D, /atom) && !istype(D, /atom/movable))
		WARNING("qdel() passed object of type [D.type]. qdel() cannot handle unmovable atoms.")
		del(D)
		garbageCollector.hard_dels++
		garbageCollector.dels_count++
		return

	//We are object pooling this.
	if(("[D.type]" in masterdatumPool) && !ignore_pooling)
		returnToPool(D)
		return

	if(isnull(D.gcDestroyed))
		// Let our friend know they're about to get fucked up.
		if(!ignore_destroy)
			D.Destroy()

		garbageCollector.addTrash(D)

/datum/controller
	var/processing = 0
	var/iteration = 0
	var/processing_interval = 0

/datum/controller/proc/recover() // If we are replacing an existing controller (due to a crash) we attempt to preserve as much as we can.

/*
 * Like Del(), but for qdel.
 * Called BEFORE qdel moves shit.
 */
/datum/proc/Destroy()
	qdel(src, 1, 1)

/client/proc/qdel_toggle()
	set name = "Toggle qdel Behavior"
	set desc = "Toggle qdel usage between normal and force del()."
	set category = "Debug"

	garbageCollector.del_everything = !garbageCollector.del_everything
	to_chat(world, "<b>GC: qdel turned [garbageCollector.del_everything ? "off" : "on"].</b>")
	log_admin("[key_name(usr)] turned qdel [garbageCollector.del_everything ? "off" : "on"].")
	message_admins("<span class='notice'>[key_name(usr)] turned qdel [garbageCollector.del_everything ? "off" : "on"].</span>", 1)

/*/client/var/running_find_references

/atom/verb/find_references()
	set category = "Debug"
	set name = "Find References"
	set background = 1
	set src in world

	if(!usr || !usr.client)
		return

	if(usr.client.running_find_references)
		testing("CANCELLED search for references to a [usr.client.running_find_references].")
		usr.client.running_find_references = null
		return

	if(alert("Running this will create a lot of lag until it finishes.  You can cancel it by running it again.  Would you like to begin the search?", "Find References", "Yes", "No") == "No")
		return
	qdel(src)
	// Remove this object from the list of things to be auto-deleted.
	if(garbageCollector)
		garbageCollector.queue -= "\ref[src]"

	usr.client.running_find_references = type
	testing("Beginning search for references to a [type].")
	var/list/things = list()
	for(var/client/thing)
		things += thing
	for(var/datum/thing)
		things += thing
	for(var/atom/thing)
		things += thing
	for(var/event/thing)
		things += thing
	testing("Collected list of things in search for references to a [type]. ([things.len] Thing\s)")
	for(var/datum/thing in things)
		if(!usr.client.running_find_references) return
		for(var/varname in thing.vars)
			var/variable = thing.vars[varname]
			if(variable == src)
				testing("Found [src.type] \ref[src] in [thing.type]'s [varname] var.")
			else if(islist(variable))
				if(src in variable)
					testing("Found [src.type] \ref[src] in [thing.type]'s [varname] list var.")
	testing("Completed search for references to a [type].")
	usr.client.running_find_references = null
*/