SUBSYSTEM_DEF(profiler)
	name = "Profiler"
	init_order = INIT_ORDER_PROFILER
	runlevels = RUNLEVELS_DEFAULT | RUNLEVEL_LOBBY
	wait = 300 SECONDS
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
	wait = CONFIG_GET(number/profiler_interval)
	return SS_INIT_SUCCESS

/datum/controller/subsystem/profiler/OnConfigLoad()
	if(CONFIG_GET(flag/auto_profile))
		StartProfiling()
		can_fire = TRUE
	else
		StopProfiling()
		can_fire = FALSE

/datum/controller/subsystem/profiler/fire()
	DumpFile()

/datum/controller/subsystem/profiler/Shutdown()
	if(CONFIG_GET(flag/auto_profile))
		DumpFile(allow_yield = FALSE)
		world.Profile(PROFILE_CLEAR, type = "sendmaps")
	return ..()

/datum/controller/subsystem/profiler/proc/StartProfiling()
	world.Profile(PROFILE_START)
	world.Profile(PROFILE_START, type = "sendmaps")

/datum/controller/subsystem/profiler/proc/StopProfiling()
	world.Profile(PROFILE_STOP)
	world.Profile(PROFILE_STOP, type = "sendmaps")

/datum/controller/subsystem/profiler/proc/DumpFile(allow_yield = TRUE)
	var/timer = TICK_USAGE_REAL
	var/current_profile_data = world.Profile(PROFILE_REFRESH, format = "json")
	var/current_sendmaps_data = world.Profile(PROFILE_REFRESH, type = "sendmaps", format="json")
	fetch_cost = MC_AVERAGE(fetch_cost, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))
	if(allow_yield)
		CHECK_TICK

	if(!length(current_profile_data)) //Would be nice to have explicit proc to check this
		stack_trace("Warning, profiling stopped manually before dump.")
	var/prof_file = file("[GLOB.log_directory]/profiler/profiler-[round(world.time * 0.1, 10)].json")
	if(fexists(prof_file))
		fdel(prof_file)
	if(!length(current_sendmaps_data)) //Would be nice to have explicit proc to check this
		stack_trace("Warning, sendmaps profiling stopped manually before dump.")
	var/sendmaps_file = file("[GLOB.log_directory]/profiler/sendmaps-[round(world.time * 0.1, 10)].json")
	if(fexists(sendmaps_file))
		fdel(sendmaps_file)

	timer = TICK_USAGE_REAL
	WRITE_FILE(prof_file, current_profile_data)
	WRITE_FILE(sendmaps_file, current_sendmaps_data)
	write_cost = MC_AVERAGE(write_cost, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))

