#define GC_COLLECTIONS_PER_TICK 300 // Was 100.
#define GC_COLLECTION_TIMEOUT (10 SECONDS)
#define GC_FORCE_DEL_PER_TICK 20
//#define GC_DEBUG

var/global/datum/controller/garbage_collector/garbage

/datum/controller/garbage_collector
	processing_interval = GC_COLLECTION_TIMEOUT

	var/list/queue = list()
	var/del_everything = 1

	// To let them know how hardworking am I :^).
	var/dels_count = 0
	var/hard_dels = 0

/datum/controller/garbage_collector/New()
	. = ..()

	if (garbage != src)
		if (istype(garbage))
			recover()
			qdel(garbage)

		garbage = src

/datum/controller/garbage_collector/proc/addTrash(const/atom/movable/AM)
	if (isnull(AM))
		return

	if (del_everything)
		del AM
		hard_dels++
		dels_count++
		return

	var/timeofday = world.timeofday
	AM.timeDestroyed = timeofday
	queue -= "\ref[AM]"
	queue["\ref[AM]"] = timeofday

/datum/controller/garbage_collector/proc/process()
	processing = 1

	spawn (0)
		var/remainingCollectionPerTick
		var/remainingForceDelPerTick
		var/collectionTimeScope

		while (1)
			iteration++

			if (processing)
				remainingCollectionPerTick = GC_COLLECTIONS_PER_TICK
				remainingForceDelPerTick = GC_FORCE_DEL_PER_TICK
				collectionTimeScope = world.timeofday - GC_COLLECTION_TIMEOUT

				while (queue.len && --remainingCollectionPerTick >= 0)
					var/refID = queue[1]
					var/destroyedAtTime = queue[refID]

					if (destroyedAtTime > collectionTimeScope)
						break

					var/atom/A = locate(refID)

					// Something's still referring to the qdel'd object. Kill it.
					if (A && A.timeDestroyed == destroyedAtTime)
						if (remainingForceDelPerTick <= 0)
							break

						#ifdef GC_DEBUG
						WARNING("gc process force delete [A.type]")
						#endif

						del A

						hard_dels++
						remainingForceDelPerTick--

					queue.Cut(1, 2)
					dels_count++

			sleep(processing_interval)

#ifdef GC_DEBUG
#undef GC_DEBUG
#endif

/datum/controller/garbage_collector/recover()
	. = ..()
	iteration = garbage.iteration
	del_everything = garbage.del_everything
	queue = garbage.queue.Copy()
	dels_count = garbage.dels_count
	hard_dels = garbage.hard_dels
	processing_interval = garbage.processing_interval

#undef GC_FORCE_DEL_PER_TICK
#undef GC_COLLECTION_TIMEOUT
#undef GC_COLLECTIONS_PER_TICK

/proc/qdel(const/O)
	if (isnull(O))
		return

	if (isnull(garbage))
		del O
		return

	if (!istype(O, /datum))
		del O
		garbage.hard_dels++
		garbage.dels_count++
		return

	var/datum/D = O

	if (isnull(D.gcDestroyed))
		// Let our friend know they're about to get fucked up.
		D.Destroy()

		if (D)
			if (isturf(D))
				del D
				return

			garbage.addTrash(D)

/datum
	// Garbage collection (qdel).
	var/gcDestroyed
	var/timeDestroyed

/datum/controller
	var/processing = 0
	var/iteration = 0
	var/processing_interval = 0

/datum/controller/proc/recover() // If we are replacing an existing controller (due to a crash) we attempt to preserve as much as we can.

/datum/controller/New()
	. = ..()
	tag = "[type]:NOGC"

/datum/Del()
	sleep(-1)
	..()

/*
 * Like Del(), but for qdel.
 * Called BEFORE qdel moves shit.
 */
/datum/proc/Destroy()
	del src

/datum/controller/Destroy()
	tag = null
	..()

/client/proc/qdel_toggle()
	set name = "Toggle qdel Behavior"
	set desc = "Toggle qdel usage between normal and force del()."
	set category = "Debug"

	garbage.del_everything = !garbage.del_everything
	world << "<b>GC: qdel turned [garbage.del_everything?"off":"on"].</b>"
	log_admin("[key_name(usr)] turned qdel [garbage.del_everything?"off":"on"].")
	message_admins("\blue [key_name(usr)] turned qdel [garbage.del_everything?"off":"on"].", 1)