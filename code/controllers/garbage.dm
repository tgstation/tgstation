#define GC_COLLECTIONS_PER_TICK 250 // Was 100.
#define GC_COLLECTION_TIMEOUT 100 // 10s.
#define GC_FORCE_DEL_PER_TICK 20

var/global/datum/controller/garbage_collector/garbage

/datum/controller/garbage_collector
	var/list/queue = list()
	var/del_everything = 1

	// To let them know how hardworking am I :^).
	var/dels_count = 0
	var/hard_dels = 0

/datum/controller/garbage_collector/proc/process()
	var/dels = 0
	var/queue_size = min(queue.len, GC_COLLECTIONS_PER_TICK)

	for (var/i = 0, ++i <= queue_size)
		var/atom/movable/A = locate(queue[1])

		if (A && A.gc_destroyed)
			if (++dels <= GC_FORCE_DEL_PER_TICK)
				break

			WARNING("gc process force delete [A.type]")

			// Something's still referring to the qdel'd object. Kill it.
			del A
			hard_dels++

		queue.Cut(1, 2)
		dels_count++

#undef GC_FORCE_DEL_PER_TICK
#undef GC_COLLECTION_TIMEOUT
#undef GC_COLLECTIONS_PER_TICK

/datum/controller/garbage_collector/proc/AddTrash(const/atom/movable/A)
	if (isnull(A))
		return

	if (del_everything)
		del A
		hard_dels++
		dels_count++
		return

	queue.Add(A)

/*
 * NEVER USE THIS FOR ANYTHING OTHER THAN /atom/movable and derived types.
 */
/proc/qdel(const/atom/movable/A)
	if (isnull(A))
		return

	if (isnull(garbage))
		del A
		return

	if (!istype(A))
		WARNING("qdel() passed object of type [A.type]. qdel() can only handle /atom/movable derived types.")
		del A
		garbage.hard_dels++
		garbage.dels_count++
		return

	// Let our friend know they're about to get fucked up.
	A.Destroy()

	garbage.AddTrash(A)

/client/proc/qdel_toggle()
	set name = "Toggle qdel Behavior"
	set desc = "Toggle qdel usage between normal and force del()."
	set category = "Debug"

	garbage.del_everything = !garbage.del_everything
	world << "<b>GC: qdel turned [garbage.del_everything?"off":"on"].</b>"
	log_admin("[key_name(usr)] turned qdel [garbage.del_everything?"off":"on"].")
	message_admins("\blue [key_name(usr)] turned qdel [garbage.del_everything?"off":"on"].", 1)