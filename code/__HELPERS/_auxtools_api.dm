#define AUXTOOLS_FULL_INIT 2
#define AUXTOOLS_PARTIAL_INIT 1

GLOBAL_LIST_EMPTY(auxtools_initialized)

#define AUXTOOLS_CHECK(LIB)\
	if (GLOB.auxtools_initialized[LIB] != AUXTOOLS_FULL_INIT) {\
		if (fexists(LIB)) {\
			var/string = call(LIB,"auxtools_init")();\
			if(findtext(string, "SUCCESS")) {\
				GLOB.auxtools_initialized[LIB] = AUXTOOLS_FULL_INIT;\
			} else {\
				CRASH(string);\
			}\
		} else {\
			CRASH("No file named [LIB] found!")\
		}\
	}\

#define AUXTOOLS_SHUTDOWN(LIB)\
	if (GLOB.auxtools_initialized[LIB] == AUXTOOLS_FULL_INIT && fexists(LIB)){\
		call(LIB,"auxtools_shutdown")();\
		GLOB.auxtools_initialized[LIB] = AUXTOOLS_PARTIAL_INIT;\
	}\

#define AUXTOOLS_FULL_SHUTDOWN(LIB)\
	if (GLOB.auxtools_initialized[LIB] && fexists(LIB)){\
		call(LIB,"auxtools_full_shutdown")();\
		GLOB.auxtools_initialized[LIB] = FALSE;\
	}\
