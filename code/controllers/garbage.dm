#define GC_COLLECTIONS_PER_TICK 300 // Was 100.
#define GC_COLLECTION_TIMEOUT (10 SECONDS)
#define GC_FORCE_DEL_PER_TICK 20
//#define GC_DEBUG

var/list/gc_hard_del_types = new
var/datum/garbage_collector/garbageCollector

/client/verb/gc_dump_hdl()
	set name = "(GC) Hard Del List"
	set desc = "List types that are hard del()'d by the GC."
	set category = "Debug"

	for(var/A in gc_hard_del_types)
		usr << A

/datum/garbage_collector
	var/list/queue = new
	var/del_everything = 0

	// To let them know how hardworking am I :^).
	var/dels_count = 0
	var/hard_dels = 0

/datum/garbage_collector/proc/addTrash(const/atom/movable/AM)
	if(!istype(AM))
		return

	if(del_everything)
		del(AM)
		hard_dels++
		dels_count++
		return

	var/timeofday = world.timeofday
	AM.timeDestroyed = timeofday
	queue -= "\ref[AM]"
	queue["\ref[AM]"] = timeofday

/datum/garbage_collector/proc/process()
	var/remainingCollectionPerTick = GC_COLLECTIONS_PER_TICK
	var/remainingForceDelPerTick = GC_FORCE_DEL_PER_TICK
	var/collectionTimeScope = world.timeofday - GC_COLLECTION_TIMEOUT

	while(queue.len && --remainingCollectionPerTick >= 0)
		var/refID = queue[1]
		var/destroyedAtTime = queue[refID]

		if(destroyedAtTime > collectionTimeScope)
			break

		var/atom/movable/AM = locate(refID)

		// Something's still referring to the qdel'd object. Kill it.
		if(AM && AM.timeDestroyed == destroyedAtTime)
			if(remainingForceDelPerTick <= 0)
				break

			#ifdef GC_DEBUG
			WARNING("gc process force delete [AM.type]")
			#endif

			gc_hard_del_types |= "[AM.type]"

			del(AM)

			hard_dels++
			remainingForceDelPerTick--

		queue.Cut(1, 2)
		dels_count++

#ifdef GC_DEBUG
#undef GC_DEBUG
#endif

#undef GC_FORCE_DEL_PER_TICK
#undef GC_COLLECTION_TIMEOUT
#undef GC_COLLECTIONS_PER_TICK

/*
 * NEVER USE THIS FOR ANYTHING OTHER THAN /atom/movable
 * OTHER TYPES CANNOT BE QDEL'D BECAUSE THEIR LOC IS LOCKED OR THEY DON'T HAVE ONE.
 */
/proc/qdel(const/atom/movable/AM)
	if(isnull(AM))
		return

	if(isnull(garbageCollector))
		del(AM)
		return

	if(!istype(AM))
		WARNING("qdel() passed object of type [AM.type]. qdel() can only handle /atom/movable types.")
		del(AM)
		garbageCollector.hard_dels++
		garbageCollector.dels_count++
		return

	if(isnull(AM.gcDestroyed))
		// Let our friend know they're about to get fucked up.
		AM.Destroy()

		garbageCollector.addTrash(AM)

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
	del(src)

/client/proc/qdel_toggle()
	set name = "Toggle qdel Behavior"
	set desc = "Toggle qdel usage between normal and force del()."
	set category = "Debug"

	garbageCollector.del_everything = !garbageCollector.del_everything
	world << "<b>GC: qdel turned [garbageCollector.del_everything ? "off" : "on"].</b>"
	log_admin("[key_name(usr)] turned qdel [garbageCollector.del_everything ? "off" : "on"].")
	message_admins("\blue [key_name(usr)] turned qdel [garbageCollector.del_everything ? "off" : "on"].", 1)
