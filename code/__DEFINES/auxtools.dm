#define AUXLUA (world.system_type == MS_WINDOWS ? "auxlua.dll" : __detect_auxtools("auxlua"))

/proc/__detect_auxtools(library)
	if (fexists("./lib[library].so"))
		return "./lib[library].so"
	else if (fexists("[world.GetConfig("env", "HOME")]/.byond/bin/lib[library].so"))
		return "[world.GetConfig("env", "HOME")]/.byond/bin/lib[library].so"
	else
		CRASH("Could not find lib[library].so")
