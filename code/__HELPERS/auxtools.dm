/// Macro for getting the auxtools library file
#define AUXLIB(name) (world.system_type == MS_WINDOWS ? "[#name].dll" : __detect_auxtools(#name))
#define AUXLUA AUXLIB(auxlua)
#define AUXCOV AUXLIB(auxcov)

/proc/__detect_auxtools(library)
	if(IsAdminAdvancedProcCall())
		return
	if (fexists("./lib[library].so"))
		return "./lib[library].so"
	else if (fexists("[world.GetConfig("env", "HOME")]/.byond/bin/lib[library].so"))
		return "[world.GetConfig("env", "HOME")]/.byond/bin/lib[library].so"
	else
		CRASH("Could not find lib[library].so")
