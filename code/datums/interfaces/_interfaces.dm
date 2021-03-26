/**
 * # Interface
 *
 * A datum that represents a collection of vars and procs.
 * Does not actually contain any functionality itself.
 *
 * Any procs on an interface should be declared using [DEF_INTERFACE_PROC] so they can be checked.
 */
/datum/interface
	/// The var used to hold all the procs declared by this interfaces. Because an equivalent to .vars does not exist for procs.
	var/list/INTERFACE_PROC_CACHE_NAME

/datum/interface/New()
	. = ..()
	INTERFACE_PROC_CACHE_NAME = ____aggregate_procs()

/// Aggregates a list of all of the procs this interface declares.
/datum/interface/proc/____aggregate_procs()
	. = list()
