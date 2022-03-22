#define INIT_PROFILE_NAME "init_profiler.json"

///Subsystem exists so we can separately log init time costs from the costs of general operation
///Hopefully this makes sorting out what causes problems when easier
SUBSYSTEM_DEF(init_profiler)
	name = "Init Profiler"
	init_order = INIT_ORDER_INIT_PROFILER
	flags = SS_NO_FIRE

/datum/controller/subsystem/init_profiler/Initialize()
	if(CONFIG_GET(flag/auto_profile))
		write_init_profile()
	return ..()

/datum/controller/subsystem/init_profiler/proc/write_init_profile()
	var/current_profile_data = world.Profile(PROFILE_REFRESH, format = "json")
	CHECK_TICK

	if(!length(current_profile_data)) //Would be nice to have explicit proc to check this
		stack_trace("Warning, profiling stopped manually before dump.")
	var/prof_file = file("[GLOB.log_directory]/[INIT_PROFILE_NAME]")
	if(fexists(prof_file))
		fdel(prof_file)
	WRITE_FILE(prof_file, current_profile_data)
	world.Profile(PROFILE_CLEAR) //Now that we're written this data out, dump it. We don't want it getting mixed up with our current round data
