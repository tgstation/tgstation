SUBSYSTEM_DEF(lua)
	name = "Lua Scripting"
	runlevels = RUNLEVEL_LOBBY | RUNLEVELS_DEFAULT
	wait = 0.1 SECONDS

	/// A list of all lua states
	var/list/datum/lua_state/states = list()

	/// A list of open editors, with each key in the list associated with a list of editors.
	/// Tracks which UIs are open for each state so that they can be updated whenever
	/// code is run in the state.
	var/list/editors

	var/list/sleeps = list()
	var/list/resumes = list()

	var/list/current_run = list()
	var/list/current_states_run = list()

	var/list/needs_gc_cycle = list()

/datum/controller/subsystem/lua/Initialize()
	DREAMLUAU_SET_EXECUTION_LIMIT_SECS(5)
	// Set wrappers to ensure that lua scripts are subject to the same safety restrictions as other admin tooling
	DREAMLUAU_SET_NEW_WRAPPER("/proc/_new")
	DREAMLUAU_SET_VAR_GET_WRAPPER("/proc/wrap_lua_get_var")
	DREAMLUAU_SET_VAR_SET_WRAPPER("/proc/wrap_lua_set_var")
	DREAMLUAU_SET_OBJECT_CALL_WRAPPER("/proc/wrap_lua_datum_proc_call")
	DREAMLUAU_SET_GLOBAL_CALL_WRAPPER("/proc/wrap_lua_global_proc_call")
	// Set the print wrapper, as otherwise, the print function is meaningless
	DREAMLUAU_SET_PRINT_WRAPPER("/proc/wrap_lua_print")
	return SS_INIT_SUCCESS

/datum/controller/subsystem/lua/OnConfigLoad()
	// Read the paths from the config file
	var/list/lua_path = list()
	var/list/config_paths = CONFIG_GET(str_list/lua_path)
	for(var/path in config_paths)
		lua_path += path
	world.SetConfig("env", "LUAU_PATH", jointext(lua_path, ";"))

/datum/controller/subsystem/lua/proc/queue_resume(datum/lua_state/state, index, arguments)
	if(!initialized)
		return
	if(!istype(state))
		return
	if(!arguments)
		arguments = list()
	else if(!islist(arguments))
		arguments = list(arguments)
	else
		var/list/args_list = arguments
		arguments = args_list.Copy()
	resumes += list(list("state" = state, "index" = index, "arguments" = arguments))

/datum/controller/subsystem/lua/proc/kill_task(datum/lua_state/state, is_sleep, index)
	if(!istype(state))
		return
	if(is_sleep)
		var/state_index = 1

		// Get the nth sleep in the sleep list corresponding to the target state
		for(var/i in 1 to length(sleeps))
			var/datum/lua_state/sleeping_state = sleeps[i]
			if(sleeping_state == state)
				if(state_index == index)
					sleeps.Cut(i, i+1)
					break
				state_index++
	else
		// Remove the resumt from the resumt list
		for(var/i in 1 to length(resumes))
			var/resume = resumes[i]
			if(resume["state"] == state && resume["index"] == index)
				resumes.Cut(i, i+1)
				break
	state.kill_task(is_sleep, index)

/datum/controller/subsystem/lua/fire(resumed)
	// Each fire of SSlua awakens every sleeping task in the order they slept,
	// then resumes every yielded task in the order their resumes were queued
	if(!resumed)
		current_run = list("sleeps" = sleeps.Copy(), "resumes" = resumes.Copy())
		current_states_run = states.Copy()
		sleeps.Cut()
		resumes.Cut()

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

	while(length(current_states_run))
		var/datum/lua_state/state = current_states_run[current_states_run.len]
		current_states_run.len--
		state.process(wait)
		if(MC_TICK_CHECK)
			break

	while(length(needs_gc_cycle))
		var/datum/lua_state/state = needs_gc_cycle[needs_gc_cycle.len]
		needs_gc_cycle.len--
		state.collect_garbage()

	// Update every lua editor TGUI open for each state that had a task awakened or resumed
	for(var/datum/lua_state/state in affected_states)
		INVOKE_ASYNC(state, TYPE_PROC_REF(/datum/lua_state, update_editors))

/datum/controller/subsystem/lua/proc/log_involved_runtime(exception/runtime, list/desclines, list/lua_stacks)
	var/list/json_data = list("status" = "runtime", "file" = runtime.file, "line" = runtime.line, "message" = runtime.name, "stack" = list())
	var/level = 1
	for(var/line in desclines)
		line = copytext(line, 3)
		if(starts_with_any(line, list(
				"/datum/lua_state (/datum/lua_state): load script",
				"/datum/lua_state (/datum/lua_state): call function",
				"/datum/lua_state (/datum/lua_state): awaken",
				"/datum/lua_state (/datum/lua_state): resume"
			)))
			json_data["stack"] += lua_stacks[level]
			level++
		json_data["stack"] += line
	for(var/datum/weakref/state_ref as anything in GLOB.lua_state_stack)
		var/datum/lua_state/state = state_ref.resolve()
		if(!state)
			continue
		state.log_result(json_data)
	return
