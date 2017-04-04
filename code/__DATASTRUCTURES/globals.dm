/datum/global_vars
    var/list/protected_varlist

/datum/global_vars/vv_get_var(var_name)
	if(var_name in protected_varlist)
		return debug_variable(var_name, "SECRET", 0, src)
	return ..()

/datum/global_vars/vv_edit_var(var_name, var_value)
	if(var_name in protected_varlist)
		return FALSE
	return ..()

/datum/global_vars/proc/InitEverything()
    var/datum/exclude_these = new
    var/list/check_these = vars - exclude_these.vars - "protected_varlist"
    qdel(exclude_these)
    protected_varlist = list("protected_varlist")
    for(var/I in check_these)
        var/start_tick = world.time
        call(src, "InitGlobal[I]")()
        var/end_tick = world.time
        if(end_tick - start_tick)
            warning("Global [I] slept during initialization!")

#define GLOBAL_MANAGED(X, InitValue)\
/datum/global_vars/proc/InitGlobal##X(){\
    ##X = ##InitValue;\
}
#define GLOBAL_UNMANAGED(X, InitValue) /datum/global_vars/proc/InitGlobal##X()

#ifndef TESTING
#define GLOBAL_PROTECT(X)\
/datum/global_vars/InitGlobal##X(){\
    ..();\
    protected_varlist += #X;\
}
#else
#define GLOBAL_PROTECT(X)
#endif

#define GLOBAL_REAL(X, Typepath) var/global##Typepath/##X

GLOBAL_REAL(GLOB, /datum/global_vars);

#define GLOBAL_RAW(X) /datum/global_vars/var/static##X

#define GLOBAL_VAR_INIT(X, InitValue) GLOBAL_RAW(/##X); GLOBAL_MANAGED(X, InitValue)

#define GLOBAL_VAR_CONST(X, InitValue) GLOBAL_RAW(/const/##X) = InitValue; GLOBAL_UNMANAGED(X, InitValue)

#define GLOBAL_LIST_INIT(X, InitValue) GLOBAL_RAW(/list/##X); GLOBAL_MANAGED(X, InitValue)

#define GLOBAL_LIST_EMPTY(X) GLOBAL_LIST_INIT(X, list())

#define GLOBAL_DATUM_INIT(X, Typepath, InitValue) GLOBAL_RAW(Typepath/##X); GLOBAL_MANAGED(X, InitValue)

#define GLOBAL_VAR(X) GLOBAL_RAW(/##X); GLOBAL_MANAGED(X, null)

#define GLOBAL_LIST(X) GLOBAL_RAW(/list/##X); GLOBAL_MANAGED(X, null)

#define GLOBAL_DATUM(X, Typepath) GLOBAL_RAW(Typepath/##X); GLOBAL_MANAGED(X, null)