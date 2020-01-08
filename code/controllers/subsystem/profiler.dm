#define PROFILER_FILENAME "profiler.json"

SUBSYSTEM_DEF(profiler)
	name = "Profiler"
	init_order = INIT_ORDER_PROFILER
	flags = SS_NO_FIRE

/datum/controller/subsystem/profiler/Initialize()
	if(CONFIG_GET(flag/auto_profile))
		StartProfiling()
	return ..()

/datum/controller/subsystem/profiler/proc/StartProfiling()
#if DM_BUILD < 1506
	stack_trace("Auto profiling unsupported on this byond version")
#else
	world.Profile(PROFILE_START)
#endif

/datum/controller/subsystem/profiler/proc/DumpFile()
#if DM_BUILD < 1506
	stack_trace("Auto profiling unsupported on this byond version")
#else
	var/current_profile_data = world.Profile(PROFILE_REFRESH,format="json")
	if(!length(current_profile_data)) //Would be nice to have explicit proc to check this
		stack_trace("Warning, profiling stopped manually before dump.")
	var/json_file = file("[GLOB.log_directory]/[PROFILER_FILENAME]")
	if(fexists(json_file))
		fdel(json_file)
	WRITE_FILE(json_file, current_profile_data)
#endif

/datum/controller/subsystem/profiler/Shutdown()
	if(CONFIG_GET(flag/auto_profile))
		DumpFile()
	return ..()
