#define PROFILER_FILENAME "profiler.json"

#ifdef SENDMAPS_PROFILE
#define SENDMAPS_FILENAME "sendmaps.json"
GLOBAL_REAL_VAR(world_init_maptick_profiler) = world.Profile(PROFILE_RESTART, type = "sendmaps")
#endif

SUBSYSTEM_DEF(profiler)
	name = "Profiler"
	init_order = INIT_ORDER_PROFILER
	runlevels = RUNLEVELS_DEFAULT | RUNLEVEL_LOBBY
	wait = 3000
	var/fetch_cost = 0
	var/write_cost = 0

/datum/controller/subsystem/profiler/stat_entry(msg)
	msg += "F:[round(fetch_cost,1)]ms"
	msg += "|W:[round(write_cost,1)]ms"
	return msg

/datum/controller/subsystem/profiler/Initialize()
	if(CONFIG_GET(flag/auto_profile))
		StartProfiling()
	else
		StopProfiling() //Stop the early start profiler
	return ..()

/datum/controller/subsystem/profiler/fire()
	if(CONFIG_GET(flag/auto_profile))
		DumpFile()

/datum/controller/subsystem/profiler/Shutdown()
	if(CONFIG_GET(flag/auto_profile))
		DumpFile()
#ifdef SENDMAPS_PROFILE
		world.Profile(PROFILE_CLEAR, type = "sendmaps")
#endif
	return ..()

/datum/controller/subsystem/profiler/proc/StartProfiling()
#if DM_BUILD < 1506
	stack_trace("Auto profiling unsupported on this byond version")
	CONFIG_SET(flag/auto_profile, FALSE)
#else
	world.Profile(PROFILE_START)
#ifdef SENDMAPS_PROFILE
	world.Profile(PROFILE_START, type = "sendmaps")
#endif

#endif

/datum/controller/subsystem/profiler/proc/StopProfiling()
#if DM_BUILD >= 1506
	world.Profile(PROFILE_STOP)
#ifdef SENDMAPS_PROFILE
	world.Profile(PROFILE_STOP, type = "sendmaps")
#endif
#endif

/datum/controller/subsystem/profiler/proc/DumpFile()
#if DM_BUILD < 1506
	stack_trace("Auto profiling unsupported on this byond version")
	CONFIG_SET(flag/auto_profile, FALSE)
#else
	var/timer = TICK_USAGE_REAL
	var/current_profile_data = world.Profile(PROFILE_REFRESH, format = "json")
#ifdef SENDMAPS_PROFILE
	var/current_sendmaps_data = world.Profile(PROFILE_REFRESH, type = "sendmaps", format="json")
#endif
	fetch_cost = MC_AVERAGE(fetch_cost, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))
	CHECK_TICK

	if(!length(current_profile_data)) //Would be nice to have explicit proc to check this
		stack_trace("Warning, profiling stopped manually before dump.")
	var/prof_file = file("[GLOB.log_directory]/[PROFILER_FILENAME]")
	if(fexists(prof_file))
		fdel(prof_file)
#ifdef SENDMAPS_PROFILE
	if(!length(current_sendmaps_data)) //Would be nice to have explicit proc to check this
		stack_trace("Warning, sendmaps profiling stopped manually before dump.")
	var/sendmaps_file = file("[GLOB.log_directory]/[SENDMAPS_FILENAME]")
	if(fexists(sendmaps_file))
		fdel(sendmaps_file)
#endif

	timer = TICK_USAGE_REAL
	WRITE_FILE(prof_file, current_profile_data)
#ifdef SENDMAPS_PROFILE
	WRITE_FILE(sendmaps_file, current_sendmaps_data)
#endif
	write_cost = MC_AVERAGE(write_cost, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))
#endif
