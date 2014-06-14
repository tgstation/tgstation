#define GC_COLLECTIONS_PER_TICK 250 // Was 100.
#define GC_COLLECTION_TIMEOUT 100 // 10s.
#define GC_FORCE_DEL_PER_TICK 15

var/global/datum/controller/garbage_collector/garbage

var/global/list/uncollectable_vars=list(
	"alpha",
	"bestF",
	"bounds",
	"bound_height",
	"bound_width",
	"ckey",
	"color",
	"contents",
	"gender",
	"group",
	"key",
	//"loc",
	"locs",
	"luminosity",
	"parent",
	"parent_type",
	"step_size",
	"glide_size",
	"gc_destroyed",
	"step_x",
	"step_y",
	"step_z",
	"tag",
	"thermal_conductivity",
	"type",
	"vars",
	"verbs",
	"x",
	"y",
	"z",
)

/datum/controller/garbage_collector
	var/list/queue = list()
	var/list/destroyed = list()
	var/waiting = 0
	var/del_everything = 1
	var/dels = 0

/datum/controller/garbage_collector/proc/Pop()
	var/atom/A = queue[1]

	if (isnull(A))
		var/loopcheck = 0

		while (queue.Remove(null))
			loopcheck++

			if (loopcheck > 50)
				break

		return

	if (del_everything)
		del A
		return

	if (!istype(A,/atom/movable))
		testing("GC given a [A.type].")
		del A
		return

	for (var/vname in A.vars)
		if (!issaved(A.vars[vname]))
			continue

		if (vname in uncollectable_vars)
			continue

		//testing("Unsetting [vname] in [A.type]!")
		A.vars[vname] = null

	destroyed.Add("\ref[A]")
	queue.Remove(A)

/datum/controller/garbage_collector/proc/process()
	dels = 0

	for (var/i = 0, ++i <= min(waiting, GC_COLLECTIONS_PER_TICK))
		if (waiting--)
			Pop()

	for (var/i = 0, ++i <= min(destroyed.len, GC_COLLECTIONS_PER_TICK))
		var/refID = destroyed[1]
		var/atom/A = locate(refID)

		if (A && A.gc_destroyed && A.gc_destroyed >= world.timeofday - GC_COLLECTION_TIMEOUT)
			// Something's still referring to the qdel'd object. Kill it.
			del A
			dels++

		destroyed.Remove(refID)

/datum/controller/garbage_collector/proc/AddTrash(const/atom/A)
	if (isnull(A))
		return

	if (del_everything)
		del A
		dels++
		return

	queue.Add(A)
	waiting++

/*
 * NEVER USE THIS FOR ANYTHING OTHER THAN /atom.
 */
/proc/qdel(const/atom/A)
	if (isnull(A)) // Two possibilities, proc is called with null arg or object is gced normally.
		return

	if (isnull(garbage))
		del A
		return

	if (!istype(A))
		WARNING("qdel() passed object of type [A.type]. qdel() can only handle /atom types.")
		del A
		garbage.dels++
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