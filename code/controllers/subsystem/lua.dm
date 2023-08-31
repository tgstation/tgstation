SUBSYSTEM_DEF(lua)
	name = "Lua Scripting"
	runlevels = RUNLEVEL_LOBBY | RUNLEVELS_DEFAULT
	wait = 0.1 SECONDS
	flags = SS_OK_TO_FAIL_INIT

	/// A list of all lua states
	var/list/datum/lua_state/states = list()

	/// A list of open editors, with each key in the list associated with a list of editors.
	/// Tracks which UIs are open for each state so that they can be updated whenever
	/// code is run in the state.
	var/list/editors

	var/list/sleeps = list()
	var/list/resumes = list()

	var/list/current_run = list()

	/// Protects return values from getting GCed before getting converted to lua values
	/// Gets cleared every tick.
	var/list/gc_guard = list()

/datum/controller/subsystem/lua/Initialize()
	if(!CONFIG_GET(flag/auxtools_enabled))
		warning("SSlua requires auxtools to be enabled to run.")
		return SS_INIT_NO_NEED

	try
		// Initialize the auxtools library
		AUXTOOLS_CHECK(AUXLUA)

		// Set the wrappers for setting vars and calling procs
		__lua_set_set_var_wrapper("/proc/wrap_lua_set_var")
		__lua_set_datum_proc_call_wrapper("/proc/wrap_lua_datum_proc_call")
		__lua_set_global_proc_call_wrapper("/proc/wrap_lua_global_proc_call")
		__lua_set_print_wrapper("/proc/wrap_lua_print")
		return SS_INIT_SUCCESS
	catch(var/exception/e)
		// Something went wrong, best not allow the subsystem to run
		warning("Error initializing SSlua: [e.name]")
		return SS_INIT_FAILURE

/datum/controller/subsystem/lua/OnConfigLoad()
	// Read the paths from the config file
	var/list/lua_path = list()
	var/list/config_paths = CONFIG_GET(str_list/lua_path)
	for(var/path in config_paths)
		lua_path += path
	world.SetConfig("env", "LUAU_PATH", jointext(lua_path, ";"))

/datum/controller/subsystem/lua/Shutdown()
	AUXTOOLS_SHUTDOWN(AUXLUA)

/datum/controller/subsystem/lua/proc/queue_resume(datum/lua_state/state, index, arguments)
	if(!initialized)
		return
	if(!istype(state))
		return
	if(!arguments)
		arguments = list()
	else if(!islist(arguments))
		arguments = list(arguments)
	resumes += list(list("state" = state, "index" = index, "arguments" = arguments))

/datum/controller/subsystem/lua/proc/kill_task(datum/lua_state/state, list/task_info)
	if(!istype(state))
		return
	if(!islist(task_info))
		return
	if(!(istext(task_info["name"]) && istext(task_info["status"]) && isnum(task_info["index"])))
		return
	switch(task_info["status"])
		if("sleep")
			var/task_index = task_info["index"]
			var/state_index = 1

			// Get the nth sleep in the sleep list corresponding to the target state
			for(var/i in 1 to length(sleeps))
				var/datum/lua_state/sleeping_state = sleeps[i]
				if(sleeping_state == state)
					if(state_index == task_index)
						sleeps.Cut(i, i+1)
						break
					state_index++
		if("yield")
			// Remove the resumt from the resumt list
			for(var/i in 1 to length(resumes))
				var/resume = resumes[i]
				if(resume["state"] == state && resume["index"] == task_info["index"])
					resumes.Cut(i, i+1)
					break
	state.kill_task(task_info)

/datum/controller/subsystem/lua/fire(resumed)
	// Each fire of SSlua awakens every sleeping task in the order they slept,
	// then resumes every yielded task in the order their resumes were queued
	if(!resumed)
		current_run = list("sleeps" = sleeps.Copy(), "resumes" = resumes.Copy())
		sleeps.Cut()
		resumes.Cut()

	gc_guard.Cut()
	var/list/current_sleeps = current_run["sleeps"]
	var/list/affected_states = list()
	while(length(current_sleeps))
		var/datum/lua_state/state = current_sleeps[1]
		current_sleeps.Cut(1,2)
		if(!istype(state))
			continue
		affected_states |= state
		var/result = state.awaken()
		state.log_result(result, verbose = FALSE)

		if(MC_TICK_CHECK)
			break

	if(!length(current_sleeps))
		var/list/current_resumes = current_run["resumes"]
		while(length(current_resumes))
			var/list/resume_params = current_resumes[1]
			current_resumes.Cut(1,2)
			var/datum/lua_state/state = resume_params["state"]
			if(!istype(state))
				continue
			var/index = resume_params["index"]
			if(isnull(index) || !isnum(index))
				continue
			var/arguments = resume_params["arguments"]
			if(!islist(arguments))
				continue
			affected_states |= state
			var/result = state.resume(arglist(list(index) + arguments))
			state.log_result(result, verbose = FALSE)

			if(MC_TICK_CHECK)
				break

	// Update every lua editor TGUI open for each state that had a task awakened or resumed
	for(var/datum/lua_state/state in affected_states)
		INVOKE_ASYNC(state, TYPE_PROC_REF(/datum/lua_state, update_editors))
