#define NEW_DS_GLOBAL(varname) if(varname != src){if(istype(varname)){qdel(varname);}varname = src;}

#define DATASYSTEM_DEF(X) GLOBAL_REAL(DS##X, /datum/system/##X);\
/datum/system/##X/New(){\
	NEW_DS_GLOBAL(DS##X);\
}\
/datum/system/##X


/**
 * Global systems which are distinct from subsystems in that they do not process by the MC.
 * Data systems or "DS" are used to store round information and procs to interface with that data, if needed.
 */
/datum/system
	/// Name of the system
	var/name = "Datum System"
	/// Do we need to intialize this system? Defaults to FALSE as most datasystems are "lazyloading", or only store data on demand. This is for stuff that needs to go with the SysMgr
	var/requires_initialization = FALSE

/datum/system/proc/Initialize()
	SHOULD_CALL_PARENT(FALSE)
	CRASH("This datasystem is trying to initialize without having an Initialize() proc defined!")
