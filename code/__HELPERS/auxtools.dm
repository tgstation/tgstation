/// Macro for getting the auxtools library file
#define AUXLUA (world.system_type == MS_WINDOWS ? "auxlua.dll" : __detect_auxtools("auxlua"))

/proc/__detect_auxtools(library)
	if(IsAdminAdvancedProcCall())
		return
	if (fexists("./lib[library].so"))
		return "./lib[library].so"
	else if (fexists("[world.GetConfig("env", "HOME")]/.byond/bin/lib[library].so"))
		return "[world.GetConfig("env", "HOME")]/.byond/bin/lib[library].so"
	else
		CRASH("Could not find lib[library].so")

#define CPU_SIZE 16

/*
#define AUXCPU_DLL (world.system_type == MS_WINDOWS ? "auxcpu_auxtools.dll" : __detect_auxtools("auxcpu_auxtools"))

/proc/current_true_cpu()
	CRASH()

/proc/current_cpu_index()
	CRASH()

/proc/true_cpu_at_index(index)
	CRASH()

/proc/cpu_values()
	CRASH()

/* don't use this for now
/proc/reset_cpu_table()
	CRASH()
*/

var/static/did_auxtools_init = FALSE

/world/proc/setup_external_cpu()
	var/init_result = call_ext(AUXCPU_DLL, "auxtools_init")()
	if(init_result != "SUCCESS")
		world.log << "auxtools failed to init: [init_result]"
		return FALSE
	world.log << "auxcpu initialized"
	did_auxtools_init = TRUE
	return TRUE

/world/proc/cleanup_external_cpu()
	if(did_auxtools_init)
		call_ext(AUXCPU_DLL, "auxtools_shutdown")()
		did_auxtools_init = FALSE

*/

#define AUXCPU_DLL (world.system_type == MS_WINDOWS ? "auxcpu_byondapi.dll" : __detect_auxtools("auxcpu_byondapi"))
#if DM_VERSION >= 516
/proc/current_true_cpu()
	var/static/__current_true_cpu
	return call_ext(__current_true_cpu ||= load_ext(AUXCPU_DLL, "byond:current_true_cpu"))()

/proc/current_cpu_index()
	var/static/__current_cpu_index
	var/actual_index = call_ext(__current_cpu_index ||= load_ext(AUXCPU_DLL, "byond:current_cpu_index"))()
	return WRAP(actual_index + 1, 1, CPU_SIZE + 1)

/proc/true_cpu_at_index(index)
	var/static/__true_cpu_at_index
	var/actual_index = WRAP(index - 1, 0, CPU_SIZE)
	return call_ext(__true_cpu_at_index ||= load_ext(AUXCPU_DLL, "byond:true_cpu_at_index"))(actual_index)

/proc/cpu_values()
	var/static/__cpu_values
	return call_ext(__cpu_values ||= load_ext(AUXCPU_DLL, "byond:cpu_values"))()

// don't use this for now
/*
var/global/__reset_cpu_table
#define reset_cpu_table(...) call_ext(__reset_cpu_table ||= load_ext(AUXCPU_DLL, "byond:reset_cpu_table"))()
*/

#else

/proc/current_true_cpu()
	return call_ext(AUXCPU_DLL, "byond:current_true_cpu")()

/proc/current_cpu_index()
	var/actual_index = call_ext(AUXCPU_DLL, "byond:current_cpu_index")()
	return WRAP(actual_index + 1, 1, CPU_SIZE + 1)

/proc/true_cpu_at_index(index)
	var/actual_index = WRAP(index - 1, 0, CPU_SIZE)
	return call_ext(AUXCPU_DLL, "byond:true_cpu_at_index")(actual_index)

/proc/cpu_values()
	return call_ext(AUXCPU_DLL, "byond:cpu_values")()

// don't use this for now
/* #define reset_cpu_table(...) call_ext(AUXCPU_DLL, "byond:reset_cpu_table")() */
#endif

/world/proc/setup_external_cpu()
	if(!call_ext(AUXCPU_DLL, "byond:find_signatures")())
		world.log << "auxcpu failed to find signatures"
		return FALSE
	world.log << "signatures found"
	return TRUE

/world/proc/cleanup_external_cpu()
	return

/proc/meowtonin_stack_trace(message, source, line, full_info)
    var/list/info = list("[message || "N/A"]")
    if(istext(source))
        info += "\tsource: [source]"
        if(line)
            info += "\tline: [line]"
    if(full_info)
        world.log << "\n=== (panic start) ===\n[full_info]\n=== (panic end) ===\n"
    CRASH(jointext(info, "\n"))

