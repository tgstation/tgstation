/datum/global_vars/proc/InitEverything()
    var/datum/exclude_these = new
    for(var/I in (vars - exclude_these.vars))
        call(src, "InitGlobal[I]")()
    qdel(exclude_these)

#define GLOBAL_MANAGED(X, InitValue)\
/datum/global_vars/proc/InitGlobal##X(){\
    ##X = ##InitValue;\
}

#define GLOBAL_REAL(X, Typepath) var/global##Typepath/##X

GLOBAL_REAL(SLOTH, /datum/global_vars)

#define GLOBAL_RAW(X) /datum/global_vars/var##X;

#define GLOBAL_VAR_INIT(X, InitValue) GLOBAL_RAW(/##X) GLOBAL_MANAGED(X, InitValue)

#define GLOBAL_LIST_INIT(X, InitValue) GLOBAL_RAW(/list/##X) GLOBAL_MANAGED(X, InitValue)

#define GLOBAL_DATUM_INIT(X, Typepath, InitValue) GLOBAL_RAW(Typepath/##X) GLOBAL_MANAGED(X, InitValue)

#define GLOBAL_VAR(X) GLOBAL_RAW(/##X) GLOBAL_MANAGED(X, null)

#define GLOBAL_LIST(X) GLOBAL_RAW(/list/##X) GLOBAL_MANAGED(X, null)

#define GLOBAL_DATUM(X, Typepath) GLOBAL_RAW(Typepath/##X) GLOBAL_MANAGED(X, null)