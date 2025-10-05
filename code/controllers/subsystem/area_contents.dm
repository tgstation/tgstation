#define ALLOWED_LOOSE_TURFS 100
/**
 * Responsible for managing the sizes of area.contained_turfs and area.turfs_to_uncontain
 * These lists do not check for duplicates, which is fine, but it also means they can balloon in size over time
 * as a consequence of repeated changes in area in a space
 * They additionally may not always resolve often enough to avoid memory leaks
 * This is annoying, so lets keep an eye on them and cut them down to size if needed
 */
SUBSYSTEM_DEF(area_contents)
	name = "Area Contents"
	flags = SS_NO_INIT
	runlevels = RUNLEVEL_LOBBY|RUNLEVELS_DEFAULT
	var/list/currentrun
	var/list/area/marked_for_clearing = list()

/datum/controller/subsystem/area_contents/stat_entry(msg)
	var/total_clearing_from = 0
	var/total_to_clear = 0
	for(var/area/to_clear as anything in marked_for_clearing)
		for (var/area_zlevel in 1 to length(to_clear.turfs_to_uncontain_by_zlevel))
			if (length(to_clear.turfs_to_uncontain_by_zlevel[area_zlevel]))
				total_to_clear += length(to_clear.turfs_to_uncontain_by_zlevel[area_zlevel])
				if (length(to_clear.turfs_by_zlevel) >= area_zlevel) //this should always be true, but stat_entry is no place for runtimes. fire() can handle that
					total_clearing_from += length(to_clear.turfs_by_zlevel[area_zlevel])
	msg = "\n  A:[length(currentrun)] MR:[length(marked_for_clearing)] TC:[total_to_clear] CF:[total_clearing_from]"
	return ..()


/datum/controller/subsystem/area_contents/fire(resumed)
	if(!resumed)
		currentrun = GLOB.areas.Copy()

	while(length(currentrun))
		var/area/test = currentrun[length(currentrun)]
		for (var/area_zlevel in 1 to length(test.turfs_to_uncontain_by_zlevel))
			if(length(test.turfs_to_uncontain_by_zlevel[area_zlevel]) > ALLOWED_LOOSE_TURFS)
				marked_for_clearing |= test
				break
		currentrun.len--
		if(MC_TICK_CHECK)
			return

	// Alright, if we've done a scan on all our areas, it's time to knock the existing ones down to size
	while(length(marked_for_clearing))
		var/area/clear = marked_for_clearing[length(marked_for_clearing)]

		for (var/area_zlevel in 1 to length(clear.turfs_to_uncontain_by_zlevel))
			if (!length(clear.turfs_to_uncontain_by_zlevel[area_zlevel]))
				continue
			if (length(clear.turfs_by_zlevel) < area_zlevel)
				stack_trace("[clear]([clear.type])'s turfs_by_zlevel is length [length(clear.turfs_by_zlevel)] but we are being asked to remove turfs from zlevel [area_zlevel] from it.")
				clear.turfs_to_uncontain_by_zlevel[area_zlevel] = list()
				continue

			// The operation of cutting large lists can be expensive
			// It scales almost directly with the size of the list we're cutting with
			// Because of this, we're gonna stick to cutting 1 entry at a time
			// There's no reason to batch it I promise, this is faster. No overtime too
			var/amount_cut = 0
			var/list/cut_from = clear.turfs_to_uncontain_by_zlevel[area_zlevel]
			for(amount_cut in 1 to length(cut_from))
				clear.turfs_by_zlevel[area_zlevel] -= cut_from[amount_cut]
				if(MC_TICK_CHECK)
					cut_from.Cut(1, amount_cut + 1)
					return

		clear.turfs_to_uncontain_by_zlevel = list()
		marked_for_clearing.len--

#undef ALLOWED_LOOSE_TURFS
