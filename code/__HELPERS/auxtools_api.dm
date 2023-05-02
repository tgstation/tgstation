#define AUXTOOLS_FULL_INIT 2
#define AUXTOOLS_PARTIAL_INIT 1

GLOBAL_LIST(auxtools_initialized)
GLOBAL_PROTECT(auxtools_initialized)

#define AUXTOOLS_CHECK_NO_CONFIG(LIB)\
	LAZYINITLIST(GLOB.auxtools_initialized);\
	if (GLOB.auxtools_initialized[LIB] != AUXTOOLS_FULL_INIT) {\
		if (fexists(LIB)) {\
			var/string = LIBCALL(LIB,"auxtools_init")();\
			if(findtext(string, "SUCCESS")) {\
				GLOB.auxtools_initialized[LIB] = AUXTOOLS_FULL_INIT;\
			} else {\
				CRASH(string);\
			}\
		} else {\
			CRASH("No file named [LIB] found!")\
		}\
	}

#define AUXTOOLS_CHECK(LIB)\
	if (!CONFIG_GET(flag/auxtools_enabled)) {\
		CRASH("Auxtools is not enabled in config!");\
	}\
	AUXTOOLS_CHECK_NO_CONFIG(LIB)

#define AUXTOOLS_SHUTDOWN(LIB)\
	LAZYINITLIST(GLOB.auxtools_initialized);\
	if (GLOB.auxtools_initialized[LIB] == AUXTOOLS_FULL_INIT && fexists(LIB)){\
		LIBCALL(LIB,"auxtools_shutdown")();\
		GLOB.auxtools_initialized[LIB] = AUXTOOLS_PARTIAL_INIT;\
	}\

#define AUXTOOLS_FULL_SHUTDOWN(LIB)\
	LAZYINITLIST(GLOB.auxtools_initialized);\
	if (GLOB.auxtools_initialized[LIB] && fexists(LIB)){\
		LIBCALL(LIB,"auxtools_full_shutdown")();\
		GLOB.auxtools_initialized[LIB] = FALSE;\
	}

/proc/auxtools_stack_trace(msg)
	CRASH(msg)

/proc/auxtools_expr_stub()
	CRASH("auxtools not loaded")

/proc/enable_debugging(mode, port)
	CRASH("auxtools not loaded")

/proc/enable_code_coverage()
	CRASH("auxtools not loaded")
