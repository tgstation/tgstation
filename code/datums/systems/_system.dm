#define NEW_DS_GLOBAL(varname) if(varname != src){if(istype(varname)){qdel(varname);}varname = src;}

#define DATASYSTEM_DEF(X) GLOBAL_REAL(DS##X, /datum/system/##X);\
/datum/system/##X/New(){\
	NEW_DS_GLOBAL(DS##X);\
}\
/datum/system/##X

/// This flag, when set, will cause the system to be initialized with the SystemManager, for use when systems aren't "lazyloaded" or do their work on-demand.
#define DS_FLAG_REQUIRES_INITIALIZATION (1<<0)

/**
 * Global systems which are distinct from subsystems in that they do not process by the MC.
 * Data systems or "DS" are used to store round information and procs to interface with that data, if needed.
 */
/datum/system
	/// Name of the system
	var/name = "Datum System"
	/// Flags that pertain to the operation of a datasystem
	var/system_flags = NONE

/datum/system/proc/Initialize()
	SHOULD_CALL_PARENT(FALSE)
	CRASH("This datasystem is trying to initialize without having an Initialize() proc defined!")
