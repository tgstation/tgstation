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

#define AUXCPU_DLL (world.GetConfig("env", "AUXCPU_DLL") || (world.system_type == MS_WINDOWS ? "../../auxcpu_auxtools.dll" : "../target/i686-pc-windows-msvc/release/libauxcpu_auxtools.so"))

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

/proc/setup()
	var/init_result = call_ext(AUXCPU_DLL, "auxtools_init")()
	if(init_result != "SUCCESS")
		world.log << "auxtools failed to init: [init_result]"
		return FALSE
	world.log << "auxcpu initialized"
	did_auxtools_init = TRUE
	return TRUE

/proc/cleanup()
	if(did_auxtools_init)
		call_ext(AUXCPU_DLL, "auxtools_shutdown")()
		did_auxtools_init = FALSE

/world/New()
	if(!setup())
		del(src)
		return
	return ..()

/world/Del()
	cleanup()
	return ..()
